class OnboardingData {
  // Step 1: Goal
  String? primaryGoal; // lose_fat, gain_muscle, recomp, athletic, maintain, healthy

  // Step 2: Bio
  String? gender; // male, female, non_binary, prefer_not
  int? age;

  // Step 3: Body Stats
  double? heightCm;
  double? weightKg;
  double? bodyFatPct;

  // Step 4: Location
  String? country;
  String? city;

  // Step 5: Activity
  String? activityLevel; // sedentary, lightly_active, moderately_active, very_active, extremely_active

  // Step 6: Dream Body
  String? targetBodyType; // lean, athletic, bulk (varies per gender)

  // Step 7: Sleep
  int? bedtimeHour;
  int? bedtimeMin;
  int? wakeHour;
  int? wakeMin;

  // Step 8: Diet
  List<String>? dietaryRestrictions; // vegetarian, vegan, keto, halal, etc.
  List<String>? cuisinePreferences;
  List<String>? dislikedIngredients;

  // Step 9: Budget
  double? monthlyBudgetUsd;

  // Step 10: Targets
  double? targetWeightKg;
  String? weightChangePace; // slow, steady, aggressive, maximum
  int? workoutDaysPerWeek;

  OnboardingData();

  /// Creates a shallow copy so StateNotifier detects the change.
  OnboardingData clone() => OnboardingData.fromJson(toJson());

  bool get isComplete =>
      primaryGoal != null &&
      gender != null &&
      age != null &&
      heightCm != null &&
      weightKg != null &&
      activityLevel != null &&
      targetWeightKg != null;

  Map<String, dynamic> toJson() => {
        'primaryGoal': primaryGoal,
        'gender': gender,
        'age': age,
        'heightCm': heightCm,
        'weightKg': weightKg,
        'bodyFatPct': bodyFatPct,
        'country': country,
        'city': city,
        'activityLevel': activityLevel,
        'targetBodyType': targetBodyType,
        'bedtimeHour': bedtimeHour,
        'bedtimeMin': bedtimeMin,
        'wakeHour': wakeHour,
        'wakeMin': wakeMin,
        'dietaryRestrictions': dietaryRestrictions,
        'cuisinePreferences': cuisinePreferences,
        'dislikedIngredients': dislikedIngredients,
        'monthlyBudgetUsd': monthlyBudgetUsd,
        'targetWeightKg': targetWeightKg,
        'weightChangePace': weightChangePace,
        'workoutDaysPerWeek': workoutDaysPerWeek,
      };

  factory OnboardingData.fromJson(Map<String, dynamic> json) {
    return OnboardingData()
      ..primaryGoal = json['primaryGoal']
      ..gender = json['gender']
      ..age = json['age']
      ..heightCm = json['heightCm']?.toDouble()
      ..weightKg = json['weightKg']?.toDouble()
      ..bodyFatPct = json['bodyFatPct']?.toDouble()
      ..country = json['country']
      ..city = json['city']
      ..activityLevel = json['activityLevel']
      ..targetBodyType = json['targetBodyType']
      ..bedtimeHour = json['bedtimeHour']
      ..bedtimeMin = json['bedtimeMin']
      ..wakeHour = json['wakeHour']
      ..wakeMin = json['wakeMin']
      ..dietaryRestrictions = (json['dietaryRestrictions'] as List?)?.cast<String>()
      ..cuisinePreferences = (json['cuisinePreferences'] as List?)?.cast<String>()
      ..dislikedIngredients = (json['dislikedIngredients'] as List?)?.cast<String>()
      ..monthlyBudgetUsd = json['monthlyBudgetUsd']?.toDouble()
      ..targetWeightKg = json['targetWeightKg']?.toDouble()
      ..weightChangePace = json['weightChangePace']
      ..workoutDaysPerWeek = json['workoutDaysPerWeek'];
  }
}
