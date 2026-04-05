import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../main.dart';
import '../../../utils/colors.dart';
import '../../../utils/common_base.dart';
import '../../../utils/app_common.dart';
import '../../../utils/view_all_label_component.dart';
import '../../nurse/nurse_list_screen.dart';
import '../../nurse/nurse_request_list_screen.dart';
import '../../lab_test/lab_test_categories_screen.dart';
import '../../lab_test/labs_list_screen.dart';
import '../../lab_test/radiology_centers_screen.dart';
import '../../lab_test/test_order_list_screen.dart';
import '../../request_service/request_service_list_screen.dart';
import '../../icu/hospital_list_screen.dart';
import '../../icu/admission_list_screen.dart';
import '../../call_booking/call_doctor_list_screen.dart';
import '../../call_booking/call_booking_list_screen.dart';
import '../../independent_booking/independent_doctor_list_screen.dart';
import '../../independent_booking/independent_booking_list_screen.dart';
import '../../search/search_hub_screen.dart';

/// Custom painter for decorative geometric shapes on service cards
class _CardDecorationPainter extends CustomPainter {
  final Color color;

  _CardDecorationPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    // Top-right circle
    canvas.drawCircle(
      Offset(size.width * 0.85, size.height * 0.15),
      size.width * 0.25,
      paint,
    );

    // Bottom-left circle
    canvas.drawCircle(
      Offset(size.width * 0.1, size.height * 0.9),
      size.width * 0.2,
      paint,
    );

