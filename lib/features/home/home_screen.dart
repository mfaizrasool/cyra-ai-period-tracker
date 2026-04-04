import 'package:cyra_ai_period_tracker/core/cycle/cycle_phase_helper.dart';
import 'package:cyra_ai_period_tracker/core/utils/date_utils.dart';
import 'package:cyra_ai_period_tracker/features/home/cycle_controller.dart';
import 'package:cyra_ai_period_tracker/features/home/period_flow_sheet.dart';
import 'package:cyra_ai_period_tracker/features/home/shell_nav_controller.dart';
import 'package:cyra_ai_period_tracker/utils/theme/constants/app_constants.dart';
import 'package:cyra_ai_period_tracker/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final controller = Get.find<CycleController>();
    final shellNav = Get.find<ShellNavController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cyra'),
        centerTitle: true,
        scrolledUnderElevation: 0,
      ),
      body: SafeArea(
        child: Obx(() {
          final nextDate = controller.nextPeriodDate.value;
          final daysUntil = controller.daysUntilNextPeriod.value;
          final cycleDay = controller.cycleDay.value;
          final periodBleedDay = controller.periodDayInBleeding.value;
          final ov = controller.ovulationDate.value;
          final today = dateOnly(DateTime.now());
          final daysUntilOv = calendarDaysBetween(ov, today);

          final headline = periodBleedDay != null
              ? 'Period day $periodBleedDay'
              : 'Cycle day $cycleDay';

          final phase = CyclePhaseInfo.resolve(
            today: today,
            ovulationDate: ov,
            fertileWindow: controller.fertileWindow.toList(),
            periodDayInBleeding: periodBleedDay,
          );

          return RefreshIndicator(
            onRefresh: () => controller.loadData(),
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    child: _HeroHeader(
                      headline: headline,
                      dateLine: DateFormat('EEEE, MMMM d').format(DateTime.now()),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: Row(
                      children: [
                        Expanded(
                          child: _StatTile(
                            icon: Icons.water_drop_outlined,
                            color: AppColors.periodColor,
                            label: daysUntil > 0
                                ? 'Next period'
                                : daysUntil == 0
                                    ? 'Period'
                                    : 'Late',
                            value: daysUntil > 0
                                ? '$daysUntil d'
                                : daysUntil == 0
                                    ? 'Today'
                                    : '${-daysUntil} d',
                            caption: DateFormat('MMM d').format(nextDate),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _StatTile(
                            icon: Icons.bubble_chart_outlined,
                            color: AppColors.ovulationColor,
                            label: 'Ovulation',
                            value: daysUntilOv > 0
                                ? '$daysUntilOv d'
                                : daysUntilOv == 0
                                    ? 'Today'
                                    : '—',
                            caption: daysUntilOv < 0 ? 'Passed' : DateFormat('MMM d').format(ov),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: _PhaseTipCard(phase: phase),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(color: theme.dividerColor),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.event_repeat, color: theme.primaryColor, size: 22),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    daysUntil > 0
                                        ? 'Next period in $daysUntil days'
                                        : daysUntil == 0
                                            ? 'Period expected today'
                                            : 'Period is late by ${-daysUntil} days',
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Expected on ${DateFormat('MMMM d, y').format(nextDate)}',
                              style: theme.textTheme.bodyMedium,
                            ),
                            if (periodBleedDay != null) ...[
                              const SizedBox(height: 10),
                              Text(
                                'You logged bleeding today — predictions update as you log.',
                                style: theme.textTheme.bodySmall,
                              ),
                            ],
                            const SizedBox(height: 16),
                            Wrap(
                              spacing: 16,
                              runSpacing: 8,
                              children: [
                                _homeLegendDot(AppColors.periodColor, 'Period'),
                                _homeLegendDot(AppColors.fertileColor, 'Fertile'),
                                _homeLegendDot(AppColors.ovulationColor, 'Ovulation'),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: PrimaryButton(
                            title: 'Log period',
                            onPressed: () => showPeriodFlowSheet(context, controller),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: PrimaryButton(
                            title: 'Daily log',
                            onPressed: () => shellNav.goToTab(2),
                            backgroundColor: theme.colorScheme.secondaryContainer,
                            titleColor: theme.colorScheme.onSecondaryContainer,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    child: Material(
                      color: theme.cardColor,
                      elevation: 0,
                      borderRadius: BorderRadius.circular(16),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () => shellNav.goToTab(3),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              DecoratedBox(
                                decoration: BoxDecoration(
                                  color: AppColors.insightColor.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Padding(
                                  padding: EdgeInsets.all(10),
                                  child: Icon(Icons.auto_awesome_outlined, color: AppColors.insightColor),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Insights',
                                      style: theme.textTheme.titleSmall?.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Averages use your ${controller.avgCycleLength.value}-day cycle '
                                      'and last logged bleeding start.',
                                      style: theme.textTheme.bodySmall,
                                    ),
                                  ],
                                ),
                              ),
                              Icon(Icons.chevron_right, color: theme.hintColor),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

Widget _homeLegendDot(Color color, String label) {
  return Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
      const SizedBox(width: 6),
      Text(label, style: const TextStyle(fontSize: 13)),
    ],
  );
}

class _HeroHeader extends StatelessWidget {
  const _HeroHeader({required this.headline, required this.dateLine});

  final String headline;
  final String dateLine;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryColor.withValues(alpha: theme.brightness == Brightness.dark ? 0.35 : 0.22),
            theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
            theme.colorScheme.surface,
          ],
        ),
        border: Border.all(color: AppColors.primaryColor.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hello',
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.hintColor,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(dateLine, style: theme.textTheme.bodyMedium),
          const SizedBox(height: 12),
          Text(
            headline,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
    required this.caption,
  });

  final IconData icon;
  final Color color;
  final String label;
  final String value;
  final String caption;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: color.withValues(alpha: 0.08),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 10),
          Text(label, style: theme.textTheme.labelSmall?.copyWith(color: theme.hintColor)),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(caption, style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _PhaseTipCard extends StatelessWidget {
  const _PhaseTipCard({required this.phase});

  final CyclePhaseInfo phase;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: phase.accentColor.withValues(alpha: 0.07),
        border: Border.all(color: phase.accentColor.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.spa_outlined, color: phase.accentColor, size: 22),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  phase.title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: phase.accentColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(phase.subtitle, style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }
}
