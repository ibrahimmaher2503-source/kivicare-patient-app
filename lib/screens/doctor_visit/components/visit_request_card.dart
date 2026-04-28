import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nb_utils/nb_utils.dart';

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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: context.cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: softShadowColor,
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    request.referenceNumber,
                    style: boldTextStyle(size: 14, color: appColorPrimary),
                  ),
                  VisitStatusChip(status: request.status),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                request.visitReason,
                style: secondaryTextStyle(size: 13),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(Icons.calendar_today_outlined, size: 14, color: appColorSecondary),
                  const SizedBox(width: 6),
                  Text(
                    DateFormat('d MMM yyyy').format(request.preferredDate),
                    style: secondaryTextStyle(size: 12),
                  ),
                  if (request.assignedDoctor != null) ...[
                    const SizedBox(width: 16),
                    const Icon(Icons.medical_services_outlined, size: 14, color: appColorSecondary),
                    const SizedBox(width: 6),
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
    );
  }
}
