import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../../components/cached_image_widget.dart';
import 'walkthrough_controller.dart';
import '../../utils/colors.dart';

class WalkthroughScreen extends StatelessWidget {
  WalkthroughScreen({super.key});
  final WalkthroughController walkthroughController = Get.put(WalkthroughController());

  @override
  Widget build(BuildContext context) {
    // Transparent status bar for immersive walkthrough experience
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
    ));

    return Scaffold(
      backgroundColor: appColorPrimary,
      body: Stack(
        children: [
          // Full-screen page view with walkthrough images
          PageView.builder(
            itemCount: walkthroughController.walkthroughDetails.length,
            controller: walkthroughController.pageController,
            onPageChanged: (int index) {
              walkthroughController.currentPage(index);
            },
            itemBuilder: (context, index) {
              return CachedImageWidget(
                url: walkthroughController.walkthroughDetails[index].image.validate(),
                fit: BoxFit.cover,
                width: Get.width,
                height: Get.height,
              );
            },
          ),
          // Bottom content overlay with frosted glass effect
          Positioned(
            bottom: 0,
            width: Get.width,
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(32),
                topRight: Radius.circular(32),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 24.0, sigmaY: 24.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: gradientStart.withValues(alpha: 0.65),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(32),
                      topRight: Radius.circular(32),
                    ),
                    border: Border(
                      top: BorderSide(color: glassStrokeLight, width: 0.5),
                    ),
                  ),
                  child: Obx(
                    () => Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 32),
                        // Title with premium typography
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 350),
                          child: Text(
                            walkthroughController.walkthroughDetails[walkthroughController.currentPage.value].title ?? "",
                            key: ValueKey<int>(walkthroughController.currentPage.value),
                            textAlign: TextAlign.center,
                            style: GoogleFonts.outfit(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: -0.5,
                              height: 1.3,
                            ),
                          ),
                        ).paddingSymmetric(horizontal: 40),
                        const SizedBox(height: 16),
                        // Subtitle with refined secondary style
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 350),
                          child: Text(
                            walkthroughController.walkthroughDetails[walkthroughController.currentPage.value].subTitle ?? "",
                            key: ValueKey<String>('sub_${walkthroughController.currentPage.value}'),
                            textAlign: TextAlign.center,
                            style: GoogleFonts.outfit(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: Colors.white.withValues(alpha: 0.72),
                              height: 1.5,
                              letterSpacing: 0.1,
                            ),
                          ),
                        ).paddingSymmetric(horizontal: 40),
                        const SizedBox(height: 40),
                        // Next button with gradient fill
                        Obx(
                          () => Column(
                            children: [
                              CircularPercentIndicator(
                                radius: (walkthroughController.skipBtnSize / 2) + 8,
                                lineWidth: 2.5,
                                percent: (walkthroughController.currentPage.value + 1) / walkthroughController.walkthroughDetails.length,
                                progressColor: appColorAccent,
                                fillColor: Colors.transparent,
                                backgroundColor: Colors.white.withValues(alpha: 0.15),
                                circularStrokeCap: CircularStrokeCap.round,
                                center: GestureDetector(
                                  onTap: () {
                                    walkthroughController.handleNext();
                                  },
                                  child: Container(
                                    width: walkthroughController.skipBtnSize,
                                    height: walkthroughController.skipBtnSize,
                                    margin: const EdgeInsets.all(6),
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [gradientSecondaryStart, gradientSecondaryEnd],
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Color(0x40037F7C),
                                          blurRadius: 16,
                                          offset: Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: Center(
                                      child: Icon(
                                        Icons.arrow_forward_rounded,
                                        color: Colors.white,
                                        size: 24,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 32),
                              // Pill-shaped page indicators
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List<Widget>.generate(
                                  walkthroughController.walkthroughDetails.length,
                                  (index) {
                                    final bool isActive = walkthroughController.currentPage.value == index;
                                    return GestureDetector(
                                      onTap: () {
                                        walkthroughController.pageController.animateToPage(
                                          index,
                                          duration: const Duration(milliseconds: 300),
                                          curve: Curves.easeInOut,
                                        );
                                      },
                                      child: AnimatedContainer(
                                        duration: const Duration(milliseconds: 300),
                                        curve: Curves.easeInOut,
                                        height: 6,
                                        width: isActive ? 32 : 6,
                                        margin: const EdgeInsets.symmetric(horizontal: 4),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(3),
                                          color: isActive ? appColorAccent : Colors.white.withValues(alpha: 0.35),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ).paddingSymmetric(horizontal: 16),
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
