import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../components/app_scaffold.dart';
import '../../main.dart';
import '../../utils/app_common.dart';
import '../../utils/colors.dart';
import 'model/lab_test_model.dart';
import 'create_test_order_screen.dart';

class LabTestDetailScreen extends StatelessWidget {
  final LabTest labTestData;

  const LabTestDetailScreen({super.key, required this.labTestData});

  @override
  Widget build(BuildContext context) {
    return AppScaffoldNew(
      appBartitleText: locale.value.labTestDetails,
      hasLeadingWidget: true,
      appBarVerticalSize: Get.height * 0.12,
      body: AnimatedScrollView(
        listAnimationType: ListAnimationType.FadeIn,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        children: [
          16.height,

          // Test Name Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [gradientStart, gradientEnd],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: appColorPrimary.withValues(alpha: 0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  labTestData.name,
                  style: GoogleFonts.outfit(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                    color: Colors.white,
                  ),
                ),
                if (labTestData.code.isNotEmpty) ...[
                  8.height,
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.white.withValues(alpha: 0.2),
                    ),
                    child: Text(
                      labTestData.code,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          20.height,

          // Details Card
          _buildInfoCard(children: [
            if (labTestData.category != null)
              _buildInfoRow(
                icon: Icons.category_outlined,
                label: locale.value.labTestCategories,
                value: labTestData.category!.name,
              ),
            if (labTestData.department.isNotEmpty)
              _buildInfoRow(
                icon: Icons.local_hospital_outlined,
                label: locale.value.department,
                value: labTestData.department.toLowerCase() == 'laboratory'
                    ? locale.value.laboratory
                    : labTestData.department.toLowerCase() == 'radiology'
                        ? locale.value.radiology
                        : labTestData.department,
              ),
            if (labTestData.sampleType.isNotEmpty)
              _buildInfoRow(
                icon: Icons.science_outlined,
                label: locale.value.sampleType,
                value: labTestData.sampleType,
              ),
            if (labTestData.turnaroundTime.isNotEmpty)
              _buildInfoRow(
                icon: Icons.schedule_outlined,
                label: locale.value.turnaroundTime,
                value: labTestData.turnaroundTime,
              ),
            if (labTestData.defaultPrice > 0)
              _buildInfoRow(
                icon: Icons.payments_outlined,
                label: locale.value.defaultPrice,
                value: '\$${labTestData.defaultPrice.toStringAsFixed(2)}',
                valueColor: appColorSecondary,
              ),
          ]),

          // Description
          if (labTestData.description.isNotEmpty) ...[
            16.height,
            _buildInfoCard(children: [
              _buildSectionTitle(locale.value.description),
              8.height,
              Text(
                labTestData.description,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  letterSpacing: 0.1,
                  height: 1.5,
                  color: isDarkMode.value ? Colors.white70 : secondaryTextColor,
                ),
              ),
            ]),
          ],

          // Preparation Instructions
          if (labTestData.preparationInstructions.isNotEmpty) ...[
            16.height,
            _buildInfoCard(children: [
              _buildSectionTitle(locale.value.preparationInstructions),
              8.height,
              Text(
                labTestData.preparationInstructions,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  letterSpacing: 0.1,
                  height: 1.5,
                  color: isDarkMode.value ? Colors.white70 : secondaryTextColor,
                ),
              ),
            ]),
          ],

          24.height,

          // Add to Order Button
          GestureDetector(
            onTap: () {
              Get.to(() => CreateTestOrderScreen(), arguments: {'labTest': labTestData});
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [gradientSecondaryStart, gradientSecondaryEnd],
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: appColorSecondary.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  locale.value.addTest,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.1,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          16.height,
        ],
      ).paddingTop(16),
    );
  }

  Widget _buildInfoCard({required List<Widget> children}) {
    return Container(
      width: double.infinity,
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
        children: children,
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: appColorSecondary),
          12.width,
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  letterSpacing: 0.1,
                  color: secondaryTextColor,
                ),
              ),
              2.height,
              Text(
                value,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.1,
                  color: valueColor ?? (isDarkMode.value ? Colors.white : primaryTextColor),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.outfit(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.3,
        color: isDarkMode.value ? Colors.white : primaryTextColor,
      ),
    );
  }
}
