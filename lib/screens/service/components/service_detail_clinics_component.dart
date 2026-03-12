import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../../components/cached_image_widget.dart';
import '../../../generated/assets.dart';
import '../../../main.dart';
import '../../../utils/app_common.dart';
import '../../../utils/colors.dart';
import '../../../utils/common_base.dart';
import '../../../utils/view_all_label_component.dart';
import '../../clinic/model/clinics_res_model.dart';
import '../service_detail_controller.dart';

class ServiceDetailClinicsComponent extends StatelessWidget {
  final ServiceDetailController serviceDetailController;
  final Function(Clinic)? onClickViewDetail;
  final void Function(Clinic)? onCardTap;
  const ServiceDetailClinicsComponent({super.key, required this.serviceDetailController, this.onCardTap, this.onClickViewDetail});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Column(
        children: [
          16.height,
          ViewAllLabel(
            label: locale.value.chooseClinic,
            isShowAll: false,
          ),
          Obx(
            () => AnimatedListView(
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              itemCount: serviceDetailController.serviceData.value.clinics.length,
              itemBuilder: (context, index) {
                Clinic clinicData = serviceDetailController.serviceData.value.clinics[index];
                return Obx(
                  () => GestureDetector(
                    onTap: () {
                      onCardTap?.call(clinicData);
                    },
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          alignment: Alignment.center,
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isDarkMode.value ? surfaceElevatedDark : surfaceElevated,
                            borderRadius: BorderRadius.circular(16),
                            border: clinicData.id == serviceDetailController.selectedClinic.value.id
                                ? Border.all(color: appColorSecondary.withValues(alpha: 0.3), width: 1.5)
                                : null,
                            boxShadow: [
                              BoxShadow(
                                color: isDarkMode.value ? softShadowColorDark : softShadowColor,
                                blurRadius: 16,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              // Clinic image with rounded styling
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: isDarkMode.value ? softShadowColorDark : softShadowColor,
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: CachedImageWidget(
                                    url: clinicData.clinicImage,
                                    width: 100,
                                    height: 100,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              16.width,
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        clinicData.name,
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                        style: GoogleFonts.outfit(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: -0.3,
                                          color: isDarkMode.value ? Colors.white : primaryTextColor,
                                        ),
                                      ).flexible(),
                                    ],
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      launchMap(clinicData.address);
                                    },
                                    behavior: HitTestBehavior.opaque,
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const CachedImageWidget(url: Assets.iconsIcLocation, color: appColorSecondary, width: 16, height: 16),
                                        12.width,
                                        Text(
                                          clinicData.address,
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 12,
                                            color: secondaryTextColor,
                                            letterSpacing: 0.1,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ).flexible(),
                                      ],
                                    ),
                                  ).paddingTop(8).visible(clinicData.address.trim().isNotEmpty),
                                  Row(
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          launchCall(clinicData.contactNumber);
                                        },
                                        behavior: HitTestBehavior.opaque,
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const CachedImageWidget(url: Assets.iconsIcCall, color: appColorSecondary, width: 14, height: 14),
                                            12.width,
                                            Text(
                                              clinicData.contactNumber,
                                              style: GoogleFonts.plusJakartaSans(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w600,
                                                color: appColorPrimary,
                                                letterSpacing: 0.1,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ).paddingTop(8).visible(clinicData.contactNumber.trim().isNotEmpty),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      TextButton(
                                        style: const ButtonStyle(padding: WidgetStatePropertyAll(EdgeInsets.zero)),
                                        onPressed: () {
                                          onClickViewDetail?.call(clinicData);
                                        },
                                        child: Text(
                                          locale.value.viewDetail,
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w700,
                                            color: appColorSecondary,
                                            letterSpacing: 0.1,
                                          ),
                                        ).paddingSymmetric(horizontal: 8),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: getClinicStatusLightColor(clinicStatus: clinicData.clinicStatus.toLowerCase()),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          getClinicStatus(status: clinicData.clinicStatus.toLowerCase()),
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w700,
                                            color: getClinicStatusColor(clinicStatus: clinicData.clinicStatus.toLowerCase()),
                                            letterSpacing: 0.1,
                                          ),
                                        ),
                                      ).paddingLeft(4),
                                    ],
                                  )
                                ],
                              ).expand(),
                              12.width,
                            ],
                          ),
                        ),
                        // Selected checkmark with gradient
                        Positioned(
                          top: -8,
                          right: -8,
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(colors: [gradientSecondaryStart, gradientSecondaryEnd]),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: appColorSecondary.withValues(alpha: 0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Icon(Icons.check_rounded, color: Colors.white, size: 16),
                          ),
                        ).visible(clinicData.id == serviceDetailController.selectedClinic.value.id),
                      ],
                    ),
                  ),
                );
              },
            ),
          )
        ],
      ).paddingSymmetric(horizontal: 16),
    );
  }
}
