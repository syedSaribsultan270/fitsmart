import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_mediapipe_chat/flutter_mediapipe_chat.dart';
import 'package:path_provider/path_provider.dart';
import '../core/constants/app_constants.dart';

/// Status of the on-device LLM model.
enum LlmModelStatus {
  /// Model not present on disk.
  notDownloaded,

  /// Model is currently being downloaded.
  downloading,

  /// Model is on disk but not loaded into memory.
  downloaded,

  /// Model is loaded and ready for inference.
  ready,

  /// An error occurred during download or loading.
  error,
}

/// Manages the on-device Gemma 3 1B model lifecycle:
///
///  1. **Download** — fetches the model file from a configurable URL and stores
///     it in the app's documents directory. Progress is exposed as a [Stream].
///  2. **Load** — loads the model into memory via MediaPipe. This takes 2-4
///     seconds on modern phones.
///  3. **Generate** — runs inference for a given prompt. Supports both
///     synchronous (full response) and streaming modes.
///  4. **Unload** — frees memory when the model is no longer needed.
///
/// Model: Gemma 3 1B int4 (~529 MB). Faster and smaller than Gemma 2 2B
/// while matching or exceeding it on reasoning tasks.
///
/// Only used for **chat** and **daily insight** features — structured data
/// features (meal analysis, plans) use the faster deterministic fallback.
class LocalLlmService {
  LocalLlmService._();
  static final instance = LocalLlmService._();

  FlutterMediapipeChat? _chat;
  LlmModelStatus _status = LlmModelStatus.notDownloaded;
  double _downloadProgress = 0;
  String? _errorMessage;

  /// Current model status.
  LlmModelStatus get status => _status;

  /// Download progress (0.0 – 1.0) when [status] is [LlmModelStatus.downloading].
  double get downloadProgress => _downloadProgress;

  /// Human-readable error message when [status] is [LlmModelStatus.error].
  String? get errorMessage => _errorMessage;

  /// Whether the model is loaded and ready for inference.
  bool get isReady => _status == LlmModelStatus.ready;

  /// Whether the model file exists on disk (may not be loaded yet).
  bool get isDownloaded =>
      _status == LlmModelStatus.downloaded || _status == LlmModelStatus.ready;

  // ── Model Path ──────────────────────────────────────────────────

  Future<String> _modelDir() async {
    final dir = await getApplicationDocumentsDirectory();
    return '${dir.path}/models';
  }

  Future<String> _modelPath() async {
    return '${await _modelDir()}/${AppConstants.llmModelFileName}';
  }

  // ── Initialization ──────────────────────────────────────────────

  /// Check if the model file exists on disk and update status.
  Future<void> checkModelStatus() async {
    if (kIsWeb) {
      _status = LlmModelStatus.notDownloaded; // LLM not supported on web
      return;
    }

    try {
      final path = await _modelPath();
      final file = File(path);
      if (await file.exists()) {
        final size = await file.length();
        // Gemma 3 1B int4 is ~529 MB. Reject truncated files.
        if (size > 100 * 1024 * 1024) {
          _status = LlmModelStatus.downloaded;
        } else {
          // Truncated / corrupt — delete and re-download
          await file.delete();
          _status = LlmModelStatus.notDownloaded;
        }
      } else {
        _status = LlmModelStatus.notDownloaded;
      }
    } catch (e) {
      debugPrint('[LocalLlm] Error checking model status: $e');
      _status = LlmModelStatus.notDownloaded;
    }
  }

  // ── Download ────────────────────────────────────────────────────

  /// Download the model file from the given [url].
  ///
  /// Call this from a settings screen or trigger it automatically on first
  /// Gemini failure. The [url] should point to a Gemma 3 1B int4 `.task` file
  /// hosted on your CDN, Firebase Storage, or any HTTP server.
  ///
  /// Returns a [Stream] of download progress (0.0 – 1.0).
  Stream<double> downloadModel(String url) async* {
    if (_status == LlmModelStatus.downloading) return;
    if (kIsWeb) return;

    _status = LlmModelStatus.downloading;
    _downloadProgress = 0;
    _errorMessage = null;

    try {
      final dir = await _modelDir();
      await Directory(dir).create(recursive: true);
      final path = await _modelPath();
      final tmpPath = '$path.tmp';

      final client = HttpClient();
      final request = await client.getUrl(Uri.parse(url));
      final response = await request.close();

      if (response.statusCode != 200) {
        throw Exception('HTTP ${response.statusCode}');
      }

      final totalBytes = response.contentLength;
      int receivedBytes = 0;
      final sink = File(tmpPath).openWrite();

      await for (final chunk in response) {
        sink.add(chunk);
        receivedBytes += chunk.length;
        if (totalBytes > 0) {
          _downloadProgress = receivedBytes / totalBytes;
          yield _downloadProgress;
        }
      }

      await sink.flush();
      await sink.close();
      client.close();

      // Rename tmp → final atomically
      await File(tmpPath).rename(path);

      _status = LlmModelStatus.downloaded;
      _downloadProgress = 1.0;
      yield 1.0;

      debugPrint('[LocalLlm] Model downloaded: ${(receivedBytes / 1024 / 1024).toStringAsFixed(1)} MB');
    } catch (e) {
      _status = LlmModelStatus.error;
      _errorMessage = 'Download failed: $e';
      debugPrint('[LocalLlm] Download error: $e');

      // Clean up partial download
      try {
        final tmpPath = '${await _modelPath()}.tmp';
        final tmpFile = File(tmpPath);
        if (await tmpFile.exists()) await tmpFile.delete();
      } catch (e) { debugPrint('[LocalLLM] cleanup partial download failed: $e'); }

      yield -1; // Signal error
    }
  }

