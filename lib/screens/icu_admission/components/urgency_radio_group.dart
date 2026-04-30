import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../../main.dart';
import '../../../utils/colors.dart';
import '../models/admission_request_model.dart';

class UrgencyRadioGroup extends StatelessWidget {
  final UrgencyLevel selectedUrgency;
  final ValueChanged<UrgencyLevel> onChanged;

  const UrgencyRadioGroup({
    super.key,
    required this.selectedUrgency,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(locale.value.urgencyLevel, style: boldTextStyle()),
        8.height,
        Row(
          children: UrgencyLevel.values.map((urgency) {
            final isSelected = selectedUrgency == urgency;
            final color = _getUrgencyColor(urgency);

            return Expanded(
              child: GestureDetector(
                onTap: () => onChanged(urgency),
                child: Container(
                  margin: EdgeInsets.only(right: urgency == UrgencyLevel.critical ? 0 : 8),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected ? color.withValues(alpha: 0.1) : context.cardColor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected ? color : context.dividerColor,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      _getUrgencyLabel(urgency),
                      style: boldTextStyle(
                        color: isSelected ? color : context.iconColor,
                        size: 14,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Color _getUrgencyColor(UrgencyLevel urgency) {
    switch (urgency) {
      case UrgencyLevel.routine:
        return urgencyStandardColor;
      case UrgencyLevel.urgent:
        return urgencyUrgentColor;
      case UrgencyLevel.critical:
        return urgencyCriticalColor;
    }
  }

  String _getUrgencyLabel(UrgencyLevel urgency) {
    switch (urgency) {
      case UrgencyLevel.routine:
        return locale.value.routine;
      case UrgencyLevel.urgent:
        return locale.value.urgent;
      case UrgencyLevel.critical:
        return locale.value.critical;
    }
  }
}
