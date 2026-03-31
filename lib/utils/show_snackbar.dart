import 'package:cyra_ai_period_tracker/utils/theme/constants/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

// Global variables to track last snackbar time and message
DateTime? _lastSnackbarTime;
String? _lastSnackbarMessage;
const Duration _snackbarDebounceTime = Duration(milliseconds: 500);

///
///
///
void showSuccessMessage(
  String message, {
  ScaffoldMessengerState? messengerState,
}) {
  // Debounce rapid successive calls with same message
  final now = DateTime.now();
  if (_lastSnackbarTime != null &&
      now.difference(_lastSnackbarTime!) < _snackbarDebounceTime &&
      _lastSnackbarMessage == message) {
    return;
  }

  _lastSnackbarTime = now;
  _lastSnackbarMessage = message;

  final s = messengerState ?? ScaffoldMessenger.of(Get.context!);

  // Clear any existing snackbars before showing new one
  s.clearSnackBars();

  s.showSnackBar(
    SnackBar(content: Text(message), backgroundColor: AppColors.positiveColor),
  );
}

///
///
///
void showErrorMessage(
  String message, {
  ScaffoldMessengerState? messengerState,
}) {
  // Debounce rapid successive calls with same message
  final now = DateTime.now();
  if (_lastSnackbarTime != null &&
      now.difference(_lastSnackbarTime!) < _snackbarDebounceTime &&
      _lastSnackbarMessage == message) {
    return;
  }

  _lastSnackbarTime = now;
  _lastSnackbarMessage = message;

  final s = messengerState ?? ScaffoldMessenger.of(Get.context!);

  // Clear any existing snackbars before showing new one
  s.clearSnackBars();

  s.showSnackBar(
    SnackBar(
      content: Text(
        message,
        style: GoogleFonts.nunitoSans(
          textStyle: const TextStyle(color: AppColors.white),
        ),
      ),
      backgroundColor: AppColors.negativeColor,
    ),
  );
}
