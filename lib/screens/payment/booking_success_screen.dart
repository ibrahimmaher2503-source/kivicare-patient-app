import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../components/app_scaffold.dart';
import '../../generated/assets.dart';
import '../../main.dart';
import '../../utils/app_common.dart';
import '../../utils/colors.dart';
import '../../utils/common_base.dart';
import '../../utils/price_widget.dart';
import '../booking/model/save_booking_res.dart';

class BookingSuccessScreen extends StatelessWidget {
  BookingSuccessScreen({super.key});

  final RxBool isLoading = false.obs;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      hideAppBar: true,
      isLoading: isLoading,
      body: Container(
        height: Get.height * 0.7,
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
        child: Stack(
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.vertical,
              padding: const EdgeInsets.only(top: 50, bottom: 30),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  /// Animated checkmark circle with gradient glow
                  Container(
                    padding: const EdgeInsets.all(24),
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
                          color: appColorSecondary.withValues(alpha: 0.3),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Image.asset(Assets.imagesConfirm, scale: 1),
                  ),
                  24.height,
                  Text(
                    locale.value.great,
                    style: GoogleFonts.outfit(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5,
                      color: appColorSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  16.height,
                  Text(
                    locale.value.bookingSuccessful,
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.3,
                      color: isDarkMode.value ? Colors.white : appColorPrimary,
                    ),
                  ),
                  8.height,
                  Text(
                    locale.value.yourAppointmentHasBeenBookedSuccessfully,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      color: secondaryTextColor,
                      letterSpacing: 0.1,
                    ),
                  ),
                  32.height,
                  Wrap(
                    runSpacing: 8,
                    spacing: 4,
                    children: List.generate(
                      Get.width ~/ 14,
                      (index) => Container(
                        width: 8,
                        height: 2,
                        decoration: BoxDecoration(
                          color: isDarkMode.value
                              ? context.dividerColor.withValues(alpha: 0.15)
                              : context.dividerColor.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(1),
                        ),
                      ),
                    ),
                  ),
                  32.height,
                  Text(
                    "To ${saveBookingRes.value.saveBookingResData.clinicName.capitalizeEachWord()} On ${saveBookingRes.value.saveBookingResData.appointmentDate.dateInDMMMMyyyyFormat} At ${saveBookingRes.value.saveBookingResData.appointmentTime.format24HourtoAMPM} ${saveBookingRes.value.saveBookingResData.endTime.isNotEmpty ? "-" : ""} ${saveBookingRes.value.saveBookingResData.endTime.isNotEmpty ? saveBookingRes.value.saveBookingResData.endTime.format24HourtoAMPM : ""}",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      color: secondaryTextColor,
                      letterSpacing: 0.1,
                    ),
                  ).paddingSymmetric(horizontal: 16),
                  32.height,
                  Text(
                    saveBookingRes.value.saveBookingResData.advancePaidAmount != 0 ? locale.value.advancePayment : locale.value.totalPayment,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: secondaryTextColor,
                      letterSpacing: 0.1,
                    ),
                  ),
                  16.height,
                  PriceWidget(
                    price: saveBookingRes.value.saveBookingResData.advancePaidAmount != 0 ? saveBookingRes.value.saveBookingResData.advancePaidAmount : saveBookingRes.value.saveBookingResData.totalAmount,
                    color: appColorPrimary,
                    size: 20,
                  ),
                ],
              ),
            ).paddingBottom(80),
            Positioned(
              bottom: 22,
              left: 16,
              right: 16,
              child: Container(
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
                      /// To Clear Value
                      saveBookingRes(SaveBookingRes(saveBookingResData: SaveBookingResData()));
                      Get.back();
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      child: Center(
                        child: Text(
                          locale.value.goToAppointments,
                          style: GoogleFonts.outfit(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ).paddingSymmetric(horizontal: 16).center(),
    );
  }
}
