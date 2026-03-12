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
import '../../booking/model/employee_review_data.dart';

class DoctorReviewCard extends StatelessWidget {
  final DoctorReviewData doctorReviewData;

  const DoctorReviewCard({super.key, required this.doctorReviewData});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Top row: rating badge, title, service badge
          SizedBox(
            width: Get.width,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isDarkMode.value ? appColorAccent.withValues(alpha: 0.12) : lightAccentColor,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CachedImageWidget(
                        url: Assets.iconsIcStarFilled,
                        color: appColorAccent,
                        height: 12,
                      ),
                      6.width,
                      Text(
                        doctorReviewData.rating.toString(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: isDarkMode.value ? Colors.white : appColorPrimary,
                        ),
                      ).paddingTop(1),
                    ],
                  ),
                ),
                Text(
                  doctorReviewData.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                    color: isDarkMode.value ? Colors.white : appColorPrimary,
                  ),
                ).paddingLeft(8).expand(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isDarkMode.value ? appColorSecondary.withValues(alpha: 0.12) : lightSecondaryColor,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    doctorReviewData.serviceName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: appColorSecondary,
                    ),
                  ),
                ).paddingLeft(16).expand().visible(doctorReviewData.serviceName.isNotEmpty),
              ],
            ),
          ),

          /// Reviewer info row
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CachedImageWidget(
                url: doctorReviewData.profileImage,
                firstName: doctorReviewData.username,
                height: 40,
                width: 40,
                fit: BoxFit.cover,
                circle: true,
              ),
              12.width,
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        "${locale.value.by} ${doctorReviewData.username}",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isDarkMode.value ? Colors.white : appColorPrimary,
                        ),
                      ),
                      const CachedImageWidget(url: Assets.iconsIcVerified, width: 14, height: 14).paddingLeft(8),
                    ],
                  ),
                  4.height,
                  Text(
                    doctorReviewData.createdAt.dateInyyyyMMddHHmmFormat.timeAgoWithLocalization,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: secondaryTextColor,
                    ),
                  ),
                ],
              ),
            ],
          ).paddingTop(16).visible(doctorReviewData.username.isNotEmpty),

          /// Review message
          Text(
            doctorReviewData.reviewMsg,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: secondaryTextColor,
              height: 1.5,
            ),
          ).paddingTop(16).visible(doctorReviewData.reviewMsg.isNotEmpty),
        ],
      ),
    );
  }
}
