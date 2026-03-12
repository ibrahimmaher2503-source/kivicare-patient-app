// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kivicare_patient/components/cached_image_widget.dart';
import 'package:kivicare_patient/configs.dart';
import 'package:kivicare_patient/generated/assets.dart';
import 'package:kivicare_patient/main.dart';
import 'package:kivicare_patient/utils/app_common.dart';
import 'package:kivicare_patient/utils/colors.dart';
import 'package:kivicare_patient/utils/constants.dart';
import 'package:kivicare_patient/utils/price_widget.dart';
import 'package:nb_utils/nb_utils.dart';

class ConfirmBookingBottomSheet extends StatelessWidget {
  final VoidCallback onConfirm;
  final String? titleText;
  final String? subTitleText;
  final String? confirmText;
  final String? changeToastMessage;
  final bool hideAgree;
  final String serviceName;
  final String dateTime;
  final num price;
  final bool? isQuickBook;

  ConfirmBookingBottomSheet({
    super.key,
    required this.onConfirm,
    required this.serviceName,
    required this.dateTime,
    required this.price,
    this.titleText,
    this.subTitleText,
    this.confirmText,
    this.hideAgree = false,
    this.changeToastMessage,
    this.isQuickBook
  });

  RxBool isAgree = false.obs;
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        width: Get.width,
        padding: const EdgeInsets.only(top: 8, bottom: 32),
        decoration: BoxDecoration(
          color: isDarkMode.value ? surfaceElevatedDark : surfaceElevated,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          boxShadow: [
            BoxShadow(
              color: isDarkMode.value ? softShadowColorDark : softShadowColorMedium,
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            /// Handle indicator
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(top: 8, bottom: 16),
                decoration: BoxDecoration(
                  color: isDarkMode.value ? Colors.white24 : Colors.black12,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const CachedImageWidget(url: Assets.iconsIcConfirmation, height: 50, width: 50, fit: BoxFit.contain),
            16.height,
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  titleText ?? locale.value.confirmAppointment,
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                  textAlign: TextAlign.center,
                ),
                16.height,
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDarkMode.value ? inputFillColorDark : inputFillColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    spacing: 8,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            locale.value.serviceName.suffixText(value: ": "),
                            style: secondaryTextStyle(),
                          ).expand(flex: 1),
                          Text(serviceName, style: primaryTextStyle(size: 12)).expand(flex: 3),
                        ],
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            locale.value.dateTime.suffixText(value: ":"),
                            style: secondaryTextStyle(),
                          ).expand(flex: 1),
                          Text(
                            dateTime,
                            style: primaryTextStyle(size: 12),
                            textAlign: TextAlign.start,
                          ).expand(flex: 3),
                        ],
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            locale.value.price.suffixText(value: ': '),
                            style: secondaryTextStyle(),
                          ).expand(flex: 1),
                          PriceWidget(
                            price: price,
                            isSemiBoldText: true,
                            size: 12,
                            color: appColorSecondary,
                          ).expand(flex: 3),
                        ],
                      ),
                    ],
                  ),
                ),
                16.height,
                if (appConfigs.value.isCancellationChargeEnabled && isQuickBook != true) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: appColorSecondary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: appColorSecondary.withValues(alpha: 0.3), width: 1),
                    ),
                    child: Text(
                      locale.value.cancellationChargesWillBeAppliedForCancellationWithin(
                        appConfigs.value.cancellationType == TaxType.PERCENTAGE
                            ? appConfigs.value.isCancellationChargesAvailable
                                ? '${appConfigs.value.cancellationCharge}%'
                                : ''
                            : appConfigs.value.isCancellationChargesAvailable
                                ? '${leftCurrencyFormat()}${appConfigs.value.cancellationCharge.toStringAsFixed(appCurrency.value.noOfDecimal).formatNumberWithComma(seperator: appCurrency.value.thousandSeparator)}'
                                : '',
                        appConfigs.value.isCancellationHoursAvailable ? '${appConfigs.value.cancellationChargeHours}' : '',
                      ),
                      style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w600, color: appColorSecondary),
                    ),
                  ),
                  16.height,
                ],
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
                    title: Text("${confirmText ?? locale.value.iHaveReadAll} $APP_NAME.", style: secondaryTextStyle()),
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                  ).visible(!hideAgree),
                ),
              ],
            ).paddingSymmetric(horizontal: 16),
            24.height,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                AppButton(
                  text: locale.value.cancel,
                  textColor: isDarkMode.value ? white : blackColor,
                  color: isDarkMode.value ? surfaceElevatedDark : surfaceSubtle,
                  shapeBorder: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: isDarkMode.value ? borderColorDark : whiteBorderColor),
                  ),
                  onTap: () {
                    Get.back();
                  },
                ).expand(),
                24.width,
                GestureDetector(
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
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [gradientSecondaryStart, gradientSecondaryEnd],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: gradientSecondaryStart.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Text(
                      locale.value.continueText,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white),
                    ),
                  ),
                ).expand(),
              ],
            ).paddingSymmetric(horizontal: 24),
          ],
        ),
      ),
    );
  }
}