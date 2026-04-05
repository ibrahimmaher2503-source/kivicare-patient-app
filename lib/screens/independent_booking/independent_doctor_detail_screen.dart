import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../api/core_apis.dart';
import '../../components/app_scaffold.dart';
import '../../components/cached_image_widget.dart';
import '../../components/loader_widget.dart';
import '../../main.dart';
import '../../utils/app_common.dart';
import '../../utils/colors.dart';
import '../../utils/common_base.dart';
import 'book_independent_screen.dart';
import 'components/independent_service_card.dart';
import 'model/independent_doctor_model.dart';

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

class IndependentDoctorDetailScreen extends StatefulWidget {
  final IndependentDoctor doctorData;

  const IndependentDoctorDetailScreen({
    super.key,
    required this.doctorData,
  });

  @override
  State<IndependentDoctorDetailScreen> createState() => _IndependentDoctorDetailScreenState();
}

class _IndependentDoctorDetailScreenState extends State<IndependentDoctorDetailScreen> with TickerProviderStateMixin, WidgetsBindingObserver {
  late final AnimationController _pulseController;

  IndependentDoctor get doctorData => widget.doctorData;

  RxList<IndependentService> services = RxList<IndependentService>();
  RxBool isLoadingServices = false.obs;

  static const Color _accentColor = Color(0xFF00897B);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    // Initialize services from doctor data or load from API
    if (doctorData.services.isNotEmpty) {
      services.addAll(doctorData.services);
    } else {
      _loadServices();
    }
  }

  Future<void> _loadServices() async {
    isLoadingServices(true);
    try {
      final result = await CoreServiceApis.getIndependentDoctorServices(doctorId: doctorData.id);
      services.assignAll(result);
    } catch (e) {
      log("Load services error: $e");
    } finally {
      isLoadingServices(false);
    }
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

    if (doctorData.expert.isNotEmpty) {
      infoCards.add(_InfoCardData(
        icon: Icons.medical_information_outlined,
        title: locale.value.specialization,
        value: doctorData.expert,
        index: cardIndex++,
      ));
    }
    if (doctorData.experience.isNotEmpty) {
      infoCards.add(_InfoCardData(
        icon: Icons.work_outline_rounded,
        title: locale.value.experience,
        value: doctorData.experience,
        index: cardIndex++,
      ));
    }

    // Stats cards
    if (doctorData.totalAppointment > 0) {
      infoCards.add(_InfoCardData(
        icon: Icons.event_note_rounded,
        title: locale.value.totalAppointmentsLabel,
        value: '${doctorData.totalAppointment}',
        index: cardIndex++,
      ));
    }
    if (doctorData.totalPatient > 0) {
      infoCards.add(_InfoCardData(
        icon: Icons.people_outline_rounded,
        title: locale.value.totalPatientsLabel,
        value: '${doctorData.totalPatient}',
        index: cardIndex++,
      ));
    }
    if (doctorData.totalReviews > 0) {
      infoCards.add(_InfoCardData(
        icon: Icons.star_outline_rounded,
        title: locale.value.reviews,
        value: '${doctorData.totalReviews}',
        index: cardIndex++,
      ));
    }

    if (doctorData.email.isNotEmpty) {
      infoCards.add(_InfoCardData(
        icon: Icons.email_outlined,
        title: locale.value.email,
        value: doctorData.email,
        index: cardIndex++,
      ));
    }
    if (doctorData.mobile.isNotEmpty) {
      infoCards.add(_InfoCardData(
        icon: Icons.phone_outlined,
        title: locale.value.contactNumber,
        value: doctorData.mobile,
        index: cardIndex++,
      ));
    }

    return AppScaffoldNew(
      appBartitleText: doctorData.fullName,
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
                              colors: [_accentColor, Color(0xFF26A69A)],
                            ),
                          ),
                          child: CustomPaint(
                            painter: _SubtlePatternPainter(),
                          ),
                        ),
                      ),

                      // Profile image centered and overlapping content below
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
                                  color: _accentColor.withValues(alpha: 0.25),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Hero(
                              tag: 'independent_doctor_${doctorData.id}',
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: doctorData.profileImage.isNotEmpty
                                    ? CachedImageWidget(
                                        url: doctorData.profileImage,
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
                                              _accentColor.withValues(alpha: 0.15),
                                              _accentColor.withValues(alpha: 0.05),
                                            ],
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.person_rounded,
                                          size: 50,
                                          color: _accentColor,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      // In-person badge
                      Positioned(
                        top: 16,
                        right: 16,
                        child: _buildInPersonHeaderBadge(),
                      ),

                      // Rating badge
                      if (doctorData.averageRating > 0)
                        Positioned(
                          top: 16,
                          left: 16,
                          child: _buildRatingBadge(),
                        ),
                    ],
                  ),

                  48.height,

                  // Name and specialty
                  Center(
                    child: Column(
                      children: [
                        Text(
                          doctorData.fullName,
                          style: GoogleFonts.outfit(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.3,
                            color: isDarkMode.value ? Colors.white : primaryTextColor,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        if (doctorData.expert.isNotEmpty) ...[
                          6.height,
                          Text(
                            doctorData.expert,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.1,
                              color: appColorSecondary,
                            ),
                          ),
                        ],
                        if (doctorData.averageRating > 0) ...[
                          10.height,
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildRatingStars(),
                              8.width,
                              Text(
                                '${doctorData.averageRating.toStringAsFixed(1)} (${doctorData.totalReviews} ${locale.value.reviews})',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.1,
                                  color: isDarkMode.value ? Colors.white70 : secondaryTextColor,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Address section
                  if (doctorData.address.isNotEmpty) ...[
                    16.height,
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _accentColor.withValues(alpha: isDarkMode.value ? 0.15 : 0.06),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _accentColor.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.location_on_outlined, size: 18, color: _accentColor),
                            10.width,
                            Expanded(
                              child: Text(
                                doctorData.address,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0.1,
                                  color: isDarkMode.value ? Colors.white70 : primaryTextColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],

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

                  // About Section
                  if (doctorData.description.isNotEmpty) ...[
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
                              color: _accentColor.withValues(alpha: 0.5),
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
                              doctorData.description,
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

                  // Services Section
                  24.height,
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      locale.value.independentServices,
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.3,
                        color: isDarkMode.value ? Colors.white : primaryTextColor,
                      ),
                    ),
                  ),
                  12.height,

                  Obx(() {
                    if (isLoadingServices.value) {
                      return const Padding(
                        padding: EdgeInsets.all(32),
                        child: Center(child: LoaderWidget()),
                      );
                    }

                    if (services.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                        child: Center(
                          child: Text(
                            locale.value.noIndependentDoctorsFound,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              letterSpacing: 0.1,
                              color: secondaryTextColor,
                            ),
                          ),
                        ),
                      );
                    }

                    return Column(
                      children: services.asMap().entries.map((entry) {
                        final index = entry.key;
                        final service = entry.value;
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
                            child: IndependentServiceCard(
                              serviceData: service,
                              onTap: () {
                                doIfLoggedIn(() {
                                  Get.to(() => BookIndependentScreen(
                                    doctor: doctorData,
                                    service: service,
                                  ));
                                });
                              },
                            ).paddingBottom(12),
                          ),
                        );
                      }).toList(),
                    );
                  }),

                  32.height,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingStars() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final starValue = index + 1;
        if (doctorData.averageRating >= starValue) {
          return Icon(Icons.star_rounded, size: 18, color: ratingColor);
        } else if (doctorData.averageRating >= starValue - 0.5) {
          return Icon(Icons.star_half_rounded, size: 18, color: ratingColor);
        } else {
          return Icon(Icons.star_outline_rounded, size: 18, color: secondaryTextColor.withValues(alpha: 0.3));
        }
      }),
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
                  _accentColor.withValues(alpha: 0.15),
                  appColorAccent.withValues(alpha: 0.08),
                ],
              ),
            ),
            child: Icon(icon, size: 20, color: _accentColor),
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

  Widget _buildInPersonHeaderBadge() {
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
          const Icon(Icons.person_pin_rounded, size: 16, color: Colors.white),
          4.width,
          Text(
            locale.value.inPersonConsultation,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.1,
              color: Colors.white,
            ),
          ),
        ],
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
            doctorData.averageRating.toStringAsFixed(1),
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
