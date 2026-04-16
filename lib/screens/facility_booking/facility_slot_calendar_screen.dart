import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:kivicare_patient/screens/facility_booking/facility_booking_controller.dart';
import 'package:kivicare_patient/screens/facility_booking/facility_slots_controller.dart';
import 'package:kivicare_patient/screens/facility_booking/booking_details_screen.dart';
import 'package:kivicare_patient/utils/colors.dart';
import 'package:kivicare_patient/utils/common_base.dart';
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
                      const SizedBox(height: 8.0),
                      Text(
                        facilityType == 'lab' ? locale.value.laboratory : locale.value.radiologyCenter,
                        style: secondaryTextStyle(size: 14),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24.0),

                // Calendar Header
                Text(locale.value.selectDate, style: boldTextStyle(size: 16)),
                const SizedBox(height: 16.0),

                // Custom Calendar Widget
                _CalendarPicker(
                  selectedDate: controller.selectedDate.value,
                  onDateSelected: (date) {
                    controller.setSelectedDate(date);
                    controller.loadSlots(date);
                  },
                ),
                const SizedBox(height: 24.0),

                // Time Slots
                if (controller.isLoading.value)
                  Center(child: LoaderWidget())
                else if (controller.selectedDate.value != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(locale.value.selectTime, style: boldTextStyle(size: 16)),
                      const SizedBox(height: 16.0),
                      if (controller.slots.isEmpty)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 24.0),
                            child: Text(locale.value.noSlotsAvailable, style: secondaryTextStyle()),
                          ),
                        )
                      else
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 12.0,
                            mainAxisSpacing: 12.0,
                            childAspectRatio: 1.2,
                          ),
                          itemCount: controller.slots.length,
                          itemBuilder: (context, index) {
                            final slot = controller.slots[index];
                            final isSelected = bookingController.selectedTime.value == slot.time;
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
                                  borderRadius: BorderRadius.circular(12.0),
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
              final isEnabled = controller.selectedDate.value != null && bookingController.selectedTime.value != null;
              return Container(
                padding: const EdgeInsets.all(24.0),
                decoration: BoxDecoration(
                  color: isDarkMode.value ? cardDarkColor : Colors.white,
                  border: Border(top: BorderSide(color: isDarkMode.value ? gray800 : gray100)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Summary
                    Container(
                      padding: const EdgeInsets.all(12.0),
                      decoration: BoxDecoration(
                        color: isDarkMode.value ? gray800 : gray50,
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(locale.value.selectedDate, style: secondaryTextStyle()),
                              Text(
                                controller.selectedDate.value != null
                                    ? DateFormat('dd MMM yyyy').format(controller.selectedDate.value!)
                                    : '-',
                                style: boldTextStyle(),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8.0),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(locale.value.selectedTime, style: secondaryTextStyle()),
                              Text(bookingController.selectedTime.value ?? '-', style: boldTextStyle()),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16.0),

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
                        minimumSize: const Size(double.infinity, 56.0),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
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

class _CalendarPicker extends StatefulWidget {
  final DateTime? selectedDate;
  final ValueChanged<DateTime> onDateSelected;

  const _CalendarPicker({
    required this.selectedDate,
    required this.onDateSelected,
  });

  @override
  State<_CalendarPicker> createState() => _CalendarPickerState();
}

class _CalendarPickerState extends State<_CalendarPicker> {
  late DateTime _focusedMonth;

  @override
  void initState() {
    super.initState();
    _focusedMonth = widget.selectedDate ?? DateTime.now();
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final lastDay = now.add(const Duration(days: 90));
    final firstDayOfMonth = DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    final lastDayOfMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 0);
    final startWeekday = firstDayOfMonth.weekday % 7;
    final totalCells = startWeekday + lastDayOfMonth.day;
    final rows = (totalCells / 7).ceil();

    return Container(
      decoration: BoxDecoration(
        color: isDarkMode.value ? cardDarkColor : Colors.white,
        border: Border.all(color: isDarkMode.value ? gray800 : gray100),
        borderRadius: BorderRadius.circular(16.0),
      ),
      padding: const EdgeInsets.all(12.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(Icons.chevron_left, color: appColorPrimary),
                onPressed: () {
                  setState(() {
                    _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1, 1);
                  });
                },
              ),
              Text(
                '${_monthName(_focusedMonth.month)} ${_focusedMonth.year}',
                style: boldTextStyle(size: 16),
              ),
              IconButton(
                icon: Icon(Icons.chevron_right, color: appColorPrimary),
                onPressed: () {
                  setState(() {
                    _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 1);
                  });
                },
              ),
            ],
          ),
          Row(
            children: ['Su', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa'].map((d) {
              return Expanded(
                child: Center(child: Text(d, style: secondaryTextStyle(size: 11))),
              );
            }).toList(),
          ),
          const SizedBox(height: 8.0),
          ...List.generate(rows, (row) {
            return Row(
              children: List.generate(7, (col) {
                final cellIndex = row * 7 + col;
                final dayNum = cellIndex - startWeekday + 1;
                if (dayNum < 1 || dayNum > lastDayOfMonth.day) {
                  return const Expanded(child: SizedBox());
                }
                final date = DateTime(_focusedMonth.year, _focusedMonth.month, dayNum);
                final isSelected = widget.selectedDate != null && _isSameDay(date, widget.selectedDate!);
                final isToday = _isSameDay(date, now);
                final isDisabled = date.isBefore(DateTime(now.year, now.month, now.day)) || date.isAfter(lastDay);

                return Expanded(
                  child: GestureDetector(
                    onTap: isDisabled ? null : () => widget.onDateSelected(date),
                    child: Container(
                      margin: const EdgeInsets.all(2.0),
                      height: 36.0,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isSelected
                            ? appColorPrimary
                            : isToday
                                ? appColorPrimary.withValues(alpha: 0.3)
                                : Colors.transparent,
                      ),
                      child: Center(
                        child: Text(
                          '$dayNum',
                          style: primaryTextStyle(
                            color: isSelected
                                ? Colors.white
                                : isDisabled
                                    ? gray400
                                    : null,
                            size: 13,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            );
          }),
        ],
      ),
    );
  }

  String _monthName(int month) {
    const names = ['January', 'February', 'March', 'April', 'May', 'June',
        'July', 'August', 'September', 'October', 'November', 'December'];
    return names[month - 1];
  }
}
