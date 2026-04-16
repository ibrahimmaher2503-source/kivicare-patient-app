import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../components/cached_image_widget.dart';
import '../../../components/location_badge.dart';
import '../../../main.dart';
import '../../../utils/app_common.dart';
import '../../../utils/colors.dart';
import '../../../utils/constants.dart';
import '../../../utils/price_widget.dart';
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
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Main card body with left accent border
          Container(
            margin: const EdgeInsets.only(left: 28),
            padding: const EdgeInsets.only(left: 68, top: 16, bottom: 16, right: 16),
            decoration: BoxDecoration(
              color: isDarkMode.value ? surfaceElevatedDark : surfaceElevated,
              borderRadius: BorderRadius.circular(16),
              border: Border(
                left: BorderSide(color: _availabilityColor, width: 3),
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
                      3.width,
                      Text(
                        nurseData.experience,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          letterSpacing: 0.1,
                          color: secondaryTextColor,
                        ),
                      ),
                      10.width,
                    ],
                    if (nurseData.hourlyRate > 0) ...[
                      Icon(Icons.payments_outlined, size: 14, color: appColorSecondary),
                      3.width,
                      ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: [gradientSecondaryStart, gradientSecondaryEnd],
                        ).createShader(bounds),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            PriceWidget(
                              price: nurseData.hourlyRate,
                              size: 12,
                              color: Colors.white,
                            ),
                            Text(
                              locale.value.perHour,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.1,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
                if (nurseData.governorate != null) ...[
                  8.height,
                  locationBadge(nurseData.governorate, nurseData.city),
                ],
              ],
            ),
          ),

          // Profile image overlapping the card edge
          Positioned(
            left: 0,
            top: 10,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: appColorPrimary.withValues(alpha: 0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Hero(
                    tag: 'nurse_${nurseData.id}',
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: CachedImageWidget(
                        url: nurseData.profileImage,
                        height: 80,
                        width: 80,
                        fit: BoxFit.cover,
                        radius: 14,
                      ),
                    ),
                  ),
                  // Gradient overlay on profile image for depth
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.15),
                          ],
                          stops: const [0.0, 0.6, 1.0],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom gradient line based on availability
          Positioned(
            bottom: 0,
            left: 44,
            right: 16,
            child: Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    _availabilityColor.withValues(alpha: 0.5),
                    _availabilityColor.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvailabilityBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [
            _availabilityColor.withValues(alpha: 0.18),
            _availabilityColor.withValues(alpha: 0.10),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: _availabilityColor.withValues(alpha: 0.15),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _availabilityColor,
              boxShadow: [
                BoxShadow(
                  color: _availabilityColor.withValues(alpha: 0.5),
                  blurRadius: 4,
                ),
              ],
            ),
          ),
          5.width,
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
