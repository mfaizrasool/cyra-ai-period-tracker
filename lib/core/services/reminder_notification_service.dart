import 'package:cyra_ai_period_tracker/common/controllers/preference_controller.dart';
import 'package:cyra_ai_period_tracker/core/services/local_notifications_holder.dart';
import 'package:cyra_ai_period_tracker/core/utils/date_utils.dart';
import 'package:cyra_ai_period_tracker/features/home/cycle_controller.dart';
import 'package:cyra_ai_period_tracker/utils/preference_labels.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;

/// Schedules local notifications from Profile → Reminders preferences + [CycleController].
class ReminderNotificationService {
  ReminderNotificationService._();

  static const int _idPeriod = 91001;
  static const int _idDailyLog = 91002;

  static const AndroidNotificationChannel _channelPeriod =
      AndroidNotificationChannel(
    'cyra_period_reminder',
    'Period reminders',
    description: 'Alerts before your expected next period.',
    importance: Importance.high,
  );

  static const AndroidNotificationChannel _channelDaily =
      AndroidNotificationChannel(
    'cyra_daily_log',
    'Daily log reminders',
    description: 'Daily nudge to log in Cyra.',
    importance: Importance.defaultImportance,
  );

  static Future<void> _ensureReminderChannels() async {
    final android = LocalNotificationsHolder.plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await android?.createNotificationChannel(_channelPeriod);
    await android?.createNotificationChannel(_channelDaily);
  }

  static Future<void> _requestAndroidPostNotificationsIfNeeded() async {
    final android = LocalNotificationsHolder.plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await android?.requestNotificationsPermission();
  }

  /// Clears Cyra reminder notifications (not FCM).
  static Future<void> cancelAll() async {
    await LocalNotificationsHolder.plugin.cancel(_idPeriod);
    await LocalNotificationsHolder.plugin.cancel(_idDailyLog);
  }

  /// Re-reads prefs and [CycleController] (if registered) and updates schedules.
  static Future<void> sync() async {
    try {
      await _ensureReminderChannels();
      await _requestAndroidPostNotificationsIfNeeded();

      final prefs = Get.find<AppPreferencesController>();
      final periodEnabled =
          await prefs.getBool(key: AppPreferenceLabels.reminderPeriodEnabled);
      final dailyEnabled =
          await prefs.getBool(key: AppPreferenceLabels.reminderDailyLogEnabled);
      final daysStr =
          await prefs.getString(key: AppPreferenceLabels.reminderDaysBeforePeriod);
      final daysBefore = (int.tryParse(daysStr) ?? 2).clamp(0, 7);

      await LocalNotificationsHolder.plugin.cancel(_idPeriod);
      await LocalNotificationsHolder.plugin.cancel(_idDailyLog);

      if (periodEnabled && Get.isRegistered<CycleController>()) {
        await _schedulePeriodReminder(
          Get.find<CycleController>(),
          daysBefore,
        );
      }

      if (dailyEnabled) {
        await _scheduleDailyLog();
      }
    } catch (e, st) {
      if (kDebugMode) {
        print('ReminderNotificationService.sync error: $e\n$st');
      }
    }
  }

  static Future<void> _schedulePeriodReminder(
    CycleController cycle,
    int daysBefore,
  ) async {
    final now = DateTime.now();
    var nextP = dateOnly(cycle.nextPeriodDate.value);
    final cycleLen = cycle.avgCycleLength.value.clamp(21, 45);

    for (var attempt = 0; attempt < 36; attempt++) {
      final triggerDay = nextP.subtract(Duration(days: daysBefore));
      final scheduled = DateTime(
        triggerDay.year,
        triggerDay.month,
        triggerDay.day,
        9,
        0,
      );
      if (scheduled.isAfter(now)) {
        final tzDate = tz.TZDateTime.from(scheduled, tz.local);
        final pretty = DateFormat.yMMMd().format(nextP);
        final details = NotificationDetails(
          android: AndroidNotificationDetails(
            _channelPeriod.id,
            _channelPeriod.name,
            channelDescription: _channelPeriod.description,
            importance: Importance.high,
            priority: Priority.high,
            icon: 'app_icon',
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        );
        await LocalNotificationsHolder.plugin.zonedSchedule(
          _idPeriod,
          'Period reminder',
          daysBefore == 0
              ? 'Your next period is expected around $pretty. Open Cyra to log or check your calendar.'
              : 'About $daysBefore day(s) before your expected period ($pretty). Open Cyra to review.',
          tzDate,
          details,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        );
        return;
      }
      nextP = nextP.add(Duration(days: cycleLen));
    }
  }

  static Future<void> _scheduleDailyLog() async {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      20,
      0,
    );
    if (!scheduled.isAfter(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        _channelDaily.id,
        _channelDaily.name,
        channelDescription: _channelDaily.description,
        importance: Importance.defaultImportance,
        icon: 'app_icon',
      ),
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );
    await LocalNotificationsHolder.plugin.zonedSchedule(
      _idDailyLog,
      'Daily log',
      'Take a moment to log symptoms and mood in Cyra.',
      scheduled,
      details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }
}
