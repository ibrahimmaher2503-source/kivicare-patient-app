import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../utils/app_common.dart';
import '../../../utils/colors.dart';
import '../../../utils/constants.dart';
import '../../radiology/model/radiology_center_model.dart';

class RadiologyCenterCard extends StatelessWidget {
  final RadiologyCenter centerData;

  const RadiologyCenterCard({super.key, required this.centerData});

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
          // Gradient top border (radiology purple)
          Container(
            height: 2,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF7C4DFF), Color(0xFFB388FF)]),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Radiology icon
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF7C4DFF).withValues(alpha: 0.1),
                        const Color(0xFF7C4DFF).withValues(alpha: 0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    _getScanIcon(),
                    size: 24,
                    color: const Color(0xFF7C4DFF),
                  ),
                ),
                16.width,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        centerData.name,
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.3,
                          color: isDarkMode.value ? Colors.white : primaryTextColor,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      8.height,
                      // Scan type badges
                      if (centerData.scanTypes.isNotEmpty)
                        Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          children: centerData.scanTypes.map((type) {
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF7C4DFF), Color(0xFF9C7CFF)],
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                type.toUpperCase(),
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.5,
                                  color: Colors.white,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      if (centerData.governorate != null || centerData.city != null) ...[
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

  IconData _getScanIcon() {
    if (centerData.scanTypes.contains(ScanTypeConst.mri)) return Icons.psychology_outlined;
    if (centerData.scanTypes.contains(ScanTypeConst.ct)) return Icons.scanner_outlined;
    if (centerData.scanTypes.contains(ScanTypeConst.xray)) return Icons.medical_information_outlined;
    return Icons.medical_services_outlined;
  }

  String _buildLocationText() {
    final parts = <String>[];
    if (centerData.city != null && centerData.city!.name.isNotEmpty) {
      parts.add(centerData.city!.name);
    }
    if (centerData.governorate != null && centerData.governorate!.name.isNotEmpty) {
      parts.add(centerData.governorate!.name);
    }
    return parts.join(', ');
  }
}