  // ── Load / Unload ───────────────────────────────────────────────

  /// Load the model into memory. Must be called after download completes.
  /// Takes 2-4 seconds on modern phones.
  Future<bool> loadModel() async {
    if (kIsWeb) return false;
    if (_status == LlmModelStatus.ready) return true;

    await checkModelStatus();
    if (_status != LlmModelStatus.downloaded) return false;

    try {
      final path = await _modelPath();
      _chat = FlutterMediapipeChat();

      final config = ModelConfig(
        path: path,
        temperature: AppConstants.llmTemperature,
        maxTokens: AppConstants.llmMaxTokens,
        topK: AppConstants.llmTopK,
        randomSeed: 0,
      );

      await _chat!.loadModel(config);
      _status = LlmModelStatus.ready;
      debugPrint('[LocalLlm] Model loaded and ready.');
      return true;
    } catch (e) {
      _status = LlmModelStatus.error;
      _errorMessage = 'Failed to load model: $e';
      debugPrint('[LocalLlm] Load error: $e');
      _chat = null;
      return false;
    }
  }

  /// Unload the model from memory to free resources.
  void unloadModel() {
    _chat = null;
    if (_status == LlmModelStatus.ready) {
      _status = LlmModelStatus.downloaded;
    }
    debugPrint('[LocalLlm] Model unloaded.');
  }

  // ── Inference ───────────────────────────────────────────────────

  /// Generate a complete response for the given [prompt].
  ///
  /// Returns `null` if the model isn't ready or inference fails.
  Future<String?> generate(String prompt) async {
    if (!isReady || _chat == null) {
      // Try loading if downloaded but not loaded
      if (_status == LlmModelStatus.downloaded) {
        final loaded = await loadModel();
        if (!loaded) return null;
      } else {
        return null;
      }
    }

    try {
      final response = await _chat!
          .generateResponse(prompt)
          .timeout(
            Duration(seconds: AppConstants.llmInferenceTimeoutSec),
            onTimeout: () => null,
          );
      return response;
    } catch (e) {
      debugPrint('[LocalLlm] Inference error: $e');
      return null;
    }
  }

  /// Stream tokens for the given [prompt] (for real-time UI updates).
  Stream<String> generateStream(String prompt) async* {
    if (!isReady || _chat == null) {
      // Try loading if downloaded but not loaded
      if (_status == LlmModelStatus.downloaded) {
        final loaded = await loadModel();
        if (!loaded) return;
      } else {
        return;
      }
    }

    try {
      await for (final token in _chat!.generateResponseAsync(prompt)) {
        yield token;
      }
    } catch (e) {
      debugPrint('[LocalLlm] Streaming error: $e');
    }
  }

  // ── Coach Prompt Builder ────────────────────────────────────────

