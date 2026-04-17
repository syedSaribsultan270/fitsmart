import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'analytics_service.dart';

/// Handles FCM registration, permission requests, and local notification
/// initialization. Call [init] once at app startup after Firebase.initializeApp().
class NotificationService {
  NotificationService._();
  static final instance = NotificationService._();

  static const _channelId = 'fitsmart_main';
  static const _channelName = 'FitSmart Notifications';

  final _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  FlutterLocalNotificationsPlugin get plugin => _plugin;

  Future<void> init() async {
    if (_initialized || kIsWeb) return;
    _initialized = true;
    await _initLocalPlugin();
    _initFcmHandlers();
  }

  // ── Local plugin init ──────────────────────────────────────────

  Future<void> _initLocalPlugin() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    await _plugin.initialize(
      const InitializationSettings(android: androidSettings, iOS: iosSettings),
      onDidReceiveNotificationResponse: _onLocalTap,
    );

    if (!kIsWeb && Platform.isAndroid) {
      await _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(
            const AndroidNotificationChannel(
              _channelId,
              _channelName,
              description:
                  'Streak alerts, meal reminders, and workout cues from FitSmart.',
              importance: Importance.high,
            ),
          );
    }
  }

  // ── FCM handlers ──────────────────────────────────────────────

  void _initFcmHandlers() {
    FirebaseMessaging.onMessage.listen(_onFcmForeground);
    FirebaseMessaging.onMessageOpenedApp.listen(_onFcmTap);
    FirebaseMessaging.instance.getInitialMessage().then((msg) {
      if (msg != null) _onFcmTap(msg);
    });
  }

  void _onFcmForeground(RemoteMessage message) {
    AnalyticsService.instance.track('notification_received', props: {
      'type': message.data['type'] ?? 'fcm',
      'source': 'foreground',
    });
    final notif = message.notification;
    if (notif == null) return;
    _plugin.show(
      message.hashCode,
      notif.title,
      notif.body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      payload: message.data['payload'] as String?,
    );
  }

  void _onFcmTap(RemoteMessage message) {
    AnalyticsService.instance.track('notification_tapped', props: {
      'type': message.data['type'] ?? 'fcm',
      'payload': message.data['payload'] ?? '',
    });
  }

  /// Pending deep-link captured from a notification tap. The router consumes
  /// and clears this on the next navigation tick so we don't get stuck in a
  /// redirect loop. Payload format is a route path string e.g. `/weekly-review`.
  static String? pendingDeepLink;

  void _onLocalTap(NotificationResponse response) {
    final payload = response.payload ?? '';
    AnalyticsService.instance.track('notification_tapped', props: {
      'type': 'local',
      'payload': payload,
    });
    if (payload.startsWith('/')) {
      pendingDeepLink = payload;
    }
  }

  // ── Permission ────────────────────────────────────────────────

  /// Request OS notification permission. Returns true if granted.
  /// Call this at a contextual moment (not cold launch).
  Future<bool> requestPermission() async {
    if (kIsWeb) return false;
    AnalyticsService.instance.track('notification_permission_requested');
    bool granted = false;

    if (Platform.isIOS) {
      final settings = await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      granted = settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional;
    } else if (Platform.isAndroid) {
      final impl = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      granted = await impl?.requestNotificationsPermission() ?? false;
    }

    AnalyticsService.instance.track(
      granted ? 'notification_permission_granted' : 'notification_permission_denied',
    );

    if (granted) unawaited(_storeFcmToken());
    return granted;
  }

  // ── FCM token storage ─────────────────────────────────────────

  /// Refresh the FCM token in Firestore. Call on every sign-in so stale
  /// tokens (from reinstalls or Firebase token rotation) are always updated.
  Future<void> refreshFcmToken() async {
    if (kIsWeb) return;
    await _storeFcmToken();
  }

  Future<void> _storeFcmToken() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;
      final token = await FirebaseMessaging.instance.getToken();
      if (token == null) return;

      final platform = Platform.isIOS ? 'ios' : 'android';
      // Use first 20 chars of token as stable device ID
      final deviceId = token.substring(0, 20);
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('devices')
          .doc(deviceId)
          .set({
        'fcm_token': token,
        'platform': platform,
        'updated_at': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      debugPrint('[Notifications] FCM token stored ($platform).');
    } catch (e) {
      debugPrint('[Notifications] Failed to store FCM token: $e');
    }
  }
}

/// Fire-and-forget without warning.
void unawaited(Future<void> future) {
  future.catchError((Object e) {
    debugPrint('[unawaited] $e');
  });
}
