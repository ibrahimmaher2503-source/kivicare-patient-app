import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
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

  IconData get _serviceTypeIcon {
    final type = serviceData.type.toLowerCase();
    if (type.contains('nurse') || type.contains('medical')) {
      return Icons.medical_services_outlined;
    } else if (type.contains('lab') || type.contains('test')) {
      return Icons.biotech_outlined;
    } else if (type.contains('home') || type.contains('visit')) {
      return Icons.home_outlined;
    } else if (type.contains('emergency') || type.contains('urgent')) {
      return Icons.emergency_outlined;
    } else {
      return Icons.miscellaneous_services_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
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
      child: Stack(
        children: [
          // Shimmer line at the top
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: -1.0, end: 2.0),
              duration: const Duration(milliseconds: 2500),
              builder: (context, value, child) {
                return Container(
                  height: 2,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment(value - 1, 0),
                      end: Alignment(value, 0),
                      colors: [
                        Colors.transparent,
                        _statusColor.withValues(alpha: 0.4),
                        _statusColor.withValues(alpha: 0.7),
                        _statusColor.withValues(alpha: 0.4),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
                    ),
                  ),
                );
              },
            ),
          ),
          // Left accent border
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: Container(
              width: 3,
              decoration: BoxDecoration(
                color: _statusColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                ),
              ),
            ),
          ),
          // Main content
          Padding(
            padding: const EdgeInsets.only(left: 12, right: 16, top: 16, bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name + Status Badge
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          // Decorative service type icon
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: _statusColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              _serviceTypeIcon,
                              size: 16,
                              color: _statusColor,
                            ),
                          ),
                          10.width,
                          Expanded(
                            child: Text(
                              serviceData.name,
                              style: GoogleFonts.outfit(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.3,
                                color: isDarkMode.value ? Colors.white : primaryTextColor,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    8.width,
                    _buildStatusBadge(),
                  ],
                ),
                10.height,

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

                // Description (truncated) - lighter weight
                if (serviceData.description.isNotEmpty) ...[
                  Text(
                    serviceData.description,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 0.1,
                      color: secondaryTextColor,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  10.height,
                ],

                // Created date with calendar icon - nicely formatted
                if (serviceData.createdAt.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: isDarkMode.value
                          ? Colors.white.withValues(alpha: 0.05)
                          : appColorPrimary.withValues(alpha: 0.04),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.calendar_today_rounded,
                          size: 13,
                          color: appColorSecondary,
                        ),
                        6.width,
                        Text(
                          _formatDate(serviceData.createdAt),
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.1,
                            color: isDarkMode.value ? Colors.white70 : secondaryTextColor,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String rawDate) {
    final parsed = DateTime.tryParse(rawDate);
    if (parsed == null) return rawDate;
    return DateFormat(DateFormatConst.D_MMMM_yyyy).format(parsed.toLocal());
  }

  Widget _buildStatusBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [
            _statusColor.withValues(alpha: 0.18),
            _statusColor.withValues(alpha: 0.1),
          ],
        ),
        border: Border.all(
          color: _statusColor.withValues(alpha: 0.25),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: _statusColor.withValues(alpha: 0.15),
            blurRadius: 8,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _statusColor,
              boxShadow: [
                BoxShadow(
                  color: _statusColor.withValues(alpha: 0.5),
                  blurRadius: 4,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
          6.width,
          Text(
            _statusLabel,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
              color: _statusColor,
            ),
          ),
        ],
      ),
    );
  }
}
