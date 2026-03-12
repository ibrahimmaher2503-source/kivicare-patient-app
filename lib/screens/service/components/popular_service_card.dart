import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../components/app_custom_dialog.dart';
import '../../../components/cached_image_widget.dart';
import '../../../main.dart';
import '../../../utils/app_common.dart';
import '../../../utils/colors.dart';
import '../../../utils/price_widget.dart';
import '../../clinic/clinics_list_screen.dart';
import '../../doctor/doctor_list_screen.dart';
import '../model/service_list_model.dart';
import '../service_detail_controller.dart';
import '../service_detail_screen.dart';

class PopularServiceCard extends StatelessWidget {
  final ServiceElement serviceElement;
  final bool isFromClinicDetail;

  const PopularServiceCard({
    super.key,
    required this.serviceElement,
    this.isFromClinicDetail = false,
  });
  String formatDuration(int minutes) {
    final hours = minutes ~/ 60;
    final mins = minutes % 60;

    if (hours > 0 && mins > 0) {
      return '${hours}h ${mins}m';
    } else if (hours > 0) {
      return '${hours}h';
    } else {
      return '${mins}m';
    }
  }
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (isFromClinicDetail) {
          Get.delete<ServiceDetailController>();
        }
        Get.to(() => ServiceDetailScreen(isFromClinicDetail: isFromClinicDetail), arguments: serviceElement);
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: isDarkMode.value ? surfaceElevatedDark : surfaceElevated,
          boxShadow: [
            BoxShadow(
              color: isDarkMode.value ? softShadowColorDark : softShadowColor,
              blurRadius: 16,
              offset: const Offset(0, 4),
              spreadRadius: 0,
            ),
          ],
        ),
        width: Get.width / 2 - 24,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: CachedImageWidget(
                      url: serviceElement.serviceImage,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: 120,
                    ),
                  ),
                ),
                Positioned(
                  top: 16,
                  left: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: white.withValues(alpha: 0.92),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      serviceElement.categoryName,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: appColorSecondary,
                      ),
                    ),
                  ),
                )
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  serviceElement.name,
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                    color: isDarkMode.value ? Colors.white : appColorPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                8.height,
                Marquee(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    spacing: 6,
                    children: [
                      if (serviceElement.payableAmount != serviceElement.charges) PriceWidget(price: serviceElement.payableAmount, size: 18, color: appColorSecondary),
                      if (!serviceElement.isInclusiveTaxesAvailable)
                        PriceWidget(
                          price: serviceElement.charges,
                          isLineThroughEnabled: serviceElement.isDiscount ? true : false,
                          size: serviceElement.isDiscount ? 13 : 18,
                          color: serviceElement.isDiscount ? textSecondaryColorGlobal : appColorSecondary,
                        ),
                      if (serviceElement.isInclusiveTaxesAvailable) ...[
                        Text(
                          locale.value.includesInclusiveTax,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: appColorSecondary,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                8.height,
                Row(
                  children: [
                    Icon(Icons.access_time_rounded, size: 14, color: appColorSecondary),
                    4.width,
                    Text(
                      "Duration: ",
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: secondaryTextColor,
                      ),
                    ),
                    Text(
                      formatDuration(serviceElement.duration.validate().toInt()),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isDarkMode.value ? Colors.white : appColorPrimary,
                      ),
                    ),
                  ],
                ),
                16.height,
                AppButton(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  width: Get.width,
                  elevation: 0,
                  color: appColorSecondary,
                  shapeBorder: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  onTap: () {
                    if (isFromClinicDetail) {
                      showInDialog(
                        context,
                        contentPadding: EdgeInsets.zero,
                        builder: (context) {
                          return AppCustomDialog(
                            title: locale.value.doYouWantToReplaceThePreviousServiceWithTheCu,
                            negativeText: locale.value.no,
                            positiveText: locale.value.yes,
                            onTap: () {
                              currentSelectedService(serviceElement);
                              Get.back();
                              Get.to(() => DoctorsListScreen(), arguments: currentSelectedClinic.value.id);
                            },
                          );
                        },
                      );
                    } else {
                      currentSelectedService(serviceElement);
                      Get.to(() => ClinicListScreen(), arguments: serviceElement);
                    }
                  },
                  child: Text(
                    locale.value.bookNow,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: white,
                    ),
                  ),
                ),
              ],
            ).paddingSymmetric(horizontal: 12, vertical: 8)
          ],
        ),
      ),
    );
  }
}