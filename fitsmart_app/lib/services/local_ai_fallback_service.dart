import 'dart:math';
import 'food_knowledge_service.dart';

/// Fully offline AI fallback powered by the local RAG knowledge base.
///
/// Provides deterministic, rules-based responses for every AI feature:
///  - Meal text analysis (RAG lookup + USDA-style estimation)
///  - Meal photo analysis (cannot meaningfully run locally — returns safe estimate)
///  - Meal feedback (rules-based macro comparison)
///  - Meal plan generation (template + RAG foods)
///  - Workout plan generation (template-based)
///  - AI coach chat (pattern-matched FAQ + context-aware responses)
///  - Daily insight (template-based from user data)
///
/// All methods return the **exact same JSON shape** as GeminiClient so the
/// UI layer sees zero difference.
class LocalAiFallbackService {
  LocalAiFallbackService._();
  static final instance = LocalAiFallbackService._();

  FoodKnowledgeService get _kb => FoodKnowledgeService.instance;
  final _rng = Random();

  // ══════════════════════════════════════════════════════════════════
  //  MEAL TEXT ANALYSIS
  // ══════════════════════════════════════════════════════════════════

  /// Analyzes a text description by searching the RAG knowledge base.
  /// Falls back to a reasonable per-100g estimate when nothing matches.
  Map<String, dynamic> analyzeMealText({
    required String description,
    required Map<String, dynamic> userContext,
  }) {
    final tokens = description
        .toLowerCase()
        .split(RegExp(r'[\s,]+'))
        .where((t) => t.length > 2)
        .toList();

    final items = <Map<String, dynamic>>[];
    final matched = <String>{};

    // Strategy 1: search full description
    final fullResults = _kb.search(description, limit: 5);
    for (final r in fullResults) {
      if (r.score >= 0.5 && matched.add(r.food.name)) {
        items.add(_foodEntryToItem(r.food));
      }
    }

    // Strategy 2: search individual tokens
    if (items.isEmpty) {
      for (final token in tokens) {
        final results = _kb.search(token, limit: 3);
        for (final r in results) {
          if (r.score >= 0.6 && matched.add(r.food.name)) {
            items.add(_foodEntryToItem(r.food));
            break; // one match per token
          }
        }
      }
    }

    // Strategy 3: generic estimate when nothing matches
    if (items.isEmpty) {
      items.add({
        'name': _cleanName(description),
        'quantity_g': 200,
        'calories': 250,
        'protein_g': 10.0,
        'carbs_g': 30.0,
        'fat_g': 10.0,
      });
    }

    final totals = _computeTotals(items);
    final healthScore = _computeHealthScore(totals, userContext);

    final mealName = items.isNotEmpty
        ? (items.first['name'] as String? ?? 'Mixed Meal')
        : 'Mixed Meal';

    return {
      'meal_name': mealName,
      'items': items,
      'totals': totals,
      'health_score': healthScore,
      'feedback': _buildMealFeedbackLine(totals, userContext),
      'ingredients': _inferIngredients(mealName),
      'availability': _defaultAvailability(mealName),
      'best_price': _defaultBestPrice(mealName),
      'currency': 'PKR',
    };
  }

  // ══════════════════════════════════════════════════════════════════
  //  MEAL PHOTO ANALYSIS  (limited offline — uses generic estimate)
  // ══════════════════════════════════════════════════════════════════

  /// Photo analysis cannot run meaningfully on-device, so we return a
  /// reasonable generic estimate and mark confidence low.
  Map<String, dynamic> analyzeMealPhoto({
    required Map<String, dynamic> userContext,
  }) {
    final items = [
      {
        'name': 'Estimated meal',
        'quantity_g': 300,
        'calories': 350,
        'protein_g': 15.0,
        'carbs_g': 40.0,
        'fat_g': 14.0,
        'confidence': 0.3,
      }
    ];
    final totals = _computeTotals(items);
    return {
      'meal_name': 'Mixed Meal (estimated)',
      'items': items,
      'totals': {...totals, 'fiber_g': 4.0},
      'health_score': 6,
      'feedback':
          'Estimated from photo. You can edit the values for better accuracy.',
      'identified_items_summary': 'Mixed meal (estimated)',
      'ingredients': ['Various ingredients (estimated)'],
      'availability': [
        {'area': 'Street stall / Dhaba', 'min_price': 100, 'max_price': 300},
        {'area': 'Local restaurant', 'min_price': 300, 'max_price': 700},
      ],
      'best_price': 100,
      'currency': 'PKR',
    };
  }

  // ══════════════════════════════════════════════════════════════════
  //  MEAL FEEDBACK
  // ══════════════════════════════════════════════════════════════════

