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
import '../clinic/model/clinics_res_model.dart';
import 'clinic_search_controller.dart';

class ClinicSearchScreen extends StatefulWidget {
  final bool selectionMode;
  final void Function(Clinic clinic)? onClinicSelected;

  const ClinicSearchScreen({super.key, this.selectionMode = false, this.onClinicSelected});

  @override
  State<ClinicSearchScreen> createState() => _ClinicSearchScreenState();
}

class _ClinicSearchScreenState extends State<ClinicSearchScreen> {
  late final ClinicSearchController controller;

  bool get selectionMode => widget.selectionMode;
  void Function(Clinic clinic)? get onClinicSelected => widget.onClinicSelected;

  @override
  void initState() {
    super.initState();
    controller = Get.put(ClinicSearchController());
  }

  @override
  void dispose() {
    Get.delete<ClinicSearchController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => AppScaffoldNew(
        appBartitleText: locale.value.searchClinics,
        hasLeadingWidget: true,
        appBarVerticalSize: Get.height * 0.12,
        isLoading: controller.isLoading,
        body: Obx(
          () => SnapHelperWidget(
            future: controller.clinicsFuture.value,
            initialData: controller.clinics.isNotEmpty ? controller.clinics : null,
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
                          locale.value.searchClinics,
                          style: GoogleFonts.outfit(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.3,
                            color: isDarkMode.value ? Colors.white : primaryTextColor,
                          ),
                        ),
                        4.height,
                        Obx(() => Text(
                          '${controller.clinics.length} ${locale.value.clinics}',
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
                  16.height,

                  // Clinic List with stagger animation
                  Builder(
                    builder: (_) {
                      if (controller.clinics.isEmpty) {
                        return _buildEmptyState().paddingTop(Get.height * 0.1);
                      }

                      return Column(
                        children: List.generate(controller.clinics.length, (index) {
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
                            child: _ClinicResultCard(
                              clinic: controller.clinics[index],
                              onTap: selectionMode
                                  ? () {
                                      onClinicSelected?.call(controller.clinics[index]);
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
                    await controller.getClinics();
                  }
                },
                onSwipeRefresh: () async {
                  controller.page(1);
                  return await controller.getClinics();
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

// --- Clinic Result Card ---

class _ClinicResultCard extends StatelessWidget {
  final Clinic clinic;
  final VoidCallback? onTap;

  const _ClinicResultCard({required this.clinic, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap ?? () => hideKeyboard(context),
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
                Text(
                  clinic.name,
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.3,
                    color: isDarkMode.value ? Colors.white : primaryTextColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (clinic.specialty.isNotEmpty) ...[
                  6.height,
                  Text(
                    clinic.specialty,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      letterSpacing: 0.1,
                      color: appColorSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                if (clinic.address.isNotEmpty) ...[
                  6.height,
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined, size: 14, color: secondaryTextColor),
                      3.width,
                      Expanded(
                        child: Text(
                          clinic.address,
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
                  ),
                ],
                if (clinic.governorate != null) ...[
                  8.height,
                  locationBadge(clinic.governorate, clinic.governorateCity),
                ],
              ],
            ),
          ),

          // Clinic image overlapping the card edge
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
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: CachedImageWidget(
                      url: clinic.clinicImage,
                      height: 80,
                      width: 80,
                      fit: BoxFit.cover,
                      radius: 14,
                    ),
                  ),
                  // Gradient overlay on image for depth
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

          // Bottom gradient line
          Positioned(
            bottom: 0,
            left: 44,
            right: 16,
            child: Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    appColorPrimary.withValues(alpha: 0.5),
                    appColorPrimary.withValues(alpha: 0.0),
                  ],
                ),
              ),
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
          Icons.local_hospital_outlined,
          size: Get.height * 0.07,
          color: appColorPrimary.withValues(alpha: 0.3),
        ),
      ),
    );
  }
}
