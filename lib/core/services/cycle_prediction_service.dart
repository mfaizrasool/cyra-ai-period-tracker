import 'package:cyra_ai_period_tracker/core/utils/date_utils.dart';
import 'package:cyra_ai_period_tracker/data/models/period_log.dart';

class CyclePredictionService {
  /// Next period start = last period start + average cycle length (calendar days).
  DateTime predictNextPeriod(DateTime lastPeriodStart, int avgCycleLength) {
    return dateOnly(lastPeriodStart).add(Duration(days: avgCycleLength));
  }

  /// Ovulation estimate = next period - 14 days.
  DateTime predictOvulation(DateTime nextPeriodDate) {
    return dateOnly(nextPeriodDate).subtract(const Duration(days: 14));
  }

  /// Fertile window: ovulation - 5 through ovulation + 1 (inclusive range).
  List<DateTime> predictFertileWindow(DateTime ovulationDate) {
    final o = dateOnly(ovulationDate);
    final start = o.subtract(const Duration(days: 5));
    final fertileDays = <DateTime>[];
    for (int i = 0; i <= 6; i++) {
      fertileDays.add(start.add(Duration(days: i)));
    }
    return fertileDays;
  }

  /// Whether [date] falls in the predicted bleeding window (inclusive).
  bool isPredictedPeriodDay(
    DateTime date,
    DateTime nextPeriodStart,
    int avgPeriodLength,
  ) {
    final d = dateOnly(date);
    final start = dateOnly(nextPeriodStart);
    final end = start.add(Duration(days: avgPeriodLength - 1));
    return !d.isBefore(start) && !d.isAfter(end);
  }

  /// Infer last period **start** from logged bleeding days by clustering consecutive calendar days
  /// and taking the first day of the most recent cluster.
  DateTime? inferLastPeriodStartFromLogs(List<PeriodLog> logs) {
    if (logs.isEmpty) return null;

    final days = logs.map((l) => dateOnly(l.date)).toList()..sort();
    final clusters = <List<DateTime>>[];
    List<DateTime> current = [days.first];

    for (int i = 1; i < days.length; i++) {
      final prev = current.last;
      final next = days[i];
      if (calendarDaysBetween(next, prev) == 1) {
        current.add(next);
      } else {
        clusters.add(List<DateTime>.from(current));
        current = [next];
      }
    }
    clusters.add(current);

    final lastCluster = clusters.last;
    return lastCluster.first;
  }

  /// If today is inside the latest bleeding cluster, returns 1-based day index within that cluster.
  int? currentPeriodDayInCluster(List<PeriodLog> logs, DateTime today) {
    if (logs.isEmpty) return null;
    final t = dateOnly(today);
    final days = logs.map((l) => dateOnly(l.date)).toSet();
    if (!days.contains(t)) return null;

    final sorted = days.toList()..sort();
    final clusters = <List<DateTime>>[];
    List<DateTime> current = [sorted.first];
    for (int i = 1; i < sorted.length; i++) {
      final prev = current.last;
      final next = sorted[i];
      if (calendarDaysBetween(next, prev) == 1) {
        current.add(next);
      } else {
        clusters.add(List<DateTime>.from(current));
        current = [next];
      }
    }
    clusters.add(current);

    final lastCluster = clusters.last;
    if (!lastCluster.contains(t)) return null;
    return lastCluster.indexOf(t) + 1;
  }
}
