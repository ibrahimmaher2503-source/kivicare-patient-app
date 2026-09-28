import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../components/cached_image_widget.dart';
import '../../../generated/assets.dart';
import '../../../utils/app_common.dart';
import '../../../utils/colors.dart';
import '../../../utils/common_base.dart';
import '../../booking/model/employee_review_data.dart';

class DoctorReviewCard extends StatelessWidget {
  final DoctorReviewData doctorReviewData;

  const DoctorReviewCard({super.key, required this.doctorReviewData});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDarkMode.value ? surfaceElevatedDark : surfaceElevated,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDarkMode.value
                ? const Color(0xFF243046)
                : const Color(0xFFEDF1F4),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CachedImageWidget(
                  url: doctorReviewData.profileImage,
                  firstName: doctorReviewData.username,
                  height: 38,
                  width: 38,
                  fit: BoxFit.cover,
                  circle: true,
                ),
                10.width,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        doctorReviewData.username,
                        style: TextStyle(
                          color: isDarkMode.value
                              ? textPrimaryDark
                              : appColorPrimary,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          height: 1.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      3.height,
                      Text(
                        doctorReviewData.createdAt.dateInyyyyMMddHHmmFormat
                                ?.timeAgoWithLocalization ??
                            '-',
                        style: TextStyle(
                          color: isDarkMode.value
                              ? textTertiaryDark
                              : const Color(0xFF75818A),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: isDarkMode.value
                        ? const Color(0xFF223047)
                        : const Color(0xFFFFF6E5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CachedImageWidget(
                        url: Assets.iconsIcStarFilled,
                        color: checkoutStatusColor,
                        height: 12,
                      ),
                      4.width,
                      Text(
                        doctorReviewData.rating.toString(),
                        style: TextStyle(
                          color: isDarkMode.value
                              ? const Color(0xFFFFDCA2)
                              : appColorPrimary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          height: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (doctorReviewData.title.isNotEmpty) ...[
              10.height,
              Text(
                doctorReviewData.title,
                style: TextStyle(
                  color: isDarkMode.value ? textPrimaryDark : appColorPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            if (doctorReviewData.reviewMsg.isNotEmpty) ...[
              8.height,
              Text(
                doctorReviewData.reviewMsg,
                style: TextStyle(
                  color: isDarkMode.value
                      ? textSecondaryDark
                      : const Color(0xFF4E5B64),
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
            ],
            if (doctorReviewData.serviceName.isNotEmpty) ...[
              10.height,
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: isDarkMode.value
                      ? appColorSecondary.withValues(alpha: 0.12)
                      : lightSecondaryColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  doctorReviewData.serviceName,
                  style: const TextStyle(
                    color: appColorSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