  /// Build a complete prompt for the AI coach, including system instruction
  /// and user context. This mirrors what GeminiClient._chatSystemInstruction
  /// does, adapted for the local model's context window.
  String buildCoachPrompt({
    required String message,
    required Map<String, dynamic> userContext,
    List<Map<String, String>>? history,
    String? groundingContext,
  }) {
    final ctx = userContext;
    final buf = StringBuffer();

    // System instruction (concise for smaller context window)
    buf.writeln('<start_of_turn>user');
    buf.writeln('You are FitSmart AI, an expert personal fitness and nutrition coach.');
    buf.writeln('Be specific, actionable, encouraging. Use **bold** for key numbers.');
    buf.writeln('Use bullet points for lists. Reference the user\'s data below.');
    buf.writeln('');

    // User context (essential fields only to save tokens)
    buf.writeln('=== USER DATA ===');
    if (ctx['goal'] != null) buf.writeln('Goal: ${ctx['goal']}');
    if (ctx['age'] != null) buf.writeln('Age: ${ctx['age']}');
    if (ctx['gender'] != null) buf.writeln('Gender: ${ctx['gender']}');
    if (ctx['weight_kg'] != null) buf.writeln('Weight: ${ctx['weight_kg']}kg');
    if (ctx['target_weight_kg'] != null) buf.writeln('Target: ${ctx['target_weight_kg']}kg');
    if (ctx['height_cm'] != null) buf.writeln('Height: ${ctx['height_cm']}cm');
    if (ctx['activity_level'] != null) buf.writeln('Activity: ${ctx['activity_level']}');

    // Today's nutrition
    buf.writeln('');
    buf.writeln('=== TODAY ===');
    final tCal = ctx['target_calories'] ?? '?';
    final cCal = ctx['consumed_calories_today'] ?? 0;
    final tP = ctx['target_protein_g'] ?? '?';
    final cP = ctx['consumed_protein_today'] ?? 0;
    buf.writeln('Calories: $cCal / $tCal kcal');
    buf.writeln('Protein: ${cP}g / ${tP}g');
    if (ctx['consumed_carbs_today'] != null) {
      buf.writeln('Carbs: ${ctx['consumed_carbs_today']}g / ${ctx['target_carbs_g'] ?? '?'}g');
    }
    if (ctx['consumed_fat_today'] != null) {
      buf.writeln('Fat: ${ctx['consumed_fat_today']}g / ${ctx['target_fat_g'] ?? '?'}g');
    }

    // Streak & gamification
    if (ctx['current_streak'] != null && (ctx['current_streak'] as num) > 0) {
      buf.writeln('Streak: ${ctx['current_streak']} days 🔥');
    }
    if (ctx['level_name'] != null) {
      buf.writeln('Level: ${ctx['level']} (${ctx['level_name']})');
    }

    // Today's meals summary
    if (ctx['todays_meals'] != null) {
      buf.writeln('');
      buf.writeln('Meals today: ${ctx['todays_meals']}');
    }

    // Grounding context from RAG
    if (groundingContext != null && groundingContext.isNotEmpty) {
      buf.writeln('');
      buf.writeln(groundingContext);
    }

    // Recent conversation history (last 4 messages to save tokens)
    if (history != null && history.isNotEmpty) {
      buf.writeln('');
      buf.writeln('=== RECENT CHAT ===');
      for (final h in history.reversed.take(4).toList().reversed) {
        final role = h['role'] == 'user' ? 'User' : 'Coach';
        final content = h['content'] ?? '';
        // Truncate long messages to save context
        final truncated = content.length > 200 ? '${content.substring(0, 200)}...' : content;
        buf.writeln('$role: $truncated');
      }
    }

    buf.writeln('');
    buf.writeln('User: $message');
    buf.writeln('<end_of_turn>');
    buf.writeln('<start_of_turn>model');

    return buf.toString();
  }

  // ── JSON Feature Prompt Builders ───────────────────────────────

  /// Prompt for analyzing a meal from text description.
  String buildMealTextAnalysisPrompt({
    required String description,
    required Map<String, dynamic> userContext,
  }) {
    final goal = userContext['goal'] ?? 'maintain';
    final targetCal = userContext['target_calories'] ?? '?';
    final targetP = userContext['target_protein_g'] ?? '?';
    return '''<start_of_turn>user
Parse this meal and return ONLY a valid JSON object, no other text.

User goal: $goal | Daily target: $targetCal kcal, ${targetP}g protein
Meal description: "$description"

Return exactly this JSON structure:
{"items":[{"name":"string","quantity_g":number,"calories":number,"protein_g":number,"carbs_g":number,"fat_g":number}],"totals":{"calories":number,"protein_g":number,"carbs_g":number,"fat_g":number},"health_score":number,"feedback":"string"}
<end_of_turn>
<start_of_turn>model
{''';
  }

  /// Prompt for meal feedback after logging.
  String buildMealFeedbackPrompt({
    required Map<String, dynamic> mealData,
    required Map<String, dynamic> userContext,
  }) {
    final goal = userContext['goal'] ?? 'maintain';
    final targetCal = userContext['target_calories'] ?? '?';
    final targetP = userContext['target_protein_g'] ?? '?';
    final consumed = userContext['consumed_calories_today'] ?? 0;
    return '''<start_of_turn>user
Give coaching feedback on this logged meal. Return ONLY a valid JSON object.

Goal: $goal | Daily target: $targetCal kcal, ${targetP}g protein | Consumed so far today: $consumed kcal
Meal: ${mealData['name'] ?? 'meal'} — ${mealData['calories'] ?? '?'} kcal, ${mealData['protein_g'] ?? '?'}g protein, ${mealData['carbs_g'] ?? '?'}g carbs, ${mealData['fat_g'] ?? '?'}g fat

Return exactly:
{"feedback":"2-3 specific sentences referencing their data","health_score":number 1-10,"suggestions":["actionable tip","actionable tip"]}
<end_of_turn>
<start_of_turn>model
{''';
  }

