import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../main.dart';
import '../../../utils/app_common.dart';
import '../../../utils/colors.dart';
import '../../service/model/service_list_model.dart';

class DoctorServiceCard extends StatelessWidget {
  final ServiceElement serviceElement;

  const DoctorServiceCard({super.key, required this.serviceElement});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: isDarkMode.value ? surfaceElevatedDark : surfaceElevated,
          boxShadow: [
            BoxShadow(
              color: isDarkMode.value ? softShadowColorDark : softShadowColor,
              blurRadius: 16,
              offset: const Offset(0, 4),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              serviceElement.serviceName,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.outfit(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.3,
                color: isDarkMode.value ? Colors.white : appColorPrimary,
              ),
            ),
            16.height,
            Row(
              children: [
                Text(
                  "${locale.value.totalAppointmentsDone}:",
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: secondaryTextColor,
                  ),
                ),
                8.width,
                Text(
                  "${serviceElement.totalAppointments}",
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: appColorSecondary,
                  ),
                ),
              ],
            ),
            8.height,
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${locale.value.clinic}:",
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: secondaryTextColor,
                  ),
                ),
                8.width,
                Text(
                  serviceElement.clinicName.map((e) => e.validate()).toList().join(', '),
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isDarkMode.value ? Colors.white : appColorPrimary,
                  ),
                ).flexible(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
