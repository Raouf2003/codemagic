import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'api_service.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._();
  factory NotificationService() => _instance;
  NotificationService._();

  final ApiService _api = ApiService();
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  String? _fcmToken;
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    try {
      NotificationSettings settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.denied) {
        print('[FCM] Notification permission denied');
        return;
      }
    } catch (e) {
      print('[FCM] Permission request failed: $e');
      return;
    }

    try {
      _fcmToken = await _messaging.getToken().timeout(const Duration(seconds: 5));
      print('[FCM] Token: ${_fcmToken?.substring(0, 20)}...');
    } catch (e) {
      print('[FCM] Token retrieval failed: $e');
    }

    try {
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
      FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);
    } catch (e) {
      print('[FCM] Stream listeners failed: $e');
    }

    try {
      RemoteMessage? initialMessage = await _messaging.getInitialMessage().timeout(const Duration(seconds: 3));
      if (initialMessage != null) {
        _handleNotificationTap(initialMessage);
      }
    } catch (e) {
      print('[FCM] getInitialMessage failed: $e');
    }
  }

  Future<void> registerToken() async {
    if (_fcmToken == null) return;
    try {
      await _api.post('/fcm-token', {'token': _fcmToken}, requiresAuth: true);
      print('[FCM] Token registered with backend');
    } catch (e) {
      print('[FCM] Token registration failed: $e');
    }
  }

  void _handleForegroundMessage(RemoteMessage message) {
    print('[FCM] Foreground message: ${message.notification?.title}');
  }

  void _handleNotificationTap(RemoteMessage message) {
    print('[FCM] Notification tapped: ${message.notification?.title}');
  }
}
