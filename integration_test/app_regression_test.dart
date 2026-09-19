import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:integration_test/integration_test.dart';
import 'package:kivicare_patient/components/accessible_filter_button.dart';
import 'package:kivicare_patient/components/operation_verification_screen.dart';
import 'package:kivicare_patient/locale/app_localizations.dart';
import 'package:kivicare_patient/locale/languages.dart';
import 'package:kivicare_patient/screens/auth/sign_in_sign_up/signin_screen.dart';
import 'package:kivicare_patient/screens/auth/other/welcome_screen.dart';
import 'package:kivicare_patient/screens/dashboard/dashboard_screen.dart';
import 'package:kivicare_patient/main.dart';
import 'package:kivicare_patient/screens/pharmacy/pharmacy_controller.dart';
import 'package:kivicare_patient/screens/walkthrough/walkthrough_screen.dart';
import 'package:kivicare_patient/utils/app_common.dart';
import 'package:kivicare_patient/utils/common_base.dart';
import 'package:kivicare_patient/utils/constants.dart';
import 'package:nb_utils/nb_utils.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  tearDown(Get.reset);

  testWidgets('RTL filter action has one name and routes without an overlay',
      (tester) async {
    final semantics = tester.ensureSemantics();
    try {
      await tester.pumpWidget(
        GetMaterialApp(
          home: Directionality(
            textDirection: ui.TextDirection.rtl,
            child: Scaffold(
              body: Builder(
                builder: (context) => Align(
                  alignment: AlignmentDirectional.topEnd,
                  child: AccessibleFilterButton(
                    count: 2,
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const Scaffold(
                          body: Center(child: Text('Filtered results')),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.bySemanticsLabel(RegExp(r'.*: 2$')), findsOneWidget);
      expect(tester.getSize(find.byType(InkWell).first).width, 48);
      await tester.tap(find.byType(AccessibleFilterButton));
      await tester.pumpAndSettle();

      expect(find.text('Filtered results'), findsOneWidget);
      expect(find.byType(FloatingActionButton), findsNothing);
    } finally {
      semantics.dispose();
    }
  });

  testWidgets('ambiguous submission exposes a verification route',
      (tester) async {
    await tester.pumpWidget(
      GetMaterialApp(
        home: OperationVerificationScreen(
          recordsScreen: () => const Scaffold(
            body: Center(child: Text('Records')),
          ),
        ),
      ),
    );

    expect(find.byIcon(Icons.manage_search_rounded), findsOneWidget);
    expect(find.byType(AppButton), findsOneWidget);
    await tester.tap(find.byType(AppButton));
    await tester.pumpAndSettle();
    expect(find.text('Records'), findsOneWidget);
  });

  testWidgets('guest guard opens sign-in and returns false without submitting',
      (tester) async {
    final wasLoggedIn = isLoggedIn.value;
    addTearDown(() => isLoggedIn(wasLoggedIn));
    isLoggedIn(false);
    bool? authResult;

    await tester.pumpWidget(
      GetMaterialApp(
        home: Scaffold(
          body: Center(
            child: ElevatedButton(
              onPressed: () async {
                authResult = await requireAuthenticated();
              },
              child: const Text('Open protected feature'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open protected feature'));
    await tester.pumpAndSettle();

    expect(find.byType(SignInScreen), findsOneWidget);
    expect(find.text(locale.value.signIn), findsOneWidget);

    final emailField = find.byWidgetPredicate(
      (widget) =>
          widget is EditableText &&
          widget.keyboardType == TextInputType.emailAddress,
    );
    final passwordField = find.byWidgetPredicate(
      (widget) => widget is EditableText && widget.obscureText,
    );
    expect(find.byType(AppTextField), findsNWidgets(2));
    expect(emailField, findsOneWidget);
    expect(passwordField, findsOneWidget);
    await tester.enterText(emailField, 'guest@example.com');
    await tester.enterText(passwordField, 'password');

    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();

    expect(authResult, isFalse);
    expect(find.text('Open protected feature'), findsOneWidget);
  });

  testWidgets('switching locale updates direction and filter semantics',
      (tester) async {
    final originalLanguageCode = selectedLanguageCode.value;
    final originalLocale = locale.value;
    final originalIntlLocale = Intl.defaultLocale;
    final originalGetLocale = Get.locale;
    addTearDown(() {
      selectedLanguageCode(originalLanguageCode);
      locale(originalLocale);
      Intl.defaultLocale = originalIntlLocale;
      Get.locale = originalGetLocale;
    });

    final BaseLanguage english =
        await const AppLocalizations().load(const Locale('en'));
    final BaseLanguage arabic =
        await const AppLocalizations().load(const Locale('ar'));
    selectedLanguageCode('en');
    locale = english.obs;
    Intl.defaultLocale = 'en';

    await tester.pumpWidget(
      StatefulBuilder(
        builder: (context, setState) => GetMaterialApp(
          locale: Locale(selectedLanguageCode.value),
          supportedLocales: const [Locale('en'), Locale('ar')],
          localizationsDelegates: const [
            AppLocalizations(),
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: Scaffold(
            body: Column(
              children: [
                ElevatedButton(
                  onPressed: () {
                    selectedLanguageCode('ar');
                    locale = arabic.obs;
                    Intl.defaultLocale = 'ar';
                    Get.updateLocale(const Locale('ar'));
                    setState(() {});
                  },
                  child: const Text('Switch to Arabic'),
                ),
                AccessibleFilterButton(count: 1, onPressed: () {}),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final filterButton = find.byType(AccessibleFilterButton);
    expect(
        Directionality.of(tester.element(filterButton)), ui.TextDirection.ltr);
    expect(find.bySemanticsLabel('Filter: 1'), findsOneWidget);
    final englishBadge = tester.getRect(find.text('1'));
    expect(englishBadge.center.dx,
        greaterThan(tester.getRect(filterButton).center.dx));

    await tester.tap(find.text('Switch to Arabic'));
    await tester.pumpAndSettle();

    expect(
        Directionality.of(tester.element(filterButton)), ui.TextDirection.rtl);
    expect(find.bySemanticsLabel('تصفية: 1'), findsOneWidget);
    final arabicBadge = tester.getRect(find.text('1'));
    expect(arabicBadge.center.dx,
        lessThan(tester.getRect(filterButton).center.dx));
  });

  testWidgets(
      'guest onboarding skips walkthrough, explores, and opens dashboard',
      (tester) async {
    await GetStorage.init();
    final box = GetStorage();
    final hadFirstTime = box.hasData(SharedPreferenceConst.FIRST_TIME);
    final originalFirstTime = box.read(SharedPreferenceConst.FIRST_TIME);
    final hadLoggedIn = box.hasData(SharedPreferenceConst.IS_LOGGED_IN);
    final originalLoggedIn = box.read(SharedPreferenceConst.IS_LOGGED_IN);
    final originalIsLoggedIn = isLoggedIn.value;
    final originalLanguageCode = selectedLanguageCode.value;
    final originalLocale = locale.value;
    final originalIntlLocale = Intl.defaultLocale;
    final originalGetLocale = Get.locale;
    addTearDown(() async {
      if (hadFirstTime) {
        await box.write(SharedPreferenceConst.FIRST_TIME, originalFirstTime);
      } else {
        await box.remove(SharedPreferenceConst.FIRST_TIME);
      }
      if (hadLoggedIn) {
        await box.write(SharedPreferenceConst.IS_LOGGED_IN, originalLoggedIn);
      } else {
        await box.remove(SharedPreferenceConst.IS_LOGGED_IN);
      }
      isLoggedIn(originalIsLoggedIn);
      selectedLanguageCode(originalLanguageCode);
      locale(originalLocale);
      Intl.defaultLocale = originalIntlLocale;
      Get.locale = originalGetLocale;
    });

    selectedLanguageCode('en');
    final english = await const AppLocalizations().load(const Locale('en'));
    locale = english.obs;
    Intl.defaultLocale = 'en';
    Get.updateLocale(const Locale('en'));
    isLoggedIn(false);
    await box.write(SharedPreferenceConst.FIRST_TIME, false);
    await box.write(SharedPreferenceConst.IS_LOGGED_IN, false);

    PharmacyController.ensureRegistered();
    await tester.pumpWidget(
      GetMaterialApp(
        locale: const Locale('en'),
        supportedLocales: const [Locale('en'), Locale('ar')],
        localizationsDelegates: const [
          AppLocalizations(),
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: WalkthroughScreen(),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(WalkthroughScreen), findsOneWidget);
    expect(find.text(english.skip), findsOneWidget);

    await tester.tap(find.text(english.skip));
    await tester.pumpAndSettle();
    expect(find.byType(WelcomeScreen), findsOneWidget);
    expect(find.text(english.explore), findsOneWidget);
    expect(box.read(SharedPreferenceConst.FIRST_TIME), isTrue);

    await tester.tap(find.text(english.explore));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(find.byType(DashboardScreen), findsOneWidget);
    expect(Get.currentRoute, isNot('/'));
    expect(Get.key.currentState?.canPop(), isFalse);
  });
}
