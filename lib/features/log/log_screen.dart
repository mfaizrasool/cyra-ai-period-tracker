import 'package:cyra_ai_period_tracker/core/utils/date_utils.dart';
import 'package:cyra_ai_period_tracker/features/log/log_controller.dart';
import 'package:cyra_ai_period_tracker/utils/theme/constants/app_constants.dart';
import 'package:cyra_ai_period_tracker/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class LogScreen extends StatelessWidget {
  const LogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final controller = Get.find<LogController>();

    return Scaffold(
      appBar: AppBar(title: const Text('Daily Log'), centerTitle: true),
      body: SafeArea(
        child: Column(
          children: [
            // Date Selector header
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: Obx(
                () => Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left),
                      onPressed: () => controller.changeDate(
                        controller.selectedDate.value.subtract(
                          const Duration(days: 1),
                        ),
                      ),
                    ),
                    Text(
                      DateFormat(
                        'EEEE, MMM d',
                      ).format(controller.selectedDate.value),
                      style: theme.textTheme.titleMedium,
                    ),
                    IconButton(
                      icon: const Icon(Icons.chevron_right),
                      onPressed:
                          !dateOnly(
                            controller.selectedDate.value,
                          ).isBefore(dateOnly(DateTime.now()))
                          ? null
                          : () => controller.changeDate(
                              controller.selectedDate.value.add(
                                const Duration(days: 1),
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Symptoms', style: theme.textTheme.titleMedium),
                    const SizedBox(height: 12),
                    Obx(
                      () => Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: controller.symptomOptions.map((s) {
                          final isSelected = controller.selectedSymptoms
                              .contains(s);
                          return ChoiceChip(
                            label: Text(s),
                            selected: isSelected,
                            onSelected: (_) => controller.toggleSymptom(s),
                            selectedColor: theme.colorScheme.primaryContainer,
                          );
                        }).toList(),
                      ),
                    ),

                    const SizedBox(height: 24),
                    Text('Pain', style: theme.textTheme.titleMedium),
                    const SizedBox(height: 8),
                    Obx(() {
                      final v = controller.painLevel.value;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                v == null ? 'Not logged' : '$v / 10',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              TextButton(
                                onPressed: () => controller.setPainLevel(null),
                                child: const Text('Clear'),
                              ),
                            ],
                          ),
                          Slider(
                            value: (v ?? 0).toDouble(),
                            min: 0,
                            max: 10,
                            divisions: 10,
                            label: v == null ? '—' : '$v',
                            onChanged: (x) =>
                                controller.setPainLevel(x.round()),
                          ),
                          Text(
                            '0 = none · 10 = worst — optional; helps spot patterns in Insights.',
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      );
                    }),
                    const SizedBox(height: 24),
                    Text('Mood', style: theme.textTheme.titleMedium),
                    const SizedBox(height: 12),
                    Obx(
                      () => Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: controller.moodOptions.map((m) {
                          final isSelected = controller.selectedMood.value == m;
                          return ChoiceChip(
                            label: Text(m),
                            selected: isSelected,
                            onSelected: (_) => controller.setMood(m),
                            selectedColor: AppColors.insightColor.withValues(
                              alpha: 0.3,
                            ),
                          );
                        }).toList(),
                      ),
                    ),

                    const SizedBox(height: 24),
                    Text('Notes', style: theme.textTheme.titleMedium),
                    const SizedBox(height: 12),
                    TextField(
                      controller: controller.notesController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: 'Anything else to remember?',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: PrimaryButton(
                title: 'Save Entry',
                width: double.infinity,
                onPressed: () {
                  FocusScope.of(context).unfocus();
                  controller.saveLog();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
