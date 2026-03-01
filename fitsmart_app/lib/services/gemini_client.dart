import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../core/constants/app_constants.dart';

class GeminiException implements Exception {
  final String message;
  final bool isRateLimited;
  const GeminiException(this.message, {this.isRateLimited = false});
  @override
  String toString() => 'GeminiException: $message';
}

enum GeminiPriority { high, normal, low }

class _CacheEntry {
  final String response;
  final DateTime createdAt;
  final int ttlHours; // 0 = indefinite

  _CacheEntry({
    required this.response,
    required this.createdAt,
    required this.ttlHours,
  });

  bool get isExpired {
    if (ttlHours == 0) return false;
    return DateTime.now().difference(createdAt).inHours >= ttlHours;
  }
}

class GeminiClient {
  static GeminiClient? _instance;
  factory GeminiClient({required String apiKey}) {
    _instance ??= GeminiClient._internal(apiKey: apiKey);
    return _instance!;
  }

  late final GenerativeModel _model;
  late final GenerativeModel _chatModel;
  final Map<String, _CacheEntry> _cache = {};

  GeminiClient._internal({required String apiKey}) {
    // Structured JSON model — for meal analysis, workout plans, etc.
    _model = GenerativeModel(
      model: AppConstants.geminiModel,
      apiKey: apiKey,
      generationConfig: GenerationConfig(
        responseMimeType: 'application/json',
        temperature: 0.7,
        topK: 40,
        topP: 0.95,
      ),
      systemInstruction: Content.text(_systemInstruction),
    );

    // Freeform chat model — for coach conversations (no JSON constraint)
    _chatModel = GenerativeModel(
      model: AppConstants.geminiModel,
      apiKey: apiKey,
      generationConfig: GenerationConfig(
        temperature: 0.8,
        topK: 40,
        topP: 0.95,
      ),
      systemInstruction: Content.text(_chatSystemInstruction),
    );
  }

  static const _systemInstruction = '''
You are FitSmart AI, a fitness and nutrition coach assistant.
Always respond with valid JSON matching the requested schema.
Be precise with nutritional data. Use evidence-based recommendations.
Be encouraging, practical, and personalized. Keep responses concise.
Never include markdown, prose wrappers, or explanations outside the JSON structure.
''';

  static const _chatSystemInstruction = '''
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

DATA YOU HAVE ACCESS TO:
- Full bio: age, gender, height, weight, body fat %, location
- Goals: primary goal, target weight, target body type, weight change pace
- Activity: activity level, workout days/week, sleep schedule
- Nutrition: calorie/protein/carbs/fat targets and today's consumed amounts
- Food preferences: dietary restrictions, cuisine preferences, disliked ingredients, budget
- Today's meals: every meal logged with full macros and health scores
- Workout history: recent workouts with duration, calories, and dates
- Personal records: max weight lifted for each exercise
- Body measurements: chest, waist, hips, bicep, thigh, neck, shoulders, calf
- Weight history: recent weight log entries with trend analysis
- Weekly summary: last 7 days of calorie/protein intake and workout counts
- Gamification: level, XP, streak, longest streak, streak freezes, unlocked badges
- Active plans: current workout plan and meal plan if any
- All-time stats: total meals logged, total workouts logged

WHEN ASKED FOR A MEAL PLAN:
- Always provide specific meals with exact foods, portions, calories, and macros
- Format each meal clearly (e.g. "**Breakfast (450 kcal)**")
- List ingredients with gram amounts
- Include a daily total summary
- Tailor to their calorie/protein targets, dietary restrictions, cuisine preferences, disliked ingredients, and budget
- Consider what they've already eaten today

WHEN ASKED FOR A WORKOUT PLAN:
- Provide specific exercises, sets, reps, and rest periods
- Organize by day
- Match their fitness level, goals, and available workout days
- Reference their PRs when suggesting weights
- Consider their recent workout history to avoid overtraining

WHEN ANALYZING PROGRESS:
- Compare current weight to starting and target weight
- Reference body measurement trends
- Highlight PR improvements
- Track streak and consistency
- Give specific actionable adjustments based on data trends

ALWAYS:
- Reference the user's actual data (calories, protein, weight, measurements, PRs, streak) when relevant
- Give specific numbers, not vague advice
- If they've logged meals today, reference what they've eaten and remaining macros
- Consider their sleep schedule when recommending meal/workout timing
- Factor in their budget for meal suggestions
- Celebrate their achievements (PRs, streaks, badges, level ups)
''';


