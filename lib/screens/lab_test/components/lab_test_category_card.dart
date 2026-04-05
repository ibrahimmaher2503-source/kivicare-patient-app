import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../utils/app_common.dart';
import '../../../utils/colors.dart';
import '../model/lab_test_category_model.dart';
import '../lab_test_list_screen.dart';
import '../radiology_centers_screen.dart';

class LabTestCategoryCard extends StatefulWidget {
  final LabTestCategory categoryData;
  final VoidCallback? onTap;

  const LabTestCategoryCard({
    super.key,
    required this.categoryData,
    this.onTap,
  });

  @override
  State<LabTestCategoryCard> createState() => _LabTestCategoryCardState();
}

class _LabTestCategoryCardState extends State<LabTestCategoryCard>
    with SingleTickerProviderStateMixin {
  double _scale = 1.0;
  late AnimationController _shimmerController;
  late Animation<double> _shimmerAnimation;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _shimmerAnimation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.easeInOut),
    );
    // Run shimmer once on first render
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _shimmerController.forward();
    });
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  IconData get _categoryIcon {
    switch (widget.categoryData.slug.toLowerCase()) {
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
      onTapDown: (_) => setState(() => _scale = 0.95),
      onTapUp: (_) {
        setState(() => _scale = 1.0);
        final tap = widget.onTap ?? () {
          hideKeyboard(context);
          if (widget.categoryData.slug.contains('radiology')) {
            Get.to(() => const RadiologyCentersScreen());
          } else {
            Get.to(() => LabTestListScreen(), arguments: {'categoryId': widget.categoryData.id});
          }
        };
        tap();
      },
      onTapCancel: () => setState(() => _scale = 1.0),
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Main card with frosted glass effect
            AnimatedBuilder(
              animation: _shimmerController,
              builder: (context, child) {
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        isDarkMode.value
                            ? surfaceElevatedDark.withValues(alpha: 0.85)
                            : surfaceElevated.withValues(alpha: 0.9),
                        isDarkMode.value
                            ? const Color(0xFF1E2A3E).withValues(alpha: 0.85)
                            : const Color(0xFFF0F4F8).withValues(alpha: 0.9),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      width: 1,
                      color: isDarkMode.value
                          ? glassStrokeDark
                          : appColorSecondary.withValues(alpha: 0.12),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isDarkMode.value ? softShadowColorDark : softShadowColor,
                        blurRadius: 20,
                        offset: const Offset(0, 6),
                      ),
                      BoxShadow(
                        color: isDarkMode.value
                            ? Colors.transparent
                            : appColorSecondary.withValues(alpha: 0.04),
                        blurRadius: 40,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      // Shimmer overlay
                      if (_shimmerController.isAnimating)
                        Positioned.fill(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: CustomPaint(
                              painter: _ShimmerPainter(
                                progress: _shimmerAnimation.value,
                                color: isDarkMode.value
                                    ? Colors.white.withValues(alpha: 0.06)
                                    : Colors.white.withValues(alpha: 0.4),
                              ),
                            ),
                          ),
                        ),
                      // Content
                      child!,
                    ],
                  ),
                );
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Icon with radial gradient glow
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // Radial glow behind icon
                      Positioned(
                        left: -6,
                        top: -6,
                        child: Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                appColorAccent.withValues(alpha: isDarkMode.value ? 0.25 : 0.15),
                                appColorAccent.withValues(alpha: 0.0),
                              ],
                            ),
                          ),
                        ),
                      ),
                      // Icon container (48x48)
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
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
                        child: Icon(
                          _categoryIcon,
                          size: 24,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  10.height,

                  // Category Name with text gradient on light mode
                  _buildCategoryName(),

                  if (widget.categoryData.description.isNotEmpty) ...[
                    4.height,
                    Text(
                      widget.categoryData.description,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        letterSpacing: 0.1,
                        color: secondaryTextColor,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],

                  const Spacer(),
                ],
              ),
            ),

            // Test count badge - overlay in top-right corner
            Positioned(
              top: -6,
              right: -4,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [gradientSecondaryStart, gradientSecondaryEnd],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: appColorSecondary.withValues(alpha: 0.35),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  '${widget.categoryData.testCount}',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.1,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryName() {
    final text = widget.categoryData.name;
    if (isDarkMode.value) {
      return Text(
        text,
        style: GoogleFonts.outfit(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.3,
          color: Colors.white,
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      );
    }

    // Gradient text for light mode (navy -> teal)
    return ShaderMask(
      shaderCallback: (bounds) => const LinearGradient(
        colors: [appColorPrimary, appColorSecondary],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(bounds),
      blendMode: BlendMode.srcIn,
      child: Text(
        text,
        style: GoogleFonts.outfit(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.3,
          color: Colors.white,
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

class _ShimmerPainter extends CustomPainter {
  final double progress;
  final Color color;

  _ShimmerPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.transparent,
          color,
          Colors.transparent,
        ],
        stops: [
          (progress - 0.3).clamp(0.0, 1.0),
          progress.clamp(0.0, 1.0),
          (progress + 0.3).clamp(0.0, 1.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
  }

  @override
  bool shouldRepaint(_ShimmerPainter oldDelegate) => oldDelegate.progress != progress;
}
