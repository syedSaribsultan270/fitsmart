import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../core/constants/app_constants.dart';
import 'ai_tools/ai_tool.dart';
import 'ai_tools/tool_registry.dart';
import 'analytics_service.dart';
import 'gemini_client.dart';
import 'groq_client.dart';
import 'local_ai_fallback_service.dart';
import 'local_llm_service.dart';
import 'quota_service.dart';
import 'subscription_service.dart' show FreeTierLimitException;

/// Tracks which AI tier served the last response.
enum AiSource { gemini, groq, onDeviceLlm, local }

/// Central AI orchestrator — 3-tier text / vision-only Gemini.
///
/// Architecture:
///
///   VISION (image present)
///   ┌─────────────────────────────────────────────────────────┐
///   │ analyzeMealPhoto  → Gemini → Templates                  │
///   │ chat + image      → Gemini → Groq (text) → LLM → Tmpl  │
///   └─────────────────────────────────────────────────────────┘
///
///   TEXT (no image)
///   ┌─────────────────────────────────────────────────────────┐
///   │ Everything else   → Groq → On-device LLM → Templates   │
///   └─────────────────────────────────────────────────────────┘
///
/// Token discipline:
///   • Gemini receives the minimum context for the task (~7 fields).
///   • Groq structured endpoints (analysis, plans) receive task-scoped
///     context (10–15 fields) — never the full dump.
///   • Groq chat receives the full formatted context (conversation needs it).
///   • The circuit breaker is scoped to Gemini vision calls only.
class AiOrchestratorService {
  final GeminiClient _gemini;
  final GroqClient? _groq;
  final LocalAiFallbackService _local;
  final LocalLlmService _llm;

  AiOrchestratorService({
    required GeminiClient gemini,
    GroqClient? groq,
    LocalAiFallbackService? local,
    LocalLlmService? llm,
  })  : _gemini = gemini,
        _groq = groq,
        _local = local ?? LocalAiFallbackService.instance,
        _llm = llm ?? LocalLlmService.instance;

  // ── Gemini vision circuit breaker ─────────────────────────────

  int _geminiFailures = 0;
  DateTime? _geminiCircuitOpenedAt;

  AiSource lastSource = AiSource.groq;

  bool get _isGeminiCircuitOpen {
    if (_geminiCircuitOpenedAt == null) return false;
    final elapsed = DateTime.now().difference(_geminiCircuitOpenedAt!).inSeconds;
    if (elapsed >= AppConstants.circuitBreakerOpenDurationSec) return false; // half-open
    return true;
  }

  void _recordGeminiSuccess() {
    _geminiFailures = 0;
    _geminiCircuitOpenedAt = null;
  }

  void _recordGeminiFailure() {
    _geminiFailures++;
    if (_geminiFailures >= AppConstants.circuitBreakerFailureThreshold) {
      _geminiCircuitOpenedAt = DateTime.now();
      debugPrint(
        '[AiOrchestrator] Gemini circuit OPEN — $_geminiFailures vision failures. '
        'Bypassing for ${AppConstants.circuitBreakerOpenDurationSec}s.',
      );
    }
  }

  void _setSource(AiSource source) => lastSource = source;

  // ── Timeout helpers ────────────────────────────────────────────

  Future<T> _withGeminiTimeout<T>(Future<T> future) => future.timeout(
        Duration(seconds: AppConstants.geminiRequestTimeoutSec),
        onTimeout: () => throw TimeoutException('Gemini request timed out'),
      );

  Future<T> _withGroqTimeout<T>(Future<T> future) => future.timeout(
        Duration(seconds: AppConstants.groqRequestTimeoutSec),
        onTimeout: () => throw TimeoutException('Groq request timed out'),
      );

  bool get _hasGroq => _groq != null && _groq.isConfigured;

  // ── Context slimming — send only what each task needs ──────────

  /// ~7 fields. Gemini vision: nutrition targets + restrictions.
  Map<String, dynamic> _imageCtx(Map<String, dynamic> ctx) => {
        for (final k in const [
          'goal',
          'dietary_restrictions',
          'target_calories',
          'target_protein_g',
          'target_carbs_g',
          'target_fat_g',
          'consumed_calories_today',
        ])
          if (ctx[k] != null) k: ctx[k],
      };

