import 'package:cyra_ai_period_tracker/data/models/daily_log.dart';
import 'package:cyra_ai_period_tracker/utils/theme/constants/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection;

class PainLineChart extends StatelessWidget {
  const PainLineChart({super.key, required this.dailyLogs});

  final List<DailyLog> dailyLogs;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Filter logs that have pain levels
    final painLogs = dailyLogs
        .where((log) => log.painLevel != null)
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    // Display last 7 logs to keep it legible
    final recentLogs = painLogs.length > 7
        ? painLogs.sublist(painLogs.length - 7)
        : painLogs;

    if (recentLogs.isEmpty) {
      return Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: theme.dividerColor),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 16),
          child: Column(
            children: [
              Icon(
                Icons.insights_outlined,
                size: 44,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.38),
              ),
              const SizedBox(height: 12),
              Text(
                'No pain logs recorded yet',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Log your daily pain levels on the Log tab to see trends here.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Pain timeline',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Last ${recentLogs.length} logs',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 180,
              width: double.infinity,
              child: CustomPaint(
                painter: _PainChartPainter(
                  logs: recentLogs,
                  theme: theme,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PainChartPainter extends CustomPainter {
  _PainChartPainter({required this.logs, required this.theme});

  final List<DailyLog> logs;
  final ThemeData theme;

  @override
  void paint(Canvas canvas, Size size) {
    const leftPadding = 24.0;
    const rightPadding = 16.0;
    const topPadding = 16.0;
    const bottomPadding = 24.0;

    final graphWidth = size.width - leftPadding - rightPadding;
    final graphHeight = size.height - topPadding - bottomPadding;

    final double stepX = logs.length > 1 ? graphWidth / (logs.length - 1) : graphWidth;

    // Paint for Grid lines
    final gridPaint = Paint()
      ..color = theme.dividerColor.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Text configuration for labels
    final labelStyle = theme.textTheme.labelSmall?.copyWith(
      color: theme.colorScheme.onSurface.withValues(alpha: 0.45),
      fontSize: 9,
    ) ?? const TextStyle(fontSize: 9);

    // Draw horizontal grid lines (Pain level 0, 5, 10)
    final gridLevels = [0, 5, 10];
    for (final level in gridLevels) {
      final y = topPadding + graphHeight - (level / 10.0) * graphHeight;

      // Draw horizontal line
      canvas.drawLine(
        Offset(leftPadding, y),
        Offset(leftPadding + graphWidth, y),
        gridPaint,
      );

      // Draw Y-axis text labels
      final textSpan = TextSpan(text: '$level', style: labelStyle);
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      )..layout();
      textPainter.paint(
        canvas,
        Offset(leftPadding - textPainter.width - 6, y - textPainter.height / 2),
      );
    }

    // Prepare path for the bezier curve
    final path = Path();
    final fillPath = Path();

    final points = <Offset>[];
    for (int i = 0; i < logs.length; i++) {
      final pain = logs[i].painLevel ?? 0;
      final x = leftPadding + i * stepX;
      final y = topPadding + graphHeight - (pain / 10.0) * graphHeight;
      points.add(Offset(x, y));
    }

    if (points.isNotEmpty) {
      path.moveTo(points.first.dx, points.first.dy);
      fillPath.moveTo(points.first.dx, topPadding + graphHeight);
      fillPath.lineTo(points.first.dx, points.first.dy);

      for (int i = 0; i < points.length - 1; i++) {
        final p0 = points[i];
        final p1 = points[i + 1];

        // Draw cubic bezier curve for smooth aesthetics
        final controlPoint1 = Offset(p0.dx + (p1.dx - p0.dx) / 2, p0.dy);
        final controlPoint2 = Offset(p0.dx + (p1.dx - p0.dx) / 2, p1.dy);

        path.cubicTo(
          controlPoint1.dx,
          controlPoint1.dy,
          controlPoint2.dx,
          controlPoint2.dy,
          p1.dx,
          p1.dy,
        );

        fillPath.cubicTo(
          controlPoint1.dx,
          controlPoint1.dy,
          controlPoint2.dx,
          controlPoint2.dy,
          p1.dx,
          p1.dy,
        );
      }

      fillPath.lineTo(points.last.dx, topPadding + graphHeight);
      fillPath.close();

      // Paint gradient fill under the line
      final gradientPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.insightColor.withValues(alpha: 0.28),
            AppColors.insightColor.withValues(alpha: 0.0),
          ],
        ).createShader(Rect.fromLTRB(
          leftPadding,
          topPadding,
          leftPadding + graphWidth,
          topPadding + graphHeight,
        ))
        ..style = PaintingStyle.fill;
      canvas.drawPath(fillPath, gradientPaint);

      // Paint for graph line
      final linePaint = Paint()
        ..color = AppColors.insightColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0
        ..strokeCap = StrokeCap.round;
      canvas.drawPath(path, linePaint);

      // Paint data points (dots) and tooltips
      final dotPaint = Paint()
        ..color = AppColors.insightColor
        ..style = PaintingStyle.fill;

      final dotOuterPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;

      final valLabelStyle = theme.textTheme.labelMedium?.copyWith(
        color: AppColors.insightColor,
        fontWeight: FontWeight.bold,
        fontSize: 10,
      ) ?? const TextStyle(fontSize: 10, fontWeight: FontWeight.bold);

      for (int i = 0; i < points.length; i++) {
        final pt = points[i];
        final log = logs[i];

        // Draw shadow/outer ring
        canvas.drawCircle(pt, 5.0, dotOuterPaint);
        // Draw dot center
        canvas.drawCircle(pt, 4.0, dotPaint);

        // Draw the pain value label just above the point
        final valSpan = TextSpan(text: '${log.painLevel}', style: valLabelStyle);
        final valPainter = TextPainter(
          text: valSpan,
          textDirection: TextDirection.ltr,
        )..layout();
        valPainter.paint(
          canvas,
          Offset(pt.dx - valPainter.width / 2, pt.dy - valPainter.height - 4),
        );

        // Draw date label underneath on X-axis
        final dateStr = DateFormat('MMM d').format(log.date);
        final dateSpan = TextSpan(text: dateStr, style: labelStyle);
        final datePainter = TextPainter(
          text: dateSpan,
          textDirection: TextDirection.ltr,
        )..layout();
        datePainter.paint(
          canvas,
          Offset(
            pt.dx - datePainter.width / 2,
            topPadding + graphHeight + 6,
          ),
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _PainChartPainter oldDelegate) {
    return oldDelegate.logs != logs;
  }
}
