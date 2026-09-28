import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

class FacilityRatingBadge extends StatelessWidget {
  final double rating;

  const FacilityRatingBadge({super.key, required this.rating});

  @override
  Widget build(BuildContext context) {
    if (rating <= 0) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: boxDecorationWithRoundedCorners(
        borderRadius: radius(4),
        backgroundColor: Colors.amber.withValues(alpha: 0.1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star, size: 12, color: Colors.amber),
          4.width,
          Text(
            rating.toStringAsFixed(1),
            style: secondaryTextStyle(
                size: 12, color: Colors.amber, weight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
