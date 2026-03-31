import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../components/location_badge.dart';
import '../../../main.dart';
import '../../../utils/app_common.dart';
import '../../../utils/colors.dart';
import '../../../utils/price_widget.dart';
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

  IconData get _departmentIcon {
    switch (labTestData.department.toLowerCase()) {
      case 'laboratory':
        return Icons.science;
      case 'radiology':
        return Icons.radar;
      default:
        return Icons.local_hospital_outlined;
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
        clipBehavior: Clip.antiAlias,
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
            // Thin top gradient line (2px) using department color
            Container(
              height: 2,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    _departmentColor,
                    _departmentColor.withValues(alpha: 0.4),
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Test Name (larger, bolder) & Department Badge
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          labTestData.name,
                          style: GoogleFonts.outfit(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.3,
                            color: isDarkMode.value ? Colors.white : primaryTextColor,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      8.width,
                      // Department Badge - larger pill with icon
                      if (labTestData.department.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            gradient: LinearGradient(
                              colors: [
                                _departmentColor.withValues(alpha: 0.18),
                                _departmentColor.withValues(alpha: 0.08),
                              ],
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _departmentIcon,
                                size: 14,
                                color: _departmentColor,
                              ),
                              4.width,
                              Text(
                                _departmentLabel,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.1,
                                  color: _departmentColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  8.height,

                  // Code Badge - terminal style
                  if (labTestData.code.isNotEmpty) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: isDarkMode.value
                            ? const Color(0xFF0D1B0D)
                            : const Color(0xFF1A2332),
                      ),
                      child: Text(
                        labTestData.code,
                        style: GoogleFonts.sourceCodePro(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.0,
                          color: isDarkMode.value
                              ? const Color(0xFF4ADE80)
                              : const Color(0xFF6EE7A0),
                        ),
                      ),
                    ),
                    10.height,
                  ],

                  // Sample Type & Turnaround (secondary info pushed down)
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
                  12.height,

                  // Price highlight section & Select Button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
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
                      if (!showSelectButton) const Spacer(),
                      // Price with background pill
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          gradient: LinearGradient(
                            colors: isDarkMode.value
                                ? [
                                    appColorSecondary.withValues(alpha: 0.2),
                                    appColorAccent.withValues(alpha: 0.1),
                                  ]
                                : [
                                    appColorSecondary.withValues(alpha: 0.1),
                                    appColorAccent.withValues(alpha: 0.05),
                                  ],
                          ),
                        ),
                        child: labTestData.defaultPrice > 0
                            ? PriceWidget(
                                price: labTestData.defaultPrice,
                                size: 18,
                                color: isDarkMode.value ? appColorAccent : appColorSecondary,
                              )
                            : Text(
                                locale.value.freeLabel,
                                style: GoogleFonts.outfit(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -0.3,
                                  color: isDarkMode.value ? appColorAccent : appColorSecondary,
                                ),
                              ),
                      ),
                    ],
                  ),
                  if (labTestData.governorate != null) ...[
                    8.height,
                    locationBadge(labTestData.governorate, labTestData.city),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
