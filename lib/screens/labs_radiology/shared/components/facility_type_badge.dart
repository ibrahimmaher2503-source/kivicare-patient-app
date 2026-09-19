import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:kivicare_patient/screens/labs_radiology/labs_radiology_common.dart';
import '../../models/facility_type.dart';

class FacilityTypeBadge extends StatelessWidget {
  final FacilityType type;

  const FacilityTypeBadge({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    final isRadiology = type == FacilityType.radiology;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: boxDecorationWithRoundedCorners(
        borderRadius: radius(4),
        backgroundColor: isRadiology
            ? context.primaryColor.withValues(alpha: 0.1)
            : Colors.green.withValues(alpha: 0.1),
      ),
      child: Text(
        isRadiology ? locale.value.radiology : locale.value.labs,
        style: secondaryTextStyle(
          size: 12,
          color: isRadiology ? context.primaryColor : Colors.green,
          weight: FontWeight.bold,
        ),
      ),
    );
  }
}
