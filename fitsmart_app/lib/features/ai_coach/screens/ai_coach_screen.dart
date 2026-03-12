import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/theme_extensions.dart';
import '../../../providers/gemini_provider.dart';
import '../../../core/utils/mime_utils.dart';
import '../../../providers/food_knowledge_provider.dart';
import '../../../services/user_context_service.dart';

class AiCoachScreen extends ConsumerStatefulWidget {
  const AiCoachScreen({super.key});

  @override
  ConsumerState<AiCoachScreen> createState() => _AiCoachScreenState();
}

class _AiCoachScreenState extends ConsumerState<AiCoachScreen> {
  final _messageCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  final List<_Message> _messages = [];
  final List<Map<String, String>> _history = [];
  bool _isTyping = false;
  DateTime? _lastSentAt;
  static const _sendCooldown = Duration(seconds: 3);

  static const _prefsKey = 'ai_coach_messages';
  static const _historyKey = 'ai_coach_history';

  static const _suggestions = [
    '🍽️  What should I eat before my workout?',
    '💪  Why am I not seeing muscle gains?',
    '🔥  How do I break through a plateau?',
    '😴  How does sleep affect fat loss?',
    '📊  Analyze my nutrition this week',
    '🏋️  Suggest a deload week workout',
  ];

  @override
  void initState() {
    super.initState();
    _loadChat();
  }

  Future<void> _loadChat() async {
    final prefs = await SharedPreferences.getInstance();
    final savedMessages = prefs.getString(_prefsKey);
    final savedHistory = prefs.getString(_historyKey);

    if (savedMessages != null) {
      try {
        final list = jsonDecode(savedMessages) as List;
        final loaded = list
            .map((e) => _Message(
                  text: e['text'] as String,
                  isAi: e['isAi'] as bool,
                  suggestions: (e['suggestions'] as List?)?.cast<String>() ?? [],
                ))
            .toList();
        if (loaded.isNotEmpty && mounted) {
          setState(() => _messages.addAll(loaded));
        }
      } catch (e) { debugPrint('[AiCoach] load saved messages failed: $e'); }
    }

    if (savedHistory != null) {
      try {
        final list = jsonDecode(savedHistory) as List;
        _history.addAll(
          list.map((e) => Map<String, String>.from(e as Map)),
        );
      } catch (e) { debugPrint('[AiCoach] load chat history failed: $e'); }
    }

    // If nothing was loaded, add welcome message
    if (_messages.isEmpty) {
      setState(() {
        _messages.add(const _Message(
          text: 'Hey! I\'m your FitSmart AI coach 🤖\n\nI have full access to your nutrition logs, workout history, and progress data. Ask me anything about your fitness journey — I\'ll give you personalized, data-driven answers.\n\nWhat\'s on your mind?',
          isAi: true,
        ));
      });
    }
  }

  Future<void> _saveChat() async {
    final prefs = await SharedPreferences.getInstance();
    final serialized = _messages
        .map((m) => {
              'text': m.text,
              'isAi': m.isAi,
              'suggestions': m.suggestions,
            })
        .toList();
    await prefs.setString(_prefsKey, jsonEncode(serialized));
    await prefs.setString(_historyKey, jsonEncode(_history));
  }

