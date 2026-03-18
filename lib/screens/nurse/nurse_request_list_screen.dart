import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../components/app_scaffold.dart';
import '../../components/loader_widget.dart';
import '../../main.dart';
import '../../utils/app_common.dart';
import '../../utils/colors.dart';
import 'components/nurse_request_card.dart';
import 'create_nurse_request_screen.dart';
import 'nurse_request_list_controller.dart';

class NurseRequestListScreen extends StatelessWidget {
  NurseRequestListScreen({super.key});

  final NurseRequestListController controller = Get.put(NurseRequestListController());

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => AppScaffoldNew(
        appBartitleText: locale.value.myNurseRequests,
        hasLeadingWidget: true,
        appBarVerticalSize: Get.height * 0.12,
        isLoading: controller.isLoading,
        actions: [
          controller.nurseRequests.isNotEmpty
              ? IconButton(
                  onPressed: () {
                    Get.to(() => CreateNurseRequestScreen());
                  },
                  icon: const Icon(Icons.add_circle_outline_rounded, size: 28, color: Colors.white),
                ).paddingOnly(right: 8)
              : const SizedBox(),
        ],
        body: Obx(
          () => SnapHelperWidget(
            future: controller.nurseRequestFuture.value,
            initialData: controller.nurseRequests.isNotEmpty ? controller.nurseRequests : null,
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
                  // Status Filter Chips
                  if (controller.nurseRequests.isNotEmpty || controller.selectedStatus.value.isNotEmpty)
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

                  // Request List
                  Builder(
                    builder: (_) {
                      if (controller.nurseRequests.isEmpty) {
                        return _buildEmptyState().paddingTop(Get.height * 0.1);
                      }

                      return Column(
                        children: controller.nurseRequests.map((request) {
                          return NurseRequestCard(
                            requestData: request,
                            onUpdateRequest: () {
                              controller.page(1);
                              controller.getNurseRequests();
                            },
                          ).paddingBottom(16);
                        }).toList(),
                      );
                    },
                  ),
                ],
                onNextPage: () async {
                  if (!controller.isLastPage.value) {
                    controller.page(controller.page.value + 1);
                    await controller.getNurseRequests();
                  }
                },
                onSwipeRefresh: () async {
                  controller.page(1);
                  return await controller.getNurseRequests();
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
            Icons.assignment_outlined,
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
            'You have no nurse requests yet.',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              letterSpacing: 0.1,
              color: darkGrayGeneral,
            ),
            textAlign: TextAlign.center,
          ).paddingOnly(left: 12, right: 12),
          30.height,
          _buildAddButton(),
        ],
      ),
    );
  }

  Widget _buildAddButton() {
    return GestureDetector(
      onTap: () {
        Get.to(() => CreateNurseRequestScreen());
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [gradientSecondaryStart, gradientSecondaryEnd]),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: appColorSecondary.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Text(
          locale.value.createNurseRequest,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.1,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
