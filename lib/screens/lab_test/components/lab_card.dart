import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../utils/app_common.dart';
import '../../../utils/colors.dart';
import '../model/lab_model.dart';

class LabCard extends StatelessWidget {
  final Lab labData;

  const LabCard({super.key, required this.labData});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDarkMode.value ? surfaceElevatedDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDarkMode.value ? softShadowColorDark : softShadowColor,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Gradient top border
          Container(
            height: 2,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [gradientStart, gradientEnd]),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Lab icon
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        appColorPrimary.withValues(alpha: 0.1),
                        appColorPrimary.withValues(alpha: 0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    Icons.science_outlined,
                    size: 24,
                    color: appColorPrimary,
                  ),
                ),
                16.width,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        labData.name,
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.3,
                          color: isDarkMode.value ? Colors.white : primaryTextColor,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (labData.governorate != null || labData.city != null) ...[
                        6.height,
                        Row(
                          children: [
                            Icon(
                              Icons.location_on_outlined,
                              size: 14,
                              color: secondaryTextColor,
                            ),
                            4.width,
                            Expanded(
                              child: Text(
                                _buildLocationText(),
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 13,
                                  letterSpacing: 0.1,
                                  color: secondaryTextColor,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _buildLocationText() {
    final parts = <String>[];
    if (labData.city != null && labData.city!.name.isNotEmpty) {
      parts.add(labData.city!.name);
    }
    if (labData.governorate != null && labData.governorate!.name.isNotEmpty) {
      parts.add(labData.governorate!.name);
    }
    return parts.join(', ');
  }
}
