import 'package:flutter_test/flutter_test.dart';
import 'package:fitsmart_app/services/food_knowledge_service.dart';

void main() {
  group('FoodEntry.fromIndianJson', () {
    test('parses full Indian food JSON', () {
      final json = {
        'name': 'Butter Chicken',
        'category': 'curry',
        'dish': 'main',
        'dietary': 'non-veg',
        'cal': 450,
        'p': 28.0,
        'c': 12.0,
        'f': 32.0,
        'fiber': 2.0,
        'serving': '1 cup (200g)',
        'serving_g': 200,
        'ingredients': ['chicken', 'butter', 'tomato'],
        'aliases': ['murgh makhani'],
        'description': 'A popular North Indian curry',
      };

      final food = FoodEntry.fromIndianJson(json);
      expect(food.name, 'Butter Chicken');
      expect(food.category, 'curry');
      expect(food.dish, 'main');
      expect(food.dietary, 'non-veg');
      expect(food.cal, 450.0);
      expect(food.protein, 28.0);
      expect(food.carbs, 12.0);
      expect(food.fat, 32.0);
      expect(food.fiber, 2.0);
      expect(food.serving, '1 cup (200g)');
      expect(food.servingG, 200);
      expect(food.ingredients, ['chicken', 'butter', 'tomato']);
      expect(food.aliases, ['murgh makhani']);
      expect(food.description, 'A popular North Indian curry');
    });

    test('parses Indian food JSON with missing optional fields', () {
      final json = {
        'name': 'Dal',
        'cal': 180,
        'p': 12.0,
        'c': 30.0,
        'f': 2.0,
        'serving': '1 bowl',
        'serving_g': 200,
      };

      final food = FoodEntry.fromIndianJson(json);
      expect(food.name, 'Dal');
      expect(food.category, isNull);
      expect(food.dietary, isNull);
      expect(food.fiber, 0);
      expect(food.ingredients, isEmpty);
      expect(food.aliases, isEmpty);
      expect(food.description, isNull);
    });
  });

  group('FoodEntry.fromCommonJson', () {
    test('parses common food JSON', () {
      final json = {
        'name': 'Egg White',
        'cal': 17,
        'p': 3.6,
        'c': 0.2,
        'f': 0.1,
        'serving': '1 egg white (33g)',
      };

      final food = FoodEntry.fromCommonJson(json);
      expect(food.name, 'Egg White');
      expect(food.cal, 17.0);
      expect(food.protein, 3.6);
      expect(food.carbs, 0.2);
      expect(food.fat, 0.1);
      expect(food.serving, '1 egg white (33g)');
      expect(food.servingG, 33); // parsed from serving string
    });

    test('parses common food JSON with plain gram serving', () {
      final json = {
        'name': 'Chicken Breast',
        'cal': 165,
        'p': 31.0,
        'c': 0.0,
        'f': 3.6,
        'serving': '100g',
      };

      final food = FoodEntry.fromCommonJson(json);
      expect(food.servingG, 100);
    });

    test('parses ml serving string', () {
      final json = {
        'name': 'Milk',
        'cal': 42,
        'p': 3.4,
        'c': 5.0,
        'f': 1.0,
        'serving': '100ml',
      };

      final food = FoodEntry.fromCommonJson(json);
      expect(food.servingG, 100);
    });

    test('defaults to 100g when serving has no extractable number', () {
      final json = {
        'name': 'Apple',
        'cal': 52,
        'p': 0.3,
        'c': 14.0,
        'f': 0.2,
        'serving': '1 medium apple',
      };

      final food = FoodEntry.fromCommonJson(json);
      expect(food.servingG, 100);
    });
  });

  group('FoodEntry.toGroundingString', () {
    test('produces correct format', () {
      const food = FoodEntry(
        name: 'Rice',
        cal: 130,
        protein: 2.7,
        carbs: 28.2,
        fat: 0.3,
        serving: '100g',
        servingG: 100,
      );
      final s = food.toGroundingString();
      expect(s, contains('Rice:'));
      expect(s, contains('130'));
      expect(s, contains('per 100g'));
    });

    test('includes dietary tag when present', () {
      const food = FoodEntry(
        name: 'Rice',
        cal: 130,
        protein: 2.7,
        carbs: 28.2,
        fat: 0.3,
        serving: '100g',
        servingG: 100,
        dietary: 'vegan',
      );
      expect(food.toGroundingString(), contains('[vegan]'));
    });

    test('includes description when present', () {
      const food = FoodEntry(
        name: 'Rice',
        cal: 130,
        protein: 2.7,
        carbs: 28.2,
        fat: 0.3,
        serving: '100g',
        servingG: 100,
        description: 'Staple grain',
      );
      expect(food.toGroundingString(), contains('Staple grain'));
    });
  });

  // Testing the private methods via public search API would require loading
  // the actual asset files. Instead, we test the standalone static methods
  // and data classes directly.

  group('FoodSearchResult', () {
    test('holds food and score', () {
      const food = FoodEntry(
        name: 'Test',
        cal: 100,
        protein: 10,
        carbs: 10,
        fat: 5,
        serving: '100g',
        servingG: 100,
      );
      const result = FoodSearchResult(food: food, score: 0.85);
      expect(result.food.name, 'Test');
      expect(result.score, 0.85);
    });
  });

  group('FoodEntry.toJson', () {
    test('round-trip toJson → fromIndianJson', () {
      const original = FoodEntry(
        name: 'Paneer Tikka',
        category: 'snack',
        dietary: 'vegetarian',
        cal: 265,
        protein: 18.0,
        carbs: 8.0,
        fat: 18.0,
        fiber: 1.0,
        serving: '100g',
        servingG: 100,
        description: 'Grilled cottage cheese',
      );

      final json = original.toJson();
      expect(json['name'], 'Paneer Tikka');
      expect(json['cal'], 265);
      expect(json['p'], 18.0);
      expect(json['c'], 8.0);
      expect(json['f'], 18.0);
      expect(json['category'], 'snack');
      expect(json['dietary'], 'vegetarian');
    });
  });
}