  /// ~15 fields. Gemini vision-chat: profile + today's nutrition.
  Map<String, dynamic> _visionChatCtx(Map<String, dynamic> ctx) => {
        for (final k in const [
          'goal',
          'gender',
          'age',
          'weight_kg',
          'height_cm',
          'dietary_restrictions',
          'disliked_ingredients',
          'target_calories',
          'target_protein_g',
          'target_carbs_g',
          'target_fat_g',
          'consumed_calories_today',
          'consumed_protein_today',
          'consumed_carbs_today',
          'consumed_fat_today',
          'current_streak',
        ])
          if (ctx[k] != null) k: ctx[k],
      };

  /// ~14 fields. Groq meal analysis / feedback.
  Map<String, dynamic> _nutritionCtx(Map<String, dynamic> ctx) => {
        for (final k in const [
          'goal',
          'country',
          'city',
          'dietary_restrictions',
          'disliked_ingredients',
          'target_calories',
          'target_protein_g',
          'target_carbs_g',
          'target_fat_g',
          'consumed_calories_today',
          'consumed_protein_today',
          'consumed_carbs_today',
          'consumed_fat_today',
        ])
          if (ctx[k] != null) k: ctx[k],
      };

  /// ~16 fields. Groq meal plan generation.
  Map<String, dynamic> _mealPlanCtx(Map<String, dynamic> ctx) => {
        for (final k in const [
          'goal',
          'gender',
          'age',
          'weight_kg',
          'height_cm',
          'activity_level',
          'country',
          'city',
          'dietary_restrictions',
          'cuisine_preferences',
          'disliked_ingredients',
          'monthly_budget_usd',
          'target_calories',
          'target_protein_g',
          'target_carbs_g',
          'target_fat_g',
        ])
          if (ctx[k] != null) k: ctx[k],
      };

  /// ~8 fields. Groq workout plan generation.
  Map<String, dynamic> _workoutCtx(Map<String, dynamic> ctx) => {
        for (final k in const [
          'goal',
          'gender',
          'age',
          'weight_kg',
          'activity_level',
          'workout_days_per_week',
          'equipment',
          'personal_records',
        ])
          if (ctx[k] != null) k: ctx[k],
      };

  /// ~10 fields. Groq daily insight.
  Map<String, dynamic> _insightCtx(Map<String, dynamic> ctx) => {
        for (final k in const [
          'goal',
          'target_calories',
          'consumed_calories_today',
          'target_protein_g',
          'consumed_protein_today',
          'current_streak',
          'level',
          'level_name',
          'recent_workouts',
          'weekly_summary',
        ])
          if (ctx[k] != null) k: ctx[k],
      };

  // ══════════════════════════════════════════════════════════════════
  //  PUBLIC API
  // ══════════════════════════════════════════════════════════════════

  /// Analyze a meal photo.
  /// Gemini (vision) → Templates.
  /// Groq is skipped — llama-3.3-70b-versatile is text-only.
  Future<Map<String, dynamic>> analyzeMealPhoto({
    required Uint8List imageBytes,
    required Map<String, dynamic> userContext,
    String? mimeType,
    String? groundingContext,
  }) async {
    await _checkPhotoAnalysisLimit();
    if (!_isGeminiCircuitOpen) {
      try {
        final result = await _withGeminiTimeout(
          _gemini.analyzeMealPhoto(
            imageBytes: imageBytes,
            userContext: _imageCtx(userContext),
            mimeType: mimeType,
            groundingContext: groundingContext,
          ),
        );
        _recordGeminiSuccess();
        _setSource(AiSource.gemini);
        return result;
      } catch (e) {
        debugPrint('[AiOrchestrator] analyzeMealPhoto Gemini failed: $e');
        _recordGeminiFailure();
      }
    }

    _setSource(AiSource.local);
    return _local.analyzeMealPhoto(userContext: userContext);
  }

