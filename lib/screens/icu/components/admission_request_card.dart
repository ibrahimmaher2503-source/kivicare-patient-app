import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../main.dart';
import '../../../utils/app_common.dart';
import '../../../utils/colors.dart';
import '../../../utils/constants.dart';
import '../admission_detail_screen.dart';
import '../model/icu_admission_model.dart';

class AdmissionRequestCard extends StatelessWidget {
  final IcuAdmissionRequest requestData;
  final VoidCallback? onUpdateRequest;

  const AdmissionRequestCard({
    super.key,
    required this.requestData,
    this.onUpdateRequest,
  });

  Color get _statusColor {
    switch (requestData.status.toLowerCase()) {
      case IcuAdmissionStatusConst.pending:
        return icuStatusPendingColor;
      case IcuAdmissionStatusConst.accepted:
        return icuStatusAcceptedColor;
      case IcuAdmissionStatusConst.rejected:
        return icuStatusRejectedColor;
      case IcuAdmissionStatusConst.infoRequested:
        return icuStatusInfoRequestedColor;
      case IcuAdmissionStatusConst.cancelled:
        return icuStatusCancelledColor;
      default:
        return icuStatusPendingColor;
    }
  }

  String get _statusLabel {
    switch (requestData.status.toLowerCase()) {
      case IcuAdmissionStatusConst.pending:
        return locale.value.pending;
      case IcuAdmissionStatusConst.accepted:
        return locale.value.acceptedLabel;
      case IcuAdmissionStatusConst.rejected:
        return locale.value.rejectedLabel;
      case IcuAdmissionStatusConst.infoRequested:
        return locale.value.infoRequestedLabel;
      case IcuAdmissionStatusConst.cancelled:
        return locale.value.cancelled;
      default:
        return requestData.status;
    }
  }

  Color get _urgencyColor {
    switch (requestData.urgency.toLowerCase()) {
      case IcuUrgencyConst.critical:
        return urgencyCriticalColor;
      case IcuUrgencyConst.urgent:
        return urgencyUrgentColor;
      case IcuUrgencyConst.standard:
        return urgencyStandardColor;
      default:
        return urgencyStandardColor;
    }
  }

  String get _urgencyLabel {
    switch (requestData.urgency.toLowerCase()) {
      case IcuUrgencyConst.critical:
        return locale.value.criticalLabel;
      case IcuUrgencyConst.urgent:
        return locale.value.urgentLabel;
      case IcuUrgencyConst.standard:
        return locale.value.standardLabel;
      default:
        return requestData.urgency;
    }
  }

  String _formatDate(String rawDate) {
    final parsed = DateTime.tryParse(rawDate);
    if (parsed == null) return rawDate;
    return DateFormat(DateFormatConst.D_MMMM_yyyy).format(parsed.toLocal());
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        hideKeyboard(context);
        Get.to(() => AdmissionDetailScreen(requestData: requestData))?.then((_) {
          onUpdateRequest?.call();
        });
      },
      child: Container(
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
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Left accent strip based on urgency
              Container(
                width: 4,
                decoration: BoxDecoration(
                  color: _urgencyColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                  ),
                ),
              ),
              // Main content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header: request number + status badge
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              requestData.requestNumber,
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
                          8.width,
                          _buildStatusChip(_statusLabel, _statusColor),
                        ],
                      ),
                      14.height,

                      // Hospital name
                      if (requestData.hospital != null && requestData.hospital!.name.isNotEmpty)
                        Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [gradientSecondaryStart, gradientSecondaryEnd],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.local_hospital_rounded,
                                  size: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            10.width,
                            Expanded(
                              child: Text(
                                requestData.hospital!.name,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.1,
                                  color: isDarkMode.value ? Colors.white : primaryTextColor,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      if (requestData.hospital != null && requestData.hospital!.name.isNotEmpty) 10.height,

                      // Case type text
                      if (requestData.caseDetails != null && requestData.caseDetails!.caseType.isNotEmpty)
                        Text(
                          '${locale.value.caseTypeLabel}: ${requestData.caseDetails!.caseType.replaceAll('_', ' ').capitalizeFirstLetter()}',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            letterSpacing: 0.1,
                            color: secondaryTextColor,
                            height: 1.4,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      14.height,

                      // Urgency badge + creation date row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          if (requestData.urgency.isNotEmpty)
                            _buildUrgencyChip(_urgencyLabel, _urgencyColor),
                          if (requestData.createdAt.isNotEmpty)
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
                                  Icon(Icons.calendar_today_rounded, size: 13, color: appColorSecondary),
                                  6.width,
                                  Text(
                                    _formatDate(requestData.createdAt),
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 12,
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
                      12.height,

                      // View Detail Button
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [gradientSecondaryStart, gradientSecondaryEnd]),
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
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [
            color.withValues(alpha: 0.18),
            color.withValues(alpha: 0.1),
          ],
        ),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.15),
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
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.5),
                  blurRadius: 4,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
          8.width,
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUrgencyChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [
            color.withValues(alpha: 0.15),
            color.withValues(alpha: 0.08),
          ],
        ),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.priority_high_rounded,
            size: 14,
            color: color,
          ),
          4.width,
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
