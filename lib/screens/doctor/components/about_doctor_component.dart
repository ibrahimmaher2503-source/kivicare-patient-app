import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:kivicare_patient/components/app_scaffold.dart';

import '../../../components/cached_image_widget.dart';
import '../../../generated/assets.dart';
import '../../../main.dart';
import '../../../utils/app_common.dart';
import '../../../utils/colors.dart';
import '../../../utils/common_base.dart';
import '../model/doctor_list_res.dart';

class AboutDoctorComponent extends StatelessWidget {
  final Doctor doctorData;

  const AboutDoctorComponent({super.key, required this.doctorData});

  @override
  Widget build(BuildContext context) {
    return AppScaffoldNew(
      appBartitleText: locale.value.aboutMyself,
      appBarVerticalSize: Get.height * 0.12,
      body: AnimatedScrollView(
        padding: const EdgeInsets.all(24),
        children: [
          /// About section
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                locale.value.about,
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                  color: isDarkMode.value ? Colors.white : appColorPrimary,
                ),
              ),
              16.height,
              Container(
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
                child: ReadMoreText(
                  parseHtmlString(doctorData.aboutSelf),
                  trimLines: 4,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: secondaryTextColor,
                    height: 1.6,
                  ),
                  colorClickableText: appColorSecondary,
                  trimMode: TrimMode.Line,
                  textAlign: TextAlign.justify,
                  trimCollapsedText: " ...${locale.value.readMore}",
                  trimExpandedText: locale.value.readLess,
                  locale: Localizations.localeOf(context),
                ),
              ),
            ],
          ).paddingBottom(24).visible(doctorData.aboutSelf.isNotEmpty),

          /// Contact Info section
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                locale.value.contactInfo,
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                  color: isDarkMode.value ? Colors.white : appColorPrimary,
                ),
              ),
              16.height,
              Container(
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (doctorData.email.isNotEmpty)
                      GestureDetector(
                        onTap: () {
                          launchMail(doctorData.email);
                        },
                        behavior: HitTestBehavior.translucent,
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: isDarkMode.value ? appColorAccent.withValues(alpha: 0.12) : lightAccentColor,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const CachedImageWidget(url: Assets.iconsIcMail, color: appColorSecondary, width: 14, height: 14),
                            ),
                            12.width,
                            Text(
                              doctorData.email,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: secondaryTextColor,
                              ),
                            ),
                          ],
                        ),
                      ).paddingBottom(16),
                    if (doctorData.mobile.isNotEmpty)
                      GestureDetector(
                        onTap: () {
                          launchCall(doctorData.mobile);
                        },
                        behavior: HitTestBehavior.translucent,
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: isDarkMode.value ? appColorAccent.withValues(alpha: 0.12) : lightAccentColor,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const CachedImageWidget(url: Assets.iconsIcCall, color: appColorSecondary, width: 14, height: 14),
                            ),
                            12.width,
                            Text(
                              doctorData.mobile,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: secondaryTextColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ).paddingBottom(24).visible(doctorData.email.isNotEmpty || doctorData.mobile.isNotEmpty),

          /// Specialization section
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                locale.value.specialization,
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                  color: isDarkMode.value ? Colors.white : appColorPrimary,
                ),
              ),
              16.height,
              Container(
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
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isDarkMode.value ? appColorAccent.withValues(alpha: 0.12) : lightAccentColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const CachedImageWidget(url: Assets.iconsIcSpecialization, color: appColorSecondary, width: 14, height: 14),
                    ),
                    12.width,
                    Text(
                      doctorData.expert,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: secondaryTextColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ).paddingBottom(24).visible(doctorData.expert.isNotEmpty),

          /// Experience section
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                locale.value.experience,
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                  color: isDarkMode.value ? Colors.white : appColorPrimary,
                ),
              ),
              16.height,
              Container(
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
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isDarkMode.value ? appColorAccent.withValues(alpha: 0.12) : lightAccentColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const CachedImageWidget(url: Assets.iconsIcExperience, color: appColorSecondary, width: 14, height: 14),
                    ),
                    12.width,
                    Text(
                      doctorData.experience,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: secondaryTextColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ).visible(doctorData.experience.isNotEmpty),
        ],
      ),
    );
  }
}
