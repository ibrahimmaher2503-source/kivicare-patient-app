import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../utils/app_common.dart';
import '../../../utils/colors.dart';
import '../model/doctor_detail_model.dart';

class QualificationCard extends StatelessWidget {
  final Qualifications qualificationData;

  const QualificationCard({super.key, required this.qualificationData});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isDarkMode.value ? surfaceElevatedDark : surfaceElevated,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDarkMode.value
                ? const Color(0xFF243046)
                : const Color(0xFFEDF1F4),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (qualificationData.year.isNotEmpty) ...[
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: isDarkMode.value
                      ? appColorSecondary.withValues(alpha: 0.12)
                      : lightSecondaryColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  qualificationData.year,
                  style: const TextStyle(
                    color: appColorSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              12.width,
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (qualificationData.degree.isNotEmpty)
                    Text(
                      qualificationData.degree,
                      style: TextStyle(
                        color: isDarkMode.value
                            ? textPrimaryDark
                            : appColorPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        height: 1.25,
                      ),
                    ),
                  if (qualificationData.university.isNotEmpty) ...[
                    3.height,
                    Text(
                      qualificationData.university,
                      style: TextStyle(
                        color: isDarkMode.value
                            ? textSecondaryDark
                            : const Color(0xFF75818A),
                        fontSize: 12,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
