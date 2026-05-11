import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../utils/app_common.dart';
import '../../../utils/colors.dart';
import '../models/visit_request_model.dart';
import 'visit_status_chip.dart';

class VisitRequestCard extends StatelessWidget {
  final VisitRequestModel request;
  final VoidCallback onTap;

  const VisitRequestCard({
    super.key,
    required this.request,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final dark = isDarkMode.value;
    return Semantics(
      button: true,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: dark ? surfaceElevatedDark : surfaceElevated,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: dark ? borderColorDark : whiteBorderColor),
          boxShadow: dark
              ? const []
              : [
                  BoxShadow(
                    color: softShadowColor,
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: Material(
          color: appTransparentColor,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          request.referenceNumber,
                          style: boldTextStyle(size: 14, color: gradientStart),
                        ),
                      ),
                      12.width,
                      VisitStatusChip(status: request.status),
                    ],
                  ),
                  10.height,
                  Text(
                    request.visitReason,
                    style: secondaryTextStyle(size: 13),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  10.height,
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today_outlined,
                        size: 14,
                        color: appColorSecondary,
                      ),
                      6.width,
                      Text(
                        DateFormat('d MMM yyyy').format(request.preferredDate),
                        style: secondaryTextStyle(size: 12),
                      ),
                      if (request.assignedDoctor != null) ...[
                        16.width,
                        Icon(
                          Icons.medical_services_outlined,
                          size: 14,
                          color: appColorSecondary,
                        ),
                        6.width,
                        Expanded(
                          child: Text(
                            request.assignedDoctor!.name,
                            style: secondaryTextStyle(size: 12),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
