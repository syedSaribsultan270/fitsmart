import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../core/constants/app_constants.dart';
import 'ai_cache.dart';

/// Groq cloud inference client — OpenAI-compatible REST API.
///
/// **Free tier:** 30 RPM, 14,400 RPD — 10× more generous than Gemini.
/// Used as Tier 1b (secondary cloud) when Gemini is rate-limited or down.
///
/// Supports all the same methods as [GeminiClient]:
///  - [analyzeMealText] / [analyzeMealPhoto] — structured JSON
///  - [getMealFeedback] — structured JSON
///  - [generateMealPlan] / [generateWorkoutPlan] — structured JSON
///  - [chat] — freeform coach conversation
///  - [getDailyInsight] — structured JSON
class GroqClient {
  static GroqClient? _instance;
  factory GroqClient({required String apiKey}) {
    _instance ??= GroqClient._internal(apiKey: apiKey);
    return _instance!;
  }

  final String _apiKey;
  final Map<String, AiCacheEntry> _cache = {};

  static const _baseUrl = 'https://api.groq.com/openai/v1/chat/completions';

  GroqClient._internal({required String apiKey}) : _apiKey = apiKey;

  // ── System Prompts ──────────────────────────────────────────────

  static const _jsonSystemPrompt = '''
You are FitSmart AI, a fitness and nutrition coach assistant.
Always respond with valid JSON matching the requested schema.
Be precise with nutritional data. Use evidence-based recommendations.
Be encouraging, practical, and personalized. Keep responses concise.
Never include markdown code fences, prose wrappers, or explanations outside the JSON structure.
Return ONLY the raw JSON object, no ```json wrapper.''';

  static const _chatSystemPrompt = '''
You are FitSmart AI, the most advanced personal fitness and nutrition coach built into the FitSmart app. You have COMPLETE access to every piece of the user's data — their profile, body stats, goals, meals, workouts, personal records, body measurements, weight history, sleep schedule, dietary preferences, gamification progress, and more.

PERSONALITY:
- Expert-level knowledge in exercise science, nutrition, sports psychology
- Friendly, motivating, knowledgeable — like a world-class personal trainer
- Use emojis sparingly (1-2 per response)
- Be direct and actionable — no filler
- Always back up advice with the user's actual data

FORMATTING:
- Use **bold** for emphasis and key numbers
- Use bullet points (•) for lists
- Use line breaks to separate sections
- When giving meal plans, workout plans, or structured advice: use clear headers and organized lists with specific quantities, calories, and macros

ALWAYS:
- Reference the user's actual data (calories, protein, weight, measurements, PRs, streak) when relevant
- Give specific numbers, not vague advice
- If they've logged meals today, reference what they've eaten and remaining macros
- Celebrate their achievements (PRs, streaks, badges, level ups)''';

  // ── Core Request ────────────────────────────────────────────────

