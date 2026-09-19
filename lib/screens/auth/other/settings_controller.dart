import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:kivicare_patient/main.dart';
import 'package:kivicare_patient/screens/booking/model/appointment_status_model.dart';
import 'package:kivicare_patient/screens/dashboard/dashboard_controller.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../configs.dart';
import '../../../locale/app_localizations.dart';
import '../model/theme_mode_data_model.dart';
import '../../../api/auth_apis.dart';
import '../../../utils/app_common.dart';
import '../../../utils/common_base.dart';
import '../../../utils/constants.dart';
import '../../../utils/local_storage.dart';
import '../../../utils/locale_formatters.dart';
import '../../../network/network_utils.dart';

class SettingsController extends GetxController {
  RxBool isLoading = false.obs;
  RxBool isPayment = false.obs;
  RxBool isTouchId = false.obs;

  Rx<LanguageDataModel> selectedLang = LanguageDataModel().obs;
  List<ThemeModeData> themeModes = [
    ThemeModeData(id: THEME_MODE_SYSTEM, mode: "System"),
    ThemeModeData(id: THEME_MODE_LIGHT, mode: "Light"),
    ThemeModeData(id: THEME_MODE_DARK, mode: "Dark")
  ];
  Rx<ThemeModeData> dropdownValue = ThemeModeData().obs;

  Future<void> changeLanguage(LanguageDataModel newValue) async {
    selectedLang(newValue);
    isLoading(true);
    await setValue(SELECTED_LANGUAGE_CODE, newValue.languageCode);
    selectedLanguageDataModel = newValue;
    final loadedLocale = await const AppLocalizations()
        .load(Locale(newValue.languageCode.validate()));
    locale = loadedLocale.obs;
    setValueToLocal(SELECTED_LANGUAGE_CODE, newValue.languageCode.validate());
    selectedLanguageCode(newValue.languageCode!);
    Intl.defaultLocale = activeIntlLocale;
    Get.updateLocale(Locale(newValue.languageCode.validate()));
    isLoading(false);
    onLanguageChange();
  }

  void handleDeleteAccountClick() {
    ifNotTester(() async {
      if (isLoading.value) return;
      isLoading(true);
      try {
        final value = await AuthServiceApis.deleteAccountCompletely();
        await AuthServiceApis.clearData(isFromDeleteAcc: true);
        toast(sanitizeBackendMessage(
            value.message, locale.value.somethingWentWrong));
        await navigateToSignedOutHome();
      } catch (error) {
        toast(sanitizeBackendMessage(
            error, locale.value.somethingWentWrongPleaseTryAgainLater));
      } finally {
        isLoading(false);
      }
    });
  }

  @override
  Future<void> onInit() async {
    if (localeLanguageList.isNotEmpty) {
      selectedLanguageCode(
          getValueFromLocal(SELECTED_LANGUAGE_CODE) ?? DEFAULT_LANGUAGE);
      selectedLang(localeLanguageList.firstWhere(
        (element) => element.languageCode == selectedLanguageCode.value,
        orElse: () => LanguageDataModel(id: -1),
      ));
    }
    log('ISDARK: ${isDarkMode.value}');

    super.onInit();
  }

  @override
  void onReady() {
    try {
      final getThemeFromLocal =
          getValueFromLocal(SettingsLocalConst.THEME_MODE);
      if (getThemeFromLocal is int) {
        dropdownValue(themeModes.firstWhere(
          (element) => element.id == getThemeFromLocal,
          orElse: () => ThemeModeData(),
        ));
        toggleThemeMode(themeId: getThemeFromLocal);
      }
    } catch (e) {
      log('getThemeFromLocal from cache E: $e');
    }
    super.onReady();
  }

  void onLanguageChange() {
    if (Get.isRegistered<DashboardController>()) {
      Get.find<DashboardController>().reloadBottomTabs();
    }
    for (var status in filterStatus) {
      switch (status.type) {
        case AppointmentStatus.all:
          status.name!.value = locale.value.all;
          break;
        case AppointmentStatus.upcoming:
          status.name!.value = locale.value.upcoming;
          break;
        case AppointmentStatus.completed:
          status.name!.value = locale.value.completed;
          break;
      }
    }
  }
}
