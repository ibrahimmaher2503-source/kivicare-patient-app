import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../components/app_scaffold.dart';
import '../../main.dart';
import '../../utils/app_common.dart';
import '../../utils/colors.dart';
import '../../utils/common_base.dart';
import '../../utils/price_widget.dart';
import 'model/lab_test_model.dart';
import 'create_test_order_screen.dart';

class LabTestDetailScreen extends StatelessWidget {
  final LabTest labTestData;

  const LabTestDetailScreen({super.key, required this.labTestData});

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
    return AppScaffoldNew(
      appBartitleText: locale.value.labTestDetails,
      hasLeadingWidget: true,
      appBarVerticalSize: Get.height * 0.12,
      body: AnimatedScrollView(
        listAnimationType: ListAnimationType.FadeIn,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
        children: [
          16.height,

          // Gradient header with test name prominently displayed
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [gradientStart, appColorPrimary, gradientEnd],
                stops: [0.0, 0.5, 1.0],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: appColorPrimary.withValues(alpha: 0.35),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  labTestData.name,
                  style: GoogleFonts.outfit(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                    color: Colors.white,
                    height: 1.2,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (labTestData.code.isNotEmpty) ...[
                  10.height,
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.white.withValues(alpha: 0.15),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.1),
                      ),
                    ),
                    child: Text(
                      labTestData.code,
                      style: GoogleFonts.sourceCodePro(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.0,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ),
                ],
                // Department badge - large, centered under the test name
                if (labTestData.department.isNotEmpty) ...[
                  14.height,
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.white.withValues(alpha: 0.15),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.1),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _departmentIcon,
                          size: 16,
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                        8.width,
                        Text(
                          _departmentLabel,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.3,
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          20.height,

          // Details Card with icon-labeled rows and glass-style borders
          _buildInfoCard(children: [
            if (labTestData.category != null)
              _buildInfoRow(
                icon: Icons.category_outlined,
                label: locale.value.labTestCategories,
                value: labTestData.category!.name,
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
          ]),

          // Price section - standout section with gradient background
          16.height,
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDarkMode.value
                    ? [
                        appColorSecondary.withValues(alpha: 0.2),
                        appColorAccent.withValues(alpha: 0.1),
                      ]
                    : [
                        appColorSecondary.withValues(alpha: 0.08),
                        appColorAccent.withValues(alpha: 0.04),
                      ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDarkMode.value
                    ? appColorSecondary.withValues(alpha: 0.2)
                    : appColorSecondary.withValues(alpha: 0.15),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [gradientSecondaryStart, gradientSecondaryEnd],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.payments_outlined, size: 22, color: Colors.white),
                ),
                16.width,
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      locale.value.defaultPrice,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        letterSpacing: 0.1,
                        color: secondaryTextColor,
                      ),
                    ),
                    4.height,
                    labTestData.defaultPrice > 0
                        ? PriceWidget(
                            price: labTestData.defaultPrice,
                            size: 28,
                            color: isDarkMode.value ? appColorAccent : appColorSecondary,
                          )
                        : Text(
                            locale.value.freeLabel,
                            style: GoogleFonts.outfit(
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.3,
                              color: isDarkMode.value ? appColorAccent : appColorSecondary,
                            ),
                          ),
                  ],
                ),
              ],
            ),
          ),

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

          // Preparation Instructions - highlighted callout box
          if (labTestData.preparationInstructions.isNotEmpty) ...[
            16.height,
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDarkMode.value
                      ? [
                          const Color(0xFF3D2E00).withValues(alpha: 0.5),
                          const Color(0xFF2D2200).withValues(alpha: 0.3),
                        ]
                      : [
                          const Color(0xFFFFF8E1),
                          const Color(0xFFFFF3CD),
                        ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDarkMode.value
                      ? const Color(0xFFFFB300).withValues(alpha: 0.2)
                      : const Color(0xFFFFB300).withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFB300).withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.warning_amber_rounded,
                          size: 18,
                          color: Color(0xFFFF8F00),
                        ),
                      ),
                      10.width,
                      Text(
                        locale.value.preparationInstructions,
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.3,
                          color: isDarkMode.value
                              ? const Color(0xFFFFD54F)
                              : const Color(0xFF6D4C00),
                        ),
                      ),
                    ],
                  ),
                  12.height,
                  Text(
                    labTestData.preparationInstructions,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      letterSpacing: 0.1,
                      height: 1.5,
                      color: isDarkMode.value
                          ? const Color(0xFFFFE082)
                          : const Color(0xFF5D4037),
                    ),
                  ),
                ],
              ),
            ),
          ],

          28.height,

          // Add to Order Button - gradient with pulsing glow
          _AddToOrderButton(
            onTap: () {
              doIfLoggedIn(() {
                Get.to(() => CreateTestOrderScreen(), arguments: {'labTest': labTestData});
              });
            },
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
        border: Border.all(
          color: isDarkMode.value
              ? glassStrokeDark
              : appColorSecondary.withValues(alpha: 0.08),
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
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: isDarkMode.value
                  ? appColorSecondary.withValues(alpha: 0.15)
                  : appColorSecondary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: appColorSecondary),
          ),
          12.width,
          Expanded(
            child: Column(
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

/// Add to Order button with a subtle pulsing glow
class _AddToOrderButton extends StatefulWidget {
  final VoidCallback onTap;

  const _AddToOrderButton({required this.onTap});

  @override
  State<_AddToOrderButton> createState() => _AddToOrderButtonState();
}

class _AddToOrderButtonState extends State<_AddToOrderButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    _glowAnimation = Tween<double>(begin: 0.2, end: 0.5).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return GestureDetector(
          onTap: widget.onTap,
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
                  color: appColorSecondary.withValues(alpha: _glowAnimation.value),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.add_shopping_cart, size: 20, color: Colors.white),
                  8.width,
                  Text(
                    locale.value.addTest,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.1,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
