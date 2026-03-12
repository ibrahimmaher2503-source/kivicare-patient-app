import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kivicare_patient/utils/colors.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../../components/cached_image_widget.dart';
import '../../../components/app_custom_dialog.dart';
import '../../../generated/assets.dart';
import '../../../main.dart';
import '../../../utils/app_common.dart';
import '../../../utils/price_widget.dart';
import '../../clinic/clinics_list_screen.dart';
import '../../doctor/doctor_list_screen.dart';
import '../model/service_list_model.dart';
import '../service_detail_controller.dart';
import '../service_detail_screen.dart';

class ServiceCard extends StatelessWidget {
  final ServiceElement serviceElement;
  final bool isFromClinicDetail;

  const ServiceCard({super.key, required this.serviceElement, this.isFromClinicDetail = false});

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
        width: Get.width / 2 - 24,
        child: Column(
          children: [
            Hero(
              tag: serviceElement.serviceImage.trim().isNotEmpty ? "${serviceElement.id}${serviceElement.serviceImage}" : UniqueKey(),
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: CachedImageWidget(
                        url: serviceElement.serviceImage,
                        fit: BoxFit.cover,
                        width: Get.width / 2 - 40,
                        height: Get.height * 0.15,
                      ),
                    ),
                  ),
                  if (serviceElement.isVideoConsultancy)
                    Positioned(
                      bottom: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [gradientSecondaryStart, gradientSecondaryEnd]),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: CachedImageWidget(
                          url: Assets.imagesVideoCamera,
                          fit: BoxFit.fitHeight,
                          height: 10,
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      serviceElement.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.3,
                        color: isDarkMode.value ? Colors.white : primaryTextColor,
                      ),
                    ).flexible(),
                  ],
                ),
                8.height,
                Marquee(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    spacing: 6,
                    children: [
                      if (serviceElement.payableAmount != serviceElement.charges)
                        PriceWidget(price: serviceElement.payableAmount, size: 18, color: appColorSecondary),
                      if (!serviceElement.isInclusiveTaxesAvailable)
                        PriceWidget(
                          price: serviceElement.charges,
                          isLineThroughEnabled: serviceElement.isDiscount ? true : false,
                          size: serviceElement.isDiscount ? 14 : 18,
                          color: serviceElement.isDiscount ? textSecondaryColorGlobal : appColorSecondary,
                        ),
                      if (serviceElement.isInclusiveTaxesAvailable) ...[
                        Text(
                          locale.value.includesInclusiveTax,
                          style: GoogleFonts.plusJakartaSans(
                            color: appColorSecondary,
                            fontSize: 10,
                            fontStyle: FontStyle.italic,
                            letterSpacing: 0.1,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                12.height,
                // Gradient Book Now button
                GestureDetector(
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
                  child: Container(
                    width: Get.width,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [gradientSecondaryStart, gradientSecondaryEnd]),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: appColorSecondary.withValues(alpha: 0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      locale.value.bookNow,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 0.1,
                      ),
                    ),
                  ),
                ),
              ],
            ).paddingSymmetric(horizontal: 12, vertical: 12),
          ],
        ),
      ),
    );
  }
}
