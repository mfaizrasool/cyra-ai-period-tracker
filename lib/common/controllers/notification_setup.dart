import 'dart:convert';
import 'dart:io' show Platform;

import 'package:app_settings/app_settings.dart';
import 'package:cyra_ai_period_tracker/core/services/local_notifications_holder.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationSetup {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  FlutterLocalNotificationsPlugin get _localNotificationsPlugin =>
      LocalNotificationsHolder.plugin;

  static final AndroidNotificationChannel _androidChannel =
      LocalNotificationsHolder.fcmAndroidChannel;

  Future<void> requestNotificationPermission() async {
    final settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      carPlay: true,
      provisional: true,
      sound: true,
    );
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
    FirebaseMessaging.onMessage.listen((message) async {
      if (kDebugMode) {
        print(
          'FCM onMessage data=${message.data} title=${message.notification?.title} body=${message.notification?.body}',
        );
      }
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
