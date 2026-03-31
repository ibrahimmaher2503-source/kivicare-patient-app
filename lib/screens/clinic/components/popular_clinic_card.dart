import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../components/cached_image_widget.dart';
import '../../../components/location_badge.dart';
import '../../../generated/assets.dart';
import '../../../main.dart';
import '../../../utils/app_common.dart';
import '../../../utils/colors.dart';
import '../../../utils/common_base.dart';
import '../clinic_detail_screen.dart';
import '../model/clinics_res_model.dart';
import '../../service/service_list_controller.dart';

class PopularClinicCard extends StatelessWidget {
  final Clinic clinicElement;
  final double? width;

  const PopularClinicCard({super.key, required this.clinicElement, this.width});

  @override
  Widget build(BuildContext context) {
    final bool darkMode = isDarkMode.value;
    final Color statusColor = getClinicStatusColor(clinicStatus: clinicElement.clinicStatus.toLowerCase());
    final Color statusLightColor = getClinicStatusLightColor(clinicStatus: clinicElement.clinicStatus.toLowerCase());

    return GestureDetector(
      onTap: () {
        currentSelectedClinic(clinicElement);
        Get.delete<ServiceListController>();
        Get.to(() => ClinicDetailScreen(), arguments: clinicElement);
      },
      child: Container(
        width: width ?? Get.width,
        decoration: BoxDecoration(
          color: darkMode ? surfaceElevatedDark : surfaceElevated,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: darkMode ? glassStrokeDark : glassStrokeLight,
            width: 0.5,
          ),
          boxShadow: [
            BoxShadow(
              color: darkMode ? softShadowColorDark : softShadowColor,
              blurRadius: 20,
              offset: const Offset(0, 6),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Clinic image with gradient overlay and status badge
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                  child: CachedImageWidget(
                    url: clinicElement.clinicImage,
                    width: Get.width,
                    fit: BoxFit.cover,
                    height: Get.height * 0.22,
                  ),
                ),
                // Bottom gradient for text readability
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  height: 64,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(0),
                        topRight: Radius.circular(0),
                      ),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.5),
                        ],
                      ),
                    ),
                  ),
                ),
                // Status badge
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: statusLightColor,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: statusColor.withValues(alpha: 0.3),
                        width: 0.5,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: statusColor,
                            boxShadow: [
                              BoxShadow(
                                color: statusColor.withValues(alpha: 0.4),
                                blurRadius: 4,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                        ),
                        6.width,
                        Text(
                          getClinicStatus(status: clinicElement.clinicStatus.toLowerCase()),
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: statusColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Clinic info section
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Clinic name
                  Text(
                    clinicElement.name,
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3,
                      color: darkMode ? Colors.white : primaryTextColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (clinicElement.governorate != null) ...[
                    6.height,
                    locationBadge(clinicElement.governorate, clinicElement.governorateCity),
                  ],
                  12.height,

                  // Address row
                  GestureDetector(
                    onTap: () => launchMap(clinicElement.address),
                    behavior: HitTestBehavior.translucent,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: darkMode
                                ? appColorSecondary.withValues(alpha: 0.12)
                                : lightSecondaryColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: CachedImageWidget(
                            url: Assets.iconsIcLocation,
                            color: appColorSecondary,
                            width: 14,
                            height: 14,
                          ),
                        ),
                        10.width,
                        Expanded(
                          child: Text(
                            clinicElement.address,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                              color: darkMode ? Colors.white70 : secondaryTextColor,
                              height: 1.4,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  12.height,

                  // Contact + View Detail row
                  Row(
                    children: [
                      // Phone number
                      GestureDetector(
                        onTap: () => launchCall(clinicElement.contactNumber),
                        behavior: HitTestBehavior.translucent,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: darkMode
                                    ? appColorPrimary.withValues(alpha: 0.12)
                                    : lightPrimaryColor,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: CachedImageWidget(
                                url: Assets.iconsIcCall,
                                color: appColorPrimary,
                                width: 14,
                                height: 14,
                              ),
                            ),
                            8.width,
                            Text(
                              clinicElement.contactNumber,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: appColorPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      // View Detail button
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [gradientSecondaryStart, gradientSecondaryEnd],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: gradientSecondaryStart.withValues(alpha: 0.25),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              locale.value.viewDetail,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            4.width,
                            const Icon(Icons.arrow_forward_ios_rounded, size: 11, color: Colors.white),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
