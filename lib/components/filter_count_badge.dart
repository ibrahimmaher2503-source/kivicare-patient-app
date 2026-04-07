import 'package:flutter/material.dart';
import 'package:kivicare_patient/utils/colors.dart';

/// FilterCountBadge — A small gradient circle showing active filter count.
///
/// Displayed as a Positioned overlay on the filter icon, using gradientSecondaryStart/End.
/// Only visible when count > 0.
class FilterCountBadge extends StatelessWidget {
  final int count;

  const FilterCountBadge({
    super.key,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    if (count <= 0) {
      return const SizedBox.shrink();
    }

    return Positioned(
      right: -8,
      top: -8,
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              gradientSecondaryStart,
              gradientSecondaryEnd,
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: gradientSecondaryStart.withValues(alpha: 0.3),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Text(
            count.toString(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