    // Diagonal line
    final linePaint = Paint()
      ..color = color.withValues(alpha: 0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    canvas.drawLine(
      Offset(size.width * 0.6, 0),
      Offset(size.width, size.height * 0.4),
      linePaint,
    );

    // Small dot
    final dotPaint = Paint()
      ..color = color.withValues(alpha: 0.12)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
      Offset(size.width * 0.2, size.height * 0.25),
      3,
      dotPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class QuickServicesComponent extends StatelessWidget {
  const QuickServicesComponent({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ViewAllLabel(
          label: locale.value.quickServices,
          isShowAll: false,
        ).paddingOnly(left: 16, right: 8),
        8.height,

        /// Navigation cards row
        Obx(
          () => SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _buildServiceCard(
                  context,
                  icon: Icons.search_rounded,
                  label: locale.value.searchProviders,
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF1565C0),
                      const Color(0xFF1976D2).withValues(alpha: 0.85),
                      const Color(0xFF42A5F5).withValues(alpha: 0.65),
                    ],
                    stops: const [0.0, 0.5, 1.0],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  delayIndex: 0,
                  onTap: () {
                    Get.to(() => const SearchHubScreen());
                  },
                ),
                16.width,
                _buildServiceCard(
                  context,
                  icon: Icons.person_pin_rounded,
                  label: locale.value.bookADoctor,
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF00695C),
                      const Color(0xFF00897B).withValues(alpha: 0.85),
                      const Color(0xFF26A69A).withValues(alpha: 0.65),
                    ],
                    stops: const [0.0, 0.5, 1.0],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  delayIndex: 1,
                  onTap: () {
                    Get.to(() => const IndependentDoctorListScreen());
                  },
                ),
                16.width,
                _buildServiceCard(
                  context,
                  icon: Icons.video_call_rounded,
                  label: locale.value.videoConsult,
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF3949AB),
                      const Color(0xFF5C6BC0).withValues(alpha: 0.85),
                      const Color(0xFF7E57C2).withValues(alpha: 0.65),
                    ],
                    stops: const [0.0, 0.5, 1.0],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  delayIndex: 2,
                  onTap: () {
                    Get.to(() => const CallDoctorListScreen());
                  },
                ),
                16.width,
                _buildServiceCard(
                  context,
                  icon: Icons.medical_services_rounded,
                  label: locale.value.requestNurse,
                  gradient: const LinearGradient(
                    colors: [gradientSecondaryStart, Color(0xFF059E9A), gradientSecondaryEnd],
                    stops: [0.0, 0.5, 1.0],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  delayIndex: 3,
                  onTap: () {
                    Get.to(() => NurseListScreen());
                  },
                ),
                16.width,
                _buildServiceCard(
                  context,
                  icon: Icons.biotech_rounded,
                  label: locale.value.labTests,
                  gradient: const LinearGradient(
                    colors: [gradientStart, Color(0xFF0A2F65), gradientEnd],
                    stops: [0.0, 0.5, 1.0],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  delayIndex: 4,
                  onTap: () {
                    Get.to(() => LabTestCategoriesScreen());
                  },
                ),
                16.width,
                _buildServiceCard(
                  context,
                  icon: Icons.science_outlined,
                  label: locale.value.labs,
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF1565C0),
                      const Color(0xFF2196F3).withValues(alpha: 0.85),
                      const Color(0xFF42A5F5).withValues(alpha: 0.65),
                    ],
                    stops: const [0.0, 0.5, 1.0],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  delayIndex: 5,
                  onTap: () {
                    Get.to(() => const LabsListScreen());
                  },
                ),
                16.width,
                _buildServiceCard(
                  context,
                  icon: Icons.medical_information_outlined,
                  label: locale.value.radiologyCenters,
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF5E35B1),
                      const Color(0xFF7C4DFF).withValues(alpha: 0.85),
                      const Color(0xFF9C7CFF).withValues(alpha: 0.65),
                    ],
                    stops: const [0.0, 0.5, 1.0],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  delayIndex: 6,
                  onTap: () {
                    Get.to(() => const RadiologyCentersScreen());
                  },
                ),
                16.width,
                _buildServiceCard(
                  context,
                  icon: Icons.room_service_rounded,
                  label: locale.value.requestService,
                  gradient: LinearGradient(
                    colors: [
                      appColorSecondary,
                      appColorSecondary.withValues(alpha: 0.85),
                      appColorSecondary.withValues(alpha: 0.65),
                    ],
                    stops: const [0.0, 0.5, 1.0],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  delayIndex: 7,
                  onTap: () {
                    Get.to(() => RequestServiceListScreen());
                  },
                ),
                16.width,
                _buildServiceCard(
                  context,
                  icon: Icons.local_hospital_rounded,
                  label: locale.value.icuAdmissions,
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFFC62828),
                      const Color(0xFFE53935).withValues(alpha: 0.85),
                      const Color(0xFFEF5350).withValues(alpha: 0.65),
                    ],
                    stops: const [0.0, 0.5, 1.0],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  delayIndex: 8,
                  onTap: () {
                    Get.to(() => HospitalListScreen());
                  },
                ),
              ],
            ),
          ),
        ),
        24.height,

        /// My Requests section
        ViewAllLabel(
          label: locale.value.myRequests,
          isShowAll: false,
        ).paddingOnly(left: 16, right: 8),
        8.height,
        Obx(
          () => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                _buildRequestTile(
                  context,
                  icon: Icons.medical_services_outlined,
                  label: locale.value.myNurseRequests,
                  accentColor: appColorSecondary,
                  delayIndex: 0,
                  onTap: () {
                    doIfLoggedIn(() {
                      Get.to(() => NurseRequestListScreen());
                    });
                  },
                ),
                12.height,
                _buildRequestTile(
                  context,
                  icon: Icons.science_outlined,
                  label: locale.value.myTestOrders,
                  accentColor: appColorPrimary,
                  delayIndex: 1,
                  onTap: () {
                    doIfLoggedIn(() {
                      Get.to(() => TestOrderListScreen());
                    });
                  },
                ),
                12.height,
                _buildRequestTile(
                  context,
                  icon: Icons.miscellaneous_services_outlined,
                  label: locale.value.myServiceRequests,
                  accentColor: appColorAccent,
                  delayIndex: 2,
                  onTap: () {
                    doIfLoggedIn(() {
                      Get.to(() => RequestServiceListScreen());
                    });
                  },
                ),
                12.height,
                _buildRequestTile(
                  context,
                  icon: Icons.local_hospital_outlined,
                  label: locale.value.myIcuRequests,
                  accentColor: urgencyCriticalColor,
                  delayIndex: 3,
                  onTap: () {
                    doIfLoggedIn(() {
                      Get.to(() => AdmissionListScreen());
                    });
                  },
                ),
                12.height,
                _buildRequestTile(
                  context,
                  icon: Icons.video_call_outlined,
                  label: locale.value.myVideoConsults,
                  accentColor: callTypeVideoColor,
                  delayIndex: 4,
                  onTap: () {
                    doIfLoggedIn(() {
                      Get.to(() => const CallBookingListScreen());
                    });
                  },
                ),
                12.height,
                _buildRequestTile(
                  context,
                  icon: Icons.person_pin_outlined,
                  label: locale.value.myDoctorAppointments,
                  accentColor: const Color(0xFF00897B),
                  delayIndex: 5,
                  onTap: () {
                    doIfLoggedIn(() {
                      Get.to(() => const IndependentBookingListScreen());
                    });
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Builds a gradient navigation card with decorative elements and floating icon animation
  Widget _buildServiceCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Gradient gradient,
    required VoidCallback onTap,
    int delayIndex = 0,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 500 + (delayIndex * 150)),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: Get.width / 3 - 24,
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 8),
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: isDarkMode.value ? softShadowColorDark : softShadowColorMedium,
                blurRadius: 20,
                offset: const Offset(0, 8),
                spreadRadius: 2,
              ),
            ],
          ),
          child: Stack(
            children: [
              // Decorative geometric background shapes
              Positioned.fill(
                child: CustomPaint(
                  painter: _CardDecorationPainter(color: Colors.white),
                ),
              ),
              // Main content
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Frosted glass ring with glow effect
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.25),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white.withValues(alpha: 0.15),
                            blurRadius: 16,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: glassTintLight,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: glassStrokeLight,
                            width: 1.5,
                          ),
                        ),
                        // Floating animation on the icon
                        child: TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0.0, end: 1.0),
                          duration: const Duration(milliseconds: 2000),
                          builder: (context, animValue, child) {
                            // Use a sine-like curve for gentle float
                            return Transform.translate(
                              offset: Offset(0, -3 * (0.5 + 0.5 * ((2 * animValue - 1).abs() * 2 - 1).abs() - 0.5)),
                              child: child,
                            );
                          },
                          child: Icon(icon, color: Colors.white, size: 28),
                        ),
                      ),
                    ),
                    14.height,
                    Text(
                      label,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.1,
                        color: Colors.white,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds a list tile for "My Requests" with staggered entrance, accent dot, and animated chevron
  Widget _buildRequestTile(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required Color accentColor,
    int delayIndex = 0,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 400 + (delayIndex * 120)),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(30 * (1 - value), 0),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: isDarkMode.value ? surfaceElevatedDark : surfaceElevated,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isDarkMode.value
                  ? Colors.white.withValues(alpha: 0.06)
                  : appColorPrimary.withValues(alpha: 0.06),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: isDarkMode.value ? softShadowColorDark : softShadowColor,
                blurRadius: 12,
                offset: const Offset(0, 4),
                spreadRadius: 0,
              ),
            ],
          ),
          child: Row(
            children: [
              // Colored accent dot
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: accentColor,
                  boxShadow: [
                    BoxShadow(
                      color: accentColor.withValues(alpha: 0.4),
                      blurRadius: 6,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
              12.width,
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isDarkMode.value ? glassTintDark : lightSecondaryColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: appColorSecondary, size: 22),
              ),
              12.width,
              Text(
                label,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.1,
                  color: isDarkMode.value ? Colors.white : primaryTextColor,
                ),
              ).expand(),
              // Animated chevron with slight slide on build
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeOut,
                builder: (context, val, child) {
                  return Transform.translate(
                    offset: Offset(4 * (1 - val), 0),
                    child: Opacity(opacity: val, child: child),
                  );
                },
                child: Icon(
                  Icons.chevron_right_rounded,
                  color: isDarkMode.value ? Colors.white54 : dividerColor,
                  size: 22,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