  /// Analyze a meal from a text description.
  /// Groq → On-device LLM → Templates.
  Future<Map<String, dynamic>> analyzeMealText({
    required String description,
    required Map<String, dynamic> userContext,
    String? groundingContext,
  }) async {
    if (_hasGroq) {
      try {
        final result = await _withGroqTimeout(
          _groq!.analyzeMealText(
            description: description,
            userContext: _nutritionCtx(userContext),
            groundingContext: groundingContext,
          ),
        );
        _setSource(AiSource.groq);
        return result;
      } catch (e) {
        debugPrint('[AiOrchestrator] analyzeMealText Groq failed: $e');
      }
    }

    if (_llm.isReady || _llm.status == LlmModelStatus.downloaded) {
      try {
        final response = await _llm.generate(
          _llm.buildMealTextAnalysisPrompt(
            description: description,
            userContext: userContext,
          ),
        );
        if (response != null && response.trim().isNotEmpty) {
          final parsed = _parseJsonResponse('{$response');
          if (parsed != null) {
            _setSource(AiSource.onDeviceLlm);
            return parsed;
          }
        }
      } catch (e) {
        debugPrint('[AiOrchestrator] analyzeMealText on-device failed: $e');
      }
    }

    _setSource(AiSource.local);
    return _local.analyzeMealText(
      description: description,
      userContext: userContext,
    );
  }

  /// Post-meal feedback.
  /// Groq → On-device LLM → Templates.
  Future<Map<String, dynamic>> getMealFeedback({
    required Map<String, dynamic> mealData,
    required Map<String, dynamic> userContext,
  }) async {
    if (_hasGroq) {
      try {
        final result = await _withGroqTimeout(
          _groq!.getMealFeedback(
            mealData: mealData,
            userContext: _nutritionCtx(userContext),
          ),
        );
        _setSource(AiSource.groq);
        return result;
      } catch (e) {
        debugPrint('[AiOrchestrator] getMealFeedback Groq failed: $e');
      }
    }

    if (_llm.isReady || _llm.status == LlmModelStatus.downloaded) {
      try {
        final response = await _llm.generate(
          _llm.buildMealFeedbackPrompt(
            mealData: mealData,
            userContext: userContext,
          ),
        );
        if (response != null && response.trim().isNotEmpty) {
          final parsed = _parseJsonResponse('{$response');
          if (parsed != null) {
            _setSource(AiSource.onDeviceLlm);
            return parsed;
          }
        }
      } catch (e) {
        debugPrint('[AiOrchestrator] getMealFeedback on-device failed: $e');
      }
    }

    _setSource(AiSource.local);
    return _local.getMealFeedback(
      mealData: mealData,
      userContext: userContext,
    );
  }

  /// Generate a multi-day meal plan.
  /// Groq → On-device LLM → Templates.
  Future<Map<String, dynamic>> generateMealPlan({
    required Map<String, dynamic> userContext,
    required int days,
    String? overrides,
  }) async {
    if (_hasGroq) {
      try {
        final result = await _withGroqTimeout(
          _groq!.generateMealPlan(
            userContext: _mealPlanCtx(userContext),
            days: days,
            overrides: overrides,
          ),
        );
        _setSource(AiSource.groq);
        return result;
      } catch (e) {
        debugPrint('[AiOrchestrator] generateMealPlan Groq failed: $e');
      }
    }

    if (_llm.isReady || _llm.status == LlmModelStatus.downloaded) {
      try {
        final response = await _llm.generate(
          _llm.buildMealPlanPrompt(
            userContext: userContext,
            days: days,
            overrides: overrides,
          ),
        );
        if (response != null && response.trim().isNotEmpty) {
          final parsed = _parseJsonResponse('{$response');
          if (parsed != null) {
            _setSource(AiSource.onDeviceLlm);
            return parsed;
          }
        }
      } catch (e) {
        debugPrint('[AiOrchestrator] generateMealPlan on-device failed: $e');
      }
    }

    _setSource(AiSource.local);
    return _local.generateMealPlan(userContext: userContext, days: days);
  }

  /// Generate a multi-week workout plan.
  /// Groq → On-device LLM → Templates.
  Future<Map<String, dynamic>> generateWorkoutPlan({
    required Map<String, dynamic> userContext,
    required int weeks,
  }) async {
    if (_hasGroq) {
      try {
        final result = await _withGroqTimeout(
          _groq!.generateWorkoutPlan(
            userContext: _workoutCtx(userContext),
            weeks: weeks,
          ),
        );
        _setSource(AiSource.groq);
        return result;
      } catch (e) {
        debugPrint('[AiOrchestrator] generateWorkoutPlan Groq failed: $e');
      }
    }

    if (_llm.isReady || _llm.status == LlmModelStatus.downloaded) {
      try {
        final response = await _llm.generate(
          _llm.buildWorkoutPlanPrompt(
            userContext: userContext,
            weeks: weeks,
          ),
        );
        if (response != null && response.trim().isNotEmpty) {
          final parsed = _parseJsonResponse('{$response');
          if (parsed != null) {
            _setSource(AiSource.onDeviceLlm);
            return parsed;
          }
        }
      } catch (e) {
        debugPrint('[AiOrchestrator] generateWorkoutPlan on-device failed: $e');
      }
    }

    _setSource(AiSource.local);
    return _local.generateWorkoutPlan(userContext: userContext, weeks: weeks);
  }

