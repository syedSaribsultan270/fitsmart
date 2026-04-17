import 'dart:async';
import 'dart:convert';
import 'dart:io' as io;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:path_provider/path_provider.dart';
import 'auth_service.dart';

/// Triple-sink analytics service.
///
/// Every call to [track] writes to THREE places simultaneously:
///
///  1. **Flutter terminal** (debug builds only) — instant, colour-coded,
///     formatted one-liner per event. Watch with `flutter run`.
///
///  2. **Local JSONL file** (debug builds, non-web only) — append-only, one
///     JSON object per line. Path is printed to terminal on startup.
///     Tail it: `tail -f <path>` or open in any text editor.
///
///  3. **Firestore `analytics_events`** — real-time, full fidelity, queryable.
///     Open Firebase Console → Firestore → `analytics_events`.
///
///  4. **Firebase Analytics** — dashboard, funnels (data delayed ~24 h).
///
/// Auth state (sign-in / sign-out) is monitored automatically — a detailed
/// block is printed to the terminal whenever the auth state changes.
///
/// ──────────────────────────────────────────────────────────────────
/// Setup: call [init] once in main() after Firebase.initializeApp().
/// ──────────────────────────────────────────────────────────────────
class AnalyticsService {
  AnalyticsService._();
  static final instance = AnalyticsService._();

  final _fa = FirebaseAnalytics.instance;
  final _db = FirebaseFirestore.instance;

  /// One random session ID per cold-start — groups all events from one run.
  final String _sessionId = _makeSessionId();

  io.File? _logFile;
  // ignore: unused_field
  StreamSubscription<User?>? _authSub;

  static String _makeSessionId() {
    final t = DateTime.now().millisecondsSinceEpoch;
    return t.toRadixString(16) +
        (t * 1000003 & 0xFFFFFF).toRadixString(16).padLeft(6, '0');
  }

  // ── Initialisation ────────────────────────────────────────────────

  /// Must be called once in main() after [Firebase.initializeApp].
  /// Sets up the local log file and starts listening for auth state changes.
  Future<void> init() async {
    if (kDebugMode && !kIsWeb) {
      try {
        final dir = await getApplicationDocumentsDirectory();
        _logFile = io.File('${dir.path}/analytics_debug.jsonl');
        _printBanner();
      } catch (_) {}
    } else if (kDebugMode) {
      _printBanner();
    }

    // Subscribe to Firebase Auth state — fires immediately with current state.
    _authSub = FirebaseAuth.instance.authStateChanges().listen(_onAuthState);
  }

  void _printBanner() {
    debugPrint('');
    debugPrint('╔══════════════════════════════════════════════════════╗');
    debugPrint('║            FITSMART ANALYTICS — DEBUG MODE           ║');
    debugPrint('╠══════════════════════════════════════════════════════╣');
    debugPrint('║  Session : $_sessionId');
    debugPrint('║  Platform: $_platform');
    if (_logFile != null) {
      debugPrint('║  Log file: ${_logFile!.path}');
      debugPrint('║  Tail it : tail -f "${_logFile!.path}"');
    }
    debugPrint('╚══════════════════════════════════════════════════════╝');
    debugPrint('');
  }

  // ── Auth State Monitoring ─────────────────────────────────────────

  void _onAuthState(User? user) {
    if (user == null) {
      _printAuthBlock(action: 'SIGNED OUT', user: null);
      // Don't track sign-out as a full event here — it's tracked by the UI.
    } else {
      _printAuthBlock(action: 'SIGNED IN', user: user);
      track('auth_state_changed', props: {
        'uid': user.uid,
        'action': 'sign_in',
        'is_anonymous': user.isAnonymous,
        'email': user.email ?? '',
        'display_name': user.displayName ?? '',
        'providers': user.providerData.map((p) => p.providerId).join(','),
        'email_verified': user.emailVerified,
      });
    }
  }

