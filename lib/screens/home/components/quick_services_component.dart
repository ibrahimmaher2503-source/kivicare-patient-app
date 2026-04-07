import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../main.dart';
import '../../../utils/colors.dart';
import '../../../utils/common_base.dart';
import '../../../utils/app_common.dart';
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
import '../../doctor_visit/doctor_visit_list_screen.dart';
import '../../pharmacy/pharmacy_categories_screen.dart';
import '../../pharmacy/pharmacy_order_list_screen.dart';

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
        // Enhanced section header with gradient accent bar
        Padding(
          padding: const EdgeInsets.only(left: 16, right: 8),
          child: Row(
            children: [
              // Gradient accent bar
              Container(
                width: 4,
                height: 22,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [gradientSecondaryStart, appColorAccent],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              10.width,
              Text(
                locale.value.quickServices,
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.4,
                  color: isDarkMode.value ? Colors.white : primaryTextColor,
                ),
              ).expand(),
            ],
          ),
        ),
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
                _buildServiceCard(
                  context,
                  icon: Icons.home_rounded,
                  label: locale.value.doctorHomeVisit,
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
                  delayIndex: 9,
                  onTap: () {
                    Get.to(() => const DoctorVisitListScreen());
                  },
                ),
                16.width,
                _buildServiceCard(
                  context,
                  icon: Icons.local_pharmacy_rounded,
                  label: locale.value.pharmacyMarketplace,
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF1B5E20),
                      const Color(0xFF2E7D32).withValues(alpha: 0.85),
                      const Color(0xFF43A047).withValues(alpha: 0.65),
                    ],
                    stops: const [0.0, 0.5, 1.0],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  delayIndex: 10,
                  onTap: () {
                    Get.to(() => const PharmacyCategoriesScreen());
                  },
                ),
              ],
            ),
          ),
        ),
        24.height,

        /// My Requests section header
        Padding(
          padding: const EdgeInsets.only(left: 16, right: 8),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 22,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [gradientStart, gradientEnd],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              10.width,
              Text(
                locale.value.myRequests,
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.4,
                  color: isDarkMode.value ? Colors.white : primaryTextColor,
                ),
              ).expand(),
            ],
          ),
        ),
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
                12.height,
                _buildRequestTile(
                  context,
                  icon: Icons.home_outlined,
                  label: locale.value.visitRequests,
                  accentColor: const Color(0xFF00695C),
                  delayIndex: 6,
                  onTap: () {
                    doIfLoggedIn(() {
                      Get.to(() => const DoctorVisitListScreen());
                    });
                  },
                ),
                12.height,
                _buildRequestTile(
                  context,
                  icon: Icons.local_pharmacy_outlined,
                  label: locale.value.myPharmacyOrders,
                  accentColor: const Color(0xFF2E7D32),
                  delayIndex: 7,
                  onTap: () {
                    doIfLoggedIn(() {
                      Get.to(() => const PharmacyOrderListScreen());
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

  /// Builds a premium gradient navigation card
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
      duration: Duration(milliseconds: 500 + (delayIndex * 120)),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 22 * (1 - value)),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: Get.width / 3 - 22,
          padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 8),
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: isDarkMode.value
                    ? softShadowColorDark
                    : softShadowColorMedium,
                blurRadius: 22,
                offset: const Offset(0, 10),
                spreadRadius: 0,
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
              // Top sheen highlight strip
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: 40,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(22)),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.white.withValues(alpha: 0.12),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              // Main content
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Icon in white circle with glow
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.22),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.35),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white.withValues(alpha: 0.20),
                            blurRadius: 16,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Icon(icon, color: Colors.white, size: 26),
                    ),
                    12.height,
                    Text(
                      label,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.1,
                        color: Colors.white,
                        height: 1.3,
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

  /// Builds a premium list tile for "My Requests" with gradient left accent border
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
      duration: Duration(milliseconds: 400 + (delayIndex * 100)),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(28 * (1 - value), 0),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: GestureDetector(
        onTap: onTap,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Stack(
            children: [
              // Card body
              Container(
                padding: const EdgeInsets.only(
                    left: 20, right: 16, top: 14, bottom: 14),
                decoration: BoxDecoration(
                  color: isDarkMode.value ? surfaceElevatedDark : surfaceElevated,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isDarkMode.value
                        ? Colors.white.withValues(alpha: 0.05)
                        : appColorPrimary.withValues(alpha: 0.05),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color:
                          isDarkMode.value ? softShadowColorDark : softShadowColor,
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Icon container with accent tint
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: accentColor.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(icon, color: accentColor, size: 20),
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
                    // Chevron
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: isDarkMode.value
                            ? Colors.white.withValues(alpha: 0.05)
                            : accentColor.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: accentColor.withValues(alpha: 0.7),
                        size: 13,
                      ),
                    ),
                  ],
                ),
              ),
              // Gradient left accent bar
              Positioned(
                top: 0,
                bottom: 0,
                left: 0,
                child: Container(
                  width: 4,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        accentColor,
                        accentColor.withValues(alpha: 0.4),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
