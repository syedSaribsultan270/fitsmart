import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../core/constants/app_constants.dart';
import 'ai_cache.dart';

class GeminiException implements Exception {
  final String message;
  final bool isRateLimited;
  const GeminiException(this.message, {this.isRateLimited = false});
  @override
  String toString() => 'GeminiException: $message';
}

/// Gemini 2.5 Flash client — **vision only**.
///
/// Used exclusively for:
///  - [analyzeMealPhoto] — structured JSON extraction from a meal image.
///  - [chat] — multimodal coach conversation when an image is attached.
///
/// All text-only operations are handled by [GroqClient].
class GeminiClient {
  static GeminiClient? _instance;
  factory GeminiClient({required String apiKey}) {
    _instance ??= GeminiClient._internal(apiKey: apiKey);
    return _instance!;
  }

  late final GenerativeModel _model;     // JSON mode — for structured photo analysis
  late final GenerativeModel _chatModel; // Freeform — for multimodal coach chat

  final Map<String, AiCacheEntry> _cache = {};

  GeminiClient._internal({required String apiKey}) {
    _model = GenerativeModel(
      model: AppConstants.geminiModel,
      apiKey: apiKey,
      generationConfig: GenerationConfig(
        responseMimeType: 'application/json',
        temperature: 0.4, // lower = more consistent nutrition extraction
        topK: 32,
        topP: 0.9,
      ),
      systemInstruction: Content.text(_analysisSystemPrompt),
    );

    _chatModel = GenerativeModel(
      model: AppConstants.geminiModel,
      apiKey: apiKey,
      generationConfig: GenerationConfig(
        temperature: 0.8,
        topK: 40,
        topP: 0.95,
      ),
      systemInstruction: Content.text(_chatSystemPrompt),
    );
  }

  // ── System prompts ─────────────────────────────────────────────

  static const _analysisSystemPrompt = '''
You are FitSmart AI, a fitness and nutrition assistant.
Analyze the food in the image precisely.
Always respond with valid JSON matching the requested schema exactly.
Never include markdown, code fences, or any text outside the JSON structure.
''';

  static const _chatSystemPrompt = '''
You are FitSmart AI, a personal fitness and nutrition coach inside the FitSmart app.

TONE — match the user's message energy:
- Casual greeting or small talk → respond briefly and warmly, 1-2 sentences. No data dumps.
- Off-topic question → answer naturally and briefly, light fitness hook only if it fits.
- Short fitness question → concise answer, 2-4 sentences.
- Deep question or plan request → full structured response with specifics.

NEVER give a long response to a short message.

PERSONALITY: Expert, friendly, direct. Use emojis sparingly (1 max, skip for short replies). No filler phrases.
FORMATTING (substantive responses only): **bold** for key numbers, bullet points (•) for lists, clear section breaks.

When the user sends an image:
- Identify what's in it (food, exercise form, body photo, etc.)
- Give specific, actionable feedback tied to their nutrition targets and goals
- Reference their actual data when relevant

DATA: Only pull in user data when directly relevant. For greetings or small talk, keep it out.
''';

  // ── Public API ─────────────────────────────────────────────────

  /// Extract structured nutrition data from a meal photo.
  Future<Map<String, dynamic>> analyzeMealPhoto({
    required Uint8List imageBytes,
    required Map<String, dynamic> userContext,
    String? mimeType,
    String? groundingContext,
  }) async {
    final cacheKey = 'meal_photo_${_hashBytes(imageBytes)}';

    return _request(
      cacheKey: cacheKey,
      ttlHours: 0, // photo hash is unique — cache indefinitely
      buildContent: () => [
        Content.multi([
          TextPart(_buildAnalysisPrompt(userContext, groundingContext: groundingContext)),
          DataPart(mimeType ?? 'image/jpeg', imageBytes),
        ]),
      ],
    );
  }

