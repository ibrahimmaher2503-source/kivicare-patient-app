import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../components/app_scaffold.dart';
import '../../components/governorates_city_picker.dart';
import '../../components/loader_widget.dart';
import '../../main.dart';
import '../../utils/app_common.dart';
import '../../utils/colors.dart';
import 'components/nurse_card.dart';
import 'model/nurse_model.dart';
import 'nurse_list_controller.dart';

class NurseListScreen extends StatefulWidget {
  final bool selectionMode;
  final void Function(Nurse nurse)? onNurseSelected;

  const NurseListScreen({super.key, this.selectionMode = false, this.onNurseSelected});

  @override
  State<NurseListScreen> createState() => _NurseListScreenState();
}

class _NurseListScreenState extends State<NurseListScreen> {
  late final NurseListController controller;

  bool get selectionMode => widget.selectionMode;
  void Function(Nurse nurse)? get onNurseSelected => widget.onNurseSelected;

  @override
  void initState() {
    super.initState();
    controller = Get.put(NurseListController());
  }

  @override
  void dispose() {
    Get.delete<NurseListController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => AppScaffoldNew(
        appBartitleText: locale.value.browseNurses,
        hasLeadingWidget: true,
        appBarVerticalSize: Get.height * 0.12,
        isLoading: controller.isLoading,
        body: Obx(
          () => SnapHelperWidget(
            future: controller.nurseFuture.value,
            initialData: controller.nurses.isNotEmpty ? controller.nurses : null,
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
                          locale.value.browseNurses,
                          style: GoogleFonts.outfit(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.3,
                            color: isDarkMode.value ? Colors.white : primaryTextColor,
                          ),
                        ),
                        4.height,
                        Obx(() => Text(
                          '${controller.nurses.length} ${locale.value.nurses}',
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

                  // Premium Search Bar with glass-style border
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDarkMode.value ? glassStrokeDark : glassStrokeLight,
                      ),
                      boxShadow: [
                        // Inner shadow effect via darker background
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

                  // Availability Filter Chips with scale animation
                  if (controller.nurses.isNotEmpty || controller.selectedAvailability.value.isNotEmpty)
                    AnimatedWrap(
                      spacing: 12,
                      runSpacing: 8,
                      children: List.generate(controller.availabilityFilters.length, (index) {
                        final filter = controller.availabilityFilters[index];
                        return Obx(() {
                          final isSelected = controller.selectedAvailability.value == filter['key'];
                          return GestureDetector(
                            onTap: () => controller.onFilterChanged(filter['key']!),
                            child: AnimatedScale(
                              scale: isSelected ? 1.05 : 1.0,
                              duration: const Duration(milliseconds: 200),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                decoration: BoxDecoration(
                                  gradient: isSelected
                                      ? const LinearGradient(colors: [gradientStart, gradientEnd])
                                      : null,
                                  color: isSelected ? null : (isDarkMode.value ? surfaceElevatedDark : surfaceElevated),
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: isSelected
                                          ? appColorPrimary.withValues(alpha: 0.3)
                                          : (isDarkMode.value ? softShadowColorDark : softShadowColor),
                                      blurRadius: isSelected ? 12 : 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Text(
                                  filter['label']!,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.1,
                                    color: isSelected
                                        ? Colors.white
                                        : (isDarkMode.value ? Colors.white70 : primaryTextColor),
                                  ),
                                ),
                              ),
                            ),
                          );
                        });
                      }),
                    ),
                  16.height,

                  // Nurse List with stagger animation
                  Builder(
                    builder: (_) {
                      if (controller.nurses.isEmpty) {
                        return _buildEmptyState().paddingTop(Get.height * 0.1);
                      }

                      return Column(
                        children: List.generate(controller.nurses.length, (index) {
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
                            child: NurseCard(
                              nurseData: controller.nurses[index],
                              onTap: selectionMode
                                  ? () {
                                      onNurseSelected?.call(controller.nurses[index]);
                                      Get.back();
                                    }
                                  : null,
                            ).paddingBottom(16),
                          );
                        }),
                      );
                    },
                  ),
                ],
                onNextPage: () async {
                  if (!controller.isLastPage.value) {
                    controller.page(controller.page.value + 1);
                    await controller.getNurses();
                  }
                },
                onSwipeRefresh: () async {
                  controller.page(1);
                  return await controller.getNurses();
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
          // Animated floating icon with gradient circle
          _FloatingEmptyIcon(),
          30.height,
          Text(
            locale.value.noDataFound,
            style: GoogleFonts.outfit(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.5,
              color: isDarkMode.value ? Colors.white : primaryTextColor,
            ),
          ),
        ],
      ),
    );
  }
}

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
          Icons.medical_services_outlined,
          size: Get.height * 0.07,
          color: appColorPrimary.withValues(alpha: 0.3),
        ),
      ),
    );
  }
}
