import 'dart:developer';

import 'package:cyra_ai_period_tracker/common/controllers/preference_controller.dart';
import 'package:cyra_ai_period_tracker/features/home/home_shell_screen.dart';
import 'package:cyra_ai_period_tracker/features/onboarding/onboarding_screen.dart';
import 'package:cyra_ai_period_tracker/utils/preference_labels.dart';
import 'package:cyra_ai_period_tracker/utils/theme/app_dark_theme.dart';
import 'package:cyra_ai_period_tracker/utils/theme/app_light_theme.dart';
import 'package:cyra_ai_period_tracker/utils/theme/theme_controller.dart';
import 'package:cyra_ai_period_tracker/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  } catch (_) {
    // Firebase may already be initialized in the background isolate.
  }

  if (kDebugMode) {
    log('Background message received: ${message.messageId}');
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  } catch (e) {
    if (kDebugMode) {
      log('Firebase initialization skipped/error: $e');
    }
  }

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final AppPreferencesController _preferencesController = Get.put(
    AppPreferencesController(),
    permanent: true,
  );
  final ThemeController _themeController = Get.put(
    ThemeController(),
    permanent: true,
  );

  bool _loading = true;
  bool _isOnboardingComplete = false;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final onboarded = await _preferencesController.getBool(
      key: AppPreferenceLabels.isOnboardingComplete,
    );
    if (!mounted) return;
    setState(() {
      _isOnboardingComplete = onboarded;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final selectedMode = _themeController.selectedTheme.value;
      // Use controller only so theme matches after full data wipe (prefs cleared).
      final effectiveMode = selectedMode;

      return GetMaterialApp(
        title: 'Cyra - AI Period Tracker',
        debugShowCheckedModeBanner: false,
        theme: lightTheme,
        darkTheme: darkTheme,
        themeMode: effectiveMode,
        home: _loading
            ? const _LoadingScreen()
            : (_isOnboardingComplete
                  ? const HomeShellScreen()
                  : OnboardingScreen(
                      onCompleted: () {
                        setState(() => _isOnboardingComplete = true);
                      },
                    )),
        builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: TextScaler.noScaling),
            child: child ?? const SizedBox.shrink(),
          );
        },
      );
    });
  }
}

class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: const Center(child: CircularProgressIndicator()));
  }
}
