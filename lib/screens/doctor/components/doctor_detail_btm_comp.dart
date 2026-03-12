import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kivicare_patient/main.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../generated/assets.dart';
import '../../../utils/app_common.dart';
import '../../../utils/colors.dart';
import '../../../utils/common_base.dart';
import '../doctor_detail_controller.dart';
import 'about_doctor_component.dart';
import 'doctor_qualification_component.dart';
import '../doctor_review_screen.dart';
import 'doctor_services_component.dart';

class DoctorDetailBtmComp extends StatelessWidget {
  final DoctorDetailController doctorDetailCont;

  const DoctorDetailBtmComp({super.key, required this.doctorDetailCont});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      width: Get.width,
      child: Column(
        children: [
          _buildSectionItem(
            context: context,
            title: locale.value.aboutMyself,
            subtitle: locale.value.experienceSpecializationContactInfo,
            iconPath: Assets.iconsIcInfo,
            onTap: () {
              Get.to(() => AboutDoctorComponent(doctorData: doctorDetailCont.doctorData.value));
            },
          ),
          Obx(
            () => _buildSectionItem(
              context: context,
              title: locale.value.services,
              subtitle: doctorDetailCont.doctorData.value.totalServices != 0 ? "${locale.value.total} ${doctorDetailCont.doctorData.value.totalServices} ${locale.value.servicesAvailable}" : locale.value.noServicesAvailable,
              iconPath: Assets.iconsIcServices,
              onTap: () {
                Get.to(() => DoctorServicesComponent());
              },
            ).paddingTop(16),
          ),
          Obx(
            () => _buildSectionItem(
              context: context,
              title: locale.value.reviews,
              subtitle: doctorDetailCont.doctorData.value.totalReviews != 0 ? "${locale.value.total} ${doctorDetailCont.doctorData.value.totalReviews} ${locale.value.reviews}" : locale.value.noReviewsAvailable,
              iconPath: Assets.iconsIcStar,
              onTap: () {
                Get.to(() => DoctorReviewScreen(), arguments: doctorDetailCont.doctorData.value.doctorId);
              },
            ).paddingTop(16),
          ),
          _buildSectionItem(
            context: context,
            title: locale.value.qualification,
            subtitle: locale.value.qualificationInDetail,
            iconPath: Assets.iconsIcQualification,
            onTap: () {
              Get.to(() => QualificationComponent(qualificationList: doctorDetailCont.doctorData.value.qualifications));
            },
          ).paddingTop(16),
        ],
      ),
    );
  }

  Widget _buildSectionItem({
    required BuildContext context,
    required String title,
    required String subtitle,
    required String iconPath,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.translucent,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
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
        child: Row(
          children: [
            commonLeadingWid(imgPath: iconPath, color: appColorSecondary),
            16.width,
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                    color: isDarkMode.value ? Colors.white : appColorPrimary,
                  ),
                ),
                4.height,
                Text(
                  subtitle,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: secondaryTextColor,
                  ),
                ),
              ],
            ).expand(),
            Icon(Icons.arrow_forward_ios_rounded, size: 14, color: secondaryTextColor),
          ],
        ),
      ),
    );
  }
}
