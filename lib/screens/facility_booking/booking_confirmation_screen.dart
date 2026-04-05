import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kivicare_patient/models/facility_booking_model.dart';
import 'package:kivicare_patient/utils/app_common.dart';
import 'package:kivicare_patient/utils/colors.dart';
import 'package:kivicare_patient/utils/common_base.dart';
import 'package:kivicare_patient/utils/constants.dart';
import 'package:nb_utils/nb_utils.dart';

class BookingConfirmationScreen extends StatelessWidget {
  final FacilityBooking booking;

  BookingConfirmationScreen({required this.booking});

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: isDarkMode.value ? appBackgroundColorDark : Colors.white,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(24.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 40.w),

                // Success Icon
                Container(
                  width: 80.w,
                  height: 80.w,
                  decoration: BoxDecoration(
                    color: completedStatusColor.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(
                      Icons.check_circle,
                      size: 48.w,
                      color: completedStatusColor,
                    ),
                  ),
                ),
                SizedBox(height: 24.w),

                // Confirmation Title
                Text(
                  locale.value.bookingConfirmed,
                  style: boldTextStyle(size: 24),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 12.w),
                Text(
                  locale.value.yourBookingIsConfirmed,
                  style: secondaryTextStyle(size: 14),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 32.w),

                // Booking Details Container
                Container(
                  padding: EdgeInsets.all(20.w),
                  decoration: BoxDecoration(
                    color: isDarkMode.value ? cardBackgroundBlackDark : Colors.grey.shade50,
                    border: Border.all(color: isDarkMode.value ? Colors.grey.shade700 : Colors.grey.shade200),
                    borderRadius: BorderRadius.circular(16.w),
                  ),
                  child: Column(
                    children: [
                      // Booking Number
                      _DetailRow(
                        label: locale.value.bookingNumber,
                        value: booking.bookingNumber,
                        isBold: true,
                      ),
                      SizedBox(height: 16.w),
                      Divider(color: isDarkMode.value ? Colors.grey.shade700 : Colors.grey.shade200),
                      SizedBox(height: 16.w),

                      // Facility Name
                      _DetailRow(
                        label: locale.value.facility,
                        value: booking.facility?.name ?? '-',
                      ),
                      SizedBox(height: 12.w),

                      // Booking Date
                      _DetailRow(
                        label: locale.value.bookingDate,
                        value: DateFormat('dd MMM yyyy').format(
                          DateTime.parse(booking.bookingDate),
                        ),
                      ),
                      SizedBox(height: 12.w),

                      // Booking Time
                      _DetailRow(
                        label: locale.value.bookingTime,
                        value: booking.bookingTime,
                      ),
                      SizedBox(height: 12.w),

                      // Patient Name
                      _DetailRow(
                        label: locale.value.patientName,
                        value: booking.patientName,
                      ),
                      SizedBox(height: 12.w),

                      // Patient Phone
                      _DetailRow(
                        label: locale.value.patientPhone,
                        value: booking.patientPhone,
                      ),
                      if (booking.notes?.isNotEmpty ?? false) ...[
                        SizedBox(height: 12.w),

                        // Notes
                        _DetailRow(
                          label: locale.value.notes,
                          value: booking.notes ?? '-',
                        ),
                      ],
                      SizedBox(height: 16.w),
                      Divider(color: isDarkMode.value ? Colors.grey.shade700 : Colors.grey.shade200),
                      SizedBox(height: 16.w),

                      // Booking Status
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            locale.value.status,
                            style: secondaryTextStyle(),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.w),
                            decoration: BoxDecoration(
                              color: orange.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8.w),
                            ),
                            child: Text(
                              booking.status.replaceFirst(
                                booking.status[0],
                                booking.status[0].toUpperCase(),
                              ),
                              style: boldTextStyle(size: 12, color: orange),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 32.w),

                // Info Box
                Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: blue.withOpacity(0.1),
                    border: Border.all(color: blue.withOpacity(0.3)),
                    borderRadius: BorderRadius.circular(12.w),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info, color: blue, size: 20.w),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Text(
                          locale.value.bookingConfirmationSent,
                          style: secondaryTextStyle(size: 12),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 80.w),
              ],
            ),
          ),
        ),
        bottomNavigationBar: Container(
          padding: EdgeInsets.all(24.w),
          decoration: BoxDecoration(
            color: isDarkMode.value ? cardBackgroundBlackDark : Colors.white,
            border: Border(top: BorderSide(color: isDarkMode.value ? Colors.grey.shade800 : Colors.grey.shade100)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                onPressed: () => Get.offAllNamed('/bookings'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: appColorPrimary,
                  minimumSize: Size(double.infinity, 56.w),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.w)),
                ),
                child: Text(
                  locale.value.viewAllBookings,
                  style: boldTextStyle(color: Colors.white),
                ),
              ),
              SizedBox(height: 12.w),
              OutlinedButton(
                onPressed: () => Get.offAllNamed('/home'),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: appColorPrimary),
                  minimumSize: Size(double.infinity, 56.w),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.w)),
                ),
                child: Text(
                  locale.value.backToHome,
                  style: boldTextStyle(color: appColorPrimary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;

  _DetailRow({
    required this.label,
    required this.value,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: secondaryTextStyle(size: 13)),
        SizedBox(width: 12.w),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: isBold
                ? boldTextStyle(size: 14, color: appColorPrimary)
                : primaryTextStyle(size: 13),
          ),
        ),
      ],
    );
  }
}
