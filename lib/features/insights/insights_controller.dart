import 'dart:math' as math;

import 'package:cyra_ai_period_tracker/core/utils/date_utils.dart';
import 'package:cyra_ai_period_tracker/data/db/app_database.dart';
import 'package:cyra_ai_period_tracker/data/models/period_log.dart';
import 'package:get/get.dart';

class InsightsController extends GetxController {
  final AppDatabase _db = AppDatabase.instance;

  final RxString regularityLabel = ''.obs;
  final RxList<String> topSymptoms = <String>[].obs;
  final RxList<String> topMoods = <String>[].obs;
  final RxString painSummaryLabel = ''.obs;
  /// Days with any daily log row (symptoms, mood, notes, or pain).
  final RxInt dailyLogEntryCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    regularityLabel.value = 'Loading insights…';
    painSummaryLabel.value = 'Loading…';
    load();
  }

  Future<void> load() async {
    final daily = await _db.getAllDailyLogs();
    final counts = <String, int>{};
    for (final row in daily) {
      if (row.symptoms.isEmpty) continue;
      for (final s in row.symptoms.split(',')) {
        final t = s.trim();
        if (t.isEmpty) continue;
        counts[t] = (counts[t] ?? 0) + 1;
      }
    }
    final sorted = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    topSymptoms.assignAll(sorted.take(5).map((e) => '${e.key} (${e.value}×)').toList());

    final moodCounts = <String, int>{};
    for (final row in daily) {
      final m = row.mood.trim();
      if (m.isEmpty) continue;
      moodCounts[m] = (moodCounts[m] ?? 0) + 1;
    }
    final moodsSorted = moodCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    topMoods.assignAll(moodsSorted.take(5).map((e) => '${e.key} (${e.value}×)').toList());

    dailyLogEntryCount.value = daily.where((d) {
      final hasSymptoms = d.symptoms.trim().isNotEmpty;
      final hasMood = d.mood.trim().isNotEmpty;
      final hasNotes = d.notes.trim().isNotEmpty;
      final hasPain = d.painLevel != null;
      return hasSymptoms || hasMood || hasNotes || hasPain;
    }).length;

    final withPain = daily.where((d) => d.painLevel != null).toList();
    if (withPain.isEmpty) {
      painSummaryLabel.value = 'Log pain levels on the Log tab to see averages here.';
    } else {
      final sum = withPain.fold<double>(0, (a, d) => a + (d.painLevel ?? 0));
      final avg = sum / withPain.length;
      painSummaryLabel.value =
          'Average pain when logged: ${avg.toStringAsFixed(1)} / 10 (over ${withPain.length} days).';
    }

    final periods = await _db.getAllPeriodLogs();
    final bleeding = periods.where((p) => p.flowLevel > 0).toList();
    regularityLabel.value = _computeRegularity(bleeding);
  }

  String _computeRegularity(List<PeriodLog> bleeding) {
    if (bleeding.length < 2) {
      return 'Log bleeding days across more than one cycle to see regularity.';
    }
    final days = bleeding.map((l) => dateOnly(l.date)).toList()..sort();
    final clusters = <List<DateTime>>[];
    var current = <DateTime>[days.first];
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

    final starts = clusters.map((c) => c.first).toList()..sort();
    if (starts.length < 2) {
      return 'Keep logging your period starts to measure cycle-to-cycle spacing.';
    }

    final gaps = <int>[];
    for (int i = 1; i < starts.length; i++) {
      gaps.add(calendarDaysBetween(starts[i], starts[i - 1]));
    }
    final mean = gaps.reduce((a, b) => a + b) / gaps.length;
    var variance = 0.0;
    for (final g in gaps) {
      final d = g - mean;
      variance += d * d;
    }
    variance /= gaps.length;
    final sd = math.sqrt(variance);

    if (sd <= 2) {
      return 'Cycles look fairly regular (about ${mean.round()} days apart).';
    }
    if (sd <= 5) {
      return 'Cycles vary moderately (typical spacing ~${mean.round()} days, spread ~${sd.round()}).';
    }
    return 'Cycles look variable. Keep logging to improve predictions.';
  }
}
