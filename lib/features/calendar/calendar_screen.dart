import 'package:cyra_ai_period_tracker/core/services/cycle_prediction_service.dart';
import 'package:cyra_ai_period_tracker/core/utils/date_utils.dart';
import 'package:cyra_ai_period_tracker/data/models/period_log.dart';
import 'package:cyra_ai_period_tracker/features/home/cycle_controller.dart';
import 'package:cyra_ai_period_tracker/utils/theme/constants/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final CycleController _cycleController = Get.find<CycleController>();
  final CyclePredictionService _predictionService = CyclePredictionService();

  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Obx(() {
                final logs = _cycleController.loggedPeriods.toList();
                final nextPeriod = dateOnly(_cycleController.nextPeriodDate.value);
                final fertileWindow = _cycleController.fertileWindow.toList();
                final ovulation = dateOnly(_cycleController.ovulationDate.value);

                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TableCalendar<void>(
                      firstDay: DateTime(2020, 1, 1),
                      lastDay: DateTime(2035, 12, 31),
                      focusedDay: _focusedDay,
                      selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                      onDaySelected: (selectedDay, focusedDay) {
                        setState(() {
                          _selectedDay = selectedDay;
                          _focusedDay = focusedDay;
                        });
                        _showDaySheet(context, selectedDay, logs);
                      },
                      onPageChanged: (focusedDay) {
                        _focusedDay = focusedDay;
                      },
                      calendarStyle: const CalendarStyle(
                        outsideDaysVisible: false,
                      ),
                      headerStyle: const HeaderStyle(
                        formatButtonVisible: false,
                        titleCentered: true,
                      ),
                      calendarBuilders: CalendarBuilders(
                        defaultBuilder: (context, day, focusedDay) {
                          return _buildCell(
                            day,
                            logs,
                            nextPeriod,
                            fertileWindow,
                            ovulation,
                            theme,
                          );
                        },
                      ),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 8),
            Expanded(child: _buildLegend()),
          ],
        ),
      ),
    );
  }

  Future<void> _showDaySheet(
    BuildContext context,
    DateTime day,
    List<PeriodLog> logs,
  ) async {
    final d = dateOnly(day);
    PeriodLog? log;
    for (final l in logs) {
      if (isSameDay(l.date, d)) {
        log = l;
        break;
      }
    }
    final bleeding = (log?.flowLevel ?? 0) > 0;
    final flowNames = ['None', 'Spotting', 'Light', 'Medium', 'Heavy'];

    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}',
                  style: Theme.of(ctx).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  bleeding
                      ? 'Logged bleeding: ${flowNames[(log?.flowLevel ?? 0).clamp(0, flowNames.length - 1)]}.'
                      : 'No bleeding logged for this day.',
                ),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Close'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCell(
    DateTime day,
    List<PeriodLog> logs,
    DateTime nextPeriod,
    List<DateTime> fertileWindow,
    DateTime ovulation,
    ThemeData theme,
  ) {
    final isLoggedBleeding = logs.any(
      (log) => isSameDay(log.date, day) && log.flowLevel > 0,
    );

    late final Widget inner;
    if (isLoggedBleeding) {
      inner = _circleMarker(AppColors.periodColor, day.day.toString(), Colors.white);
    } else if (_predictionService.isPredictedPeriodDay(
      day,
      nextPeriod,
      _cycleController.avgPeriodLength.value,
    )) {
      inner = _outlinedMarker(
        AppColors.periodColor,
        day.day.toString(),
        theme.textTheme.bodyMedium!.color!,
      );
    } else if (isSameDay(day, ovulation)) {
      inner = _circleMarker(AppColors.ovulationColor, day.day.toString(), Colors.white);
    } else if (fertileWindow.any((x) => isSameDay(x, day))) {
      inner = _outlinedMarker(
        AppColors.fertileColor,
        day.day.toString(),
        theme.textTheme.bodyMedium!.color!,
      );
    } else {
      inner = Center(child: Text('${day.day}'));
    }

    if (isSameDay(day, DateTime.now())) {
      return Container(
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: theme.primaryColor, width: 2),
        ),
        child: inner,
      );
    }
    return inner;
  }

  Widget _circleMarker(Color color, String text, Color textColor) {
    return Container(
      margin: const EdgeInsets.all(6.0),
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(text, style: TextStyle(color: textColor)),
      ),
    );
  }

  Widget _outlinedMarker(Color color, String text, Color textColor) {
    return Container(
      margin: const EdgeInsets.all(6.0),
      decoration: BoxDecoration(
        border: Border.all(color: color, width: 2),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(text, style: TextStyle(color: textColor)),
      ),
    );
  }

  Widget _buildLegend() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: ListView(
        children: [
          _legendItem(AppColors.periodColor, 'Logged period'),
          _legendItem(AppColors.periodColor, 'Predicted period', outlined: true),
          _legendItem(AppColors.fertileColor, 'Fertile window', outlined: true),
          _legendItem(AppColors.ovulationColor, 'Ovulation'),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primaryColor, width: 2),
                ),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text('Ring = today', style: TextStyle(fontSize: 12)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _legendItem(Color color, String label, {bool outlined = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: outlined
                ? BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: color, width: 2),
                  )
                : BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(label, style: const TextStyle(fontSize: 12))),
        ],
      ),
    );
  }
}