  Map<String, dynamic> getMealFeedback({
    required Map<String, dynamic> mealData,
    required Map<String, dynamic> userContext,
  }) {
    final mealCal = (mealData['calories'] as num?)?.toDouble() ?? 0;
    final mealProtein = (mealData['protein_g'] as num?)?.toDouble() ?? 0;
    final targetCal =
        (userContext['target_calories'] as num?)?.toDouble() ?? 2000;
    final targetProtein =
        (userContext['target_protein_g'] as num?)?.toDouble() ?? 120;
    final consumedCal =
        (userContext['consumed_calories_today'] as num?)?.toDouble() ?? 0;
    final consumedProtein =
        (userContext['consumed_protein_today'] as num?)?.toDouble() ?? 0;

    final remainingCal = targetCal - consumedCal - mealCal;
    final remainingProtein = targetProtein - consumedProtein - mealProtein;

    String flag = 'ok';
    String message;
    String suggestion;

    if (remainingCal < 0) {
      flag = 'over_calories';
      message =
          'You\'re ${remainingCal.abs().round()} kcal over your daily target. '
          'Consider a lighter next meal or a short walk to balance things out.';
      suggestion = 'A light salad or fruit bowl';
    } else if (remainingProtein > targetProtein * 0.4) {
      flag = 'low_protein';
      message =
          'Your protein is running low today — ${remainingProtein.round()}g still to go. '
          'Try adding a protein-rich snack before bed.';
      suggestion = 'Greek yogurt, eggs, or paneer tikka';
    } else if ((consumedProtein + mealProtein) >= targetProtein * 0.8 &&
        remainingCal >= 0) {
      flag = 'great_balance';
      message =
          'Great balance! You\'ve hit ${((consumedProtein + mealProtein) / targetProtein * 100).round()}% of your protein target '
          'with ${remainingCal.round()} kcal still available. Keep it up! 💪';
      suggestion = 'Stay the course — a balanced snack later will close it out';
    } else {
      message =
          'Meal logged! You have ${remainingCal.round()} kcal and ${remainingProtein.round()}g protein remaining today.';
      suggestion = 'A balanced meal with protein and veggies';
    }

    return {
      'message': message,
      'remaining_calories': remainingCal.round(),
      'remaining_protein_g': remainingProtein.round(),
      'next_meal_suggestion': suggestion,
      'flag': flag,
    };
  }

  // ══════════════════════════════════════════════════════════════════
  //  MEAL PLAN
  // ══════════════════════════════════════════════════════════════════

  Map<String, dynamic> generateMealPlan({
    required Map<String, dynamic> userContext,
    required int days,
  }) {
    final targetCal =
        (userContext['target_calories'] as num?)?.toDouble() ?? 2000;

    // Gather foods from RAG by category
    final breakfasts = _foodsByCategory(['breakfast', 'snack']);
    final mains = _foodsByCategory(['main course', 'curry', 'rice', 'bread']);
    final snacks = _foodsByCategory(['snack', 'dessert', 'sweet', 'street food']);

    if (breakfasts.isEmpty) breakfasts.addAll(_kb.allFoods.take(5));
    if (mains.isEmpty) mains.addAll(_kb.allFoods.skip(5).take(10));
    if (snacks.isEmpty) snacks.addAll(_kb.allFoods.skip(15).take(5));

    // Knowledge base unavailable (first run / test env) — return a simple template.
    if (breakfasts.isEmpty || mains.isEmpty || snacks.isEmpty) {
      return _buildDefaultMealPlan(days, targetCal);
    }

    final daysList = <Map<String, dynamic>>[];
    final grocerySet = <String>{};

    for (var d = 1; d <= days; d++) {
      final bf = breakfasts[_rng.nextInt(breakfasts.length)];
      final lunch = mains[_rng.nextInt(mains.length)];
      final dinner = mains[_rng.nextInt(mains.length)];
      final snack = snacks[_rng.nextInt(snacks.length)];

      final meals = [
        _planMeal('breakfast', bf, targetCal * 0.25),
        _planMeal('lunch', lunch, targetCal * 0.35),
        _planMeal('dinner', dinner, targetCal * 0.30),
        _planMeal('snack', snack, targetCal * 0.10),
      ];

      for (final m in meals) {
        grocerySet.addAll(
            (m['ingredients'] as List).cast<String>());
      }

      final totalCal = meals.fold<double>(
          0, (s, m) => s + (m['calories'] as num).toDouble());

      daysList.add({
        'day': d,
        'meals': meals,
        'total_calories': totalCal.round(),
      });
    }

    return {
      'days': daysList,
      'grocery_list': grocerySet.toList(),
    };
  }

  // ══════════════════════════════════════════════════════════════════
  //  WORKOUT PLAN
  // ══════════════════════════════════════════════════════════════════

