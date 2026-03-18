import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../main.dart';
import '../../../utils/app_common.dart';
import '../../../utils/colors.dart';
import '../model/lab_test_category_model.dart';
import '../lab_test_list_screen.dart';

class LabTestCategoryCard extends StatelessWidget {
  final LabTestCategory categoryData;
  final VoidCallback? onTap;

  const LabTestCategoryCard({
    super.key,
    required this.categoryData,
    this.onTap,
  });

  IconData get _categoryIcon {
    switch (categoryData.slug.toLowerCase()) {
      case 'hematology':
        return Icons.bloodtype_outlined;
      case 'biochemistry':
        return Icons.science_outlined;
      case 'microbiology':
        return Icons.biotech_outlined;
      case 'radiology':
        return Icons.radio_button_checked_outlined;
      case 'pathology':
        return Icons.remove_red_eye_outlined;
      case 'immunology':
        return Icons.shield_outlined;
      case 'cardiology':
        return Icons.monitor_heart_outlined;
      case 'urology':
        return Icons.water_drop_outlined;
      default:
        return Icons.medical_services_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap ?? () {
        hideKeyboard(context);
        Get.to(() => LabTestListScreen(), arguments: {'categoryId': categoryData.id});
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              isDarkMode.value ? surfaceElevatedDark : surfaceElevated,
              isDarkMode.value ? const Color(0xFF1E2A3E) : const Color(0xFFF0F4F8),
            ],
          ),
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
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Icon with gradient background
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [gradientSecondaryStart, gradientSecondaryEnd],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _categoryIcon,
                size: 24,
                color: Colors.white,
              ),
            ),
            12.height,

            // Category Name
            Text(
              categoryData.name,
              style: GoogleFonts.outfit(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.3,
                color: isDarkMode.value ? Colors.white : primaryTextColor,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            if (categoryData.description.isNotEmpty) ...[
              4.height,
              Text(
                categoryData.description,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  letterSpacing: 0.1,
                  color: secondaryTextColor,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],

            8.height,

            // Test Count Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  colors: [
                    appColorSecondary.withValues(alpha: 0.15),
                    appColorSecondary.withValues(alpha: 0.08),
                  ],
                ),
              ),
              child: Text(
                '${categoryData.testCount} ${locale.value.testCount}',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.1,
                  color: appColorSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
