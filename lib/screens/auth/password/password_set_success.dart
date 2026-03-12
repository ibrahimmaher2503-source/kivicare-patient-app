import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../components/app_scaffold.dart';
import '../../../generated/assets.dart';
import '../../../main.dart';
import '../../../utils/app_common.dart';
import '../../../utils/colors.dart';

class PasswordSetSuccess extends StatelessWidget {
  const PasswordSetSuccess({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      hideAppBar: true,
      body: Container(
        alignment: Alignment.center,
        height: Get.height,
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Success icon with gradient glow
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [gradientSecondaryStart, gradientSecondaryEnd],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: appColorSecondary.withValues(alpha: 0.3),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(Icons.check_rounded, color: Colors.white, size: 48),
              ),
              32.height,
              // Success image
              Container(
                padding: const EdgeInsets.all(20),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isDarkMode.value ? surfaceElevatedDark : surfaceElevated,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: isDarkMode.value ? softShadowColorDark : softShadowColor,
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Image.asset(Assets.imagesVector4),
              ),
              32.height,
              SizedBox(
                width: Get.width * 0.8,
                child: Text(
                  locale.value.yourPasswordHasBeen,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                    color: isDarkMode.value ? Colors.white : primaryTextColor,
                  ),
                ),
              ),
              16.height,
              SizedBox(
                width: Get.width * 0.8,
                child: Text(
                  locale.value.youCanNowLog,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    color: secondaryTextColor,
                    letterSpacing: 0.1,
                  ),
                ),
              ),
              48.height,
              // Gradient CTA button
              GestureDetector(
                onTap: () {
                  Get.back();
                  Get.back();
                },
                child: Container(
                  width: Get.width,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [gradientSecondaryStart, gradientSecondaryEnd]),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: appColorSecondary.withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Text(
                    locale.value.done,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 0.1,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
