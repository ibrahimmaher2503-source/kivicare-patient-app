import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:kivicare_patient/screens/labs_radiology/labs_radiology_common.dart';
import 'package:kivicare_patient/utils/locale_formatters.dart';

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
                formatLocalizedDate(date, 'EEE').toUpperCase(),
                style: secondaryTextStyle(
                    color: isSelected ? Colors.white70 : secondaryTextColor,
                    size: 12),
              ),
              8.height,
              Text(
                formatLocalizedDate(date, 'd'),
                style: boldTextStyle(
                    color: isSelected ? Colors.white : context.iconColor,
                    size: 18),
              ),
              4.height,
              Text(
                formatLocalizedDate(date, 'MMM'),
                style: secondaryTextStyle(
                    color: isSelected ? Colors.white70 : secondaryTextColor,
                    size: 12),
              ),
            ],
          ),
        ).onTap(() => onDateSelected(date));
      },
    );
  }
}
