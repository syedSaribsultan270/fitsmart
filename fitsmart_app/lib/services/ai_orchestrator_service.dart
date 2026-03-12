import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../core/constants/app_constants.dart';
import 'gemini_client.dart';
import 'groq_client.dart';
import 'local_ai_fallback_service.dart';
import 'local_llm_service.dart';

/// Tracks which AI tier served the last response.
/// This is **internal only** — the user never sees it.
enum AiSource { gemini, groq, onDeviceLlm, local }

/// Central orchestrator for all AI calls — **4-tier fallback**.
///
/// **Architecture:**
///  - **Tier 1a — Gemini 2.5 Flash** (cloud): Best quality, requires network.
///    Free: 15 RPM / 1,500 RPD.
///  - **Tier 1b — Groq / Llama 3.3 70B** (cloud): Fast secondary cloud.
///    Free: 30 RPM / 14,400 RPD.
///  - **Tier 2 — Gemma 2 2B** (on-device LLM): Strong fallback for open-ended
///    chat and insights. Only used when the model is downloaded & loaded.
///  - **Tier 3 — Templates / RAG** (rules): Instant, deterministic. Always
///    available. Used for structured data (meal analysis, plans) and as the
///    final safety net for chat.
///
/// **How it works:**
///  1. Every AI method first checks the circuit breaker for Gemini.
///  2. If the circuit is **closed** (healthy), it tries Gemini with a timeout.
///  3. If Gemini fails, tries Groq as a secondary cloud provider.
///  4. For **chat** and **daily insight**: then falls to Tier 2 (on-device LLM)
///     if the model is ready, otherwise falls to Tier 3 (templates).
///  5. For **structured data** (meal analysis, plans, feedback): falls directly
///     to Tier 3 (templates/RAG) since they need structured JSON.
///  6. If the circuit is **open**, skips Gemini entirely → tries Groq first.
///
/// The user never sees any difference — same JSON shapes, same UI.
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

  // ── Circuit Breaker State ──────────────────────────────────────

  int _consecutiveFailures = 0;
  DateTime? _circuitOpenedAt;

  /// The last source used (for debugging / analytics, not shown to user).
  AiSource lastSource = AiSource.gemini;

  bool get _isCircuitOpen {
    if (_circuitOpenedAt == null) return false;
    final elapsed =
        DateTime.now().difference(_circuitOpenedAt!).inSeconds;
    if (elapsed >= AppConstants.circuitBreakerOpenDurationSec) {
      // Move to half-open: allow one probe
      return false;
    }
    return true;
  }

  void _recordSuccess() {
    _consecutiveFailures = 0;
    _circuitOpenedAt = null;
    lastSource = AiSource.gemini;
  }

  void _recordFailure() {
    _consecutiveFailures++;
    if (_consecutiveFailures >= AppConstants.circuitBreakerFailureThreshold) {
      _circuitOpenedAt = DateTime.now();
      debugPrint(
          '[AiOrchestrator] Circuit OPEN — $_consecutiveFailures consecutive failures. '
          'Falling back to local for ${AppConstants.circuitBreakerOpenDurationSec}s.');
    }
    // Source is set per-method depending on which tier answers
  }

  void _setSource(AiSource source) {
    lastSource = source;
  }

  // ── Timeout helper ─────────────────────────────────────────────

  Future<T> _withTimeout<T>(Future<T> future) {
    return future.timeout(
      Duration(seconds: AppConstants.geminiRequestTimeoutSec),
      onTimeout: () => throw TimeoutException('Gemini request timed out'),
    );
  }

  Future<T> _withGroqTimeout<T>(Future<T> future) {
    return future.timeout(
      Duration(seconds: AppConstants.groqRequestTimeoutSec),
      onTimeout: () => throw TimeoutException('Groq request timed out'),
    );
  }

  /// Whether Groq is available as a fallback.
  bool get _hasGroq => _groq != null && _groq.isConfigured;

  // ══════════════════════════════════════════════════════════════════
  //  PUBLIC API — mirrors GeminiClient exactly
  // ══════════════════════════════════════════════════════════════════

  /// Analyze a meal from a photo.
  Future<Map<String, dynamic>> analyzeMealPhoto({
    required Uint8List imageBytes,
    required Map<String, dynamic> userContext,
    String? mimeType,
    String? groundingContext,
  }) async {
    if (!_isCircuitOpen) {
      try {
        final result = await _withTimeout(
          _gemini.analyzeMealPhoto(
            imageBytes: imageBytes,
            userContext: userContext,
            mimeType: mimeType,
            groundingContext: groundingContext,
          ),
        );
        _recordSuccess();
        return result;
      } catch (e) {
        debugPrint('[AiOrchestrator] analyzeMealPhoto cloud failed: $e');
        _recordFailure();
      }
    }

    // ── Tier 1b: Groq Cloud ──
    if (_hasGroq) {
      try {
        final result = await _withGroqTimeout(
          _groq!.analyzeMealPhoto(
            imageBytes: imageBytes,
            userContext: userContext,
            mimeType: mimeType,
            groundingContext: groundingContext,
          ),
        );
        _setSource(AiSource.groq);
        return result;
      } catch (e) {
        debugPrint('[AiOrchestrator] analyzeMealPhoto Groq failed: $e');
      }
    }

    // Local fallback — photo analysis is limited but still returns valid JSON
    _setSource(AiSource.local);
    return _local.analyzeMealPhoto(userContext: userContext);
  }

  /// Analyze a meal from text description.
  Future<Map<String, dynamic>> analyzeMealText({
    required String description,
    required Map<String, dynamic> userContext,
    String? groundingContext,
  }) async {
    if (!_isCircuitOpen) {
      try {
        final result = await _withTimeout(
          _gemini.analyzeMealText(
            description: description,
            userContext: userContext,
            groundingContext: groundingContext,
          ),
        );
        _recordSuccess();
        return result;
      } catch (e) {
        debugPrint('[AiOrchestrator] analyzeMealText cloud failed: $e');
        _recordFailure();
      }
    }

    // ── Tier 1b: Groq Cloud ──
    if (_hasGroq) {
      try {
        final result = await _withGroqTimeout(
          _groq!.analyzeMealText(
            description: description,
            userContext: userContext,
            groundingContext: groundingContext,
          ),
        );
        _setSource(AiSource.groq);
        return result;
      } catch (e) {
        debugPrint('[AiOrchestrator] analyzeMealText Groq failed: $e');
      }
    }

    // Local fallback — RAG-powered, very accurate for known foods
    _setSource(AiSource.local);
    return _local.analyzeMealText(
      description: description,
      userContext: userContext,
    );
  }

  /// Get feedback after logging a meal.
  Future<Map<String, dynamic>> getMealFeedback({
    required Map<String, dynamic> mealData,
    required Map<String, dynamic> userContext,
  }) async {
    if (!_isCircuitOpen) {
      try {
        final result = await _withTimeout(
          _gemini.getMealFeedback(
            mealData: mealData,
            userContext: userContext,
          ),
        );
        _recordSuccess();
        return result;
      } catch (e) {
        debugPrint('[AiOrchestrator] getMealFeedback cloud failed: $e');
        _recordFailure();
      }
    }

    // ── Tier 1b: Groq Cloud ──
    if (_hasGroq) {
      try {
        final result = await _withGroqTimeout(
          _groq!.getMealFeedback(
            mealData: mealData,
            userContext: userContext,
          ),
        );
        _setSource(AiSource.groq);
        return result;
      } catch (e) {
        debugPrint('[AiOrchestrator] getMealFeedback Groq failed: $e');
      }
    }

    _setSource(AiSource.local);
    return _local.getMealFeedback(
      mealData: mealData,
      userContext: userContext,
    );
  }

  /// Generate a multi-day meal plan.
  Future<Map<String, dynamic>> generateMealPlan({
    required Map<String, dynamic> userContext,
    required int days,
    String? overrides,
  }) async {
    if (!_isCircuitOpen) {
      try {
        final result = await _withTimeout(
          _gemini.generateMealPlan(
            userContext: userContext,
            days: days,
            overrides: overrides,
          ),
        );
        _recordSuccess();
        return result;
      } catch (e) {
        debugPrint('[AiOrchestrator] generateMealPlan cloud failed: $e');
        _recordFailure();
      }
    }

    // ── Tier 1b: Groq Cloud ──
    if (_hasGroq) {
      try {
        final result = await _withGroqTimeout(
          _groq!.generateMealPlan(
            userContext: userContext,
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

    _setSource(AiSource.local);
    return _local.generateMealPlan(
      userContext: userContext,
      days: days,
    );
  }

  /// Generate a multi-week workout plan.
  Future<Map<String, dynamic>> generateWorkoutPlan({
    required Map<String, dynamic> userContext,
    required int weeks,
  }) async {
    if (!_isCircuitOpen) {
      try {
        final result = await _withTimeout(
          _gemini.generateWorkoutPlan(
            userContext: userContext,
            weeks: weeks,
          ),
        );
        _recordSuccess();
        return result;
      } catch (e) {
        debugPrint('[AiOrchestrator] generateWorkoutPlan cloud failed: $e');
        _recordFailure();
      }
    }

    // ── Tier 1b: Groq Cloud ──
    if (_hasGroq) {
      try {
        final result = await _withGroqTimeout(
          _groq!.generateWorkoutPlan(
            userContext: userContext,
            weeks: weeks,
          ),
        );
        _setSource(AiSource.groq);
        return result;
      } catch (e) {
        debugPrint('[AiOrchestrator] generateWorkoutPlan Groq failed: $e');
      }
    }

    _setSource(AiSource.local);
    return _local.generateWorkoutPlan(
      userContext: userContext,
      weeks: weeks,
    );
  }

  /// AI coach chat — **4-tier fallback**.
  ///
  /// Tier 1a: Gemini → Tier 1b: Groq → Tier 2: Gemma 2B → Tier 3: templates.
  Future<Map<String, dynamic>> chat({
    required String message,
    required Map<String, dynamic> userContext,
    required List<Map<String, String>> history,
    Uint8List? imageBytes,
    String? mimeType,
    String? groundingContext,
  }) async {
    // ── Tier 1a: Gemini Cloud ──
    if (!_isCircuitOpen) {
      try {
        final result = await _withTimeout(
          _gemini.chat(
            message: message,
            userContext: userContext,
            history: history,
            imageBytes: imageBytes,
            mimeType: mimeType,
            groundingContext: groundingContext,
          ),
        );
        _recordSuccess();
        return result;
      } catch (e) {
        debugPrint('[AiOrchestrator] chat Tier 1a (Gemini) failed: $e');
        _recordFailure();
      }
    }

    // ── Tier 1b: Groq Cloud ──
    if (_hasGroq) {
      try {
        final result = await _withGroqTimeout(
          _groq!.chat(
            message: message,
            userContext: userContext,
            history: history,
            imageBytes: imageBytes,
            mimeType: mimeType,
            groundingContext: groundingContext,
          ),
        );
        _setSource(AiSource.groq);
        debugPrint('[AiOrchestrator] chat served by Tier 1b (Groq).');
        return result;
      } catch (e) {
        debugPrint('[AiOrchestrator] chat Tier 1b (Groq) failed: $e');
      }
    }

    // ── Tier 2: On-Device LLM (Gemma 2 2B) ──
    if (_llm.isReady || _llm.status == LlmModelStatus.downloaded) {
      try {
        final prompt = _llm.buildCoachPrompt(
          message: message,
          userContext: userContext,
          history: history,
          groundingContext: groundingContext,
        );

        final response = await _llm.generate(prompt);
        if (response != null && response.trim().isNotEmpty) {
          _setSource(AiSource.onDeviceLlm);
          debugPrint('[AiOrchestrator] chat served by Tier 2 (on-device LLM).');
          return {'response': response.trim()};
        }
      } catch (e) {
        debugPrint('[AiOrchestrator] chat Tier 2 (LLM) failed: $e');
      }
    }

    // ── Tier 3: Templates / RAG ──
    _setSource(AiSource.local);
    debugPrint('[AiOrchestrator] chat served by Tier 3 (templates).');
    return _local.chat(
      message: message,
      userContext: userContext,
    );
  }

  /// Daily AI insight — **4-tier fallback**.
  ///
  /// Tier 1a: Gemini → Tier 1b: Groq → Tier 2: Gemma 2B → Tier 3: templates.
  Future<Map<String, dynamic>> getDailyInsight({
    required Map<String, dynamic> userContext,
  }) async {
    // ── Tier 1a: Gemini Cloud ──
    if (!_isCircuitOpen) {
      try {
        final result = await _withTimeout(
          _gemini.getDailyInsight(userContext: userContext),
        );
        _recordSuccess();
        return result;
      } catch (e) {
        debugPrint('[AiOrchestrator] getDailyInsight Tier 1a (Gemini) failed: $e');
        _recordFailure();
      }
    }

    // ── Tier 1b: Groq Cloud ──
    if (_hasGroq) {
      try {
        final result = await _withGroqTimeout(
          _groq!.getDailyInsight(userContext: userContext),
        );
        _setSource(AiSource.groq);
        debugPrint('[AiOrchestrator] getDailyInsight served by Tier 1b (Groq).');
        return result;
      } catch (e) {
        debugPrint('[AiOrchestrator] getDailyInsight Tier 1b (Groq) failed: $e');
      }
    }

    // ── Tier 2: On-Device LLM ──
    if (_llm.isReady || _llm.status == LlmModelStatus.downloaded) {
      try {
        final prompt = _llm.buildInsightPrompt(userContext);
        final response = await _llm.generate(prompt);
        if (response != null && response.trim().isNotEmpty) {
          _setSource(AiSource.onDeviceLlm);
          debugPrint('[AiOrchestrator] getDailyInsight served by Tier 2 (LLM).');
          // Try to parse as JSON, fall through if it fails
          try {
            final parsed = _parseJsonResponse(response);
            if (parsed != null) return parsed;
          } catch (e) { debugPrint('[Orchestrator] parse LLM insight JSON failed: $e'); }
          // If the LLM returned plain text, wrap it
          return {
            'insight': response.trim(),
            'icon': '🧠',
            'category': 'motivation',
          };
        }
      } catch (e) {
        debugPrint('[AiOrchestrator] getDailyInsight Tier 2 (LLM) failed: $e');
      }
    }

    // ── Tier 3: Templates ──
    _setSource(AiSource.local);
    debugPrint('[AiOrchestrator] getDailyInsight served by Tier 3 (templates).');
    return _local.getDailyInsight(userContext: userContext);
  }

  /// Try to parse a JSON object from an LLM response string.
  ///
  /// Uses balanced-brace extraction to handle nested JSON correctly.
  Map<String, dynamic>? _parseJsonResponse(String text) {
    // Find the first '{' and extract the full balanced JSON object
    final start = text.indexOf('{');
    if (start == -1) return null;

    int depth = 0;
    bool inString = false;
    bool escaped = false;
    for (int i = start; i < text.length; i++) {
      final c = text[i];
      if (escaped) {
        escaped = false;
        continue;
      }
      if (c == r'\' && inString) {
        escaped = true;
        continue;
      }
      if (c == '"') {
        inString = !inString;
        continue;
      }
      if (inString) continue;
      if (c == '{') depth++;
      if (c == '}') depth--;
      if (depth == 0) {
        try {
          return Map<String, dynamic>.from(
            jsonDecode(text.substring(start, i + 1)) as Map,
          );
        } catch (e) {
          debugPrint('[AiOrchestrator] _parseJsonResponse decode failed: $e');
          return null;
        }
      }
    }
    return null;
  }

  // ── Utility ────────────────────────────────────────────────────

  /// Manually reset the circuit breaker (e.g. when user changes network).
  void resetCircuitBreaker() {
    _consecutiveFailures = 0;
    _circuitOpenedAt = null;
    debugPrint('[AiOrchestrator] Circuit breaker reset.');
  }

  /// Clear the Gemini cache.
  void clearCache() => _gemini.clearCache();

  /// Whether the circuit breaker is currently open (for debug UIs only).
  bool get isCircuitOpen => _isCircuitOpen;

  /// Number of consecutive Gemini failures.
  int get consecutiveFailures => _consecutiveFailures;

  // ── On-Device LLM Management ─────────────────────────────────

  /// Current LLM model status.
  LlmModelStatus get llmStatus => _llm.status;

  /// Whether the on-device LLM is ready for inference.
  bool get isLlmReady => _llm.isReady;

  /// Download progress (0.0 – 1.0) when the LLM model is downloading.
  double get llmDownloadProgress => _llm.downloadProgress;

  /// Trigger LLM model download from [url].
  ///
  /// Returns a stream of progress (0.0 – 1.0).
  Stream<double> downloadLlmModel(String url) => _llm.downloadModel(url);

  /// Load the LLM model into memory (after download).
  Future<bool> loadLlmModel() => _llm.loadModel();

  /// Unload the LLM model to free memory.
  void unloadLlmModel() => _llm.unloadModel();

  /// Delete the LLM model from disk.
  Future<void> deleteLlmModel() => _llm.deleteModel();

  /// Check LLM model status (e.g. on app start).
  Future<void> checkLlmStatus() => _llm.checkModelStatus();
}
