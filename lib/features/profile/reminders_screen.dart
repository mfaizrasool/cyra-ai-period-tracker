import 'package:cyra_ai_period_tracker/common/controllers/preference_controller.dart';
import 'package:cyra_ai_period_tracker/utils/preference_labels.dart';
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

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final daysStr = await _prefs.getString(key: AppPreferenceLabels.reminderDaysBeforePeriod);
    if (daysStr.isEmpty) {
      _periodReminder = true;
      _daysBefore = 2;
      _dailyLogReminder = false;
    } else {
      _periodReminder = await _prefs.getBool(key: AppPreferenceLabels.reminderPeriodEnabled);
      _dailyLogReminder = await _prefs.getBool(key: AppPreferenceLabels.reminderDailyLogEnabled);
      _daysBefore = int.tryParse(daysStr) ?? 2;
    }
    if (mounted) setState(() {});
  }

  Future<void> _save() async {
    await _prefs.setBool(key: AppPreferenceLabels.reminderPeriodEnabled, value: _periodReminder);
    await _prefs.setBool(key: AppPreferenceLabels.reminderDailyLogEnabled, value: _dailyLogReminder);
    await _prefs.setString(key: AppPreferenceLabels.reminderDaysBeforePeriod, value: '$_daysBefore');
    Get.snackbar('Saved', 'Reminder preferences saved on this device.');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reminders'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SwitchListTile(
            title: const Text('Period reminder'),
            subtitle: const Text('Notify before your next expected period.'),
            value: _periodReminder,
            onChanged: (v) => setState(() => _periodReminder = v),
          ),
          ListTile(
            title: const Text('Days before period'),
            trailing: DropdownButton<int>(
              value: _daysBefore.clamp(0, 7),
              items: List.generate(8, (i) => DropdownMenuItem(value: i, child: Text('$i days'))),
              onChanged: (v) => setState(() => _daysBefore = v ?? 2),
            ),
          ),
          SwitchListTile(
            title: const Text('Daily log reminder'),
            subtitle: const Text('Gentle nudge to log symptoms and mood.'),
            value: _dailyLogReminder,
            onChanged: (v) => setState(() => _dailyLogReminder = v),
          ),
          const SizedBox(height: 16),
          Text(
            'Local notifications can be wired in a future update. Preferences are saved now.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _save,
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
