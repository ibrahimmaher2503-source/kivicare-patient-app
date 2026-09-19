// ignore_for_file: invalid_use_of_protected_member

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../api/auth_apis.dart';
import '../../generated/assets.dart';
import '../../main.dart';
import '../../utils/app_common.dart';
import '../../utils/common_base.dart';
import '../../utils/constants.dart';
import '../../utils/local_storage.dart';
import '../../network/network_utils.dart';
import '../auth/other/settings_screen.dart';
import '../auth/profile/profile_controller.dart';
import '../auth/profile/profile_screen.dart';
import '../booking/appointments_screen.dart';
import '../home/home_screen.dart';
import 'components/menu.dart';

class DashboardController extends GetxController with WidgetsBindingObserver {
  RxInt currentIndex = 0.obs;
  RxBool isLoading = false.obs;

  Rx<BottomBarItem> selectedBottomNav = BottomBarItem(
          title: (locale.value.home).obs,
          icon: Assets.navigationIcHomeOutlined,
          activeIcon: Assets.navigationIcHomeFilled,
          type: BottomItem.home.name)
      .obs;

  RxList<Widget> screen = [
    HomeScreen(),
    AppointmentsScreen(),
  ].obs;

  @override
  void onInit() {
    WidgetsBinding.instance.addObserver(this);
    if (!isLoggedIn.value) {
      ProfileController().getAboutPageData();
    }
    getAppConfigurations().then((value) {
      Future.delayed(const Duration(seconds: 2), () {
        if (Get.context != null) {
          showForceUpdateDialog(Get.context!);
        }
      });
    });
    super.onInit();
  }

  @override
  void onReady() {
    reloadBottomTabs();
    super.onReady();
  }

  @override
  void didChangePlatformBrightness() {
    try {
      final getThemeFromLocal =
          getValueFromLocal(SettingsLocalConst.THEME_MODE);
      if (getThemeFromLocal is int) {
        toggleThemeMode(themeId: getThemeFromLocal);
      }
    } catch (e) {
      log('getThemeFromLocal from cache E: $e');
    }
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }

  void reloadBottomTabs() {
    final authenticated = isLoggedIn.value;
    screen.assignAll([
      HomeScreen(),
      AppointmentsScreen(),
      authenticated ? ProfileScreen() : SettingScreen(),
    ]);
    bottomNavItems.assignAll([
      BottomBarItem(
        title: locale.value.home.obs,
        icon: Assets.navigationIcHomeOutlined,
        activeIcon: Assets.navigationIcHomeFilled,
        type: BottomItem.home.name,
      ),
      BottomBarItem(
        title: locale.value.appointment.obs,
        icon: Assets.navigationIcCalenderOutlined,
        activeIcon: Assets.navigationIcCalenderFilled,
        type: BottomItem.appointment.name,
      ),
      BottomBarItem(
        title:
            (authenticated ? locale.value.profile : locale.value.settings).obs,
        icon: authenticated
            ? Assets.navigationIcUserOutlined
            : Assets.iconsIcSettingOutlined,
        activeIcon: authenticated
            ? Assets.navigationIcUserFilled
            : Assets.iconsIcSetting,
        type:
            authenticated ? BottomItem.profile.name : BottomItem.settings.name,
      ),
    ]);
    currentIndex(
      currentIndex.value.clamp(0, bottomNavItems.length - 1).toInt(),
    );
    selectedBottomNav(bottomNavItems[currentIndex.value]);
  }
}

///Get App Configuration Api
Future<void> getAppConfigurations() async {
  if (appConfigs.value.status) return;
  await AuthServiceApis.getAppConfigurations().then((value) async {
    appConfigs(value);

    /// Place ChatGPT Key Here
    chatGPTAPIkey = value.chatgptKey;
  }).onError((error, stackTrace) {
    toast(sanitizeBackendMessage(
        error, locale.value.somethingWentWrongPleaseTryAgainLater));
  });
}
