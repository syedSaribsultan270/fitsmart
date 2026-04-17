import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/theme_extensions.dart';
import '../../../core/widgets/liquid_glass.dart';
import '../../../core/widgets/spark_mascot.dart';
import '../../../providers/mascot_provider.dart';
import '../../../providers/gemini_provider.dart';
import '../../../core/utils/mime_utils.dart';
import '../../../providers/food_knowledge_provider.dart';
import '../../../data/database/database_provider.dart';
import '../../../services/auth_service.dart';
import '../../../services/firestore_service.dart';
import '../../../services/user_context_service.dart';
import '../../../services/ai_orchestrator_service.dart'
    show ExecutedToolCall, SuggestedMealCard;
import '../../../services/ai_tools/ai_tool.dart' show PendingToolCall;
import '../../../services/ai_tools/log_meal_tool.dart';
import '../../../services/analytics_service.dart';
import '../../../services/snackbar_service.dart';
import '../../../services/subscription_service.dart';
import '../widgets/tool_ui.dart';

// ── Data Models ────────────────────────────────────────────────────────────

class _ChatMessage {
  final String text;
  final bool isAi;
  final DateTime timestamp;
  final Uint8List? imageBytes; // ephemeral — not persisted
  final bool isError;
  final String? failedUserText;
  final Uint8List? failedImageBytes;
  final String? failedMimeType;
  final List<String> suggestions;
  /// When the AI invoked a write tool, the receipt is attached to the
  /// message that displayed the final text. Renders as an inline card
  /// with an Undo button for 5 seconds. Not persisted across sessions.
  final List<ExecutedToolCall> toolReceipts;
  /// Opt-in meal cards the AI proposed via `suggest_meal_card`. User taps
  /// to open the log confirmation sheet. Not persisted.
  final List<SuggestedMealCard> mealSuggestions;

  const _ChatMessage({
    required this.text,
    required this.isAi,
    required this.timestamp,
    this.imageBytes,
    this.isError = false,
    this.failedUserText,
    this.failedImageBytes,
    this.failedMimeType,
    this.suggestions = const [],
    this.toolReceipts = const [],
    this.mealSuggestions = const [],
  });

  Map<String, dynamic> toJson() => {
        'text': text,
        'isAi': isAi,
        'timestamp': timestamp.toIso8601String(),
        'isError': isError,
        'failedUserText': failedUserText,
        'suggestions': suggestions,
        // imageBytes intentionally omitted — too large to persist
      };

  factory _ChatMessage.fromJson(Map<String, dynamic> json) => _ChatMessage(
        text: json['text'] as String? ?? '',
        isAi: json['isAi'] as bool? ?? true,
        timestamp: json['timestamp'] != null
            ? DateTime.tryParse(json['timestamp'] as String) ?? DateTime.now()
            : DateTime.now(),
        isError: json['isError'] as bool? ?? false,
        failedUserText: json['failedUserText'] as String?,
        suggestions: (json['suggestions'] as List?)?.cast<String>() ?? [],
      );
}

class _Conversation {
  final String id;
  String title;
  final DateTime createdAt;
  DateTime updatedAt;
  final List<_ChatMessage> messages;
  final List<Map<String, String>> history;

  _Conversation({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.updatedAt,
    List<_ChatMessage>? messages,
    List<Map<String, String>>? history,
  })  : messages = messages ?? [],
        history = history ?? [];

