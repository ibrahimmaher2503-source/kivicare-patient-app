import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:kivicare_patient/screens/labs_radiology/labs_radiology_common.dart';
import '../../models/facility_type.dart';

class FacilityTypeSelector extends StatelessWidget {
  final FacilityType selectedType;
  final Function(FacilityType) onTypeChanged;

  const FacilityTypeSelector({
    super.key,
    required this.selectedType,
    required this.onTypeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: boxDecorationWithRoundedCorners(
        backgroundColor: context.cardColor,
        borderRadius: radius(12),
      ),
      child: Row(
        children: [
          _buildItem(context, FacilityType.lab, locale.value.labs),
          _buildItem(context, FacilityType.radiology, locale.value.radiology),
        ],
      ),
    );
  }

  Widget _buildItem(BuildContext context, FacilityType type, String label) {
    final isSelected = selectedType == type;

    return Semantics(
      container: true,
      button: true,
      selected: isSelected,
      label: label,
      child: ExcludeSemantics(
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => onTypeChanged(type),
            borderRadius: radius(8),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 48),
              child: Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: isSelected
                    ? boxDecorationWithRoundedCorners(
                        backgroundColor: context.primaryColor,
                        borderRadius: radius(8),
                      )
                    : null,
                child: Text(
                  label,
                  style: boldTextStyle(
                    color: isSelected ? Colors.white : secondaryTextColor,
                    size: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ),
      ),
    ).expand();
  }
}
