import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../components/app_scaffold.dart';
import '../../components/loader_widget.dart';
import '../../main.dart';
import '../../utils/app_common.dart';
import '../../utils/colors.dart';
import 'components/department_card.dart';
import 'department_list_controller.dart';

class DepartmentListScreen extends StatefulWidget {
  final int? hospitalId;

  const DepartmentListScreen({super.key, this.hospitalId});

  @override
  State<DepartmentListScreen> createState() => _DepartmentListScreenState();
}

class _DepartmentListScreenState extends State<DepartmentListScreen> {
  late final DepartmentListController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(DepartmentListController());
    if (widget.hospitalId != null) {
      controller.hospitalId.value = widget.hospitalId;
    }
  }

  @override
  void dispose() {
    Get.delete<DepartmentListController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => AppScaffoldNew(
        appBartitleText: locale.value.icuDepartments,
        hasLeadingWidget: true,
        appBarVerticalSize: Get.height * 0.12,
        isLoading: controller.isLoading,
        body: Obx(
          () => SnapHelperWidget(
            future: controller.departmentFuture.value,
            initialData: controller.departments.isNotEmpty ? controller.departments : null,
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
                          locale.value.icuDepartments,
                          style: GoogleFonts.outfit(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.3,
                            color: isDarkMode.value ? Colors.white : primaryTextColor,
                          ),
                        ),
                        4.height,
                        Obx(() => Text(
                          '${controller.departments.length} ${locale.value.icuDepartments}',
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

                  // Filter toggles row
                  Obx(() => Row(
                    children: [
                      // Available beds only toggle
                      GestureDetector(
                        onTap: controller.toggleAvailableOnly,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            gradient: controller.availableOnly.value
                                ? const LinearGradient(colors: [Color(0xFF4CAF50), Color(0xFF66BB6A)])
                                : null,
                            color: controller.availableOnly.value
                                ? null
                                : (isDarkMode.value ? surfaceElevatedDark : surfaceElevated),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: controller.availableOnly.value
                                    ? const Color(0xFF4CAF50).withValues(alpha: 0.3)
                                    : (isDarkMode.value ? softShadowColorDark : softShadowColor),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.bed_outlined,
                                size: 16,
                                color: controller.availableOnly.value
                                    ? Colors.white
                                    : (isDarkMode.value ? Colors.white70 : primaryTextColor),
                              ),
                              6.width,
                              Text(
                                locale.value.availableBedsLabel,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.1,
                                  color: controller.availableOnly.value
                                      ? Colors.white
                                      : (isDarkMode.value ? Colors.white70 : primaryTextColor),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      12.width,
                      // Ventilator only toggle
                      GestureDetector(
                        onTap: controller.toggleVentilatorOnly,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            gradient: controller.ventilatorOnly.value
                                ? const LinearGradient(colors: [urgencyCriticalColor, Color(0xFFEF5350)])
                                : null,
                            color: controller.ventilatorOnly.value
                                ? null
                                : (isDarkMode.value ? surfaceElevatedDark : surfaceElevated),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: controller.ventilatorOnly.value
                                    ? urgencyCriticalColor.withValues(alpha: 0.3)
                                    : (isDarkMode.value ? softShadowColorDark : softShadowColor),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.air_rounded,
                                size: 16,
                                color: controller.ventilatorOnly.value
                                    ? Colors.white
                                    : (isDarkMode.value ? Colors.white70 : primaryTextColor),
                              ),
                              6.width,
                              Text(
                                locale.value.needsVentilator,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.1,
                                  color: controller.ventilatorOnly.value
                                      ? Colors.white
                                      : (isDarkMode.value ? Colors.white70 : primaryTextColor),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  )),
                  16.height,

                  // Specialty Filter Chips
                  if (controller.departments.isNotEmpty || controller.selectedSpecialty.value.isNotEmpty)
                    SizedBox(
                      height: 44,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: controller.specialtyFilters.length,
                        separatorBuilder: (_, __) => 12.width,
                        itemBuilder: (context, index) {
                          final filter = controller.specialtyFilters[index];
                          return Obx(() {
                            final isSelected = controller.selectedSpecialty.value == filter['key'];
                            return GestureDetector(
                              onTap: () => controller.onSpecialtyChanged(filter['key']!),
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
                        },
                      ),
                    ),
                  16.height,

                  // Department List with stagger animation
                  Builder(
                    builder: (_) {
                      if (controller.departments.isEmpty) {
                        return _buildEmptyState().paddingTop(Get.height * 0.1);
                      }

                      return Column(
                        children: List.generate(controller.departments.length, (index) {
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
                            child: DepartmentCard(
                              departmentData: controller.departments[index],
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
                    await controller.getDepartments();
                  }
                },
                onSwipeRefresh: () async {
                  controller.page(1);
                  return await controller.getDepartments();
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
          Icons.bed_outlined,
          size: Get.height * 0.07,
          color: appColorPrimary.withValues(alpha: 0.3),
        ),
      ),
    );
  }
}
