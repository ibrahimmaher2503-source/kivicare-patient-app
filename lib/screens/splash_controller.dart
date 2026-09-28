// ignore_for_file: depend_on_referenced_packages

import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:kivicare_patient/screens/home/home_controller.dart';
import 'package:kivicare_patient/screens/walkthrough/walkthrough_screen.dart';
import 'package:kivicare_patient/utils/app_common.dart';
import 'package:kivicare_patient/utils/local_storage.dart';
import '../api/auth_apis.dart';
import '../utils/common_base.dart';
import '../utils/constants.dart';
import '../utils/secure_session_storage.dart';
import '../utils/push_notification_service.dart';
import 'auth/model/login_response.dart';
import 'dashboard/dashboard_screen.dart';

class SplashScreenController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    getPackageInfo().then((value) => currentPackageinfo(value));
  }

  @override
  void onReady() {
    try {
      final getThemeFromLocal =
          getValueFromLocal(SettingsLocalConst.THEME_MODE);
      if (getThemeFromLocal is int) {
        toggleThemeMode(themeId: getThemeFromLocal);
      } else {
        toggleThemeMode(themeId: THEME_MODE_LIGHT);
      }
    } catch (e) {
      log('getThemeFromLocal from cache E: $e');
    }
    getAppConfigurations();
    super.onReady();
  }

  ///Get ChooseService List
  Future<void> getAppConfigurations() async {
    try {
      final value = await AuthServiceApis.getAppConfigurations()
          .timeout(const Duration(seconds: 15));
      appCurrency(value.currency);
      appConfigs(value);
    } catch (error) {
      log('getAppConfigurations E: $error');
    }
    await navigationLogic();
  }

  Future<void> navigationLogic() async {
    if ((getValueFromLocal(SharedPreferenceConst.FIRST_TIME) ?? false) ==
        false) {
      Get.offAll(() => WalkthroughScreen());
    } else if (getValueFromLocal(SharedPreferenceConst.IS_LOGGED_IN) == true) {
      try {
        final userData = await SecureSessionStorage.readUser();
        if (userData == null ||
            userData.id <= 0 ||
            userData.apiToken.trim().isEmpty) {
          throw const FormatException('Invalid cached session');
        }
        loginUserData(userData);
        isLoggedIn(true);
        Get.offAll(() => DashboardScreen(), binding: BindingsBuilder(() {
          Get.put(HomeController());
        }));
      } catch (e) {
        await SecureSessionStorage.clear();
        removeValueFromLocal(SharedPreferenceConst.USER_DATA);
        removeValueFromLocal(SharedPreferenceConst.USER_PASSWORD);
        setValueToLocal(SharedPreferenceConst.IS_LOGGED_IN, false);
        isLoggedIn(false);
        loginUserData(UserData());
        Get.offAll(() => DashboardScreen(), binding: BindingsBuilder(() {
          Get.put(HomeController());
        }));
      }
    } else {
      Get.offAll(() => DashboardScreen(), binding: BindingsBuilder(() {
        Get.put(HomeController());
      }));
    }

    final pushService = PushNotificationService();
    pushService.markAuthStateReady();
    if (isLoggedIn.value) {
      await pushService.registerFCMAndTopics();
    }
  }
}
