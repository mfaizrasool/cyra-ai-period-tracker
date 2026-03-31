import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cyra_ai_period_tracker/utils/app_labels.dart';
import 'package:cyra_ai_period_tracker/utils/app_text_styles.dart';
import 'package:cyra_ai_period_tracker/utils/theme/constants/app_constants.dart';
import 'package:cyra_ai_period_tracker/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

/// Dialogs related to user account operations (logout, delete)
class AccountDialogs {
  /// Show logout confirmation dialog
  static Future<bool> showLogoutDialog() async {
    bool confirmed = false;

    await AwesomeDialog(
      context: Get.context!,
      dialogType: DialogType.noHeader,
      animType: AnimType.scale,
      headerAnimationLoop: false,
      title: 'Logout',
      desc: 'Are you sure you want to logout?',
      btnCancelOnPress: () {
        confirmed = false;
      },
      btnOkText: 'Logout',
      btnOkOnPress: () {
        confirmed = true;
      },
      btnOkColor: Colors.red,
      btnCancelColor: Colors.grey,
      dismissOnBackKeyPress: true,
      dismissOnTouchOutside: false,
    ).show();

    // Small delay to ensure overlay cleanup
    await Future.delayed(const Duration(milliseconds: 100));

    return confirmed;
  }

  /// Show delete account confirmation dialog
  static Future<bool> showDeleteAccountDialog() async {
    bool confirmed = false;

    await AwesomeDialog(
      context: Get.context!,
      dialogType: DialogType.noHeader,
      animType: AnimType.scale,
      headerAnimationLoop: false,
      title: 'Delete Account',
      desc:
          'Are you sure you want to permanently delete your account? This action cannot be undone.',
      btnCancelOnPress: () {
        confirmed = false;
      },
      btnOkText: 'Delete',
      btnOkOnPress: () {
        confirmed = true;
      },
      btnOkColor: Colors.red,
      btnCancelColor: Colors.grey,
      dismissOnBackKeyPress: true,
      dismissOnTouchOutside: false,
    ).show();

    // Small delay to ensure overlay cleanup
    await Future.delayed(const Duration(milliseconds: 100));

    return confirmed;
  }

  /// Show deleted account dialog with contact option
  static Future<dynamic> showDeletedAccountDialog() async {
    final result = await AwesomeDialog(
      context: Get.context!,
      dialogType: DialogType.noHeader,
      animType: AnimType.scale,
      headerAnimationLoop: false,
      dismissOnTouchOutside: false,
      dismissOnBackKeyPress: true,
      title: 'Account Deleted',
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(Icons.error, size: 80, color: AppColors.red),
            const SizedBox(height: 20),
            Text(
              'Account Deleted',
              style: AppTextStyle.headlineMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              AppLabels.deletedAccount,
              textAlign: TextAlign.center,
              style: AppTextStyle.bodyMedium,
            ),
            const SizedBox(height: 20),
            PrimaryButton(
              width: 250,
              title: AppLabels.contactUs,
              onPressed: () async {
                String email = Uri.encodeComponent("support@foldious.com");
                String subject = Uri.encodeComponent("Account Deleted Issue");
                String body = Uri.encodeComponent(
                  "Hello Support Team,\n\nI am experiencing an issue with my account.\n\nPlease help me resolve this.\n\nThank you.",
                );
                Uri mail = Uri.parse(
                  "mailto:$email?subject=$subject&body=$body",
                );

                try {
                  if (await canLaunchUrl(mail)) {
                    await launchUrl(mail);
                  }
                } catch (e) {
                  // Handle error silently
                }
              },
            ),
          ],
        ),
      ),
      btnOkText: 'Close',
      btnOkOnPress: () {},
      btnOkColor: AppColors.primaryColor,
    ).show();

    // Small delay to ensure overlay cleanup
    await Future.delayed(const Duration(milliseconds: 100));
    return result;
  }
}