  Map<String, dynamic> generateWorkoutPlan({
    required Map<String, dynamic> userContext,
    required int weeks,
  }) {
    final goal = (userContext['goal'] as String?) ?? 'build_muscle';
    final daysPerWeek = (userContext['workout_days'] as int?) ?? 4;
    final fitnessLevel =
        (userContext['fitness_level'] as String?) ?? 'intermediate';

    final programName = _workoutProgramName(goal);
    final weeksList = <Map<String, dynamic>>[];

    for (var w = 1; w <= weeks; w++) {
      final days = <Map<String, dynamic>>[];
      final splits = _workoutSplits(goal, daysPerWeek);

      for (var d = 0; d < splits.length; d++) {
        days.add({
          'day_name': 'Day ${d + 1}',
          'focus': splits[d]['focus'],
          'exercises': _exercisesForFocus(
            splits[d]['focus'] as String,
            fitnessLevel,
            w, // progressive overload: bump volume each week
          ),
        });
      }

      weeksList.add({'week': w, 'days': days});
    }

    return {
      'program_name': programName,
      'weeks': weeksList,
    };
  }

  // ══════════════════════════════════════════════════════════════════
  //  AI COACH CHAT
  // ══════════════════════════════════════════════════════════════════

  Map<String, dynamic> chat({
    required String message,
    required Map<String, dynamic> userContext,
  }) {
    final lower = message.toLowerCase();
    String response;

    // ── Pattern-match common intents ────────────────────────────
    if (_matches(lower, ['calorie', 'calories', 'kcal', 'how many calories', 'remaining'])) {
      response = _calorieResponse(userContext);
    } else if (_matches(lower, ['protein', 'enough protein', 'protein intake'])) {
      response = _proteinResponse(userContext);
    } else if (_matches(lower, ['what should i eat', 'meal suggestion', 'suggest a meal', 'hungry', 'what to eat'])) {
      response = _mealSuggestionResponse(userContext);
    } else if (_matches(lower, ['workout', 'exercise', 'train', 'gym', 'lifting'])) {
      response = _workoutResponse(userContext);
    } else if (_matches(lower, ['weight', 'progress', 'lost', 'gained', 'body'])) {
      response = _progressResponse(userContext);
    } else if (_matches(lower, ['streak', 'xp', 'level', 'badge', 'gamif'])) {
      response = _gamificationResponse(userContext);
    } else if (_matches(lower, ['sleep', 'rest', 'recover'])) {
      response = _sleepResponse(userContext);
    } else if (_matches(lower, ['water', 'hydrat'])) {
      response = _waterResponse(userContext);
    } else if (_matches(lower, ['macro', 'carbs', 'fat', 'fats'])) {
      response = _macroResponse(userContext);
    } else if (_matches(lower, ['hi', 'hello', 'hey', 'sup', 'good morning', 'good evening'])) {
      response = _greetingResponse(userContext);
    } else {
      // Generic helpful fallback
      response = _genericResponse(userContext);
    }

    return {
      'response': response,
      'suggestions': <String>[],
    };
  }

  // ══════════════════════════════════════════════════════════════════
  //  DAILY INSIGHT
  // ══════════════════════════════════════════════════════════════════

  Map<String, dynamic> getDailyInsight({
    required Map<String, dynamic> userContext,
  }) {
    final cal = _toDouble(userContext['calories']);
    final targetCal = _toDouble(userContext['target_calories']);
    final protein = _toDouble(userContext['protein']);
    final meals = (userContext['meals_today'] as num?)?.toInt() ?? 0;

    final templates = <Map<String, dynamic>>[];

    if (meals == 0) {
      templates.add({
        'insight':
            'Start your day strong! Log your first meal and I\'ll give you personalized insights.',
        'icon': '🌅',
        'category': 'motivation',
      });
    }

    if (cal > 0 && targetCal > 0) {
      final pct = (cal / targetCal * 100).round();
      if (pct < 50) {
        templates.add({
          'insight':
              'You\'re at $pct% of your daily calories. Plenty of room for nutritious meals — make them count with high-protein choices!',
          'icon': '📊',
          'category': 'nutrition',
        });
      } else if (pct >= 80 && pct <= 110) {
        templates.add({
          'insight':
              'You\'re right on track at $pct% of your calorie target! Consistency like this drives real results.',
          'icon': '🎯',
          'category': 'progress',
        });
      } else if (pct > 110) {
        templates.add({
          'insight':
              'You\'re at $pct% of your daily target — a bit over, but one day won\'t derail progress. Stay consistent tomorrow!',
          'icon': '💡',
          'category': 'nutrition',
        });
      }
    }

    if (protein > 0) {
      final targetP = _toDouble(userContext['target_protein_g']);
      if (targetP > 0) {
        final pPct = (protein / targetP * 100).round();
        if (pPct < 40) {
          templates.add({
            'insight':
                'Protein check: only ${protein.round()}g so far ($pPct%). '
                'Add some paneer, eggs, or dal to close the gap!',
            'icon': '🥚',
            'category': 'nutrition',
          });
        }
      }
    }

    // Motivation templates
    templates.addAll([
      {
        'insight':
            'Every meal logged is a step closer to your goals. You\'re building a powerful habit — keep showing up!',
        'icon': '🔥',
        'category': 'motivation',
      },
      {
        'insight':
            'Consistency beats perfection. Even on off days, tracking keeps you honest and in control.',
        'icon': '💪',
        'category': 'motivation',
      },
    ]);

    return templates[_rng.nextInt(min(3, templates.length))];
  }

