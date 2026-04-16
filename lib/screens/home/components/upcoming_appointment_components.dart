import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../main.dart';
import '../../../utils/colors.dart';
import '../../../utils/common_base.dart';
import '../../../utils/app_common.dart';
import '../../booking/components/appointment_card.dart';
import '../home_controller.dart';

class UpcomingAppointmentComponents extends StatelessWidget {
  UpcomingAppointmentComponents({super.key});
  final HomeController homeScreenController = Get.find();

  @override
  Widget build(BuildContext context) {
    if (homeScreenController.dashboardData.value.upcomingAppointment.isEmpty) {
      return const Offstage();
    }

    final appointment =
        homeScreenController.dashboardData.value.upcomingAppointment.first;
    final Color statusAccentColor =
        getBookingStatusColor(status: appointment.status);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Section header ─────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              // Gradient icon badge
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [gradientStart, gradientEnd],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: appColorPrimary.withValues(alpha: 0.25),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.event_note_rounded,
                  color: Colors.white,
                  size: 16,
                ),
              ),
              10.width,
              Text(
                locale.value.upcomingAppointments,
                style: GoogleFonts.outfit(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                  color: isDarkMode.value ? Colors.white : primaryTextColor,
                ),
              ).expand(),
            ],
          ),
        ),
        12.height,

        // ── Appointment card with premium left-accent ──────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: statusAccentColor.withValues(alpha: 0.18),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                  spreadRadius: -2,
                ),
                BoxShadow(
                  color: isDarkMode.value ? softShadowColorDark : softShadowColor,
                  blurRadius: 14,
                  offset: const Offset(0, 3),
                  spreadRadius: 0,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Stack(
                children: [
                  // Main card background
                  Container(
                    decoration: BoxDecoration(
                      color: isDarkMode.value ? surfaceElevatedDark : surfaceElevated,
                    ),
                    child: AppointmentCard(appointment: appointment),
                  ),
                  // Gradient left accent border
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
                            statusAccentColor,
                            statusAccentColor.withValues(alpha: 0.5),
                          ],
                        ),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(18),
                          bottomLeft: Radius.circular(18),
                        ),
                      ),
                    ),
                  ),
                  // Subtle top-right status glow
                  Positioned(
                    top: -20,
                    right: -20,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: statusAccentColor.withValues(alpha: 0.06),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
