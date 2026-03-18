import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../main.dart';
import '../../../utils/app_common.dart';
import '../../../utils/colors.dart';
import '../model/lab_test_model.dart';
import '../lab_test_detail_screen.dart';

class LabTestCard extends StatelessWidget {
  final LabTest labTestData;
  final VoidCallback? onTap;
  final bool showSelectButton;
  final VoidCallback? onSelect;

  const LabTestCard({
    super.key,
    required this.labTestData,
    this.onTap,
    this.showSelectButton = false,
    this.onSelect,
  });

  Color get _departmentColor {
    switch (labTestData.department.toLowerCase()) {
      case 'laboratory':
        return labStatusProcessingColor;
      case 'radiology':
        return labStatusSampleCollectedColor;
      default:
        return appColorSecondary;
    }
  }

  String get _departmentLabel {
    switch (labTestData.department.toLowerCase()) {
      case 'laboratory':
        return locale.value.laboratory;
      case 'radiology':
        return locale.value.radiology;
      default:
        return labTestData.department;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap ?? () {
        hideKeyboard(context);
        Get.to(() => LabTestDetailScreen(labTestData: labTestData));
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDarkMode.value ? surfaceElevatedDark : surfaceElevated,
          borderRadius: BorderRadius.circular(16),
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
            // Test Name & Code
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        labTestData.name,
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.3,
                          color: isDarkMode.value ? Colors.white : primaryTextColor,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      6.height,
                      // Code Badge
                      if (labTestData.code.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: isDarkMode.value
                                ? appColorPrimary.withValues(alpha: 0.2)
                                : appColorPrimary.withValues(alpha: 0.08),
                          ),
                          child: Text(
                            labTestData.code,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                              color: appColorPrimary,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                8.width,
                // Department Badge
                if (labTestData.department.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: LinearGradient(
                        colors: [
                          _departmentColor.withValues(alpha: 0.15),
                          _departmentColor.withValues(alpha: 0.08),
                        ],
                      ),
                    ),
                    child: Text(
                      _departmentLabel,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.1,
                        color: _departmentColor,
                      ),
                    ),
                  ),
              ],
            ),
            12.height,

            // Sample Type, Price, Turnaround
            Row(
              children: [
                if (labTestData.sampleType.isNotEmpty) ...[
                  Icon(Icons.science_outlined, size: 14, color: secondaryTextColor),
                  4.width,
                  Flexible(
                    child: Text(
                      labTestData.sampleType,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        letterSpacing: 0.1,
                        color: secondaryTextColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  12.width,
                ],
                if (labTestData.turnaroundTime.isNotEmpty) ...[
                  Icon(Icons.schedule_outlined, size: 14, color: secondaryTextColor),
                  4.width,
                  Text(
                    labTestData.turnaroundTime,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      letterSpacing: 0.1,
                      color: secondaryTextColor,
                    ),
                  ),
                ],
              ],
            ),
            8.height,

            // Price & Select Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (labTestData.defaultPrice > 0)
                  Text(
                    '\$${labTestData.defaultPrice.toStringAsFixed(2)}',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.1,
                      color: isDarkMode.value ? Colors.white : primaryTextColor,
                    ),
                  ),
                if (showSelectButton)
                  GestureDetector(
                    onTap: onSelect,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [gradientSecondaryStart, gradientSecondaryEnd]),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        locale.value.addTest,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
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
}