  void _printAuthBlock({required String action, required User? user}) {
    if (!kDebugMode) return;
    const divider = '══════════════════════════════════════════════════════';
    debugPrint('');
    debugPrint('╔$divider╗');
    debugPrint('║  [AUTH]  $action');
    debugPrint('╠$divider╣');
    if (user == null) {
      debugPrint('║  uid          : —');
      debugPrint('║  anonymous    : —');
      debugPrint('║  email        : —');
      debugPrint('║  display name : —');
      debugPrint('║  providers    : —');
      debugPrint('║  email verified: —');
    } else {
      final providers = user.providerData.map((p) => p.providerId).join(', ');
      debugPrint('║  uid          : ${user.uid}');
      debugPrint('║  anonymous    : ${user.isAnonymous}');
      debugPrint('║  email        : ${user.email ?? "—"}');
      debugPrint('║  display name : ${user.displayName ?? "—"}');
      debugPrint('║  providers    : ${providers.isEmpty ? "—" : providers}');
      debugPrint('║  email verified: ${user.emailVerified}');
    }
    debugPrint('╚$divider╝');
    debugPrint('');
  }

  // ── Core track() ─────────────────────────────────────────────────

  /// Log an analytics event to all sinks simultaneously.
  ///
  /// [event] must be snake_case. [props] can be anything JSON-serialisable.
  Future<void> track(String event, {Map<String, dynamic>? props}) async {
    final properties = props ?? const {};
    final now = DateTime.now();

    // ── 0. Terminal + local file (debug builds only) ───────────────
    if (kDebugMode) {
      _printEvent(event, properties, now);
      if (!kIsWeb) _appendToFile(event, properties, now);
    }

    // ── 1. Firestore (real-time, queryable) ────────────────────────
    try {
      await _db.collection('analytics_events').add({
        'user_id': _uid,
        'event': event,
        'ts': FieldValue.serverTimestamp(),
        'session': _sessionId,
        'platform': _platform,
        'props': properties,
      });
    } catch (e) {
      debugPrint('[ANA] ✕ Firestore write failed for "$event": $e');
    }

    // ── 2. Firebase Analytics (dashboard, delayed ~24 h) ───────────
    try {
      final faName = event.length > 40 ? event.substring(0, 40) : event;
      final faParams = <String, Object>{};
      properties.forEach((k, v) {
        if (v == null) return;
        final key = k.length > 40 ? k.substring(0, 40) : k;
        final val = v.toString();
        faParams[key] = val.length > 100 ? val.substring(0, 100) : val;
      });
      await _fa.logEvent(
        name: faName,
        parameters: faParams.isEmpty ? null : faParams,
      );
    } catch (e) {
      debugPrint('[ANA] ✕ Firebase Analytics failed for "$event": $e');
    }
  }

  // ── Terminal pretty-print ─────────────────────────────────────────

  void _printEvent(
      String event, Map<String, dynamic> props, DateTime ts) {
    final h = ts.hour.toString().padLeft(2, '0');
    final m = ts.minute.toString().padLeft(2, '0');
    final s = ts.second.toString().padLeft(2, '0');
    final ms = ts.millisecond.toString().padLeft(3, '0');
    final time = '$h:$m:$s.$ms';

    final uid = _uid;
    final shortUid = uid.length > 8 ? uid.substring(0, 8) : uid;
    final eventCol = event.padRight(30);

    if (props.isEmpty) {
      debugPrint('[ANA] $time  ▶ $eventCol  uid=$shortUid');
    } else {
      final propsStr =
          props.entries.map((e) => '${e.key}=${e.value}').join('  ');
      debugPrint('[ANA] $time  ▶ $eventCol  uid=$shortUid  $propsStr');
    }
  }

  // ── Local file append ─────────────────────────────────────────────

  void _appendToFile(
      String event, Map<String, dynamic> props, DateTime ts) {
    final file = _logFile;
    if (file == null) return;
    try {
      final line = jsonEncode({
        'ts': ts.toIso8601String(),
        'event': event,
        'uid': _uid,
        'session': _sessionId,
        'platform': _platform,
        'props': props,
      });
      file.writeAsStringSync(
        '$line\n',
        mode: io.FileMode.append,
        flush: true,
      );
    } catch (_) {}
  }

  // ── Helpers ───────────────────────────────────────────────────────

