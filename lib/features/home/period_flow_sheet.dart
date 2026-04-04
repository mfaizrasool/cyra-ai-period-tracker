import 'package:cyra_ai_period_tracker/features/home/cycle_controller.dart';
import 'package:cyra_ai_period_tracker/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

const _flowLabels = ['None', 'Spotting', 'Light', 'Medium', 'Heavy'];

/// Bottom sheet to log period flow for [date] (defaults to today).
Future<void> showPeriodFlowSheet(
  BuildContext context,
  CycleController controller, {
  DateTime? date,
}) async {
  final target = date ?? DateTime.now();
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
                Text('Flow', style: Theme.of(ctx).textTheme.titleMedium),
                const SizedBox(height: 12),
                DropdownButtonFormField<int>(
                  key: ValueKey(level),
                  initialValue: level,
                  decoration: const InputDecoration(labelText: 'Intensity'),
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
                    await controller.logPeriodDay(target, level);
                    Get.snackbar(
                      'Saved',
                      level == 0 ? 'Updated for this day.' : 'Period logged.',
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
