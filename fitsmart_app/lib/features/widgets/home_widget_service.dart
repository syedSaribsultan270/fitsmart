import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';
import '../../services/analytics_service.dart';

/// Writes data to the native home-screen widget and signals it to refresh.
///
/// iOS:  Reads from shared UserDefaults (App Group: group.com.fitsmart.widget)
/// Android: Reads from SharedPreferences via home_widget provider
///
/// Call [update] after any meal, workout, or water log.
class HomeWidgetService {
  HomeWidgetService._();
  static final instance = HomeWidgetService._();

  static const _appGroupId = 'group.com.fitsmart.widget';
  static const _iosWidgetName = 'FitSmartWidget';
  static const _androidWidgetName =
      'com.fitsmart.fitsmart_app.FitSmartWidgetProvider';

  bool _initialized = false;

  Future<void> init() async {
    if (kIsWeb) return;
    try {
      await HomeWidget.setAppGroupId(_appGroupId);
      _initialized = true;
    } catch (e) {
      debugPrint('[HomeWidget] init failed: $e');
    }
  }

  /// Push fresh data to the widget and request a UI refresh.
  ///
  /// [caloriesConsumed] — kcal eaten today.
  /// [caloriesGoal]    — daily kcal target.
  /// [proteinG], [carbsG], [fatG] — today's macros.
  /// [streakDays]      — current logging streak.
  Future<void> update({
    required int caloriesConsumed,
    required int caloriesGoal,
    required int proteinG,
    required int carbsG,
    required int fatG,
    required int streakDays,
  }) async {
    if (!_initialized || kIsWeb) return;
    try {
      final remaining = (caloriesGoal - caloriesConsumed).clamp(0, caloriesGoal);
      final pct = caloriesGoal > 0
          ? ((caloriesConsumed / caloriesGoal) * 100).round().clamp(0, 100)
          : 0;

      await Future.wait([
        HomeWidget.saveWidgetData('calories_consumed', caloriesConsumed),
        HomeWidget.saveWidgetData('calories_goal', caloriesGoal),
        HomeWidget.saveWidgetData('calories_remaining', remaining),
        HomeWidget.saveWidgetData('calories_pct', pct),
        HomeWidget.saveWidgetData('protein_g', proteinG),
        HomeWidget.saveWidgetData('carbs_g', carbsG),
        HomeWidget.saveWidgetData('fat_g', fatG),
        HomeWidget.saveWidgetData('streak_days', streakDays),
        HomeWidget.saveWidgetData('updated_at',
            DateTime.now().toIso8601String().substring(0, 16)),
      ]);

      await HomeWidget.updateWidget(
        iOSName: _iosWidgetName,
        androidName: _androidWidgetName,
      );

      AnalyticsService.instance.track('home_widget_updated', props: {
        'calories_pct': pct,
        'streak': streakDays,
      });
    } catch (e) {
      debugPrint('[HomeWidget] update failed: $e');
    }
  }
}
