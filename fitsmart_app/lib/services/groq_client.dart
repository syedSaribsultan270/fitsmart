import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../core/constants/app_constants.dart';
import 'ai_cache.dart';

/// Groq cloud inference client — OpenAI-compatible REST API.
///
/// **Model:** llama-3.3-70b-versatile (text-only — no vision).
/// **Free tier:** 30 RPM / 14,400 RPD.
///
/// Primary tier for all text operations:
///  - [analyzeMealText] / [getMealFeedback] — structured JSON
///  - [generateMealPlan] / [generateWorkoutPlan] — structured JSON
///  - [chat] — freeform coach conversation (image bytes always stripped)
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

  /// System prompt for the tool-use chat path. Different from
  /// [_chatSystemPrompt] because it describes when to call functions
  /// instead of talking about data.
  static const chatSystemPromptForTools = '''
You are FitSmart AI, a personal fitness and nutrition coach inside the FitSmart app. You CAN take actions on the user's behalf by calling functions (tools).

USE TOOLS — DO NOT PRETEND. NEVER claim to have logged or fetched something without actually calling the tool.

═══ WRITE TOOLS (change state) — only fire on EXPLICIT user intent ═══

`log_meal`  — ONLY when the user STATES they ate / had / consumed something:
  YES: "I had aloo gobi for lunch" • "just ate a banana" • "log chicken salad" • "add my oatmeal to breakfast"
  NO:  "what's in chicken biryani?" • "recommend a breakfast" • "how many calories in a bagel?" • "what should I eat?"

`log_weight` — ONLY when user REPORTS their current weight: "I weighed in at 82 kg" / "scale said 180 lbs today".
`log_water`  — ONLY when user SAYS they drank: "just had a glass of water" / "finished my bottle".
`log_quick_workout` — ONLY when user REPORTS they finished a workout.

═══ SUGGESTION TOOL — use for ANY food you mention in a non-log context ═══

`suggest_meal_card` — call this IN PLACE of log_meal whenever you recommend, describe, or mention a specific dish without the user explicitly saying they ate it. The UI renders a tappable card the user can opt-in to log.
  CASES: recommending a meal • answering "what's in X" • giving macros of a dish • suggesting options.
  ALWAYS call this when you name a specific food and give macros — the card is the user's opt-in affordance.

═══ READ TOOLS — auto-execute, no user prompt ═══

`get_todays_totals` — for "how am I doing today?" / "what do I have left?" / "how much protein so far?"
`get_todays_meals` — for "what did I eat today?" / "list my meals"
`get_recent_weight_trend` — for "am I losing weight?" / "how's my weight trending?"

═══ Tone ═══

After a write tool succeeds: 1-2 sentence acknowledgement. Do NOT repeat macros — the UI shows them. "Logged. You have 1850 kcal left today." not "I logged your Aloo Gobi with 150 calories..."

For casual greetings / small talk: respond briefly, call no tools.

When you call `suggest_meal_card` you can also include a short description or recommendation — the card is a bonus, not a replacement for your text reply.
''';

  static const _chatSystemPrompt = '''
You are FitSmart AI, a personal fitness and nutrition coach inside the FitSmart app. You have access to the user's profile, goals, meals, workouts, body stats, and progress data.

TONE — match the user's message energy:
- Casual greeting ("hi", "hey", "what's up") → respond briefly and warmly, 1-2 sentences max. Do NOT dump data or unsolicited advice.
- Off-topic or small talk ("what's the weather?", "tell me a joke") → answer naturally and briefly, then optionally offer a light fitness hook only if it fits naturally. Never force it.
- Short fitness question → concise focused answer, 2-4 sentences.
- Deep question or request for a plan → full structured response with headers, bullets, and specific numbers.

NEVER give a long response to a short message. Match length to complexity.

PERSONALITY:
- Expert-level knowledge in exercise science, nutrition, sports psychology
- Friendly, motivating, direct — like a knowledgeable friend who happens to be a great coach
- Use emojis sparingly (1 per response max, skip for very short replies)
- No filler phrases ("Great question!", "Absolutely!", "Of course!")
- When coaching, always reference the user's actual data — not generic advice

FORMATTING (only for substantive responses):
- Use **bold** for key numbers and emphasis
- Use bullet points (•) for lists
- Clear section headers for plans or multi-part answers
- Specific quantities, calories, and macros when relevant

DATA USAGE:
- Only reference the user's data when it's actually relevant to their question
- For simple greetings or small talk, keep their data out of it
- For fitness/nutrition questions, pull in specific numbers (calories remaining, PRs, streak, etc.)
- Celebrate achievements when they come up organically''';

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

    final responseData = await _postRaw(body);
    final choices = responseData['choices'] as List<dynamic>?;
    if (choices == null || choices.isEmpty) {
      throw const GroqException('Groq returned empty response.');
    }
    return (choices[0] as Map<String, dynamic>)['message']['content']
        as String;
  }

  /// Post a request body and return the parsed response JSON. Used by both
  /// the simple text path and the tool-use path below.
  Future<Map<String, dynamic>> _postRaw(Map<String, dynamic> body) async {
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
      final snippet = response.body.length > 300
          ? response.body.substring(0, 300)
          : response.body;
      debugPrint('[GroqClient] HTTP ${response.statusCode} body: ${response.body}');
      throw GroqException(
        'Groq API error: HTTP ${response.statusCode} — $snippet',
      );
    }
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  /// Tool-use chat turn. Accepts the full conversation (system + user +
  /// prior assistant + prior tool responses) and a `tools` schema array.
  ///
  /// Returns the raw assistant message — either:
  ///   - `{ content: "text...", tool_calls: null }`  → final text reply, OR
  ///   - `{ content: null, tool_calls: [...] }`      → model wants tools run.
  ///
  /// The orchestrator owns the loop: parse tool_calls, execute (or confirm
  /// with user first for write tools), append tool-response messages, call
  /// this again.
  Future<Map<String, dynamic>> chatCompletionWithTools({
    required List<Map<String, dynamic>> messages,
    required List<Map<String, dynamic>> tools,
    double temperature = 0.7,
    int maxTokens = 2048,
  }) async {
    final body = <String, dynamic>{
      'model': AppConstants.groqModel,
      'messages': messages,
      'tools': tools,
      'tool_choice': 'auto',
      'temperature': temperature,
      'max_tokens': maxTokens,
      'top_p': 0.95,
    };
    final data = await _postRaw(body);
    final choices = data['choices'] as List<dynamic>?;
    if (choices == null || choices.isEmpty) {
      throw const GroqException('Groq returned empty response.');
    }
    return (choices[0] as Map<String, dynamic>)['message']
        as Map<String, dynamic>;
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

Also identify: the meal name, main ingredients, and realistic price ranges where this meal can be found in ${_locationString(userContext)} (use local currency).

Return JSON:
{
  "meal_name": "string (common name of the dish)",
  "items": [{"name": "string", "quantity_g": number, "calories": number, "protein_g": number, "carbs_g": number, "fat_g": number}],
  "totals": {"calories": number, "protein_g": number, "carbs_g": number, "fat_g": number, "fiber_g": number},
  "health_score": number (1-10),
  "feedback": "string (1 sentence)",
  "ingredients": ["string"],
  "availability": [
    {"area": "string (e.g. Street stall / Local restaurant)", "min_price": number, "max_price": number}
  ],
  "best_price": number,
  "currency": "string (ISO currency code for user's country)"
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
For each meal include ingredients and realistic price ranges in ${_locationString(userContext)} (use local currency).

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
          "ingredients": ["string"],
          "availability": [{"area": "string", "min_price": number, "max_price": number}],
          "best_price": number,
          "currency": "string (ISO currency code for user's country)",
          "items": [{"name": "string", "quantity_g": number, "calories": number, "protein_g": number, "carbs_g": number, "fat_g": number}],
          "totals": {"calories": number, "protein_g": number, "carbs_g": number, "fat_g": number}
        }
      ],
      "day_totals": {"calories": number, "protein_g": number, "carbs_g": number, "fat_g": number}
    }
  ],
  "grocery_list": ["string"]
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
  ///
  /// llama-3.3-70b-versatile is text-only. The orchestrator always strips
  /// imageBytes before calling this method; the parameters are kept so the
  /// call sites stay uniform but they are intentionally unused here.
  Future<Map<String, dynamic>> chat({
    required String message,
    required Map<String, dynamic> userContext,
    required List<Map<String, String>> history,
    Uint8List? imageBytes,   // always null from orchestrator — text-only model
    String? mimeType,        // always null from orchestrator
    String? groundingContext,
  }) async {
    final messages = <Map<String, dynamic>>[];

    // Add conversation history (last 10), skipping any with empty content
    // (empty content causes HTTP 400 on the OpenAI-compatible API)
    for (final h in history.reversed.take(10).toList().reversed) {
      final content = h['content'] ?? '';
      if (content.isEmpty) continue;
      messages.add({
        'role': h['role'] == 'user' ? 'user' : 'assistant',
        'content': content,
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
      ..writeln('Location: ${_locationString(ctx)}')
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

    // Text-only message — image bytes are always null here (stripped by orchestrator)
    final prompt = '$contextBlock\n\nUser message: $message\n\nRespond as their personal AI coach. Be specific, actionable, and reference their data above.';
    messages.add({'role': 'user', 'content': prompt});

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

  /// Returns a human-readable location string from the context map.
  /// e.g. "Islamabad, Pakistan" or "Pakistan" or "not specified".
  String _locationString(Map<String, dynamic> ctx) {
    final city = ctx['city'] as String?;
    final country = ctx['country'] as String?;
    if (city != null && city.isNotEmpty && country != null && country.isNotEmpty) {
      return '$city, $country';
    }
    if (country != null && country.isNotEmpty) return country;
    return 'not specified';
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

