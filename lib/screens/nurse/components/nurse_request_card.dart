import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../main.dart';
import '../../../utils/app_common.dart';
import '../../../utils/colors.dart';
import '../../../utils/constants.dart';
import '../../../utils/price_widget.dart';
import '../model/nurse_request_model.dart';
import '../nurse_request_detail_screen.dart';

class NurseRequestCard extends StatelessWidget {
  final NurseRequest requestData;
  final VoidCallback? onUpdateRequest;

  const NurseRequestCard({
    super.key,
    required this.requestData,
    this.onUpdateRequest,
  });

  Color get _statusColor {
    switch (requestData.status.toLowerCase()) {
      case NurseRequestStatusConst.pending:
        return nurseStatusPendingColor;
      case NurseRequestStatusConst.confirmed:
        return nurseStatusConfirmedColor;
      case NurseRequestStatusConst.inProgress:
        return nurseStatusInProgressColor;
      case NurseRequestStatusConst.completed:
        return nurseStatusCompletedColor;
      case NurseRequestStatusConst.cancelled:
        return nurseStatusCancelledColor;
      default:
        return nurseStatusPendingColor;
    }
  }

  String get _statusLabel {
    switch (requestData.status.toLowerCase()) {
      case NurseRequestStatusConst.pending:
        return locale.value.nurseRequestPending;
      case NurseRequestStatusConst.confirmed:
        return locale.value.nurseRequestConfirmed;
      case NurseRequestStatusConst.inProgress:
        return locale.value.nurseRequestInProgress;
      case NurseRequestStatusConst.completed:
        return locale.value.nurseRequestCompleted;
      case NurseRequestStatusConst.cancelled:
        return locale.value.cancel;
      default:
        return requestData.status;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        hideKeyboard(context);
        Get.to(() => NurseRequestDetailScreen(requestData: requestData))?.then((_) {
          onUpdateRequest?.call();
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDarkMode.value ? surfaceElevatedDark : surfaceElevated,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: isDarkMode.value ? softShadowColorDark : softShadowColor,
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: date + status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (requestData.preferredDate.isNotEmpty)
                  Text(
                    requestData.preferredDate,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.1,
                      color: secondaryTextColor,
                    ),
                  ),
                _buildStatusChip(_statusLabel, _statusColor),
              ],
            ),
            16.height,

            // Nurse name
            if (requestData.nurse != null)
              Text(
                requestData.nurse!.name,
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.3,
                  color: isDarkMode.value ? Colors.white : primaryTextColor,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            8.height,

            // Service description (truncated)
            if (requestData.serviceDescription.isNotEmpty)
              Text(
                requestData.serviceDescription,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  letterSpacing: 0.1,
                  color: secondaryTextColor,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            12.height,

            // Bottom row: time + amount
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (requestData.preferredTime.isNotEmpty)
                  Row(
                    children: [
                      Icon(Icons.access_time_rounded, size: 14, color: secondaryTextColor),
                      4.width,
                      Text(
                        requestData.preferredTime,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          letterSpacing: 0.1,
                          color: secondaryTextColor,
                        ),
                      ),
                    ],
                  ),
                if (requestData.totalAmount > 0)
                  PriceWidget(
                    price: requestData.totalAmount,
                    size: 14,
                    color: isDarkMode.value ? Colors.white : primaryTextColor,
                  ),
              ],
            ),
            12.height,

            // View Detail Button
            GestureDetector(
              onTap: () => Get.to(() => NurseRequestDetailScreen(requestData: requestData))?.then((_) {
                onUpdateRequest?.call();
              }),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [gradientSecondaryStart, gradientSecondaryEnd]),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: appColorSecondary.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Text(
                  locale.value.viewDetail,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.1,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          colors: [
            color.withValues(alpha: 0.15),
            color.withValues(alpha: 0.08),
          ],
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
              color: color,
            ),
          ),
          6.width,
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.1,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
