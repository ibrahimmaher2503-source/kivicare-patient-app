import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:kivicare_patient/locale/language_en.dart';
import 'app_theme.dart';
import 'configs.dart';
import 'firebase_options.dart';
import 'locale/app_localizations.dart';
import 'locale/languages.dart';
import 'screens/splash_screen.dart';
import 'screens/dashboard/dashboard_screen.dart';
import 'screens/home/home_controller.dart';
import 'screens/pharmacy/pharmacy_controller.dart';
import 'utils/app_common.dart';
import 'utils/colors.dart';
import 'utils/common_base.dart';
import 'utils/constants.dart';
import 'utils/local_storage.dart';
import 'utils/locale_formatters.dart';
import 'utils/push_notification_service.dart';
import 'screens/location_filter/service/location_cache_service.dart';
import 'screens/labs_radiology/shared/service/report_download_service.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // Notification payloads are displayed by Android while the app is in the
  // background. Data-only payloads need a local notification so they are not
  // silently lost; the payload is retained for authenticated routing on tap.
  if (message.notification == null) {
    final title = message.data['title']?.toString() ?? 'Espitalia';
    final body = message.data['body']?.toString() ?? '';
    await PushNotificationService().showNotification(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      message.data,
    );
  }
}

Rx<BaseLanguage> locale = LanguageEn().obs;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Future.wait([
    initializeDateFormatting('ar_EG'),
    initializeDateFormatting('en_EG'),
  ]);
  tz.initializeTimeZones();
  if (DefaultFirebaseOptions.isSupportedPlatform) {
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      await PushNotificationService().setupFirebaseMessaging();
      if (kReleaseMode) {
        FlutterError.onError =
            FirebaseCrashlytics.instance.recordFlutterFatalError;
      }
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('Firebase initialization failed: $error');
        debugPrintStack(stackTrace: stackTrace);
      }
    }
  }

  await GetStorage.init();
  registerSessionStateClearer(ReportDownloadService.clearCachedReports);
  await LocationCacheService().init();
  // Remove exact-location values written by older releases. Location is now
  // held in memory and only coarse filter IDs may be cached.
  await localStorage.remove(LocatinKeys.LATITUDE);
  await localStorage.remove(LocatinKeys.LONGITUDE);
  await localStorage.remove(LocatinKeys.CURRENT_ADDRESS);
  //
  fontFamilyPrimaryGlobal = 'PlusJakartaSans';
  textPrimarySizeGlobal = 16;
  fontFamilySecondaryGlobal = 'PlusJakartaSans';
  textSecondarySizeGlobal = 16;
  fontFamilyBoldGlobal = 'Outfit';
  //
  defaultBlurRadius = 0;
  defaultRadius = 12;
  defaultSpreadRadius = 0;
  appButtonBackgroundColorGlobal = appColorPrimary;
  defaultAppButtonRadius = defaultRadius;
  defaultAppButtonElevation = 0;
  defaultAppButtonTextColorGlobal = Colors.white;
  passwordLengthGlobal = 8;

  selectedLanguageCode(
      getValueFromLocal(SELECTED_LANGUAGE_CODE) ?? DEFAULT_LANGUAGE);
  Intl.defaultLocale = activeIntlLocale;

  await initialize(
      aLocaleLanguageList: languageList(),
      defaultLanguage: selectedLanguageCode.value);

  final loadedLocale =
      await const AppLocalizations().load(Locale(selectedLanguageCode.value));
  locale = loadedLocale.obs;

  try {
    final getThemeFromLocal = getValueFromLocal(SettingsLocalConst.THEME_MODE);
    if (getThemeFromLocal is int) {
      toggleThemeMode(themeId: getThemeFromLocal);
    } else {
      toggleThemeMode(themeId: THEME_MODE_LIGHT);
    }
  } catch (e) {
    log('getThemeFromLocal from cache E: $e');
  }
  signedOutNavigationHandler = () async {
    if (Get.context == null) return;
    Get.offAll(
      () => DashboardScreen(),
      binding: BindingsBuilder(() {
        Get.put(HomeController());
      }),
    );
  };
  PharmacyController.ensureRegistered();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  List<Locale> get _supportedLocales {
    final configuredLocales = LanguageDataModel.languageLocales();
    if (configuredLocales.isNotEmpty) {
      return configuredLocales;
    }

    return languageList()
        .map((language) => Locale(language.languageCode.validate()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return RestartAppWidget(
      child: Obx(
        () => GetMaterialApp(
          navigatorKey: navigatorKey,
          title: APP_NAME,
          debugShowCheckedModeBanner: false,
          supportedLocales: _supportedLocales,
          localizationsDelegates: const [
            AppLocalizations(),
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          localeResolutionCallback: (locale, supportedLocales) =>
              Locale(selectedLanguageCode.value),
          fallbackLocale: const Locale(DEFAULT_LANGUAGE),
          locale: Locale(selectedLanguageCode.value),
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: isDarkMode.value ? ThemeMode.dark : ThemeMode.light,
          initialBinding: BindingsBuilder(() {
            //initialBinding logic
            setStatusBarColor(transparentColor);
          }),
          home: SplashScreen(),
        ),
      ),
    );
  }
}
