import 'package:flutter_test/flutter_test.dart';
import 'package:fitsmart_app/core/utils/meal_utils.dart';

void main() {
  group('mealEmoji', () {
    test('breakfast → 🌅', () {
      expect(mealEmoji('breakfast'), '🌅');
    });

    test('lunch → ☀️', () {
      expect(mealEmoji('lunch'), '☀️');
    });

    test('dinner → 🌙', () {
      expect(mealEmoji('dinner'), '🌙');
    });

    test('snack → 🍎', () {
      expect(mealEmoji('snack'), '🍎');
    });

    test('pre-workout → ⚡', () {
      expect(mealEmoji('pre-workout'), '⚡');
    });

    test('post-workout → 💪', () {
      expect(mealEmoji('post-workout'), '💪');
    });

    test('unknown type → 🍽️ (default)', () {
      expect(mealEmoji('brunch'), '🍽️');
    });

    test('case insensitivity: BREAKFAST → 🌅', () {
      expect(mealEmoji('BREAKFAST'), '🌅');
    });

    test('case insensitivity: Lunch → ☀️', () {
      expect(mealEmoji('Lunch'), '☀️');
    });

    test('case insensitivity: Pre-Workout → ⚡', () {
      expect(mealEmoji('Pre-Workout'), '⚡');
    });

    test('empty string → 🍽️ (default)', () {
      expect(mealEmoji(''), '🍽️');
    });
  });
}
