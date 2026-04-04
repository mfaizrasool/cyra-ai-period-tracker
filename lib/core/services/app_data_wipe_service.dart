import 'package:cyra_ai_period_tracker/common/controllers/preference_controller.dart';
import 'package:cyra_ai_period_tracker/data/db/app_database.dart';
import 'package:cyra_ai_period_tracker/features/home/cycle_controller.dart';
import 'package:cyra_ai_period_tracker/features/home/shell_nav_controller.dart';
import 'package:cyra_ai_period_tracker/features/insights/insights_controller.dart';
import 'package:cyra_ai_period_tracker/features/log/log_controller.dart';
import 'package:cyra_ai_period_tracker/utils/theme/theme_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Clears all on-device data: SQLite + SharedPreferences, resets theme in memory, removes feature controllers.
class AppDataWipeService {
  AppDataWipeService._();

  static Future<void> wipeEverything() async {
    await AppDatabase.instance.closeAndDeleteDatabase();

    final prefs = Get.find<AppPreferencesController>();
    await prefs.clearData();

    final theme = Get.find<ThemeController>();
    theme.selectedTheme.value = ThemeMode.system;
    Get.changeThemeMode(ThemeMode.system);

    if (Get.isRegistered<ShellNavController>()) {
      Get.delete<ShellNavController>(force: true);
    }
    if (Get.isRegistered<CycleController>()) {
      Get.delete<CycleController>(force: true);
    }
    if (Get.isRegistered<LogController>()) {
      Get.delete<LogController>(force: true);
    }
    if (Get.isRegistered<InsightsController>()) {
      Get.delete<InsightsController>(force: true);
    }
  }
}
