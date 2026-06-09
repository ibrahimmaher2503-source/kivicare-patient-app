import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:kivicare_patient/screens/labs_radiology/labs_radiology_common.dart';
import 'package:kivicare_patient/screens/location_filter/governorate_selection_screen.dart';
import 'package:kivicare_patient/screens/location_filter/models/location_filter_result.dart';

class LocationFilterChip extends StatelessWidget {
  final int? selectedGovernorateId;
  final int? selectedCityId;
  final String? selectedGovernorateName;
  final String? selectedCityName;
  final Function(LocationFilterResult?) onLocationChanged;

  const LocationFilterChip({
    super.key,
    this.selectedGovernorateId,
    this.selectedCityId,
    this.selectedGovernorateName,
    this.selectedCityName,
    required this.onLocationChanged,
  });

  @override
  Widget build(BuildContext context) {
    String label = locale.value.allLocations;
    if (selectedGovernorateName != null) {
      label = selectedGovernorateName!;
      if (selectedCityName != null) {
        label = locale.value.locationFilterFormat
            .replaceAll('{governorate}', selectedGovernorateName!)
            .replaceAll('{city}', selectedCityName!);
      }
    }

    final isSelected = selectedGovernorateId != null;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: boxDecorationWithRoundedCorners(
        backgroundColor: isSelected
            ? context.primaryColor.withValues(alpha: 0.1)
            : context.cardColor,
        borderRadius: radius(20),
        border: Border.all(
            color: isSelected ? context.primaryColor : context.dividerColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.location_on_outlined,
            size: 16,
            color: isSelected ? context.primaryColor : secondaryTextColor,
          ),
          8.width,
          Text(
            label,
            style: secondaryTextStyle(
              color: isSelected ? context.primaryColor : secondaryTextColor,
              weight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          if (isSelected) ...[
            8.width,
            Icon(Icons.close, size: 14, color: context.primaryColor).onTap(() {
              onLocationChanged(const LocationFilterResult.cleared());
            }),
          ],
        ],
      ),
    ).onTap(() async {
      final result =
          await Get.to<LocationFilterResult>(() => GovernorateSelectionScreen(
                initiallySelectedId: selectedGovernorateId,
                initiallySelectedCityId: selectedCityId,
              ));
      if (result != null) {
        onLocationChanged(result);
      }
    });
  }
}
