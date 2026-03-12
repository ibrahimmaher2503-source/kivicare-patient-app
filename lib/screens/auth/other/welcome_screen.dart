import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:kivicare_patient/utils/colors.dart';
import '../../../components/app_scaffold.dart';
import '../../../generated/assets.dart';
import '../../../main.dart';
import '../../../utils/app_common.dart';
import '../../dashboard/dashboard_screen.dart';
import '../../home/home_controller.dart';
import '../sign_in_sign_up/signin_screen.dart';
import 'welcome_controller.dart';

class WelcomeScreen extends StatelessWidget {
  WelcomeScreen({super.key});
  final WelcomeScreenController optionScreenController = Get.put(WelcomeScreenController());

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      hideAppBar: true,
      isLoading: optionScreenController.isLoading,
      body: Stack(
        children: [
          SizedBox(
            height: Get.height,
            width: Get.width,
          ),
          Positioned(
            width: Get.width,
            top: 0,
            child: Image.asset(
              Assets.imagesWelcomeBg,
              width: Get.width,
              fit: BoxFit.fitWidth,
            ),
          ),
          Positioned(
            bottom: 0,
            child: Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  width: MediaQuery.of(context).size.width,
                  height: optionScreenController.bottomWidgetHeight,
                  decoration: BoxDecoration(
                    color: isDarkMode.value ? surfaceElevatedDark : surfaceElevated,
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(30),
                      topLeft: Radius.circular(30),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isDarkMode.value ? softShadowColorDark : softShadowColor,
                        blurRadius: 24,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Spacer(),
                      Text(
                        locale.value.exploreTopClinicsWithAdvancedServicesTailored,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.outfit(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.5,
                          color: isDarkMode.value ? Colors.white : primaryTextColor,
                        ),
                      ),
                      16.height,
                      Text(
                        locale.value.discoverYourIdealClinicWithOurPersonalizedSea,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          color: secondaryTextColor,
                          letterSpacing: 0.1,
                        ),
                        textAlign: TextAlign.center,
                      ).paddingSymmetric(horizontal: 24),
                      const Spacer(),
                      Row(
                        children: [
                          // Sign In - navy outline button
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                Get.to(
                                  () => SignInScreen(),
                                  arguments: true,
                                  binding: BindingsBuilder(() {}),
                                );
                              },
                              child: Container(
                                height: 52,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: isDarkMode.value
                                      ? appColorPrimary.withValues(alpha: 0.12)
                                      : lightPrimaryColor,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isDarkMode.value
                                        ? appColorPrimary.withValues(alpha: 0.2)
                                        : appColorPrimary.withValues(alpha: 0.08),
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  locale.value.signIn,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: isDarkMode.value ? Colors.white : appColorPrimary,
                                    letterSpacing: 0.1,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          24.width,
                          // Explore - gradient CTA
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                Get.offAll(() => DashboardScreen(), binding: BindingsBuilder(() {
                                  Get.put(HomeController());
                                }));
                              },
                              child: Container(
                                height: 52,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [gradientSecondaryStart, gradientSecondaryEnd],
                                  ),
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
                                  locale.value.explore,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                    letterSpacing: 0.1,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ).paddingSymmetric(horizontal: 24).paddingBottom(30),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
