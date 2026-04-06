import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kivicare_patient/screens/facility_booking/booking_details_controller.dart';
import 'package:kivicare_patient/screens/facility_booking/facility_booking_controller.dart';
import 'package:kivicare_patient/utils/colors.dart';
import 'package:kivicare_patient/utils/common_base.dart';
import 'package:kivicare_patient/utils/constants.dart';
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
        selectedDate: bookingController.selectedDate?.toString() ?? '',
        selectedTime: bookingController.selectedTime ?? '',
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
            padding: EdgeInsets.all(24.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Facility Info
                Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: isDarkMode.value ? cardDarkColor : Colors.white,
                    border: Border.all(color: isDarkMode.value ? gray800 : gray100),
                    borderRadius: BorderRadius.circular(16.w),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(facilityName, style: boldTextStyle(size: 16)),
                      SizedBox(height: 12.w),
                      Row(
                        children: [
                          Icon(Icons.calendar_today, size: 14.w, color: gray500),
                          SizedBox(width: 8.w),
                          Text(
                            bookingController.selectedDate != null
                                ? DateFormat('dd MMM yyyy').format(bookingController.selectedDate!)
                                : '-',
                            style: secondaryTextStyle(),
                          ),
                        ],
                      ),
                      SizedBox(height: 8.w),
                      Row(
                        children: [
                          Icon(Icons.access_time, size: 14.w, color: gray500),
                          SizedBox(width: 8.w),
                          Text(
                            bookingController.selectedTime ?? '-',
                            style: secondaryTextStyle(),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24.w),

                // Patient Details Section
                Text(locale.value.patientInformation, style: boldTextStyle(size: 16)),
                SizedBox(height: 16.w),

                // Patient Name Input
                Text(locale.value.patientName, style: secondaryTextStyle(size: 12)),
                SizedBox(height: 8.w),
                Container(
                  decoration: BoxDecoration(
                    color: isDarkMode.value ? cardDarkColor : gray50,
                    border: Border.all(color: isDarkMode.value ? gray700 : gray200),
                    borderRadius: BorderRadius.circular(12.w),
                  ),
                  child: TextFormField(
                    initialValue: controller.patientName.value,
                    onChanged: (value) => controller.patientName(value),
                    decoration: InputDecoration(
                      hintText: 'e.g., John Doe',
                      hintStyle: secondaryTextStyle(color: gray400),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(16.w),
                    ),
                    style: primaryTextStyle(),
                  ),
                ),
                SizedBox(height: 16.w),

                // Patient Phone Input
                Text(locale.value.patientPhone, style: secondaryTextStyle(size: 12)),
                SizedBox(height: 8.w),
                Container(
                  decoration: BoxDecoration(
                    color: isDarkMode.value ? cardDarkColor : gray50,
                    border: Border.all(color: isDarkMode.value ? gray700 : gray200),
                    borderRadius: BorderRadius.circular(12.w),
                  ),
                  child: TextFormField(
                    initialValue: controller.patientPhone.value,
                    onChanged: (value) => controller.patientPhone(value),
                    decoration: InputDecoration(
                      hintText: 'e.g., +1234567890',
                      hintStyle: secondaryTextStyle(color: gray400),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(16.w),
                    ),
                    style: primaryTextStyle(),
                    keyboardType: TextInputType.phone,
                  ),
                ),
                SizedBox(height: 16.w),

                // Clinical Notes Input
                Text(locale.value.notes, style: secondaryTextStyle(size: 12)),
                SizedBox(height: 8.w),
                Container(
                  decoration: BoxDecoration(
                    color: isDarkMode.value ? cardDarkColor : gray50,
                    border: Border.all(color: isDarkMode.value ? gray700 : gray200),
                    borderRadius: BorderRadius.circular(12.w),
                  ),
                  child: TextFormField(
                    initialValue: controller.notes.value,
                    onChanged: (value) => controller.notes(value),
                    decoration: InputDecoration(
                      hintText: locale.value.addNotesOptional,
                      hintStyle: secondaryTextStyle(color: gray400),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(16.w),
                    ),
                    style: primaryTextStyle(),
                    maxLines: 4,
                    maxLength: 1000,
                  ),
                ),
                SizedBox(height: 32.w),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: GetBuilder<BookingDetailsController>(
        builder: (controller) {
          return Container(
            padding: EdgeInsets.all(24.w),
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
                      minimumSize: Size(double.infinity, 56.w),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.w)),
                    ),
                    child: controller.isLoading.value
                        ? SizedBox(
                            height: 24.w,
                            width: 24.w,
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
