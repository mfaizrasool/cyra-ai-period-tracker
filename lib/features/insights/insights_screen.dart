import 'package:cyra_ai_period_tracker/features/home/cycle_controller.dart';
import 'package:cyra_ai_period_tracker/features/insights/insights_controller.dart';
import 'package:cyra_ai_period_tracker/utils/app_text_styles.dart';
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
      appBar: AppBar(title: const Text('Insights'), centerTitle: true),
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
                Card(
                  elevation: 0,
                  color: AppColors.insightColor.withValues(alpha: 0.08),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: BorderSide(
                      color: AppColors.insightColor.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.edit_note_outlined,
                          color: theme.primaryColor,
                          size: 22,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Daily log → Insights',
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                insights.dailyLogEntryCount.value == 0
                                    ? 'Save symptoms, mood, pain, or notes on the Log tab; they show in the sections below.'
                                    : '${insights.dailyLogEntryCount.value} days with saved log entries. '
                                          'Pain, symptoms, and mood summaries update here.',
                                style: AppTextStyle.bodyMedium.copyWith(
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text('Cycle overview', style: theme.textTheme.titleMedium),
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
                Text(
                  'From your daily logs',
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  'Logged on the Log tab',
                  style: AppTextStyle.bodyMedium.copyWith(
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 12),
                Text('Pain', style: theme.textTheme.titleSmall),
                const SizedBox(height: 8),
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: theme.dividerColor),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.monitor_heart_outlined,
                          color: theme.primaryColor,
                        ),
                        const SizedBox(width: 12),
                        Expanded(child: Text(insights.painSummaryLabel.value)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text('Mood', style: theme.textTheme.titleSmall),
                const SizedBox(height: 8),
                if (insights.topMoods.isEmpty)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        'No moods logged yet. Choose a mood on the Log tab when you save an entry.',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                  )
                else
                  ...insights.topMoods.map(
                    (s) => Card(
                      child: ListTile(
                        leading: Icon(
                          Icons.mood_outlined,
                          color: theme.primaryColor,
                        ),
                        title: Text(s),
                      ),
                    ),
                  ),
                const SizedBox(height: 16),
                Text('Symptoms', style: theme.textTheme.titleSmall),
                const SizedBox(height: 8),
                if (insights.topSymptoms.isEmpty)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        'No symptoms logged yet. Tap symptoms on the Log tab when you save.',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                  )
                else
                  ...insights.topSymptoms.map(
                    (s) => Card(
                      child: ListTile(
                        leading: Icon(
                          Icons.healing_outlined,
                          color: theme.primaryColor,
                        ),
                        title: Text(s),
                      ),
                    ),
                  ),
                const SizedBox(height: 24),
                Text('Cycle regularity', style: theme.textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(
                  'From period flow you log on Home / Calendar',
                  style: AppTextStyle.bodyMedium.copyWith(
                    color: theme.colorScheme.onSurface,
                  ),
                ),
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
            Text(
              unit,
              style: AppTextStyle.bodyMedium.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: AppTextStyle.bodyMedium.copyWith(
                color: theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
