import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../components/app_scaffold.dart';
import '../../components/governorates_city_picker.dart';
import '../../components/loader_widget.dart';
import '../../components/location_badge.dart';
import '../../main.dart';
import '../../screens/lab_test/model/lab_test_model.dart';
import '../../utils/app_common.dart';
import '../../utils/colors.dart';
import 'lab_search_controller.dart';

class LabSearchScreen extends StatefulWidget {
  const LabSearchScreen({super.key});

  @override
  State<LabSearchScreen> createState() => _LabSearchScreenState();
}

class _LabSearchScreenState extends State<LabSearchScreen> {
  late final LabSearchController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(LabSearchController());
  }

  @override
  void dispose() {
    Get.delete<LabSearchController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => AppScaffoldNew(
        appBartitleText: locale.value.searchLabs,
        hasLeadingWidget: true,
        appBarVerticalSize: Get.height * 0.12,
        isLoading: controller.isLoading,
        body: Obx(
          () => SnapHelperWidget(
            future: controller.itemsFuture.value,
            initialData: controller.items.isNotEmpty ? controller.items : null,
            errorBuilder: (error) {
              return _buildEmptyState();
            },
            loadingWidget: controller.isLoading.value ? const Offstage() : const LoaderWidget(),
            onSuccess: (_) {
              return AnimatedScrollView(
                listAnimationType: ListAnimationType.FadeIn,
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  // Decorative header gradient
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(top: 16),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          appColorPrimary.withValues(alpha: isDarkMode.value ? 0.3 : 0.06),
                          appColorSecondary.withValues(alpha: isDarkMode.value ? 0.2 : 0.04),
                        ],
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          locale.value.searchLabs,
                          style: GoogleFonts.outfit(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.3,
                            color: isDarkMode.value ? Colors.white : primaryTextColor,
                          ),
                        ),
                        4.height,
                        Obx(() => Text(
                              '${controller.items.length} ${locale.value.labs}',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                letterSpacing: 0.1,
                                color: secondaryTextColor,
                              ),
                            )),
                      ],
                    ),
                  ),
                  16.height,

                  // Search Bar
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDarkMode.value ? glassStrokeDark : glassStrokeLight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: isDarkMode.value
                              ? Colors.black.withValues(alpha: 0.15)
                              : appColorPrimary.withValues(alpha: 0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: AppTextField(
                      textStyle: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        letterSpacing: 0.1,
                        color: isDarkMode.value ? Colors.white : primaryTextColor,
                      ),
                      controller: controller.searchCont,
                      textFieldType: TextFieldType.OTHER,
                      onChanged: controller.onSearchChanged,
                      decoration: InputDecoration(
                        hintText: '${locale.value.searchHere}...',
                        hintStyle: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          letterSpacing: 0.1,
                          color: secondaryTextColor,
                        ),
                        prefixIcon: ShaderMask(
                          shaderCallback: (bounds) => const LinearGradient(
                            colors: [appColorSecondary, appColorAccent],
                          ).createShader(bounds),
                          child: const Icon(Icons.search, color: Colors.white),
                        ),
                        filled: true,
                        fillColor: isDarkMode.value ? inputFillColorDark : inputFillColor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                    ),
                  ),
                  16.height,

                  // Governorate / City filter
                  Obx(() => GovernoratesCityPicker(
                        selectedGovernorateId: controller.selectedGovernorateId.value,
                        selectedCityId: controller.selectedCityId.value,
                        onGovernorateChanged: controller.onGovernorateChanged,
                        onCityChanged: controller.onCityChanged,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      )),
                  16.height,

                  // Lab cards
                  Builder(
                    builder: (_) {
                      if (controller.items.isEmpty) {
                        return _buildEmptyState().paddingTop(Get.height * 0.1);
                      }

                      return Column(
                        children: List.generate(controller.items.length, (index) {
                          return TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0.0, end: 1.0),
                            duration: Duration(milliseconds: 400 + (index.clamp(0, 10) * 80)),
                            builder: (context, value, child) {
                              return Opacity(
                                opacity: value,
                                child: Transform.translate(
                                  offset: Offset(0, 20 * (1 - value)),
                                  child: child,
                                ),
                              );
                            },
                            child: _LabCard(lab: controller.items[index]).paddingBottom(16),
                          );
                        }),
                      );
                    },
                  ),
                ],
                onNextPage: () async {
                  if (!controller.isLastPage.value) {
                    controller.page(controller.page.value + 1);
                    await controller.getItems(showLoader: false);
                  }
                },
                onSwipeRefresh: () async {
                  controller.page(1);
                  return await controller.getItems(showLoader: false);
                },
              ).paddingOnly(bottom: 10);
            },
          ),
        ).paddingTop(16),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _FloatingEmptyIcon(),
          30.height,
          Text(
            locale.value.noSearchResults,
            style: GoogleFonts.outfit(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.5,
              color: isDarkMode.value ? Colors.white : primaryTextColor,
            ),
          ),
          8.height,
          Text(
            locale.value.broadenFilters,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              letterSpacing: 0.1,
              color: secondaryTextColor,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Lab Card
// ---------------------------------------------------------------------------

class _LabCard extends StatelessWidget {
  final LabTest lab;

  const _LabCard({required this.lab});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode.value ? surfaceElevatedDark : surfaceElevated,
        borderRadius: BorderRadius.circular(16),
        border: const Border(
          left: BorderSide(color: appColorPrimary, width: 3),
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
          // Name
          Text(
            lab.name,
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.3,
              color: isDarkMode.value ? Colors.white : primaryTextColor,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          8.height,

          // Department & Category
          if (lab.department.isNotEmpty || lab.category != null)
            Row(
              children: [
                if (lab.department.isNotEmpty) ...[
                  Icon(Icons.local_hospital_outlined, size: 14, color: appColorSecondary),
                  4.width,
                  Flexible(
                    child: Text(
                      lab.department,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        letterSpacing: 0.1,
                        color: appColorSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
                if (lab.department.isNotEmpty && lab.category != null) 12.width,
                if (lab.category != null) ...[
                  Icon(Icons.category_outlined, size: 14, color: secondaryTextColor),
                  4.width,
                  Flexible(
                    child: Text(
                      lab.category!.name,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
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

          // Location badge
          if (lab.governorate != null) ...[
            8.height,
            locationBadge(lab.governorate, lab.city),
          ],
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Floating empty-state icon
// ---------------------------------------------------------------------------

class _FloatingEmptyIcon extends StatefulWidget {
  @override
  State<_FloatingEmptyIcon> createState() => _FloatingEmptyIconState();
}

class _FloatingEmptyIconState extends State<_FloatingEmptyIcon> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final offset = math.sin(_controller.value * 2 * math.pi) * 8;
        return Transform.translate(
          offset: Offset(0, offset),
          child: child,
        );
      },
      child: Container(
        width: Get.height * 0.15,
        height: Get.height * 0.15,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              appColorPrimary.withValues(alpha: 0.12),
              appColorSecondary.withValues(alpha: 0.08),
            ],
          ),
        ),
        child: Icon(
          Icons.biotech_outlined,
          size: Get.height * 0.07,
          color: appColorPrimary.withValues(alpha: 0.3),
        ),
      ),
    );
  }
}