  Future<void> _clearChat() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefsKey);
    await prefs.remove(_historyKey);
    setState(() {
      _messages.clear();
      _history.clear();
      _messages.add(const _Message(
        text: 'Hey! I\'m your FitSmart AI coach 🤖\n\nI have full access to your nutrition logs, workout history, and progress data. Ask me anything about your fitness journey — I\'ll give you personalized, data-driven answers.\n\nWhat\'s on your mind?',
        isAi: true,
      ));
    });
  }

  @override
  void dispose() {
    _messageCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  bool get _isCoolingDown =>
      _lastSentAt != null &&
      DateTime.now().difference(_lastSentAt!) < _sendCooldown;

  Future<void> _sendMessage(String text, {Uint8List? imageBytes, String? mimeType}) async {
    if (text.trim().isEmpty && imageBytes == null) return;
    if (_isCoolingDown) return; // rate limit

    _lastSentAt = DateTime.now();
    final userText = text.trim().isNotEmpty ? text.trim() : 'Analyze this image';
    setState(() {
      _messages.add(_Message(text: userText, isAi: false, imageBytes: imageBytes));
      _isTyping = true;
      _messageCtrl.clear();
    });
    _scrollToBottom();
    _saveChat();

    try {
      final ai = ref.read(aiProvider);
      final userContext = await UserContextService.buildFullContext(ref);

      // RAG: build food knowledge grounding if the message mentions food/nutrition
      final kb = ref.read(foodKnowledgeProvider);
      final grounding = kb.isLoaded
          ? kb.buildGroundingContext(userText, maxResults: 8)
          : null;

      final result = await ai.chat(
        message: userText,
        userContext: userContext,
        history: _history,
        imageBytes: imageBytes,
        mimeType: mimeType,
        groundingContext: grounding,
      );

      final response = result['response'] as String? ??
          'I couldn\'t generate a response. Please try again.';

      _history.add({'role': 'user', 'content': userText});
      _history.add({'role': 'model', 'content': response});

      if (mounted) {
        setState(() {
          _isTyping = false;
          _messages.add(_Message(
            text: response,
            isAi: true,
          ));
        });
        _scrollToBottom();
        _saveChat();
      }
    } catch (e) {
      debugPrint('Chat error: $e');
      if (mounted) {
        setState(() {
          _isTyping = false;
          _messages.add(_Message(
            text: 'Hmm, I\'m having a moment 😅 Tap retry to try again.',
            isAi: true,
            isError: true,
            failedUserText: userText,
            failedImageBytes: imageBytes,
            failedMimeType: mimeType,
          ));
        });
        _scrollToBottom();
        _saveChat();
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

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Scaffold(
      backgroundColor: colors.bgPrimary,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: colors.limeGlow,
                shape: BoxShape.circle,
                border: Border.all(color: colors.lime.withValues(alpha: 0.3)),
              ),
              child: const Center(child: Text('🤖', style: TextStyle(fontSize: 18))),
            ),
            const SizedBox(width: AppSpacing.sm),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('AI Coach',
                    style: AppTypography.bodyMedium
                        .copyWith(fontWeight: FontWeight.w700)),
                Row(
                  children: [
                    Container(
                      width: 7,
                      height: 7,
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
          ],
        ),
        actions: [
          if (_messages.length > 1)
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded, size: 20),
              color: colors.textTertiary,
              tooltip: 'Clear chat',
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Clear chat?'),
                    content: const Text('This will delete all chat messages.'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(ctx);
                          _clearChat();
                        },
                        child: const Text('Clear'),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
      body: Column(
        children: [
          // Messages
          Expanded(
            child: ListView.builder(
              controller: _scrollCtrl,
              padding: const EdgeInsets.all(AppSpacing.pagePadding),
              itemCount: _messages.length + (_isTyping ? 1 : 0),
              itemBuilder: (_, i) {
                if (_isTyping && i == _messages.length) {
                  return _TypingIndicator().animate().fadeIn(duration: 200.ms);
                }
                final msg = _messages[i];
                return _ChatBubble(
                  message: msg,
                  onSuggestionTap: _sendMessage,
                  onRetry: msg.isError && msg.failedUserText != null
                      ? () {
                          // Remove the error bubble and re-send
                          setState(() => _messages.removeAt(i));
                          _sendMessage(
                            msg.failedUserText!,
                            imageBytes: msg.failedImageBytes,
                            mimeType: msg.failedMimeType,
                          );
                        }
                      : null,
                )
                    .animate(delay: 50.ms)
                    .slideY(begin: 0.1, duration: 300.ms, curve: Curves.easeOut)
                    .fadeIn(duration: 300.ms);
              },
            ),
          ),

          // Suggestions (shown when only the welcome message exists)
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
                  onTap: () => _sendMessage(
                      _suggestions[i].replaceFirst(RegExp(r'^[^\s]+\s+'), '')),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: colors.surfaceCard,
                      borderRadius: BorderRadius.circular(AppRadius.full),
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

          // Input bar
          Container(
            decoration: BoxDecoration(
              color: colors.bgSecondary,
              border:
                  Border(top: BorderSide(color: colors.surfaceCardBorder)),
            ),
            padding: EdgeInsets.fromLTRB(
              AppSpacing.pagePadding,
              AppSpacing.sm,
              AppSpacing.pagePadding,
              MediaQuery.of(context).padding.bottom + AppSpacing.sm,
            ),
            child: Row(
              children: [
                // Image picker button
                GestureDetector(
                  onTap: _isTyping ? null : _pickAndSendImage,
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
                      color: _isTyping
                          ? colors.textTertiary
                          : colors.lime,
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: TextField(
                    controller: _messageCtrl,
                    style: AppTypography.body,
                    maxLines: 3,
                    minLines: 1,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: const InputDecoration(
                      hintText: 'Ask your AI coach anything...',
                      border: OutlineInputBorder(),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    onSubmitted: _sendMessage,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                GestureDetector(
                  onTap: _isTyping
                      ? null
                      : () => _sendMessage(_messageCtrl.text),
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: _isTyping
                          ? colors.surfaceCard
                          : colors.lime,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: Icon(
                      Icons.send_rounded,
                      color: _isTyping
                          ? colors.textTertiary
                          : colors.textInverse,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Message {
  final String text;
  final bool isAi;
  final List<String> suggestions;
  final Uint8List? imageBytes;
  final bool isError;
  final String? failedUserText;
  final Uint8List? failedImageBytes;
  final String? failedMimeType;
  const _Message({
    required this.text,
    required this.isAi,
    this.suggestions = const [],
    this.imageBytes,
    this.isError = false,
    this.failedUserText,
    this.failedImageBytes,
    this.failedMimeType,
  });
}

class _ChatBubble extends StatelessWidget {
  final _Message message;
  final void Function(String) onSuggestionTap;
  final VoidCallback? onRetry;
  const _ChatBubble({required this.message, required this.onSuggestionTap, this.onRetry});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment:
            message.isAi ? CrossAxisAlignment.start : CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: message.isAi
                ? MainAxisAlignment.start
                : MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (message.isAi) ...[
                Container(
                  width: 32,
                  height: 32,
                  margin:
                      const EdgeInsets.only(right: AppSpacing.sm, top: 2),
                  decoration: BoxDecoration(
                    color: colors.limeGlow,
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: colors.lime.withValues(alpha: 0.3)),
                  ),
                  child: const Center(
                      child: Text('🤖', style: TextStyle(fontSize: 14))),
                ),
              ],
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.md,
                  ),
                  decoration: BoxDecoration(
                    color: message.isAi
                        ? colors.surfaceCard
                        : colors.lime,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(AppRadius.lg),
                      topRight: const Radius.circular(AppRadius.lg),
                      bottomLeft: Radius.circular(
                          message.isAi ? 4 : AppRadius.lg),
                      bottomRight: Radius.circular(
                          message.isAi ? AppRadius.lg : 4),
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
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          child: Image.memory(
                            message.imageBytes!,
                            width: 200,
                            height: 200,
                            fit: BoxFit.cover,
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
                            color: colors.textInverse,
                            height: 1.6,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          // Retry button for error messages
          if (message.isError && onRetry != null) ...[            const SizedBox(height: AppSpacing.sm),
            Padding(
              padding: const EdgeInsets.only(left: 40),
              child: GestureDetector(
                onTap: onRetry,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: colors.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppRadius.full),
                    border: Border.all(color: colors.error.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.refresh_rounded, color: colors.error, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        'Retry',
                        style: AppTypography.caption.copyWith(
                          color: colors.error,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
          // Follow-up suggestion chips
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
                                fontWeight: FontWeight.w600,
                              ),
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

class _RichText extends StatelessWidget {
  final String text;
  const _RichText({required this.text});

  // Parses **bold** inline within a line, applying baseStyle to normal text
  // and lime+bold to bold runs.
  Widget _parseInline(String raw, TextStyle baseStyle, Color boldColor) {
    final boldRegex = RegExp(r'\*\*(.+?)\*\*');
    final spans = <InlineSpan>[];
    int lastEnd = 0;
    for (final m in boldRegex.allMatches(raw)) {
      if (m.start > lastEnd) {
        spans.add(TextSpan(text: raw.substring(lastEnd, m.start), style: baseStyle));
      }
      spans.add(TextSpan(
        text: m.group(1),
        style: baseStyle.copyWith(
          color: boldColor,
          fontWeight: FontWeight.w700,
        ),
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
      // ── Empty line → small vertical gap ────────────────────────────
      if (line.trim().isEmpty) {
        widgets.add(const SizedBox(height: 6));
        continue;
      }

      // ── ### Heading 3 ───────────────────────────────────────────────
      if (line.startsWith('### ')) {
        widgets.add(Padding(
          padding: const EdgeInsets.only(top: 10, bottom: 3),
          child: _parseInline(
            line.substring(4),
            AppTypography.bodyMedium.copyWith(
              color: colors.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 14.5,
              height: 1.5,
            ),
            colors.lime,
          ),
        ));
        continue;
      }

      // ── ## Heading 2 ────────────────────────────────────────────────
      if (line.startsWith('## ')) {
        widgets.add(Padding(
          padding: const EdgeInsets.only(top: 12, bottom: 4),
          child: _parseInline(
            line.substring(3),
            AppTypography.bodyMedium.copyWith(
              color: colors.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 15.5,
              height: 1.5,
            ),
            colors.lime,
          ),
        ));
        continue;
      }

      // ── # Heading 1 ─────────────────────────────────────────────────
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

      // ── Bullet: * text  /  - text  /  • text ───────────────────────
      final isBullet = line.startsWith('* ') ||
          line.startsWith('- ') ||
          line.startsWith('• ');
      if (isBullet) {
        final content = line.substring(2);
        widgets.add(Padding(
          padding: const EdgeInsets.only(top: 2, bottom: 2),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '•  ',
                style: AppTypography.body.copyWith(
                  color: colors.lime,
                  height: 1.6,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Expanded(
                child: _parseInline(
                  content,
                  AppTypography.body.copyWith(
                    color: colors.textPrimary,
                    height: 1.6,
                  ),
                  colors.lime,
                ),
              ),
            ],
          ),
        ));
        continue;
      }

      // ── Regular paragraph line ──────────────────────────────────────
      widgets.add(_parseInline(
        line,
        AppTypography.body.copyWith(
          color: colors.textPrimary,
          height: 1.6,
        ),
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
            width: 32,
            height: 32,
            margin: const EdgeInsets.only(right: AppSpacing.sm, top: 2),
            decoration: BoxDecoration(
              color: colors.limeGlow,
              shape: BoxShape.circle,
            ),
            child:
                const Center(child: Text('🤖', style: TextStyle(fontSize: 14))),
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
            child: AnimatedBuilder(
              animation: _controller,
              builder: (_, __) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(3, (i) {
                    final offset =
                        (_controller.value - i * 0.2).clamp(0.0, 1.0);
                    final y = -4 *
                        (offset < 0.5
                            ? offset * 2
                            : (1 - offset) * 2);
                    return Transform.translate(
                      offset: Offset(0, y),
                      child: Container(
                        width: 8,
                        height: 8,
                        margin:
                            const EdgeInsets.symmetric(horizontal: 2),
                        decoration: BoxDecoration(
                          color: colors.textTertiary,
                          shape: BoxShape.circle,
                        ),
                      ),
                    );
                  }),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