  Map<String, dynamic> _buildDefaultMealPlan(int days, double targetCal) {
    final scale = targetCal / 1320; // 1320 = default template total
    Map<String, dynamic> scaleMeal(Map<String, dynamic> m) => {
          ...m,
          'calories': ((m['calories'] as num) * scale).round(),
          'protein_g': ((m['protein_g'] as num) * scale).round(),
          'carbs_g': ((m['carbs_g'] as num) * scale).round(),
          'fat_g': ((m['fat_g'] as num) * scale).round(),
        };

    final templates = [
      scaleMeal({'type': 'breakfast', 'name': 'Oats with Milk', 'calories': 350, 'protein_g': 12, 'carbs_g': 55, 'fat_g': 8, 'prep_min': 5, 'ingredients': ['oats', 'milk'], 'instructions': 'Cook oats with milk for 3 minutes.'}),
      scaleMeal({'type': 'lunch', 'name': 'Dal Rice', 'calories': 450, 'protein_g': 15, 'carbs_g': 70, 'fat_g': 8, 'prep_min': 20, 'ingredients': ['dal', 'rice', 'spices'], 'instructions': 'Cook dal and rice with spices.'}),
      scaleMeal({'type': 'dinner', 'name': 'Grilled Chicken Salad', 'calories': 400, 'protein_g': 35, 'carbs_g': 25, 'fat_g': 12, 'prep_min': 20, 'ingredients': ['chicken breast', 'salad greens', 'olive oil'], 'instructions': 'Grill chicken, serve with salad.'}),
      scaleMeal({'type': 'snack', 'name': 'Greek Yogurt', 'calories': 120, 'protein_g': 12, 'carbs_g': 8, 'fat_g': 3, 'prep_min': 0, 'ingredients': ['greek yogurt'], 'instructions': 'Serve chilled.'}),
    ];

    final totalCal = templates.fold<double>(0, (s, m) => s + (m['calories'] as num));
    return {
      'days': List.generate(days, (i) => {
        'day': i + 1,
        'meals': templates,
        'total_calories': totalCal.round(),
      }),
      'grocery_list': ['oats', 'milk', 'dal', 'rice', 'chicken breast', 'salad greens', 'olive oil', 'greek yogurt'],
    };
  }

  // ══════════════════════════════════════════════════════════════════
  //  PRIVATE HELPERS
  // ══════════════════════════════════════════════════════════════════

  Map<String, dynamic> _foodEntryToItem(FoodEntry food) {
    return {
      'name': food.name,
      'quantity_g': food.servingG,
      'calories': food.cal.round(),
      'protein_g': food.protein,
      'carbs_g': food.carbs,
      'fat_g': food.fat,
    };
  }

  Map<String, dynamic> _computeTotals(List<Map<String, dynamic>> items) {
    double cal = 0, p = 0, c = 0, f = 0;
    for (final item in items) {
      cal += (item['calories'] as num).toDouble();
      p += (item['protein_g'] as num).toDouble();
      c += (item['carbs_g'] as num).toDouble();
      f += (item['fat_g'] as num).toDouble();
    }
    return {
      'calories': cal.round(),
      'protein_g': p,
      'carbs_g': c,
      'fat_g': f,
    };
  }

  int _computeHealthScore(
      Map<String, dynamic> totals, Map<String, dynamic> ctx) {
    final cal = (totals['calories'] as num).toDouble();
    final targetCal = (ctx['target_calories'] as num?)?.toDouble() ?? 2000;
    final ratio = cal / (targetCal / 3); // assume 3 meals
    if (ratio >= 0.8 && ratio <= 1.2) return 8;
    if (ratio >= 0.6 && ratio <= 1.4) return 6;
    return 5;
  }

  String _buildMealFeedbackLine(
      Map<String, dynamic> totals, Map<String, dynamic> ctx) {
    final cal = (totals['calories'] as num).toDouble();
    if (cal < 200) return 'Light meal — consider adding more protein.';
    if (cal > 800) return 'Hearty meal! That covers a good chunk of your day.';
    return 'Balanced meal logged. Keep it going!';
  }

