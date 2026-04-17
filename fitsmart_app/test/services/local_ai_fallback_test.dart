import 'package:flutter_test/flutter_test.dart';
import 'package:fitsmart_app/services/local_ai_fallback_service.dart';

void main() {
  final svc = LocalAiFallbackService.instance;

  // ── Helper: minimal user context ──────────────────────────────────
  Map<String, dynamic> ctx({
    double targetCalories = 2000,
    double targetProtein = 150,
    double targetCarbs = 200,
    double targetFat = 65,
    double consumedCalories = 0,
    double consumedProtein = 0,
    double consumedCarbs = 0,
    double consumedFat = 0,
    double weightKg = 75,
    double targetWeightKg = 70,
    String goal = 'lose_fat',
    int streak = 0,
    int mealsToday = 1,
  }) =>
      {
        'target_calories': targetCalories,
        'target_protein_g': targetProtein,
        'target_carbs_g': targetCarbs,
        'target_fat_g': targetFat,
        'consumed_calories_today': consumedCalories,
        'consumed_protein_today': consumedProtein,
        'consumed_carbs_today': consumedCarbs,
        'consumed_fat_today': consumedFat,
        'weight_kg': weightKg,
        'target_weight_kg': targetWeightKg,
        'goal': goal,
        'current_streak': streak,
        'meals_today': mealsToday,
      };

  // ══════════════════════════════════════════════════════════════════
  //  getMealFeedback
  // ══════════════════════════════════════════════════════════════════

  group('LocalAiFallbackService.getMealFeedback', () {
    test('flag=over_calories when consumed + meal exceeds target', () {
      // target=2000, consumed=1800, meal=400 → remaining=-200 (< 0)
      final result = svc.getMealFeedback(
        mealData: {'calories': 400, 'protein_g': 20},
        userContext: ctx(targetCalories: 2000, consumedCalories: 1800),
      );
      expect(result['flag'], 'over_calories');
    });

    test('over_calories message mentions the overage amount', () {
      final result = svc.getMealFeedback(
        mealData: {'calories': 400, 'protein_g': 20},
        userContext: ctx(targetCalories: 2000, consumedCalories: 1800),
      );
      expect((result['message'] as String).toLowerCase(), contains('200'));
    });

    test('flag=low_protein when remaining protein > 40% of target', () {
      // targetProtein=150, consumed=20, meal=10 → remaining=120 > 60 (40%)
      // remainingCal=1200 → not over
      final result = svc.getMealFeedback(
        mealData: {'calories': 300, 'protein_g': 10},
        userContext: ctx(
          targetCalories: 2000,
          consumedCalories: 500,
          targetProtein: 150,
          consumedProtein: 20,
        ),
      );
      expect(result['flag'], 'low_protein');
    });

    test('flag=great_balance when >= 80% protein target hit and calories ok', () {
      // consumed+meal protein = 100+25 = 125 >= 150*0.8 = 120, remainingCal >= 0
      final result = svc.getMealFeedback(
        mealData: {'calories': 300, 'protein_g': 25},
        userContext: ctx(
          targetCalories: 2000,
          consumedCalories: 500,
          targetProtein: 150,
          consumedProtein: 100,
        ),
      );
      expect(result['flag'], 'great_balance');
    });

    test('flag=ok for balanced default case', () {
      // remainingCal = 2000-500-400 = 1100 (not over)
      // consumed+meal protein = 80+20 = 100 < 120 (not great_balance)
      // remainingProtein = 150-80-20 = 50 < 60 (not low_protein)
      final result = svc.getMealFeedback(
        mealData: {'calories': 400, 'protein_g': 20},
        userContext: ctx(
          targetCalories: 2000,
          consumedCalories: 500,
          targetProtein: 150,
          consumedProtein: 80,
        ),
      );
      expect(result['flag'], 'ok');
    });

    test('remaining_calories correctly calculated', () {
      // 2000 - 800 - 400 = 800
      final result = svc.getMealFeedback(
        mealData: {'calories': 400, 'protein_g': 20},
        userContext: ctx(targetCalories: 2000, consumedCalories: 800),
      );
      expect(result['remaining_calories'], 800);
    });

    test('remaining_protein_g correctly calculated', () {
      // 150 - 60 - 30 = 60
      final result = svc.getMealFeedback(
        mealData: {'calories': 400, 'protein_g': 30},
        userContext: ctx(targetProtein: 150, consumedProtein: 60),
      );
      expect(result['remaining_protein_g'], 60);
    });

    test('returns all required keys', () {
      final result = svc.getMealFeedback(
        mealData: {'calories': 400, 'protein_g': 30},
        userContext: ctx(),
      );
      expect(result.containsKey('message'), isTrue);
      expect(result.containsKey('remaining_calories'), isTrue);
      expect(result.containsKey('remaining_protein_g'), isTrue);
      expect(result.containsKey('next_meal_suggestion'), isTrue);
      expect(result.containsKey('flag'), isTrue);
    });

    test('handles missing mealData fields gracefully (defaults to 0)', () {
      expect(
        () => svc.getMealFeedback(mealData: {}, userContext: ctx()),
        returnsNormally,
      );
    });
  });

  // ══════════════════════════════════════════════════════════════════
  //  analyzeMealPhoto
  // ══════════════════════════════════════════════════════════════════

  group('LocalAiFallbackService.analyzeMealPhoto', () {
    test('returns all required JSON keys', () {
      final result = svc.analyzeMealPhoto(userContext: ctx());
      expect(result.containsKey('items'), isTrue);
      expect(result.containsKey('totals'), isTrue);
      expect(result.containsKey('health_score'), isTrue);
      expect(result.containsKey('feedback'), isTrue);
      expect(result.containsKey('identified_items_summary'), isTrue);
    });

    test('confidence is 0.3 (low — no real vision)', () {
      final items = svc.analyzeMealPhoto(userContext: ctx())['items'] as List;
      expect(items.isNotEmpty, isTrue);
      expect((items[0] as Map)['confidence'], 0.3);
    });

    test('health_score is 6 for the generic estimate', () {
      expect(svc.analyzeMealPhoto(userContext: ctx())['health_score'], 6);
    });

    test('totals contains fiber_g field', () {
      final totals =
          svc.analyzeMealPhoto(userContext: ctx())['totals'] as Map;
      expect(totals.containsKey('fiber_g'), isTrue);
    });
  });

  // ══════════════════════════════════════════════════════════════════
  //  analyzeMealText (KB not loaded → generic fallback path)
  // ══════════════════════════════════════════════════════════════════

  group('LocalAiFallbackService.analyzeMealText', () {
    test('returns all required JSON keys for unknown food', () {
      final result = svc.analyzeMealText(
        description: 'xyzzy999_not_in_database',
        userContext: ctx(),
      );
      expect(result.containsKey('items'), isTrue);
      expect(result.containsKey('totals'), isTrue);
      expect(result.containsKey('health_score'), isTrue);
      expect(result.containsKey('feedback'), isTrue);
    });

    test('items list is non-empty even for unknown food', () {
      final items = svc.analyzeMealText(
        description: 'completelyunknownfooditem99',
        userContext: ctx(),
      )['items'] as List;
      expect(items.isNotEmpty, isTrue);
    });

    test('totals contains calories, protein_g, carbs_g, fat_g', () {
      final totals = svc.analyzeMealText(
        description: 'unknown meal xyz',
        userContext: ctx(),
      )['totals'] as Map;
      for (final key in ['calories', 'protein_g', 'carbs_g', 'fat_g']) {
        expect(totals.containsKey(key), isTrue, reason: 'missing key: $key');
      }
    });

    test('health_score is an integer 1-10', () {
      final score = svc.analyzeMealText(
        description: 'test food',
        userContext: ctx(),
      )['health_score'];
      expect(score, isA<int>());
      expect(score, greaterThanOrEqualTo(1));
      expect(score, lessThanOrEqualTo(10));
    });
  });

  // ══════════════════════════════════════════════════════════════════
  //  chat — intent matching
  // ══════════════════════════════════════════════════════════════════

  group('LocalAiFallbackService.chat — intent matching', () {
    test('returns response and suggestions keys', () {
      final result = svc.chat(message: 'hello', userContext: ctx());
      expect(result.containsKey('response'), isTrue);
      expect(result.containsKey('suggestions'), isTrue);
    });

    test('calorie keyword → calorie-specific response', () {
      final response = svc.chat(
        message: 'how many calories remaining today?',
        userContext: ctx(targetCalories: 2000, consumedCalories: 800),
      )['response'] as String;
      expect(response.toLowerCase(), contains('calorie'));
    });

    test('protein keyword → protein-specific response', () {
      final response = svc.chat(
        message: 'is my protein intake enough?',
        userContext: ctx(),
      )['response'] as String;
      expect(response.toLowerCase(), contains('protein'));
    });

    test('workout keyword → workout tips response', () {
      final response = svc.chat(
        message: 'what workout should I do at the gym today?',
        userContext: ctx(),
      )['response'] as String;
      expect(response.toLowerCase(), contains('workout'));
    });

    test('macro keyword → macro breakdown table', () {
      final response = svc.chat(
        message: 'show me my macro breakdown',
        userContext: ctx(),
      )['response'] as String;
      expect(response.toLowerCase(), contains('macro'));
    });

    test('sleep keyword → sleep and recovery advice', () {
      final response = svc.chat(
        message: 'tips for better sleep and recovery',
        userContext: ctx(),
      )['response'] as String;
      expect(response.toLowerCase(), contains('sleep'));
    });

    test('water keyword → hydration advice', () {
      final response = svc.chat(
        message: 'how much water should I drink?',
        userContext: ctx(),
      )['response'] as String;
      expect(response.toLowerCase(),
          anyOf(contains('water'), contains('hydrat')));
    });

    test('greeting (hello) → non-empty welcome response', () {
      final response = svc.chat(
        message: 'hello',
        userContext: ctx(targetCalories: 2000),
      )['response'] as String;
      expect(response.isNotEmpty, isTrue);
    });

    test('greeting (hey) → non-empty welcome response', () {
      final response = svc.chat(
        message: 'hey there!',
        userContext: ctx(),
      )['response'] as String;
      expect(response.isNotEmpty, isTrue);
    });

    test('weight/progress keyword → progress response', () {
      final response = svc.chat(
        message: 'how is my weight progress?',
        userContext: ctx(weightKg: 80, targetWeightKg: 72),
      )['response'] as String;
      expect(response.isNotEmpty, isTrue);
    });

    test('gamification keyword → stats response', () {
      final response = svc.chat(
        message: 'show my streak and xp',
        userContext: ctx(streak: 7),
      )['response'] as String;
      expect(response.isNotEmpty, isTrue);
    });

    test('unrecognized message → generic response mentioning remaining data', () {
      final response = svc.chat(
        message: 'qwerty_completely_unknown_request_99xyz',
        userContext: ctx(targetCalories: 2000, consumedCalories: 500),
      )['response'] as String;
      expect(response.isNotEmpty, isTrue);
    });

    test('streak shown in greeting when > 0', () {
      final response = svc.chat(
        message: 'hi',
        userContext: ctx(streak: 5),
      )['response'] as String;
      expect(response, contains('5'));
    });
  });

  // ══════════════════════════════════════════════════════════════════
  //  getDailyInsight
  // ══════════════════════════════════════════════════════════════════

  group('LocalAiFallbackService.getDailyInsight', () {
    test('returns required keys: insight, icon, category', () {
      final result = svc.getDailyInsight(userContext: ctx());
      expect(result.containsKey('insight'), isTrue);
      expect(result.containsKey('icon'), isTrue);
      expect(result.containsKey('category'), isTrue);
    });

    test('insight is a non-empty string', () {
      final insight = svc.getDailyInsight(userContext: ctx())['insight'];
      expect(insight, isA<String>());
      expect((insight as String).isNotEmpty, isTrue);
    });

    test('icon is a non-empty string', () {
      final icon = svc.getDailyInsight(userContext: ctx())['icon'];
      expect(icon, isA<String>());
      expect((icon as String).isNotEmpty, isTrue);
    });

    test('category is one of the valid values', () {
      const valid = ['nutrition', 'workout', 'progress', 'motivation'];
      final cat = svc.getDailyInsight(userContext: ctx())['category'];
      expect(valid.contains(cat), isTrue,
          reason: 'Unexpected category: $cat');
    });

    test('no meals today → returns a motivation/start-day insight', () {
      final result = svc.getDailyInsight(
        userContext: {'meals_today': 0, 'target_calories': 2000},
      );
      expect((result['insight'] as String).isNotEmpty, isTrue);
    });
  });

  // ══════════════════════════════════════════════════════════════════
  //  generateWorkoutPlan
  // ══════════════════════════════════════════════════════════════════

  group('LocalAiFallbackService.generateWorkoutPlan', () {
    test('returns program_name and weeks keys', () {
      final result =
          svc.generateWorkoutPlan(userContext: ctx(), weeks: 4);
      expect(result.containsKey('program_name'), isTrue);
      expect(result.containsKey('weeks'), isTrue);
    });

    test('weeks list has the requested count', () {
      final weeks =
          svc.generateWorkoutPlan(userContext: ctx(), weeks: 3)['weeks']
              as List;
      expect(weeks.length, 3);
    });

    test('lose_fat goal → program name contains "Fat"', () {
      final result = svc.generateWorkoutPlan(
        userContext: {'goal': 'lose_fat', 'workout_days': 3},
        weeks: 1,
      );
      expect((result['program_name'] as String).toLowerCase(), contains('fat'));
    });

    test('gain_muscle goal → program name contains "Muscle"', () {
      final result = svc.generateWorkoutPlan(
        userContext: {'goal': 'gain_muscle', 'workout_days': 4},
        weeks: 1,
      );
      expect(
          (result['program_name'] as String).toLowerCase(), contains('muscle'));
    });

    test('athletic goal → "Athletic Performance"', () {
      final result = svc.generateWorkoutPlan(
        userContext: {'goal': 'athletic', 'workout_days': 4},
        weeks: 1,
      );
      expect((result['program_name'] as String).toLowerCase(),
          contains('athletic'));
    });

    test('each week has week number and non-empty days list', () {
      final result =
          svc.generateWorkoutPlan(userContext: ctx(), weeks: 2);
      for (final w in result['weeks'] as List) {
        final week = w as Map;
        expect(week.containsKey('week'), isTrue);
        expect((week['days'] as List).isNotEmpty, isTrue);
      }
    });

    test('each exercise has name, sets, reps, rest_sec', () {
      final result =
          svc.generateWorkoutPlan(userContext: ctx(), weeks: 1);
      final days =
          ((result['weeks'] as List)[0] as Map)['days'] as List;
      final ex = ((days[0] as Map)['exercises'] as List)[0] as Map;
      for (final key in ['name', 'sets', 'reps', 'rest_sec']) {
        expect(ex.containsKey(key), isTrue, reason: 'missing key: $key');
      }
    });

    test('progressive overload: sets increase after week 2', () {
      final result =
          svc.generateWorkoutPlan(userContext: ctx(), weeks: 3);
      final weeks = result['weeks'] as List;

      final setsW1 = (((weeks[0] as Map)['days'] as List)[0]
          as Map)['exercises'] as List;
      final setsW3 = (((weeks[2] as Map)['days'] as List)[0]
          as Map)['exercises'] as List;

      final s1 = (setsW1[0] as Map)['sets'] as int;
      final s3 = (setsW3[0] as Map)['sets'] as int;
      expect(s3, greaterThan(s1));
    });
  });

  // ══════════════════════════════════════════════════════════════════
  //  generateMealPlan
  // ══════════════════════════════════════════════════════════════════

  group('LocalAiFallbackService.generateMealPlan', () {
    test('returns days and grocery_list keys', () {
      final result = svc.generateMealPlan(userContext: ctx(), days: 3);
      expect(result.containsKey('days'), isTrue);
      expect(result.containsKey('grocery_list'), isTrue);
    });

    test('days list has the requested count', () {
      final days =
          svc.generateMealPlan(userContext: ctx(), days: 5)['days'] as List;
      expect(days.length, 5);
    });

    test('each day has day number, meals list, and total_calories', () {
      final day = (svc.generateMealPlan(userContext: ctx(), days: 1)['days']
              as List)[0] as Map;
      expect(day.containsKey('day'), isTrue);
      expect(day.containsKey('meals'), isTrue);
      expect(day.containsKey('total_calories'), isTrue);
      expect((day['meals'] as List).isNotEmpty, isTrue);
    });

    test('each meal has type, name, calories, protein_g', () {
      final day = (svc.generateMealPlan(userContext: ctx(), days: 1)['days']
              as List)[0] as Map;
      final meal = (day['meals'] as List)[0] as Map;
      for (final key in ['type', 'name', 'calories', 'protein_g']) {
        expect(meal.containsKey(key), isTrue, reason: 'missing key: $key');
      }
    });

    test('grocery_list is a non-empty list', () {
      final groceries =
          svc.generateMealPlan(userContext: ctx(), days: 1)['grocery_list']
              as List;
      expect(groceries.isNotEmpty, isTrue);
    });

    test('does not crash for 1-day plan', () {
      expect(
        () => svc.generateMealPlan(userContext: ctx(), days: 1),
        returnsNormally,
      );
    });

    test('does not crash for 7-day plan', () {
      expect(
        () => svc.generateMealPlan(userContext: ctx(), days: 7),
        returnsNormally,
      );
    });
  });
}
