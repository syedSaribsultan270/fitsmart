import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persisted app settings state.
class AppSettings {
  final bool isMetric;
  final bool notificationsEnabled;
  final bool weeklyReportEnabled;
  final String displayName;
  final ThemeMode themeMode;
  final int? accentColorValue; // null = default lime

  const AppSettings({
    this.isMetric = true,
    this.notificationsEnabled = true,
    this.weeklyReportEnabled = false,
    this.displayName = 'FitSmart User',
    this.themeMode = ThemeMode.system,
    this.accentColorValue,
  });

  Color? get accentColor =>
      accentColorValue != null ? Color(accentColorValue!) : null;

  AppSettings copyWith({
    bool? isMetric,
    bool? notificationsEnabled,
    bool? weeklyReportEnabled,
    String? displayName,
    ThemeMode? themeMode,
    int? accentColorValue,
    bool clearAccent = false,
  }) {
    return AppSettings(
      isMetric: isMetric ?? this.isMetric,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      weeklyReportEnabled: weeklyReportEnabled ?? this.weeklyReportEnabled,
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
        'displayName': displayName,
        'themeMode': themeMode.index,
        'accentColorValue': accentColorValue,
      };

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      isMetric: json['isMetric'] ?? true,
      notificationsEnabled: json['notificationsEnabled'] ?? true,
      weeklyReportEnabled: json['weeklyReportEnabled'] ?? false,
      displayName: json['displayName'] ?? 'FitSmart User',
      themeMode: ThemeMode
              .values
              .elementAtOrNull(json['themeMode'] as int? ?? 0) ??
          ThemeMode.system,
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
    }
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('app_settings', jsonEncode(state.toJson()));
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
