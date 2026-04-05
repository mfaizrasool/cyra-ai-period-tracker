import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Single [FlutterLocalNotificationsPlugin] for FCM-forwarded alerts and Cyra reminders.
class LocalNotificationsHolder {
  LocalNotificationsHolder._();

  static final FlutterLocalNotificationsPlugin plugin =
      FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel fcmAndroidChannel =
      AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    description: 'This channel is used for important notifications.',
    importance: Importance.max,
  );

  static Future<void> initialize() async {
    final iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      requestProvisionalPermission: false,
      requestCriticalPermission: false,
      defaultPresentAlert: true,
      defaultPresentBadge: true,
      defaultPresentSound: true,
      defaultPresentBanner: true,
      defaultPresentList: true,
    );
    const androidSettings = AndroidInitializationSettings('app_icon');

    final settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await plugin.initialize(
      settings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        if (kDebugMode) print('Notification tapped: ${response.payload}');
        try {
          if (response.payload == null) return;
          final Map<String, dynamic> payload = Map<String, dynamic>.from(
            (response.payload!.isNotEmpty)
                ? (jsonDecode(response.payload!) as Map<String, dynamic>)
                : <String, dynamic>{},
          );
          if (kDebugMode) print('Notification payload: $payload');
        } catch (e) {
          if (kDebugMode) print('Error handling notification tap: $e');
        }
      },
    );

    final androidImpl = plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await androidImpl?.createNotificationChannel(fcmAndroidChannel);
  }
}
