import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../configs.dart';
import '../generated/assets.dart';
import '../utils/app_common.dart';
import '../utils/colors.dart';
import '../utils/constants.dart';

class AppLogoWidget extends StatelessWidget {
  const AppLogoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final bool dark = isDarkMode.value;
    return Container(
      height: Constants.appLogoSize,
      width: Constants.appLogoSize,
      alignment: Alignment.center,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: dark ? surfaceElevatedDark : surfaceElevated,
        boxShadow: [
          BoxShadow(
            color: dark ? softShadowColorDark : softShadowColor,
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
          // Subtle teal glow accent
          BoxShadow(
            color: appColorSecondary.withValues(alpha: dark ? 0.08 : 0.06),
            blurRadius: 24,
            spreadRadius: 2,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Image.asset(
        Assets.assetsAppLogo,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Text(
          APP_NAME.toUpperCase(),
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.w700,
            color: appColorPrimary,
            letterSpacing: -0.5,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