  /// Make a request to Groq's API.
  Future<String> _post({
    required String systemPrompt,
    required List<Map<String, dynamic>> messages,
    bool jsonMode = false,
    double temperature = 0.7,
    int maxTokens = 2048,
  }) async {
    final body = <String, dynamic>{
      'model': AppConstants.groqModel,
      'messages': [
        {'role': 'system', 'content': systemPrompt},
        ...messages,
      ],
      'temperature': temperature,
      'max_tokens': maxTokens,
      'top_p': 0.95,
    };

    if (jsonMode) {
      body['response_format'] = {'type': 'json_object'};
    }

    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: {
        'Authorization': 'Bearer $_apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 429) {
      throw GroqException(
        'Groq rate limited — too many requests.',
        isRateLimited: true,
      );
    }

    if (response.statusCode != 200) {
      throw GroqException(
        'Groq API error: HTTP ${response.statusCode}',
      );
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final choices = json['choices'] as List<dynamic>?;
    if (choices == null || choices.isEmpty) {
      throw const GroqException('Groq returned empty response.');
    }

    final content =
        (choices[0] as Map<String, dynamic>)['message']['content'] as String;
    return content;
  }

  /// JSON request with caching.
  Future<Map<String, dynamic>> _jsonRequest({
    required String? cacheKey,
    required int ttlHours,
    required List<Map<String, dynamic>> messages,
    double temperature = 0.7,
    int maxTokens = 2048,
  }) async {
    // Check cache
    if (cacheKey != null) {
      final cached = _cache[cacheKey];
      if (cached != null && !cached.isExpired) {
        return jsonDecode(cached.response) as Map<String, dynamic>;
      }
    }

    final text = await _post(
      systemPrompt: _jsonSystemPrompt,
      messages: messages,
      jsonMode: true,
      temperature: temperature,
      maxTokens: maxTokens,
    );

    // Strip markdown fences if present
    final cleaned = _stripJsonFences(text);
    final parsed = jsonDecode(cleaned) as Map<String, dynamic>;

    if (cacheKey != null) {
      _cache[cacheKey] = AiCacheEntry(
        response: cleaned,
        createdAt: DateTime.now(),
        ttlHours: ttlHours,
      );
    }

    return parsed;
  }

  // ── Public API ──────────────────────────────────────────────────

  /// Analyze a meal from a photo.
  ///
  /// Note: Groq doesn't support image input on all models. Falls through
  /// if the model doesn't support vision.
  Future<Map<String, dynamic>> analyzeMealPhoto({
    required Uint8List imageBytes,
    required Map<String, dynamic> userContext,
    String? mimeType,
    String? groundingContext,
  }) async {
    // Groq's Llama models support vision via base64
    final base64Image = base64Encode(imageBytes);
    final mime = mimeType ?? 'image/jpeg';

    return _jsonRequest(
      cacheKey: null, // Don't cache photo analysis across providers
      ttlHours: 0,
      messages: [
        {
          'role': 'user',
          'content': [
            {
              'type': 'text',
              'text': '''${_buildUserContextString(userContext)}
${groundingContext != null ? '\n$groundingContext\n' : ''}
Analyze this meal photo. Identify all visible food items, estimate portions, and calculate macros.

Return JSON:
{
  "items": [{"name": "string", "quantity_g": number, "calories": number, "protein_g": number, "carbs_g": number, "fat_g": number, "confidence": number}],
  "totals": {"calories": number, "protein_g": number, "carbs_g": number, "fat_g": number, "fiber_g": number},
  "health_score": number (1-10),
  "feedback": "string",
  "identified_items_summary": "string"
}''',
            },
            {
              'type': 'image_url',
              'image_url': {
                'url': 'data:$mime;base64,$base64Image',
              },
            },
          ],
        },
      ],
    );
  }

  /// Analyze a meal from text description.
  Future<Map<String, dynamic>> analyzeMealText({
    required String description,
    required Map<String, dynamic> userContext,
    String? groundingContext,
  }) async {
    final cacheKey = 'groq_meal_text_${description.hashCode}';

    return _jsonRequest(
      cacheKey: cacheKey,
      ttlHours: 24,
      messages: [
        {
          'role': 'user',
          'content': '''${_buildUserContextString(userContext)}
${groundingContext != null ? '\n$groundingContext\n' : ''}
Parse this meal description and return nutritional data:
"$description"

Return JSON:
{
  "items": [{"name": "string", "quantity_g": number, "calories": number, "protein_g": number, "carbs_g": number, "fat_g": number}],
  "totals": {"calories": number, "protein_g": number, "carbs_g": number, "fat_g": number},
  "health_score": number (1-10),
  "feedback": "string (1 sentence)"
}''',
        },
      ],
    );
  }

  /// Get feedback after logging a meal.
  Future<Map<String, dynamic>> getMealFeedback({
    required Map<String, dynamic> mealData,
    required Map<String, dynamic> userContext,
  }) async {
    return _jsonRequest(
      cacheKey: null,
      ttlHours: 0,
      messages: [
        {
          'role': 'user',
          'content': '''${_buildUserContextString(userContext)}

Meal just logged: ${jsonEncode(mealData)}

Give feedback on this meal. Return JSON:
{
  "feedback": "string (2-3 sentences, specific, encouraging)",
  "health_score": number (1-10),
  "suggestions": ["string"]
}''',
        },
      ],
    );
  }

  /// Generate a multi-day meal plan.
  Future<Map<String, dynamic>> generateMealPlan({
    required Map<String, dynamic> userContext,
    required int days,
    String? overrides,
  }) async {
    return _jsonRequest(
      cacheKey: null,
      ttlHours: 0,
      maxTokens: 4096,
      messages: [
        {
          'role': 'user',
          'content': '''${_buildUserContextString(userContext)}
${overrides != null ? 'Special requests: $overrides\n' : ''}
Generate a $days-day meal plan tailored to these targets and preferences.

Return JSON:
{
  "plan_name": "string",
  "days": [
    {
      "day": number,
      "meals": [
        {
          "meal_type": "breakfast"|"lunch"|"dinner"|"snack",
          "name": "string",
          "items": [{"name": "string", "quantity_g": number, "calories": number, "protein_g": number, "carbs_g": number, "fat_g": number}],
          "totals": {"calories": number, "protein_g": number, "carbs_g": number, "fat_g": number}
        }
      ],
      "day_totals": {"calories": number, "protein_g": number, "carbs_g": number, "fat_g": number}
    }
  ]
}''',
        },
      ],
    );
  }

  /// Generate a multi-week workout plan.
  Future<Map<String, dynamic>> generateWorkoutPlan({
    required Map<String, dynamic> userContext,
    required int weeks,
  }) async {
    return _jsonRequest(
      cacheKey: null,
      ttlHours: 0,
      maxTokens: 4096,
      messages: [
        {
          'role': 'user',
          'content': '''${_buildUserContextString(userContext)}

Generate a $weeks-week workout plan. Return JSON:
{
  "plan_name": "string",
  "weeks": [
    {
      "week": number,
      "days": [
        {
          "day_name": "string",
          "focus": "string",
          "exercises": [
            {"name": "string", "sets": number, "reps": "string", "rest_sec": number, "notes": "string"}
          ]
        }
      ]
    }
  ]
}''',
        },
      ],
    );
  }

  /// AI coach chat.
  Future<Map<String, dynamic>> chat({
    required String message,
    required Map<String, dynamic> userContext,
    required List<Map<String, String>> history,
    Uint8List? imageBytes,
    String? mimeType,
    String? groundingContext,
  }) async {
    final messages = <Map<String, dynamic>>[];

    // Add conversation history (last 10)
    for (final h in history.reversed.take(10).toList().reversed) {
      messages.add({
        'role': h['role'] == 'user' ? 'user' : 'assistant',
        'content': h['content'] ?? '',
      });
    }

    // Build the rich context + message
    final ctx = userContext;
    final contextBlock = StringBuffer()
      ..writeln('=== COMPLETE USER PROFILE ===')
      ..writeln('Goal: ${ctx['goal']}')
      ..writeln('Gender: ${ctx['gender'] ?? 'not set'} | Age: ${ctx['age'] ?? 'not set'}')
      ..writeln('Height: ${ctx['height_cm'] ?? '?'}cm | Weight: ${ctx['weight_kg'] ?? '?'}kg → Target: ${ctx['target_weight_kg'] ?? '?'}kg')
      ..writeln('Activity: ${ctx['activity_level'] ?? 'moderate'} | Workout days: ${ctx['workout_days_per_week'] ?? '?'}/week')
      ..writeln('Diet restrictions: ${ctx['dietary_restrictions'] ?? 'none'} | Cuisine: ${ctx['cuisine_preferences'] ?? 'any'}')
      ..writeln('')
      ..writeln('=== TODAY\'S NUTRITION ===')
      ..writeln('Targets: ${ctx['target_calories']} kcal | ${ctx['target_protein_g']}g P | ${ctx['target_carbs_g']}g C | ${ctx['target_fat_g']}g F')
      ..writeln('Consumed: ${ctx['consumed_calories_today']} kcal | ${ctx['consumed_protein_today']}g P | ${ctx['consumed_carbs_today']}g C | ${ctx['consumed_fat_today']}g F')
      ..writeln('Remaining: ${(ctx['target_calories'] ?? 0) - (ctx['consumed_calories_today'] ?? 0)} kcal');

    if (ctx['current_streak'] != null && (ctx['current_streak'] as num) > 0) {
      contextBlock.writeln('Streak: ${ctx['current_streak']} days 🔥 | Level: ${ctx['level']} (${ctx['level_name']})');
    }

    if (ctx['todays_meals'] != null) {
      contextBlock.writeln('\n=== MEALS TODAY ===\n${ctx['todays_meals']}');
    }
    if (ctx['recent_workouts'] != null) {
      contextBlock.writeln('\n=== RECENT WORKOUTS ===\n${ctx['recent_workouts']}');
    }
    if (ctx['personal_records'] != null) {
      contextBlock.writeln('\n=== PERSONAL RECORDS ===\n${ctx['personal_records']}');
    }
    if (ctx['body_measurements'] != null) {
      contextBlock.writeln('\n=== BODY MEASUREMENTS ===\n${ctx['body_measurements']}');
    }
    if (ctx['weight_history'] != null) {
      contextBlock.writeln('\n=== WEIGHT HISTORY ===\n${ctx['weight_history']}');
    }
    if (ctx['weekly_summary'] != null) {
      contextBlock.writeln('\n=== LAST 7 DAYS ===\n${ctx['weekly_summary']}');
    }
    if (ctx['active_workout_plan'] != null) {
      contextBlock.writeln('\n=== ACTIVE WORKOUT PLAN ===\n${ctx['active_workout_plan']}');
    }
    if (ctx['active_meal_plan'] != null) {
      contextBlock.writeln('\n=== ACTIVE MEAL PLAN ===\n${ctx['active_meal_plan']}');
    }
    if (groundingContext != null && groundingContext.isNotEmpty) {
      contextBlock.writeln('\n$groundingContext');
    }

    // Build message content
    final prompt = '$contextBlock\n\nUser message: $message\n\nRespond as their personal AI coach. Be specific, actionable, and reference their data above.';

    if (imageBytes != null) {
      final base64Image = base64Encode(imageBytes);
      final mime = mimeType ?? 'image/jpeg';
      messages.add({
        'role': 'user',
        'content': [
          {'type': 'text', 'text': prompt},
          {
            'type': 'image_url',
            'image_url': {'url': 'data:$mime;base64,$base64Image'},
          },
        ],
      });
    } else {
      messages.add({'role': 'user', 'content': prompt});
    }

    final text = await _post(
      systemPrompt: _chatSystemPrompt,
      messages: messages,
      temperature: 0.8,
      maxTokens: 2048,
    );

    return {'response': text, 'suggestions': <String>[]};
  }

  /// Daily AI insight for the dashboard.
  Future<Map<String, dynamic>> getDailyInsight({
    required Map<String, dynamic> userContext,
  }) async {
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final cacheKey = 'groq_insight_$today';

    return _jsonRequest(
      cacheKey: cacheKey,
      ttlHours: AppConstants.cacheTtlDailyInsight,
      messages: [
        {
          'role': 'user',
          'content': '''${_buildUserContextString(userContext)}

Generate today's motivational AI insight based on recent trends.
Return JSON:
{
  "insight": "string (2 sentences, specific to their data)",
  "icon": "string (emoji)",
  "category": "nutrition"|"workout"|"progress"|"motivation"
}''',
        },
      ],
    );
  }

  // ── Helpers ─────────────────────────────────────────────────────

  String _buildUserContextString(Map<String, dynamic> ctx) {
    return 'USER_CONTEXT: ${jsonEncode(ctx)}';
  }

  String _stripJsonFences(String text) {
    var s = text.trim();
    if (s.startsWith('```json')) s = s.substring(7);
    if (s.startsWith('```')) s = s.substring(3);
    if (s.endsWith('```')) s = s.substring(0, s.length - 3);
    return s.trim();
  }

  void clearCache() => _cache.clear();

  /// Whether Groq is configured (has an API key).
  bool get isConfigured => _apiKey.isNotEmpty;
}

/// Groq-specific exception.
class GroqException implements Exception {
  final String message;
  final bool isRateLimited;
  const GroqException(this.message, {this.isRateLimited = false});
  @override
  String toString() => 'GroqException: $message';
}

