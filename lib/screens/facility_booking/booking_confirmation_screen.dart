import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:kivicare_patient/main.dart';
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
            padding: EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 40),

                // Success Icon
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: completedStatusColor.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(
                      Icons.check_circle,
                      size: 48,
                      color: completedStatusColor,
                    ),
                  ),
                ),
                SizedBox(height: 24),

                // Confirmation Title
                Text(
                  locale.value.bookingConfirmed,
                  style: boldTextStyle(size: 24),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 12),
                Text(
                  locale.value.yourBookingIsConfirmed,
                  style: secondaryTextStyle(size: 14),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 32),

                // Booking Details Container
                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isDarkMode.value ? cardBackgroundBlackDark : Colors.grey.shade50,
                    border: Border.all(color: isDarkMode.value ? Colors.grey.shade700 : Colors.grey.shade200),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      // Booking Number
                      _DetailRow(
                        label: locale.value.bookingNumber,
                        value: booking.bookingNumber,
                        isBold: true,
                      ),
                      SizedBox(height: 16),
                      Divider(color: isDarkMode.value ? Colors.grey.shade700 : Colors.grey.shade200),
                      SizedBox(height: 16),

                      // Facility Name
                      _DetailRow(
                        label: locale.value.facility,
                        value: booking.facility?.name ?? '-',
                      ),
                      SizedBox(height: 12),

                      // Booking Date
                      _DetailRow(
                        label: locale.value.bookingDate,
                        value: DateFormat('dd MMM yyyy').format(
                          DateTime.parse(booking.bookingDate),
                        ),
                      ),
                      SizedBox(height: 12),

                      // Booking Time
                      _DetailRow(
                        label: locale.value.bookingTime,
                        value: booking.bookingTime,
                      ),
                      SizedBox(height: 12),

                      // Patient Name
                      _DetailRow(
                        label: locale.value.patientName,
                        value: booking.patientName,
                      ),
                      SizedBox(height: 12),

                      // Patient Phone
                      _DetailRow(
                        label: locale.value.patientPhone,
                        value: booking.patientPhone,
                      ),
                      if (booking.notes?.isNotEmpty ?? false) ...[
                        SizedBox(height: 12),

                        // Notes
                        _DetailRow(
                          label: locale.value.notes,
                          value: booking.notes ?? '-',
                        ),
                      ],
                      SizedBox(height: 16),
                      Divider(color: isDarkMode.value ? Colors.grey.shade700 : Colors.grey.shade200),
                      SizedBox(height: 16),

                      // Booking Status
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            locale.value.status,
                            style: secondaryTextStyle(),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: pendingStatusColor.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              booking.status.replaceFirst(
                                booking.status[0],
                                booking.status[0].toUpperCase(),
                              ),
                              style: boldTextStyle(size: 12, color: pendingStatusColor),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 32),

                // Info Box
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: appColorPrimary.withOpacity(0.1),
                    border: Border.all(color: appColorPrimary.withOpacity(0.3)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info, color: appColorPrimary, size: 20),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          locale.value.bookingConfirmationSent,
                          style: secondaryTextStyle(size: 12),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 80),
              ],
            ),
          ),
        ),
        bottomNavigationBar: Container(
          padding: EdgeInsets.all(24),
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
                  minimumSize: Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(
                  locale.value.viewAllBookings,
                  style: boldTextStyle(color: Colors.white),
                ),
              ),
              SizedBox(height: 12),
              OutlinedButton(
                onPressed: () => Get.offAllNamed('/home'),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: appColorPrimary),
                  minimumSize: Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
        SizedBox(width: 12),
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
