import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persisted app settings state.
class AppSettings {
  final bool isMetric;
  final bool notificationsEnabled;
  final bool weeklyReportEnabled;
  final String displayName;

  const AppSettings({
    this.isMetric = true,
    this.notificationsEnabled = true,
    this.weeklyReportEnabled = false,
    this.displayName = 'FitSmart User',
  });

  AppSettings copyWith({
    bool? isMetric,
    bool? notificationsEnabled,
    bool? weeklyReportEnabled,
    String? displayName,
  }) {
    return AppSettings(
      isMetric: isMetric ?? this.isMetric,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      weeklyReportEnabled: weeklyReportEnabled ?? this.weeklyReportEnabled,
      displayName: displayName ?? this.displayName,
    );
  }

  Map<String, dynamic> toJson() => {
        'isMetric': isMetric,
        'notificationsEnabled': notificationsEnabled,
        'weeklyReportEnabled': weeklyReportEnabled,
        'displayName': displayName,
      };

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      isMetric: json['isMetric'] ?? true,
      notificationsEnabled: json['notificationsEnabled'] ?? true,
      weeklyReportEnabled: json['weeklyReportEnabled'] ?? false,
      displayName: json['displayName'] ?? 'FitSmart User',
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
}

final settingsProvider =
    StateNotifierProvider<SettingsNotifier, AppSettings>(
  (ref) => SettingsNotifier(),
);
