import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nb_utils/nb_utils.dart';

import '../utils/colors.dart';

class AppTheme {
  AppTheme._();

  static const _baseTextTheme = TextTheme(
    bodyLarge: TextStyle(
      fontFamily: 'PlusJakartaSans',
      fontSize: 16,
      height: 1.5,
    ),
    bodyMedium: TextStyle(
      fontFamily: 'PlusJakartaSans',
      fontSize: 16,
      height: 1.5,
    ),
    bodySmall: TextStyle(
      fontFamily: 'PlusJakartaSans',
      fontSize: 14,
      height: 1.45,
    ),
    titleLarge: TextStyle(
      fontFamily: 'Outfit',
      fontSize: 22,
      fontWeight: FontWeight.w600,
      height: 1.3,
    ),
    titleMedium: TextStyle(
      fontFamily: 'Outfit',
      fontSize: 18,
      fontWeight: FontWeight.w600,
      height: 1.35,
    ),
    titleSmall: TextStyle(
      fontFamily: 'Outfit',
      fontSize: 16,
      fontWeight: FontWeight.w600,
      height: 1.4,
    ),
    labelLarge: TextStyle(
      fontFamily: 'PlusJakartaSans',
      fontSize: 16,
      fontWeight: FontWeight.w600,
    ),
  );

  static final ThemeData lightTheme = ThemeData(
    scaffoldBackgroundColor: appScreenBackground,
    primaryColor: appColorPrimary,
    primaryColorDark: appColorPrimary,
    colorScheme: ColorScheme.fromSeed(
      seedColor: appColorPrimary,
      primary: appColorPrimary,
      onPrimary: const Color(0xFFF8FAFB),
      surface: const Color(0xFFF1F3F4),
      onSurface: primaryTextColor,
      secondary: appColorSecondary,
      onSecondary: const Color(0xFFF8FAFB),
      error: cancelStatusColor,
      brightness: Brightness.light,
    ),
    useMaterial3: true,
    hoverColor: Colors.white54,
    dividerColor: const Color(0xFF626E8A),
    fontFamily: 'PlusJakartaSans',
    drawerTheme: const DrawerThemeData(backgroundColor: appScreenBackground),
    appBarTheme: AppBarTheme(
      surfaceTintColor: appLayoutBackground,
      backgroundColor: appLayoutBackground,
      iconTheme: const IconThemeData(color: textPrimaryColor),
      titleTextStyle: TextStyle(
        color: canvasColor,
        fontFamily: 'Outfit',
      ),
      systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarBrightness: Brightness.light,
          statusBarIconBrightness: Brightness.dark),
    ),
    tabBarTheme: const TabBarThemeData(
        indicator: UnderlineTabIndicator(
            borderSide: BorderSide(color: Color(0xFFB6D5EF), width: 3))),
    textSelectionTheme:
        const TextSelectionThemeData(cursorColor: appColorPrimary),
    cardTheme: const CardThemeData(color: Colors.white),
    cardColor: appSectionBackground,
    iconTheme: const IconThemeData(color: textPrimaryColor),
    bottomSheetTheme: const BottomSheetThemeData(backgroundColor: whiteColor),
    textTheme: _baseTextTheme.apply(
      bodyColor: primaryTextColor,
      displayColor: primaryTextColor,
    ),
    //visualDensity: VisualDensity.adaptivePlatformDensity,
    radioTheme: RadioThemeData(
      fillColor: WidgetStateProperty.all(appColorPrimary),
    ),
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: <TargetPlatform, PageTransitionsBuilder>{
        TargetPlatform.android: OpenUpwardsPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.linux: OpenUpwardsPageTransitionsBuilder(),
        TargetPlatform.macOS: OpenUpwardsPageTransitionsBuilder(),
      },
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    scaffoldBackgroundColor: appScreenBackgroundDark,
    primaryColor: appColorPrimary,
    primaryColorDark: appColorPrimary,
    colorScheme: ColorScheme.fromSeed(
      seedColor: appColorPrimary,
      primary: appColorPrimary,
      onPrimary: textPrimaryDark,
      surface: appBackgroundSecondaryColorDark,
      onSurface: textPrimaryDark,
      secondary: appColorSecondary,
      onSecondary: textPrimaryDark,
      error: cancelStatusColor,
      brightness: Brightness.dark,
    ),
    useMaterial3: true,
    hoverColor: Colors.black12,
    dividerColor: canvasColor,
    fontFamily: 'PlusJakartaSans',
    drawerTheme:
        const DrawerThemeData(backgroundColor: fullDarkCanvasColorDark),
    appBarTheme: AppBarTheme(
      surfaceTintColor: appScreenBackgroundDark,
      backgroundColor: appScreenBackgroundDark,
      iconTheme: const IconThemeData(color: whiteColor),
      titleTextStyle: TextStyle(
        color: whiteTextColor,
        fontFamily: 'Outfit',
      ),
      systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarBrightness: Brightness.light,
          statusBarIconBrightness: Brightness.light),
    ),
    tabBarTheme: const TabBarThemeData(
        indicator:
            UnderlineTabIndicator(borderSide: BorderSide(color: Colors.white))),
    textSelectionTheme:
        const TextSelectionThemeData(cursorColor: appColorPrimary),
    cardTheme: const CardThemeData(color: fullDarkCanvasColor),
    cardColor: fullDarkCanvasColor,
    iconTheme: const IconThemeData(color: whiteColor),
    bottomSheetTheme:
        const BottomSheetThemeData(backgroundColor: appBackgroundColorDark),
    textTheme: _baseTextTheme.apply(
      bodyColor: textPrimaryDark,
      displayColor: textPrimaryDark,
    ),
    radioTheme: RadioThemeData(
      fillColor: WidgetStateProperty.all(appColorPrimary),
    ),
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: <TargetPlatform, PageTransitionsBuilder>{
        TargetPlatform.android: OpenUpwardsPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.linux: OpenUpwardsPageTransitionsBuilder(),
        TargetPlatform.macOS: OpenUpwardsPageTransitionsBuilder(),
      },
    ),
  );
}
