import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../utils/app_common.dart';
import '../../../utils/colors.dart';

/// A selectable chip widget displaying a time slot label (e.g., "9:00 AM").
///
/// Selected state: gradient background (teal), white text.
/// Unselected state: elevated surface with border, dark text.
class TimeSlotChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const TimeSlotChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(colors: [gradientSecondaryStart, gradientSecondaryEnd])
              : null,
          color: isSelected ? null : (isDarkMode.value ? surfaceElevatedDark : surfaceElevated),
          borderRadius: BorderRadius.circular(12),
          border: isSelected
              ? null
              : Border.all(
                  color: isDarkMode.value ? borderColorDark : borderColor,
                  width: 1,
                ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: appColorSecondary.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [
                  BoxShadow(
                    color: isDarkMode.value ? softShadowColorDark : softShadowColor,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 250),
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            letterSpacing: 0.1,
            color: isSelected
                ? Colors.white
                : (isDarkMode.value ? Colors.white : primaryTextColor),
          ),
          child: Text(label),
        ),
      ),
    );
  }
}
