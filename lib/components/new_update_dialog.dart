import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:kivicare_patient/utils/colors.dart';
import '../generated/assets.dart';
import '../main.dart';
import '../utils/app_common.dart';
import 'package:url_launcher/url_launcher.dart';
import '../configs.dart';
import '../utils/common_base.dart';

class NewUpdateDialog extends StatelessWidget {
  final bool canClose;
  const NewUpdateDialog({super.key, this.canClose = true});

  @override
  Widget build(BuildContext context) {
    final bool dark = isDarkMode.value;
    return Stack(
      alignment: Alignment.topCenter,
      clipBehavior: Clip.none,
      children: [
        Container(
          width: Get.width - 16,
          constraints: BoxConstraints(maxHeight: Get.height * 0.6),
          decoration: BoxDecoration(
            color: dark ? surfaceElevatedDark : surfaceElevated,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: dark ? softShadowColorDark : softShadowColor,
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: AnimatedScrollView(
            listAnimationType: ListAnimationType.FadeIn,
            children: [
              60.height,
              Text(
                locale.value.newUpdate,
                style: GoogleFonts.outfit(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.3,
                  color: dark ? Colors.white : primaryTextColor,
                ),
              ),
              8.height,
              Text(
                "${locale.value.anUpdateTo}  $APP_NAME ${locale.value.isAvailableGoTo}",
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 0.1,
                  color: secondaryTextColor,
                ),
                textAlign: TextAlign.left,
              ),
              24.height,
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Later / Close App button
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () async {
                        if (canClose) {
                          Get.back();
                        } else {
                          exit(0);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: dark ? borderColorDark : borderColor.withValues(alpha: 0.3),
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          canClose ? locale.value.later : locale.value.closeApp,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: dark ? Colors.white70 : secondaryTextColor,
                          ),
                        ),
                      ),
                    ),
                  ).expand(),
                  16.width,
                  // Update Now button with teal gradient
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () async {
                        getPackageName().then((value) {
                          if (isAndroid) {
                            String package = '';
                            package = value;

                            log('dfdfdfdf: ${getSocialMediaLink(LinkProvider.PLAY_STORE)}$package}');
                            commonLaunchUrl(
                              '${getSocialMediaLink(LinkProvider.PLAY_STORE)}$package',
                              launchMode: LaunchMode.externalApplication,
                            );

                            if (canClose) {
                              Get.back();
                            } else {
                              exit(0);
                            }
                          } else if (isIOS) {
                            if (appConfigs.value.patientAppUrl.patientAppAppStore.trim().isNotEmpty) {
                              commonLaunchUrl(appConfigs.value.patientAppUrl.patientAppAppStore.trim(), launchMode: LaunchMode.externalApplication);
                            } else {
                              commonLaunchUrl(APP_APPSTORE_URL, launchMode: LaunchMode.externalApplication);
                            }

                            if (canClose) {
                              Get.back();
                            } else {
                              exit(0);
                            }
                          }
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          gradient: const LinearGradient(
                            colors: [gradientSecondaryStart, gradientSecondaryEnd],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: appColorSecondary.withValues(alpha: 0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          locale.value.updateNow,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ).expand(),
                ],
              ),
            ],
          ).paddingSymmetric(horizontal: 16, vertical: 24),
        ),
        Positioned(
          top: -42,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: dark ? softShadowColorDark : softShadowColor,
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Image.asset(Assets.imagesForceUpdate, height: 100, width: 100, fit: BoxFit.cover),
          ),
        ),
      ],
    );
  }
}
