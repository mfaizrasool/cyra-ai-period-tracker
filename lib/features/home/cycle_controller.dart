import 'package:cyra_ai_period_tracker/common/controllers/preference_controller.dart';
import 'package:cyra_ai_period_tracker/core/services/cycle_prediction_service.dart';
import 'package:cyra_ai_period_tracker/core/services/reminder_notification_service.dart';
import 'package:cyra_ai_period_tracker/core/utils/date_utils.dart';
import 'package:cyra_ai_period_tracker/data/db/app_database.dart';
import 'package:cyra_ai_period_tracker/data/models/period_log.dart';
import 'package:cyra_ai_period_tracker/features/insights/insights_controller.dart';
import 'package:cyra_ai_period_tracker/utils/preference_labels.dart';
import 'package:get/get.dart';

class CycleController extends GetxController {
  final AppPreferencesController _prefs = Get.find<AppPreferencesController>();
  final CyclePredictionService _predictionService = CyclePredictionService();
  final AppDatabase _db = AppDatabase.instance;

  final RxList<PeriodLog> loggedPeriods = <PeriodLog>[].obs;

  final Rx<DateTime> lastPeriodStartDate = DateTime.now().obs;
  final Rx<DateTime> nextPeriodDate = DateTime.now().obs;
  final Rx<DateTime> ovulationDate = DateTime.now().obs;
  final RxList<DateTime> fertileWindow = <DateTime>[].obs;

  final RxInt avgCycleLength = 28.obs;
  final RxInt avgPeriodLength = 5.obs;
  final RxInt daysUntilNextPeriod = 0.obs;
  /// Cycle day since last period start (1-based). Not shown when [periodDayInBleeding] is set.
  final RxInt cycleDay = 1.obs;
  /// If today is a logged bleeding day, day index within current cluster.
  final Rx<int?> periodDayInBleeding = Rx<int?>(null);

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  Future<void> loadData() async {
    final cycleLenStr = await _prefs.getString(key: AppPreferenceLabels.avgCycleLength);
    final periodLenStr = await _prefs.getString(key: AppPreferenceLabels.avgPeriodLength);
    final lastPeriodStr = await _prefs.getString(key: AppPreferenceLabels.lastPeriodStartDate);

    avgCycleLength.value = cycleLenStr.isNotEmpty ? int.parse(cycleLenStr) : 28;
    avgPeriodLength.value = periodLenStr.isNotEmpty ? int.parse(periodLenStr) : 5;

    DateTime fallbackLastStart;
    if (lastPeriodStr.isNotEmpty) {
      fallbackLastStart = dateOnly(DateTime.parse(lastPeriodStr));
    } else {
      fallbackLastStart = dateOnly(DateTime.now().subtract(Duration(days: avgCycleLength.value)));
    }

    final logs = await _db.getAllPeriodLogs();
    loggedPeriods.assignAll(logs);

    final bleedingLogs = logs.where((l) => l.flowLevel > 0).toList();
    final inferred = _predictionService.inferLastPeriodStartFromLogs(bleedingLogs);
    lastPeriodStartDate.value = inferred ?? fallbackLastStart;

    nextPeriodDate.value = _predictionService.predictNextPeriod(
      lastPeriodStartDate.value,
      avgCycleLength.value,
    );
    ovulationDate.value = _predictionService.predictOvulation(nextPeriodDate.value);
    fertileWindow.assignAll(
      _predictionService.predictFertileWindow(ovulationDate.value),
    );

    final today = dateOnly(DateTime.now());
    daysUntilNextPeriod.value = calendarDaysBetween(nextPeriodDate.value, today);

    periodDayInBleeding.value = _predictionService.currentPeriodDayInCluster(
      bleedingLogs,
      today,
    );

    cycleDay.value = calendarDaysBetween(today, lastPeriodStartDate.value) + 1;
    if (cycleDay.value < 1) cycleDay.value = 1;

    if (Get.isRegistered<InsightsController>()) {
      await Get.find<InsightsController>().load();
    }
    await ReminderNotificationService.sync();
  }

  Future<void> logPeriodDay(DateTime date, int flowLevel) async {
    final d = dateOnly(date);
    if (flowLevel <= 0) {
      await _db.deletePeriodLogForDate(d);
    } else {
      await _db.upsertPeriodLog(PeriodLog(date: d, flowLevel: flowLevel));
    }
    await loadData();
  }

  Future<void> updateAveragesFromProfile({required int cycle, required int period}) async {
    avgCycleLength.value = cycle;
    avgPeriodLength.value = period;
    await _prefs.setString(key: AppPreferenceLabels.avgCycleLength, value: '$cycle');
    await _prefs.setString(key: AppPreferenceLabels.avgPeriodLength, value: '$period');
    await loadData();
  }
}
