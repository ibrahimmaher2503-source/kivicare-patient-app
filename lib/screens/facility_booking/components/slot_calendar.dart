import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:kivicare_patient/utils/colors.dart';
import 'package:kivicare_patient/utils/common_base.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../utils/app_common.dart';
class SlotCalendar extends StatelessWidget {
  final DateTime? selectedDate;
  final ValueChanged<DateTime> onDateSelected;
  final int daysInAdvance;

  const SlotCalendar({
    required this.selectedDate,
    required this.onDateSelected,
    this.daysInAdvance = 90,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDarkMode.value ? cardDarkColor : Colors.white,
        border: Border.all(color: isDarkMode.value ? gray800 : gray100),
        borderRadius: BorderRadius.circular(16.w),
      ),
      padding: EdgeInsets.all(12.w),
      child: TableCalendar(
        firstDay: DateTime.now(),
        lastDay: DateTime.now().add(Duration(days: daysInAdvance)),
        focusedDay: selectedDate ?? DateTime.now(),
        selectedDayPredicate: (day) => isSameDay(selectedDate, day),
        onDaySelected: (selectedDay, focusedDay) => onDateSelected(selectedDay),
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
    );
  }
}
