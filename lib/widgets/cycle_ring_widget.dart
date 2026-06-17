import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';

import 'package:cyra_ai_period_tracker/core/cycle/cycle_phase_helper.dart';
import 'package:cyra_ai_period_tracker/core/utils/date_utils.dart';
import 'package:cyra_ai_period_tracker/utils/theme/constants/app_constants.dart';
import 'package:flutter/material.dart';

class CycleRingWidget extends StatefulWidget {
  const CycleRingWidget({
    super.key,
    required this.avgCycleLength,
    required this.avgPeriodLength,
    required this.currentCycleDay,
    required this.periodDayInBleeding,
    required this.daysUntilNextPeriod,
    required this.ovulationDate,
    required this.nextPeriodDate,
    required this.lastPeriodStartDate,
    required this.fertileWindow,
    required this.phase,
    required this.onLogPeriodTap,
  });

  final int avgCycleLength;
  final int avgPeriodLength;
  final int currentCycleDay;
  final int? periodDayInBleeding;
  final int daysUntilNextPeriod;
  final DateTime ovulationDate;
  final DateTime nextPeriodDate;
  final DateTime lastPeriodStartDate;
  final List<DateTime> fertileWindow;
  final CyclePhaseInfo phase;
  final VoidCallback onLogPeriodTap;

  @override
  State<CycleRingWidget> createState() => _CycleRingWidgetState();
}

class _CycleRingWidgetState extends State<CycleRingWidget> {
  int? _exploredDay;
  Timer? _resetTimer;
  bool _isExploring = false;

  @override
  void dispose() {
    _resetTimer?.cancel();
    super.dispose();
  }

