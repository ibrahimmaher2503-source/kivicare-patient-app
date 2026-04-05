import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../components/app_scaffold.dart';
import '../../main.dart';
import '../../utils/app_common.dart';
import '../../utils/colors.dart';
import 'doctor_search_screen.dart';
import 'clinic_search_screen.dart';
import 'nurse_search_screen.dart';
import 'lab_search_screen.dart';
import 'radiology_search_screen.dart';
import 'home_healthcare_search_screen.dart';

class SearchHubScreen extends StatelessWidget {
  const SearchHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cards = [
      _SearchCard(
        icon: Icons.person_search_rounded,
        label: locale.value.searchDoctors,
        gradient: const LinearGradient(
          colors: [gradientStart, Color(0xFF0A2F65), gradientEnd],
          stops: [0.0, 0.5, 1.0],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        onTap: () => Get.to(() => const DoctorSearchScreen()),
      ),
      _SearchCard(
        icon: Icons.local_hospital_rounded,
        label: locale.value.searchClinics,
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
        onTap: () => Get.to(() => const ClinicSearchScreen()),
      ),
      _SearchCard(
        icon: Icons.medical_services_rounded,
        label: locale.value.searchNurses,
        gradient: const LinearGradient(
          colors: [gradientSecondaryStart, Color(0xFF059E9A), gradientSecondaryEnd],
          stops: [0.0, 0.5, 1.0],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        onTap: () => Get.to(() => const NurseSearchScreen()),
      ),
      _SearchCard(
        icon: Icons.biotech_rounded,
        label: locale.value.searchLabs,
        gradient: LinearGradient(
          colors: [
            const Color(0xFF4527A0),
            const Color(0xFF5E35B1).withValues(alpha: 0.85),
            const Color(0xFF7E57C2).withValues(alpha: 0.65),
          ],
          stops: const [0.0, 0.5, 1.0],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        onTap: () => Get.to(() => const LabSearchScreen()),
      ),
      _SearchCard(
        icon: Icons.radio_button_checked_rounded,
        label: locale.value.searchRadiology,
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
        onTap: () => Get.to(() => const RadiologySearchScreen()),
      ),
      _SearchCard(
        icon: Icons.home_rounded,
        label: locale.value.searchHomeHealthcare,
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
        onTap: () => Get.to(() => const HomeHealthcareSearchScreen()),
      ),
    ];

    return AppScaffoldNew(
      appBartitleText: locale.value.searchProviders,
      hasLeadingWidget: true,
      body: AnimatedScrollView(
        padding: const EdgeInsets.all(16),
        listAnimationType: ListAnimationType.FadeIn,
        children: [
          16.height,
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: List.generate(cards.length, (index) {
              final card = cards[index];
              return TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: Duration(milliseconds: 400 + (index * 100)),
                curve: Curves.easeOutCubic,
                builder: (context, value, child) {
                  return Transform.translate(
                    offset: Offset(0, 20 * (1 - value)),
                    child: Opacity(opacity: value, child: child),
                  );
                },
                child: _buildCard(context, card, index),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(BuildContext context, _SearchCard card, int index) {
    final cardWidth = (Get.width - 48) / 2;
    return GestureDetector(
      onTap: card.onTap,
      child: Container(
        width: cardWidth,
        height: cardWidth * 0.85,
        decoration: BoxDecoration(
          gradient: card.gradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: isDarkMode.value ? softShadowColorDark : softShadowColorMedium,
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              right: -10,
              top: -10,
              child: Icon(card.icon, size: 80, color: Colors.white.withValues(alpha: 0.08)),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(card.icon, color: Colors.white, size: 24),
                  ),
                  12.height,
                  Text(
                    card.label,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 0.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchCard {
  final IconData icon;
  final String label;
  final Gradient gradient;
  final VoidCallback onTap;

  const _SearchCard({
    required this.icon,
    required this.label,
    required this.gradient,
    required this.onTap,
  });
}
