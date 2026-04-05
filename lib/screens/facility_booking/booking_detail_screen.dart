import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kivicare_patient/models/facility_booking_model.dart';
import 'package:kivicare_patient/screens/facility_booking/booking_detail_controller.dart';
import 'package:kivicare_patient/screens/facility_booking/components/booking_status_badge.dart';
import 'package:kivicare_patient/screens/lab_test/components/cancellation_reason_dialog.dart';
import 'package:kivicare_patient/utils/colors.dart';
import 'package:kivicare_patient/utils/common_base.dart';
import 'package:kivicare_patient/components/app_scaffold.dart';
import 'package:kivicare_patient/components/loader_widget.dart';
import 'package:kivicare_patient/components/empty_error_state_widget.dart';
import 'package:nb_utils/nb_utils.dart';

class BookingDetailScreen extends StatelessWidget {
  final int bookingId;

  const BookingDetailScreen({
    required this.bookingId,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(
      BookingDetailController(bookingId: bookingId),
    );

    return AppScaffold(
      appBarTitle: locale.value.bookingDetail ?? 'Booking Detail',
      body: GetBuilder<BookingDetailController>(
        builder: (controller) {
          if (controller.isLoading.value) {
            return Center(child: LoaderWidget());
          }

          if (controller.hasError) {
            return EmptyErrorStateWidget(
              title: locale.value.somethingWentWrong,
              subTitle: controller.errorMessage.value,
              onRetry: controller.loadBookingDetail,
            );
          }

          if (!controller.hasBookingLoaded) {
            return EmptyErrorStateWidget(
              title: locale.value.bookingNotFound,
              subTitle: locale.value.tryAgainLater,
              onRetry: controller.loadBookingDetail,
            );
          }

          final booking = controller.booking.value!;

          return SingleChildScrollView(
            padding: EdgeInsets.all(24.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Booking Header
                _buildBookingHeader(booking, context),
                SizedBox(height: 32.w),

                // Facility Section
                _buildSection(
                  title: locale.value.facility,
                  child: _buildFacilityCard(booking),
                ),
                SizedBox(height: 24.w),

                // Appointment Section
                _buildSection(
                  title: locale.value.appointment,
                  child: _buildAppointmentCard(booking),
                ),
                SizedBox(height: 24.w),

                // Patient Section
                _buildSection(
                  title: locale.value.patientInformation,
                  child: _buildPatientCard(booking),
                ),
                SizedBox(height: 24.w),

                // Notes Section (if available)
                if (booking.notes?.isNotEmpty ?? false) ...[
                  _buildSection(
                    title: locale.value.notes,
                    child: _buildNotesCard(booking),
                  ),
                  SizedBox(height: 24.w),
                ],

                // Action Buttons
                _buildActionButtons(booking, controller, context),
                SizedBox(height: 24.w),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBookingHeader(FacilityBooking booking, BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isDarkMode.value ? cardDarkColor : gray50,
        border: Border.all(
          color: isDarkMode.value ? gray700 : gray200,
        ),
        borderRadius: BorderRadius.circular(12.w),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    locale.value.bookingNumber,
                    style: secondaryTextStyle(size: 12),
                  ),
                  SizedBox(height: 4.w),
                  Text(
                    booking.bookingNumber ?? 'N/A',
                    style: boldTextStyle(size: 16),
                  ),
                ],
              ),
              BookingStatusBadge(status: booking.status ?? 'pending'),
            ],
          ),
          SizedBox(height: 12.w),
          Text(
            'Booked on ${booking.createdAt?.split('T')[0] ?? 'N/A'}',
            style: secondaryTextStyle(size: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: boldTextStyle(size: 14),
        ),
        SizedBox(height: 8.w),
        child,
      ],
    );
  }

  Widget _buildFacilityCard(FacilityBooking booking) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: isDarkMode.value ? cardDarkColor : Colors.white,
        border: Border.all(
          color: isDarkMode.value ? gray700 : gray200,
        ),
        borderRadius: BorderRadius.circular(12.w),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: isDarkMode.value ? gray800 : gray100,
              borderRadius: BorderRadius.circular(8.w),
            ),
            child: Icon(
              booking.type == 'lab' ? Icons.local_hospital : Icons.medical_services,
              color: primaryColor,
              size: 20.w,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  booking.facility?['name'] ?? 'N/A',
                  style: boldTextStyle(size: 14),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4.w),
                Text(
                  booking.type == 'lab'
                      ? locale.value.laboratory
                      : locale.value.radiologyCenter,
                  style: secondaryTextStyle(size: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentCard(FacilityBooking booking) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: isDarkMode.value ? cardDarkColor : Colors.white,
        border: Border.all(
          color: isDarkMode.value ? gray700 : gray200,
        ),
        borderRadius: BorderRadius.circular(12.w),
      ),
      child: Column(
        children: [
          _buildInfoRow(
            icon: Icons.calendar_today,
            label: locale.value.date,
            value: booking.bookingDate ?? 'N/A',
          ),
          SizedBox(height: 12.w),
          _buildInfoRow(
            icon: Icons.schedule,
            label: locale.value.time,
            value: booking.bookingTime ?? 'N/A',
          ),
        ],
      ),
    );
  }

  Widget _buildPatientCard(FacilityBooking booking) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: isDarkMode.value ? cardDarkColor : Colors.white,
        border: Border.all(
          color: isDarkMode.value ? gray700 : gray200,
        ),
        borderRadius: BorderRadius.circular(12.w),
      ),
      child: Column(
        children: [
          _buildInfoRow(
            icon: Icons.person,
            label: locale.value.name,
            value: booking.patientName ?? 'N/A',
          ),
          SizedBox(height: 12.w),
          _buildInfoRow(
            icon: Icons.phone,
            label: locale.value.phone,
            value: booking.patientPhone ?? 'N/A',
          ),
        ],
      ),
    );
  }

  Widget _buildNotesCard(FacilityBooking booking) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: isDarkMode.value ? cardDarkColor : Colors.white,
        border: Border.all(
          color: isDarkMode.value ? gray700 : gray200,
        ),
        borderRadius: BorderRadius.circular(12.w),
      ),
      child: Text(
        booking.notes ?? '',
        style: primaryTextStyle(size: 13),
        maxLines: 5,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          color: primaryColor,
          size: 18.w,
        ),
        SizedBox(width: 12.w),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: secondaryTextStyle(size: 11),
            ),
            SizedBox(height: 2.w),
            Text(
              value,
              style: boldTextStyle(size: 13),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButtons(
    FacilityBooking booking,
    BookingDetailController controller,
    BuildContext context,
  ) {
    final canCancel = booking.status == 'pending' || booking.status == 'confirmed';

    return Column(
      children: [
        if (canCancel)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _showCancelDialog(booking, controller, context),
              style: ElevatedButton.styleFrom(
                backgroundColor: redColor,
                padding: EdgeInsets.symmetric(vertical: 12.w),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.w),
                ),
              ),
              icon: Icon(Icons.close, size: 18.w),
              label: Text(
                locale.value.cancelBooking ?? 'Cancel Booking',
                style: boldTextStyle(color: Colors.white, size: 14),
              ),
            ),
          ),
      ],
    );
  }

  void _showCancelDialog(
    FacilityBooking booking,
    BookingDetailController controller,
    BuildContext context,
  ) {
    showCancellationReasonDialog(context, (reason) {
      controller.cancelBooking(booking.id, reason: reason);
    });
  }
}