  String get _platform {
    if (kIsWeb) return 'web';
    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
        return 'ios';
      case TargetPlatform.android:
        return 'android';
      default:
        return defaultTargetPlatform.name;
    }
  }

  String get _uid =>
      AuthService.currentUser?.uid ??
      'pre_auth_${_sessionId.substring(0, 8)}';

  /// Track a UI tap / button press.
  /// [element] — snake_case name of what was tapped (e.g. 'log_meal_btn').
  /// [screen]  — which screen it's on (optional but very useful).
  void tap(String element, {String? screen, Map<String, dynamic>? props}) {
    track('tap', props: {
      'element': element,
      if (screen != null) 'screen': screen,
      ...?props,
    });
  }

  /// Track a setting change.
  void settingChanged(String setting, dynamic value, {String? screen}) {
    track('setting_changed', props: {
      'setting': setting,
      'value': value.toString(),
      if (screen != null) 'screen': screen,
    });
  }

  /// Track a tab switch.
  void tabSwitch(String tab, {required String screen, String? from}) {
    track('tab_switch', props: {
      'tab': tab,
      'screen': screen,
      if (from != null) 'from': from,
    });
  }

  /// Track a dialog open.
  void dialogOpened(String name, {String? screen}) {
    track('dialog_opened', props: {
      'dialog': name,
      if (screen != null) 'screen': screen,
    });
  }

  /// Track a dialog action (confirm / cancel / dismiss).
  void dialogAction(String name, String action, {String? screen}) {
    track('dialog_action', props: {
      'dialog': name,
      'action': action,
      if (screen != null) 'screen': screen,
    });
  }

  /// Call once after the user signs in so Firebase Analytics links events to
  /// a user identity.
  Future<void> setUserId(String uid) async {
    try {
      await _fa.setUserId(id: uid);
    } catch (e) {
      debugPrint('[ANA] setUserId failed: $e');
    }
  }

  /// Set user properties for segmentation in Firebase Analytics.
  /// Call after onboarding completes and on app start for returning users.
  ///
  /// [goalType]      — e.g. 'lose_fat', 'gain_muscle', 'recomp'
  /// [activityLevel] — e.g. 'sedentary', 'moderately_active'
  /// [dietType]      — e.g. 'omnivore', 'vegetarian', 'vegan', 'keto'
  /// [ageGroup]      — e.g. '18-24', '25-34', '35-44', '45-54', '55+'
  /// [gender]        — e.g. 'male', 'female', 'other'
  Future<void> setUserProperties({
    String? goalType,
    String? activityLevel,
    String? dietType,
    String? ageGroup,
    String? gender,
  }) async {
    try {
      if (goalType != null) await _fa.setUserProperty(name: 'goal_type', value: goalType);
      if (activityLevel != null) await _fa.setUserProperty(name: 'activity_level', value: activityLevel);
      if (dietType != null) await _fa.setUserProperty(name: 'diet_type', value: dietType);
      if (ageGroup != null) await _fa.setUserProperty(name: 'age_group', value: ageGroup);
      if (gender != null) await _fa.setUserProperty(name: 'gender', value: gender);
    } catch (e) {
      debugPrint('[ANA] setUserProperties failed: $e');
    }
  }

  /// Derive an age-group bucket string from a raw age integer.
  static String ageGroup(int age) {
    if (age < 25) return '18-24';
    if (age < 35) return '25-34';
    if (age < 45) return '35-44';
    if (age < 55) return '45-54';
    return '55+';
  }
}

// ── Navigation Observer ────────────────────────────────────────────────────

/// Attach to GoRouter's observers list.
/// Tracks every push/pop/replace with from→to route names.
class AnalyticsNavigatorObserver extends NavigatorObserver {
  // ignore: unused_field
  String? _current;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    final to = _name(route);
    final from = _name(previousRoute);
    _current = to;
    AnalyticsService.instance.track('nav_push', props: {
      'to': to,
      if (from != null) 'from': from,
    });
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    final from = _name(route);
    final to = _name(previousRoute);
    _current = to;
    AnalyticsService.instance.track('nav_pop', props: {
      'from': from ?? 'unknown',
      if (to != null) 'to': to,
    });
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    final to = _name(newRoute);
    final from = _name(oldRoute);
    _current = to;
    AnalyticsService.instance.track('nav_replace', props: {
      'to': to ?? 'unknown',
      if (from != null) 'from': from,
    });
  }

  String? _name(Route<dynamic>? route) {
    if (route == null) return null;
    final name = route.settings.name;
    if (name != null && name.isNotEmpty) return name;
    return route.runtimeType.toString();
  }
}
