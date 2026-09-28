import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../components/cached_image_widget.dart';
import '../../../generated/assets.dart';
import '../../../main.dart';
import '../../../utils/app_common.dart';
import '../../../utils/colors.dart';
import '../doctor_detail_screen.dart';
import '../model/doctor_list_res.dart';

class PopularDoctorCard extends StatelessWidget {
  const PopularDoctorCard({
    super.key,
    required this.doctorElement,
    this.isFromClinicDetail = false,
  });

  final Doctor doctorElement;
  final bool isFromClinicDetail;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.to(() => DoctorDetailScreen(), arguments: doctorElement),
      child: Obx(
        () => Container(
          padding: const EdgeInsets.fromLTRB(12, 16, 12, 16),
          width: Get.width / 2 - 24,
          decoration: BoxDecoration(
            color: isDarkMode.value ? surfaceElevatedDark : surfaceElevated,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: isDarkMode.value
                    ? Colors.black.withValues(alpha: 0.18)
                    : softShadowColor,
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: appColorSecondary.withValues(alpha: 0.25),
                    width: 2,
                  ),
                ),
                child: CachedImageWidget(
                  url: doctorElement.profileImage,
                  firstName: doctorElement.firstName,
                  lastName: doctorElement.lastName,
                  circle: true,
                  height: 64,
                  width: 64,
                  fit: BoxFit.cover,
                ),
              ),
              10.height,
              Text(
                doctorElement.fullName,
                style: TextStyle(
                  color: isDarkMode.value ? textPrimaryDark : appColorPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  height: 1.25,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
              if (doctorElement.expert.isNotEmpty) ...[
                5.height,
                Text(
                  doctorElement.expert,
                  style: const TextStyle(
                    color: appColorSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ],
              10.height,
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CachedImageWidget(
                    url: Assets.iconsIcStarFilled,
                    color: checkoutStatusColor,
                    height: 13,
                  ),
                  4.width,
                  Text(
                    doctorElement.averageRating.toStringAsFixed(1),
                    style: TextStyle(
                      color: isDarkMode.value ? textPrimaryDark : appColorPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              if (doctorElement.totalAppointmemt > 0) ...[
                6.height,
                Text(
                  '${doctorElement.totalAppointmemt} ${locale.value.patientServed}',
                  style: TextStyle(
                    color: isDarkMode.value
                        ? textTertiaryDark
                        : const Color(0xFF75818A),
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
