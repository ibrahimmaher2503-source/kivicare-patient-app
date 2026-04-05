import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../components/app_scaffold.dart';
import '../../components/cached_image_widget.dart';
import '../../main.dart';
import '../../utils/app_common.dart';
import '../../utils/colors.dart';
import '../../utils/common_base.dart';
import '../../utils/constants.dart';
import 'components/department_card.dart';
import 'create_admission_screen.dart';
import 'model/hospital_model.dart';

class _WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 40);
    path.quadraticBezierTo(size.width * 0.25, size.height, size.width * 0.5, size.height - 20);
    path.quadraticBezierTo(size.width * 0.75, size.height - 40, size.width, size.height - 10);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class HospitalDetailScreen extends StatefulWidget {
  final Hospital hospitalData;

  const HospitalDetailScreen({
    super.key,
    required this.hospitalData,
  });

  @override
  State<HospitalDetailScreen> createState() => _HospitalDetailScreenState();
}

class _HospitalDetailScreenState extends State<HospitalDetailScreen> with TickerProviderStateMixin, WidgetsBindingObserver {
  late final AnimationController _pulseController;

  Hospital get hospitalData => widget.hospitalData;

  Color get _typeColor {
    switch (hospitalData.hospitalType.toLowerCase()) {
      case IcuHospitalTypeConst.government:
        return const Color(0xFF2196F3);
      case IcuHospitalTypeConst.private_:
        return appColorSecondary;
      case IcuHospitalTypeConst.military:
        return const Color(0xFF4CAF50);
      case IcuHospitalTypeConst.university:
        return const Color(0xFF9C27B0);
      default:
        return appColorPrimary;
    }
  }

  String get _typeLabel {
    switch (hospitalData.hospitalType.toLowerCase()) {
      case IcuHospitalTypeConst.government:
        return 'Government';
      case IcuHospitalTypeConst.private_:
        return 'Private';
      case IcuHospitalTypeConst.military:
        return 'Military';
      case IcuHospitalTypeConst.university:
        return 'University';
      default:
        return hospitalData.hospitalType;
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _pulseController.stop();
    } else if (state == AppLifecycleState.resumed) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Build info cards
    final List<_InfoCardData> infoCards = [];
    int cardIndex = 0;

    if (hospitalData.address.isNotEmpty) {
      infoCards.add(_InfoCardData(
        icon: Icons.location_on_outlined,
        title: locale.value.address,
        value: hospitalData.address,
        index: cardIndex++,
      ));
    }
    if (hospitalData.city.isNotEmpty) {
      infoCards.add(_InfoCardData(
        icon: Icons.location_city_outlined,
        title: locale.value.city,
        value: '${hospitalData.city}${hospitalData.state.isNotEmpty ? ', ${hospitalData.state}' : ''}',
        index: cardIndex++,
      ));
    }
    if (hospitalData.phone.isNotEmpty) {
      infoCards.add(_InfoCardData(
        icon: Icons.phone_outlined,
        title: locale.value.contactNumber,
        value: hospitalData.phone,
        index: cardIndex++,
      ));
    }
    if (hospitalData.email.isNotEmpty) {
      infoCards.add(_InfoCardData(
        icon: Icons.email_outlined,
        title: locale.value.email,
        value: hospitalData.email,
        index: cardIndex++,
      ));
    }
    if (hospitalData.website.isNotEmpty) {
      infoCards.add(_InfoCardData(
        icon: Icons.language_outlined,
        title: 'Website',
        value: hospitalData.website,
        index: cardIndex++,
      ));
    }
    if (hospitalData.licenseNumber.isNotEmpty) {
      infoCards.add(_InfoCardData(
        icon: Icons.badge_outlined,
        title: 'License',
        value: hospitalData.licenseNumber,
        index: cardIndex++,
      ));
    }

    return AppScaffoldNew(
      appBartitleText: hospitalData.name,
      hasLeadingWidget: true,
      appBarVerticalSize: Get.height * 0.12,
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Dramatic Header Section
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // Gradient background with wave clip
                      ClipPath(
                        clipper: _WaveClipper(),
                        child: Container(
                          width: double.infinity,
                          height: 220,
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [appColorPrimary, appColorSecondary],
                            ),
                          ),
                          child: CustomPaint(
                            painter: _SubtlePatternPainter(),
                          ),
                        ),
                      ),

