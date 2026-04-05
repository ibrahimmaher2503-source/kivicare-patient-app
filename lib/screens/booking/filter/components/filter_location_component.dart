import 'package:flutter/material.dart';
import 'package:kivicare_patient/components/governorates_city_picker.dart';
import 'package:kivicare_patient/screens/booking/filter/filter_controller.dart';
import 'package:kivicare_patient/utils/app_common.dart';
import 'package:kivicare_patient/utils/colors.dart';

/// FilterLocationComponent — Wraps GovernoratesCityPicker with filter modal styling.
///
/// Uses surfaceElevated background, glass border, 16px radius to match Clinical Elegance design.
class FilterLocationComponent extends StatelessWidget {
  final FilterController controller;

  const FilterLocationComponent({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDarkMode.value ? surfaceElevatedDark : surfaceElevated,
        border: Border.all(
          color: isDarkMode.value ? glassStrokeDark : glassStrokeLight,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDarkMode.value ? softShadowColorDark : softShadowColor,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: GovernoratesCityPicker(
        selectedGovernorateId: controller.selectedGovernorateId.value,
        selectedCityId: controller.selectedCityId.value,
        onGovernorateChanged: (id) => controller.onGovernorateChanged(id),
        onCityChanged: (id) => controller.onCityChanged(id),
        padding: const EdgeInsets.all(16),
      ),
    );
  }
}
