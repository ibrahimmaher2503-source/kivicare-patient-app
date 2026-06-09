import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:kivicare_patient/screens/labs_radiology/labs_radiology_common.dart';

class DistanceBadge extends StatelessWidget {
  final double? distanceKm;

  const DistanceBadge({super.key, this.distanceKm});

  @override
  Widget build(BuildContext context) {
    if (distanceKm == null || distanceKm! <= 0) return const SizedBox.shrink();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.location_on_outlined,
            size: 12, color: secondaryTextColor),
        2.width,
        Text(
          '${distanceKm!.toStringAsFixed(1)} km',
          style: secondaryTextStyle(size: 11),
        ),
      ],
    );
  }
}
