import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:kivicare_patient/screens/facility_booking/facility_booking_controller.dart';
import 'package:kivicare_patient/screens/facility_booking/facility_slots_controller.dart';
import 'package:kivicare_patient/screens/facility_booking/booking_details_screen.dart';
import 'package:kivicare_patient/utils/colors.dart';
import 'package:kivicare_patient/utils/common_base.dart';
import 'package:kivicare_patient/utils/constants.dart';
import 'package:kivicare_patient/components/loader_widget.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../main.dart';
import '../../utils/app_common.dart';
class FacilitySlotCalendarScreen extends StatelessWidget {
  final int facilityId;
  final String facilityType;
  final String facilityName;

  FacilitySlotCalendarScreen({
    required this.facilityId,
    required this.facilityType,
    required this.facilityName,
  });

  @override
  Widget build(BuildContext context) {
    final tag = '${facilityType}_$facilityId';
    final slotsController = Get.put(
      FacilitySlotsController(facilityId: facilityId, facilityType: facilityType),
      tag: tag,
    );
    final bookingController = Get.find<FacilityBookingController>();

    return Scaffold(
      backgroundColor: isDarkMode.value ? scaffoldDarkColor : Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: isDarkMode.value ? scaffoldDarkColor : Colors.white,
        title: Text(locale.value.selectDate, style: boldTextStyle(size: 18)),
        leading: GestureDetector(
          onTap: () => Get.back(),
          child: Icon(Icons.arrow_back, color: isDarkMode.value ? whiteColor : blackColor),
        ),
      ),
      body: GetBuilder<FacilitySlotsController>(
        tag: tag,
        init: slotsController,
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
                      SizedBox(height: 8.w),
                      Text(
                        facilityType == 'lab' ? locale.value.laboratory : locale.value.radiologyCenter,
                        style: secondaryTextStyle(size: 14),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24.w),

                // Calendar Header
                Text(locale.value.selectDate, style: boldTextStyle(size: 16)),
                SizedBox(height: 16.w),

                // Calendar Widget
                Container(
                  decoration: BoxDecoration(
                    color: isDarkMode.value ? cardDarkColor : Colors.white,
                    border: Border.all(color: isDarkMode.value ? gray800 : gray100),
                    borderRadius: BorderRadius.circular(16.w),
                  ),
                  padding: EdgeInsets.all(12.w),
                  child: TableCalendar(
                    firstDay: DateTime.now(),
                    lastDay: DateTime.now().add(Duration(days: 90)),
                    focusedDay: controller.selectedDate ?? DateTime.now(),
                    selectedDayPredicate: (day) => isSameDay(controller.selectedDate, day),
                    onDaySelected: (selectedDay, focusedDay) {
                      controller.setSelectedDate(selectedDay);
                      controller.loadSlots(selectedDay);
                    },
                    calendarFormat: CalendarFormat.month,
                    startingDayOfWeek: StartingDayOfWeek.sunday,
                    headerStyle: HeaderStyle(
                      formatButtonVisible: false,
                      titleCentered: true,
                      titleTextStyle: boldTextStyle(size: 16),
                      leftChevronIcon: Icon(Icons.chevron_left, color: appColorPrimary),
                      rightChevronIcon: Icon(Icons.chevron_right, color: appColorPrimary),
                    ),
                    calendarStyle: CalendarStyle(
                      selectedDecoration: BoxDecoration(color: appColorPrimary, shape: BoxShape.circle),
                      selectedTextStyle: boldTextStyle(color: Colors.white),
                      todayDecoration: BoxDecoration(color: appColorPrimary.withOpacity(0.3), shape: BoxShape.circle),
                      todayTextStyle: boldTextStyle(color: appColorPrimary),
                      defaultTextStyle: primaryTextStyle(),
                      weekendTextStyle: primaryTextStyle(color: cancelStatusColor),
                      outsideTextStyle: primaryTextStyle(color: gray400),
                    ),
                  ),
                ),
                SizedBox(height: 24.w),

                // Time Slots
                if (controller.isLoading.value)
                  Center(child: LoaderWidget())
                else if (controller.selectedDate != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(locale.value.selectTime, style: boldTextStyle(size: 16)),
                      SizedBox(height: 16.w),
                      if (controller.slots.isEmpty)
                        Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 24.w),
                            child: Text(locale.value.noSlotsAvailable, style: secondaryTextStyle()),
                          ),
                        )
                      else
                        GridView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 12.w,
                            mainAxisSpacing: 12.w,
                            childAspectRatio: 1.2,
                          ),
                          itemCount: controller.slots.length,
                          itemBuilder: (context, index) {
                            final slot = controller.slots[index];
                            final isSelected = bookingController.selectedTime == slot.time;
                            final isAvailable = slot.available;
                            return GestureDetector(
                              onTap: isAvailable ? () => bookingController.selectTime(slot.time) : null,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? appColorPrimary
                                      : isAvailable
                                          ? (isDarkMode.value ? cardDarkColor : Colors.white)
                                          : (isDarkMode.value ? gray800 : gray100),
                                  border: Border.all(
                                    color: isSelected
                                        ? appColorPrimary
                                        : isAvailable
                                            ? (isDarkMode.value ? gray700 : gray200)
                                            : (isDarkMode.value ? gray600 : gray100),
                                  ),
                                  borderRadius: BorderRadius.circular(12.w),
                                ),
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        slot.time,
                                        style: boldTextStyle(
                                          size: 14,
                                          color: isSelected
                                              ? Colors.white
                                              : (isAvailable
                                                  ? (isDarkMode.value ? whiteColor : blackColor)
                                                  : gray500),
                                        ),
                                      ),
                                      if (!isAvailable)
                                        Text(
                                          locale.value.booked,
                                          style: secondaryTextStyle(size: 10, color: gray500),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                    ],
                  ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: GetBuilder<FacilitySlotsController>(
        tag: tag,
        builder: (controller) {
          return GetBuilder<FacilityBookingController>(
            builder: (bookingController) {
              final isEnabled = controller.selectedDate != null && bookingController.selectedTime != null;
              return Container(
                padding: EdgeInsets.all(24.w),
                decoration: BoxDecoration(
                  color: isDarkMode.value ? cardDarkColor : Colors.white,
                  border: Border(top: BorderSide(color: isDarkMode.value ? gray800 : gray100)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Summary
                    Container(
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color: isDarkMode.value ? gray800 : gray50,
                        borderRadius: BorderRadius.circular(12.w),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(locale.value.selectedDate, style: secondaryTextStyle()),
                              Text(
                                controller.selectedDate != null
                                    ? DateFormat('dd MMM yyyy').format(controller.selectedDate!)
                                    : '-',
                                style: boldTextStyle(),
                              ),
                            ],
                          ),
                          SizedBox(height: 8.w),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(locale.value.selectedTime, style: secondaryTextStyle()),
                              Text(bookingController.selectedTime ?? '-', style: boldTextStyle()),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16.w),

                    // Continue Button
                    ElevatedButton(
                      onPressed: isEnabled
                          ? () => Get.to(
                                () => BookingDetailsScreen(
                                  facilityId: facilityId,
                                  facilityType: facilityType,
                                  facilityName: facilityName,
                                ),
                              )
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isEnabled ? appColorPrimary : gray300,
                        disabledBackgroundColor: gray300,
                        minimumSize: Size(double.infinity, 56.w),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.w)),
                      ),
                      child: Text(locale.value.continueText, style: boldTextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
