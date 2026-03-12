import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';

import '../utils/colors.dart';

class AppTheme {
  AppTheme._();

  static TextTheme _buildTextTheme(TextTheme base) {
    final bodyFont = GoogleFonts.plusJakartaSans();
    final displayFont = GoogleFonts.outfit();
    return base.copyWith(
      displayLarge: displayFont.copyWith(letterSpacing: -0.5),
      displayMedium: displayFont.copyWith(letterSpacing: -0.5),
      displaySmall: displayFont.copyWith(letterSpacing: -0.5),
      headlineLarge: displayFont.copyWith(letterSpacing: -0.5),
      headlineMedium: displayFont.copyWith(letterSpacing: -0.3),
      headlineSmall: displayFont.copyWith(letterSpacing: -0.3),
      titleLarge: displayFont.copyWith(letterSpacing: -0.3),
      titleMedium: bodyFont.copyWith(letterSpacing: 0.1),
      titleSmall: bodyFont.copyWith(letterSpacing: 0.1),
      bodyLarge: bodyFont.copyWith(letterSpacing: 0.1),
      bodyMedium: bodyFont.copyWith(letterSpacing: 0.1),
      bodySmall: bodyFont.copyWith(letterSpacing: 0.1),
      labelLarge: bodyFont.copyWith(letterSpacing: 0.1),
      labelMedium: bodyFont.copyWith(letterSpacing: 0.1),
      labelSmall: bodyFont.copyWith(letterSpacing: 0.1),
    );
  }

  static final ThemeData lightTheme = ThemeData(
    scaffoldBackgroundColor: appScreenBackground,
    primaryColor: appColorPrimary,
    primaryColorDark: appColorPrimary,
    colorScheme: ColorScheme.fromSeed(
      seedColor: appColorPrimary,
      primary: appColorPrimary,
      surface: const Color(0xFFF1F3F4),
      secondary: appColorSecondary,
      brightness: Brightness.light,
    ),
    useMaterial3: true,
    hoverColor: Colors.white54,
    dividerColor: const Color(0xFF626E8A),
    fontFamily: GoogleFonts.plusJakartaSans().fontFamily,
    drawerTheme: const DrawerThemeData(backgroundColor: appScreenBackground),
    appBarTheme: AppBarTheme(
      surfaceTintColor: appLayoutBackground,
      color: appLayoutBackground,
      iconTheme: const IconThemeData(color: textPrimaryColor),
      titleTextStyle: TextStyle(
        color: canvasColor,
        fontFamily: GoogleFonts.plusJakartaSans().fontFamily,
      ),
      systemOverlayStyle: const SystemUiOverlayStyle(statusBarBrightness: Brightness.light, statusBarIconBrightness: Brightness.dark),
    ),
    tabBarTheme: const TabBarThemeData(indicator: UnderlineTabIndicator(borderSide: BorderSide(color: Color(0xFFB6D5EF), width: 3))),
    textSelectionTheme: const TextSelectionThemeData(cursorColor: appColorPrimary),
    cardTheme: const CardThemeData(color: Colors.white),
    cardColor: appSectionBackground,
    iconTheme: const IconThemeData(color: textPrimaryColor),
    bottomSheetTheme: const BottomSheetThemeData(backgroundColor: whiteColor),
    textTheme: _buildTextTheme(GoogleFonts.plusJakartaSansTextTheme()),
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
      surface: const Color(0xFFF1F3F4),
      secondary: appColorSecondary,
      brightness: Brightness.dark,
    ),
    useMaterial3: true,
    hoverColor: Colors.black12,
    dividerColor: canvasColor,
    fontFamily: GoogleFonts.plusJakartaSans().fontFamily,
    drawerTheme: const DrawerThemeData(backgroundColor: fullDarkCanvasColorDark),
    appBarTheme: AppBarTheme(
      surfaceTintColor: appScreenBackgroundDark,
      color: appScreenBackgroundDark,
      iconTheme: const IconThemeData(color: whiteColor),
      titleTextStyle: TextStyle(
        color: whiteTextColor,
        fontFamily: GoogleFonts.plusJakartaSans().fontFamily,
      ),
      systemOverlayStyle: const SystemUiOverlayStyle(statusBarBrightness: Brightness.light, statusBarIconBrightness: Brightness.light),
    ),
    tabBarTheme: const TabBarThemeData(indicator: UnderlineTabIndicator(borderSide: BorderSide(color: Colors.white))),
    textSelectionTheme: const TextSelectionThemeData(cursorColor: appColorPrimary),
    cardTheme: const CardThemeData(color: fullDarkCanvasColor),
    cardColor: fullDarkCanvasColor,
    iconTheme: const IconThemeData(color: whiteColor),
    bottomSheetTheme: const BottomSheetThemeData(backgroundColor: appBackgroundColorDark),
    textTheme: _buildTextTheme(GoogleFonts.plusJakartaSansTextTheme()),
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