import 'package:cyra_ai_period_tracker/core/services/app_data_wipe_service.dart';
import 'package:cyra_ai_period_tracker/core/services/export_service.dart';
import 'package:cyra_ai_period_tracker/features/home/cycle_controller.dart';
import 'package:cyra_ai_period_tracker/features/home/home_shell_screen.dart';
import 'package:cyra_ai_period_tracker/features/onboarding/onboarding_screen.dart';
import 'package:cyra_ai_period_tracker/features/profile/reminders_screen.dart';
import 'package:cyra_ai_period_tracker/utils/theme/theme_controller.dart';
import 'package:cyra_ai_period_tracker/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();
    final cycle = Get.find<CycleController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile & Settings'),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          const SizedBox(height: 20),
          const CircleAvatar(radius: 40, child: Icon(Icons.person, size: 40)),
          const SizedBox(height: 16),
          const Center(
            child: Text(
              'Cyra',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 8),
          const Center(
            child: Text('Private, on-device cycle tracking'),
          ),
          const SizedBox(height: 32),

          _SectionHeader(title: 'Cycle'),
          ListTile(
            leading: const Icon(Icons.timelapse_outlined),
            title: const Text('Cycle & period length'),
            subtitle: Obx(
              () => Text(
                '${cycle.avgCycleLength.value} day cycle · ${cycle.avgPeriodLength.value} day period',
              ),
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showCycleSettings(context, cycle),
          ),

          _SectionHeader(title: 'App'),
          Obx(
            () {
              final mode = themeController.selectedTheme.value;
              final systemDark =
                  SchedulerBinding.instance.platformDispatcher.platformBrightness ==
                      Brightness.dark;
              final on =
                  mode == ThemeMode.dark || (mode == ThemeMode.system && systemDark);
              return ListTile(
                leading: const Icon(Icons.dark_mode),
                title: const Text('Dark mode'),
                trailing: Switch(
                  value: on,
                  onChanged: (val) {
                    themeController.setTheme(val ? ThemeMode.dark : ThemeMode.light);
                  },
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('Reminders'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Get.to(() => const RemindersScreen()),
          ),

          _SectionHeader(title: 'Data & privacy'),
          ListTile(
            leading: const Icon(Icons.lock_outline),
            title: const Text('Privacy'),
            subtitle: const Text('Your logs are stored locally on this device.'),
            onTap: () {
              showDialog<void>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Privacy'),
                  content: const Text(
                    'Cyra keeps period and daily logs in a local database on your phone. '
                    'Export creates a simple text summary you can share or save.',
                  ),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('OK')),
                  ],
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.ios_share_outlined),
            title: const Text('Export health data'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () async {
              try {
                await ExportService().shareHealthExport();
              } catch (e) {
                Get.snackbar('Export', 'Could not open share sheet: $e');
              }
            },
          ),

          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: PrimaryButton(
              title: 'Reset app & delete all data',
              backgroundColor: Colors.redAccent.withValues(alpha: 0.1),
              titleColor: Colors.redAccent,
              onPressed: () async {
                final go = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Delete all data?'),
                    content: const Text(
                      'This removes all period logs, daily logs, cycle settings, reminders, '
                      'and other saved preferences from this device. This cannot be undone.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: const Text('Cancel'),
                      ),
                      FilledButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        child: const Text('Delete everything'),
                      ),
                    ],
                  ),
                );
                if (go != true || !context.mounted) return;

                await AppDataWipeService.wipeEverything();

                if (!context.mounted) return;
                Get.offAll(
                  () => OnboardingScreen(
                    onCompleted: () => Get.offAll(() => const HomeShellScreen()),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Future<void> _showCycleSettings(BuildContext context, CycleController cycle) async {
    final cycleCtrl = TextEditingController(text: '${cycle.avgCycleLength.value}');
    final periodCtrl = TextEditingController(text: '${cycle.avgPeriodLength.value}');

    await showDialog<void>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Cycle settings'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: cycleCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Average cycle length (days)'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: periodCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Average period length (days)'),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            FilledButton(
              onPressed: () async {
                final c = int.tryParse(cycleCtrl.text.trim());
                final p = int.tryParse(periodCtrl.text.trim());
                if (c == null || p == null || c < 21 || c > 45 || p < 2 || p > 10) {
                  Get.snackbar('Check values', 'Cycle: 21–45 days. Period: 2–10 days.');
                  return;
                }
                Navigator.pop(ctx);
                await cycle.updateAveragesFromProfile(cycle: c, period: p);
                Get.snackbar('Saved', 'Cycle settings updated.');
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          color: Theme.of(context).primaryColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
