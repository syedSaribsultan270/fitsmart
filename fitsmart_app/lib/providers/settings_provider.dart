import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/app_constants.dart';
import '../services/firestore_service.dart';

/// Persisted app settings state.
class AppSettings {
  final bool isMetric;
  final bool notificationsEnabled;
  final bool weeklyReportEnabled;
  /// 1=Mon … 7=Sun. Defaults to Monday — fresh-start ritual.
  final int weeklyReviewWeekday;
  /// 0–23 local hour. Defaults to 6am — pre-day, low contention.
  final int weeklyReviewHour;
  final String displayName;
  final ThemeMode themeMode;
  final int? accentColorValue; // null = default lime

  const AppSettings({
    this.isMetric = true,
    this.notificationsEnabled = true,
    this.weeklyReportEnabled = true,
    this.weeklyReviewWeekday = AppConstants.defaultWeeklyReviewWeekday,
    this.weeklyReviewHour = AppConstants.defaultWeeklyReviewHour,
    this.displayName = 'FitSmart User',
    this.themeMode = ThemeMode.dark,
    this.accentColorValue,
  });

  Color? get accentColor =>
      accentColorValue != null ? Color(accentColorValue!) : null;

  AppSettings copyWith({
    bool? isMetric,
    bool? notificationsEnabled,
    bool? weeklyReportEnabled,
    int? weeklyReviewWeekday,
    int? weeklyReviewHour,
    String? displayName,
    ThemeMode? themeMode,
    int? accentColorValue,
    bool clearAccent = false,
  }) {
    return AppSettings(
      isMetric: isMetric ?? this.isMetric,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      weeklyReportEnabled: weeklyReportEnabled ?? this.weeklyReportEnabled,
      weeklyReviewWeekday: weeklyReviewWeekday ?? this.weeklyReviewWeekday,
      weeklyReviewHour: weeklyReviewHour ?? this.weeklyReviewHour,
      displayName: displayName ?? this.displayName,
      themeMode: themeMode ?? this.themeMode,
      accentColorValue:
          clearAccent ? null : (accentColorValue ?? this.accentColorValue),
    );
  }

  Map<String, dynamic> toJson() => {
        'isMetric': isMetric,
        'notificationsEnabled': notificationsEnabled,
        'weeklyReportEnabled': weeklyReportEnabled,
        'weeklyReviewWeekday': weeklyReviewWeekday,
        'weeklyReviewHour': weeklyReviewHour,
        'displayName': displayName,
        'themeMode': themeMode.index,
        'accentColorValue': accentColorValue,
      };

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      isMetric: json['isMetric'] ?? true,
      notificationsEnabled: json['notificationsEnabled'] ?? true,
      weeklyReportEnabled: json['weeklyReportEnabled'] ?? true,
      weeklyReviewWeekday: (json['weeklyReviewWeekday'] as num?)?.toInt()
          ?? AppConstants.defaultWeeklyReviewWeekday,
      weeklyReviewHour: (json['weeklyReviewHour'] as num?)?.toInt()
          ?? AppConstants.defaultWeeklyReviewHour,
      displayName: json['displayName'] ?? 'FitSmart User',
      themeMode: ThemeMode
              .values
              .elementAtOrNull(json['themeMode'] as int? ?? 2) ??
          ThemeMode.dark,
      accentColorValue: json['accentColorValue'] as int?,
    );
  }
}

class SettingsNotifier extends StateNotifier<AppSettings> {
  SettingsNotifier() : super(const AppSettings()) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString('app_settings');
    if (json != null) {
      state = AppSettings.fromJson(jsonDecode(json));
      return;
    }
    // SharedPrefs cold (new device/browser) — try Firestore.
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      try {
        final remote = await FirestoreService.getSettings(uid);
        if (remote != null) {
          state = AppSettings.fromJson(remote);
          await prefs.setString('app_settings', jsonEncode(state.toJson()));
        }
      } catch (_) {}
    }
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('app_settings', jsonEncode(state.toJson()));
    // Mirror to Firestore so settings roam across all devices/browsers.
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      FirestoreService.saveSettings(uid, state.toJson())
          .catchError((e) => debugPrint('[Settings] Firestore sync failed: $e'));
    }
  }

  Future<void> setMetric(bool isMetric) async {
    state = state.copyWith(isMetric: isMetric);
    await _save();
  }

  Future<void> setNotifications(bool enabled) async {
    state = state.copyWith(notificationsEnabled: enabled);
    await _save();
  }

  Future<void> setWeeklyReport(bool enabled) async {
    state = state.copyWith(weeklyReportEnabled: enabled);
    await _save();
  }

  /// [weekday]: 1=Mon … 7=Sun. [hour]: 0–23 local.
  Future<void> setWeeklyReviewSchedule({
    required int weekday,
    required int hour,
  }) async {
    state = state.copyWith(
      weeklyReviewWeekday: weekday.clamp(1, 7),
      weeklyReviewHour: hour.clamp(0, 23),
    );
    await _save();
  }

  Future<void> setDisplayName(String name) async {
    state = state.copyWith(displayName: name);
    await _save();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = state.copyWith(themeMode: mode);
    await _save();
  }

  Future<void> setAccentColor(Color? color) async {
    if (color == null) {
      state = state.copyWith(clearAccent: true);
    } else {
      state = state.copyWith(accentColorValue: color.toARGB32());
    }
    await _save();
  }
}

final settingsProvider =
    StateNotifierProvider<SettingsNotifier, AppSettings>(
  (ref) => SettingsNotifier(),
);
