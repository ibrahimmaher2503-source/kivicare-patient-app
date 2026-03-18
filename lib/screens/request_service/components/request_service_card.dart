import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../main.dart';
import '../../../utils/app_common.dart';
import '../../../utils/colors.dart';
import '../../../utils/constants.dart';
import '../model/request_service_model.dart';

class RequestServiceCard extends StatelessWidget {
  final RequestService serviceData;

  const RequestServiceCard({
    super.key,
    required this.serviceData,
  });

  Color get _statusColor {
    switch (serviceData.isStatus.toLowerCase()) {
      case ServiceRequestStatusConst.pending:
        return serviceStatusPendingColor;
      case ServiceRequestStatusConst.accept:
        return serviceStatusAcceptColor;
      case ServiceRequestStatusConst.reject:
        return serviceStatusRejectColor;
      default:
        return serviceStatusPendingColor;
    }
  }

  String get _statusLabel {
    switch (serviceData.isStatus.toLowerCase()) {
      case ServiceRequestStatusConst.pending:
        return locale.value.serviceStatusPending;
      case ServiceRequestStatusConst.accept:
        return locale.value.serviceStatusAccepted;
      case ServiceRequestStatusConst.reject:
        return locale.value.serviceStatusRejected;
      default:
        return serviceData.isStatus;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
          // Name + Status Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  serviceData.name,
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.3,
                    color: isDarkMode.value ? Colors.white : primaryTextColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              8.width,
              _buildStatusBadge(),
            ],
          ),
          8.height,

          // Type
          if (serviceData.type.isNotEmpty) ...[
            Text(
              serviceData.type,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                letterSpacing: 0.1,
                color: appColorSecondary,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            6.height,
          ],

          // Description (truncated)
          if (serviceData.description.isNotEmpty) ...[
            Text(
              serviceData.description,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                letterSpacing: 0.1,
                color: secondaryTextColor,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            8.height,
          ],

          // Created date
          if (serviceData.createdAt.isNotEmpty)
            Row(
              children: [
                Icon(Icons.calendar_today_outlined, size: 14, color: secondaryTextColor),
                4.width,
                Text(
                  serviceData.createdAt,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    letterSpacing: 0.1,
                    color: secondaryTextColor,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          colors: [
            _statusColor.withValues(alpha: 0.15),
            _statusColor.withValues(alpha: 0.08),
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
              color: _statusColor,
            ),
          ),
          4.width,
          Text(
            _statusLabel,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.1,
              color: _statusColor,
            ),
          ),
        ],
      ),
    );
  }
}