  // ── Public API ─────────────────────────────────────────────────────

  Future<Map<String, dynamic>> analyzeMealPhoto({
    required Uint8List imageBytes,
    required Map<String, dynamic> userContext,
    String? mimeType,
  }) async {
    final imageHash = _hashBytes(imageBytes);
    final cacheKey = 'meal_photo_$imageHash';

    return _request(
      cacheKey: cacheKey,
      ttlHours: 0, // indefinite cache for same photo
      priority: GeminiPriority.high,
      buildContent: () => [
        Content.multi([
          TextPart(_buildMealAnalysisPrompt(userContext)),
          DataPart(mimeType ?? 'image/jpeg', imageBytes),
        ]),
      ],
    );
  }

  Future<Map<String, dynamic>> analyzeMealText({
    required String description,
    required Map<String, dynamic> userContext,
  }) async {
    final cacheKey = 'meal_text_${description.hashCode}';

    return _request(
      cacheKey: cacheKey,
      ttlHours: 24,
      priority: GeminiPriority.high,
      buildContent: () => [
        Content.text('''
${_buildUserContextString(userContext)}

Parse this meal description and return nutritional data:
"$description"

Return JSON:
{
  "items": [
    {
      "name": "string",
      "quantity_g": number,
      "calories": number,
      "protein_g": number,
      "carbs_g": number,
      "fat_g": number
    }
  ],
  "totals": { "calories": number, "protein_g": number, "carbs_g": number, "fat_g": number },
  "health_score": number (1-10),
  "feedback": "string (1 sentence)"
}'''),
      ],
    );
  }

  Future<Map<String, dynamic>> getMealFeedback({
    required Map<String, dynamic> mealData,
    required Map<String, dynamic> userContext,
  }) async {
    final cacheKey = 'meal_feedback_${jsonEncode(mealData).hashCode}';

    return _request(
      cacheKey: cacheKey,
      ttlHours: 4,
      priority: GeminiPriority.normal,
      buildContent: () => [
        Content.text('''
${_buildUserContextString(userContext)}

Meal just logged: ${jsonEncode(mealData)}

Provide brief, personalized feedback considering their daily targets and what's remaining.
Return JSON:
{
  "message": "string (2-3 sentences, encouraging)",
  "remaining_calories": number,
  "remaining_protein_g": number,
  "next_meal_suggestion": "string",
  "flag": "ok" | "low_protein" | "over_calories" | "great_balance"
}'''),
      ],
    );
  }

  Future<Map<String, dynamic>> generateMealPlan({
    required Map<String, dynamic> userContext,
    required int days,
    String? overrides,
  }) async {
    final cacheKey = 'meal_plan_${userContext.hashCode}_${days}_${overrides?.hashCode}';

    return _request(
      cacheKey: cacheKey,
      ttlHours: AppConstants.cacheTtlMealPlan,
      priority: GeminiPriority.normal,
      buildContent: () => [
        Content.text('''
${_buildUserContextString(userContext)}
${overrides != null ? 'Special instructions: $overrides' : ''}

Generate a $days-day meal plan. Return JSON:
{
  "days": [
    {
      "day": 1,
      "meals": [
        {
          "type": "breakfast"|"lunch"|"dinner"|"snack",
          "name": "string",
          "calories": number,
          "protein_g": number,
          "carbs_g": number,
          "fat_g": number,
          "prep_min": number,
          "ingredients": ["string"],
          "instructions": "string (brief)"
        }
      ],
      "total_calories": number
    }
  ],
  "grocery_list": ["string"]
}'''),
      ],
    );
  }

