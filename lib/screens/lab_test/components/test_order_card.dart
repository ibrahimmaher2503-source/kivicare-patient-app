import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../main.dart';
import '../../../utils/app_common.dart';
import '../../../utils/colors.dart';
import '../model/test_order_model.dart';
import '../test_order_detail_screen.dart';

class TestOrderCard extends StatelessWidget {
  final TestOrder orderData;
  final VoidCallback? onTap;

  const TestOrderCard({
    super.key,
    required this.orderData,
    this.onTap,
  });

  Color get _statusColor {
    switch (orderData.status.toLowerCase()) {
      case 'pending':
        return labStatusPendingColor;
      case 'confirmed':
        return labStatusConfirmedColor;
      case 'sample_collected':
        return labStatusSampleCollectedColor;
      case 'processing':
        return labStatusProcessingColor;
      case 'completed':
        return labStatusCompletedColor;
      case 'delivered':
        return labStatusDeliveredColor;
      case 'cancelled':
        return labStatusCancelledColor;
      default:
        return labStatusPendingColor;
    }
  }

  String get _statusLabel {
    switch (orderData.status.toLowerCase()) {
      case 'pending':
        return locale.value.pending;
      case 'confirmed':
        return locale.value.confirmed;
      case 'sample_collected':
        return locale.value.sampleCollected;
      case 'processing':
        return locale.value.processing;
      case 'completed':
        return locale.value.completed;
      case 'delivered':
        return locale.value.delivered;
      case 'cancelled':
        return locale.value.cancelled;
      default:
        return orderData.status;
    }
  }

  Color get _priorityColor {
    switch (orderData.priority.toLowerCase()) {
      case 'urgent':
        return resultAbnormalColor;
      case 'stat':
        return resultCriticalColor;
      default:
        return appColorSecondary;
    }
  }

  String get _priorityLabel {
    switch (orderData.priority.toLowerCase()) {
      case 'routine':
        return locale.value.priorityRoutine;
      case 'urgent':
        return locale.value.priorityUrgent;
      case 'stat':
        return locale.value.priorityStat;
      default:
        return orderData.priority;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap ?? () {
        hideKeyboard(context);
        Get.to(() => TestOrderDetailScreen(orderData: orderData));
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
            // Order Number & Status Badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    '#${orderData.orderNumber}',
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
            10.height,

            // Order Date
            Row(
              children: [
                Icon(Icons.calendar_today_outlined, size: 14, color: secondaryTextColor),
                4.width,
                Text(
                  orderData.orderDate,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    letterSpacing: 0.1,
                    color: secondaryTextColor,
                  ),
                ),
                16.width,
                // Item Count
                Icon(Icons.science_outlined, size: 14, color: secondaryTextColor),
                4.width,
                Text(
                  '${orderData.items.length} ${locale.value.testCount}',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    letterSpacing: 0.1,
                    color: secondaryTextColor,
                  ),
                ),
              ],
            ),
            10.height,

            // Priority Badge & Final Amount
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (orderData.priority.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: LinearGradient(
                        colors: [
                          _priorityColor.withValues(alpha: 0.15),
                          _priorityColor.withValues(alpha: 0.08),
                        ],
                      ),
                    ),
                    child: Text(
                      _priorityLabel,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.1,
                        color: _priorityColor,
                      ),
                    ),
                  ),
                Text(
                  '\$${orderData.finalAmount.toStringAsFixed(2)}',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.1,
                    color: isDarkMode.value ? Colors.white : primaryTextColor,
                  ),
                ),
              ],
            ),
          ],
        ),
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
