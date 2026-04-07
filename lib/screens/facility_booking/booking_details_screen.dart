import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:kivicare_patient/screens/facility_booking/booking_details_controller.dart';
import 'package:kivicare_patient/screens/facility_booking/facility_booking_controller.dart';
import 'package:kivicare_patient/utils/colors.dart';
import 'package:kivicare_patient/utils/common_base.dart';
import 'package:kivicare_patient/utils/form_validators.dart';
import 'package:kivicare_patient/components/loader_widget.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../main.dart';
import '../../utils/app_common.dart';

class BookingDetailsScreen extends StatelessWidget {
  final int facilityId;
  final String facilityType;
  final String facilityName;

  BookingDetailsScreen({
    required this.facilityId,
    required this.facilityType,
    required this.facilityName,
  });

  @override
  Widget build(BuildContext context) {
    final bookingController = Get.find<FacilityBookingController>();
    final detailsController = Get.put(
      BookingDetailsController(
        facilityId: facilityId,
        facilityType: facilityType,
        selectedDate: bookingController.selectedDate.value ?? '',
        selectedTime: bookingController.selectedTime.value ?? '',
      ),
    );

    return Scaffold(
      backgroundColor: isDarkMode.value ? scaffoldDarkColor : Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: isDarkMode.value ? scaffoldDarkColor : Colors.white,
        title: Text(locale.value.bookingDetails, style: boldTextStyle(size: 18)),
        leading: GestureDetector(
          onTap: () => Get.back(),
          child: Icon(
            Icons.arrow_back,
            color: isDarkMode.value ? whiteColor : blackColor,
          ),
        ),
      ),
      body: GetBuilder<BookingDetailsController>(
        builder: (controller) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Facility Info
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: isDarkMode.value ? cardDarkColor : Colors.white,
                    border: Border.all(color: isDarkMode.value ? gray800 : gray100),
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(facilityName, style: boldTextStyle(size: 16)),
                      const SizedBox(height: 12.0),
                      Row(
                        children: [
                          Icon(Icons.calendar_today, size: 14.0, color: gray500),
                          const SizedBox(width: 8.0),
                          Text(
                            bookingController.selectedDate.value != null
                                ? DateFormat('dd MMM yyyy').format(DateTime.tryParse(bookingController.selectedDate.value ?? '') ?? DateTime.now())
                                : '-',
                            style: secondaryTextStyle(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8.0),
                      Row(
                        children: [
                          Icon(Icons.access_time, size: 14.0, color: gray500),
                          const SizedBox(width: 8.0),
                          Text(
                            bookingController.selectedTime.value ?? '-',
                            style: secondaryTextStyle(),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24.0),

                // Patient Details Section
                Text(locale.value.patientInformation, style: boldTextStyle(size: 16)),
                const SizedBox(height: 16.0),

                // Patient Name Input
                Text(locale.value.patientName, style: secondaryTextStyle(size: 12)),
                const SizedBox(height: 8.0),
                Container(
                  decoration: BoxDecoration(
                    color: isDarkMode.value ? cardDarkColor : gray50,
                    border: Border.all(color: isDarkMode.value ? gray700 : gray200),
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: TextFormField(
                    initialValue: controller.patientName.value,
                    onChanged: (value) => controller.patientName(value),
                    decoration: InputDecoration(
                      hintText: 'e.g., John Doe',
                      hintStyle: secondaryTextStyle(color: gray400),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.all(16.0),
                    ),
                    style: primaryTextStyle(),
                  ),
                ),
                const SizedBox(height: 16.0),

                // Patient Phone Input
                Text(locale.value.patientPhone, style: secondaryTextStyle(size: 12)),
                const SizedBox(height: 8.0),
                Container(
                  decoration: BoxDecoration(
                    color: isDarkMode.value ? cardDarkColor : gray50,
                    border: Border.all(color: isDarkMode.value ? gray700 : gray200),
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: TextFormField(
                    initialValue: controller.patientPhone.value,
                    onChanged: (value) => controller.patientPhone(value),
                    decoration: InputDecoration(
                      hintText: 'e.g., +1234567890',
                      hintStyle: secondaryTextStyle(color: gray400),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.all(16.0),
                    ),
                    style: primaryTextStyle(),
                    keyboardType: TextInputType.phone,
                  ),
                ),
                const SizedBox(height: 16.0),

                // Clinical Notes Input
                Text(locale.value.notes, style: secondaryTextStyle(size: 12)),
                const SizedBox(height: 8.0),
                Container(
                  decoration: BoxDecoration(
                    color: isDarkMode.value ? cardDarkColor : gray50,
                    border: Border.all(color: isDarkMode.value ? gray700 : gray200),
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: TextFormField(
                    initialValue: controller.notes.value,
                    onChanged: (value) => controller.notes(value),
                    decoration: InputDecoration(
                      hintText: locale.value.addNotesOptional,
                      hintStyle: secondaryTextStyle(color: gray400),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.all(16.0),
                    ),
                    style: primaryTextStyle(),
                    maxLines: 4,
                    maxLength: 1000,
                  ),
                ),
                const SizedBox(height: 32.0),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: GetBuilder<BookingDetailsController>(
        builder: (controller) {
          return Container(
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              color: isDarkMode.value ? cardDarkColor : Colors.white,
              border: Border(top: BorderSide(color: isDarkMode.value ? gray800 : gray100)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Obx(
                  () => ElevatedButton(
                    onPressed: controller.isLoading.value
                        ? null
                        : () {
                            final validation = controller.validateBookingForm();
                            if (validation == null) {
                              controller.createBooking();
                            } else {
                              Get.snackbar(
                                locale.value.error,
                                validation,
                                snackPosition: SnackPosition.BOTTOM,
                              );
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: appColorPrimary,
                      disabledBackgroundColor: gray300,
                      minimumSize: const Size(double.infinity, 56.0),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                    ),
                    child: controller.isLoading.value
                        ? const SizedBox(
                            height: 24.0,
                            width: 24.0,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation(Colors.white),
                            ),
                          )
                        : Text(
                            locale.value.confirmBooking,
                            style: boldTextStyle(color: Colors.white),
                          ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