  Future<Map<String, dynamic>> generateWorkoutPlan({
    required Map<String, dynamic> userContext,
    required int weeks,
  }) async {
    final cacheKey = 'workout_plan_${userContext.hashCode}_$weeks';

    return _request(
      cacheKey: cacheKey,
      ttlHours: AppConstants.cacheTtlWorkoutPlan,
      priority: GeminiPriority.normal,
      buildContent: () => [
        Content.text('''
${_buildUserContextString(userContext)}

Generate a $weeks-week workout program.
Goal: ${userContext['goal']}, Days/week: ${userContext['workout_days']}, Equipment: ${userContext['equipment']}

Return JSON:
{
  "program_name": "string",
  "weeks": [
    {
      "week": 1,
      "days": [
        {
          "day_name": "string",
          "focus": "string",
          "exercises": [
            {
              "name": "string",
              "sets": number,
              "reps": "string",
              "rest_sec": number,
              "notes": "string"
            }
          ]
        }
      ]
    }
  ]
}'''),
      ],
    );
  }

  Future<Map<String, dynamic>> chat({
    required String message,
    required Map<String, dynamic> userContext,
    required List<Map<String, String>> history,
    Uint8List? imageBytes,
    String? mimeType,
  }) async {
    try {
      final contents = <Content>[];

      // Add history (last 10 messages for richer context)
      for (final h in history.reversed.take(10).toList().reversed) {
        contents.add(
          h['role'] == 'user'
              ? Content.text(h['content']!)
              : Content.model([TextPart(h['content']!)]),
        );
      }

      // Build rich context string
      final ctx = userContext;
      final contextBlock = StringBuffer()
        ..writeln('=== COMPLETE USER PROFILE ===')
        ..writeln('Goal: ${ctx['goal']}')
        ..writeln('Gender: ${ctx['gender'] ?? 'not set'}')
        ..writeln('Age: ${ctx['age'] ?? 'not set'}')
        ..writeln('Height: ${ctx['height_cm'] ?? '?'}cm')
        ..writeln('Current weight: ${ctx['weight_kg'] ?? '?'}kg → Target: ${ctx['target_weight_kg'] ?? '?'}kg')
        ..writeln('Body fat: ${ctx['body_fat_pct'] != null ? '${ctx['body_fat_pct']}%' : 'not measured'}')
        ..writeln('Target body type: ${ctx['target_body_type'] ?? 'not set'}')
        ..writeln('Weight change pace: ${ctx['weight_change_pace'] ?? 'steady'}')
        ..writeln('Activity level: ${ctx['activity_level'] ?? 'moderate'}')
        ..writeln('Workout days/week: ${ctx['workout_days_per_week'] ?? '?'}')
        ..writeln('Location: ${ctx['city'] ?? ''} ${ctx['country'] ?? ''}')
        ..writeln('Dietary restrictions: ${ctx['dietary_restrictions'] ?? 'none'}')
        ..writeln('Cuisine preferences: ${ctx['cuisine_preferences'] ?? 'any'}')
        ..writeln('Disliked ingredients: ${ctx['disliked_ingredients'] ?? 'none'}')
        ..writeln('Monthly budget: ${ctx['monthly_budget_usd'] != null ? '\$${ctx['monthly_budget_usd']}' : 'not set'}')
        ..writeln('Sleep: ${ctx['sleep_schedule'].toString().isNotEmpty ? ctx['sleep_schedule'] : 'not set'}')
        ..writeln('')
        ..writeln('=== TODAY\'S NUTRITION TARGETS ===')
        ..writeln('Calories: ${ctx['target_calories']} kcal')
        ..writeln('Protein: ${ctx['target_protein_g']}g | Carbs: ${ctx['target_carbs_g']}g | Fat: ${ctx['target_fat_g']}g')
        ..writeln('')
        ..writeln('=== TODAY\'S PROGRESS ===')
        ..writeln('Consumed: ${ctx['consumed_calories_today']} kcal (${ctx['consumed_protein_today']}g P / ${ctx['consumed_carbs_today']}g C / ${ctx['consumed_fat_today']}g F)')
        ..writeln('Remaining: ${(ctx['target_calories'] ?? 0) - (ctx['consumed_calories_today'] ?? 0)} kcal | ${(ctx['target_protein_g'] ?? 0) - (ctx['consumed_protein_today'] ?? 0)}g P | ${(ctx['target_carbs_g'] ?? 0) - (ctx['consumed_carbs_today'] ?? 0)}g C | ${(ctx['target_fat_g'] ?? 0) - (ctx['consumed_fat_today'] ?? 0)}g F')
        ..writeln('Water today: ${ctx['water_ml_today']}ml')
        ..writeln('')
        ..writeln('=== GAMIFICATION ===')
        ..writeln('Level: ${ctx['level']} (${ctx['level_name']})')
        ..writeln('Total XP: ${ctx['total_xp']} | XP to next level: ${ctx['xp_to_next_level']}')
        ..writeln('Current streak: ${ctx['current_streak']} days | Longest streak: ${ctx['longest_streak']} days')
        ..writeln('Streak freezes: ${ctx['streak_freezes_available']}')
        ..writeln('Badges: ${ctx['unlocked_badges'] ?? 'none yet'}')
        ..writeln('')
        ..writeln('=== ALL-TIME STATS ===')
        ..writeln('Total meals logged: ${ctx['total_meals_logged']}')
        ..writeln('Total workouts logged: ${ctx['total_workouts_logged']}');

      if (ctx['todays_meals'] != null) {
        contextBlock.writeln('');
        contextBlock.writeln('=== MEALS LOGGED TODAY ===');
        contextBlock.writeln(ctx['todays_meals']);
      }

      if (ctx['recent_workouts'] != null) {
        contextBlock.writeln('');
        contextBlock.writeln('=== RECENT WORKOUTS (last 10) ===');
        contextBlock.writeln(ctx['recent_workouts']);
      }

      if (ctx['personal_records'] != null) {
        contextBlock.writeln('');
        contextBlock.writeln('=== PERSONAL RECORDS (max weight per exercise) ===');
        contextBlock.writeln(ctx['personal_records']);
      }

      if (ctx['body_measurements'] != null) {
        contextBlock.writeln('');
        contextBlock.writeln('=== LATEST BODY MEASUREMENTS ===');
        contextBlock.writeln(ctx['body_measurements']);
      }

      if (ctx['weight_history'] != null) {
        contextBlock.writeln('');
        contextBlock.writeln('=== WEIGHT HISTORY ===');
        contextBlock.writeln(ctx['weight_history']);
      }

      if (ctx['weekly_summary'] != null) {
        contextBlock.writeln('');
        contextBlock.writeln('=== LAST 7 DAYS SUMMARY ===');
        contextBlock.writeln(ctx['weekly_summary']);
      }

      if (ctx['active_workout_plan'] != null) {
        contextBlock.writeln('');
        contextBlock.writeln('=== ACTIVE WORKOUT PLAN ===');
        contextBlock.writeln(ctx['active_workout_plan']);
      }

      if (ctx['active_meal_plan'] != null) {
        contextBlock.writeln('');
        contextBlock.writeln('=== ACTIVE MEAL PLAN ===');
        contextBlock.writeln(ctx['active_meal_plan']);
      }

      // Build the user message with context
      final prompt = '''
$contextBlock

User message: $message

Respond as their personal AI coach. Be specific, actionable, and reference their data above.''';

      if (imageBytes != null) {
        contents.add(Content.multi([
          TextPart(prompt),
          DataPart(mimeType ?? 'image/jpeg', imageBytes),
        ]));
      } else {
        contents.add(Content.text(prompt));
      }

      final response = await _chatModel.generateContent(contents);
      final text = response.text ?? 'I couldn\'t generate a response. Please try again.';

      return {
        'response': text,
        'suggestions': <String>[],
      };
    } catch (e) {
      if (e is GeminiException) rethrow;
      throw _friendlyException(e);
    }
  }

