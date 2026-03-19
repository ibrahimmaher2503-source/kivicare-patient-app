import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../components/app_scaffold.dart';
import '../../components/loader_widget.dart';
import '../../main.dart';
import '../../utils/app_common.dart';
import '../../utils/colors.dart';
import 'components/request_service_card.dart';
import 'create_request_service_screen.dart';
import 'request_service_list_controller.dart';

class RequestServiceListScreen extends StatelessWidget {
  RequestServiceListScreen({super.key});

  final RequestServiceListController controller = Get.put(RequestServiceListController());

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => AppScaffoldNew(
        appBartitleText: locale.value.myServiceRequests,
        hasLeadingWidget: true,
        appBarVerticalSize: Get.height * 0.12,
        isLoading: controller.isLoading,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded, color: Colors.white),
            onPressed: () {
              Get.to(() => CreateRequestServiceScreen())?.then((_) {
                controller.page(1);
                controller.getServiceRequests();
              });
            },
          ),
        ],
        body: Obx(
          () => SnapHelperWidget(
            future: controller.serviceFuture.value,
            initialData: controller.services.isNotEmpty ? controller.services : null,
            errorBuilder: (error) {
              return _buildEmptyState();
            },
            loadingWidget: controller.isLoading.value ? const LoaderWidget() : const Offstage(),
            onSuccess: (_) {
              return AnimatedScrollView(
                listAnimationType: ListAnimationType.FadeIn,
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  // Decorative gradient header section
                  16.height,
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          appColorPrimary.withValues(alpha: isDarkMode.value ? 0.3 : 0.08),
                          appColorSecondary.withValues(alpha: isDarkMode.value ? 0.15 : 0.04),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDarkMode.value
                            ? Colors.white.withValues(alpha: 0.06)
                            : appColorPrimary.withValues(alpha: 0.06),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: appColorSecondary.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.miscellaneous_services_rounded,
                            color: appColorSecondary,
                            size: 24,
                          ),
                        ),
                        16.width,
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                locale.value.myServiceRequests,
                                style: GoogleFonts.outfit(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -0.3,
                                  color: isDarkMode.value ? Colors.white : appColorPrimary,
                                ),
                              ),
                              4.height,
                              Obx(() => Text(
                                '${controller.services.length} request${controller.services.length != 1 ? 's' : ''}',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: secondaryTextColor,
                                ),
                              )),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  16.height,

                  // Search Bar
                  AppTextField(
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
                      prefixIcon: const Icon(Icons.search, color: secondaryTextColor),
                      filled: true,
                      fillColor: isDarkMode.value ? inputFillColorDark : inputFillColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                  16.height,

                  // Status Filter Chips with AnimatedScale
                  if (controller.services.isNotEmpty || controller.selectedStatus.value.isNotEmpty)
                    AnimatedWrap(
                      spacing: 12,
                      runSpacing: 8,
                      children: List.generate(controller.statusFilters.length, (index) {
                        final filter = controller.statusFilters[index];
                        return Obx(() {
                          final isSelected = controller.selectedStatus.value == filter['key'];
                          return TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0.85, end: 1.0),
                            duration: Duration(milliseconds: 300 + (index * 80)),
                            curve: Curves.easeOutBack,
                            builder: (context, scaleValue, child) {
                              return Transform.scale(
                                scale: scaleValue,
                                child: child,
                              );
                            },
                            child: GestureDetector(
                              onTap: () => controller.onFilterChanged(filter['key']!),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 250),
                                curve: Curves.easeInOut,
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                decoration: BoxDecoration(
                                  gradient: isSelected
                                      ? const LinearGradient(colors: [gradientStart, gradientEnd])
                                      : null,
                                  color: isSelected ? null : (isDarkMode.value ? surfaceElevatedDark : surfaceElevated),
                                  borderRadius: BorderRadius.circular(12),
                                  border: isSelected
                                      ? null
                                      : Border.all(
                                          color: isDarkMode.value
                                              ? Colors.white.withValues(alpha: 0.08)
                                              : appColorPrimary.withValues(alpha: 0.08),
                                          width: 1,
                                        ),
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
                                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
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

                  // Service List with staggered entrance
                  Builder(
                    builder: (_) {
                      if (controller.services.isEmpty) {
                        return _buildEmptyState().paddingTop(Get.height * 0.1);
                      }

                      return Column(
                        children: List.generate(controller.services.length, (index) {
                          final service = controller.services[index];
                          return TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0.0, end: 1.0),
                            duration: Duration(milliseconds: 400 + (index * 80)),
                            curve: Curves.easeOutCubic,
                            builder: (context, value, child) {
                              return Transform.translate(
                                offset: Offset(0, 20 * (1 - value)),
                                child: Opacity(
                                  opacity: value,
                                  child: child,
                                ),
                              );
                            },
                            child: RequestServiceCard(
                              serviceData: service,
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
                    await controller.getServiceRequests();
                  }
                },
                onSwipeRefresh: () async {
                  controller.page(1);
                  return await controller.getServiceRequests();
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
          // Floating animated icon
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 1500),
            curve: Curves.easeInOut,
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(0, -8 * (0.5 + 0.5 * ((2 * value - 1).abs() * 2 - 1).abs() - 0.5)),
                child: Opacity(
                  opacity: 0.3 + 0.7 * value,
                  child: child,
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    appColorPrimary.withValues(alpha: 0.08),
                    appColorSecondary.withValues(alpha: 0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Icon(
                Icons.miscellaneous_services_outlined,
                size: Get.height * 0.08,
                color: appColorPrimary.withValues(alpha: 0.3),
              ),
            ),
          ),
          24.height,
          Text(
            locale.value.noDataFound,
            style: GoogleFonts.outfit(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.5,
              color: isDarkMode.value ? Colors.white : primaryTextColor,
            ),
          ),
          10.height,
          Text(
            '',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              letterSpacing: 0.1,
              color: darkGrayGeneral,
            ),
            textAlign: TextAlign.center,
          ).paddingOnly(left: 12, right: 12),
        ],
      ),
    );
  }
}
