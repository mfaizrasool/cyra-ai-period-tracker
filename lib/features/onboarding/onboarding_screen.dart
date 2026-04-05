import 'package:cyra_ai_period_tracker/common/controllers/preference_controller.dart';
import 'package:cyra_ai_period_tracker/core/utils/date_utils.dart';
import 'package:cyra_ai_period_tracker/utils/app_text_styles.dart';
import 'package:cyra_ai_period_tracker/utils/preference_labels.dart';
import 'package:cyra_ai_period_tracker/utils/theme/constants/app_constants.dart';
import 'package:cyra_ai_period_tracker/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key, required this.onCompleted});

  final VoidCallback onCompleted;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageController = PageController();
  final _prefs = Get.find<AppPreferencesController>();

  int _currentIndex = 0;
  DateTime _lastPeriodDate = dateOnly(
    DateTime.now().subtract(const Duration(days: 28)),
  );
  int _cycleLength = 28;
  int _periodLength = 5;
  bool _loading = false;

  Future<void> _completeOnboarding() async {
    setState(() => _loading = true);
    await _prefs.setBool(
      key: AppPreferenceLabels.isOnboardingComplete,
      value: true,
    );
    await _prefs.setString(
      key: AppPreferenceLabels.lastPeriodStartDate,
      value: dateOnly(_lastPeriodDate).toIso8601String(),
    );
    await _prefs.setString(
      key: AppPreferenceLabels.avgCycleLength,
      value: _cycleLength.toString(),
    );
    await _prefs.setString(
      key: AppPreferenceLabels.avgPeriodLength,
      value: _periodLength.toString(),
    );
    setState(() => _loading = false);
    widget.onCompleted();
  }

  void _next() {
    if (_currentIndex == 3) {
      _completeOnboarding();
      return;
    }
    _pageController.nextPage(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOut,
    );
  }

  void _previous() {
    if (_currentIndex <= 0) return;
    _pageController.previousPage(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: _currentIndex > 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: _loading ? null : _previous,
              )
            : null,
        title: const Text('Cyra'),
        centerTitle: true,
        scrolledUnderElevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 8),
            _StepIndicator(current: _currentIndex, total: 4),
            const SizedBox(height: 12),
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) => setState(() => _currentIndex = index),
                children: [
                  const _WelcomeOnboardingPage(),
                  _OnboardingStepShell(
                    stepNumber: 2,
                    totalSteps: 4,
                    icon: Icons.calendar_today_rounded,
                    accentColor: AppColors.ovulationColor,
                    title: 'Last period start',
                    subtitle:
                        'Choose the first day of bleeding of your most recent period — '
                        'not the last day.',
                    child: _DateOnboardingBody(
                      selectedDate: _lastPeriodDate,
                      onChanged: (d) => setState(() => _lastPeriodDate = d),
                    ),
                  ),
                  _OnboardingStepShell(
                    stepNumber: 3,
                    totalSteps: 4,
                    icon: Icons.repeat_rounded,
                    accentColor: AppColors.fertileColor,
                    title: 'Cycle length',
                    subtitle:
                        'Full cycle length: from the first day of one period to the day before the next one starts.',
                    footerHint:
                        'Typical range is about 21–35 days. You can change this later in Profile.',
                    child: _StepperNumberPicker(
                      value: _cycleLength,
                      min: 21,
                      max: 45,
                      suffix: 'days',
                      accentColor: AppColors.fertileColor,
                      onChanged: (v) => setState(() => _cycleLength = v),
                    ),
                  ),
                  _OnboardingStepShell(
                    stepNumber: 4,
                    totalSteps: 4,
                    icon: Icons.water_drop_rounded,
                    accentColor: AppColors.periodColor,
                    title: 'Period length',
                    subtitle:
                        'How many days you usually bleed (spotting can count if that’s normal for you).',
                    footerHint:
                        'This helps estimate your fertile window. Editable anytime in Profile.',
                    recap: _SetupRecapCard(
                      lastPeriod: _lastPeriodDate,
                      cycleDays: _cycleLength,
                      periodDays: _periodLength,
                    ),
                    child: _StepperNumberPicker(
                      value: _periodLength,
                      min: 2,
                      max: 10,
                      suffix: 'days',
                      accentColor: AppColors.periodColor,
                      onChanged: (v) => setState(() => _periodLength = v),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: PrimaryButton(
                title: _loading
                    ? 'Saving...'
                    : (_currentIndex == 3 ? 'Start Tracking' : 'Continue'),
                onPressed: _loading ? () {} : _next,
                enabled: !_loading,
                width: double.infinity,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// First step: visual welcome — not wrapped in the standard small card.
class _WelcomeOnboardingPage extends StatelessWidget {
  const _WelcomeOnboardingPage();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                color: Color.alphaBlend(
                  AppColors.primaryColor.withValues(
                    alpha: isDark ? 0.16 : 0.12,
                  ),
                  theme.colorScheme.surface,
                ),
                border: Border.all(
                  color: AppColors.primaryColor.withValues(alpha: 0.18),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryColor.withValues(alpha: 0.12),
                    blurRadius: 24,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    right: -20,
                    top: 40,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.ovulationColor.withValues(alpha: 0.12),
                      ),
                    ),
                  ),
                  Positioned(
                    left: -30,
                    bottom: 100,
                    child: Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.fertileColor.withValues(alpha: 0.1),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(22),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: theme.colorScheme.surface.withValues(
                                alpha: 0.9,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primaryColor.withValues(
                                    alpha: 0.15,
                                  ),
                                  blurRadius: 20,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.favorite_rounded,
                              size: 72,
                              color: AppColors.primaryColor,
                            ),
                          ),
                          const SizedBox(height: 28),
                          Text(
                            'Track your cycle',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'A calm space for predictions, daily logs, and insights — '
                            'with your data kept on this device.',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              height: 1.45,
                            ),
                          ),
                          const SizedBox(height: 28),
                          _WelcomeFeatureRow(
                            icon: Icons.lock_outline_rounded,
                            label: 'Private on-device',
                            color: AppColors.fertileColor,
                          ),
                          const SizedBox(height: 12),
                          _WelcomeFeatureRow(
                            icon: Icons.calendar_month_rounded,
                            label: 'Calendar & reminders',
                            color: AppColors.ovulationColor,
                          ),
                          const SizedBox(height: 12),
                          _WelcomeFeatureRow(
                            icon: Icons.auto_awesome_rounded,
                            label: 'Insights from your logs',
                            color: AppColors.insightColor,
                          ),
                          const SizedBox(height: 20),
                          Text(
                            '4 quick steps · about a minute',
                            style: theme.textTheme.labelMedium?.copyWith(
                              letterSpacing: 0.2,
                            ),
                          ),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WelcomeFeatureRow extends StatelessWidget {
  const _WelcomeFeatureRow({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.22)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Icon(
            Icons.check_circle_rounded,
            size: 18,
            color: color.withValues(alpha: 0.7),
          ),
        ],
      ),
    );
  }
}

