import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:kivicare_patient/screens/labs_radiology/labs_radiology_common.dart';

class CalendarStrip extends StatelessWidget {
  final List<DateTime> availableDates;
  final DateTime? selectedDate;
  final Function(DateTime) onDateSelected;

  const CalendarStrip({
    super.key,
    required this.availableDates,
    required this.selectedDate,
    required this.onDateSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (availableDates.isEmpty) return const SizedBox.shrink();

    return HorizontalList(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: availableDates.length,
      itemBuilder: (context, index) {
        final date = availableDates[index];
        final isSelected = selectedDate != null &&
            date.year == selectedDate!.year &&
            date.month == selectedDate!.month &&
            date.day == selectedDate!.day;

        return Container(
          width: 70,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: boxDecorationWithRoundedCorners(
            backgroundColor:
                isSelected ? context.primaryColor : context.cardColor,
            borderRadius: radius(12),
            border: Border.all(
                color:
                    isSelected ? context.primaryColor : context.dividerColor),
          ),
          child: Column(
            children: [
              Text(
                DateFormat('EEE').format(date).toUpperCase(),
                style: secondaryTextStyle(
                    color: isSelected ? Colors.white70 : secondaryTextColor,
                    size: 10),
              ),
              8.height,
              Text(
                date.day.toString(),
                style: boldTextStyle(
                    color: isSelected ? Colors.white : context.iconColor,
                    size: 18),
              ),
              4.height,
              Text(
                DateFormat('MMM').format(date),
                style: secondaryTextStyle(
                    color: isSelected ? Colors.white70 : secondaryTextColor,
                    size: 10),
              ),
            ],
          ),
        ).onTap(() => onDateSelected(date));
      },
    );
  }
}
