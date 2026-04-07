import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../main.dart';
import '../../../utils/app_common.dart';
import '../../../utils/colors.dart';
import '../../../utils/constants.dart';
import '../model/hospital_model.dart';

class DepartmentCard extends StatelessWidget {
  final IcuDepartment departmentData;
  final VoidCallback? onTap;

  const DepartmentCard({
    super.key,
    required this.departmentData,
    this.onTap,
  });

  Color get _specialtyColor {
    switch (departmentData.specialtyType.toLowerCase()) {
      case IcuSpecialtyConst.cardiac:
        return const Color(0xFFE53935);
      case IcuSpecialtyConst.neurology:
        return const Color(0xFF9C27B0);
      case IcuSpecialtyConst.pediatric:
        return const Color(0xFF2196F3);
      case IcuSpecialtyConst.neonatal:
        return const Color(0xFFFF9800);
      case IcuSpecialtyConst.burns:
        return const Color(0xFFFF5722);
      case IcuSpecialtyConst.chest:
        return appColorSecondary;
      case IcuSpecialtyConst.surgical:
        return appColorPrimary;
      case IcuSpecialtyConst.general:
        return const Color(0xFF4CAF50);
      default:
        return appColorPrimary;
    }
  }

  Color get _bedAvailabilityColor {
    return departmentData.availableBeds > 0
        ? const Color(0xFF4CAF50)
        : const Color(0xFFE53935);
  }

  String get _equipmentLabel {
    switch (departmentData.equipmentLevel.toLowerCase()) {
      case IcuEquipmentLevelConst.basic:
        return 'Basic';
      case IcuEquipmentLevelConst.advanced:
        return 'Advanced';
      case IcuEquipmentLevelConst.full:
        return 'Full';
      default:
        return departmentData.equipmentLevel;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDarkMode.value ? surfaceElevatedDark : surfaceElevated,
          borderRadius: BorderRadius.circular(16),
          border: Border(
            left: BorderSide(color: _specialtyColor, width: 3),
          ),
          boxShadow: [
            BoxShadow(
              color: isDarkMode.value ? softShadowColorDark : softShadowColor,
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Name and specialty badge row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    departmentData.name,
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.3,
                      color: isDarkMode.value ? Colors.white : primaryTextColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                8.width,
                _buildSpecialtyBadge(),
              ],
            ),
            10.height,

            // Bed availability row
            Row(
              children: [
                Icon(Icons.bed_outlined, size: 16, color: _bedAvailabilityColor),
                6.width,
                Text(
                  '${departmentData.availableBeds}/${departmentData.totalBeds} ${locale.value.availableBedsLabel}',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.1,
                    color: _bedAvailabilityColor,
                  ),
                ),
              ],
            ),
            10.height,

            // Equipment indicators row
            Row(
              children: [
                // Ventilator indicator
                if (departmentData.hasVentilator) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: isDarkMode.value
                          ? urgencyCriticalColor.withValues(alpha: 0.2)
                          : urgencyCriticalColor.withValues(alpha: 0.08),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.air_rounded, size: 12, color: urgencyCriticalColor),
                        4.width,
                        Text(
                          locale.value.needsVentilator,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.1,
                            color: urgencyCriticalColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  8.width,
                ],

                // Oxygen indicator
                if (departmentData.hasOxygen) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: isDarkMode.value
                          ? urgencyStandardColor.withValues(alpha: 0.2)
                          : urgencyStandardColor.withValues(alpha: 0.08),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.masks_rounded, size: 12, color: urgencyStandardColor),
                        4.width,
                        Text(
                          locale.value.needsOxygen,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.1,
                            color: urgencyStandardColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
            10.height,

            // Equipment level and daily price row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Equipment level badge
                if (departmentData.equipmentLevel.isNotEmpty)
                  _buildEquipmentBadge(),

                // Daily price
                if (departmentData.dailyPrice.isNotEmpty)
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [gradientSecondaryStart, gradientSecondaryEnd],
                    ).createShader(bounds),
                    child: Text(
                      '${departmentData.dailyPrice} ${locale.value.dailyPriceLabel}',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.1,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecialtyBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [
            _specialtyColor.withValues(alpha: 0.18),
            _specialtyColor.withValues(alpha: 0.10),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: _specialtyColor.withValues(alpha: 0.15),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        departmentData.specialtyType.capitalizeFirstLetter(),
        style: GoogleFonts.plusJakartaSans(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.1,
          color: _specialtyColor,
        ),
      ),
    );
  }

  Widget _buildEquipmentBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: isDarkMode.value
            ? appColorPrimary.withValues(alpha: 0.2)
            : appColorPrimary.withValues(alpha: 0.06),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.settings_suggest_outlined, size: 12,
            color: isDarkMode.value ? Colors.white70 : appColorPrimary),
          4.width,
          Text(
            '${locale.value.equipmentLevelLabel}: $_equipmentLabel',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.1,
              color: isDarkMode.value ? Colors.white70 : appColorPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
