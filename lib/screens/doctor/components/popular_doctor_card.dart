import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../../main.dart';
import '../../../utils/app_common.dart';
import '../../../utils/colors.dart';
import '../doctor_detail_screen.dart';
import '../model/doctor_list_res.dart';

class PopularDoctorCard extends StatelessWidget {
  const PopularDoctorCard({super.key, required this.doctorElement, this.isFromClinicDetail = false});

  final Doctor doctorElement;
  final bool isFromClinicDetail;

  @override
  Widget build(BuildContext context) {
    final bool darkMode = isDarkMode.value;
    final double rating = doctorElement.averageRating.toDouble();

    return GestureDetector(
      onTap: () {
        Get.to(() => DoctorDetailScreen(), arguments: doctorElement);
      },
      child: Container(
        decoration: BoxDecoration(
          color: darkMode ? surfaceElevatedDark : surfaceElevated,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: darkMode ? glassStrokeDark : glassStrokeLight,
            width: 0.5,
          ),
          boxShadow: [
            BoxShadow(
              color: darkMode ? softShadowColorDark : softShadowColor,
              blurRadius: 16,
              offset: const Offset(0, 4),
              spreadRadius: 0,
            ),
          ],
        ),
        width: Get.width / 2 - 24,
        child: Column(
          children: [
            // Doctor image with overlay gradient
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    height: 120,
                    child: doctorElement.profileImage.isNotEmpty
                        ? Image.network(
                            doctorElement.profileImage,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              color: darkMode ? surfaceElevatedDark : lightPrimaryColor,
                              child: Icon(
                                Icons.person,
                                size: 48,
                                color: darkMode ? bodyWhite : secondaryTextColor,
                              ),
                            ),
                          )
                        : Container(
                            color: darkMode ? surfaceElevatedDark : lightPrimaryColor,
                            child: Icon(
                              Icons.person,
                              size: 48,
                              color: darkMode ? bodyWhite : secondaryTextColor,
                            ),
                          ),
                  ),
                ),
                // Bottom fade gradient for text readability
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  height: 48,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.45),
                        ],
                      ),
                    ),
                  ),
                ),
                // Online indicator
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.green.withValues(alpha: 0.3),
                          blurRadius: 4,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            // Info section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Doctor name
                  Text(
                    doctorElement.fullName,
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      letterSpacing: -0.3,
                      color: darkMode ? Colors.white : primaryTextColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                  4.height,
                  // Speciality
                  Text(
                    doctorElement.expert,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: darkMode ? bodyWhite : secondaryTextColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                  8.height,
                  // Rating row with teal accent
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ...List.generate(5, (index) {
                        if (index < rating.floor()) {
                          // Full star
                          return const Icon(Icons.star_rounded, color: appColorAccent, size: 18);
                        } else if (index < rating && rating - index >= 0.5) {
                          // Half star
                          return const Icon(Icons.star_half_rounded, color: appColorAccent, size: 18);
                        } else {
                          // Empty star
                          return Icon(Icons.star_outline_rounded, color: darkMode ? Colors.grey[600] : Colors.grey[300], size: 18);
                        }
                      }),
                      4.width,
                      Text(
                        '${doctorElement.totalReviews}',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: darkMode ? bodyWhite : secondaryTextColor,
                        ),
                      ),
                    ],
                  ),
                  8.height,
                  // Patient served with teal accent
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: darkMode ? appColorSecondary.withValues(alpha: 0.15) : lightSecondaryColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${doctorElement.totalAppointmemt} Patient Served',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: appColorSecondary,
                      ),
                    ),
                  ),
                  8.height,
                  Container(
                    width: double.infinity,
                    height: 34,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [appColorPrimary, appColorSecondary],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        locale.value.bookNow,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
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