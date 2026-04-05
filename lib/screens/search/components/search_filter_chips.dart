import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../utils/app_common.dart';
import '../../../utils/colors.dart';

class SearchFilterChips extends StatelessWidget {
  final List<Map<String, String>> filters;
  final String selectedKey;
  final ValueChanged<String> onChanged;

  const SearchFilterChips({
    super.key,
    required this.filters,
    required this.selectedKey,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedWrap(
      spacing: 12,
      runSpacing: 8,
      children: List.generate(filters.length, (index) {
        final filter = filters[index];
        final isSelected = selectedKey == filter['key'];
        return GestureDetector(
          onTap: () => onChanged(filter['key']!),
          child: AnimatedScale(
            scale: isSelected ? 1.05 : 1.0,
            duration: const Duration(milliseconds: 200),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? const LinearGradient(colors: [gradientStart, gradientEnd])
                    : null,
                color: isSelected ? null : (isDarkMode.value ? surfaceElevatedDark : surfaceElevated),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: isSelected
                        ? appColorPrimary.withValues(alpha: 0.3)
                        : (isDarkMode.value ? softShadowColorDark : softShadowColor),
                    blurRadius: isSelected ? 12 : 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                filter['label']!,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.1,
                  color: isSelected
                      ? Colors.white
                      : (isDarkMode.value ? Colors.white70 : primaryTextColor),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
