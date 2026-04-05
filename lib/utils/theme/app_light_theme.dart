import 'package:cyra_ai_period_tracker/utils/app_text_styles.dart';
import 'package:cyra_ai_period_tracker/utils/theme/constants/app_constants.dart';
import 'package:cyra_ai_period_tracker/utils/theme/extension/theme_extension.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

final ColorScheme _lightColorScheme = ThemeData.light().colorScheme.copyWith(
  primary: AppColors.primaryColor,
  surface: AppLightThemeColors.appBackgroundColor,
  onSurface: AppLightThemeColors.primaryTextColor,
  secondaryContainer: AppLightThemeColors.lightGreyColor,
  primaryContainer: AppColors.greyColor,
);

final lightTheme = ThemeData.light().copyWith(
  brightness: Brightness.light,
  cardColor: const Color(0xFFFFF2F5),
  colorScheme: _lightColorScheme,
  dividerColor: const Color(0xFFEBEDF1),
  bottomSheetTheme: const BottomSheetThemeData(
    backgroundColor: AppLightThemeColors.bottomSheetColor,
  ),
  listTileTheme: ListTileThemeData(
    textColor: AppLightThemeColors.primaryTextColor,
    titleTextStyle: AppTextStyle.bodyMedium,
  ),
  primaryColor: AppColors.primaryColor,
  scaffoldBackgroundColor: AppLightThemeColors.appBackgroundColor,
  textTheme: TextTheme(
    bodyLarge: AppTextStyle.bodyLarge.copyWith(
      fontSize: 16.0,
      color: _lightColorScheme.onSurface,
    ),
    bodyMedium: AppTextStyle.bodyMedium.copyWith(
      color: _lightColorScheme.onSurface,
    ),
    bodySmall: AppTextStyle.bodySmall.copyWith(
      color: _lightColorScheme.onSurface,
      fontSize: 14.0,
    ),
    labelSmall: AppTextStyle.bodySmall.copyWith(
      fontSize: 11,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.2,
      color: _lightColorScheme.onSurface,
    ),
    titleLarge: AppTextStyle.titleLarge.copyWith(
      color: _lightColorScheme.onSurface,
    ),
    titleMedium: AppTextStyle.titleMedium.copyWith(
      color: _lightColorScheme.onSurface,
    ),
    titleSmall: AppTextStyle.titleSmall.copyWith(
      fontWeight: FontWeight.bold,
      color: _lightColorScheme.onSurface,
    ),
  ),
  appBarTheme: AppBarTheme(
    backgroundColor: AppLightThemeColors.appBackgroundColor,
    elevation: 0,
    titleTextStyle: AppTextStyle.bodyMedium.copyWith(
      fontSize: 16,
      color: AppLightThemeColors.primaryTextColor,
    ),
    iconTheme: const IconThemeData(color: AppLightThemeColors.iconColor),
  ),
  canvasColor: AppLightThemeColors.bottomSheetColor,
  iconTheme: const IconThemeData(color: AppLightThemeColors.iconColor),
  tabBarTheme: TabBarThemeData(
    labelStyle: AppTextStyle.bodyMedium.copyWith(
      fontWeight: FontWeight.w600,
      color: AppLightThemeColors.primaryTextColor,
    ),
    indicatorColor: AppLightThemeColors.primaryTextColor,
    unselectedLabelColor: AppLightThemeColors.primaryTextColor,
    labelColor: AppLightThemeColors.primaryTextColor,
    indicatorSize: TabBarIndicatorSize.tab,
    labelPadding: const EdgeInsets.symmetric(horizontal: 2.0),
    indicator: const BoxDecoration(
      color: AppLightThemeColors.appBackgroundColor,
      border: Border(
        bottom: BorderSide(
          width: 1,
          color: AppLightThemeColors.primaryTextColor,
        ),
      ),
    ),
  ),
  cupertinoOverrideTheme: const NoDefaultCupertinoThemeData(
    brightness: Brightness.light,
  ),
  inputDecorationTheme: InputDecorationTheme(
    labelStyle: AppTextStyle.bodyMedium.copyWith(
      color: AppLightThemeColors.primaryTextColor,
    ),
    hintStyle: const TextStyle(color: AppColors.greyColor),
    contentPadding: const EdgeInsets.all(12.0),
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(
        // color: AppLightThemeColors.lightGreyColor,
        color: AppColors.primaryColor.withValues(alpha: 0.3),
        width: 1,
      ),
      borderRadius: BorderRadius.circular(10),
    ),
    disabledBorder: OutlineInputBorder(
      borderSide: const BorderSide(
        color: AppLightThemeColors.lightGreyColor,
        width: 1,
      ),
      borderRadius: BorderRadius.circular(10),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: const BorderSide(color: AppColors.primaryColor, width: 1),
      borderRadius: BorderRadius.circular(10),
    ),
  ),
  buttonTheme: const ButtonThemeData(buttonColor: AppColors.primaryColor),
  extensions: [
    const CustomThemeExtension(positiveColor: AppColors.positiveColor),
  ],
);
