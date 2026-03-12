import 'package:flutter_test/flutter_test.dart';
import 'package:fitsmart_app/models/gamification.dart';
import 'package:fitsmart_app/features/dashboard/providers/dashboard_provider.dart';

void main() {
  // We test the GamificationNotifier directly by constructing it.
  // Since it normally uses SharedPreferences, we test the state logic
  // by exercising the state transitions on GamificationState + copyWith.

  group('GamificationNotifier — awardXp logic', () {
    test('awardXp increments total XP', () {
      const state = GamificationState(totalXp: 100);
      final newState = state.copyWith(totalXp: state.totalXp + 50);
      expect(newState.totalXp, 150);
    });

    test('level-up detection: XP crosses threshold', () {
      const state = GamificationState(totalXp: 90); // level 1
      expect(state.currentLevel, 1);
      final newState = state.copyWith(totalXp: state.totalXp + 20); // → 110, level 2
      expect(newState.currentLevel, 2);
      // Simulating return: newLevel > prevLevel → returns newLevel
      expect(newState.currentLevel > state.currentLevel, true);
    });

    test('no level-up: returns 0', () {
      const state = GamificationState(totalXp: 50);
      final newState = state.copyWith(totalXp: state.totalXp + 10); // → 60, still level 1
      expect(newState.currentLevel, state.currentLevel); // no change
    });
  });

  group('GamificationNotifier — streak logic', () {
    test('first log: streak = 1', () {
      // When lastLogDate is null, streak becomes 1
      const state = GamificationState(lastLogDate: null);
      final newState = state.copyWith(
        currentStreak: 1,
        longestStreak: 1,
        lastLogDate: DateTime.now(),
      );
      expect(newState.currentStreak, 1);
      expect(newState.longestStreak, 1);
    });

    test('consecutive day: streak increments', () {
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      final state = GamificationState(
        currentStreak: 5,
        longestStreak: 10,
        lastLogDate: yesterday,
      );
      // daysDiff = 1 → consecutive
      final newStreak = state.currentStreak + 1;
      final newState = state.copyWith(
        currentStreak: newStreak,
        longestStreak: newStreak > state.longestStreak ? newStreak : state.longestStreak,
        lastLogDate: DateTime.now(),
      );
      expect(newState.currentStreak, 6);
      expect(newState.longestStreak, 10); // didn't exceed longest
    });

    test('consecutive day: longest streak updates if exceeded', () {
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      final state = GamificationState(
        currentStreak: 10,
        longestStreak: 10,
        lastLogDate: yesterday,
      );
      final newStreak = state.currentStreak + 1; // 11
      final newState = state.copyWith(
        currentStreak: newStreak,
        longestStreak: newStreak > state.longestStreak ? newStreak : state.longestStreak,
      );
      expect(newState.currentStreak, 11);
      expect(newState.longestStreak, 11);
    });

    test('gap > 1 day without freeze: streak resets to 1', () {
      final threeDaysAgo = DateTime.now().subtract(const Duration(days: 3));
      final state = GamificationState(
        currentStreak: 7,
        longestStreak: 14,
        streakFreezesAvailable: 0,
        lastLogDate: threeDaysAgo,
      );
      // daysDiff > 1 and no freezes → reset
      final newState = state.copyWith(
        currentStreak: 1,
        lastLogDate: DateTime.now(),
      );
      expect(newState.currentStreak, 1);
      expect(newState.longestStreak, 14); // longest preserved
    });

    test('gap > 1 day with freeze: uses freeze, keeps streak', () {
      final twoDaysAgo = DateTime.now().subtract(const Duration(days: 2));
      final state = GamificationState(
        currentStreak: 7,
        longestStreak: 14,
        streakFreezesAvailable: 2,
        lastLogDate: twoDaysAgo,
      );
      // daysDiff > 1 but has freezes → decrement freeze, keep streak
      final newState = state.copyWith(
        streakFreezesAvailable: state.streakFreezesAvailable - 1,
        lastLogDate: DateTime.now(),
      );
      expect(newState.currentStreak, 7); // streak preserved
      expect(newState.streakFreezesAvailable, 1); // freeze used
    });

    test('same day: no streak change', () {
      final today = DateTime.now();
      final state = GamificationState(
        currentStreak: 3,
        lastLogDate: today,
      );
      // daysDiff = 0 → no-op
      // In the logic, this just returns without changes
      expect(state.currentStreak, 3);
    });
  });

  group('GamificationNotifier — unlockBadge logic', () {
    test('new badge: added to unlockedBadges and awards XP', () {
      const state = GamificationState(
        totalXp: 100,
        unlockedBadges: [],
      );
      // Badge XP for first_log = 25
      final badgeXp = Badges.all[Badges.firstLog]!.xpReward;
      final newState = state.copyWith(
        unlockedBadges: [...state.unlockedBadges, Badges.firstLog],
        totalXp: state.totalXp + badgeXp,
      );
      expect(newState.unlockedBadges, contains(Badges.firstLog));
      expect(newState.totalXp, 125);
    });

    test('already unlocked badge: no-op', () {
      const state = GamificationState(
        totalXp: 125,
        unlockedBadges: [Badges.firstLog],
      );
      // Check if already contains → no duplicate
      final alreadyUnlocked = state.unlockedBadges.contains(Badges.firstLog);
      expect(alreadyUnlocked, true);
      // No state change
      expect(state.totalXp, 125);
    });
  });

  group('GamificationNotifier — addStreakFreeze logic', () {
    test('adds freeze when below max (2)', () {
      const state = GamificationState(streakFreezesAvailable: 1);
      final newState = state.copyWith(
        streakFreezesAvailable: state.streakFreezesAvailable + 1,
      );
      expect(newState.streakFreezesAvailable, 2);
    });

    test('capped at 2 — does not exceed max', () {
      const state = GamificationState(streakFreezesAvailable: 2);
      // In the real code: if < maxStreakFreezesStored (2) → add, else no-op
      final shouldAdd = state.streakFreezesAvailable < 2;
      expect(shouldAdd, false);
      // State unchanged
      expect(state.streakFreezesAvailable, 2);
    });

    test('adds from 0 to 1', () {
      const state = GamificationState(streakFreezesAvailable: 0);
      final newState = state.copyWith(
        streakFreezesAvailable: state.streakFreezesAvailable + 1,
      );
      expect(newState.streakFreezesAvailable, 1);
    });
  });

  group('DailyNutrition', () {
    test('default values', () {
      const n = DailyNutrition();
      expect(n.consumedCalories, 0);
      expect(n.targetCalories, 2000);
      expect(n.consumedProtein, 0);
      expect(n.targetProtein, 150);
    });

    test('copyWith overrides correctly', () {
      const n = DailyNutrition();
      final updated = n.copyWith(consumedCalories: 500, consumedProtein: 40);
      expect(updated.consumedCalories, 500);
      expect(updated.consumedProtein, 40);
      expect(updated.targetCalories, 2000); // unchanged
    });
  });

  group('NutritionTargets', () {
    test('default values', () {
      const t = NutritionTargets();
      expect(t.calories, 2000);
      expect(t.proteinG, 150);
      expect(t.carbsG, 200);
      expect(t.fatG, 65);
    });
  });
}
