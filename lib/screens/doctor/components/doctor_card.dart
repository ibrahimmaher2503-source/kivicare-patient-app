import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:kivicare_patient/components/cached_image_widget.dart';
import 'package:kivicare_patient/screens/doctor/model/doctor_list_res.dart';
import '../../../components/location_badge.dart';

import '../../../../generated/assets.dart';
import '../../../utils/app_common.dart';
import '../../../utils/colors.dart';
import '../../../utils/common_base.dart';
import '../doctor_detail_screen.dart';
import '../doctor_list_controller.dart';

class DoctorCard extends StatelessWidget {
  final Doctor doctorData;

  DoctorCard({super.key, required this.doctorData});

  final DoctorListController doctorsListCont = Get.find();

  @override
  Widget build(BuildContext context) {
    final bool darkMode = isDarkMode.value;

    return Obx(
      () {
        final bool isSelected = doctorData.doctorId == doctorsListCont.selectedDoctor.value.doctorId;

        return GestureDetector(
          onTap: () {
            /// Store selected doctor in global variable
            if (isSelected) {
              /// Deselect, If again tap on same doctor
              doctorsListCont.selectedDoctor(Doctor());
              currentSelectedDoctor(doctorsListCont.selectedDoctor.value);
              log('CURRENT SELECTED CLINIC ID==> ${currentSelectedDoctor.value.doctorId}');
              log('CURRENT SELECTED CLINIC NAME==> ${currentSelectedDoctor.value.fullName}');
            } else {
              doctorsListCont.selectedDoctor(doctorData);
              currentSelectedDoctor(doctorsListCont.selectedDoctor.value);
              log('CURRENT SELECTED CLINIC ID==> ${currentSelectedDoctor.value.doctorId}');
              log('CURRENT SELECTED CLINIC NAME==> ${currentSelectedDoctor.value.fullName}');
            }
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            decoration: BoxDecoration(
              color: darkMode ? surfaceElevatedDark : surfaceElevated,
              borderRadius: BorderRadius.circular(16),
              border: isSelected
                  ? Border.all(color: appColorSecondary, width: 2)
                  : Border.all(color: darkMode ? glassStrokeDark : glassStrokeLight, width: 1),
              boxShadow: [
                BoxShadow(
                  color: darkMode ? softShadowColorDark : softShadowColor,
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Doctor image with rounded corners and subtle border
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: darkMode ? glassStrokeDark : glassStrokeLight,
                      width: 0.5,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: CachedImageWidget(
                      url: doctorData.profileImage,
                      height: 192,
                      fit: BoxFit.cover,
                      width: Get.width / 2 - 24,
                    ),
                  ),
                ),
                // Online indicator
                const Positioned(
                  top: 12,
                  left: 12,
                  child: CachedImageWidget(url: Assets.iconsIcOnline, height: 16, width: 16),
                ),
                // Selection overlay
                Positioned(
                  left: 0,
                  right: 0,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeInOut,
                    decoration: BoxDecoration(
                      color: isSelected ? appColorPrimary.withValues(alpha: 0.35) : Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    width: Get.width,
                    height: 192,
                  ),
                ),
                // Selection checkmark badge
                Positioned(
                  top: -10,
                  right: -10,
                  child: AnimatedOpacity(
                    opacity: isSelected ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    child: commonLeadingWid(
                      imgPath: Assets.imagesConfirm,
                      color: whiteTextColor,
                      size: 8,
                    ).circularLightPrimaryBg(color: appColorPrimary, padding: 8),
                  ),
                ).visible(isSelected),
                // Bottom info card
                Positioned(
                  bottom: 16,
                  right: 16,
                  left: 16,
                  child: GestureDetector(
                    onTap: () {
                      Get.to(() => DoctorDetailScreen(), arguments: doctorData);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: darkMode ? surfaceElevatedDark : surfaceElevated,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: darkMode ? softShadowColorDark : softShadowColorMedium,
                            blurRadius: 12,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (doctorData.fullName.isNotEmpty)
                                Text(
                                  doctorData.fullName,
                                  style: GoogleFonts.outfit(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                    letterSpacing: -0.3,
                                    color: darkMode ? Colors.white : primaryTextColor,
                                  ),
                                ).paddingBottom(4),
                              if (doctorData.expert.isNotEmpty)
                                Text(
                                  doctorData.expert,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12,
                                    color: darkMode ? bodyWhite : secondaryTextColor,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              if (doctorData.governorate != null) ...[
                                6.height,
                                locationBadge(doctorData.governorate, doctorData.governorateCity),
                              ],
                            ],
                          ).expand(),
                          8.width,
                          Image.asset(Assets.iconsIcInfo, height: 20, width: 20),
                        ],
                      ),
                    ),
                  ),
                ).visible(doctorData.fullName.isNotEmpty || doctorData.expert.isNotEmpty),
              ],
            ),
          ),
        );
      },
    );
  }
}