  factory _Conversation.fresh() {
    final now = DateTime.now();
    return _Conversation(
      id: now.millisecondsSinceEpoch.toString(),
      title: 'New chat',
      createdAt: now,
      updatedAt: now,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'messages': messages.map((m) => m.toJson()).toList(),
        'history': history,
      };

  factory _Conversation.fromJson(Map<String, dynamic> json) => _Conversation(
        id: json['id'] as String? ?? DateTime.now().millisecondsSinceEpoch.toString(),
        title: json['title'] as String? ?? 'Chat',
        createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
        updatedAt: DateTime.tryParse(json['updatedAt'] as String? ?? '') ?? DateTime.now(),
        messages: (json['messages'] as List?)
                ?.map((e) => _ChatMessage.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
        history: (json['history'] as List?)
                ?.map((e) => Map<String, String>.from(e as Map))
                .toList() ??
            [],
      );
}

// ── Constants ─────────────────────────────────────────────────────────────

const _welcomeText =
    'Hey! I\'m your FitSmart AI coach 🤖\n\nI have full access to your nutrition logs, workout history, and progress data. Ask me anything about your fitness journey — I\'ll give you personalized, data-driven answers.\n\nWhat\'s on your mind?';

const _suggestions = [
  '🍽️  What should I eat before my workout?',
  '💪  Why am I not seeing muscle gains?',
  '🔥  How do I break through a plateau?',
  '😴  How does sleep affect fat loss?',
  '📊  Analyze my nutrition this week',
  '🏋️  Suggest a deload week workout',
];

// ── Main Screen ────────────────────────────────────────────────────────────

class AiCoachScreen extends ConsumerStatefulWidget {
  const AiCoachScreen({super.key});

  @override
  ConsumerState<AiCoachScreen> createState() => _AiCoachScreenState();
}

class _AiCoachScreenState extends ConsumerState<AiCoachScreen> {
  final _messageCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  List<_Conversation> _conversations = [];
  int _activeIdx = 0;
  _Conversation? _pendingConv; // unsaved new chat, not yet in _conversations
  bool _isLoading = true;
  bool _isTyping = false;
  bool _showScrollToBottom = false;
  DateTime? _lastSentAt;

  static const _sendCooldown = Duration(seconds: 3);
  // Old flat key — NOT per-user. Kept only for one-time migration on upgrade.
  static const _prefsKeyLegacyV2 = 'ai_conversations_v2';
  static const _legacyMsgKey = 'ai_coach_messages';
  static const _legacyHistKey = 'ai_coach_history';

  /// Per-user prefs key — scoped to the signed-in UID so that switching
  /// accounts on the same device NEVER shows another user's conversations.
  String get _prefsKey {
    final uid = AuthService.uid;
    return uid != null ? 'ai_conversations_v3_$uid' : 'ai_conversations_v3_anon';
  }

  bool get _isPending => _pendingConv != null;
  _Conversation get _active => _pendingConv ?? _conversations[_activeIdx];
  List<_ChatMessage> get _messages => _active.messages;

  @override
  void initState() {
    super.initState();
    _scrollCtrl.addListener(_onScroll);
    _loadChats();
  }

  @override
  void dispose() {
    _messageCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollCtrl.hasClients) return;
    final atBottom =
        _scrollCtrl.position.pixels >= _scrollCtrl.position.maxScrollExtent - 80;
    final shouldShow = !atBottom && _messages.length > 6;
    if (_showScrollToBottom != shouldShow) {
      setState(() => _showScrollToBottom = shouldShow);
    }
  }

  // ── Persistence ──────────────────────────────────────────────────────────

  Future<void> _loadChats() async {
    final prefs = await SharedPreferences.getInstance();

    // ── Legacy v1 migration (ai_coach_messages → per-user key) ────────────
    // Migrate the very old single-chat format, saving into the UID-scoped key.
    final legacyMsg = prefs.getString(_legacyMsgKey);
    if (legacyMsg != null) {
      try {
        final legacyHist = prefs.getString(_legacyHistKey);
        final msgList = jsonDecode(legacyMsg) as List;
        final histList = legacyHist != null
            ? (jsonDecode(legacyHist) as List)
                .map((e) => Map<String, String>.from(e as Map))
                .toList()
            : <Map<String, String>>[];

        final now = DateTime.now();
        final legacy = _Conversation(
          id: '0',
          title: 'Previous chat',
          createdAt: now,
          updatedAt: now,
          messages: msgList
              .map((e) => _ChatMessage(
                    text: e['text'] as String,
                    isAi: e['isAi'] as bool,
                    timestamp: now,
                    suggestions: (e['suggestions'] as List?)?.cast<String>() ?? [],
                  ))
              .toList(),
          history: histList,
        );

        await prefs.setString(_prefsKey, jsonEncode([legacy.toJson()]));
        await prefs.remove(_legacyMsgKey);
        await prefs.remove(_legacyHistKey);
      } catch (_) {}
    }

    // ── Legacy v2 migration (shared key → per-user key) ───────────────────
    // The old 'ai_conversations_v2' key was shared across all accounts on a
    // device. Migrate it into the UID-scoped key ONLY when the stored
    // onboarding_uid matches the current user (i.e. this device's data
    // belongs to them), then delete the shared key so no future sign-in
    // by a different account can ever inherit it.
    if (prefs.getString(_prefsKey) == null) {
      final legacyV2 = prefs.getString(_prefsKeyLegacyV2);
      if (legacyV2 != null) {
        final storedUid = prefs.getString('onboarding_uid');
        final currentUid = AuthService.uid;
        if (currentUid != null && currentUid == storedUid) {
          // Safe to migrate — the legacy data belongs to the current user.
          await prefs.setString(_prefsKey, legacyV2);
        }
        // Remove the shared key regardless so no other account ever sees it.
        await prefs.remove(_prefsKeyLegacyV2);
      }
    }

    // ── Step 1: load local data (instant) ─────────────────────────────────
    List<_Conversation> local = [];
    final saved = prefs.getString(_prefsKey);
    if (saved != null) {
      try {
        final list = jsonDecode(saved) as List;
        local = list
            .map((e) => _Conversation.fromJson(e as Map<String, dynamic>))
            .toList();
      } catch (e) {
        debugPrint('[AiCoach] local load failed: $e');
      }
    }

    // Show local conversations immediately so the screen is responsive,
    // and always open on a fresh pending chat (never re-open the last chat).
    if (mounted) {
      setState(() {
        _conversations = local;
        _pendingConv = _Conversation.fresh()
          ..messages.add(_ChatMessage(
            text: _welcomeText,
            isAi: true,
            timestamp: DateTime.now(),
          ));
        _isLoading = false;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    }

    // ── Step 2: ALWAYS check Firestore and merge ───────────────────────────
    // This recovers chats from past sessions, other devices, or after local
    // data was cleared. Only updates the history list — never changes the
    // active view (user stays on their pending new chat).
    final uid = AuthService.uid;
    if (uid != null) {
      try {
        final remote = await FirestoreService.getConversations(uid);
        if (remote.isNotEmpty) {
          final remoteLoaded = remote.map((e) => _Conversation.fromJson(e)).toList();
          final localIds = local.map((c) => c.id).toSet();
          final merged = [...local];
          for (final rc in remoteLoaded) {
            if (!localIds.contains(rc.id)) merged.add(rc);
          }
          merged.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

          if (merged.length > local.length && mounted) {
            await prefs.setString(
              _prefsKey,
              jsonEncode(merged.map((c) => c.toJson()).toList()),
            );
            setState(() {
              _conversations = merged;
              // _pendingConv stays — user remains on the new chat
            });
          }
        }
      } catch (e) {
        debugPrint('[AiCoach] Firestore load failed: $e');
      }
    }
  }

  Future<void> _saveChats() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _prefsKey,
      jsonEncode(_conversations.map((c) => c.toJson()).toList()),
    );
    // Mirror to Firestore so chats roam across devices/browsers.
    final uid = AuthService.uid;
    if (uid != null) {
      for (final conv in _conversations) {
        FirestoreService.saveConversation(uid, conv.toJson())
            .catchError((e) => debugPrint('[AiCoach] Firestore save failed: $e'));
      }
    }
  }

  // ── Conversation management ───────────────────────────────────────────────

  void _startFreshConversation() {
    setState(() {
      _pendingConv = _Conversation.fresh()
        ..messages.add(_ChatMessage(
          text: _welcomeText,
          isAi: true,
          timestamp: DateTime.now(),
        ));
      // Don't save — persisted only when the user sends their first message
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  void _switchConversation(int idx) {
    setState(() {
      _pendingConv = null; // discard unsaved chat when switching to history
      _activeIdx = idx;
    });
    Navigator.pop(context);
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  void _deleteConversation(int idx) {
    final convId = _conversations[idx].id;
    setState(() {
      _conversations.removeAt(idx);
      if (!_isPending) {
        // If the deleted chat was the active one, go to pending
        if (idx == _activeIdx) {
          _pendingConv ??= _Conversation.fresh()
            ..messages.add(_ChatMessage(
              text: _welcomeText,
              isAi: true,
              timestamp: DateTime.now(),
            ));
        } else {
          _activeIdx = _activeIdx.clamp(0, (_conversations.length - 1).clamp(0, double.maxFinite.toInt()));
        }
      }
    });
    _saveChats();
    final uid = AuthService.uid;
    if (uid != null) {
      FirestoreService.deleteConversation(uid, convId)
          .catchError((e) => debugPrint('[AiCoach] Firestore delete failed: $e'));
    }
  }

  void _clearActiveChat() {
    final conv = _Conversation.fresh()
      ..messages.add(_ChatMessage(
        text: _welcomeText,
        isAi: true,
        timestamp: DateTime.now(),
      ));
    setState(() {
      _conversations[_activeIdx] = conv;
    });
    _saveChats();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  // ── Messaging ─────────────────────────────────────────────────────────────

  bool get _isCoolingDown =>
      _lastSentAt != null &&
      DateTime.now().difference(_lastSentAt!) < _sendCooldown;

  /// Handle tap on a [MealSuggestionCard] — opens the normal log
  /// confirmation sheet, then fires the actual `log_meal` tool on confirm.
  /// The result surfaces as an inline receipt on the same bubble below
  /// the card, mirroring the regular log flow.
  Future<void> _logSuggestedMeal(SuggestedMealCard card) async {
    final tool = LogMealTool();
    final pending = PendingToolCall(
      id: 'suggest-${card.name}-${DateTime.now().millisecondsSinceEpoch}',
      tool: tool,
      args: card.toLogMealArgs(),
    );
    final approved = await showToolConfirmation(context, pending: pending);
    if (!approved || !mounted) return;
    try {
      final result = await tool.execute(
        <T>(p) => ref.read(p),
        pending.args,
      );
      if (!result.success) {
        SnackbarService.error(
            result.errorMessage ?? 'Could not log that meal.');
        return;
      }
      // Append a receipt to the LAST AI message so the log is visible.
      if (_messages.isNotEmpty && _messages.last.isAi) {
        final last = _messages.last;
        setState(() {
          _active.messages[_active.messages.length - 1] = _ChatMessage(
            text: last.text,
            isAi: last.isAi,
            timestamp: last.timestamp,
            imageBytes: last.imageBytes,
            isError: last.isError,
            failedUserText: last.failedUserText,
            failedImageBytes: last.failedImageBytes,
            failedMimeType: last.failedMimeType,
            suggestions: last.suggestions,
            mealSuggestions: last.mealSuggestions,
            toolReceipts: [
              ...last.toolReceipts,
              ExecutedToolCall(
                tool: tool,
                args: pending.args,
                entityId: result.entityId,
              ),
            ],
          );
        });
      }
      AnalyticsService.instance.track('ai_meal_card_logged', props: {
        'name': card.name,
        'calories': card.calories,
      });
    } catch (e) {
      debugPrint('[AiCoach] logSuggestedMeal failed: $e');
      SnackbarService.error('Could not log that meal.');
    }
  }

  /// Undo a tool receipt. Deletes the entity the AI created and mirrors
  /// to Firestore where applicable. Used as the callback for
  /// [ToolReceiptCard]'s Undo button.
  Future<void> _undoReceipt(ExecutedToolCall receipt) async {
    final id = receipt.entityId;
    if (id == null) return;
    final db = ref.read(databaseProvider);
    final uid = AuthService.uid;

    // Route the undo to the right Drift + Firestore delete based on the
    // tool that executed. (Water logs are aggregates on daily_summaries —
    // undo by adding the negative amount. Read tools never have receipts.)
    switch (receipt.tool.name) {
      case 'log_meal':
        await db.deleteMeal(id);
        // Recompute the meal's deterministic docId to hit Firestore too.
        // We could read cloudId from the row we just inserted, but the row
        // is gone by the time we reach this branch — so instead let the
        // SyncService dedup handle reconciliation on next pull.
        if (uid != null) {
          // Best-effort cloud delete using the known doc-id pattern — we
          // don't have cloudId in hand here, but the dedup-by-id on next
          // sync will catch this. Log the gap explicitly.
          debugPrint('[AiCoach] meal undo — cloud row will be '
              'reconciled on next sync');
        }
        break;
      case 'log_weight':
        await db.deleteWeight(id);
        break;
      case 'log_quick_workout':
        await db.deleteWorkout(id);
        break;
      case 'log_water':
        // Water is an aggregate — roll back by subtracting the ml.
        final ml = (receipt.args['ml'] as num?)?.toInt() ?? 0;
        if (ml > 0) await db.addWater(-ml);
        break;
    }
    AnalyticsService.instance.track('ai_tool_undone', props: {
      'tool': receipt.tool.name,
    });
  }

  Future<void> _sendMessage(
    String text, {
    Uint8List? imageBytes,
    String? mimeType,
  }) async {
    if (text.trim().isEmpty && imageBytes == null) return;
    if (_isCoolingDown) return;

    _lastSentAt = DateTime.now();
    final userText = text.trim().isNotEmpty ? text.trim() : 'Analyze this image';

    // Auto-title the conversation from the first user message
    if (_messages.length == 1) {
      _active.title =
          userText.length > 42 ? '${userText.substring(0, 42)}…' : userText;
    }

    // Promote pending chat into saved history on first real message
    if (_isPending) {
      _conversations.insert(0, _pendingConv!);
      _activeIdx = 0;
      _pendingConv = null;
    }

    setState(() {
      _active.messages.add(_ChatMessage(
        text: userText,
        isAi: false,
        timestamp: DateTime.now(),
        imageBytes: imageBytes,
      ));
      _active.updatedAt = DateTime.now();
      _isTyping = true;
      _messageCtrl.clear();
    });
    _scrollToBottom();
    _saveChats();

    AnalyticsService.instance.track('ai_chat_sent', props: {
      'has_image': imageBytes != null,
      'msg_len': userText.length,
      'history_len': _active.history.length,
    });

    final sw = Stopwatch()..start();

    try {
      final ai = ref.read(aiProvider);
      final userContext = await UserContextService.buildFullContext(ref);
      final kb = ref.read(foodKnowledgeProvider);
      final grounding =
          kb.isLoaded ? kb.buildGroundingContext(userText, maxResults: 8) : null;

      // Text-only path uses tool-use (AI can actually log meals, fetch totals).
      // Vision path stays on the existing chat() flow — tool use with images
      // isn't wired yet, and the meal-photo flow already writes to the DB.
      final String response;
      final List<ExecutedToolCall> receipts;
      final List<SuggestedMealCard> suggestedCards;
      if (imageBytes == null) {
        final reply = await ai.chatWithTools(
          // Pass `ref.read` so tools can query providers from the widget
          // tree's Riverpod container.
          read: <T>(p) => ref.read(p),
          message: userText,
          userContext: userContext,
          history: _active.history,
          confirmWrite: (pending) =>
              showToolConfirmation(context, pending: pending),
        );
        response = reply.text.isNotEmpty
            ? reply.text
            : (reply.executed.isNotEmpty
                ? 'Done. Anything else?'
                : "I couldn't generate a response. Please try again.");
        receipts = reply.executed;
        suggestedCards = reply.suggestedMealCards;
      } else {
        final result = await ai.chat(
          message: userText,
          userContext: userContext,
          history: _active.history,
          imageBytes: imageBytes,
          mimeType: mimeType,
          groundingContext: grounding,
        );
        response = result['response'] as String? ??
            "I couldn't generate a response. Please try again.";
        receipts = const [];
        suggestedCards = const [];
      }

      sw.stop();
      AnalyticsService.instance.track('ai_chat_received', props: {
        'ai_source': ai.lastSource.name,
        'duration_ms': sw.elapsedMilliseconds,
        'resp_len': response.length,
        'tool_count': receipts.length,
        'suggestion_count': suggestedCards.length,
      });

      _active.history.add({'role': 'user', 'content': userText});
      _active.history.add({'role': 'model', 'content': response});

      if (mounted) {
        setState(() {
          _isTyping = false;
          _active.messages.add(_ChatMessage(
            text: response,
            isAi: true,
            timestamp: DateTime.now(),
            toolReceipts: receipts,
            mealSuggestions: suggestedCards,
          ));
          _active.updatedAt = DateTime.now();
        });
        _scrollToBottom();
        _saveChats();
      }
    } on FreeTierLimitException {
      sw.stop();
      if (mounted) {
        setState(() {
          _isTyping = false;
          if (_messages.isNotEmpty && !_messages.last.isAi) {
            _active.messages.removeLast();
          }
        });
        context.push('/paywall', extra: 'unlimited_ai');
      }
    } catch (e) {
      sw.stop();
      AnalyticsService.instance.track('ai_chat_error', props: {
        'error': e.toString().substring(0, e.toString().length.clamp(0, 200)),
        'duration_ms': sw.elapsedMilliseconds,
      });
      debugPrint('[AiCoach] chat error: $e');
      if (mounted) {
        setState(() {
          _isTyping = false;
          _active.messages.add(_ChatMessage(
            text: 'Hmm, I\'m having a moment 😅 Tap retry to try again.',
            isAi: true,
            timestamp: DateTime.now(),
            isError: true,
            failedUserText: userText,
            failedImageBytes: imageBytes,
            failedMimeType: mimeType,
          ));
        });
        _scrollToBottom();
        _saveChats();
      }
    }
  }

  Future<void> _pickAndSendImage() async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );
      if (picked == null) return;
      final bytes = await picked.readAsBytes();
      final mimeType = picked.mimeType ?? mimeTypeFromPath(picked.name);
      await _sendMessage(_messageCtrl.text, imageBytes: bytes, mimeType: mimeType);
    } catch (e) {
      debugPrint('Image picker error: $e');
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _showConversationsSheet() {
    AnalyticsService.instance.tap('view_chat_history', screen: 'ai_coach');
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ConversationsSheet(
        conversations: _conversations,
        activeIdx: _isPending ? -1 : _activeIdx,
        onSelect: _switchConversation,
        onDelete: _deleteConversation,
        onNew: () {
          Navigator.pop(context);
          _startFreshConversation();
        },
      ),
    );
  }

  void _confirmClear() {
    AnalyticsService.instance.dialogOpened('clear_chat');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear this chat?'),
        content: const Text('All messages will be deleted and the conversation will reset.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              AnalyticsService.instance.dialogAction('clear_chat', 'confirmed');
              _clearActiveChat();
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: colors.bgPrimary,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final items = _buildItemList();

    return Scaffold(
      backgroundColor: colors.bgPrimary,
      appBar: LiquidAppBar(
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.chat_bubble_outline_rounded, size: 22),
          color: colors.textSecondary,
          tooltip: 'All chats',
          onPressed: _showConversationsSheet,
        ),
        title: GestureDetector(
          onTap: _showConversationsSheet,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Procedural mascot replaces the static 🤖 emoji.
              // Thinking state takes precedence (locally driven by _isTyping).
              // Otherwise, reflect the global mood — celebrations triggered
              // by workouts, meals, PRs etc. show up here even when the user
              // navigates back to the AI Coach later.
              // .reactive() wires the eyes to the global pointer tracker
              // and layers the random quirk controller on top.
              Consumer(builder: (_, ref, __) {
                final globalMood = ref.watch(mascotMoodProvider);
                final mood = _isTyping ? SparkMood.thinking : globalMood;
                return SparkMascot.reactive(size: 36, mood: mood);
              }),
              const SizedBox(width: AppSpacing.sm),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _active.title,
                      style: AppTypography.bodyMedium
                          .copyWith(fontWeight: FontWeight.w700),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: colors.success,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Online · Context-aware',
                          style: AppTypography.overline.copyWith(
                            color: colors.textTertiary,
                            fontSize: 9,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_comment_outlined, size: 20),
            color: colors.lime,
            tooltip: 'New chat',
            onPressed: _startFreshConversation,
          ),
          if (!_isPending && _messages.length > 1)
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded, size: 20),
              color: colors.textTertiary,
              tooltip: 'Clear chat',
              onPressed: _confirmClear,
            ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // ── Message list ──────────────────────────────────────────
              Expanded(
                child: ListView.builder(
                  controller: _scrollCtrl,
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.pagePadding,
                    AppSpacing.sm,
                    AppSpacing.pagePadding,
                    AppSpacing.pagePadding,
                  ),
                  itemCount: items.length + (_isTyping ? 1 : 0),
                  itemBuilder: (_, i) {
                    if (_isTyping && i == items.length) {
                      return _TypingIndicator().animate().fadeIn(duration: 200.ms);
                    }

                    final item = items[i];

                    // Date separator
                    if (item is DateTime) {
                      return _DateSeparator(date: item);
                    }

                    final msg = item as _ChatMessage;
                    final msgIdx = _messages.indexOf(msg);

                    return _ChatBubble(
                      message: msg,
                      onSuggestionTap: _sendMessage,
                      onUndoReceipt: _undoReceipt,
                      onLogSuggestedMeal: _logSuggestedMeal,
                      onRetry: msg.isError && msg.failedUserText != null
                          ? () {
                              setState(() => _active.messages.removeAt(msgIdx));
                              _sendMessage(
                                msg.failedUserText!,
                                imageBytes: msg.failedImageBytes,
                                mimeType: msg.failedMimeType,
                              );
                            }
                          : null,
                    )
                        .animate(delay: 30.ms)
                        .slideY(
                            begin: 0.06,
                            duration: 250.ms,
                            curve: Curves.easeOut)
                        .fadeIn(duration: 250.ms);
                  },
                ),
              ),

              // ── Suggestion chips (welcome only) ───────────────────────
              if (_messages.length == 1) ...[
                SizedBox(
                  height: 44,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.pagePadding),
                    itemCount: _suggestions.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (_, i) => GestureDetector(
                      onTap: () {
                        final text = _suggestions[i]
                            .replaceFirst(RegExp(r'^[^\s]+\s+'), '');
                        AnalyticsService.instance.tap('suggestion_chip',
                            screen: 'ai_coach', props: {'text': text});
                        _sendMessage(text);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: colors.surfaceCard,
                          borderRadius:
                              BorderRadius.circular(AppRadius.full),
                          border: Border.all(color: colors.surfaceCardBorder),
                        ),
                        child: Text(
                          _suggestions[i],
                          style: AppTypography.caption
                              .copyWith(color: colors.textSecondary),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
              ],

              // ── Input bar ─────────────────────────────────────────────
              _InputBar(
                controller: _messageCtrl,
                isTyping: _isTyping,
                onSend: () => _sendMessage(_messageCtrl.text),
                onImage: _isTyping ? null : _pickAndSendImage,
              ),
            ],
          ),

          // ── Scroll-to-bottom FAB ──────────────────────────────────────
          if (_showScrollToBottom)
            Positioned(
              bottom: 80,
              right: AppSpacing.pagePadding,
              child: GestureDetector(
                onTap: _scrollToBottom,
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: colors.lime,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: colors.lime.withValues(alpha: 0.4),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: colors.textInverse,
                    size: 22,
                  ),
                ),
              ).animate().scale(duration: 150.ms, curve: Curves.easeOut),
            ),
        ],
      ),
    );
  }

  /// Interleaves date separators between messages.
  List<Object> _buildItemList() {
    final result = <Object>[];
    DateTime? lastDate;
    for (final msg in _messages) {
      final d = DateTime(
          msg.timestamp.year, msg.timestamp.month, msg.timestamp.day);
      if (lastDate == null || d != lastDate) {
        result.add(d);
        lastDate = d;
      }
      result.add(msg);
    }
    return result;
  }
}

