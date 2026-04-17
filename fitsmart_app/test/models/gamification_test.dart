import 'package:flutter_test/flutter_test.dart';
import 'package:fitsmart_app/models/gamification.dart';

void main() {
  group('GamificationState.currentLevel', () {
    // levelThresholds = [0, 100, 300, 600, 1000, 1500, 2200, 3000]
    test('0 XP → level 1', () {
      const state = GamificationState(totalXp: 0);
      expect(state.currentLevel, 1);
    });

    test('50 XP → level 1', () {
      const state = GamificationState(totalXp: 50);
      expect(state.currentLevel, 1);
    });

    test('100 XP → level 2', () {
      const state = GamificationState(totalXp: 100);
      expect(state.currentLevel, 2);
    });

    test('299 XP → level 2', () {
      const state = GamificationState(totalXp: 299);
      expect(state.currentLevel, 2);
    });

    test('300 XP → level 3', () {
      const state = GamificationState(totalXp: 300);
      expect(state.currentLevel, 3);
    });

    test('600 XP → level 4', () {
      const state = GamificationState(totalXp: 600);
      expect(state.currentLevel, 4);
    });

    test('1000 XP → level 5', () {
      const state = GamificationState(totalXp: 1000);
      expect(state.currentLevel, 5);
    });

    test('1500 XP → level 6', () {
      const state = GamificationState(totalXp: 1500);
      expect(state.currentLevel, 6);
    });

    test('2200 XP → level 7', () {
      const state = GamificationState(totalXp: 2200);
      expect(state.currentLevel, 7);
    });

    test('3000 XP → level 8 (max)', () {
      const state = GamificationState(totalXp: 3000);
      expect(state.currentLevel, 8);
    });

    test('9999 XP → still level 8', () {
      const state = GamificationState(totalXp: 9999);
      expect(state.currentLevel, 8);
    });
  });

  group('GamificationState.levelName', () {
    // levelNames = ['Rookie', 'Grinder', 'Hustler', 'Achiever', 'Warrior', 'Beast', 'Legend', 'FitSmart']
    test('level 1 = Rookie', () {
      const state = GamificationState(totalXp: 0);
      expect(state.levelName, 'Rookie');
    });

    test('level 2 = Grinder', () {
      const state = GamificationState(totalXp: 100);
      expect(state.levelName, 'Grinder');
    });

    test('level 3 = Hustler', () {
      const state = GamificationState(totalXp: 300);
      expect(state.levelName, 'Hustler');
    });

    test('level 4 = Achiever', () {
      const state = GamificationState(totalXp: 600);
      expect(state.levelName, 'Achiever');
    });

    test('level 5 = Warrior', () {
      const state = GamificationState(totalXp: 1000);
      expect(state.levelName, 'Warrior');
    });

    test('level 6 = Beast', () {
      const state = GamificationState(totalXp: 1500);
      expect(state.levelName, 'Beast');
    });

    test('level 7 = Legend', () {
      const state = GamificationState(totalXp: 2200);
      expect(state.levelName, 'Legend');
    });

    test('level 8 = FitSmart', () {
      const state = GamificationState(totalXp: 3000);
      expect(state.levelName, 'FitSmart');
    });
  });

  group('GamificationState.levelProgress', () {
    test('0 XP at level 1 → progress 0.0', () {
      const state = GamificationState(totalXp: 0);
      expect(state.levelProgress, closeTo(0.0, 0.001));
    });

    test('50 XP at level 1 → 50% progress (0→100 range)', () {
      const state = GamificationState(totalXp: 50);
      expect(state.levelProgress, closeTo(0.5, 0.001));
    });

    test('at max level (3000+ XP) → progress 1.0', () {
      const state = GamificationState(totalXp: 3000);
      expect(state.levelProgress, 1.0);
    });

    test('at max level (5000 XP) → still 1.0', () {
      const state = GamificationState(totalXp: 5000);
      expect(state.levelProgress, 1.0);
    });

    test('progress is between 0.0 and 1.0 for mid-level', () {
      const state = GamificationState(totalXp: 450); // level 3 (300→600)
      // (450-300) / (600-300) = 150/300 = 0.5
      expect(state.levelProgress, closeTo(0.5, 0.001));
    });
  });

  group('GamificationState.xpToNextLevel', () {
    test('0 XP → 100 to next', () {
      const state = GamificationState(totalXp: 0);
      expect(state.xpToNextLevel, 100);
    });

    test('50 XP → 50 to next', () {
      const state = GamificationState(totalXp: 50);
      expect(state.xpToNextLevel, 50);
    });

    test('100 XP → 200 to level 3 (threshold = 300)', () {
      const state = GamificationState(totalXp: 100);
      expect(state.xpToNextLevel, 200);
    });

    test('max level returns 0', () {
      const state = GamificationState(totalXp: 3000);
      expect(state.xpToNextLevel, 0);
    });

    test('above max XP returns 0', () {
      const state = GamificationState(totalXp: 5000);
      expect(state.xpToNextLevel, 0);
    });
  });

  group('GamificationState JSON serialization', () {
    test('round-trip: toJson → fromJson preserves all fields', () {
      final original = GamificationState(
        totalXp: 1250,
        currentStreak: 7,
        longestStreak: 14,
        streakFreezesAvailable: 2,
        unlockedBadges: ['first_log', 'streak_7'],
        lastLogDate: DateTime(2025, 3, 1, 10, 30),
      );

      final json = original.toJson();
      final restored = GamificationState.fromJson(json);

      expect(restored.totalXp, 1250);
      expect(restored.currentStreak, 7);
      expect(restored.longestStreak, 14);
      expect(restored.streakFreezesAvailable, 2);
      expect(restored.unlockedBadges, ['first_log', 'streak_7']);
      expect(restored.lastLogDate, isNotNull);
      expect(restored.lastLogDate!.year, 2025);
    });

    test('fromJson with missing fields uses defaults', () {
      final state = GamificationState.fromJson({});
      expect(state.totalXp, 0);
      expect(state.currentStreak, 0);
      expect(state.longestStreak, 0);
      expect(state.streakFreezesAvailable, 0);
      expect(state.unlockedBadges, isEmpty);
      expect(state.lastLogDate, isNull);
    });

    test('fromJson with null unlockedBadges defaults to empty list', () {
      final state = GamificationState.fromJson({'unlockedBadges': null});
      expect(state.unlockedBadges, isEmpty);
    });

    test('fromJson with null lastLogDate defaults to null', () {
      final state = GamificationState.fromJson({'lastLogDate': null});
      expect(state.lastLogDate, isNull);
    });
  });

  group('GamificationState.copyWith', () {
    test('preserves values when no arguments provided', () {
      final original = GamificationState(
        totalXp: 500,
        currentStreak: 3,
        longestStreak: 10,
        streakFreezesAvailable: 1,
        unlockedBadges: ['first_log'],
        lastLogDate: DateTime(2025, 1, 1),
      );
      final copy = original.copyWith();
      expect(copy.totalXp, 500);
      expect(copy.currentStreak, 3);
      expect(copy.longestStreak, 10);
      expect(copy.streakFreezesAvailable, 1);
      expect(copy.unlockedBadges, ['first_log']);
    });

    test('overrides specified fields', () {
      const original = GamificationState(totalXp: 500);
      final copy = original.copyWith(totalXp: 1000, currentStreak: 5);
      expect(copy.totalXp, 1000);
      expect(copy.currentStreak, 5);
      expect(copy.longestStreak, 0); // not overridden
    });
  });

  group('Badges', () {
    test('all badges map has 10 entries', () {
      expect(Badges.all.length, 10);
    });

    test('each badge has non-zero xpReward', () {
      for (final badge in Badges.all.values) {
        expect(badge.xpReward, greaterThan(0));
      }
    });

    test('badge IDs match map keys', () {
      for (final entry in Badges.all.entries) {
        expect(entry.key, entry.value.id);
      }
    });
  });
}
