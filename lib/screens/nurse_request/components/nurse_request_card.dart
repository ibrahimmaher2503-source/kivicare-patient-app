import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kivicare_patient/main.dart';
import 'package:kivicare_patient/utils/app_common.dart';
import 'package:kivicare_patient/utils/colors.dart';
import 'package:kivicare_patient/utils/price_widget.dart';
import 'package:nb_utils/nb_utils.dart';

import '../models/nurse_request_model.dart';
import '../models/nurse_status.dart';
import 'nurse_status_chip.dart';

class NurseRequestCard extends StatelessWidget {
  final NurseRequestModel request;
  final VoidCallback onTap;

  const NurseRequestCard({super.key, required this.request, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final localeCode = locale.value.language == 'العربية' ? 'ar' : 'en';
    final description = request.serviceDescriptionLocalized(localeCode) ?? '';
    final dateStr = DateFormat('dd MMM yyyy').format(request.preferredDate);
    final durationStr = locale.value.durationHoursValue(request.durationHours);
    final timeStr = request.preferredTime ?? '';
    final scheduleStr = [dateStr, if (timeStr.isNotEmpty) timeStr, durationStr].join(' · ');
    final status = NurseStatusExtension.fromString(request.status);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDarkMode.value ? surfaceElevatedDark : surfaceElevated,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: softShadowColor, blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    request.referenceNumber,
                    style: boldTextStyle(size: 14),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                NurseStatusChip(status: status),
              ],
            ),
            if (description.isNotEmpty) ...[
              6.height,
              Text(
                description,
                style: primaryTextStyle(size: 13),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            6.height,
            Text(scheduleStr, style: secondaryTextStyle(size: 12)),
            4.height,
            Text(
              '${request.addressLine1}, ${request.city}',
              style: secondaryTextStyle(size: 12),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (request.assignedNurse != null) ...[
              4.height,
              Text(
                request.assignedNurse!.displayName,
                style: primaryTextStyle(size: 13, color: gradientStart),
              ),
            ],
            if (request.totalAmount != null) ...[
              4.height,
              PriceWidget(price: request.totalAmount!, size: 13, color: Colors.green.shade700),
            ],
          ],
        ),
      ),
    );
  }
}
