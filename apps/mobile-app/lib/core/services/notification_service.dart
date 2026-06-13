import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  bool _isInitialized = false;

  Future<void> initialize() async {
    try {
      if (kIsWeb) {
        // Web requires specific options which we might not have yet
        return;
      }
      
      await Firebase.initializeApp();
      _isInitialized = true;

      FirebaseMessaging messaging = FirebaseMessaging.instance;

      NotificationSettings settings = await messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        debugPrint('User granted permission');
      } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
        debugPrint('User granted provisional permission');
      } else {
        debugPrint('User declined or has not accepted permission');
      }

      final token = await messaging.getToken();
      debugPrint("FCM Token: $token");
      // TODO: Send token to backend

      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint('Got a message whilst in the foreground!');
        debugPrint('Message data: ${message.data}');

        if (message.notification != null) {
          debugPrint('Message also contained a notification: ${message.notification}');
          // Note: FlutterLocalNotificationsPlugin can be used here to show Heads-up notification
        }
      });
      
    } catch (e) {
      debugPrint("Firebase initialization failed (expected if google-services.json is missing): $e");
    }
  }

  bool get isInitialized => _isInitialized;
}
