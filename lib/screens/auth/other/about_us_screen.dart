import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../components/app_scaffold.dart';
import '../../../main.dart';
import '../../../utils/app_common.dart';
import '../../../utils/colors.dart';
import '../../../utils/common_base.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffoldNew(
      appBartitleText: locale.value.aboutApp,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section heading
            Padding(
              padding: const EdgeInsets.only(bottom: 8, left: 4),
              child: Text(
                locale.value.aboutApp,
                style: GoogleFonts.outfit(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                  color: isDarkMode.value ? Colors.white : primaryTextColor,
                ),
              ),
            ),
            8.height,
            // About items as refined cards
            ...List.generate(aboutPages.length, (index) {
              if (aboutPages[index].name.isEmpty || aboutPages[index].url.isEmpty) {
                return const SizedBox();
              }
              return GestureDetector(
                onTap: () {
                  commonLaunchUrl(aboutPages[index].url.trim(), launchMode: LaunchMode.externalApplication);
                },
                child: Container(
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
                      // Icon container
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: isDarkMode.value
                              ? appColorSecondary.withValues(alpha: 0.12)
                              : lightSecondaryColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.description_outlined,
                          color: appColorSecondary,
                          size: 20,
                        ),
                      ),
                      16.width,
                      Expanded(
                        child: Text(
                          aboutPages[index].name,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.1,
                            color: isDarkMode.value ? Colors.white : primaryTextColor,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 16,
                        color: secondaryTextColor.withValues(alpha: 0.5),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
