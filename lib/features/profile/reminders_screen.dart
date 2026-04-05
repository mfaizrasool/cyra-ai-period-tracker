import 'package:cyra_ai_period_tracker/common/controllers/preference_controller.dart';
import 'package:cyra_ai_period_tracker/core/services/reminder_notification_service.dart';
import 'package:cyra_ai_period_tracker/utils/app_text_styles.dart';
import 'package:cyra_ai_period_tracker/utils/preference_labels.dart';
import 'package:cyra_ai_period_tracker/utils/theme/constants/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RemindersScreen extends StatefulWidget {
  const RemindersScreen({super.key});

  @override
  State<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen> {
  final _prefs = Get.find<AppPreferencesController>();
  bool _periodReminder = true;
  int _daysBefore = 2;
  bool _dailyLogReminder = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final daysStr =
        await _prefs.getString(key: AppPreferenceLabels.reminderDaysBeforePeriod);
    if (daysStr.isEmpty) {
      _periodReminder = true;
      _daysBefore = 2;
      _dailyLogReminder = false;
    } else {
      _periodReminder =
          await _prefs.getBool(key: AppPreferenceLabels.reminderPeriodEnabled);
      _dailyLogReminder =
          await _prefs.getBool(key: AppPreferenceLabels.reminderDailyLogEnabled);
      _daysBefore = int.tryParse(daysStr) ?? 2;
    }
    if (mounted) setState(() {});
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    await _prefs.setBool(
      key: AppPreferenceLabels.reminderPeriodEnabled,
      value: _periodReminder,
    );
    await _prefs.setBool(
      key: AppPreferenceLabels.reminderDailyLogEnabled,
      value: _dailyLogReminder,
    );
    await _prefs.setString(
      key: AppPreferenceLabels.reminderDaysBeforePeriod,
      value: '$_daysBefore',
    );
    await ReminderNotificationService.sync();
    if (mounted) {
      setState(() => _saving = false);
      Get.snackbar(
        'Saved',
        'Reminder settings updated. Allow notifications in system settings if prompted.',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reminders'),
        centerTitle: true,
        scrolledUnderElevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            elevation: 0,
            color: AppColors.insightColor.withValues(alpha: 0.08),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: AppColors.insightColor.withValues(alpha: 0.2),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.notifications_active_outlined, color: theme.primaryColor),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Local notifications on this device. Period reminders use your '
                      'next predicted date from the Home calendar. Daily log fires every day at 8:00 PM.',
                      style: AppTextStyle.bodyMedium.copyWith(
                        color: theme.colorScheme.onSurface,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text('Period', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Period reminder'),
            subtitle: const Text(
              'One notification before your next expected period (9:00 AM local time).',
            ),
            value: _periodReminder,
            onChanged: (v) => setState(() => _periodReminder = v),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Days before period'),
            subtitle: Text(
              '0 = same day as expected start',
              style: AppTextStyle.bodyMedium.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
            trailing: DropdownButton<int>(
              value: _daysBefore.clamp(0, 7),
              items: List.generate(
                8,
                (i) => DropdownMenuItem(value: i, child: Text('$i days')),
              ),
              onChanged: (v) => setState(() => _daysBefore = v ?? 2),
            ),
          ),
          const SizedBox(height: 20),
          Text('Daily log', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Daily log reminder'),
            subtitle: const Text(
              'Repeats every day at 8:00 PM to log symptoms, mood, and pain.',
            ),
            value: _dailyLogReminder,
            onChanged: (v) => setState(() => _dailyLogReminder = v),
          ),
          const SizedBox(height: 28),
          FilledButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Save & schedule notifications'),
          ),
        ],
      ),
    );
  }
}
