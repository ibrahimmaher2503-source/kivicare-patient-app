import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../components/app_scaffold.dart';
import '../../components/cached_image_widget.dart';
import '../../main.dart';
import '../../utils/app_common.dart';
import '../../utils/colors.dart';
import '../../utils/constants.dart';
import 'create_nurse_request_screen.dart';
import 'model/nurse_model.dart';

class NurseDetailScreen extends StatelessWidget {
  final Nurse nurseData;

  const NurseDetailScreen({
    super.key,
    required this.nurseData,
  });

  Color get _availabilityColor {
    switch (nurseData.availabilityStatus.toLowerCase()) {
      case NurseAvailabilityConst.available:
        return nurseAvailableColor;
      case NurseAvailabilityConst.busy:
        return nurseBusyColor;
      case NurseAvailabilityConst.offDuty:
        return nurseOffDutyColor;
      default:
        return nurseOffDutyColor;
    }
  }

  String get _availabilityLabel {
    switch (nurseData.availabilityStatus.toLowerCase()) {
      case NurseAvailabilityConst.available:
        return locale.value.nurseAvailable;
      case NurseAvailabilityConst.busy:
        return locale.value.nurseBusy;
      case NurseAvailabilityConst.offDuty:
        return locale.value.nurseOffDuty;
      default:
        return nurseData.availabilityStatus;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffoldNew(
      appBartitleText: nurseData.name,
      hasLeadingWidget: true,
      appBarVerticalSize: Get.height * 0.12,
      body: Column(
        children: [
          Expanded(
            child: AnimatedScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              listAnimationType: ListAnimationType.Scale,
              fadeInConfiguration: FadeInConfiguration(duration: GetNumUtils(1).seconds),
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                16.height,

                // Hero Profile Section
                Center(
                  child: Column(
                    children: [
                      Hero(
                        tag: 'nurse_${nurseData.id}',
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: CachedImageWidget(
                            url: nurseData.profileImage,
                            height: 120,
                            width: 120,
                            fit: BoxFit.cover,
                            radius: 20,
                          ),
                        ),
                      ),
                      16.height,
                      Text(
                        nurseData.name,
                        style: GoogleFonts.outfit(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.3,
                          color: isDarkMode.value ? Colors.white : primaryTextColor,
                        ),
                      ),
                      6.height,
                      if (nurseData.specialization.isNotEmpty)
                        Text(
                          nurseData.specialization,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.1,
                            color: appColorSecondary,
                          ),
                        ),
                      12.height,
                      _buildAvailabilityBadge(),
                    ],
                  ),
                ),
                24.height,

                // Info Cards
                if (nurseData.specialization.isNotEmpty) _buildInfoCard(
                  icon: Icons.local_hospital_outlined,
                  title: locale.value.specialization,
                  value: nurseData.specialization,
                ),
                if (nurseData.experience.isNotEmpty) _buildInfoCard(
                  icon: Icons.work_outline_rounded,
                  title: locale.value.experience,
                  value: nurseData.experience,
                ),
                if (nurseData.hourlyRate > 0) _buildInfoCard(
                  icon: Icons.payments_outlined,
                  title: locale.value.hourlyRate,
                  value: '\$${nurseData.hourlyRate.toStringAsFixed(2)} / hour',
                ),
                if (nurseData.serviceArea.isNotEmpty) _buildInfoCard(
                  icon: Icons.location_on_outlined,
                  title: locale.value.serviceArea,
                  value: nurseData.serviceArea,
                ),
                if (nurseData.about.isNotEmpty) ...[
                  16.height,
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
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
                          nurseData.about,
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
                ],
                32.height,
              ],
            ).paddingSymmetric(horizontal: 16),
          ),

          // Request This Nurse Button
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: GestureDetector(
              onTap: () {
                Get.to(() => CreateNurseRequestScreen(preSelectedNurse: nurseData));
              },
              child: Container(
                width: Get.width,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [gradientSecondaryStart, gradientSecondaryEnd]),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: appColorSecondary.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Text(
                  locale.value.requestNurse,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.1,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
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
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: appColorSecondary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 22, color: appColorSecondary),
          ),
          16.width,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    letterSpacing: 0.1,
                    color: secondaryTextColor,
                  ),
                ),
                4.height,
                Text(
                  value,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.1,
                    color: isDarkMode.value ? Colors.white : primaryTextColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvailabilityBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          colors: [
            _availabilityColor.withValues(alpha: 0.15),
            _availabilityColor.withValues(alpha: 0.08),
          ],
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
              color: _availabilityColor,
            ),
          ),
          6.width,
          Text(
            _availabilityLabel,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.1,
              color: _availabilityColor,
            ),
          ),
        ],
      ),
    );
  }
}
