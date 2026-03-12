import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../main.dart';
import '../../../utils/app_common.dart';
import '../../../utils/colors.dart';
import '../model/doctor_detail_model.dart';

class QualificationCard extends StatelessWidget {
  final Qualifications qualificationData;

  const QualificationCard({super.key, required this.qualificationData});

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "${locale.value.year}:",
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: secondaryTextColor,
                ),
              ),
              8.height,
              Text(
                qualificationData.year,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: isDarkMode.value ? Colors.white : appColorPrimary,
                ),
              ),
            ],
          ).expand(flex: 1).visible(qualificationData.year.isNotEmpty),
          16.width,
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "${locale.value.degree}:",
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: secondaryTextColor,
                ),
              ),
              8.height,
              Text(
                qualificationData.degree,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: appColorSecondary,
                ),
              ),
            ],
          ).expand(flex: 2),
          16.width,
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "${locale.value.university}:",
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: secondaryTextColor,
                ),
              ),
              8.height,
              Text(
                qualificationData.university,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: isDarkMode.value ? Colors.white : appColorPrimary,
                ),
              ),
            ],
          ).expand(flex: 2),
        ],
      ),
    );
  }
}
