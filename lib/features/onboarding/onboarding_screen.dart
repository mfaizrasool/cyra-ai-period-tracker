import 'package:cyra_ai_period_tracker/common/controllers/preference_controller.dart';
import 'package:cyra_ai_period_tracker/core/utils/date_utils.dart';
import 'package:cyra_ai_period_tracker/utils/preference_labels.dart';
import 'package:cyra_ai_period_tracker/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
  DateTime _lastPeriodDate =
      dateOnly(DateTime.now().subtract(const Duration(days: 28)));
  int _cycleLength = 28;
  int _periodLength = 5;
  bool _loading = false;

  Future<void> _completeOnboarding() async {
    setState(() => _loading = true);
    await _prefs.setBool(key: AppPreferenceLabels.isOnboardingComplete, value: true);
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Welcome to Cyra'),
        centerTitle: true,
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
                  _OnboardingPageCard(
                    title: 'Track your cycle simply',
                    subtitle:
                        'Private, easy, and AI-enhanced period tracking with a clean experience.',
                    child: Icon(
                      Icons.favorite_rounded,
                      size: 90,
                      color: theme.primaryColor,
                    ),
                  ),
                  _OnboardingPageCard(
                    title: 'When did your last period start?',
                    subtitle: 'Select the first day of your most recent period.',
                    child: CalendarDatePicker(
                      initialDate: _lastPeriodDate,
                      firstDate: DateTime(2010),
                      lastDate: DateTime.now(),
                      onDateChanged: (date) =>
                          setState(() => _lastPeriodDate = dateOnly(date)),
                    ),
                  ),
                  _OnboardingPageCard(
                    title: 'Average cycle length',
                    subtitle: 'Number of days from one period start to the next.',
                    child: _NumberPickerTile(
                      value: _cycleLength,
                      min: 21,
                      max: 45,
                      suffix: 'days',
                      onChanged: (v) => setState(() => _cycleLength = v),
                    ),
                  ),
                  _OnboardingPageCard(
                    title: 'Average period length',
                    subtitle: 'How many days your period usually lasts.',
                    child: _NumberPickerTile(
                      value: _periodLength,
                      min: 2,
                      max: 10,
                      suffix: 'days',
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

class _OnboardingPageCard extends StatelessWidget {
  const _OnboardingPageCard({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: theme.textTheme.titleLarge),
              const SizedBox(height: 8),
              Text(subtitle, style: theme.textTheme.bodyMedium),
              const SizedBox(height: 18),
              Expanded(child: child),
            ],
          ),
        ),
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
            color: active ? theme.primaryColor : theme.colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(10),
          ),
        );
      }),
    );
  }
}

class _NumberPickerTile extends StatelessWidget {
  const _NumberPickerTile({
    required this.value,
    required this.min,
    required this.max,
    required this.suffix,
    required this.onChanged,
  });

  final int value;
  final int min;
  final int max;
  final String suffix;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final items = List.generate(max - min + 1, (index) => min + index);
    return Column(
      children: [
        DropdownButtonFormField<int>(
          key: ValueKey(value),
          initialValue: value,
          items: items
              .map((v) => DropdownMenuItem(value: v, child: Text('$v $suffix')))
              .toList(),
          onChanged: (v) {
            if (v != null) onChanged(v);
          },
          decoration: const InputDecoration(labelText: 'Select'),
        ),
        const Spacer(),
      ],
    );
  }
}
