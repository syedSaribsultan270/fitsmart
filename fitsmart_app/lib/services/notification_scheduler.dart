import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tzdata;
import '../core/constants/app_constants.dart';
import 'analytics_service.dart';
import 'notification_service.dart';

/// Schedules and cancels local notifications based on user preferences.
/// Call [rescheduleAll] after: enabling notifications, changing settings,
/// completing onboarding.
class NotificationScheduler {
  NotificationScheduler._();
  static final instance = NotificationScheduler._();

  static const _streakId = 1;
  static const _breakfastId = 2;
  static const _lunchId = 3;
  static const _dinnerId = 4;
  static const _weeklyId = 5;

  bool _tzReady = false;

  Future<void> _ensureTimezone() async {
    if (_tzReady) return;
    tzdata.initializeTimeZones();
    try {
      final name = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(name));
    } catch (_) {
      // Fallback: UTC is safe; notifications will fire at device-local time
      // but without DST awareness on some edge cases.
    }
    _tzReady = true;
  }

  // ── Public API ─────────────────────────────────────────────────

  /// Cancels all local notifications and reschedules based on [enabled].
  /// [weeklyReviewWeekday] (1=Mon..7=Sun) and [weeklyReviewHour] (0-23) control
  /// the weekly review notification — defaults to Monday 6am.
  Future<void> rescheduleAll({
    bool enabled = true,
    int weeklyReviewWeekday = AppConstants.defaultWeeklyReviewWeekday,
    int weeklyReviewHour = AppConstants.defaultWeeklyReviewHour,
  }) async {
    if (kIsWeb) return;
    await cancelAll();
    if (!enabled) return;

    await _ensureTimezone();
    await _scheduleStreakReminder();
    await _scheduleMealReminders();
    await _scheduleWeeklyRecap(
      weekday: weeklyReviewWeekday,
      hour: weeklyReviewHour,
    );

    AnalyticsService.instance.track('notification_scheduled', props: {
      'type': 'all',
      'count': 5,
    });
    debugPrint('[Notifications] Scheduled 5 local notifications.');
  }

  Future<void> cancelAll() async {
    if (kIsWeb) return;
    await NotificationService.instance.plugin.cancelAll();
    debugPrint('[Notifications] All notifications cancelled.');
  }

  // ── Individual schedulers ──────────────────────────────────────

  Future<void> _scheduleStreakReminder() async {
    // 10:00 PM daily — "Don't break your streak"
    await _scheduleDailyAt(
      id: _streakId,
      hour: 22,
      minute: 0,
      title: "Don't break your streak! 🔥",
      body: 'Log something today before midnight to keep it alive.',
      tag: 'streak_reminder',
    );
  }

  Future<void> _scheduleMealReminders() async {
    final meals = [
      (
        id: _breakfastId,
        hour: 8,
        minute: 0,
        title: 'Breakfast logged yet? 🥣',
        body: "Start your day right — log your first meal!",
      ),
      (
        id: _lunchId,
        hour: 12,
        minute: 30,
        title: "Haven't logged lunch? 🥗",
        body: 'Quick tap to log what you ate.',
      ),
      (
        id: _dinnerId,
        hour: 19,
        minute: 0,
        title: 'Dinner time! 🍽️',
        body: 'Log your dinner to stay on track with your goals.',
      ),
    ];

    for (final m in meals) {
      await _scheduleDailyAt(
        id: m.id,
        hour: m.hour,
        minute: m.minute,
        title: m.title,
        body: m.body,
        tag: 'meal_reminder',
      );
    }
  }

  Future<void> _scheduleWeeklyRecap({
    required int weekday,
    required int hour,
  }) async {
    final plugin = NotificationService.instance.plugin;
    final now = tz.TZDateTime.now(tz.local);
    var scheduled =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, 0);
    // Advance to next matching weekday (DateTime.monday=1 … sunday=7).
    while (scheduled.weekday != weekday || !scheduled.isAfter(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    await plugin.zonedSchedule(
      _weeklyId,
      'Your week in review 🏆',
      'See your wins, your stats, and pick one move for next week.',
      scheduled,
      _notifDetails('weekly_recap'),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      payload: '/weekly-review',
    );
  }

  // ── Helpers ────────────────────────────────────────────────────

  Future<void> _scheduleDailyAt({
    required int id,
    required int hour,
    required int minute,
    required String title,
    required String body,
    required String tag,
  }) async {
    if (!Platform.isIOS && !Platform.isAndroid) return;
    final plugin = NotificationService.instance.plugin;
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    await plugin.zonedSchedule(
      id,
      title,
      body,
      scheduled,
      _notifDetails(tag),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  NotificationDetails _notifDetails(String tag) => NotificationDetails(
        android: AndroidNotificationDetails(
          'fitsmart_main',
          'FitSmart Notifications',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
          tag: tag,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      );
}
