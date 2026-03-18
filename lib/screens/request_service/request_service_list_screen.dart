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
            loadingWidget: controller.isLoading.value ? const Offstage() : const LoaderWidget(),
            onSuccess: (_) {
              return AnimatedScrollView(
                listAnimationType: ListAnimationType.FadeIn,
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  // Search Bar
                  16.height,
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

                  // Status Filter Chips
                  if (controller.services.isNotEmpty || controller.selectedStatus.value.isNotEmpty)
                    AnimatedWrap(
                      spacing: 12,
                      runSpacing: 8,
                      children: List.generate(controller.statusFilters.length, (index) {
                        final filter = controller.statusFilters[index];
                        return Obx(() {
                          final isSelected = controller.selectedStatus.value == filter['key'];
                          return GestureDetector(
                            onTap: () => controller.onFilterChanged(filter['key']!),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                              decoration: BoxDecoration(
                                gradient: isSelected
                                    ? LinearGradient(colors: [gradientStart, gradientEnd])
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
                          );
                        });
                      }),
                    ),
                  16.height,

                  // Service List
                  Builder(
                    builder: (_) {
                      if (controller.services.isEmpty) {
                        return _buildEmptyState().paddingTop(Get.height * 0.1);
                      }

                      return Column(
                        children: controller.services.map((service) {
                          return RequestServiceCard(
                            serviceData: service,
                          ).paddingBottom(16);
                        }).toList(),
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
          Icon(
            Icons.miscellaneous_services_outlined,
            size: Get.height * 0.1,
            color: appColorPrimary.withValues(alpha: 0.3),
          ),
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
          10.height,
          Text(
            locale.value.noDataFound,
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