  Future<Map<String, dynamic>> getDailyInsight({
    required Map<String, dynamic> userContext,
  }) async {
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final cacheKey = 'insight_$today';

    return _request(
      cacheKey: cacheKey,
      ttlHours: AppConstants.cacheTtlDailyInsight,
      priority: GeminiPriority.low,
      buildContent: () => [
        Content.text('''
${_buildUserContextString(userContext)}

Generate today's motivational AI insight based on recent trends.
Return JSON:
{
  "insight": "string (2 sentences, specific to their data)",
  "icon": "string (emoji)",
  "category": "nutrition"|"workout"|"progress"|"motivation"
}'''),
      ],
    );
  }

  // ── Private Methods ─────────────────────────────────────────────────

  Future<Map<String, dynamic>> _request({
    required String? cacheKey,
    required int ttlHours,
    required GeminiPriority priority,
    required List<Content> Function() buildContent,
  }) async {
    // Check cache
    if (cacheKey != null) {
      final cached = _cache[cacheKey];
      if (cached != null && !cached.isExpired) {
        return jsonDecode(cached.response) as Map<String, dynamic>;
      }
    }

    try {
      final contents = buildContent();
      final response = await _model.generateContent(contents);
      final text = response.text ?? '{}';

      final parsed = jsonDecode(text) as Map<String, dynamic>;

      // Cache the response
      if (cacheKey != null) {
        _cache[cacheKey] = _CacheEntry(
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

  /// Converts raw API errors into user-friendly messages.
  static GeminiException _friendlyException(Object e) {
    final msg = e.toString().toLowerCase();
    if (msg.contains('quota') || msg.contains('rate') || msg.contains('429') || msg.contains('resource_exhausted')) {
      return const GeminiException(
        'AI is taking a breather ☕ Too many requests — wait a moment and try again.',
        isRateLimited: true,
      );
    }
    if (msg.contains('api_key') || msg.contains('permission') || msg.contains('403')) {
      return const GeminiException('API key issue — please check your Gemini API key.');
    }
    if (msg.contains('timeout') || msg.contains('deadline')) {
      return const GeminiException('Request timed out — check your internet and try again.');
    }
    if (msg.contains('network') || msg.contains('socket') || msg.contains('connection')) {
      return const GeminiException('No internet connection — please check your network.');
    }
    return GeminiException('Something went wrong. Please try again.');
  }

  String _buildUserContextString(Map<String, dynamic> ctx) {
    return 'USER_CONTEXT: ${jsonEncode(ctx)}';
  }

  String _buildMealAnalysisPrompt(Map<String, dynamic> userContext) {
    return '''
${_buildUserContextString(userContext)}

Analyze this meal photo. Identify all visible food items, estimate portions, and calculate macros.

Return JSON:
{
  "items": [
    {
      "name": "string",
      "quantity_g": number,
      "calories": number,
      "protein_g": number,
      "carbs_g": number,
      "fat_g": number,
      "confidence": number (0-1)
    }
  ],
  "totals": {
    "calories": number,
    "protein_g": number,
    "carbs_g": number,
    "fat_g": number,
    "fiber_g": number
  },
  "health_score": number (1-10),
  "feedback": "string (1-2 sentences, personalized)",
  "identified_items_summary": "string"
}''';
  }

  String _hashBytes(List<int> bytes) {
    final digest = sha256.convert(bytes);
    return digest.toString().substring(0, 16);
  }

  /// Clears all cached AI responses.
  void clearCache() => _cache.clear();
}
