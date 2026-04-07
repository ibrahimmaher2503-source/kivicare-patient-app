import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../main.dart';
import '../../../utils/app_common.dart';
import '../../../utils/colors.dart';
import '../../../utils/constants.dart';
import '../../../utils/price_widget.dart';
import '../model/independent_booking_model.dart';

/// A card widget displaying a single independent booking entry in a list.
class IndependentBookingCard extends StatelessWidget {
  final IndependentBooking booking;
  final VoidCallback? onTap;

  const IndependentBookingCard({
    super.key,
    required this.booking,
    this.onTap,
  });

  static const Color _inPersonColor = Color(0xFF00897B); // Teal

  Color get _statusColor {
    switch (booking.status.toLowerCase()) {
      case 'confirmed':
        return callBookingConfirmedColor;
      case 'completed':
        return callBookingCompletedColor;
      case 'cancelled':
        return callBookingCancelledColor;
      default:
        return pendingStatusColor;
    }
  }

  String get _statusLabel {
    switch (booking.status.toLowerCase()) {
      case 'confirmed':
        return locale.value.confirm;
      case 'completed':
        return locale.value.completed;
      case 'cancelled':
        return locale.value.cancelled;
      case 'pending':
        return locale.value.pending;
      default:
        return booking.status;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
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
            // Top row: Doctor label + badges
            Row(
              children: [
                Expanded(
                  child: Text(
                    locale.value.doctor,
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.3,
                      color: isDarkMode.value ? Colors.white : primaryTextColor,
                    ),
                  ),
                ),
                // In-Person badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: _inPersonColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.person_pin_rounded,
                        size: 12,
                        color: _inPersonColor,
                      ),
                      4.width,
                      Text(
                        locale.value.inPersonConsultation,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.1,
                          color: _inPersonColor,
                        ),
                      ),
                    ],
                  ),
                ),
                8.width,
                // Status badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: _statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
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
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.1,
                          color: _statusColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            12.height,

            // Date + time row
            Row(
              children: [
                Icon(Icons.calendar_today_outlined, size: 14, color: secondaryTextColor),
                6.width,
                Text(
                  _formatDate(booking.appointmentDate),
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.1,
                    color: isDarkMode.value ? Colors.white70 : primaryTextColor,
                  ),
                ),
                16.width,
                Icon(Icons.access_time_outlined, size: 14, color: secondaryTextColor),
                6.width,
                Text(
                  booking.appointmentTime,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.1,
                    color: isDarkMode.value ? Colors.white70 : primaryTextColor,
                  ),
                ),
              ],
            ),
            12.height,

            // Amount row (no Join Call button for in-person)
            Row(
              children: [
                PriceWidget(
                  price: booking.totalAmount,
                  size: 18,
                  color: appColorSecondary,
                ),
                const Spacer(),
                if (booking.duration > 0) ...[
                  Icon(Icons.timer_outlined, size: 14, color: secondaryTextColor),
                  4.width,
                  Text(
                    '${booking.duration} min',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.1,
                      color: secondaryTextColor,
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

  String _formatDate(String rawDate) {
    final parsed = DateTime.tryParse(rawDate);
    if (parsed == null) return rawDate;
    return DateFormat(DateFormatConst.D_MMMM_yyyy).format(parsed.toLocal());
  }
}