  /// AI coach chat.
  ///
  /// With image  → Gemini (vision, no circuit recording) → Groq (text) → LLM → Templates.
  /// Text only   → Groq → On-device LLM → Templates.
  Future<Map<String, dynamic>> chat({
    required String message,
    required Map<String, dynamic> userContext,
    required List<Map<String, String>> history,
    Uint8List? imageBytes,
    String? mimeType,
    String? groundingContext,
  }) async {
    await _checkChatLimit();
    // Vision path — only when image is attached
    if (imageBytes != null && !_isGeminiCircuitOpen) {
      try {
        final result = await _withGeminiTimeout(
          _gemini.chat(
            message: message,
            userContext: _visionChatCtx(userContext),
            history: history,
            imageBytes: imageBytes,
            mimeType: mimeType,
            groundingContext: groundingContext,
          ),
        );
        _setSource(AiSource.gemini);
        return result;
      } catch (e) {
        // Don't record into the vision circuit breaker — image-in-chat
        // failures are conversational, not a sign Gemini vision is down.
        debugPrint('[AiOrchestrator] chat (vision) Gemini failed: $e');
      }
    }

    // Groq — primary for text, graceful degradation for image (drops the image)
    if (_hasGroq) {
      final groqMsg = imageBytes != null
          ? '[User sent an image that could not be processed] $message'
          : message;
      try {
        final result = await _withGroqTimeout(
          _groq!.chat(
            message: groqMsg,
            userContext: userContext, // full context — chat needs it
            history: history,
            imageBytes: null,
            mimeType: null,
            groundingContext: groundingContext,
          ),
        );
        _setSource(AiSource.groq);
        debugPrint('[AiOrchestrator] chat → Groq.');
        return result;
      } catch (e) {
        debugPrint('[AiOrchestrator] chat Groq failed: $e');
      }
    }

    // On-device LLM
    if (_llm.isReady || _llm.status == LlmModelStatus.downloaded) {
      try {
        final response = await _llm.generate(
          _llm.buildCoachPrompt(
            message: message,
            userContext: userContext,
            history: history,
            groundingContext: groundingContext,
          ),
        );
        if (response != null && response.trim().isNotEmpty) {
          _setSource(AiSource.onDeviceLlm);
          debugPrint('[AiOrchestrator] chat → on-device LLM.');
          return {'response': response.trim()};
        }
      } catch (e) {
        debugPrint('[AiOrchestrator] chat on-device failed: $e');
      }
    }

    // Templates
    _setSource(AiSource.local);
    debugPrint('[AiOrchestrator] chat → templates.');
    return _local.chat(message: message, userContext: userContext);
  }

  /// Daily AI insight for the dashboard.
  /// Groq → On-device LLM → Templates.
  Future<Map<String, dynamic>> getDailyInsight({
    required Map<String, dynamic> userContext,
  }) async {
    if (_hasGroq) {
      try {
        final result = await _withGroqTimeout(
          _groq!.getDailyInsight(userContext: _insightCtx(userContext)),
        );
        _setSource(AiSource.groq);
        debugPrint('[AiOrchestrator] getDailyInsight → Groq.');
        return result;
      } catch (e) {
        debugPrint('[AiOrchestrator] getDailyInsight Groq failed: $e');
      }
    }

    if (_llm.isReady || _llm.status == LlmModelStatus.downloaded) {
      try {
        final response = await _llm.generate(_llm.buildInsightPrompt(userContext));
        if (response != null && response.trim().isNotEmpty) {
          _setSource(AiSource.onDeviceLlm);
          debugPrint('[AiOrchestrator] getDailyInsight → on-device LLM.');
          try {
            final parsed = _parseJsonResponse(response);
            if (parsed != null) return parsed;
          } catch (_) {}
          return {
            'insight': response.trim(),
            'icon': '🧠',
            'category': 'motivation',
          };
        }
      } catch (e) {
        debugPrint('[AiOrchestrator] getDailyInsight on-device failed: $e');
      }
    }

    _setSource(AiSource.local);
    debugPrint('[AiOrchestrator] getDailyInsight → templates.');
    return _local.getDailyInsight(userContext: userContext);
  }

