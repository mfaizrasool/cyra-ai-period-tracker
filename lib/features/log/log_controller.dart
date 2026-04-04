import 'package:cyra_ai_period_tracker/core/utils/date_utils.dart';
import 'package:cyra_ai_period_tracker/data/db/app_database.dart';
import 'package:cyra_ai_period_tracker/data/models/daily_log.dart';
import 'package:cyra_ai_period_tracker/features/insights/insights_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LogController extends GetxController {
  final AppDatabase _db = AppDatabase.instance;

  Rx<DateTime> selectedDate = DateTime.now().obs;

  RxString selectedMood = ''.obs;
  RxList<String> selectedSymptoms = <String>[].obs;

  /// 0–10; null means not set for this entry.
  final Rxn<int> painLevel = Rxn<int>();
  final notesController = TextEditingController();

  final List<String> moodOptions = [
    'Happy',
    'Calm',
    'Irritated',
    'Sad',
    'Anxious',
  ];
  final List<String> symptomOptions = [
    'Cramps',
    'Headache',
    'Bloating',
    'Fatigue',
    'Acne',
    'Back Pain',
  ];

  @override
  void onInit() {
    super.onInit();
    selectedDate.value = dateOnly(DateTime.now());
    _loadLogForDate(selectedDate.value);
  }

  void changeDate(DateTime date) {
    final d = dateOnly(date);
    final today = dateOnly(DateTime.now());
    if (d.isAfter(today)) return;
    selectedDate.value = d;
    _loadLogForDate(selectedDate.value);
  }

  Future<void> _loadLogForDate(DateTime date) async {
    final log = await _db.getDailyLogForDate(date);
    if (log != null) {
      selectedMood.value = log.mood;
      painLevel.value = log.painLevel;
      selectedSymptoms.value = log.symptoms.isEmpty
          ? <String>[]
          : log.symptoms
                .split(',')
                .map((e) => e.trim())
                .where((e) => e.isNotEmpty)
                .toList();
      notesController.text = log.notes;
    } else {
      selectedMood.value = '';
      painLevel.value = null;
      selectedSymptoms.clear();
      notesController.clear();
    }
  }

  void toggleSymptom(String symptom) {
    if (selectedSymptoms.contains(symptom)) {
      selectedSymptoms.remove(symptom);
    } else {
      selectedSymptoms.add(symptom);
    }
    selectedSymptoms.refresh();
  }

  void setMood(String mood) {
    if (selectedMood.value == mood) {
      selectedMood.value = '';
    } else {
      selectedMood.value = mood;
    }
  }

  void setPainLevel(int? value) {
    painLevel.value = value;
  }

  Future<void> saveLog() async {
    final log = DailyLog(
      date: selectedDate.value,
      symptoms: selectedSymptoms.join(','),
      mood: selectedMood.value,
      notes: notesController.text,
      painLevel: painLevel.value,
    );
    await _db.upsertDailyLog(log);
    if (Get.isRegistered<InsightsController>()) {
      await Get.find<InsightsController>().load();
    }
    Get.snackbar(
      'Saved',
      'Your log has been saved.',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  @override
  void onClose() {
    notesController.dispose();
    super.onClose();
  }
}
