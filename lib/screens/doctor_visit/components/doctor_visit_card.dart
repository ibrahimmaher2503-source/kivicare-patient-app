import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../utils/app_common.dart';
import '../../../utils/colors.dart';
import '../doctor_visit_detail_screen.dart';
import '../model/doctor_visit_request_model.dart';
import 'doctor_visit_status_badge.dart';

class DoctorVisitCard extends StatelessWidget {
  final DoctorVisitRequest request;
  final bool showPatientName;

  const DoctorVisitCard({
    super.key,
    required this.request,
    this.showPatientName = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Get.to(() => DoctorVisitDetailScreen(referenceNumber: request.referenceNumber)),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDarkMode.value ? cardDarkColor : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDarkMode.value ? Colors.grey.shade800 : Colors.grey.shade200,
          ),
          boxShadow: [
            BoxShadow(
              color: softShadowColor.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(request.referenceNumber, style: boldTextStyle(size: 14)),
                      if (showPatientName && request.patient != null) ...[
                        const SizedBox(height: 4),
                        Text(request.patient!.name, style: secondaryTextStyle(size: 12)),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                DoctorVisitStatusBadge(status: request.status),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: appColorPrimary.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                request.visitReason,
                style: secondaryTextStyle(size: 12),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 14, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Text(request.preferredDate, style: secondaryTextStyle(size: 12)),
                const Spacer(),
                if (request.assignedDoctor != null) ...[
                  Icon(Icons.person, size: 14, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      request.assignedDoctor!.name,
                      style: secondaryTextStyle(size: 12),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ] else if (request.preferredDoctor != null) ...[
                  Icon(Icons.person_outline, size: 14, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      request.preferredDoctor!.name,
                      style: secondaryTextStyle(size: 12, color: Colors.grey.shade500),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
