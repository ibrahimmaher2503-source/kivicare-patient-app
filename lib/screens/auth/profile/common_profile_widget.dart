import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:kivicare_patient/utils/colors.dart';
import '../../../components/cached_image_widget.dart';
import '../../../utils/app_common.dart';

class ProfilePicWidget extends StatelessWidget {
  final double picSize;
  final String profileImage;
  final String heroTag;
  final String firstName;
  final String lastName;
  final String userName;
  final String subInfo;
  final Function()? onCameraTap;
  final Function()? onPicTap;
  final bool showOnlyPhoto;
  final bool showCameraIconOnCornar;
  const ProfilePicWidget({
    super.key,
    this.picSize = 130,
    required this.profileImage,
    required this.heroTag,
    this.firstName = "",
    this.lastName = "",
    this.userName = "",
    this.subInfo = "",
    this.onCameraTap,
    this.onPicTap,
    this.showCameraIconOnCornar = true,
    this.showOnlyPhoto = false,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            Stack(
              children: [
                Align(
                  alignment: Alignment.topCenter,
                  child: GestureDetector(
                    onTap: onPicTap,
                    child: Stack(
                      children: [
                        // Avatar with accent border ring
                        Container(
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: appColorAccent, width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: isDarkMode.value ? softShadowColorDark : appColorAccent.withValues(alpha: 0.15),
                                blurRadius: 16,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Hero(
                            tag: heroTag,
                            child: CachedImageWidget(
                              url: profileImage,
                              firstName: firstName,
                              lastName: lastName,
                              height: picSize,
                              width: picSize,
                              fit: BoxFit.cover,
                              circle: true,
                            ),
                          ),
                        ),
                        // Camera button
                        Positioned(
                          top: picSize * 3 / 4 + 6,
                          left: picSize * 3 / 4 + 6,
                          child: GestureDetector(
                            onTap: onCameraTap,
                            child: Container(
                              padding: const EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isDarkMode.value ? surfaceElevatedDark : Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: isDarkMode.value ? softShadowColorDark : softShadowColorMedium,
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [gradientSecondaryStart, gradientSecondaryEnd],
                                  ),
                                ),
                                child: const Icon(
                                  Icons.camera_alt_outlined,
                                  size: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ).visible(showCameraIconOnCornar)
                      ],
                    ),
                  ),
                ),
              ],
            ),
            if (!showOnlyPhoto) ...[
              16.height,
              Text(
                userName,
                style: GoogleFonts.outfit(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: isDarkMode.value ? whiteTextColor : primaryTextColor,
                  letterSpacing: -0.3,
                ),
              ),
              4.height,
              Text(
                subInfo,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  color: secondaryTextColor,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}
