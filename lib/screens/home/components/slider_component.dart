import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kivicare_patient/utils/colors.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../components/cached_image_widget.dart';
import '../../../utils/common_base.dart';
import '../../../utils/constants.dart';
import '../../category/category_screen.dart';
import '../../service/service_detail_screen.dart';
import '../home_controller.dart';

class SliderComponent extends StatefulWidget {
  const SliderComponent({super.key});

  @override
  State<SliderComponent> createState() => _SliderComponentState();
}

class _SliderComponentState extends State<SliderComponent> {
  final HomeController homeScreenController = Get.find();
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startAutoScroll();
  }

  void _startAutoScroll() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 5), (Timer timer) {
      if (homeScreenController.dashboardData.value.slider.isNotEmpty) {
        int nextPage = homeScreenController.sliderCurrentPage.value + 1;
        if (nextPage >= homeScreenController.dashboardData.value.slider.length) {
          nextPage = 0;
        }
        homeScreenController.sliderPageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 650),
          curve: Curves.easeInOutCubic,
        );
        homeScreenController.sliderCurrentPage(nextPage);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (homeScreenController.dashboardData.value.slider.isEmpty) {
      return const Offstage();
    }

    final total = homeScreenController.dashboardData.value.slider.length;

    return Obx(() {
      final currentPage = homeScreenController.sliderCurrentPage.value;

      return SizedBox(
        height: 200,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // ── PageView ────────────────────────────────────────────────────
            PageView.builder(
              controller: homeScreenController.sliderPageController,
              onPageChanged: (int page) {
                hideKeyboard(context);
                homeScreenController.sliderCurrentPage(page);
              },
              itemCount: total,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    final slide =
                        homeScreenController.dashboardData.value.slider[index];
                    if (slide.link.isURL) {
                      commonLaunchUrl(
                        slide.link,
                        launchMode: LaunchMode.externalApplication,
                      );
                    } else if (slide.type == BannerType.CATEGORY) {
                      Get.to(
                        () => CategoryScreen(),
                        duration: const Duration(milliseconds: 800),
                      );
                    } else if (slide.type == BannerType.SERVICE) {
                      Get.to(
                        () => ServiceDetailScreen(),
                        arguments: slide.linkId,
                      );
                    }
                  },
                  behavior: HitTestBehavior.translucent,
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: softShadowColorMedium,
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                          spreadRadius: 0,
                        ),
                        BoxShadow(
                          color: appColorPrimary.withValues(alpha: 0.12),
                          blurRadius: 32,
                          offset: const Offset(0, 16),
                          spreadRadius: -4,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          // Banner image
                          CachedImageWidget(
                            url: homeScreenController
                                .dashboardData.value.slider[index].sliderImage,
                            fit: BoxFit.cover,
                            usePlaceholderIfUrlEmpty: false,
                            width: Get.width,
                            height: 200,
                          ),
                          // Bottom gradient overlay for depth
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            height: 80,
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                  colors: [
                                    Colors.black.withValues(alpha: 0.40),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                            ),
                          ),
                          // Top-right slide counter badge
                          Positioned(
                            top: 12,
                            right: 12,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.45),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.25),
                                  width: 0.5,
                                ),
                              ),
                              child: Text(
                                '${index + 1} / $total',
                                style: GoogleFonts.plusJakartaSans(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),

            // ── Indicator dots ───────────────────────────────────────────────
            Positioned(
              bottom: -16,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List<Widget>.generate(
                  total,
                  (index) {
                    final bool isActive = currentPage == index;
                    return GestureDetector(
                      onTap: () {
                        homeScreenController.sliderPageController.animateToPage(
                          index,
                          duration: const Duration(milliseconds: 350),
                          curve: Curves.easeInOut,
                        );
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOutCubic,
                        height: isActive ? 8 : 6,
                        width: isActive ? 28 : 6,
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          gradient: isActive
                              ? const LinearGradient(
                                  colors: [gradientSecondaryStart, appColorAccent],
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                )
                              : null,
                          color: isActive
                              ? null
                              : appColorPrimary.withValues(alpha: 0.25),
                          boxShadow: isActive
                              ? [
                                  BoxShadow(
                                    color: appColorSecondary
                                        .withValues(alpha: 0.4),
                                    blurRadius: 6,
                                    spreadRadius: 0,
                                  ),
                                ]
                              : [],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ).paddingTop(16);
    });
  }
}
