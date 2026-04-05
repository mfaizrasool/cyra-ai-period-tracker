import 'dart:convert';
import 'dart:io' show Platform;

import 'package:app_settings/app_settings.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationSetup {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel _androidChannel =
      AndroidNotificationChannel(
        'high_importance_channel',
        'High Importance Notifications',
        description: 'This channel is used for important notifications.',
        importance: Importance.max,
      );

  NotificationSetup() {
    // Initialize plugin and channels early
    _initializeLocalNotifications();
    _createNotificationChannel();
  }

  // No ID normalization needed since we no longer mark read here

  Future<void> _initializeLocalNotifications() async {
    // iOS settings must request permissions
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
    final androidSettings = AndroidInitializationSettings('app_icon');

    final settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    final initialized = await _localNotificationsPlugin.initialize(
      settings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // handle notification tap
        if (kDebugMode) print('Notification tapped: ${response.payload}');
        try {
          if (response.payload == null) return;
          final Map<String, dynamic> payload = Map<String, dynamic>.from(
            // payload is JSON string produced below
            // ignore: invalid_use_of_visible_for_testing_member
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

    if (kDebugMode) {
      print('Local notifications initialized: $initialized');
    }
  }

  Future<void> _createNotificationChannel() async {
    final androidImpl = _localNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await androidImpl?.createNotificationChannel(_androidChannel);
  }

  Future<void> requestNotificationPermission() async {
    final settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      carPlay: true,
      provisional: true,
      sound: true,
    );
    // Ensure iOS shows notifications while app is in foreground
    await _firebaseMessaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
    if (settings.authorizationStatus == AuthorizationStatus.denied) {
      AppSettings.openAppSettings();
      if (kDebugMode) print('Notification permission denied');
    } else {
      if (kDebugMode) {
        print('Notification permission: ${settings.authorizationStatus}');
      }
    }
  }

  void firebaseNotificationInit(BuildContext context) {
    // Listen for foreground messages and always show via local plugin
    FirebaseMessaging.onMessage.listen((message) async {
      if (kDebugMode) {
        print(
          'FCM onMessage data=${message.data} title=${message.notification?.title} body=${message.notification?.body}',
        );
      }
      // Foreground handling:
      // - Android: FCM doesn't show system UI in foreground, so show local.
      // - iOS: With foreground presentation enabled, APNs shows alert for
      //   notification payloads. To avoid duplicates, only show local for
      //   data-only messages (no notification block).
      final hasNotificationBlock =
          message.notification?.title != null ||
          message.notification?.body != null;
      if (Platform.isAndroid) {
        await _showNotification(message);
      } else if (Platform.isIOS) {
        if (!hasNotificationBlock) {
          await _showNotification(message);
        }
      }
    });
  }

  Future<void> _showNotification(RemoteMessage message) async {
    final data = message.data;

    // Get title and body from notification or data
    final title =
        message.notification?.title ?? data['title'] ?? 'Notification';
    final body =
        message.notification?.body ??
        data['body'] ??
        data['type'] ??
        'New message received';

    if (kDebugMode) {
      print('Showing notification with title: $title');
      print('Showing notification with body: $body');
    }

    final androidDetails = AndroidNotificationDetails(
      _androidChannel.id,
      _androidChannel.name,
      channelDescription: _androidChannel.description,
      importance: Importance.max,
      priority: Priority.high,
      enableLights: true,
      enableVibration: true,
      playSound: true,
      showWhen: true,
      when: DateTime.now().millisecondsSinceEpoch,
      visibility: NotificationVisibility.public,
    );

    // iOS attachments need Notification Service Extension in native iOS
    final iosAttachments = <DarwinNotificationAttachment>[];

    final iosDetails = DarwinNotificationDetails(
      attachments: iosAttachments,
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    try {
      await _localNotificationsPlugin.show(
        0,
        title,
        body,
        details,
        // Send JSON so we can route on tap
        payload: jsonEncode(data),
      );
      if (kDebugMode) print('Notification shown successfully');
    } catch (e) {
      if (kDebugMode) print('Error showing notification: $e');
    }
  }

  Future<void> setupInteractMessages(BuildContext context) async {
    final initial = await _firebaseMessaging.getInitialMessage();
    if (initial != null && context.mounted) handleInteraction(context, initial);
    FirebaseMessaging.onMessageOpenedApp.listen((msg) {
      if (context.mounted) handleInteraction(context, msg);
    });
  }

  void handleInteraction(BuildContext context, RemoteMessage msg) async {}

  Future<String?> getDeviceToken() async =>
      FirebaseMessaging.instance.getToken();
}
