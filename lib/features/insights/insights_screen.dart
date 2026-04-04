import 'package:cyra_ai_period_tracker/features/home/cycle_controller.dart';
import 'package:cyra_ai_period_tracker/features/insights/insights_controller.dart';
import 'package:cyra_ai_period_tracker/utils/theme/constants/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cycle = Get.find<CycleController>();
    final insights = Get.find<InsightsController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Insights'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Obx(
          () => RefreshIndicator(
            onRefresh: () async {
              await cycle.loadData();
              await insights.load();
            },
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              children: [
                Text('Your averages', style: theme.textTheme.titleMedium),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _InfoCard(
                        title: 'Cycle length',
                        value: '${cycle.avgCycleLength.value}',
                        unit: 'days',
                        color: AppColors.fertileColor,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _InfoCard(
                        title: 'Period length',
                        value: '${cycle.avgPeriodLength.value}',
                        unit: 'days',
                        color: AppColors.periodColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text('Cycle regularity', style: theme.textTheme.titleMedium),
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      insights.regularityLabel.value,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text('Common symptoms', style: theme.textTheme.titleMedium),
                const SizedBox(height: 12),
                if (insights.topSymptoms.isEmpty)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        'No symptoms logged yet. Add them on the Log tab.',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                  )
                else
                  ...insights.topSymptoms.map(
                    (s) => Card(
                      child: ListTile(
                        leading: Icon(Icons.healing_outlined, color: theme.primaryColor),
                        title: Text(s),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.title,
    required this.value,
    required this.unit,
    required this.color,
  });

  final String title;
  final String value;
  final String unit;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      color: color.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: color.withValues(alpha: 0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              value,
              style: theme.textTheme.headlineLarge?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(unit, style: theme.textTheme.bodySmall),
            const SizedBox(height: 8),
            Text(
              title,
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
