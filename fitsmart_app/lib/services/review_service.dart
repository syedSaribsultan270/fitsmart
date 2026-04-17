import 'package:in_app_review/in_app_review.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'analytics_service.dart';

/// Manages in-app review prompts.
///
/// Call [maybeRequestReview] at high-delight moments:
///  - After completing a workout
///  - When streak hits a milestone (7, 14, 30 days)
///  - After hitting all macro targets 3 days in a row
///
/// Enforces a minimum 60-day gap between requests so users aren't annoyed.
class ReviewService {
  ReviewService._();
  static final instance = ReviewService._();

  static const _prefsKey = 'review_last_requested_ms';
  static const _minDaysBetween = 60;

  final _review = InAppReview.instance;

  Future<void> maybeRequestReview({required String trigger}) async {
    try {
      if (!await _review.isAvailable()) return;

      final prefs = await SharedPreferences.getInstance();
      final lastMs = prefs.getInt(_prefsKey) ?? 0;
      final msSinceLast = DateTime.now().millisecondsSinceEpoch - lastMs;
      final daysSinceLast = msSinceLast / 86400000;

      if (daysSinceLast < _minDaysBetween) return;

      await _review.requestReview();
      await prefs.setInt(_prefsKey, DateTime.now().millisecondsSinceEpoch);

      AnalyticsService.instance.track('review_prompt_shown', props: {
        'trigger': trigger,
      });
    } catch (_) {
      // Never crash the app over a review prompt
    }
  }
}