  /// Prompt for generating a meal plan (simplified for 1B model — 1 day).
  String buildMealPlanPrompt({
    required Map<String, dynamic> userContext,
    required int days,
    String? overrides,
  }) {
    final goal = userContext['goal'] ?? 'maintain';
    final targetCal = userContext['target_calories'] ?? 2000;
    final targetP = userContext['target_protein_g'] ?? 150;
    final targetC = userContext['target_carbs_g'] ?? 200;
    final targetF = userContext['target_fat_g'] ?? 65;
    final diet = userContext['dietary_restrictions'] ?? 'none';
    return '''<start_of_turn>user
Create a 1-day meal plan. Return ONLY a valid JSON object.

Goal: $goal | Targets: $targetCal kcal, ${targetP}g protein, ${targetC}g carbs, ${targetF}g fat
Diet restrictions: $diet${overrides != null ? ' | Special: $overrides' : ''}

Return exactly:
{"plan_name":"string","days":[{"day":1,"meals":[{"meal_type":"breakfast","name":"string","items":[{"name":"string","quantity_g":number,"calories":number,"protein_g":number,"carbs_g":number,"fat_g":number}],"totals":{"calories":number,"protein_g":number,"carbs_g":number,"fat_g":number}},{"meal_type":"lunch","name":"string","items":[{"name":"string","quantity_g":number,"calories":number,"protein_g":number,"carbs_g":number,"fat_g":number}],"totals":{"calories":number,"protein_g":number,"carbs_g":number,"fat_g":number}},{"meal_type":"dinner","name":"string","items":[{"name":"string","quantity_g":number,"calories":number,"protein_g":number,"carbs_g":number,"fat_g":number}],"totals":{"calories":number,"protein_g":number,"carbs_g":number,"fat_g":number}}],"day_totals":{"calories":number,"protein_g":number,"carbs_g":number,"fat_g":number}}]}
<end_of_turn>
<start_of_turn>model
{''';
  }

  /// Prompt for generating a workout plan (simplified for 1B model — 1 week).
  String buildWorkoutPlanPrompt({
    required Map<String, dynamic> userContext,
    required int weeks,
  }) {
    final goal = userContext['goal'] ?? 'maintain';
    final days = userContext['workout_days_per_week'] ?? 4;
    final activity = userContext['activity_level'] ?? 'moderate';
    return '''<start_of_turn>user
Create a 1-week workout plan. Return ONLY a valid JSON object.

Goal: $goal | Workout days per week: $days | Activity level: $activity

Return exactly:
{"plan_name":"string","weeks":[{"week":1,"days":[{"day_name":"string","focus":"string","exercises":[{"name":"string","sets":number,"reps":"string","rest_sec":number,"notes":"string"}]}]}]}
<end_of_turn>
<start_of_turn>model
{''';
  }

  /// Build a prompt for generating a daily insight.
  String buildInsightPrompt(Map<String, dynamic> userContext) {
    final buf = StringBuffer();
    buf.writeln('<start_of_turn>user');
    buf.writeln('You are FitSmart AI. Generate a brief (2 sentences) motivational insight.');
    buf.writeln('Based on this data:');
    buf.writeln('Meals today: ${userContext['meals_today'] ?? 0}');
    buf.writeln('Calories: ${userContext['calories'] ?? 0} / ${userContext['target_calories'] ?? '?'}');
    buf.writeln('Protein: ${userContext['protein'] ?? 0}g');
    buf.writeln('');
    buf.writeln('Return ONLY a JSON object: {"insight": "...", "icon": "emoji", "category": "nutrition|workout|progress|motivation"}');
    buf.writeln('<end_of_turn>');
    buf.writeln('<start_of_turn>model');
    return buf.toString();
  }

  // ── Cleanup ─────────────────────────────────────────────────────

  /// Delete the downloaded model file from disk.
  Future<void> deleteModel() async {
    unloadModel();
    try {
      final path = await _modelPath();
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
        debugPrint('[LocalLlm] Model file deleted.');
      }
    } catch (e) {
      debugPrint('[LocalLlm] Delete error: $e');
    }
    _status = LlmModelStatus.notDownloaded;
    _downloadProgress = 0;
  }
}
