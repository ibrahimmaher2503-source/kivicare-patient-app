import 'package:get/get.dart';
import 'package:kivicare_patient/utils/common_base.dart';
import 'package:nb_utils/nb_utils.dart';

/// Utility class for RBAC (Role-Based Access Control) handling
class RBACUtils {
  /// Handle 403 Forbidden error
  static void handle403Error(String? message) {
    final errorMsg = message ?? locale.value.accessDenied;
    toast(errorMsg);

    // Log access denial for audit
    appPrint('403 Access Denied: $errorMsg');
  }

  /// Show unauthorized access screen
  static void showUnauthorizedScreen(String? message) {
    Get.dialog(
      WillPopScope(
        onWillPop: () async => false,
        child: AlertDialog(
          title: Text(
            locale.value.accessDenied,
            style: boldTextStyle(),
          ),
          content: Text(
            message ?? locale.value.youDontHavePermissionToAccessThis,
            style: primaryTextStyle(),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Get.back();
                Get.offAllNamed('/home');
              },
              child: Text(locale.value.ok),
            ),
          ],
        ),
      ),
      barrierDismissible: false,
    );
  }

  /// Check if response is 403 Forbidden
  static bool is403Error(dynamic response) {
    return response?.statusCode == 403 || response?.statusCode == '403';
  }

  /// Log access attempt for audit
  static void logAccessAttempt(String resource, bool allowed, String? reason) {
    final timestamp = DateTime.now().toIso8601String();
    final userId = loginUserData.value.id;
    final userRoles = loginUserData.value.userRole.join(',');

    final auditMessage =
        'Audit: User#$userId ($userRoles) attempted access to $resource at $timestamp - ${allowed ? 'ALLOWED' : 'DENIED: $reason'}';

    appPrint(auditMessage);

    // TODO: Send to backend logging/analytics service
    // Crashlytics.instance.log(auditMessage);
  }
}