  String _cleanName(String raw) {
    return raw.length > 40 ? '${raw.substring(0, 37)}...' : raw;
  }

  List<FoodEntry> _foodsByCategory(List<String> categories) {
    if (!_kb.isLoaded) return [];
    return _kb.allFoods.where((f) {
      final cat = (f.category ?? '').toLowerCase();
      final dish = (f.dish ?? '').toLowerCase();
      return categories.any((c) => cat.contains(c) || dish.contains(c));
    }).toList();
  }

  Map<String, dynamic> _planMeal(
      String type, FoodEntry food, double targetCal) {
    // Scale portion to fit the target calorie slot
    final scale = food.cal > 0 ? targetCal / food.cal : 1.0;
    final clampedScale = scale.clamp(0.5, 2.5);
    return {
      'type': type,
      'name': food.name,
      'calories': (food.cal * clampedScale).round(),
      'protein_g': (food.protein * clampedScale).round(),
      'carbs_g': (food.carbs * clampedScale).round(),
      'fat_g': (food.fat * clampedScale).round(),
      'prep_min': 20,
      'ingredients': food.ingredients.isNotEmpty
          ? food.ingredients
          : [food.name.toLowerCase()],
      'instructions': 'Prepare ${food.name} as per standard recipe.',
    };
  }

  // ── Meal enrichment helpers ──────────────────────────────────────

  List<String> _inferIngredients(String mealName) {
    final name = mealName.toLowerCase();
    if (name.contains('biryani')) {
      return ['Basmati rice', 'Chicken/Beef', 'Onion', 'Tomato', 'Yogurt', 'Spices', 'Oil'];
    }
    if (name.contains('nihari')) {
      return ['Beef shank', 'Wheat flour', 'Ghee', 'Spices', 'Ginger', 'Garlic'];
    }
    if (name.contains('karahi')) {
      return ['Chicken/Mutton', 'Tomato', 'Green chilli', 'Ginger', 'Garlic', 'Oil', 'Spices'];
    }
    if (name.contains('dal') || name.contains('daal')) {
      return ['Lentils', 'Onion', 'Tomato', 'Garlic', 'Cumin', 'Oil', 'Salt'];
    }
    if (name.contains('rice')) {
      return ['Rice', 'Water', 'Salt', 'Oil'];
    }
    if (name.contains('paratha') || name.contains('roti') || name.contains('chapati')) {
      return ['Wheat flour', 'Water', 'Salt', 'Oil/Butter'];
    }
    if (name.contains('egg') || name.contains('anda')) {
      return ['Eggs', 'Oil', 'Salt', 'Pepper', 'Onion', 'Tomato'];
    }
    if (name.contains('chicken')) {
      return ['Chicken', 'Onion', 'Tomato', 'Garlic', 'Ginger', 'Spices', 'Oil'];
    }
    if (name.contains('salad')) {
      return ['Lettuce', 'Tomato', 'Cucumber', 'Olive oil', 'Lemon', 'Salt'];
    }
    if (name.contains('sandwich')) {
      return ['Bread', 'Chicken/Beef', 'Lettuce', 'Tomato', 'Sauce', 'Cheese'];
    }
    if (name.contains('burger')) {
      return ['Bun', 'Beef patty', 'Lettuce', 'Tomato', 'Onion', 'Sauce', 'Cheese'];
    }
    if (name.contains('pizza')) {
      return ['Dough', 'Tomato sauce', 'Cheese', 'Toppings', 'Olive oil'];
    }
    return ['Mixed ingredients'];
  }

  List<Map<String, dynamic>> _defaultAvailability(String mealName) {
    final name = mealName.toLowerCase();
    // Fast food / western
    if (name.contains('burger') || name.contains('pizza') || name.contains('sandwich')) {
      return [
        {'area': 'Fast food chain', 'min_price': 450, 'max_price': 900},
        {'area': 'Local café / bakery', 'min_price': 250, 'max_price': 500},
        {'area': 'Food delivery app', 'min_price': 500, 'max_price': 1000},
      ];
    }
    // Biryani
    if (name.contains('biryani')) {
      return [
        {'area': 'Street stall / Dhaba', 'min_price': 150, 'max_price': 250},
        {'area': 'Local biryani house', 'min_price': 280, 'max_price': 450},
        {'area': 'Upscale restaurant', 'min_price': 600, 'max_price': 1200},
      ];
    }
    // Default Pakistani street food
    return [
      {'area': 'Street stall / Dhaba', 'min_price': 80, 'max_price': 200},
      {'area': 'Local restaurant', 'min_price': 200, 'max_price': 450},
      {'area': 'Upscale / Delivery', 'min_price': 500, 'max_price': 1000},
    ];
  }

