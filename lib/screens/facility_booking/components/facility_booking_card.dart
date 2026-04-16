import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kivicare_patient/models/facility_booking_model.dart';
import 'package:kivicare_patient/screens/facility_booking/components/booking_status_badge.dart';
import 'package:kivicare_patient/screens/facility_booking/facility_booking_controller.dart';
import 'package:kivicare_patient/utils/colors.dart';
import 'package:kivicare_patient/utils/common_base.dart';
import 'package:kivicare_patient/utils/app_common.dart';
import 'package:nb_utils/nb_utils.dart';

class FacilityBookingCard extends StatelessWidget {
  final FacilityBooking booking;
  final VoidCallback? onTap;
  final VoidCallback? onCancel;

  const FacilityBookingCard({
    required this.booking,
    this.onTap,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final bookingController = Get.find<FacilityBookingController>();
    final canCancel = bookingController.canCancelBooking(booking) && onCancel != null;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: isDarkMode.value ? cardDarkColor : Colors.white,
          border: Border.all(color: isDarkMode.value ? gray700 : gray200),
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        booking.bookingNumber,
                        style: boldTextStyle(size: 14),
                      ),
                      const SizedBox(height: 4.0),
                      Text(
                        booking.facility?.name ?? 'Unknown Facility',
                        style: secondaryTextStyle(size: 12),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8.0),
                BookingStatusBadge(status: booking.status),
              ],
            ),
            const SizedBox(height: 12.0),

            // Details Grid
            Row(
              children: [
                Expanded(
                  child: _DetailItem(
                    icon: Icons.calendar_today,
                    label: booking.bookingDate,
                  ),
                ),
                const SizedBox(width: 12.0),
                Expanded(
                  child: _DetailItem(
                    icon: Icons.access_time,
                    label: booking.bookingTime,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12.0),

            // Patient Info
            _DetailItem(
              icon: Icons.person,
              label: booking.patientName,
            ),
            const SizedBox(height: 8.0),
            _DetailItem(
              icon: Icons.phone,
              label: booking.patientPhone,
            ),

            // Action Buttons
            if (canCancel && onCancel != null) ...[
              const SizedBox(height: 12.0),
              SizedBox(
                width: double.infinity,
                height: 36.0,
                child: OutlinedButton.icon(
                  onPressed: onCancel,
                  icon: const Icon(Icons.close, size: 16.0),
                  label: Text('Cancel', style: boldTextStyle(size: 12)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: cancelStatusColor),
                    foregroundColor: cancelStatusColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _DetailItem extends StatelessWidget {
  final IconData icon;
  final String label;

  const _DetailItem({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16.0, color: gray500),
        const SizedBox(width: 8.0),
        Expanded(
          child: Text(
            label,
            style: secondaryTextStyle(size: 12),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
