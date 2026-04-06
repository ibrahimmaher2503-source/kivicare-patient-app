import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kivicare_patient/models/facility_booking_model.dart';
import 'package:kivicare_patient/screens/facility_booking/components/booking_status_badge.dart';
import 'package:kivicare_patient/screens/facility_booking/facility_booking_controller.dart';
import 'package:kivicare_patient/utils/colors.dart';
import 'package:kivicare_patient/utils/common_base.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../utils/app_common.dart';
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
        margin: EdgeInsets.symmetric(vertical: 8.w),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: isDarkMode.value ? cardDarkColor : Colors.white,
          border: Border.all(color: isDarkMode.value ? gray700 : gray200),
          borderRadius: BorderRadius.circular(12.w),
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
                      SizedBox(height: 4.w),
                      Text(
                        booking.facility?.name ?? 'Unknown Facility',
                        style: secondaryTextStyle(size: 12),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 8.w),
                BookingStatusBadge(status: booking.status),
              ],
            ),
            SizedBox(height: 12.w),

            // Details Grid
            Row(
              children: [
                Expanded(
                  child: _DetailItem(
                    icon: Icons.calendar_today,
                    label: booking.bookingDate,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: _DetailItem(
                    icon: Icons.access_time,
                    label: booking.bookingTime,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.w),

            // Patient Info
            _DetailItem(
              icon: Icons.person,
              label: booking.patientName,
            ),
            SizedBox(height: 8.w),
            _DetailItem(
              icon: Icons.phone,
              label: booking.patientPhone,
            ),

            // Action Buttons
            if (canCancel && onCancel != null) ...[
              SizedBox(height: 12.w),
              SizedBox(
                width: double.infinity,
                height: 36.w,
                child: OutlinedButton.icon(
                  onPressed: onCancel,
                  icon: Icon(Icons.close, size: 16.w),
                  label: Text('Cancel', style: boldTextStyle(size: 12)),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: cancelStatusColor),
                    foregroundColor: cancelStatusColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.w)),
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
        Icon(icon, size: 16.w, color: gray500),
        SizedBox(width: 8.w),
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