// ── Conversations sheet ────────────────────────────────────────────────────

class _ConversationsSheet extends StatelessWidget {
  final List<_Conversation> conversations;
  final int activeIdx;
  final void Function(int) onSelect;
  final void Function(int) onDelete;
  final VoidCallback onNew;

  const _ConversationsSheet({
    required this.conversations,
    required this.activeIdx,
    required this.onSelect,
    required this.onDelete,
    required this.onNew,
  });

  String _relativeDate(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inDays == 0) return 'Today';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${dt.day}/${dt.month}/${dt.year.toString().substring(2)}';
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return DraggableScrollableSheet(
      initialChildSize: 0.65,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      expand: false,
      builder: (_, scrollCtrl) => Container(
        decoration: BoxDecoration(
          color: colors.bgSecondary,
          borderRadius:
              const BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
        ),
        child: Column(
          children: [
            // Drag handle
            Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 4),
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: colors.surfaceCardBorder,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
              ),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.pagePadding,
                8,
                AppSpacing.pagePadding,
                12,
              ),
              child: Row(
                children: [
                  Text('Chats', style: AppTypography.h3),
                  const Spacer(),
                  GestureDetector(
                    onTap: onNew,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: colors.limeGlow,
                        borderRadius: BorderRadius.circular(AppRadius.full),
                        border: Border.all(
                            color: colors.lime.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.add_rounded, color: colors.lime, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            'New chat',
                            style: AppTypography.caption.copyWith(
                              color: colors.lime,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Divider(height: 1, color: colors.surfaceCardBorder),

            // List
            Expanded(
              child: conversations.isEmpty
                  ? Center(
                      child: Text(
                        'No chats yet',
                        style: AppTypography.body
                            .copyWith(color: colors.textTertiary),
                      ),
                    )
                  : ListView.separated(
                      controller: scrollCtrl,
                      itemCount: conversations.length,
                      separatorBuilder: (_, __) =>
                          Divider(height: 1, color: colors.surfaceCardBorder),
                      itemBuilder: (_, i) {
                        final conv = conversations[i];
                        final isActive = i == activeIdx;
                        final msgCount =
                            conv.messages.where((m) => !m.isAi).length;

                        return Dismissible(
                          key: Key(conv.id),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            color: colors.errorBg,
                            child: Icon(Icons.delete_outline_rounded,
                                color: colors.error),
                          ),
                          onDismissed: (_) => onDelete(i),
                          child: ListTile(
                            selected: isActive,
                            selectedTileColor: colors.limeGlow,
                            onTap: () => onSelect(i),
                            leading: Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                color: isActive
                                    ? colors.limeGlow
                                    : colors.surfaceCard,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isActive
                                      ? colors.lime.withValues(alpha: 0.5)
                                      : colors.surfaceCardBorder,
                                ),
                              ),
                              child: const Center(
                                  child: Text('🤖',
                                      style: TextStyle(fontSize: 18))),
                            ),
                            title: Text(
                              conv.title,
                              style: AppTypography.bodyMedium.copyWith(
                                fontWeight: isActive
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Text(
                              '$msgCount message${msgCount == 1 ? '' : 's'} · ${_relativeDate(conv.updatedAt)}',
                              style: AppTypography.caption
                                  .copyWith(color: colors.textTertiary),
                            ),
                            trailing: isActive
                                ? Icon(Icons.check_rounded,
                                    color: colors.lime, size: 18)
                                : Icon(Icons.chevron_right_rounded,
                                    color: colors.textTertiary, size: 18),
                          ),
                        );
                      },
                    ),
            ),

            SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
          ],
        ),
      ),
    );
  }
}