  /// Multimodal coach chat (text + optional image).
  Future<Map<String, dynamic>> chat({
    required String message,
    required Map<String, dynamic> userContext,
    required List<Map<String, String>> history,
    Uint8List? imageBytes,
    String? mimeType,
    String? groundingContext,
  }) async {
    try {
      final contents = <Content>[];

      // Conversation history (last 10 turns)
      for (final h in history.reversed.take(10).toList().reversed) {
        contents.add(
          h['role'] == 'user'
              ? Content.text(h['content']!)
              : Content.model([TextPart(h['content']!)]),
        );
      }

      // Context + message
      final ctx = userContext;
      final contextBlock = StringBuffer()
        ..writeln('=== USER PROFILE ===')
        ..writeln('Goal: ${ctx['goal']} | Gender: ${ctx['gender'] ?? '?'} | Age: ${ctx['age'] ?? '?'}')
        ..writeln('Weight: ${ctx['weight_kg'] ?? '?'}kg → Target: ${ctx['target_weight_kg'] ?? '?'}kg')
        ..writeln('Diet: ${ctx['dietary_restrictions'] ?? 'none'} | Avoid: ${ctx['disliked_ingredients'] ?? 'none'}')
        ..writeln('')
        ..writeln('=== TODAY\'S NUTRITION ===')
        ..writeln('Targets: ${ctx['target_calories']} kcal | ${ctx['target_protein_g']}g P | ${ctx['target_carbs_g']}g C | ${ctx['target_fat_g']}g F')
        ..writeln('Consumed: ${ctx['consumed_calories_today']} kcal | ${ctx['consumed_protein_today']}g P | ${ctx['consumed_carbs_today']}g C | ${ctx['consumed_fat_today']}g F')
        ..writeln('Remaining: ${(ctx['target_calories'] ?? 0) - (ctx['consumed_calories_today'] ?? 0)} kcal');

      if ((ctx['current_streak'] ?? 0) > 0) {
        contextBlock.writeln('Streak: ${ctx['current_streak']} days 🔥 | Level ${ctx['level']} (${ctx['level_name']})');
      }

      if (groundingContext != null && groundingContext.isNotEmpty) {
        contextBlock.writeln('\n$groundingContext');
      }

      final prompt = '$contextBlock\n\nUser: $message\n\nRespond as their AI coach.';

      if (imageBytes != null) {
        contents.add(Content.multi([
          TextPart(prompt),
          DataPart(mimeType ?? 'image/jpeg', imageBytes),
        ]));
      } else {
        contents.add(Content.text(prompt));
      }

      final response = await _chatModel.generateContent(contents);
      return {
        'response': response.text ?? 'I couldn\'t generate a response. Please try again.',
        'suggestions': <String>[],
      };
    } catch (e) {
      if (e is GeminiException) rethrow;
      throw _friendlyException(e);
    }
  }

  // ── Private ────────────────────────────────────────────────────

  Future<Map<String, dynamic>> _request({
    required String? cacheKey,
    required int ttlHours,
    required List<Content> Function() buildContent,
  }) async {
    if (cacheKey != null) {
      final cached = _cache[cacheKey];
      if (cached != null && !cached.isExpired) {
        return jsonDecode(cached.response) as Map<String, dynamic>;
      }
    }

    try {
      final response = await _model.generateContent(buildContent());
      final text = response.text ?? '{}';
      final parsed = jsonDecode(text) as Map<String, dynamic>;

      if (cacheKey != null) {
        _cache[cacheKey] = AiCacheEntry(
          response: text,
          createdAt: DateTime.now(),
          ttlHours: ttlHours,
        );
      }
      return parsed;
    } catch (e) {
      if (e is GeminiException) rethrow;
      throw _friendlyException(e);
    }
  }

  String _buildAnalysisPrompt(
    Map<String, dynamic> ctx, {
    String? groundingContext,
  }) {
    return '''
USER: goal=${ctx['goal']}, diet=${ctx['dietary_restrictions'] ?? 'none'}, targets=${ctx['target_calories']}kcal/${ctx['target_protein_g']}gP/${ctx['target_carbs_g']}gC/${ctx['target_fat_g']}gF, consumed_today=${ctx['consumed_calories_today']}kcal
${groundingContext != null ? '\n$groundingContext\n' : ''}
Identify all food items in the image, estimate portions, calculate macros.
Also identify the meal name, its main ingredients, and realistic price ranges where this meal can be found in Pakistan (PKR).

Return JSON:
{
  "meal_name": "string (common name of the overall dish, e.g. 'Chicken Biryani')",
  "items": [
    {
      "name": "string",
      "quantity_g": number,
      "calories": number,
      "protein_g": number,
      "carbs_g": number,
      "fat_g": number,
      "confidence": number
    }
  ],
  "totals": {
    "calories": number,
    "protein_g": number,
    "carbs_g": number,
    "fat_g": number,
    "fiber_g": number
  },
  "health_score": number,
  "feedback": "string",
  "identified_items_summary": "string",
  "ingredients": ["string"],
  "availability": [
    {"area": "string (e.g. Street stall / Dhaba)", "min_price": number, "max_price": number}
  ],
  "best_price": number,
  "currency": "PKR"
}''';
  }

  static GeminiException _friendlyException(Object e) {
    final msg = e.toString().toLowerCase();
    debugPrint('[GeminiClient] raw error: $e');
    if (msg.contains('quota') || msg.contains('rate') || msg.contains('429') || msg.contains('resource_exhausted')) {
      return const GeminiException('Rate limited — falling back.', isRateLimited: true);
    }
    if (msg.contains('api_key') || msg.contains('permission') || msg.contains('403')) {
      return const GeminiException('API key issue — check your Gemini API key.');
    }
    if (msg.contains('timeout') || msg.contains('deadline')) {
      return const GeminiException('Request timed out.');
    }
    if (msg.contains('network') || msg.contains('socket') || msg.contains('connection')) {
      return const GeminiException('No internet connection.');
    }
    return GeminiException('Something went wrong. Please try again.');
  }

  String _hashBytes(List<int> bytes) =>
      sha256.convert(bytes).toString().substring(0, 16);

  void clearCache() => _cache.clear();
}