  // ── JSON extraction ────────────────────────────────────────────

  /// Extract a JSON object from an LLM response using balanced-brace scanning.
  Map<String, dynamic>? _parseJsonResponse(String text) {
    final start = text.indexOf('{');
    if (start == -1) return null;

    int depth = 0;
    bool inString = false;
    bool escaped = false;

    for (int i = start; i < text.length; i++) {
      final c = text[i];
      if (escaped) { escaped = false; continue; }
      if (c == r'\' && inString) { escaped = true; continue; }
      if (c == '"') { inString = !inString; continue; }
      if (inString) continue;
      if (c == '{') depth++;
      if (c == '}') depth--;
      if (depth == 0) {
        try {
          return Map<String, dynamic>.from(
            jsonDecode(text.substring(start, i + 1)) as Map,
          );
        } catch (e) {
          debugPrint('[AiOrchestrator] _parseJsonResponse failed: $e');
          return null;
        }
      }
    }
    return null;
  }

  // ── Free-tier rate limiting (server-enforced via QuotaService) ───
  //
  // Counters live in Firestore at users/{uid}/quotas/{YYYY-MM-DD} with
  // increment-only rules capped at the free tier. Replaces the previous
  // SharedPreferences counters (which were trivially bypassed by clearing
  // app data — direct revenue leak).
  //
  // QuotaService.consume throws FreeTierQuotaException at the cap; we
  // re-raise as FreeTierLimitException to keep the existing UI handlers
  // (ai_coach_screen, log_meal_screen paywall surfaces) unchanged.

  Future<void> _checkChatLimit() async {
    try {
      await QuotaService.instance.consumeAiMessage();
    } on FreeTierQuotaException {
      throw const FreeTierLimitException('unlimited_ai');
    } catch (_) {
      // Soft-fail (offline / unauth) → allow through.
    }
  }

  Future<void> _checkPhotoAnalysisLimit() async {
    try {
      await QuotaService.instance.consumePhotoAnalysis();
    } on FreeTierQuotaException {
      throw const FreeTierLimitException('unlimited_photo_analysis');
    } catch (_) {
      // Soft-fail (offline / unauth) → allow through.
    }
  }

  // ── Utility ────────────────────────────────────────────────────

  /// Reset the Gemini vision circuit breaker (e.g. after network recovery).
  void resetCircuitBreaker() {
    _geminiFailures = 0;
    _geminiCircuitOpenedAt = null;
    debugPrint('[AiOrchestrator] Gemini circuit breaker reset.');
  }

  void clearCache() => _gemini.clearCache();

  bool get isCircuitOpen => _isGeminiCircuitOpen;
  int get consecutiveFailures => _geminiFailures;

  // ── On-device LLM management ───────────────────────────────────

  LlmModelStatus get llmStatus => _llm.status;
  bool get isLlmReady => _llm.isReady;
  double get llmDownloadProgress => _llm.downloadProgress;
  Stream<double> downloadLlmModel(String url) => _llm.downloadModel(url);
  Future<bool> loadLlmModel() => _llm.loadModel();
  void unloadLlmModel() => _llm.unloadModel();
  Future<void> deleteLlmModel() => _llm.deleteModel();
  Future<void> checkLlmStatus() => _llm.checkModelStatus();

  // ── Tool-use chat ──────────────────────────────────────────────
  //
  // Tool-use mode: the AI can call app functions (log_meal, log_weight,
  // get_todays_totals, etc.) instead of hallucinating that it did.
  // Runs on Groq today (Llama 3.3 70B supports OpenAI-style tool_calls).
  // When Groq is unavailable, falls back to plain chat — the AI can still
  // reply conversationally but can't perform actions.
  //
  // See lib/services/ai_tools/ for the tool registry.

  /// Max tool iterations per user message. Prevents runaway loops where
  /// the model keeps calling tools without producing text.
  static const _maxToolIterations = 5;

  /// Conduct a chat turn with tool-use enabled.
  ///
  /// [confirmWrite] is invoked for every *write* tool the model wants to
  /// fire. Return `true` to authorize execution, `false` to deny (the model
  /// will see a "user declined" response and can acknowledge or retry).
  /// *Read* tools (get_*) auto-execute without confirmation.
  ///
  /// Returns a [ChatWithToolsReply] containing final text + executed
  /// write-tool receipts (for rendering the inline UI).
  Future<ChatWithToolsReply> chatWithTools({
    required ToolRef read,
    required String message,
    required Map<String, dynamic> userContext,
    required List<Map<String, String>> history,
    required Future<bool> Function(PendingToolCall) confirmWrite,
  }) async {
    await _checkChatLimit();

    if (_groq == null) {
      // No tool-capable client — fall back to plain chat; AI can still reply.
      final reply = await chat(
        message: message,
        userContext: userContext,
        history: history,
      );
      return ChatWithToolsReply(
        text: reply['response'] as String? ?? '',
        executed: const [],
        source: lastSource,
      );
    }

    // Build OpenAI-style message history.
    // System prompt tells the model it has tools and when to use them.
    final systemPrompt = _toolsSystemPrompt(userContext);
    final messages = <Map<String, dynamic>>[
      {'role': 'system', 'content': systemPrompt},
      for (final h in history.reversed.take(10).toList().reversed)
        if ((h['content'] ?? '').isNotEmpty)
          {
            'role': h['role'] == 'user' ? 'user' : 'assistant',
            'content': h['content'] ?? '',
          },
      {'role': 'user', 'content': message},
    ];

    final tools = ToolRegistry.instance.toOpenAiTools();
    final executed = <ExecutedToolCall>[];
    final suggestedCards = <SuggestedMealCard>[];

    for (var iter = 0; iter < _maxToolIterations; iter++) {
      final assistant = await _withGroqTimeout(
        _groq.chatCompletionWithTools(
          messages: messages,
          tools: tools,
        ),
      );

      final toolCalls = assistant['tool_calls'] as List?;

      // No tool calls → model gave a final text answer. Done.
      if (toolCalls == null || toolCalls.isEmpty) {
        final content = assistant['content'] as String? ?? '';
        _setSource(AiSource.groq);
        return ChatWithToolsReply(
          text: content,
          executed: executed,
          suggestedMealCards: suggestedCards,
          source: AiSource.groq,
        );
      }

      // Append the assistant turn (with its tool_calls) to history so the
      // model can see its own calls when we send tool responses back.
      messages.add(assistant);

      for (final rawCall in toolCalls) {
        final call = rawCall as Map<String, dynamic>;
        final fn = call['function'] as Map<String, dynamic>;
        final name = fn['name'] as String;
        final id = call['id'] as String? ?? name;

        Map<String, dynamic> args;
        try {
          args = fn['arguments'] is String
              ? jsonDecode(fn['arguments'] as String) as Map<String, dynamic>
              : (fn['arguments'] as Map<String, dynamic>? ?? {});
        } catch (e) {
          messages.add(_toolResponseMsg(
              id, name, {'success': false, 'error': 'invalid JSON args: $e'}));
          continue;
        }

        final tool = ToolRegistry.instance.byName(name);
        if (tool == null) {
          messages.add(_toolResponseMsg(
              id, name, {'success': false, 'error': 'unknown tool'}));
          continue;
        }

        AnalyticsService.instance.track('ai_tool_requested',
            props: {'tool': name, 'is_write': tool.isWrite});

        // Write tools require user confirmation.
        if (tool.isWrite) {
          final pending = PendingToolCall(id: id, tool: tool, args: args);
          final approved = await confirmWrite(pending);
          if (!approved) {
            messages.add(_toolResponseMsg(id, name, {
              'success': false,
              'error': 'user declined the action',
            }));
            AnalyticsService.instance.track('ai_tool_declined',
                props: {'tool': name});
            continue;
          }
        }

        // Execute (either read tool or approved write tool).
        try {
          final result = await tool.execute(read, args);
          messages.add(_toolResponseMsg(id, name, result.toJson()));
          if (tool.isWrite && result.success) {
            executed.add(ExecutedToolCall(
              tool: tool,
              args: args,
              entityId: result.entityId,
            ));
            AnalyticsService.instance.track('ai_tool_executed',
                props: {'tool': name, 'success': true});
          }
          // suggest_meal_card — the "read" tool whose payload surfaces as
          // a tappable opt-in card in the chat UI. Collect here.
          if (name == 'suggest_meal_card' && result.success) {
            suggestedCards.add(SuggestedMealCard.fromArgs(args));
          }
        } catch (e) {
          messages.add(_toolResponseMsg(id, name, {
            'success': false,
            'error': e.toString(),
          }));
          AnalyticsService.instance.track('ai_tool_executed',
              props: {'tool': name, 'success': false, 'error': e.toString()});
        }
      }
    }

    // Iteration limit hit — return whatever we've got.
    debugPrint('[AiOrchestrator] chatWithTools iteration limit reached.');
    return ChatWithToolsReply(
      text: "I've handled that. Anything else?",
      executed: executed,
      suggestedMealCards: suggestedCards,
      source: AiSource.groq,
    );
  }

  Map<String, dynamic> _toolResponseMsg(
      String id, String name, Map<String, dynamic> body) {
    return {
      'role': 'tool',
      'tool_call_id': id,
      'name': name,
      'content': jsonEncode(body),
    };
  }

  /// System prompt telling the model about tool use. Packed with the
  /// existing user-context so the model has both.
  String _toolsSystemPrompt(Map<String, dynamic> ctx) {
    final buffer = StringBuffer()
      ..writeln(GroqClient.chatSystemPromptForTools)
      ..writeln()
      ..writeln('=== USER CONTEXT ===')
      ..writeln('Goal: ${ctx['goal'] ?? 'not set'}')
      ..writeln(
          'Targets: ${ctx['target_calories']} kcal / ${ctx['target_protein_g']}g P / ${ctx['target_carbs_g']}g C / ${ctx['target_fat_g']}g F')
      ..writeln(
          'Consumed today: ${ctx['consumed_calories_today']} kcal / ${ctx['consumed_protein_today']}g P / ${ctx['consumed_carbs_today']}g C / ${ctx['consumed_fat_today']}g F');
    if (ctx['todays_meals'] != null) {
      buffer.writeln('\nToday\'s meals:\n${ctx['todays_meals']}');
    }
    return buffer.toString();
  }
}

// ── Return types for chatWithTools ───────────────────────────────────

/// A write tool the AI successfully executed. Surface these as inline
/// receipt cards in the chat so the user sees what just happened.
class ExecutedToolCall {
  final AiTool tool;
  final Map<String, dynamic> args;
  final int? entityId;
  const ExecutedToolCall({
    required this.tool,
    required this.args,
    this.entityId,
  });
}

/// The AI proposed this meal — the UI renders a tappable card the user can
/// opt-in to log. Populated when the model calls `suggest_meal_card`.
class SuggestedMealCard {
  final String name;
  final String mealType;
  final double calories;
  final double proteinG;
  final double carbsG;
  final double fatG;
  final double fiberG;

