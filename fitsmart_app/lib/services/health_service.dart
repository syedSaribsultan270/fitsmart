import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:health/health.dart';
import 'analytics_service.dart';

/// Wraps the `health` package for reading Apple Health (iOS) and
/// Health Connect (Android) data.
///
/// iOS setup required (Xcode):
///   1. Add "HealthKit" capability in Runner target → Signing & Capabilities.
///   2. Add to Info.plist:
///        NSHealthShareUsageDescription → "FitSmart reads your health data…"
///        NSHealthUpdateUsageDescription → "FitSmart may write workout data…"
///
/// Android setup: Health Connect permissions are declared in AndroidManifest.xml.
/// Users must have Health Connect app installed (available Google Play).
class HealthService {
  HealthService._();
  static final instance = HealthService._();

  static final _readTypes = [
    HealthDataType.STEPS,
    HealthDataType.ACTIVE_ENERGY_BURNED,
    HealthDataType.WEIGHT,
  ];

  bool _authorized = false;

  // ── Permission ─────────────────────────────────────────────────

  Future<bool> requestPermission() async {
    if (kIsWeb) return false;
    if (!Platform.isIOS && !Platform.isAndroid) return false;

    AnalyticsService.instance.track('health_permission_requested', props: {
      'platform': Platform.isIOS ? 'ios' : 'android',
    });

    try {
      final health = Health();
      final permissions = List.filled(_readTypes.length, HealthDataAccess.READ);
      _authorized = await health.requestAuthorization(
        _readTypes,
        permissions: permissions,
      );
      AnalyticsService.instance.track(
        _authorized ? 'health_permission_granted' : 'health_permission_denied',
        props: {'types': _readTypes.map((t) => t.name).toList()},
      );
      return _authorized;
    } catch (e) {
      debugPrint('[Health] requestPermission failed: $e');
      AnalyticsService.instance.track('health_permission_denied');
      return false;
    }
  }

  bool get isAuthorized => _authorized;

  // ── Data reads ─────────────────────────────────────────────────

  /// Today's step count. Returns 0 on any error or when not authorized.
  Future<int> getStepsToday() async {
    if (kIsWeb || !_authorized) return 0;
    try {
      final health = Health();
      final now = DateTime.now();
      final midnight = DateTime(now.year, now.month, now.day);
      return await health.getTotalStepsInInterval(midnight, now) ?? 0;
    } catch (e) {
      debugPrint('[Health] getStepsToday failed: $e');
      return 0;
    }
  }

  /// Active energy burned today in kcal. Returns 0 on error.
  Future<double> getActiveCaloriesToday() async {
    if (kIsWeb || !_authorized) return 0;
    try {
      final health = Health();
      final now = DateTime.now();
      final midnight = DateTime(now.year, now.month, now.day);
      final data = await health.getHealthDataFromTypes(
        startTime: midnight,
        endTime: now,
        types: [HealthDataType.ACTIVE_ENERGY_BURNED],
      );
      return data.fold<double>(0, (sum, point) {
        final val = point.value;
        return sum +
            (val is NumericHealthValue ? val.numericValue.toDouble() : 0);
      });
    } catch (e) {
      debugPrint('[Health] getActiveCaloriesToday failed: $e');
      return 0;
    }
  }

  /// Most recent body weight in kg from the last 30 days. Returns null if none.
  Future<double?> getLatestWeight() async {
    if (kIsWeb || !_authorized) return null;
    try {
      final health = Health();
      final now = DateTime.now();
      final data = await health.getHealthDataFromTypes(
        startTime: now.subtract(const Duration(days: 30)),
        endTime: now,
        types: [HealthDataType.WEIGHT],
      );
      if (data.isEmpty) return null;
      data.sort((a, b) => b.dateFrom.compareTo(a.dateFrom));
      final val = data.first.value;
      return val is NumericHealthValue ? val.numericValue.toDouble() : null;
    } catch (e) {
      debugPrint('[Health] getLatestWeight failed: $e');
      return null;
    }
  }

  Future<void> syncToAnalytics() async {
    final steps = await getStepsToday();
    final cal = await getActiveCaloriesToday();
    if (steps > 0 || cal > 0) {
      AnalyticsService.instance.track('health_data_synced', props: {
        'steps': steps,
        'active_cal': cal.toStringAsFixed(0),
      });
    }
  }
}
