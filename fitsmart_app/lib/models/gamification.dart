import '../core/constants/app_constants.dart';

class GamificationState {
  final int totalXp;
  final int currentStreak;
  final int longestStreak;
  final int streakFreezesAvailable;
  final List<String> unlockedBadges;
  final DateTime? lastLogDate;

  const GamificationState({
    this.totalXp = 0,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.streakFreezesAvailable = 0,
    this.unlockedBadges = const [],
    this.lastLogDate,
  });

  int get currentLevel {
    for (int i = AppConstants.levelThresholds.length - 1; i >= 0; i--) {
      if (totalXp >= AppConstants.levelThresholds[i]) return i + 1;
    }
    return 1;
  }

  String get levelName {
    final idx = currentLevel - 1;
    return idx < AppConstants.levelNames.length
        ? AppConstants.levelNames[idx]
        : 'FitSmart';
  }

  double get levelProgress {
    final level = currentLevel - 1;
    if (level >= AppConstants.levelThresholds.length - 1) return 1.0;
    final currentThreshold = AppConstants.levelThresholds[level];
    final nextThreshold = AppConstants.levelThresholds[level + 1];
    return (totalXp - currentThreshold) / (nextThreshold - currentThreshold);
  }

  int get xpToNextLevel {
    final level = currentLevel - 1;
    if (level >= AppConstants.levelThresholds.length - 1) return 0;
    return AppConstants.levelThresholds[level + 1] - totalXp;
  }

  GamificationState copyWith({
    int? totalXp,
    int? currentStreak,
    int? longestStreak,
    int? streakFreezesAvailable,
    List<String>? unlockedBadges,
    DateTime? lastLogDate,
  }) {
    return GamificationState(
      totalXp: totalXp ?? this.totalXp,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      streakFreezesAvailable:
          streakFreezesAvailable ?? this.streakFreezesAvailable,
      unlockedBadges: unlockedBadges ?? this.unlockedBadges,
      lastLogDate: lastLogDate ?? this.lastLogDate,
    );
  }

  Map<String, dynamic> toJson() => {
        'totalXp': totalXp,
        'currentStreak': currentStreak,
        'longestStreak': longestStreak,
        'streakFreezesAvailable': streakFreezesAvailable,
        'unlockedBadges': unlockedBadges,
        'lastLogDate': lastLogDate?.toIso8601String(),
      };

  factory GamificationState.fromJson(Map<String, dynamic> json) {
    return GamificationState(
      totalXp: json['totalXp'] ?? 0,
      currentStreak: json['currentStreak'] ?? 0,
      longestStreak: json['longestStreak'] ?? 0,
      streakFreezesAvailable: json['streakFreezesAvailable'] ?? 0,
      unlockedBadges: (json['unlockedBadges'] as List?)?.cast<String>() ?? [],
      lastLogDate: json['lastLogDate'] != null
          ? DateTime.parse(json['lastLogDate'])
          : null,
    );
  }
}

/// All badge IDs
abstract class Badges {
  static const firstLog = 'first_log';
  static const streak7 = 'streak_7';
  static const streak30 = 'streak_30';
  static const streak100 = 'streak_100';
  static const proteinKing = 'protein_king';
  static const macroMaster = 'macro_master';
  static const prCrusher = 'pr_crusher';
  static const aiFoodie = 'ai_foodie';
  static const planner = 'planner';
  static const gymRat = 'gym_rat';

  static const Map<String, BadgeInfo> all = {
    firstLog: BadgeInfo(
      id: firstLog,
      name: 'First Log',
      description: 'Logged your first meal',
      icon: '🥗',
      xpReward: 25,
    ),
    streak7: BadgeInfo(
      id: streak7,
      name: '7-Day Streak',
      description: 'Logged every day for a week',
      icon: '🔥',
      xpReward: 50,
    ),
    streak30: BadgeInfo(
      id: streak30,
      name: '30-Day Streak',
      description: 'Logged every day for a month',
      icon: '⚡',
      xpReward: 200,
    ),
    streak100: BadgeInfo(
      id: streak100,
      name: '100-Day Streak',
      description: '100 consecutive days of logging',
      icon: '👑',
      xpReward: 500,
    ),
    proteinKing: BadgeInfo(
      id: proteinKing,
      name: 'Protein King',
      description: 'Hit protein target 7 days in a row',
      icon: '💪',
      xpReward: 100,
    ),
    macroMaster: BadgeInfo(
      id: macroMaster,
      name: 'Macro Master',
      description: 'Hit all macros 3 days straight',
      icon: '🎯',
      xpReward: 75,
    ),
    prCrusher: BadgeInfo(
      id: prCrusher,
      name: 'PR Crusher',
      description: '5 personal records in one month',
      icon: '🏆',
      xpReward: 150,
    ),
    aiFoodie: BadgeInfo(
      id: aiFoodie,
      name: 'AI Foodie',
      description: '100 AI meal analyses',
      icon: '🤖',
      xpReward: 100,
    ),
    planner: BadgeInfo(
      id: planner,
      name: 'The Planner',
      description: 'Completed a full weekly meal plan',
      icon: '📋',
      xpReward: 75,
    ),
    gymRat: BadgeInfo(
      id: gymRat,
      name: 'Gym Rat',
      description: '20 workouts in a single month',
      icon: '🐀',
      xpReward: 150,
    ),
  };
}

class BadgeInfo {
  final String id;
  final String name;
  final String description;
  final String icon;
  final int xpReward;

  const BadgeInfo({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.xpReward,
  });
}
