import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../generated/assets.dart';
import '../../../main.dart';
import '../../../utils/app_common.dart';
import '../../../utils/colors.dart';
import '../../../utils/common_base.dart';
import '../../doctor/doctor_list_screen.dart';
import '../../service/services_list_screen.dart';
import '../clinic_detail_controller.dart';
import '../clinic_gallery_list_screen.dart';
import 'clinic_session_component.dart';

class ClinicDetailBtmComp extends StatelessWidget {
  final ClinicDetailController clinicDetailCont;

  const ClinicDetailBtmComp({super.key, required this.clinicDetailCont});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      width: Get.width,
      child: Column(
        children: [
          _buildSectionTile(
            context,
            title: locale.value.sessions,
            subtitle: locale.value.clinicSessionsInformation,
            iconPath: Assets.iconsIcClock,
            onTap: () {
              Get.to(() => ClinicSessionComponent(clinicDetailCont: clinicDetailCont));
            },
          ),
          12.height,
          Obx(
            () => _buildSectionTile(
              context,
              title: locale.value.services,
              subtitle: clinicDetailCont.clinicData.value.totalServices != 0
                  ? "${locale.value.total} ${clinicDetailCont.clinicData.value.totalServices} ${locale.value.servicesAvailable}"
                  : locale.value.noServicesAvailable,
              iconPath: Assets.iconsIcServices,
              onTap: () {
                Get.to(() => ServiceListScreen(isFromClinicDetail: true), arguments: clinicDetailCont.clinicData.value.id);
              },
            ),
          ),
          12.height,
          Obx(
            () => _buildSectionTile(
              context,
              title: locale.value.doctors,
              subtitle: clinicDetailCont.clinicData.value.totalDoctors != 0
                  ? "${locale.value.total} ${clinicDetailCont.clinicData.value.totalDoctors} ${locale.value.doctorsAvailable}"
                  : locale.value.noDoctorsAvailable,
              iconPath: Assets.iconsIcDoctor,
              onTap: () {
                Get.to(() => DoctorsListScreen(), arguments: clinicDetailCont.clinicData.value.id);
              },
            ),
          ),
          12.height,
          Obx(
            () => _buildSectionTile(
              context,
              title: locale.value.gallery,
              subtitle: clinicDetailCont.clinicData.value.totalGalleryImages != 0
                  ? "${locale.value.total} ${clinicDetailCont.clinicData.value.totalGalleryImages} ${locale.value.photosAvailable}"
                  : locale.value.noPhotosAvailable,
              iconPath: Assets.iconsIcGallery,
              onTap: () {
                Get.to(() => ClinicGalleryListScreen(), arguments: clinicDetailCont.clinicData.value.id);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String iconPath,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          color: isDarkMode.value ? surfaceElevatedDark : surfaceElevated,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: isDarkMode.value ? softShadowColorDark : softShadowColor,
              blurRadius: 12,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isDarkMode.value ? appColorSecondary.withValues(alpha: 0.15) : lightSecondaryColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: commonLeadingWid(imgPath: iconPath, color: appColorSecondary),
            ),
            16.width,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDarkMode.value ? Colors.white : appColorPrimary,
                    ),
                  ),
                  4.height,
                  Text(
                    subtitle,
                    style: GoogleFonts.plusJakartaSans(fontSize: 12, color: secondaryTextColor),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: isDarkMode.value ? Colors.white.withValues(alpha: 0.05) : surfaceSubtle,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.arrow_forward_ios_rounded,
                size: 12,
                color: isDarkMode.value ? Colors.white54 : secondaryTextColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
