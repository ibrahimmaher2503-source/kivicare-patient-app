import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:kivicare_patient/screens/labs_radiology/labs_radiology_common.dart';
import '../../models/slot_model.dart';

class SlotGrid extends StatelessWidget {
  final List<SlotModel> slots;
  final SlotModel? selectedSlot;
  final Function(SlotModel) onSlotSelected;

  const SlotGrid({
    super.key,
    required this.slots,
    required this.selectedSlot,
    required this.onSlotSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (slots.isEmpty) {
      return Column(
        children: [
          40.height,
          const Icon(Icons.calendar_today_outlined,
              size: 50, color: secondaryTextColor),
          16.height,
          Text(locale.value.noSlotsAvailable, style: boldTextStyle()),
          8.height,
          Text(locale.value.tryAnotherDate, style: secondaryTextStyle()),
        ],
      ).center();
    }

    return GridView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 2.2,
      ),
      itemCount: slots.length,
      itemBuilder: (context, index) {
        final slot = slots[index];
        final isSelected = selectedSlot?.id == slot.id;
        final isAvailable = slot.available;

        return Container(
          decoration: boxDecorationWithRoundedCorners(
            backgroundColor: isSelected
                ? context.primaryColor
                : (isAvailable
                    ? context.cardColor
                    : context.dividerColor.withValues(alpha: 0.1)),
            borderRadius: radius(8),
            border: Border.all(
              color: isSelected ? context.primaryColor : context.dividerColor,
            ),
          ),
          child: Text(
            slot.formattedRange(selectedLanguageCode.value),
            style: boldTextStyle(
              size: 12,
              color: isSelected
                  ? Colors.white
                  : (isAvailable ? context.iconColor : secondaryTextColor),
              decoration: isAvailable ? null : TextDecoration.lineThrough,
            ),
          ).center(),
        ).onTap(isAvailable ? () => onSlotSelected(slot) : null);
      },
    );
  }
}