  const SuggestedMealCard({
    required this.name,
    required this.mealType,
    required this.calories,
    required this.proteinG,
    required this.carbsG,
    required this.fatG,
    this.fiberG = 0,
  });

  factory SuggestedMealCard.fromArgs(Map<String, dynamic> args) {
    return SuggestedMealCard(
      name: args['name'] as String? ?? 'Meal',
      mealType: args['meal_type'] as String? ?? 'Snack',
      calories: (args['calories'] as num?)?.toDouble() ?? 0,
      proteinG: (args['protein_g'] as num?)?.toDouble() ?? 0,
      carbsG: (args['carbs_g'] as num?)?.toDouble() ?? 0,
      fatG: (args['fat_g'] as num?)?.toDouble() ?? 0,
      fiberG: (args['fiber_g'] as num?)?.toDouble() ?? 0,
    );
  }

  /// Args shape for log_meal when the user taps "Log this".
  Map<String, dynamic> toLogMealArgs() => {
        'name': name,
        'meal_type': mealType,
        'calories': calories,
        'protein_g': proteinG,
        'carbs_g': carbsG,
        'fat_g': fatG,
        'fiber_g': fiberG,
      };
}

class ChatWithToolsReply {
  final String text;
  final List<ExecutedToolCall> executed;
  /// Inline tappable meal cards the AI offered. User decides whether to log.
  final List<SuggestedMealCard> suggestedMealCards;
  final AiSource source;
  const ChatWithToolsReply({
    required this.text,
    required this.executed,
    this.suggestedMealCards = const [],
    required this.source,
  });
}
