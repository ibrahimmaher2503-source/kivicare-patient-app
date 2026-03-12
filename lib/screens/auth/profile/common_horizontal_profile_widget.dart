import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../../components/cached_image_widget.dart';
import '../../../utils/app_common.dart';
import '../../../utils/colors.dart';

class ProfilePicHorizotalWidget extends StatelessWidget {
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
  const ProfilePicHorizotalWidget({
    super.key,
    this.picSize = 70,
    required this.profileImage,
    required this.heroTag,
    this.firstName = "",
    this.lastName = "",
    required this.userName,
    this.subInfo = "",
    this.onCameraTap,
    this.onPicTap,
    this.showCameraIconOnCornar = true,
    this.showOnlyPhoto = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: isDarkMode.value ? surfaceElevatedDark : surfaceElevated,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDarkMode.value ? softShadowColorDark : softShadowColor,
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: onPicTap,
            child: SizedBox(
              height: picSize + 16,
              width: picSize + 16,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // Avatar with accent ring
                  Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: appColorAccent, width: 2),
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
                  // Edit button
                  Positioned(
                    bottom: 0,
                    right: -4,
                    child: GestureDetector(
                      onTap: onCameraTap,
                      child: Container(
                        height: 30,
                        width: 30,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: appColorSecondary,
                          border: Border.all(
                            color: isDarkMode.value ? surfaceElevatedDark : surfaceElevated,
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: appColorSecondary.withValues(alpha: 0.3),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.edit_outlined, color: Colors.white, size: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (!showOnlyPhoto) ...[
            16.width,
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userName,
                  style: GoogleFonts.outfit(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: isDarkMode.value ? Colors.white : primaryTextColor,
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
            ).expand(),
          ],
        ],
      ),
    );
  }
}
