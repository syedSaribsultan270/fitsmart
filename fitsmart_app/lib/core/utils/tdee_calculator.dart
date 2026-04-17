import '../constants/app_constants.dart';

class TdeeResult {
  final double bmr;
  final double tdee;
  final double targetCalories;
  final double proteinG;
  final double carbsG;
  final double fatG;

  const TdeeResult({
    required this.bmr,
    required this.tdee,
    required this.targetCalories,
    required this.proteinG,
    required this.carbsG,
    required this.fatG,
  });
}

class TdeeCalculator {
  /// Mifflin-St Jeor BMR formula
  static double calculateBmr({
    required double weightKg,
    required double heightCm,
    required int age,
    required String gender, // 'male' | 'female' | 'other'
  }) {
    final base = (10 * weightKg) + (6.25 * heightCm) - (5 * age);
    return gender == 'male' ? base + 5 : base - 161;
  }

  static TdeeResult calculate({
    required double weightKg,
    required double heightCm,
    required int age,
    required String gender,
    required String activityLevel,
    required String goal,
    double? bodyFatPct,
  }) {
    final bmr = calculateBmr(
      weightKg: weightKg,
      heightCm: heightCm,
      age: age,
      gender: gender,
    );

    final multiplier = AppConstants.activityMultipliers[activityLevel] ?? 1.55;
    final tdee = bmr * multiplier;

    final adjustment = AppConstants.goalCalAdjustments[goal] ?? 0;
    final targetCalories = (tdee + adjustment).clamp(1200.0, 6000.0);

    // Macro split based on goal
    final macros = _calculateMacros(targetCalories, weightKg, goal);

    return TdeeResult(
      bmr: bmr,
      tdee: tdee,
      targetCalories: targetCalories,
      proteinG: macros['protein']!,
      carbsG: macros['carbs']!,
      fatG: macros['fat']!,
    );
  }

  static Map<String, double> _calculateMacros(
    double calories,
    double weightKg,
    String goal,
  ) {
    double proteinG;
    double fatPct;

    switch (goal) {
      case 'gain_muscle':
      case 'gain_muscle_aggressive':
        proteinG = weightKg * 2.2; // 2.2g/kg
        fatPct = 0.25;
        break;
      case 'lose_fat':
      case 'lose_fat_slow':
        proteinG = weightKg * 2.4; // higher protein to preserve muscle
        fatPct = 0.30;
        break;
      case 'recomp':
        proteinG = weightKg * 2.5;
        fatPct = 0.28;
        break;
      case 'athletic':
        proteinG = weightKg * 2.0;
        fatPct = 0.28;
        break;
      default: // maintain
        proteinG = weightKg * 1.8;
        fatPct = 0.30;
    }

    final proteinCals = proteinG * 4;
    final fatCals = calories * fatPct;
    final carbsCals = calories - proteinCals - fatCals;

    return {
      'protein': proteinG,
      'fat': fatCals / 9,
      'carbs': (carbsCals / 4).clamp(50.0, 1000.0),
    };
  }

  static String levelToGoalKey(String paceKey) {
    switch (paceKey) {
      case 'slow':
        return 'lose_fat_slow';
      case 'aggressive':
        return 'lose_fat';
      default:
        return 'lose_fat';
    }
  }
}
