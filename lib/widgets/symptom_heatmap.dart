import 'package:cyra_ai_period_tracker/core/utils/date_utils.dart';
import 'package:cyra_ai_period_tracker/data/models/daily_log.dart';
import 'package:cyra_ai_period_tracker/utils/theme/constants/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SymptomHeatmap extends StatefulWidget {
  const SymptomHeatmap({super.key, required this.dailyLogs});

  final List<DailyLog> dailyLogs;

  @override
  State<SymptomHeatmap> createState() => _SymptomHeatmapState();
}

class _SymptomHeatmapState extends State<SymptomHeatmap> {
  DateTime? _selectedDate;
  DailyLog? _selectedLog;

  // Generate the list of the last 28 days (4 weeks) to display as a grid
  late final List<DateTime> _gridDates;

  @override
  void initState() {
    super.initState();
    final today = dateOnly(DateTime.now());
    _gridDates = List.generate(28, (index) {
      return today.subtract(Duration(days: 27 - index));
    });
    _selectedDate = today;
    _selectedLog = _findLogForDate(today);
  }

  DailyLog? _findLogForDate(DateTime date) {
    for (final log in widget.dailyLogs) {
      if (isSameCalendarDay(log.date, date)) {
        return log;
      }
    }
    return null;
  }

  void _onCellTapped(DateTime date) {
    setState(() {
      _selectedDate = date;
      _selectedLog = _findLogForDate(date);
    });
  }

  int _getSymptomCount(DailyLog? log) {
    if (log == null || log.symptoms.trim().isEmpty) return 0;
    return log.symptoms.split(',').where((s) => s.trim().isNotEmpty).length;
  }

  Color _getCellColor(int count, ThemeData theme) {
    if (count == 0) {
      return theme.brightness == Brightness.dark
          ? AppDarkThemeColors.lightGreyColor.withValues(alpha: 0.4)
          : AppLightThemeColors.lightGreyColor.withValues(alpha: 0.5);
    }
    if (count == 1) {
      return AppColors.insightColor.withValues(alpha: 0.25);
    }
    if (count == 2) {
      return AppColors.insightColor.withValues(alpha: 0.5);
    }
    if (count == 3) {
      return AppColors.insightColor.withValues(alpha: 0.75);
    }
    return AppColors.insightColor;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.dividerColor),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Symptom frequency heatmap',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Grid displays symptom density over the last 4 weeks. Tap a square to inspect details.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 20),

            // Heatmap Grid: 4 rows (weeks), 7 columns (days of the week)
            Center(
              child: SizedBox(
                width: 280,
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 7,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: _gridDates.length,
                  itemBuilder: (context, index) {
                    final date = _gridDates[index];
                    final log = _findLogForDate(date);
                    final count = _getSymptomCount(log);
                    final cellColor = _getCellColor(count, theme);
                    final isSelected = _selectedDate != null && isSameCalendarDay(_selectedDate!, date);
                    final isToday = isSameCalendarDay(DateTime.now(), date);

                    return GestureDetector(
                      onTap: () => _onCellTapped(date),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        decoration: BoxDecoration(
                          color: cellColor,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: isSelected
                                ? theme.primaryColor
                                : isToday
                                    ? theme.primaryColor.withValues(alpha: 0.5)
                                    : Colors.transparent,
                            width: isSelected ? 2.5 : (isToday ? 1.5 : 0),
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: theme.primaryColor.withValues(alpha: 0.3),
                                    blurRadius: 4,
                                    spreadRadius: 1,
                                  )
                                ]
                              : null,
                        ),
                        child: Center(
                          child: Text(
                            '${date.day}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontSize: 10,
                              fontWeight: isToday || isSelected ? FontWeight.bold : FontWeight.normal,
                              color: count > 2
                                  ? Colors.white
                                  : theme.colorScheme.onSurface.withValues(alpha: count > 0 ? 0.9 : 0.45),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            const SizedBox(height: 16),
            // Legend
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Less', style: theme.textTheme.labelSmall?.copyWith(fontSize: 10)),
                const SizedBox(width: 6),
                _legendSquare(0, theme),
                const SizedBox(width: 4),
                _legendSquare(1, theme),
                const SizedBox(width: 4),
                _legendSquare(2, theme),
                const SizedBox(width: 4),
                _legendSquare(3, theme),
                const SizedBox(width: 4),
                _legendSquare(4, theme),
                const SizedBox(width: 6),
                Text('More', style: theme.textTheme.labelSmall?.copyWith(fontSize: 10)),
              ],
            ),

            const SizedBox(height: 20),
            // Inspection Card
            if (_selectedDate != null) ...[
              Divider(color: theme.dividerColor, height: 1),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    DateFormat('EEEE, MMM d').format(_selectedDate!),
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (isSameCalendarDay(DateTime.now(), _selectedDate!))
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: theme.primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'TODAY',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 9,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              if (_selectedLog != null && _selectedLog!.symptoms.isNotEmpty) ...[
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: _selectedLog!.symptoms.split(',').map((s) {
                    final symptom = s.trim();
                    return Chip(
                      labelPadding: const EdgeInsets.symmetric(horizontal: 4),
                      visualDensity: VisualDensity.compact,
                      label: Text(symptom, style: const TextStyle(fontSize: 11)),
                      backgroundColor: theme.colorScheme.secondaryContainer.withValues(alpha: 0.5),
                      side: BorderSide.none,
                    );
                  }).toList(),
                ),
                if (_selectedLog!.mood.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.mood_outlined, size: 14, color: theme.primaryColor),
                      const SizedBox(width: 6),
                      Text(
                        'Mood: ${_selectedLog!.mood}',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ],
              ] else ...[
                Text(
                  'No symptoms logged for this date.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _legendSquare(int count, ThemeData theme) {
    return Container(
      width: 14,
      height: 14,
      decoration: BoxDecoration(
        color: _getCellColor(count, theme),
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }
}
