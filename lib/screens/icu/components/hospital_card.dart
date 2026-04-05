import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../components/cached_image_widget.dart';
import '../../../main.dart';
import '../../../utils/app_common.dart';
import '../../../utils/colors.dart';
import '../../../utils/constants.dart';
import '../model/hospital_model.dart';
import '../hospital_detail_screen.dart';

class HospitalCard extends StatelessWidget {
  final Hospital hospitalData;
  final VoidCallback? onTap;

  const HospitalCard({
    super.key,
    required this.hospitalData,
    this.onTap,
  });

  Color get _typeColor {
    switch (hospitalData.hospitalType.toLowerCase()) {
      case IcuHospitalTypeConst.government:
        return const Color(0xFF2196F3);
      case IcuHospitalTypeConst.private_:
        return appColorSecondary;
      case IcuHospitalTypeConst.military:
        return const Color(0xFF4CAF50);
      case IcuHospitalTypeConst.university:
        return const Color(0xFF9C27B0);
      default:
        return appColorPrimary;
    }
  }

  String get _typeLabel {
    switch (hospitalData.hospitalType.toLowerCase()) {
      case IcuHospitalTypeConst.government:
        return 'Government';
      case IcuHospitalTypeConst.private_:
        return 'Private';
      case IcuHospitalTypeConst.military:
        return 'Military';
      case IcuHospitalTypeConst.university:
        return 'University';
      default:
        return hospitalData.hospitalType;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap ?? () {
        hideKeyboard(context);
        Get.to(() => HospitalDetailScreen(hospitalData: hospitalData));
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
                left: BorderSide(color: _typeColor, width: 3),
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
                        hospitalData.name,
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
                    _buildTypeBadge(),
                  ],
                ),
                6.height,
                // City and rating row
                Row(
                  children: [
                    if (hospitalData.city.isNotEmpty) ...[
                      Icon(Icons.location_on_outlined, size: 14, color: secondaryTextColor),
                      3.width,
                      Text(
                        hospitalData.city,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          letterSpacing: 0.1,
                          color: secondaryTextColor,
                        ),
                      ),
                      10.width,
                    ],
                    if (hospitalData.rating > 0) ...[
                      Icon(Icons.star_rounded, size: 14, color: ratingColor),
                      3.width,
                      Text(
                        hospitalData.rating.toStringAsFixed(1),
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.1,
                          color: isDarkMode.value ? Colors.white : primaryTextColor,
                        ),
                      ),
                    ],
                  ],
                ),
                8.height,
                // Departments count
                Row(
                  children: [
                    Icon(Icons.local_hospital_outlined, size: 14, color: appColorSecondary),
                    3.width,
                    ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [gradientSecondaryStart, gradientSecondaryEnd],
                      ).createShader(bounds),
                      child: Text(
                        '${hospitalData.departmentsCount} ${locale.value.icuDepartments}',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.1,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                // Insurance tags
                if (hospitalData.acceptedInsurance.isNotEmpty) ...[
                  8.height,
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: hospitalData.acceptedInsurance.take(3).map((insurance) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: isDarkMode.value
                              ? appColorPrimary.withValues(alpha: 0.2)
                              : appColorPrimary.withValues(alpha: 0.06),
                        ),
                        child: Text(
                          insurance,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.1,
                            color: isDarkMode.value ? Colors.white70 : appColorPrimary,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),

          // Logo overlapping the card edge
          Positioned(
            left: 0,
            top: 10,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: _typeColor.withValues(alpha: 0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Hero(
                    tag: 'hospital_${hospitalData.id}',
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: hospitalData.logo.isNotEmpty
                          ? CachedImageWidget(
                              url: hospitalData.logo,
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
                                    _typeColor.withValues(alpha: 0.15),
                                    _typeColor.withValues(alpha: 0.05),
                                  ],
                                ),
                              ),
                              child: Icon(
                                Icons.local_hospital_rounded,
                                size: 36,
                                color: _typeColor,
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

          // Bottom gradient line based on type
          Positioned(
            bottom: 0,
            left: 44,
            right: 16,
            child: Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    _typeColor.withValues(alpha: 0.5),
                    _typeColor.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [
            _typeColor.withValues(alpha: 0.18),
            _typeColor.withValues(alpha: 0.10),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: _typeColor.withValues(alpha: 0.15),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        _typeLabel,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.1,
          color: _typeColor,
        ),
      ),
    );
  }
}
