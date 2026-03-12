import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:kivicare_patient/utils/colors.dart';

import '../../../../components/cached_image_widget.dart';
import '../../../generated/assets.dart';
import '../../../main.dart';
import '../../../utils/app_common.dart';
import '../../../utils/common_base.dart';
import '../../service/service_list_controller.dart';
import '../clinic_detail_screen.dart';
import '../clinic_list_controller.dart';
import '../model/clinic_detail_model.dart';
import '../model/clinics_res_model.dart';

class ClinicCard extends StatelessWidget {
  final Clinic clinicData;

  ClinicCard({super.key, required this.clinicData});

  final ClinicListController clinicListCont = Get.find();

  @override
  Widget build(BuildContext context) {
    return Obx(
      () {
        final bool isSelected = clinicData.id == clinicListCont.selectedClinic.value.id;

        return GestureDetector(
          onTap: () {
            /// Store selected clinic in global variable
            if (clinicData.id == clinicListCont.selectedClinic.value.id) {
              /// Deselect, If again tap on same clinic
              clinicListCont.selectedClinic(Clinic(clinicSession: ClinicSession()));
              currentSelectedClinic(clinicListCont.selectedClinic.value);
              log('CURRENT SELECTED CLINIC ID==> ${currentSelectedClinic.value.id}');
              log('CURRENT SELECTED CLINIC NAME==> ${currentSelectedClinic.value.name}');
            } else {
              clinicListCont.selectedClinic(clinicData);
              currentSelectedClinic(clinicListCont.selectedClinic.value);
              log('CURRENT SELECTED CLINIC ID==> ${currentSelectedClinic.value.id}');
              log('CURRENT SELECTED CLINIC NAME==> ${currentSelectedClinic.value.name}');
            }
          },
          child: Container(
            decoration: BoxDecoration(
              color: isDarkMode.value ? surfaceElevatedDark : surfaceElevated,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: isDarkMode.value ? softShadowColorDark : softShadowColor,
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Image section with gradient overlay and selection indicator
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    /// Clinic image with top-rounded corners
                    ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                      child: Stack(
                        children: [
                          CachedImageWidget(
                            url: clinicData.clinicImage,
                            width: Get.width,
                            fit: BoxFit.cover,
                            height: Get.height * 0.24,
                          ),
                          /// Gradient overlay at bottom for text readability
                          Positioned(
                            left: 0,
                            right: 0,
                            bottom: 0,
                            child: Container(
                              height: Get.height * 0.10,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Colors.black.withValues(alpha: 0.45),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          /// Selection overlay
                          if (isSelected)
                            Container(
                              width: Get.width,
                              height: Get.height * 0.24,
                              color: appColorPrimary.withValues(alpha: 0.35),
                            ),
                        ],
                      ),
                    ),
                    /// Selection checkmark badge
                    if (isSelected)
                      Positioned(
                        top: -10,
                        right: -10,
                        child: commonLeadingWid(
                          imgPath: Assets.imagesConfirm,
                          color: whiteTextColor,
                          size: 8,
                        ).circularLightPrimaryBg(color: appColorPrimary, padding: 8),
                      ),
                  ],
                ),

                /// Info section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// Clinic name
                      if (clinicData.name.trim().isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: Text(
                            clinicData.name,
                            style: GoogleFonts.outfit(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.3,
                              color: isDarkMode.value ? Colors.white : primaryTextColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),

                      /// Address row
                      if (clinicData.address.trim().isNotEmpty)
                        GestureDetector(
                          onTap: () {
                            launchMap(clinicData.address);
                          },
                          behavior: HitTestBehavior.translucent,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Row(
                              children: [
                                const CachedImageWidget(url: Assets.iconsIcLocation, color: iconColor, width: 16, height: 16),
                                8.width,
                                Expanded(
                                  child: Text(
                                    clinicData.address,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w400,
                                      color: isDarkMode.value ? Colors.white70 : secondaryTextColor,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                      /// Phone + Status row
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Row(
                          children: [
                            if (clinicData.contactNumber.trim().isNotEmpty)
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    launchCall(clinicData.contactNumber);
                                  },
                                  behavior: HitTestBehavior.translucent,
                                  child: Row(
                                    children: [
                                      const CachedImageWidget(url: Assets.iconsIcCall, color: iconColor, width: 14, height: 14),
                                      8.width,
                                      Text(
                                        clinicData.contactNumber,
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: appColorPrimary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            /// Status badge with gradient tinted background
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                              decoration: BoxDecoration(
                                color: getClinicStatusLightColor(clinicStatus: clinicData.clinicStatus.toLowerCase()),
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: Text(
                                getClinicStatus(status: clinicData.clinicStatus.toLowerCase()),
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: getClinicStatusColor(clinicStatus: clinicData.clinicStatus.toLowerCase()),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      /// View Detail button - refined pill style
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: GestureDetector(
                          onTap: () {
                            /// Store selected clinic in global variable
                            currentSelectedClinic(clinicData);
                            Get.delete<ServiceListController>();
                            Get.to(() => ClinicDetailScreen(), arguments: clinicData);
                          },
                          behavior: HitTestBehavior.translucent,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: appColorSecondary.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  locale.value.viewDetail,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: appColorSecondary,
                                  ),
                                ),
                                4.width,
                                const Icon(Icons.arrow_forward_ios_rounded, size: 11, color: appColorSecondary),
                              ],
                            ),
                          ),
                        ),
                      ),
                      16.height,
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
