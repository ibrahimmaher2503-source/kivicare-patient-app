import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../components/app_scaffold.dart';
import '../../components/loader_widget.dart';
import '../../main.dart';
import '../../utils/app_common.dart';
import '../../utils/colors.dart';
import 'components/test_order_card.dart';
import 'create_test_order_screen.dart';
import 'test_order_list_controller.dart';

class TestOrderListScreen extends StatelessWidget {
  TestOrderListScreen({super.key});

  final TestOrderListController controller = Get.put(TestOrderListController());

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => AppScaffoldNew(
        appBartitleText: locale.value.myTestOrders,
        hasLeadingWidget: true,
        appBarVerticalSize: Get.height * 0.12,
        isLoading: controller.isLoading,
        fabWidget: FloatingActionButton(
          onPressed: () {
            Get.to(() => CreateTestOrderScreen());
          },
          backgroundColor: appColorSecondary,
          child: const Icon(Icons.add, color: Colors.white),
        ),
        body: Obx(
          () => SnapHelperWidget(
            future: controller.orderFuture.value,
            initialData: controller.orders.isNotEmpty ? controller.orders : null,
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
                  16.height,

                  // Status Filter Chips
                  if (controller.orders.isNotEmpty || controller.selectedStatus.value.isNotEmpty)
                    SizedBox(
                      height: 44,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: controller.statusFilters.length,
                        separatorBuilder: (_, __) => 12.width,
                        itemBuilder: (context, index) {
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
                            );
                          });
                        },
                      ),
                    ),
                  16.height,

                  // Order List
                  Builder(
                    builder: (_) {
                      if (controller.orders.isEmpty) {
                        return _buildEmptyState().paddingTop(Get.height * 0.1);
                      }

                      return Column(
                        children: controller.orders.map((order) {
                          return TestOrderCard(
                            orderData: order,
                          ).paddingBottom(16);
                        }).toList(),
                      );
                    },
                  ),
                ],
                onNextPage: () async {
                  if (!controller.isLastPage.value) {
                    controller.page(controller.page.value + 1);
                    await controller.getTestOrders();
                  }
                },
                onSwipeRefresh: () async {
                  controller.page(1);
                  return await controller.getTestOrders();
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
            'No test orders found.',
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
