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

  int get _statusStep {
    switch (requestData.status.toLowerCase()) {
      case NurseRequestStatusConst.pending:
        return 0;
      case NurseRequestStatusConst.confirmed:
        return 1;
      case NurseRequestStatusConst.inProgress:
        return 2;
      case NurseRequestStatusConst.completed:
        return 3;
      case NurseRequestStatusConst.cancelled:
        return -1;
      default:
        return 0;
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
              // Left accent strip - 4px based on status
              Container(
                width: 4,
                decoration: BoxDecoration(
                  color: _statusColor,
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
                    // Header: date + status
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (requestData.preferredDate.isNotEmpty)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.calendar_today_rounded,
                                size: 13,
                                color: appColorSecondary,
                              ),
                              6.width,
                              Text(
                                requestData.preferredDate,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.1,
                                  color: secondaryTextColor,
                                ),
                              ),
                            ],
                          ),
                        _buildStatusChip(_statusLabel, _statusColor),
                      ],
                    ),
                    14.height,

                    // Nurse name with avatar indicator
                    if (requestData.nurse != null)
                      Row(
                        children: [
                          // Small avatar indicator
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
                            child: Center(
                              child: Text(
                                requestData.nurse!.name.isNotEmpty
                                    ? requestData.nurse!.name[0].toUpperCase()
                                    : 'N',
                                style: GoogleFonts.outfit(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          10.width,
                          Expanded(
                            child: Text(
                              requestData.nurse!.name,
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
                    10.height,

                    // Service description (truncated)
                    if (requestData.serviceDescription.isNotEmpty)
                      Text(
                        requestData.serviceDescription,
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

                    // Mini timeline
                    if (_statusStep >= 0) _buildMiniTimeline(),
                    if (_statusStep >= 0) 14.height,

                    // Bottom row: time + amount
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (requestData.preferredTime.isNotEmpty)
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
                                Icon(Icons.access_time_rounded, size: 14, color: appColorSecondary),
                                6.width,
                                Text(
                                  requestData.preferredTime,
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
                        if (requestData.totalAmount > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  appColorSecondary.withValues(alpha: 0.12),
                                  appColorAccent.withValues(alpha: 0.08),
                                ],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: appColorSecondary.withValues(alpha: 0.15),
                                width: 1,
                              ),
                            ),
                            child: PriceWidget(
                              price: requestData.totalAmount,
                              size: 14,
                              color: isDarkMode.value ? appColorAccent : appColorSecondary,
                            ),
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

  /// Builds a mini timeline showing request progress
  Widget _buildMiniTimeline() {
    final steps = ['Requested', 'Confirmed', 'In Progress', 'Completed'];
    final currentStep = _statusStep;

    return Row(
      children: List.generate(steps.length * 2 - 1, (index) {
        if (index.isOdd) {
          // Connector line
          final stepIndex = index ~/ 2;
          final isActive = stepIndex < currentStep;
          return Expanded(
            child: Container(
              height: 2,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                color: isActive
                    ? appColorSecondary
                    : (isDarkMode.value
                        ? Colors.white.withValues(alpha: 0.1)
                        : appColorPrimary.withValues(alpha: 0.08)),
                borderRadius: BorderRadius.circular(1),
              ),
            ),
          );
        } else {
          // Dot
          final stepIndex = index ~/ 2;
          final isActive = stepIndex <= currentStep;
          final isCurrent = stepIndex == currentStep;

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: isCurrent ? 12 : 8,
                height: isCurrent ? 12 : 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isActive ? _statusColor : Colors.transparent,
                  border: Border.all(
                    color: isActive
                        ? _statusColor
                        : (isDarkMode.value
                            ? Colors.white.withValues(alpha: 0.15)
                            : appColorPrimary.withValues(alpha: 0.15)),
                    width: isCurrent ? 2.5 : 1.5,
                  ),
                  boxShadow: isCurrent
                      ? [
                          BoxShadow(
                            color: _statusColor.withValues(alpha: 0.4),
                            blurRadius: 6,
                            spreadRadius: 1,
                          ),
                        ]
                      : null,
                ),
              ),
            ],
          );
        }
      }),
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
}
