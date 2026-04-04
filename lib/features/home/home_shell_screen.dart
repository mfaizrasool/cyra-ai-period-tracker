import 'package:cyra_ai_period_tracker/features/calendar/calendar_screen.dart';
import 'package:cyra_ai_period_tracker/features/home/cycle_controller.dart';
import 'package:cyra_ai_period_tracker/features/home/home_screen.dart';
import 'package:cyra_ai_period_tracker/features/home/shell_nav_controller.dart';
import 'package:cyra_ai_period_tracker/features/insights/insights_controller.dart';
import 'package:cyra_ai_period_tracker/features/insights/insights_screen.dart';
import 'package:cyra_ai_period_tracker/features/log/log_controller.dart';
import 'package:cyra_ai_period_tracker/features/log/log_screen.dart';
import 'package:cyra_ai_period_tracker/features/profile/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeShellScreen extends StatefulWidget {
  const HomeShellScreen({super.key});

  @override
  State<HomeShellScreen> createState() => _HomeShellScreenState();
}

class _HomeShellScreenState extends State<HomeShellScreen> {
  @override
  void initState() {
    super.initState();
    // Fresh shell instance (e.g. after onboarding) must rebuild controllers so prefs/DB sync.
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
    Get.put(ShellNavController(), permanent: true);
    Get.put(CycleController(), permanent: true);
    Get.put(LogController(), permanent: true);
    Get.put(InsightsController(), permanent: true);
  }

  static const _screens = [
    HomeScreen(),
    CalendarScreen(),
    LogScreen(),
    InsightsScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final nav = Get.find<ShellNavController>();
    return Obx(
      () => Scaffold(
        body: IndexedStack(
          index: nav.currentIndex.value,
          children: _screens,
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: nav.currentIndex.value,
          onDestinationSelected: nav.goToTab,
          destinations: const [
            NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Home'),
            NavigationDestination(icon: Icon(Icons.calendar_month_outlined), label: 'Calendar'),
            NavigationDestination(icon: Icon(Icons.add_circle_outline), label: 'Log'),
            NavigationDestination(icon: Icon(Icons.insights_outlined), label: 'Insights'),
            NavigationDestination(icon: Icon(Icons.person_outline), label: 'Profile'),
          ],
        ),
      ),
    );
  }
}
