import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kivicare_patient/main.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../utils/app_common.dart';
import '../../../utils/colors.dart';
import '../../../utils/common_base.dart';
import '../model/encounter_list_model.dart';

class AllEncountersCard extends StatelessWidget {
  final EncounterElement encounterElement;

  const AllEncountersCard({super.key, required this.encounterElement});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDarkMode.value ? surfaceElevatedDark : surfaceElevated,
        borderRadius: BorderRadius.circular(16),
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
          16.height,
          Row(
            children: [
              Expanded(
                child: Text(
                  encounterElement.doctorName,
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.3,
                    color: isDarkMode.value ? Colors.white : primaryTextColor,
                  ),
                ),
              ),
              8.width,
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: LinearGradient(
                    colors: encounterElement.status
                        ? [completedStatusColor.withValues(alpha: 0.15), completedStatusColor.withValues(alpha: 0.08)]
                        : [pendingStatusColor.withValues(alpha: 0.15), pendingStatusColor.withValues(alpha: 0.08)],
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: encounterElement.status ? completedStatusColor : pendingStatusColor,
                      ),
                    ),
                    6.width,
                    Text(
                      encounterElement.status ? locale.value.active : locale.value.closed,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.1,
                        color: encounterElement.status ? completedStatusColor : pendingStatusColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ).paddingSymmetric(horizontal: 16),
          12.height,
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            height: 1,
            color: isDarkMode.value ? borderColor.withValues(alpha: 0.08) : borderColor.withValues(alpha: 0.2),
          ),
          12.height,
          Row(
            children: [
              Text(
                encounterElement.appointmentId == -1 ? locale.value.encounterId : locale.value.appointmentId,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  letterSpacing: 0.1,
                  color: secondaryTextColor,
                ),
              ),
              6.width,
              Text(
                encounterElement.appointmentId == -1 ? encounterElement.id.toString() : encounterElement.appointmentId.toString(),
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.1,
                  color: isDarkMode.value ? Colors.white : primaryTextColor,
                ),
              ).expand(),
            ],
          ).paddingSymmetric(horizontal: 16),
          8.height,
          Row(
            children: [
              Text(
                '${locale.value.date}:',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  letterSpacing: 0.1,
                  color: secondaryTextColor,
                ),
              ),
              6.width,
              Text(
                encounterElement.encounterDate.dateInDMMMMyyyyFormat,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.1,
                  color: isDarkMode.value ? Colors.white : primaryTextColor,
                ),
              ).expand(),
            ],
          ).paddingSymmetric(horizontal: 16),
          8.height,
          Row(
            children: [
              Text(
                '${locale.value.clinicName}:',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  letterSpacing: 0.1,
                  color: secondaryTextColor,
                ),
              ),
              6.width,
              Text(
                encounterElement.clinicName,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.1,
                  color: isDarkMode.value ? Colors.white : primaryTextColor,
                ),
              ).expand(),
            ],
          ).paddingSymmetric(horizontal: 16).visible(encounterElement.clinicName.isNotEmpty),
          16.height,
        ],
      ),
    );
  }
}
