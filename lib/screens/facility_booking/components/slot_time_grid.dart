import 'package:flutter/material.dart';
import 'package:kivicare_patient/models/booking_slot_model.dart';
import 'package:kivicare_patient/utils/colors.dart';
import 'package:kivicare_patient/utils/common_base.dart';
import 'package:kivicare_patient/utils/app_common.dart';
import 'package:nb_utils/nb_utils.dart';

class SlotTimeGrid extends StatelessWidget {
  final List<BookingSlot> slots;
  final String? selectedTime;
  final ValueChanged<String> onSlotSelected;
  final bool isLoading;

  const SlotTimeGrid({
    required this.slots,
    required this.selectedTime,
    required this.onSlotSelected,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    if (slots.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 24.0),
          child: Text('No time slots available for selected date'),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12.0,
        mainAxisSpacing: 12.0,
        childAspectRatio: 1.2,
      ),
      itemCount: slots.length,
      itemBuilder: (context, index) {
        final slot = slots[index];
        final isSelected = selectedTime == slot.time;
        final isAvailable = slot.available;

        return GestureDetector(
          onTap: isAvailable && !isLoading ? () => onSlotSelected(slot.time) : null,
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
                    const Padding(
                      padding: EdgeInsets.only(top: 4.0),
                      child: Text(
                        'Booked',
                        style: TextStyle(fontSize: 10, color: Colors.grey),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
