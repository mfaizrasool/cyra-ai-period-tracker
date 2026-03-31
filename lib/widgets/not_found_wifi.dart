import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:cyra_ai_period_tracker/utils/app_text_styles.dart';
import 'package:cyra_ai_period_tracker/utils/show_snackbar.dart';
import 'package:cyra_ai_period_tracker/utils/theme/constants/app_constants.dart';
import 'package:cyra_ai_period_tracker/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NotFoundWifiPage extends StatefulWidget {
  const NotFoundWifiPage({super.key});

  @override
  State<NotFoundWifiPage> createState() => _NotFoundWifiPageState();
}

class _NotFoundWifiPageState extends State<NotFoundWifiPage> {
  bool _isCheckingConnection = false;

  Future<void> checkInternetConnection() async {
    setState(() {
      _isCheckingConnection = true;
    });

    try {
      final connectivityResult = await Connectivity().checkConnectivity();

      if (connectivityResult.contains(ConnectivityResult.none)) {
        showErrorMessage(
          "No internet connection available. Please check your network settings.",
        );
      } else {
        showSuccessMessage("Internet connection restored!");
        Navigator.of(Get.context!).pop();
      }
    } catch (e) {
      showErrorMessage("Unable to check connection. Please try again.");
    } finally {
      setState(() {
        _isCheckingConnection = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final height = size.height;
    final width = size.width;
    final theme = Theme.of(context);

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // WiFi Icon
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: AppColors.greyColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.wifi_off_rounded,
                    size: 60,
                    color: AppColors.greyColor,
                  ),
                ),

                SizedBox(height: height * 0.04),

                // Title
                Text(
                  "No Internet Connection",
                  style: AppTextStyle.headlineMedium.copyWith(
                    color: theme.textTheme.titleLarge?.color,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: height * 0.02),

                // Description
                Text(
                  "Please check your internet connection and try again. Make sure you're connected to WiFi or mobile data.",
                  style: AppTextStyle.bodyMedium.copyWith(
                    color: AppColors.greyColor,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: height * 0.06),

                // Retry Button
                PrimaryButton(
                  title: _isCheckingConnection ? "Checking..." : "Try Again",
                  onPressed: _isCheckingConnection
                      ? () {}
                      : () => checkInternetConnection(),
                  enabled: !_isCheckingConnection,
                  width: width * 0.7,
                  height: 50,
                ),

                SizedBox(height: height * 0.02),

                // Additional Help Text
                Text(
                  "If the problem persists, please check your network settings or contact your internet service provider.",
                  style: AppTextStyle.bodySmall.copyWith(
                    color: AppColors.greyColor.withValues(alpha: 0.7),
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