  int _defaultBestPrice(String mealName) {
    final avail = _defaultAvailability(mealName);
    if (avail.isEmpty) return 80;
    return (avail.first['min_price'] as int);
  }

  // ── Workout helpers ──────────────────────────────────────────────

  String _workoutProgramName(String goal) {
    switch (goal) {
      case 'lose_fat':
      case 'lose_fat_slow':
        return 'Fat Burn Focus';
      case 'gain_muscle':
      case 'gain_muscle_aggressive':
        return 'Muscle Builder Pro';
      case 'athletic':
        return 'Athletic Performance';
      case 'recomp':
        return 'Body Recomposition';
      default:
        return 'FitSmart Training Plan';
    }
  }

  List<Map<String, String>> _workoutSplits(String goal, int daysPerWeek) {
    final isStrength =
        goal.contains('muscle') || goal == 'recomp' || goal == 'athletic';
    if (daysPerWeek >= 5) {
      return [
        {'focus': 'Chest & Triceps'},
        {'focus': 'Back & Biceps'},
        {'focus': 'Legs & Glutes'},
        {'focus': 'Shoulders & Arms'},
        {'focus': isStrength ? 'Full Body Power' : 'HIIT Cardio'},
      ].take(daysPerWeek).toList();
    }
    if (daysPerWeek >= 3) {
      return [
        {'focus': 'Upper Body Push'},
        {'focus': 'Lower Body'},
        {'focus': 'Upper Body Pull'},
        if (daysPerWeek >= 4) {'focus': isStrength ? 'Legs & Core' : 'Cardio & Core'},
      ];
    }
    return [
      {'focus': 'Full Body A'},
      {'focus': 'Full Body B'},
    ];
  }

  List<Map<String, dynamic>> _exercisesForFocus(
      String focus, String level, int week) {
    final baseSets = level == 'beginner' ? 3 : 4;
    final sets = baseSets + (week > 2 ? 1 : 0); // progressive overload
    final reps = level == 'beginner' ? '10-12' : '8-12';
    final rest = level == 'beginner' ? 90 : 60;

    final exercises = _exerciseDatabase[focus] ??
        _exerciseDatabase['Full Body A']!;

    return exercises.map((name) {
      return {
        'name': name,
        'sets': sets,
        'reps': reps,
        'rest_sec': rest,
        'notes': week > 2 ? 'Increase weight from week 1-2' : 'Focus on form',
      };
    }).toList();
  }

  static const _exerciseDatabase = {
    'Chest & Triceps': [
      'Bench Press', 'Incline Dumbbell Press', 'Cable Flyes',
      'Tricep Pushdowns', 'Overhead Tricep Extension',
    ],
    'Back & Biceps': [
      'Barbell Rows', 'Lat Pulldowns', 'Seated Cable Rows',
      'Barbell Curls', 'Hammer Curls',
    ],
    'Legs & Glutes': [
      'Barbell Squats', 'Romanian Deadlifts', 'Leg Press',
      'Walking Lunges', 'Hip Thrusts',
    ],
    'Shoulders & Arms': [
      'Overhead Press', 'Lateral Raises', 'Face Pulls',
      'EZ-Bar Curls', 'Skull Crushers',
    ],
    'Upper Body Push': [
      'Bench Press', 'Overhead Press', 'Incline Dumbbell Press',
      'Lateral Raises', 'Tricep Pushdowns',
    ],
    'Upper Body Pull': [
      'Barbell Rows', 'Pull-Ups', 'Face Pulls',
      'Barbell Curls', 'Rear Delt Flyes',
    ],
    'Lower Body': [
      'Barbell Squats', 'Romanian Deadlifts', 'Leg Press',
      'Bulgarian Split Squats', 'Calf Raises',
    ],
    'Full Body A': [
      'Barbell Squats', 'Bench Press', 'Barbell Rows',
      'Overhead Press', 'Plank',
    ],
    'Full Body B': [
      'Deadlifts', 'Incline Dumbbell Press', 'Lat Pulldowns',
      'Lunges', 'Hanging Leg Raises',
    ],
    'Full Body Power': [
      'Deadlifts', 'Clean and Press', 'Front Squats',
      'Weighted Pull-Ups', 'Farmer\'s Walks',
    ],
    'HIIT Cardio': [
      'Burpees', 'Mountain Climbers', 'Jump Squats',
      'Kettlebell Swings', 'Battle Ropes',
    ],
    'Legs & Core': [
      'Front Squats', 'Leg Curls', 'Hip Thrusts',
      'Cable Woodchops', 'Hanging Leg Raises',
    ],
    'Cardio & Core': [
      'Rowing Machine (Intervals)', 'Box Jumps', 'Jump Rope',
      'Russian Twists', 'Plank Variations',
    ],
  };

