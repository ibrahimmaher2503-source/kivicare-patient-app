import 'package:flutter/material.dart';
import 'package:kivicare_patient/utils/colors.dart';
import 'package:kivicare_patient/utils/common_base.dart';
import 'package:kivicare_patient/utils/app_common.dart';
import 'package:nb_utils/nb_utils.dart';

class SlotCalendar extends StatefulWidget {
  final DateTime? selectedDate;
  final ValueChanged<DateTime> onDateSelected;
  final int daysInAdvance;

  const SlotCalendar({
    required this.selectedDate,
    required this.onDateSelected,
    this.daysInAdvance = 90,
  });

  @override
  State<SlotCalendar> createState() => _SlotCalendarState();
}

class _SlotCalendarState extends State<SlotCalendar> {
  late DateTime _focusedMonth;

  @override
  void initState() {
    super.initState();
    _focusedMonth = widget.selectedDate ?? DateTime.now();
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  void _previousMonth() {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1, 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final lastDay = now.add(Duration(days: widget.daysInAdvance));
    final firstDayOfMonth = DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    final lastDayOfMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 0);
    final startWeekday = firstDayOfMonth.weekday % 7; // Sunday = 0
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
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(Icons.chevron_left, color: appColorPrimary),
                onPressed: _previousMonth,
              ),
              Text(
                '${_monthName(_focusedMonth.month)} ${_focusedMonth.year}',
                style: boldTextStyle(size: 16),
              ),
              IconButton(
                icon: Icon(Icons.chevron_right, color: appColorPrimary),
                onPressed: _nextMonth,
              ),
            ],
          ),
          // Day labels
          Row(
            children: ['Su', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa'].map((d) {
              return Expanded(
                child: Center(
                  child: Text(d, style: secondaryTextStyle(size: 11)),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 8.0),
          // Calendar grid
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
