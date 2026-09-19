import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../utils/colors.dart';

class LocationCountBadge extends StatelessWidget {
  final int count;
  final String labelTemplate;

  const LocationCountBadge({
    super.key,
    required this.count,
    required this.labelTemplate,
  });

  @override
  Widget build(BuildContext context) {
    if (count <= 0) return const SizedBox.shrink();
    final label = labelTemplate.replaceAll('{count}', count.toString());
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: lightAccentColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: secondaryTextStyle(size: 12, color: appColorSecondary),
      ),
    );
  }
}