                      // Logo centered and overlapping content below
                      Positioned(
                        bottom: -30,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: isDarkMode.value ? surfaceElevatedDark : surfaceElevated,
                                width: 4,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: appColorPrimary.withValues(alpha: 0.25),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Hero(
                              tag: 'hospital_${hospitalData.id}',
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: hospitalData.logo.isNotEmpty
                                    ? CachedImageWidget(
                                        url: hospitalData.logo,
                                        height: 120,
                                        width: 120,
                                        fit: BoxFit.cover,
                                        radius: 20,
                                      )
                                    : Container(
                                        height: 120,
                                        width: 120,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(20),
                                          gradient: LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            colors: [
                                              _typeColor.withValues(alpha: 0.15),
                                              _typeColor.withValues(alpha: 0.05),
                                            ],
                                          ),
                                        ),
                                        child: Icon(
                                          Icons.local_hospital_rounded,
                                          size: 50,
                                          color: _typeColor,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Type badge and rating
                      Positioned(
                        top: 16,
                        right: 16,
                        child: _buildTypeBadge(),
                      ),
                      if (hospitalData.rating > 0)
                        Positioned(
                          top: 16,
                          left: 16,
                          child: _buildRatingBadge(),
                        ),
                    ],
                  ),

                  48.height,

                  // Name and type
                  Center(
                    child: Column(
                      children: [
                        Text(
                          hospitalData.name,
                          style: GoogleFonts.outfit(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.3,
                            color: isDarkMode.value ? Colors.white : primaryTextColor,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        6.height,
                        Text(
                          '${locale.value.hospitalTypeLabel}: $_typeLabel',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.1,
                            color: appColorSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  24.height,

                  // Info Cards in 2-column grid with stagger animation
                  if (infoCards.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: infoCards.map((data) {
                          return TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0.0, end: 1.0),
                            duration: Duration(milliseconds: 400 + (data.index * 100)),
                            builder: (context, value, child) {
                              return Opacity(
                                opacity: value,
                                child: Transform.translate(
                                  offset: Offset(0, 20 * (1 - value)),
                                  child: child,
                                ),
                              );
                            },
                            child: SizedBox(
                              width: (Get.width - 44) / 2,
                              child: _buildGlassInfoCard(
                                icon: data.icon,
                                title: data.title,
                                value: data.value,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),

                  // Accepted Insurance Section
                  if (hospitalData.acceptedInsurance.isNotEmpty) ...[
                    24.height,
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: Duration(milliseconds: 400 + (cardIndex * 100)),
                      builder: (context, value, child) {
                        return Opacity(
                          opacity: value,
                          child: Transform.translate(
                            offset: Offset(0, 20 * (1 - value)),
                            child: child,
                          ),
                        );
                      },
                      child: Container(
                        width: double.infinity,
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDarkMode.value ? surfaceElevatedDark : surfaceElevated,
                          borderRadius: BorderRadius.circular(16),
                          border: Border(
                            left: BorderSide(
                              color: appColorSecondary.withValues(alpha: 0.5),
                              width: 3,
                            ),
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
                            Text(
                              locale.value.insuranceLabel,
                              style: GoogleFonts.outfit(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                letterSpacing: -0.3,
                                color: isDarkMode.value ? Colors.white : primaryTextColor,
                              ),
                            ),
                            12.height,
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: hospitalData.acceptedInsurance.map((insurance) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    gradient: LinearGradient(
                                      colors: [
                                        appColorPrimary.withValues(alpha: 0.12),
                                        appColorPrimary.withValues(alpha: 0.06),
                                      ],
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: appColorPrimary.withValues(alpha: 0.08),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Text(
                                    insurance,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.1,
                                      color: isDarkMode.value ? Colors.white : appColorPrimary,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],

                  // Description Section
                  if (hospitalData.description.isNotEmpty) ...[
                    24.height,
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: Duration(milliseconds: 500 + (cardIndex * 100)),
                      builder: (context, value, child) {
                        return Opacity(
                          opacity: value,
                          child: Transform.translate(
                            offset: Offset(0, 20 * (1 - value)),
                            child: child,
                          ),
                        );
                      },
                      child: Container(
                        width: double.infinity,
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDarkMode.value ? surfaceElevatedDark : surfaceElevated,
                          borderRadius: BorderRadius.circular(16),
                          border: Border(
                            left: BorderSide(
                              color: appColorPrimary.withValues(alpha: 0.5),
                              width: 3,
                            ),
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
                            Text(
                              locale.value.about,
                              style: GoogleFonts.outfit(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                letterSpacing: -0.3,
                                color: isDarkMode.value ? Colors.white : primaryTextColor,
                              ),
                            ),
                            10.height,
                            Text(
                              hospitalData.description,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14,
                                letterSpacing: 0.1,
                                color: secondaryTextColor,
                                height: 1.6,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],

                  // ICU Departments Section
                  if (hospitalData.departments.isNotEmpty) ...[
                    24.height,
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        locale.value.icuDepartments,
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.3,
                          color: isDarkMode.value ? Colors.white : primaryTextColor,
                        ),
                      ),
                    ),
                    12.height,
                    ...hospitalData.departments.asMap().entries.map((entry) {
                      final index = entry.key;
                      final dept = entry.value;
                      return TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.0, end: 1.0),
                        duration: Duration(milliseconds: 400 + (index * 100)),
                        builder: (context, value, child) {
                          return Opacity(
                            opacity: value,
                            child: Transform.translate(
                              offset: Offset(0, 20 * (1 - value)),
                              child: child,
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: DepartmentCard(departmentData: dept).paddingBottom(12),
                        ),
                      );
                    }),
                  ],
                  32.height,
                ],
              ),
            ),
          ),

          // Request Admission Button with pulsing glow
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                final glowOpacity = 0.2 + (_pulseController.value * 0.15);
                final glowSpread = 4.0 + (_pulseController.value * 4.0);
                return GestureDetector(
                  onTap: () {
                    doIfLoggedIn(() {
                      Get.to(() => CreateAdmissionScreen(preSelectedHospital: hospitalData));
                    });
                  },
                  child: Container(
                    width: Get.width,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [gradientSecondaryStart, gradientSecondaryEnd]),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: appColorSecondary.withValues(alpha: glowOpacity),
                          blurRadius: 12 + glowSpread,
                          spreadRadius: glowSpread / 2,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Text(
                      locale.value.createAdmissionRequest,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.1,
                        color: Colors.white,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassInfoCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDarkMode.value
            ? surfaceElevatedDark.withValues(alpha: 0.8)
            : surfaceElevated.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDarkMode.value ? glassStrokeDark : glassStrokeLight,
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
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  appColorSecondary.withValues(alpha: 0.15),
                  appColorAccent.withValues(alpha: 0.08),
                ],
              ),
            ),
            child: Icon(icon, size: 20, color: appColorSecondary),
          ),
          10.height,
          Text(
            title,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              letterSpacing: 0.1,
              color: secondaryTextColor,
            ),
          ),
          4.height,
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.1,
              color: isDarkMode.value ? Colors.white : primaryTextColor,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildTypeBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white.withValues(alpha: 0.2),
        border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: _typeColor.withValues(alpha: 0.2),
            blurRadius: 8,
          ),
        ],
      ),
      child: Text(
        _typeLabel,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.1,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildRatingBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white.withValues(alpha: 0.2),
        border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star_rounded, size: 16, color: Colors.amber),
          4.width,
          Text(
            hospitalData.rating.toStringAsFixed(1),
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.1,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCardData {
  final IconData icon;
  final String title;
  final String value;
  final int index;

  _InfoCardData({
    required this.icon,
    required this.title,
    required this.value,
    required this.index,
  });
}

/// Subtle decorative pattern for the header gradient
class _SubtlePatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.04)
      ..style = PaintingStyle.fill;

    // Draw subtle circles for texture
    canvas.drawCircle(Offset(size.width * 0.8, size.height * 0.3), 60, paint);
    canvas.drawCircle(Offset(size.width * 0.2, size.height * 0.7), 40, paint);
    canvas.drawCircle(Offset(size.width * 0.6, size.height * 0.1), 30, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
