import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../components/cached_image_widget.dart';
import '../../../main.dart';
import '../../../utils/app_common.dart';
import '../../../utils/colors.dart';
import '../../../utils/constants.dart';
import '../model/nurse_model.dart';
import '../nurse_detail_screen.dart';

class NurseCard extends StatelessWidget {
  final Nurse nurseData;
  final VoidCallback? onTap;

  const NurseCard({
    super.key,
    required this.nurseData,
    this.onTap,
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
    return GestureDetector(
      onTap: onTap ?? () {
        hideKeyboard(context);
        Get.to(() => NurseDetailScreen(nurseData: nurseData));
      },
      child: Container(
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Image
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CachedImageWidget(
                url: nurseData.profileImage,
                height: 80,
                width: 80,
                fit: BoxFit.cover,
                radius: 12,
              ),
            ),
            16.width,
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          nurseData.name,
                          style: GoogleFonts.outfit(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.3,
                            color: isDarkMode.value ? Colors.white : primaryTextColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      8.width,
                      _buildAvailabilityBadge(),
                    ],
                  ),
                  6.height,
                  if (nurseData.specialization.isNotEmpty)
                    Text(
                      nurseData.specialization,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        letterSpacing: 0.1,
                        color: appColorSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  8.height,
                  Row(
                    children: [
                      if (nurseData.experience.isNotEmpty) ...[
                        Icon(Icons.work_outline_rounded, size: 14, color: secondaryTextColor),
                        4.width,
                        Text(
                          nurseData.experience,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            letterSpacing: 0.1,
                            color: secondaryTextColor,
                          ),
                        ),
                        12.width,
                      ],
                      if (nurseData.hourlyRate > 0) ...[
                        Icon(Icons.payments_outlined, size: 14, color: secondaryTextColor),
                        4.width,
                        Text(
                          '\$${nurseData.hourlyRate.toStringAsFixed(2)}/hr',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.1,
                            color: isDarkMode.value ? Colors.white : primaryTextColor,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvailabilityBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
          4.width,
          Text(
            _availabilityLabel,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
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
