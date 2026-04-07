import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../components/app_scaffold.dart';
import '../../components/cached_image_widget.dart';
import '../../components/governorates_city_picker.dart';
import '../../components/loader_widget.dart';
import '../../components/location_badge.dart';
import '../../main.dart';
import '../../utils/app_common.dart';
import '../../utils/colors.dart';
import '../../utils/constants.dart';
import '../../utils/price_widget.dart';
import '../nurse/model/nurse_model.dart';
import '../nurse/nurse_detail_screen.dart';
import 'components/search_filter_chips.dart';
import 'nurse_search_controller.dart';

class NurseSearchScreen extends StatefulWidget {
  final bool selectionMode;
  final void Function(Nurse nurse)? onNurseSelected;

  const NurseSearchScreen({super.key, this.selectionMode = false, this.onNurseSelected});

  @override
  State<NurseSearchScreen> createState() => _NurseSearchScreenState();
}

class _NurseSearchScreenState extends State<NurseSearchScreen> {
  late final NurseSearchController controller;

  bool get selectionMode => widget.selectionMode;
  void Function(Nurse nurse)? get onNurseSelected => widget.onNurseSelected;

  @override
  void initState() {
    super.initState();
    controller = Get.put(NurseSearchController());
  }

  @override
  void dispose() {
    Get.delete<NurseSearchController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => AppScaffoldNew(
        appBartitleText: locale.value.searchNurses,
        hasLeadingWidget: true,
        appBarVerticalSize: Get.height * 0.12,
        isLoading: controller.isLoading,
        body: Obx(
          () => SnapHelperWidget(
            future: controller.nursesFuture.value,
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
                          locale.value.searchNurses,
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

                  // Availability Filter Chips
                  if (controller.nurses.isNotEmpty || controller.selectedAvailability.value.isNotEmpty)
                    Obx(() => SearchFilterChips(
                      filters: controller.availabilityFilters,
                      selectedKey: controller.selectedAvailability.value,
                      onChanged: controller.onAvailabilityChanged,
                    )),
                  12.height,

                  // Gender Filter Chips
                  if (controller.nurses.isNotEmpty || controller.selectedGender.value.isNotEmpty)
                    Obx(() => SearchFilterChips(
                      filters: controller.genderFilters,
                      selectedKey: controller.selectedGender.value,
                      onChanged: controller.onGenderChanged,
                    )),
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
                            child: _NurseResultCard(
                              nurse: controller.nurses[index],
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

// --- Nurse Result Card ---

class _NurseResultCard extends StatelessWidget {
  final Nurse nurse;
  final VoidCallback? onTap;

  const _NurseResultCard({required this.nurse, this.onTap});

  Color get _availabilityColor {
    switch (nurse.availabilityStatus.toLowerCase()) {
      case NurseAvailabilityConst.available:
        return nurseAvailableColor;
      case NurseAvailabilityConst.busy:
        return nurseBusyColor;
      case NurseAvailabilityConst.offDuty:
        return nurseOffDutyColor;
      default:
        return nurseOffDutyColor;
    }
  }

  String get _availabilityLabel {
    switch (nurse.availabilityStatus.toLowerCase()) {
      case NurseAvailabilityConst.available:
        return locale.value.nurseAvailable;
      case NurseAvailabilityConst.busy:
        return locale.value.nurseBusy;
      case NurseAvailabilityConst.offDuty:
        return locale.value.nurseOffDuty;
      default:
        return nurse.availabilityStatus;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap ?? () {
        hideKeyboard(context);
        Get.to(() => NurseDetailScreen(nurseData: nurse));
      },
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Main card body with left accent border
          Container(
            margin: const EdgeInsets.only(left: 28),
            padding: const EdgeInsets.only(left: 68, top: 16, bottom: 16, right: 16),
            decoration: BoxDecoration(
              color: isDarkMode.value ? surfaceElevatedDark : surfaceElevated,
              borderRadius: BorderRadius.circular(16),
              border: Border(
                left: BorderSide(color: _availabilityColor, width: 3),
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        nurse.name,
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.3,
                          color: isDarkMode.value ? Colors.white : primaryTextColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    8.width,
                    _buildAvailabilityBadge(),
                  ],
                ),
                6.height,
                if (nurse.specialization.isNotEmpty)
                  Text(
                    nurse.specialization,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      letterSpacing: 0.1,
                      color: appColorSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                8.height,
                Row(
                  children: [
                    if (nurse.hourlyRate > 0) ...[
                      Icon(Icons.payments_outlined, size: 14, color: appColorSecondary),
                      3.width,
                      ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: [gradientSecondaryStart, gradientSecondaryEnd],
                        ).createShader(bounds),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            PriceWidget(
                              price: nurse.hourlyRate,
                              size: 12,
                              color: Colors.white,
                            ),
                            Text(
                              locale.value.perHour,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.1,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      10.width,
                    ],
                    // Hourly rate
                    if (nurse.hourlyRate > 0) ...[
                      Icon(Icons.payments_outlined, size: 14, color: secondaryTextColor),
                      3.width,
                      Text(
                        '${nurse.hourlyRate.toStringAsFixed(0)} /hr',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          letterSpacing: 0.1,
                          color: secondaryTextColor,
                        ),
                      ),
                    ],
                  ],
                ),
                if (nurse.governorate != null) ...[
                  8.height,
                  locationBadge(nurse.governorate, nurse.city),
                ],
              ],
            ),
          ),

          // Profile image overlapping the card edge
          Positioned(
            left: 0,
            top: 10,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: appColorPrimary.withValues(alpha: 0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Hero(
                    tag: 'nurse_search_${nurse.id}',
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: CachedImageWidget(
                        url: nurse.profileImage,
                        height: 80,
                        width: 80,
                        fit: BoxFit.cover,
                        radius: 14,
                      ),
                    ),
                  ),
                  // Gradient overlay on profile image for depth
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.15),
                          ],
                          stops: const [0.0, 0.6, 1.0],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom gradient line based on availability
          Positioned(
            bottom: 0,
            left: 44,
            right: 16,
            child: Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    _availabilityColor.withValues(alpha: 0.5),
                    _availabilityColor.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvailabilityBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [
            _availabilityColor.withValues(alpha: 0.18),
            _availabilityColor.withValues(alpha: 0.10),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: _availabilityColor.withValues(alpha: 0.15),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _availabilityColor,
              boxShadow: [
                BoxShadow(
                  color: _availabilityColor.withValues(alpha: 0.5),
                  blurRadius: 4,
                ),
              ],
            ),
          ),
          5.width,
          Text(
            _availabilityLabel,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.1,
              color: _availabilityColor,
            ),
          ),
        ],
      ),
    );
  }
}

// --- Floating Empty Icon ---

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