class _StepIndicator extends StatelessWidget {
  const _StepIndicator({required this.current, required this.total});

  final int current;
  final int total;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(total, (index) {
        final active = index <= current;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: active ? 28 : 10,
          height: 10,
          decoration: BoxDecoration(
            color: active
                ? theme.primaryColor
                : theme.colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(10),
          ),
        );
      }),
    );
  }
}

/// Steps 2–4: shared chrome matching the welcome screen.
class _OnboardingStepShell extends StatelessWidget {
  const _OnboardingStepShell({
    required this.stepNumber,
    required this.totalSteps,
    required this.icon,
    required this.accentColor,
    required this.title,
    required this.subtitle,
    required this.child,
    this.footerHint,
    this.recap,
  });

  final int stepNumber;
  final int totalSteps;
  final IconData icon;
  final Color accentColor;
  final String title;
  final String subtitle;
  final Widget child;
  final String? footerHint;
  final Widget? recap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          color: Color.alphaBlend(
            accentColor.withValues(alpha: isDark ? 0.18 : 0.14),
            theme.colorScheme.surface,
          ),
          border: Border.all(color: accentColor.withValues(alpha: 0.22)),
          boxShadow: [
            BoxShadow(
              color: accentColor.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(icon, color: accentColor, size: 26),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        'Step $stepNumber of $totalSteps',
                        style: theme.textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Text(
                title,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                subtitle,
                style: theme.textTheme.bodyMedium?.copyWith(height: 1.45),
              ),
              if (recap != null) ...[const SizedBox(height: 16), recap!],
              const SizedBox(height: 12),
              Expanded(child: child),
              if (footerHint != null) ...[
                const SizedBox(height: 12),
                Text(
                  footerHint!,
                  style: AppTextStyle.bodyMedium.copyWith(
                    color: theme.colorScheme.onSurface,
                    height: 1.35,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _SetupRecapCard extends StatelessWidget {
  const _SetupRecapCard({
    required this.lastPeriod,
    required this.cycleDays,
    required this.periodDays,
  });

  final DateTime lastPeriod;
  final int cycleDays;
  final int periodDays;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final df = DateFormat.yMMMEd();

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.25),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your setup',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            _recapRow(
              theme,
              Icons.flag_outlined,
              'Last period started',
              df.format(lastPeriod),
            ),
            const SizedBox(height: 8),
            _recapRow(theme, Icons.repeat, 'Cycle length', '$cycleDays days'),
            const SizedBox(height: 8),
            _recapRow(
              theme,
              Icons.water_drop_outlined,
              'Bleeding length',
              '$periodDays days',
            ),
          ],
        ),
      ),
    );
  }

  Widget _recapRow(ThemeData theme, IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: theme.primaryColor),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: theme.textTheme.labelSmall?.copyWith()),
              Text(
                value,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DateOnboardingBody extends StatelessWidget {
  const _DateOnboardingBody({
    required this.selectedDate,
    required this.onChanged,
  });

  final DateTime selectedDate;
  final ValueChanged<DateTime> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final formatted = DateFormat.yMMMEd().format(selectedDate);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.ovulationColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.ovulationColor.withValues(alpha: 0.28),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Icon(
                  Icons.edit_calendar_rounded,
                  color: AppColors.ovulationColor,
                  size: 22,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Selected start day',
                        style: theme.textTheme.labelSmall?.copyWith(),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        formatted,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: ColoredBox(
              color: theme.colorScheme.surface,
              child: SingleChildScrollView(
                child: CalendarDatePicker(
                  key: ValueKey<String>(
                    '${selectedDate.year}-${selectedDate.month}-${selectedDate.day}',
                  ),
                  initialDate: selectedDate,
                  firstDate: DateTime(2010),
                  lastDate: DateTime.now(),
                  onDateChanged: (date) => onChanged(dateOnly(date)),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _StepperNumberPicker extends StatelessWidget {
  const _StepperNumberPicker({
    required this.value,
    required this.min,
    required this.max,
    required this.suffix,
    required this.accentColor,
    required this.onChanged,
  });

  final int value;
  final int min;
  final int max;
  final String suffix;
  final Color accentColor;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$min–$max $suffix',
              style: theme.textTheme.labelMedium?.copyWith(),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _RoundIconButton(
                  icon: Icons.remove_rounded,
                  accentColor: accentColor,
                  onPressed: value > min ? () => onChanged(value - 1) : null,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      Text(
                        '$value',
                        style: theme.textTheme.displaySmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: accentColor,
                          height: 1,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        suffix,
                        style: theme.textTheme.titleMedium?.copyWith(),
                      ),
                    ],
                  ),
                ),
                _RoundIconButton(
                  icon: Icons.add_rounded,
                  accentColor: accentColor,
                  onPressed: value < max ? () => onChanged(value + 1) : null,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({
    required this.icon,
    required this.accentColor,
    required this.onPressed,
  });

  final IconData icon;
  final Color accentColor;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final enabled = onPressed != null;

    return Material(
      color: enabled
          ? accentColor.withValues(alpha: 0.14)
          : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: SizedBox(
          width: 52,
          height: 52,
          child: Icon(
            icon,
            color: enabled
                ? accentColor
                : theme.colorScheme.onSurface.withValues(alpha: 0.38),
            size: 28,
          ),
        ),
      ),
    );
  }
}
