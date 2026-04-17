import '../../data/database/database_provider.dart';
import '../../features/dashboard/providers/dashboard_provider.dart';
import 'ai_tool.dart';

/// Returns today's totals + remaining vs targets. Lets the AI stop
/// making up numbers when the user asks "how much protein did I have?".
class GetTodaysTotalsTool extends AiTool {
  @override
  String get name => 'get_todays_totals';

  @override
  bool get isWrite => false;

  @override
  String get confirmTitle => 'Fetch totals';

  @override
  String get description =>
      'Return the user\'s current day totals (calories + macros) and how '
      'many remain vs their daily targets. Call this whenever the user asks '
      'about what they\'ve had today, what they have left, or how close '
      'they are to a goal. Never make up numbers — call this instead.';

  @override
  Map<String, dynamic> get parameterSchema =>
      const {'type': 'object', 'properties': {}, 'required': <String>[]};

  @override
  String summarize(Map<String, dynamic> args) => "today's totals";

  @override
  Future<AiToolResult> execute(ToolRef read, Map<String, dynamic> args) async {
    final db = read(databaseProvider);
    final meals = await db.watchTodaysMeals().first;
    double cal = 0, p = 0, c = 0, f = 0, fib = 0;
    for (final m in meals) {
      cal += m.calories;
      p += m.proteinG;
      c += m.carbsG;
      f += m.fatG;
      fib += m.fiberG;
    }
    final water = await db.getTodaysWater();

    // Targets — read the same nutrition provider the dashboard uses.
    final targets = read(nutritionTargetsProvider);

    return AiToolResult.ok({
      'consumed': {
        'calories': cal.round(),
        'protein_g': p.round(),
        'carbs_g': c.round(),
        'fat_g': f.round(),
        'fiber_g': fib.round(),
        'water_ml': water,
      },
      'targets': {
        'calories': targets.calories.round(),
        'protein_g': targets.proteinG.round(),
        'carbs_g': targets.carbsG.round(),
        'fat_g': targets.fatG.round(),
      },
      'remaining': {
        'calories': (targets.calories - cal).round(),
        'protein_g': (targets.proteinG - p).round(),
        'carbs_g': (targets.carbsG - c).round(),
        'fat_g': (targets.fatG - f).round(),
      },
      'meal_count': meals.length,
    });
  }
}

/// Returns the names + macros of every meal logged today. For "what did I
/// eat today?" type prompts.
class GetTodaysMealsTool extends AiTool {
  @override
  String get name => 'get_todays_meals';

  @override
  bool get isWrite => false;

  @override
  String get confirmTitle => 'Fetch meals';

  @override
  String get description =>
      'List every meal the user has logged today (name + macros + time). '
      'Call when the user asks what they ate today or wants a breakdown.';

  @override
  Map<String, dynamic> get parameterSchema =>
      const {'type': 'object', 'properties': {}, 'required': <String>[]};

  @override
  String summarize(Map<String, dynamic> args) => "today's meals";

  @override
  Future<AiToolResult> execute(ToolRef read, Map<String, dynamic> args) async {
    final db = read(databaseProvider);
    final meals = await db.watchTodaysMeals().first;
    return AiToolResult.ok({
      'meals': meals
          .map((m) => {
                'name': m.name,
                'meal_type': m.mealType,
                'calories': m.calories.round(),
                'protein_g': m.proteinG.round(),
                'carbs_g': m.carbsG.round(),
                'fat_g': m.fatG.round(),
                'logged_at': m.loggedAt.toIso8601String(),
              })
          .toList(),
    });
  }
}

/// Last N weigh-ins with dates + delta from oldest. Powers "how's my
/// weight trending?" questions.
class GetRecentWeightTrendTool extends AiTool {
  @override
  String get name => 'get_recent_weight_trend';

  @override
  bool get isWrite => false;

  @override
  String get confirmTitle => 'Fetch weight trend';

  @override
  String get description =>
      'Return the last 14 weigh-ins with dates so you can reason about '
      'the trend. Call when the user asks about weight progress.';

  @override
  Map<String, dynamic> get parameterSchema =>
      const {'type': 'object', 'properties': {}, 'required': <String>[]};

  @override
  String summarize(Map<String, dynamic> args) => 'weight trend';

  @override
  Future<AiToolResult> execute(ToolRef read, Map<String, dynamic> args) async {
    final db = read(databaseProvider);
    final logs = await db.getWeightHistory(limit: 14);
    if (logs.isEmpty) {
      return AiToolResult.ok({
        'has_data': false,
        'entries': const <Map<String, dynamic>>[],
      });
    }
    final oldest = logs.last.weightKg;
    final latest = logs.first.weightKg;
    return AiToolResult.ok({
      'has_data': true,
      'latest_kg': latest,
      'oldest_kg': oldest,
      'delta_kg': (latest - oldest),
      'entries': logs
          .map((w) => {
                'weight_kg': w.weightKg,
                'logged_at': w.loggedAt.toIso8601String(),
              })
          .toList(),
    });
  }
}
