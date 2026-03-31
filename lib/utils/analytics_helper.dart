import 'package:cyra_ai_period_tracker/common/controllers/preference_controller.dart';
import 'package:cyra_ai_period_tracker/utils/preference_labels.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticsHelper {
  /// Log a page view event with user_id if available, otherwise use class name
  /// This tracks to both Firebase Analytics
  static Future<void> logPageView(String className) async {
    try {
      final userId = await AppPreferencesController().getString(
        key: AppPreferenceLabels.userId,
      );

      final parameters = <String, Object>{
        if (userId.isNotEmpty) 'user_id': userId else 'class_name': className,
      };

      // Track to Firebase Analytics
      await FirebaseAnalytics.instance.logEvent(
        name: 'page_view',
        parameters: parameters,
      );
    } catch (e) {
      // Silently fail analytics logging
      print('Analytics error: $e');
    }
  }

  /// Log a custom event with user_id if available
  /// This tracks to both Firebase Analytics and TikTok Events SDK
  static Future<void> logEvent(
    String eventName, {
    Map<String, dynamic>? additionalParameters,
    String? userId,
  }) async {
    try {
      String? finalUserId = userId;
      if (finalUserId == null || finalUserId.isEmpty) {
        finalUserId = await AppPreferencesController().getString(
          key: AppPreferenceLabels.userId,
        );
      }

      final parameters = <String, Object>{
        if (finalUserId.isNotEmpty) 'user_id': finalUserId,
        if (additionalParameters != null)
          ...additionalParameters.map(
            (key, value) => MapEntry(key, value as Object),
          ),
      };

      // Track to Firebase Analytics
      await FirebaseAnalytics.instance.logEvent(
        name: eventName,
        parameters: parameters,
      );
    } catch (e) {
      // Silently fail analytics logging
      print('Analytics error: $e');
    }
  }
}
