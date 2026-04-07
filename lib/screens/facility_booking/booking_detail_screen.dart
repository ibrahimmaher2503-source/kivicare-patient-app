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
import 'package:kivicare_patient/utils/empty_error_state_widget.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../main.dart';
import '../../utils/app_common.dart';

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
      appBarTitle: Text(locale.value.bookingDetail),
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
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Booking Header
                _buildBookingHeader(booking, context),
                const SizedBox(height: 32.0),

                // Facility Section
                _buildSection(
                  title: locale.value.facility,
                  child: _buildFacilityCard(booking),
                ),
                const SizedBox(height: 24.0),

                // Appointment Section
                _buildSection(
                  title: locale.value.appointment,
                  child: _buildAppointmentCard(booking),
                ),
                const SizedBox(height: 24.0),

                // Patient Section
                _buildSection(
                  title: locale.value.patientInformation,
                  child: _buildPatientCard(booking),
                ),
                const SizedBox(height: 24.0),

                // Notes Section (if available)
                if (booking.notes?.isNotEmpty ?? false) ...[
                  _buildSection(
                    title: locale.value.notes,
                    child: _buildNotesCard(booking),
                  ),
                  const SizedBox(height: 24.0),
                ],

                // Action Buttons
                _buildActionButtons(booking, controller, context),
                const SizedBox(height: 24.0),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBookingHeader(FacilityBooking booking, BuildContext context) {
    final createdDateStr = booking.createdAt != null
        ? '${booking.createdAt!.year}-${booking.createdAt!.month.toString().padLeft(2, '0')}-${booking.createdAt!.day.toString().padLeft(2, '0')}'
        : 'N/A';

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: isDarkMode.value ? cardDarkColor : gray50,
        border: Border.all(
          color: isDarkMode.value ? gray700 : gray200,
        ),
        borderRadius: BorderRadius.circular(12.0),
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
                  const SizedBox(height: 4.0),
                  Text(
                    booking.bookingNumber,
                    style: boldTextStyle(size: 16),
                  ),
                ],
              ),
              BookingStatusBadge(status: booking.status),
            ],
          ),
          const SizedBox(height: 12.0),
          Text(
            'Booked on $createdDateStr',
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
        const SizedBox(height: 8.0),
        child,
      ],
    );
  }

  Widget _buildFacilityCard(FacilityBooking booking) {
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: isDarkMode.value ? cardDarkColor : Colors.white,
        border: Border.all(
          color: isDarkMode.value ? gray700 : gray200,
        ),
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: isDarkMode.value ? gray800 : gray100,
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Icon(
              booking.type == 'lab' ? Icons.local_hospital : Icons.medical_services,
              color: appColorPrimary,
              size: 20.0,
            ),
          ),
          const SizedBox(width: 12.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  booking.facility.name,
                  style: boldTextStyle(size: 14),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4.0),
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
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: isDarkMode.value ? cardDarkColor : Colors.white,
        border: Border.all(
          color: isDarkMode.value ? gray700 : gray200,
        ),
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(
        children: [
          _buildInfoRow(
            icon: Icons.calendar_today,
            label: locale.value.date,
            value: booking.bookingDate,
          ),
          const SizedBox(height: 12.0),
          _buildInfoRow(
            icon: Icons.schedule,
            label: locale.value.time,
            value: booking.bookingTime,
          ),
        ],
      ),
    );
  }

  Widget _buildPatientCard(FacilityBooking booking) {
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: isDarkMode.value ? cardDarkColor : Colors.white,
        border: Border.all(
          color: isDarkMode.value ? gray700 : gray200,
        ),
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(
        children: [
          _buildInfoRow(
            icon: Icons.person,
            label: locale.value.name,
            value: booking.patientName,
          ),
          const SizedBox(height: 12.0),
          _buildInfoRow(
            icon: Icons.phone,
            label: locale.value.phone,
            value: booking.patientPhone,
          ),
        ],
      ),
    );
  }

  Widget _buildNotesCard(FacilityBooking booking) {
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: isDarkMode.value ? cardDarkColor : Colors.white,
        border: Border.all(
          color: isDarkMode.value ? gray700 : gray200,
        ),
        borderRadius: BorderRadius.circular(12.0),
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
          color: appColorPrimary,
          size: 18.0,
        ),
        const SizedBox(width: 12.0),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: secondaryTextStyle(size: 11),
            ),
            const SizedBox(height: 2.0),
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
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              icon: const Icon(Icons.close, size: 18.0),
              label: Text(
                locale.value.cancelBooking,
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
