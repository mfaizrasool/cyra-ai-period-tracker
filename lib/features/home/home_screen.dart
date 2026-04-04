import 'package:cyra_ai_period_tracker/features/home/cycle_controller.dart';
import 'package:cyra_ai_period_tracker/features/home/shell_nav_controller.dart';
import 'package:cyra_ai_period_tracker/utils/theme/constants/app_constants.dart';
import 'package:cyra_ai_period_tracker/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const _flowLabels = ['None', 'Spotting', 'Light', 'Medium', 'Heavy'];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final controller = Get.find<CycleController>();
    final shellNav = Get.find<ShellNavController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cyra'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Obx(() {
            final nextDate = controller.nextPeriodDate.value;
            final daysUntil = controller.daysUntilNextPeriod.value;
            final cycleDay = controller.cycleDay.value;
            final periodBleedDay = controller.periodDayInBleeding.value;

            final headline = periodBleedDay != null
                ? 'Period day $periodBleedDay'
                : 'Cycle day $cycleDay';

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateFormat('EEEE, MMMM d').format(DateTime.now()),
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 4),
                Text(headline, style: theme.textTheme.titleLarge),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          daysUntil > 0
                              ? 'Next period in $daysUntil days'
                              : daysUntil == 0
                                  ? 'Period expected today'
                                  : 'Period is late by ${-daysUntil} days',
                          style: theme.textTheme.titleMedium,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Expected on ${DateFormat('MMM d').format(nextDate)}',
                          style: theme.textTheme.bodyMedium,
                        ),
                        if (periodBleedDay != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            'You logged bleeding today — predictions update as you log.',
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            _legendDot(AppColors.periodColor, 'Period'),
                            const SizedBox(width: 12),
                            _legendDot(AppColors.fertileColor, 'Fertile'),
                            const SizedBox(width: 12),
                            _legendDot(AppColors.ovulationColor, 'Ovulation'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: PrimaryButton(
                        title: 'Log period',
                        onPressed: () => _showFlowPicker(context, controller),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: PrimaryButton(
                        title: 'Symptoms',
                        onPressed: () => shellNav.goToTab(2),
                        backgroundColor: theme.colorScheme.secondaryContainer,
                        titleColor: theme.colorScheme.onSecondaryContainer,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.auto_awesome_outlined),
                    title: const Text('Smart insight'),
                    subtitle: Text(
                      'Next period estimate uses your ${controller.avgCycleLength.value}-day cycle '
                      'and last logged bleeding start.',
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => shellNav.goToTab(3),
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  Future<void> _showFlowPicker(BuildContext context, CycleController controller) async {
    var level = 3;
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: StatefulBuilder(
            builder: (context, setSt) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Flow for today', style: Theme.of(ctx).textTheme.titleMedium),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<int>(
                    key: ValueKey(level),
                    initialValue: level,
                    decoration: const InputDecoration(labelText: 'Flow'),
                    items: List.generate(
                      _flowLabels.length,
                      (i) => DropdownMenuItem(value: i, child: Text(_flowLabels[i])),
                    ),
                    onChanged: (v) => setSt(() => level = v ?? 3),
                  ),
                  const SizedBox(height: 20),
                  PrimaryButton(
                    title: 'Save',
                    width: double.infinity,
                    onPressed: () async {
                      Navigator.pop(ctx);
                      await controller.logPeriodDay(DateTime.now(), level);
                      Get.snackbar(
                        'Saved',
                        level == 0
                            ? 'Updated for today.'
                            : 'Period logged for today.',
                        snackPosition: SnackPosition.BOTTOM,
                      );
                    },
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Widget _legendDot(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label),
      ],
    );
  }
}
