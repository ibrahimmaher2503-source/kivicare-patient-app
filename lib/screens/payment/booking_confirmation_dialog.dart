// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../components/cached_image_widget.dart';
import '../../configs.dart';

import '../../generated/assets.dart';
import '../../main.dart';
import '../../utils/app_common.dart';
import '../../utils/colors.dart';
class ConfirmBookingDialog extends StatelessWidget {
  RxBool isAgree = false.obs;
  final VoidCallback onConfirm;
  final String? titleText;
  final String? subTitleText;
  final String? confirmText;
  final String? changeToastMessage;
  final bool hideAgree;
  ConfirmBookingDialog({
    super.key,
    required this.onConfirm,
    this.titleText,
    this.subTitleText,
    this.confirmText,
    this.hideAgree = false,
    this.changeToastMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: Get.width,
      padding: const EdgeInsets.symmetric(vertical: 32),
      decoration: BoxDecoration(
        color: isDarkMode.value ? surfaceElevatedDark : surfaceElevated,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDarkMode.value ? glassStrokeDark : glassStrokeLight,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isDarkMode.value ? softShadowColorDark : softShadowColorMedium,
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          /// Confirmation icon with gradient glow
          Container(
            height: 100,
            width: 100,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [gradientSecondaryStart, gradientSecondaryEnd],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: appColorSecondary.withValues(alpha: 0.25),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: const CachedImageWidget(url: Assets.iconsIcConfirmation, height: 50, width: 50, fit: BoxFit.contain),
          ),
          16.height,
          Text(
            titleText ?? locale.value.confirmAppointment,
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.3,
              color: isDarkMode.value ? Colors.white : appColorPrimary,
            ),
          ),
          16.height,
          Text(
            subTitleText ?? locale.value.doYouConfirmThisAppointment,
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              color: secondaryTextColor,
              letterSpacing: 0.1,
            ),
          ).paddingSymmetric(horizontal: 32),
          16.height,
          Obx(
            () => CheckboxListTile(
              checkColor: whiteColor,
              value: isAgree.value,
              activeColor: appColorSecondary,
              onChanged: (val) async {
                isAgree.value = !isAgree.value;
              },
              checkboxShape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(5)),
              ),
              side: const BorderSide(color: secondaryTextColor, width: 1.5),
              title: Text(
                "${confirmText ?? locale.value.iHaveReadAll} $APP_NAME.",
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  color: secondaryTextColor,
                  letterSpacing: 0.1,
                ),
              ),
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
            ).paddingSymmetric(horizontal: 16).visible(!hideAgree),
          ),
          32.height,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              /// Cancel button with subtle surface
              Container(
                decoration: BoxDecoration(
                  color: isDarkMode.value ? lightSecondaryColor.withValues(alpha: 0.1) : lightSecondaryColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      Get.back();
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      child: Center(
                        child: Text(
                          locale.value.cancel,
                          style: GoogleFonts.outfit(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: appColorSecondary,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ).expand(),
              32.width,

              /// Confirm button with teal gradient
              Container(
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
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      if (hideAgree) {
                        onConfirm.call();
                      } else {
                        if (isAgree.value) {
                          onConfirm.call();
                        } else {
                          toast(changeToastMessage ?? locale.value.pleaseAcceptTermsAnd);
                        }
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      child: Center(
                        child: Text(
                          locale.value.confirm,
                          style: GoogleFonts.outfit(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ).expand(),
            ],
          ).paddingSymmetric(horizontal: 32),
        ],
      ),
    );
  }
}