  void _handleGesture(Offset localPosition, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final dx = localPosition.dx - center.dx;
    final dy = localPosition.dy - center.dy;

    // Calculate angle from center in radians, shifting so 0 is at -pi/2 (top)
    double angle = math.atan2(dy, dx) + math.pi / 2;
    if (angle < 0) {
      angle += 2 * math.pi;
    }

    // Convert angle to cycle day
    int day = ((angle / (2 * math.pi)) * widget.avgCycleLength).round() + 1;
    day = day.clamp(1, widget.avgCycleLength);

    setState(() {
      _exploredDay = day;
      _isExploring = true;
    });

    _resetTimer?.cancel();
    _resetTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _exploredDay = null;
          _isExploring = false;
        });
      }
    });
  }

  // Helper to determine the phase of any given cycle day
  CyclePhaseInfo _resolvePhaseForDay(int day) {
    // Determine the date for the selected day in this cycle
    final date = widget.lastPeriodStartDate.add(Duration(days: day - 1));

    // Calculate if it falls under bleeding
    int? bleedDay;
    if (day <= widget.avgPeriodLength) {
      bleedDay = day;
    }

    return CyclePhaseInfo.resolve(
      today: date,
      ovulationDate: widget.ovulationDate,
      fertileWindow: widget.fertileWindow,
      periodDayInBleeding: bleedDay,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final ringSize = math.min(size.width * 0.72, 280.0);

    final activeDay = _exploredDay ?? widget.currentCycleDay;
    final activePhase = _resolvePhaseForDay(activeDay);

    // Get info text for the center
    String centerTitle = '';
    String centerSubtitle = '';
    Color centerColor = activePhase.accentColor;

    if (_isExploring) {
      centerTitle = 'Day $activeDay';
      centerSubtitle = activePhase.title;
    } else {
      if (widget.periodDayInBleeding != null) {
        centerTitle = 'Period';
        centerSubtitle = 'Day ${widget.periodDayInBleeding}';
      } else {
        centerTitle = 'Day $activeDay';
        centerSubtitle = activePhase.title;
      }
    }

    // Next event text
    String nextEventText = '';
    if (!_isExploring) {
      if (widget.daysUntilNextPeriod > 0) {
        nextEventText = 'Next period in ${widget.daysUntilNextPeriod}d';
      } else if (widget.daysUntilNextPeriod == 0) {
        nextEventText = 'Period starts today';
      } else {
        nextEventText = 'Period late by ${-widget.daysUntilNextPeriod}d';
      }
    } else {
      nextEventText = 'Tap to explore cycle';
    }

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onPanUpdate: (details) => _handleGesture(details.localPosition, Size(ringSize, ringSize)),
            onPanDown: (details) => _handleGesture(details.localPosition, Size(ringSize, ringSize)),
            child: Container(
              width: ringSize,
              height: ringSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: centerColor.withValues(alpha: 0.12),
                    blurRadius: 36,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // The Custom Painted Ring
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _CycleRingPainter(
                        avgCycleLength: widget.avgCycleLength,
                        avgPeriodLength: widget.avgPeriodLength,
                        currentDay: activeDay,
                        ovulationDayIndex: calendarDaysBetween(widget.ovulationDate, widget.lastPeriodStartDate) + 1,
                        theme: theme,
                        glowColor: centerColor,
                      ),
                    ),
                  ),

                  // Glassmorphic Inner Center
                  ClipOval(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                      child: Container(
                        width: ringSize * 0.76,
                        height: ringSize * 0.76,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: theme.colorScheme.surface.withValues(alpha: theme.brightness == Brightness.dark ? 0.35 : 0.65),
                          border: Border.all(
                            color: theme.colorScheme.outline.withValues(alpha: 0.18),
                            width: 1.5,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              AnimatedDefaultTextStyle(
                                duration: const Duration(milliseconds: 180),
                                style: theme.textTheme.headlineMedium!.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: centerColor,
                                  letterSpacing: -0.5,
                                ),
                                child: Text(centerTitle),
                              ),
                              const SizedBox(height: 4),
                              AnimatedDefaultTextStyle(
                                duration: const Duration(milliseconds: 180),
                                style: theme.textTheme.titleSmall!.copyWith(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                  color: theme.colorScheme.onSurface,
                                ),
                                child: Text(
                                  centerSubtitle,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                nextEventText,
                                style: theme.textTheme.labelMedium!.copyWith(
                                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                                  fontSize: 11,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Exploration reset indicator or context
          AnimatedOpacity(
            opacity: _isExploring ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 200),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: theme.colorScheme.secondaryContainer.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Release to show today',
                style: theme.textTheme.labelSmall!.copyWith(
                  color: theme.colorScheme.onSecondaryContainer,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CycleRingPainter extends CustomPainter {
  _CycleRingPainter({
    required this.avgCycleLength,
    required this.avgPeriodLength,
    required this.currentDay,
    required this.ovulationDayIndex,
    required this.theme,
    required this.glowColor,
  });

  final int avgCycleLength;
  final int avgPeriodLength;
  final int currentDay;
  final int ovulationDayIndex;
  final ThemeData theme;
  final Color glowColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 12;
    const strokeWidth = 14.0;

    // Draw background track
    final bgPaint = Paint()
      ..color = theme.colorScheme.surfaceContainerHighest.withValues(alpha: theme.brightness == Brightness.dark ? 0.15 : 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawCircle(center, radius, bgPaint);

    // Calculate phase boundaries
    // Menstrual: Days 1 to avgPeriodLength
    // Fertile window: ovulationDayIndex - 5 to ovulationDayIndex + 1
    // Ovulation: ovulationDayIndex
    // Follicular: between Menstrual end and Fertile start
    // Luteal: between Fertile end and avgCycleLength

    final fertileStart = ovulationDayIndex - 5;
    final fertileEnd = ovulationDayIndex + 1;

    for (int day = 1; day <= avgCycleLength; day++) {
      // Find arc sweep for this specific day
      final double startAngle = -math.pi / 2 + ((day - 1) / avgCycleLength) * 2 * math.pi;
      final double sweepAngle = (1.0 / avgCycleLength) * 2 * math.pi - 0.02; // Small gap between segments

      Color segmentColor;
      if (day <= avgPeriodLength) {
        segmentColor = AppColors.periodColor;
      } else if (day == ovulationDayIndex) {
        segmentColor = AppColors.ovulationColor;
      } else if (day >= fertileStart && day <= fertileEnd) {
        segmentColor = AppColors.fertileColor;
      } else if (day < fertileStart) {
        segmentColor = AppColors.insightColor;
      } else {
        segmentColor = AppColors.greyColor;
      }

      final paint = Paint()
        ..color = segmentColor.withValues(alpha: 0.8)
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = strokeWidth;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        paint,
      );
    }

    // Draw the active/current day cursor dot
    final double cursorAngle = -math.pi / 2 + ((currentDay - 0.5) / avgCycleLength) * 2 * math.pi;
    final cursorX = center.dx + radius * math.cos(cursorAngle);
    final cursorY = center.dy + radius * math.sin(cursorAngle);
    final cursorCenter = Offset(cursorX, cursorY);

    // Outer glow for cursor
    final glowPaint = Paint()
      ..color = glowColor.withValues(alpha: 0.6)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawCircle(cursorCenter, 13.0, glowPaint);

    // Main cursor dot
    final cursorPaint = Paint()
      ..color = glowColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(cursorCenter, 8.0, cursorPaint);

    // White core for pointer definition
    final corePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(cursorCenter, 4.0, corePaint);
  }

  @override
  bool shouldRepaint(covariant _CycleRingPainter oldDelegate) {
    return oldDelegate.avgCycleLength != avgCycleLength ||
        oldDelegate.avgPeriodLength != avgPeriodLength ||
        oldDelegate.currentDay != currentDay ||
        oldDelegate.ovulationDayIndex != ovulationDayIndex ||
        oldDelegate.glowColor != glowColor;
  }
}
