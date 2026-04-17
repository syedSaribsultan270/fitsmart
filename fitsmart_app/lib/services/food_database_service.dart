import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../core/constants/app_constants.dart';
import 'analytics_service.dart';

/// Nutritional data for one food item, expressed per 100 g.
/// Call [scaledTo] to get values for a custom serving size.
class FoodItem {
  final String name;
  final double caloriesPer100g;
  final double proteinPer100g;
  final double carbsPer100g;
  final double fatPer100g;
  final double fiberPer100g;

  const FoodItem({
    required this.name,
    required this.caloriesPer100g,
    required this.proteinPer100g,
    required this.carbsPer100g,
    required this.fatPer100g,
    this.fiberPer100g = 0,
  });

  /// Returns a [FoodItem] whose values are scaled to [grams] grams.
  FoodItem scaledTo(double grams) {
    final factor = grams / 100;
    return FoodItem(
      name: name,
      caloriesPer100g: caloriesPer100g * factor,
      proteinPer100g: proteinPer100g * factor,
      carbsPer100g: carbsPer100g * factor,
      fatPer100g: fatPer100g * factor,
      fiberPer100g: fiberPer100g * factor,
    );
  }

  /// Convert to the `_analysisResult` map format used by LogMealScreen.
  Map<String, dynamic> toResultMap({
    String feedback = 'Logged from barcode scan.',
  }) =>
      {
        'name': name,
        'calories': caloriesPer100g,
        'protein_g': proteinPer100g,
        'carbs_g': carbsPer100g,
        'fat_g': fatPer100g,
        'fiber_g': fiberPer100g,
        'health_score': 70,
        'feedback': feedback,
        'items': <dynamic>[],
      };
}

/// Looks up nutritional data from the Open Food Facts public API.
/// Caches successful lookups in memory for the app session.
class FoodDatabaseService {
  FoodDatabaseService._();
  static final instance = FoodDatabaseService._();

  final Map<String, FoodItem?> _cache = {};

  /// Fetches food data for [barcode]. Returns null if not found or on error.
  Future<FoodItem?> fetchByBarcode(String barcode) async {
    if (_cache.containsKey(barcode)) return _cache[barcode];

    try {
      final uri = Uri.parse(
        '${AppConstants.openFoodFactsBaseUrl}/api/v2/product/$barcode.json'
        '?fields=product_name,nutriments',
      );
      final response = await http.get(
        uri,
        headers: {'User-Agent': 'FitSmartApp/1.0'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        _cache[barcode] = null;
        AnalyticsService.instance.track('barcode_scan_not_found',
            props: {'barcode': barcode});
        return null;
      }

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      if ((json['status'] as int?) != 1) {
        _cache[barcode] = null;
        AnalyticsService.instance.track('barcode_scan_not_found',
            props: {'barcode': barcode});
        return null;
      }

      final product = (json['product'] as Map<String, dynamic>?) ?? {};
      final nutriments = (product['nutriments'] as Map<String, dynamic>?) ?? {};

      final name = (product['product_name'] as String?)?.trim() ?? '';
      if (name.isEmpty) {
        _cache[barcode] = null;
        return null;
      }

      final item = FoodItem(
        name: name,
        caloriesPer100g:
            (nutriments['energy-kcal_100g'] as num?)?.toDouble() ?? 0,
        proteinPer100g:
            (nutriments['proteins_100g'] as num?)?.toDouble() ?? 0,
        carbsPer100g:
            (nutriments['carbohydrates_100g'] as num?)?.toDouble() ?? 0,
        fatPer100g: (nutriments['fat_100g'] as num?)?.toDouble() ?? 0,
        fiberPer100g: (nutriments['fiber_100g'] as num?)?.toDouble() ?? 0,
      );

      _cache[barcode] = item;
      AnalyticsService.instance.track('barcode_scan_success', props: {
        'barcode': barcode,
        'product_name': name,
        'found_in_db': true,
      });
      return item;
    } catch (e) {
      debugPrint('[FoodDB] fetchByBarcode error: $e');
      _cache[barcode] = null;
      AnalyticsService.instance.track('barcode_scan_not_found',
          props: {'barcode': barcode});
      return null;
    }
  }
}
