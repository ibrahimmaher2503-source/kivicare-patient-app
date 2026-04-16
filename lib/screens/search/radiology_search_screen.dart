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
import '../../screens/radiology/model/radiology_center_model.dart';
import '../../utils/app_common.dart';
import '../../utils/colors.dart';
import 'components/search_filter_chips.dart';
import 'radiology_search_controller.dart';

class RadiologySearchScreen extends StatefulWidget {
  const RadiologySearchScreen({super.key});

  @override
  State<RadiologySearchScreen> createState() => _RadiologySearchScreenState();
}

class _RadiologySearchScreenState extends State<RadiologySearchScreen> {
  late final RadiologySearchController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(RadiologySearchController());
  }

  @override
  void dispose() {
    Get.delete<RadiologySearchController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => AppScaffoldNew(
        appBartitleText: locale.value.searchRadiology,
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
                          locale.value.searchRadiology,
                          style: GoogleFonts.outfit(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.3,
                            color: isDarkMode.value ? Colors.white : primaryTextColor,
                          ),
                        ),
                        4.height,
                        Obx(() => Text(
                              '${controller.items.length} ${locale.value.radiologyCenters}',
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

                  // Governorate / City filter
                  Obx(() => GovernoratesCityPicker(
                        selectedGovernorateId: controller.selectedGovernorateId.value,
                        selectedCityId: controller.selectedCityId.value,
                        onGovernorateChanged: controller.onGovernorateChanged,
                        onCityChanged: controller.onCityChanged,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      )),

                  // Scan Type Filter Chips
                  Obx(() {
                    if (controller.items.isNotEmpty || controller.selectedScanType.value.isNotEmpty) {
                      return SearchFilterChips(
                        filters: controller.scanTypeFilters,
                        selectedKey: controller.selectedScanType.value,
                        onChanged: controller.onScanTypeChanged,
                      );
                    }
                    return const SizedBox.shrink();
                  }),
                  16.height,

                  // Radiology center cards
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
                            child: _RadiologyCard(center: controller.items[index]).paddingBottom(16),
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
// Radiology Center Card
// ---------------------------------------------------------------------------

class _RadiologyCard extends StatelessWidget {
  final RadiologyCenter center;

  const _RadiologyCard({required this.center});

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
            center.name,
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

          // Scan types
          if (center.scanTypes.isNotEmpty)
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: center.scanTypes.map((type) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: appColorSecondary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  type,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.1,
                    color: appColorSecondary,
                  ),
                ),
              )).toList(),
            ),

          // Location badge
          if (center.governorate != null) ...[
            8.height,
            locationBadge(center.governorate, center.city),
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
          Icons.image_search_outlined,
          size: Get.height * 0.07,
          color: appColorPrimary.withValues(alpha: 0.3),
        ),
      ),
    );
  }
}
