import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../components/cached_image_widget.dart';
import '../../../main.dart';
import '../../../utils/app_common.dart';
import '../../../utils/colors.dart';
import '../../../utils/price_widget.dart';
import '../model/call_doctor_model.dart';
import '../call_doctor_detail_screen.dart';

class CallDoctorCard extends StatelessWidget {
  final CallDoctor doctorData;
  final VoidCallback? onTap;

  const CallDoctorCard({
    super.key,
    required this.doctorData,
    this.onTap,
  });

  Color get _accentColor {
    if (doctorData.hasVideoCall && doctorData.hasPhoneCall) {
      return callTypeVideoColor;
    } else if (doctorData.hasVideoCall) {
      return callTypeVideoColor;
    } else if (doctorData.hasPhoneCall) {
      return callTypePhoneColor;
    }
    return appColorSecondary;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap ?? () {
        hideKeyboard(context);
        Get.to(() => CallDoctorDetailScreen(doctorData: doctorData));
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
                left: BorderSide(color: _accentColor, width: 3),
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
                // Name row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        doctorData.fullName,
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
                    _buildCallTypeIndicators(),
                  ],
                ),
                6.height,

                // Specialty and experience row
                Row(
                  children: [
                    if (doctorData.expert.isNotEmpty) ...[
                      Icon(Icons.medical_information_outlined, size: 14, color: secondaryTextColor),
                      3.width,
                      Expanded(
                        child: Text(
                          doctorData.expert,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            letterSpacing: 0.1,
                            color: secondaryTextColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ],
                ),
                8.height,

                // Rating and experience row
                Row(
                  children: [
                    if (doctorData.averageRating > 0) ...[
                      _buildRatingStars(),
                      6.width,
                      Text(
                        '(${doctorData.totalReviews})',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          letterSpacing: 0.1,
                          color: secondaryTextColor,
                        ),
                      ),
                      12.width,
                    ],
                    if (doctorData.experience.isNotEmpty) ...[
                      Icon(Icons.work_outline_rounded, size: 14, color: appColorSecondary),
                      3.width,
                      Text(
                        doctorData.experience,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.1,
                          color: isDarkMode.value ? Colors.white70 : primaryTextColor,
                        ),
                      ),
                    ],
                  ],
                ),

                // Starting price
                if (doctorData.callStartingPrice > 0) ...[
                  8.height,
                  Row(
                    children: [
                      ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: [gradientSecondaryStart, gradientSecondaryEnd],
                        ).createShader(bounds),
                        child: Text(
                          '${locale.value.startingFrom} ',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.1,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      PriceWidget(
                        price: doctorData.callStartingPrice,
                        size: 14,
                        color: appColorSecondary,
                      ),
                    ],
                  ),
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
                    color: _accentColor.withValues(alpha: 0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Hero(
                    tag: 'call_doctor_${doctorData.id}',
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: doctorData.profileImage.isNotEmpty
                          ? CachedImageWidget(
                              url: doctorData.profileImage,
                              height: 80,
                              width: 80,
                              fit: BoxFit.cover,
                              radius: 14,
                            )
                          : Container(
                              height: 80,
                              width: 80,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(14),
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    _accentColor.withValues(alpha: 0.15),
                                    _accentColor.withValues(alpha: 0.05),
                                  ],
                                ),
                              ),
                              child: Icon(
                                Icons.person_rounded,
                                size: 36,
                                color: _accentColor,
                              ),
                            ),
                    ),
                  ),
                  // Gradient overlay for depth
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

          // Bottom gradient line
          Positioned(
            bottom: 0,
            left: 44,
            right: 16,
            child: Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    _accentColor.withValues(alpha: 0.5),
                    _accentColor.withValues(alpha: 0.0),
                  ],
                ),
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
          return Icon(Icons.star_rounded, size: 14, color: ratingColor);
        } else if (doctorData.averageRating >= starValue - 0.5) {
          return Icon(Icons.star_half_rounded, size: 14, color: ratingColor);
        } else {
          return Icon(Icons.star_outline_rounded, size: 14, color: secondaryTextColor.withValues(alpha: 0.3));
        }
      }),
    );
  }

  Widget _buildCallTypeIndicators() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (doctorData.hasVideoCall)
          Container(
            padding: const EdgeInsets.all(6),
            margin: EdgeInsets.only(right: doctorData.hasPhoneCall ? 6 : 0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              gradient: LinearGradient(
                colors: [
                  callTypeVideoColor.withValues(alpha: 0.18),
                  callTypeVideoColor.withValues(alpha: 0.10),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: callTypeVideoColor.withValues(alpha: 0.15),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(Icons.videocam_rounded, size: 16, color: callTypeVideoColor),
          ),
        if (doctorData.hasPhoneCall)
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              gradient: LinearGradient(
                colors: [
                  callTypePhoneColor.withValues(alpha: 0.18),
                  callTypePhoneColor.withValues(alpha: 0.10),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: callTypePhoneColor.withValues(alpha: 0.15),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(Icons.phone_rounded, size: 16, color: callTypePhoneColor),
          ),
      ],
    );
  }
}