// ── Input bar ──────────────────────────────────────────────────────────────

class _InputBar extends StatelessWidget {
  final TextEditingController controller;
  final bool isTyping;
  final VoidCallback onSend;
  final VoidCallback? onImage;

  const _InputBar({
    required this.controller,
    required this.isTyping,
    required this.onSend,
    this.onImage,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return LiquidGlass(
      borderRadius: BorderRadius.zero,
      intensity: GlassIntensity.strong,
      padding: EdgeInsets.fromLTRB(
        AppSpacing.pagePadding,
        AppSpacing.sm,
        AppSpacing.pagePadding,
        MediaQuery.of(context).padding.bottom + AppSpacing.sm,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Image picker
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: GestureDetector(
              onTap: onImage,
              child: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: colors.surfaceCard,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(color: colors.surfaceCardBorder),
                ),
                child: Icon(
                  Icons.image_outlined,
                  color: onImage == null ? colors.textTertiary : colors.lime,
                  size: 20,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),

          // Text field
          Expanded(
            child: TextField(
              controller: controller,
              style: AppTypography.body,
              maxLines: 5,
              minLines: 1,
              textCapitalization: TextCapitalization.sentences,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => onSend(),
              decoration: InputDecoration(
                hintText: 'Message AI Coach...',
                filled: true,
                fillColor: colors.bgPrimary,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  borderSide: BorderSide(color: colors.surfaceCardBorder),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  borderSide: BorderSide(color: colors.surfaceCardBorder),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  borderSide:
                      BorderSide(color: colors.lime, width: 1.5),
                ),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),

          // Send button
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: GestureDetector(
              onTap: isTyping ? null : onSend,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isTyping ? colors.surfaceCard : colors.lime,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(
                  Icons.send_rounded,
                  color: isTyping ? colors.textTertiary : colors.textInverse,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Date separator ─────────────────────────────────────────────────────────

class _DateSeparator extends StatelessWidget {
  final DateTime date;
  const _DateSeparator({required this.date});

  String _label() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    if (date == today) return 'Today';
    if (date == yesterday) return 'Yesterday';
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Row(
        children: [
          Expanded(child: Divider(color: colors.surfaceCardBorder)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Text(
              _label(),
              style: AppTypography.overline
                  .copyWith(color: colors.textTertiary),
            ),
          ),
          Expanded(child: Divider(color: colors.surfaceCardBorder)),
        ],
      ),
    );
  }
}

// ── Chat bubble ────────────────────────────────────────────────────────────

class _ChatBubble extends StatelessWidget {
  final _ChatMessage message;
  final void Function(String) onSuggestionTap;
  final Future<void> Function(ExecutedToolCall) onUndoReceipt;
  final Future<void> Function(SuggestedMealCard) onLogSuggestedMeal;
  final VoidCallback? onRetry;

  const _ChatBubble({
    required this.message,
    required this.onSuggestionTap,
    required this.onUndoReceipt,
    required this.onLogSuggestedMeal,
    this.onRetry,
  });

  String _timeLabel(DateTime dt) {
    final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final m = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    return '$h:$m $period';
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment:
            message.isAi ? CrossAxisAlignment.start : CrossAxisAlignment.end,
        children: [
          // Avatar + bubble row
          Row(
            mainAxisAlignment: message.isAi
                ? MainAxisAlignment.start
                : MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (message.isAi) ...[
                Container(
                  width: 30,
                  height: 30,
                  margin: const EdgeInsets.only(right: AppSpacing.sm, bottom: 2),
                  decoration: BoxDecoration(
                    color: colors.limeGlow,
                    shape: BoxShape.circle,
                    border:
                        Border.all(color: colors.lime.withValues(alpha: 0.3)),
                  ),
                  child: const Center(
                      child: Text('🤖', style: TextStyle(fontSize: 14))),
                ),
              ],
              Flexible(
                child: GestureDetector(
                  onLongPress: () {
                    Clipboard.setData(ClipboardData(text: message.text));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Copied to clipboard'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: AppSpacing.md,
                    ),
                    decoration: BoxDecoration(
                      color: message.isAi ? colors.surfaceCard : colors.lime,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(AppRadius.lg),
                        topRight: const Radius.circular(AppRadius.lg),
                        bottomLeft:
                            Radius.circular(message.isAi ? 4 : AppRadius.lg),
                        bottomRight:
                            Radius.circular(message.isAi ? AppRadius.lg : 4),
                      ),
                      border: message.isAi
                          ? Border.all(color: colors.surfaceCardBorder)
                          : null,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (message.imageBytes != null) ...[
                          ClipRRect(
                            borderRadius:
                                BorderRadius.circular(AppRadius.md),
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                maxWidth:
                                    MediaQuery.of(context).size.width * 0.65,
                                maxHeight:
                                    MediaQuery.of(context).size.width * 0.65,
                              ),
                              child: Image.memory(message.imageBytes!,
                                  fit: BoxFit.cover),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                        ],
                        if (message.isAi)
                          _RichText(text: message.text)
                        else
                          Text(
                            message.text,
                            style: AppTypography.body.copyWith(
                                color: colors.textInverse, height: 1.6),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Timestamp
          Padding(
            padding: EdgeInsets.only(
              top: 4,
              left: message.isAi ? 38 : 0,
            ),
            child: Text(
              _timeLabel(message.timestamp),
              style: AppTypography.overline.copyWith(
                color: colors.textTertiary,
                fontSize: 9,
                letterSpacing: 0.3,
              ),
            ),
          ),

          // Retry button
          if (message.isError && onRetry != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Padding(
              padding: const EdgeInsets.only(left: 40),
              child: GestureDetector(
                onTap: onRetry,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: colors.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppRadius.full),
                    border: Border.all(
                        color: colors.error.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.refresh_rounded,
                          color: colors.error, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        'Retry',
                        style: AppTypography.caption.copyWith(
                            color: colors.error, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],

          // Tool receipt cards — rendered inline under the AI bubble when
          // the AI invoked a write tool this turn. Each has its own 5s undo
          // window; indented to align with the bubble (past the avatar).
          if (message.isAi && message.toolReceipts.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.only(left: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: message.toolReceipts
                    .map((r) => ToolReceiptCard(
                          receipt: r,
                          onUndo: onUndoReceipt,
                        ))
                    .toList(),
              ),
            ),
          ],

          // Opt-in meal suggestion cards — rendered when the AI called
          // `suggest_meal_card` (info question, recommendation, etc.).
          // The user taps Log to open the confirm sheet; nothing persists
          // without that tap.
          if (message.isAi && message.mealSuggestions.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.only(left: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: message.mealSuggestions
                    .map((s) => MealSuggestionCard(
                          card: s,
                          onLog: onLogSuggestedMeal,
                        ))
                    .toList(),
              ),
            ),
          ],

          // Suggestion chips
          if (message.isAi && message.suggestions.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Padding(
              padding: const EdgeInsets.only(left: 40),
              child: Wrap(
                spacing: 8,
                runSpacing: 6,
                children: message.suggestions
                    .map((s) => GestureDetector(
                          onTap: () => onSuggestionTap(s),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: colors.limeGlow,
                              borderRadius:
                                  BorderRadius.circular(AppRadius.full),
                              border: Border.all(
                                  color:
                                      colors.lime.withValues(alpha: 0.3)),
                            ),
                            child: Text(
                              s,
                              style: AppTypography.caption.copyWith(
                                  color: colors.lime,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                        ))
                    .toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Rich text renderer (markdown subset) ───────────────────────────────────

class _RichText extends StatelessWidget {
  final String text;
  const _RichText({required this.text});

  Widget _parseInline(String raw, TextStyle baseStyle, Color boldColor) {
    final boldRegex = RegExp(r'\*\*(.+?)\*\*');
    final spans = <InlineSpan>[];
    int lastEnd = 0;
    for (final m in boldRegex.allMatches(raw)) {
      if (m.start > lastEnd) {
        spans.add(TextSpan(
            text: raw.substring(lastEnd, m.start), style: baseStyle));
      }
      spans.add(TextSpan(
        text: m.group(1),
        style: baseStyle.copyWith(
            color: boldColor, fontWeight: FontWeight.w700),
      ));
      lastEnd = m.end;
    }
    if (lastEnd < raw.length) {
      spans.add(TextSpan(text: raw.substring(lastEnd), style: baseStyle));
    }
    if (spans.length == 1 && spans.first is TextSpan) {
      final ts = spans.first as TextSpan;
      if (ts.children == null) return Text(ts.text ?? '', style: baseStyle);
    }
    return RichText(text: TextSpan(children: spans));
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final lines = text.split('\n');
    final widgets = <Widget>[];

    for (final line in lines) {
      if (line.trim().isEmpty) {
        widgets.add(const SizedBox(height: 6));
        continue;
      }
      if (line.startsWith('### ')) {
        widgets.add(Padding(
          padding: const EdgeInsets.only(top: 10, bottom: 3),
          child: _parseInline(
            line.substring(4),
            AppTypography.bodyMedium.copyWith(
                color: colors.textPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 14.5,
                height: 1.5),
            colors.lime,
          ),
        ));
        continue;
      }
      if (line.startsWith('## ')) {
        widgets.add(Padding(
          padding: const EdgeInsets.only(top: 12, bottom: 4),
          child: _parseInline(
            line.substring(3),
            AppTypography.bodyMedium.copyWith(
                color: colors.textPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 15.5,
                height: 1.5),
            colors.lime,
          ),
        ));
        continue;
      }
      if (line.startsWith('# ')) {
        widgets.add(Padding(
          padding: const EdgeInsets.only(top: 12, bottom: 4),
          child: _parseInline(
            line.substring(2),
            AppTypography.h3.copyWith(height: 1.4),
            colors.lime,
          ),
        ));
        continue;
      }
      final isBullet = line.startsWith('* ') ||
          line.startsWith('- ') ||
          line.startsWith('• ');
      if (isBullet) {
        widgets.add(Padding(
          padding: const EdgeInsets.only(top: 2, bottom: 2),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('•  ',
                  style: AppTypography.body.copyWith(
                      color: colors.lime,
                      height: 1.6,
                      fontWeight: FontWeight.w700)),
              Expanded(
                child: _parseInline(
                  line.substring(2),
                  AppTypography.body
                      .copyWith(color: colors.textPrimary, height: 1.6),
                  colors.lime,
                ),
              ),
            ],
          ),
        ));
        continue;
      }
      widgets.add(_parseInline(
        line,
        AppTypography.body
            .copyWith(color: colors.textPrimary, height: 1.6),
        colors.lime,
      ));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: widgets,
    );
  }
}

// ── Typing indicator ───────────────────────────────────────────────────────

class _TypingIndicator extends StatefulWidget {
  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 30,
            height: 30,
            margin: const EdgeInsets.only(right: AppSpacing.sm, top: 2),
            decoration: BoxDecoration(
              color: colors.limeGlow,
              shape: BoxShape.circle,
              border: Border.all(color: colors.lime.withValues(alpha: 0.3)),
            ),
            child: const Center(
                child: Text('🤖', style: TextStyle(fontSize: 14))),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: colors.surfaceCard,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppRadius.lg),
                topRight: Radius.circular(AppRadius.lg),
                bottomRight: Radius.circular(AppRadius.lg),
                bottomLeft: Radius.circular(4),
              ),
              border: Border.all(color: colors.surfaceCardBorder),
            ),
            // Breathing dots: each dot pulses scale+alpha in a phase-shifted
            // cycle. Reads as "AI thinking" calmly — no jumpy bounce.
            child: AnimatedBuilder(
              animation: _controller,
              builder: (_, __) => Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(3, (i) {
                  // Phase-shift each dot by 0.18 of the cycle.
                  final phase = (_controller.value + i * 0.18) % 1.0;
                  // sin-eased pulse: 0..1..0 over the cycle.
                  final t = (phase < 0.5 ? phase * 2 : (1 - phase) * 2);
                  final scale = 0.85 + 0.4 * t;        // 0.85 → 1.25
                  final alpha = 0.35 + 0.65 * t;       // .35 → 1.0
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: Transform.scale(
                      scale: scale,
                      child: Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          color: colors.lime.withValues(alpha: alpha),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: colors.lime
                                  .withValues(alpha: 0.35 * t),
                              blurRadius: 6,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
