import 'package:flutter/material.dart';

class AppColors {
  static const white = Colors.white;
  static const black = Colors.black;
  static const transparent = Colors.transparent;

  /// Primary brand — light rose pink (readable with white button labels).
  static const primaryColor = Color(0xFFF06292);

  static const greyColor = Color(0xFF9E8E96);

  /// Cycle accents (kept distinct from primary for calendar / legend).
  static const periodColor = Color(0xFFFF5E8A);
  static const fertileColor = Color(0xFF2DB7A3);
  static const ovulationColor = Color(0xFF4E8CFF);
  static const insightColor = Color(0xFFEC407A);

  static const blue = Colors.blue;
  static const red = Colors.red;
  static const green = Colors.green;
  static const orange = Colors.orange;

  static const Color positiveColor = Color(0xFF35C484);
  static const Color negativeColor = Color(0xFFFF5F6D);
}

class AppLightThemeColors {
  static const Color appBackgroundColor = Color(0xFFFFF8FA);

  static const Color secondaryButtonColor = Color(0xFFFFEEF3);

  static const Color primaryTextColor = Color(0xFF2D1F26);

  static const Color primaryButtonTextColor = Color(0xFFFFFFFF);

  static const Color secondaryButtonTextColor = AppColors.primaryColor;

  static const Color lightGreyColor = Color(0xFFF5E3E9);

  static const Color bottomSheetColor = Color(0xFFFFFFFF);

  static const Color iconColor = primaryTextColor;
}

class AppDarkThemeColors {
  static const Color appBackgroundColor = Color(0xFF1C1216);

  static const Color secondaryButtonColor = Color(0xFF3D2A32);

  static const Color primaryTextColor = Color(0xFFFFF5F7);

  static const Color primaryButtonTextColor = Color(0xFFFFFFFF);

  static const Color secondaryButtonTextColor = AppColors.primaryColor;

  static const Color lightGreyColor = Color(0xFF4A3E44);

  static const Color bottomSheetColor = Color(0xFF2A1F24);

  static const Color iconColor = primaryTextColor;
}