  // ── Chat response helpers ────────────────────────────────────────

  bool _matches(String text, List<String> keywords) {
    return keywords.any((kw) => text.contains(kw));
  }

  double _toDouble(dynamic v) {
    if (v == null) return 0;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    if (v is String) return double.tryParse(v) ?? 0;
    if (v is num) return v.toDouble();
    return 0;
  }

  String _calorieResponse(Map<String, dynamic> ctx) {
    final consumed = _toDouble(ctx['consumed_calories_today']);
    final target = _toDouble(ctx['target_calories']);
    final remaining = target - consumed;
    final pct = target > 0 ? (consumed / target * 100).round() : 0;

    return '📊 **Calorie Update**\n\n'
        '• Consumed: **${consumed.round()} kcal** ($pct% of target)\n'
        '• Target: **${target.round()} kcal**\n'
        '• Remaining: **${remaining.round()} kcal**\n\n'
        '${remaining > 500 ? 'You have plenty of room for a solid meal. Focus on protein-rich options!' : remaining > 0 ? 'Getting close to your target — consider a light snack if needed.' : 'You\'ve hit your target for today. If you\'re still hungry, opt for veggies or a protein shake.'}';
  }

  String _proteinResponse(Map<String, dynamic> ctx) {
    final consumed = _toDouble(ctx['consumed_protein_today']);
    final target = _toDouble(ctx['target_protein_g']);
    final remaining = target - consumed;

    return '🥩 **Protein Status**\n\n'
        '• Consumed: **${consumed.round()}g** / ${target.round()}g\n'
        '• Remaining: **${remaining.round()}g**\n\n'
        '${remaining > 40 ? 'Time to load up! Great options:\n• Paneer tikka (~25g per 100g)\n• Chicken breast (~31g per 100g)\n• Greek yogurt (~10g per serving)\n• Dal/lentils (~9g per cup)' : remaining > 0 ? 'Almost there! A quick protein shake or some eggs will close the gap.' : 'Excellent — you\'ve hit your protein target! 💪'}';
  }

  String _mealSuggestionResponse(Map<String, dynamic> ctx) {
    final remaining = _toDouble(ctx['target_calories']) -
        _toDouble(ctx['consumed_calories_today']);
    final remProtein = _toDouble(ctx['target_protein_g']) -
        _toDouble(ctx['consumed_protein_today']);

    // Pick foods from RAG
    final suggestions = _kb.isLoaded
        ? _kb.search('high protein meal', limit: 4)
        : <FoodSearchResult>[];

    final buf = StringBuffer('🍽️ **Meal Suggestion**\n\n');
    buf.writeln(
        'You have ~**${remaining.round()} kcal** and **${remProtein.round()}g protein** remaining.\n');

    if (suggestions.isNotEmpty) {
      buf.writeln('Here are some options from our database:');
      for (final s in suggestions) {
        buf.writeln(
            '• **${s.food.name}** — ${s.food.cal.round()} kcal, ${s.food.protein.round()}g protein per ${s.food.serving}');
      }
    } else {
      buf.writeln('Consider:\n'
          '• Grilled chicken with rice and veggies\n'
          '• Paneer tikka with roti\n'
          '• Eggs with toast and avocado\n'
          '• Dal with brown rice');
    }

    return buf.toString();
  }

  String _workoutResponse(Map<String, dynamic> ctx) {
    return '🏋️ **Workout Tips**\n\n'
        'Based on your goal of **${ctx['goal'] ?? 'general fitness'}**:\n\n'
        '• Focus on compound movements (squats, deadlifts, bench, rows)\n'
        '• Hit each muscle group 2x/week for optimal growth\n'
        '• Progressive overload is key — increase weight or reps each week\n'
        '• Rest 60-90s between sets for hypertrophy, 2-3min for strength\n\n'
        'Generate a full plan from the Workouts tab for a structured program!';
  }

  String _progressResponse(Map<String, dynamic> ctx) {
    final weight = _toDouble(ctx['weight_kg']);
    final target = _toDouble(ctx['target_weight_kg']);
    final streak = (ctx['current_streak'] as num?)?.toInt() ?? 0;

    final buf = StringBuffer('📈 **Your Progress**\n\n');
    if (weight > 0) {
      buf.writeln('• Current weight: **${weight}kg**');
      if (target > 0) {
        final diff = (weight - target).abs();
        buf.writeln(
            '• Target: **${target}kg** (${diff.toStringAsFixed(1)}kg to go)');
      }
    }
    if (streak > 0) {
      buf.writeln('• Current streak: **$streak days** 🔥');
    }
    buf.writeln(
        '\nConsistency is the #1 predictor of success. Keep logging and the results will follow!');
    return buf.toString();
  }

  String _gamificationResponse(Map<String, dynamic> ctx) {
    final level = ctx['level'] ?? '?';
    final levelName = ctx['level_name'] ?? '';
    final xp = ctx['total_xp'] ?? 0;
    final streak = ctx['current_streak'] ?? 0;

    return '🏆 **Your Stats**\n\n'
        '• Level: **$level** ($levelName)\n'
        '• Total XP: **$xp**\n'
        '• Streak: **$streak days**\n\n'
        'Keep logging meals and workouts to earn XP and level up!';
  }

  String _sleepResponse(Map<String, dynamic> ctx) {
    return '😴 **Sleep & Recovery**\n\n'
        'Sleep is crucial for both muscle recovery and fat loss:\n'
        '• Aim for **7-9 hours** per night\n'
        '• Keep a consistent sleep schedule\n'
        '• Avoid screens 30min before bed\n'
        '• A casein protein shake before bed supports overnight recovery\n\n'
        '${ctx['sleep_schedule'] != null ? 'Your sleep schedule: **${ctx['sleep_schedule']}** — great that you\'re tracking it!' : 'Set your sleep schedule in Settings for personalized timing advice.'}';
  }

  String _waterResponse(Map<String, dynamic> ctx) {
    final water = (ctx['water_ml_today'] as num?)?.toInt() ?? 0;
    return '💧 **Hydration**\n\n'
        '• Today: **${water}ml**\n'
        '• Goal: **2500-3000ml** for active individuals\n\n'
        '${water < 1500 ? 'You\'re behind on hydration — try drinking a glass of water right now!' : water < 2500 ? 'Good progress! Keep sipping throughout the day.' : 'Excellent hydration today! 👏'}';
  }

  String _macroResponse(Map<String, dynamic> ctx) {
    final cCal = _toDouble(ctx['consumed_calories_today']);
    final cP = _toDouble(ctx['consumed_protein_today']);
    final cC = _toDouble(ctx['consumed_carbs_today']);
    final cF = _toDouble(ctx['consumed_fat_today']);
    final tCal = _toDouble(ctx['target_calories']);
    final tP = _toDouble(ctx['target_protein_g']);
    final tC = _toDouble(ctx['target_carbs_g']);
    final tF = _toDouble(ctx['target_fat_g']);

    return '📋 **Macro Breakdown**\n\n'
        '| Macro | Consumed | Target | Remaining |\n'
        '|-------|----------|--------|----------|\n'
        '| Calories | ${cCal.round()} | ${tCal.round()} | ${(tCal - cCal).round()} |\n'
        '| Protein | ${cP.round()}g | ${tP.round()}g | ${(tP - cP).round()}g |\n'
        '| Carbs | ${cC.round()}g | ${tC.round()}g | ${(tC - cC).round()}g |\n'
        '| Fat | ${cF.round()}g | ${tF.round()}g | ${(tF - cF).round()}g |\n\n'
        '${(tP - cP) > 30 ? 'Focus on getting more protein in your remaining meals!' : 'You\'re hitting your macros well today! 🎯'}';
  }

  String _greetingResponse(Map<String, dynamic> ctx) {
    final streak = (ctx['current_streak'] as num?)?.toInt() ?? 0;
    final name = ctx['name'] as String? ?? '';
    final greeting = name.isNotEmpty ? 'Hey $name! 👋' : 'Hey there! 👋';

    return '$greeting\n\n'
        'I\'m your FitSmart AI coach. Here\'s your quick status:\n'
        '${streak > 0 ? '• 🔥 Streak: **$streak days**\n' : ''}'
        '• 🎯 Calories: **${_toDouble(ctx['consumed_calories_today']).round()}** / ${_toDouble(ctx['target_calories']).round()} kcal\n'
        '• 🥩 Protein: **${_toDouble(ctx['consumed_protein_today']).round()}g** / ${_toDouble(ctx['target_protein_g']).round()}g\n\n'
        'What can I help you with? Ask me about meals, workouts, macros, or anything fitness-related!';
  }

  String _genericResponse(Map<String, dynamic> ctx) {
    final remCal = _toDouble(ctx['target_calories']) -
        _toDouble(ctx['consumed_calories_today']);
    final remP = _toDouble(ctx['target_protein_g']) -
        _toDouble(ctx['consumed_protein_today']);

    return 'Here\'s what I can see from your data:\n\n'
        '• **${remCal.round()} kcal** and **${remP.round()}g protein** remaining today\n\n'
        'I can help with:\n'
        '• 🍽️ Meal suggestions and analysis\n'
        '• 🏋️ Workout advice and plans\n'
        '• 📊 Calorie/macro tracking\n'
        '• 📈 Progress analysis\n'
        '• 💧 Hydration tips\n\n'
        'Just ask me anything specific and I\'ll give you detailed, personalized advice!';
  }
}
