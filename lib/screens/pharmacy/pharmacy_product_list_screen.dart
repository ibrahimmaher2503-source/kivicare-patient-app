import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../components/app_scaffold.dart';
import '../../components/filter_count_badge.dart';
import '../../main.dart';
import '../../utils/colors.dart';
import '../../utils/app_common.dart';
import '../../utils/empty_error_state_widget.dart';
import 'components/pharmacy_product_card.dart';
import 'pharmacy_cart_controller.dart';
import 'pharmacy_cart_screen.dart';
import 'pharmacy_product_list_controller.dart';
import 'pharmacy_product_detail_screen.dart';

class PharmacyProductListScreen extends StatelessWidget {
  final int subcategoryId;
  final String subcategoryName;

  const PharmacyProductListScreen({
    super.key,
    required this.subcategoryId,
    required this.subcategoryName,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<PharmacyProductListController>(
      tag: subcategoryId.toString(),
      init: PharmacyProductListController(),
      initState: (state) => state.controller?.init(subcategoryId),
      builder: (controller) {
        final cartController = Get.isRegistered<PharmacyCartController>()
            ? Get.find<PharmacyCartController>()
            : Get.put(PharmacyCartController());
        return AppScaffold(
          appBarTitle: Text(subcategoryName),
          actions: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                IconButton(
                  icon: const Icon(Icons.shopping_cart_outlined),
                  onPressed: () => Get.to(() => const PharmacyCartScreen()),
                ),
                Obx(() {
                  final count = cartController.itemCount;
                  if (count == 0) return const SizedBox.shrink();
                  return Positioned(
                    top: 4,
                    right: 4,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                        color: gradientSecondaryStart,
                        shape: BoxShape.circle,
                      ),
                      constraints:
                          const BoxConstraints(minWidth: 16, minHeight: 16),
                      child: Text(
                        '$count',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }),
              ],
            ),
          ],
          body: Column(
            children: [
              // Search bar
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: isDarkMode.value ? surfaceElevatedDark : surfaceElevated,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isDarkMode.value
                                ? Colors.white12
                                : appColorPrimary.withValues(alpha: 0.08),
                          ),
                        ),
                        child: TextField(
                          onChanged: controller.onSearchChanged,
                          decoration: InputDecoration(
                            hintText: locale.value.search,
                            hintStyle: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              color: secondaryTextColor,
                            ),
                            prefixIcon: Icon(Icons.search_rounded,
                                color: secondaryTextColor, size: 20),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 12, horizontal: 8),
                          ),
                        ),
                      ),
                    ),
                    12.width,
                    // Filter button with badge
                    Obx(() => Stack(
                          clipBehavior: Clip.none,
                          children: [
                            GestureDetector(
                              onTap: () =>
                                  _showFilterSheet(context, controller),
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: isDarkMode.value
                                      ? surfaceElevatedDark
                                      : surfaceElevated,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isDarkMode.value
                                        ? Colors.white12
                                        : appColorPrimary.withValues(alpha: 0.08),
                                  ),
                                ),
                                child: Icon(Icons.tune_rounded,
                                    color: appColorPrimary, size: 22),
                              ),
                            ),
                            FilterCountBadge(
                                count: controller.activeFilterCount),
                          ],
                        )),
                  ],
                ),
              ),
              // Product list
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value &&
                      controller.products.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (controller.products.isEmpty) {
                    return Center(
                      child: EmptyErrorStateWidget(
                        title: locale.value.noProductsFound,
                        subTitle: locale.value.tryAdjustingYourFilters,
                        onRetry: () => controller.loadProducts(isRefresh: true),
                      ),
                    );
                  }
                  return RefreshIndicator(
                    onRefresh: () => controller.loadProducts(isRefresh: true),
                    child: GridView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 90),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.72,
                      ),
                      itemCount: controller.products.length +
                          (controller.isLastPage ? 0 : 1),
                      itemBuilder: (context, index) {
                        if (index >= controller.products.length) {
                          if (!controller.isLoadingMore.value) {
                            controller.loadMore();
                          }
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                        final product = controller.products[index];
                        return PharmacyProductCard(
                          product: product,
                          onTap: () {
                            Get.to(() => PharmacyProductDetailScreen(),
                                arguments: product.id);
                          },
                        );
                      },
                    ),
                  );
                }),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showFilterSheet(
      BuildContext context, PharmacyProductListController controller) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _PharmacyFilterSheet(controller: controller),
    );
  }
}

class _PharmacyFilterSheet extends StatelessWidget {
  final PharmacyProductListController controller;

  const _PharmacyFilterSheet({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.75),
      decoration: BoxDecoration(
        color: isDarkMode.value ? surfaceElevatedDark : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle + title
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(locale.value.filterProducts,
                    style: GoogleFonts.outfit(
                        fontSize: 18, fontWeight: FontWeight.w700)),
                TextButton(
                  onPressed: () => Get.back(),
                  child: Text(locale.value.cancel),
                ),
              ],
            ),
          ),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Brands section
                  Obx(() {
                    if (controller.availableBrands.isEmpty) {
                      return const SizedBox.shrink();
                    }
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(locale.value.selectBrands,
                            style: GoogleFonts.plusJakartaSans(
                                fontSize: 14, fontWeight: FontWeight.w600)),
                        8.height,
                        ...controller.availableBrands.map((brand) {
                          return Obx(() => CheckboxListTile(
                                dense: true,
                                contentPadding: EdgeInsets.zero,
                                title: Text(brand.name,
                                    style: GoogleFonts.plusJakartaSans(
                                        fontSize: 13)),
                                value: controller.selectedBrandIds
                                    .contains(brand.id),
                                onChanged: (val) {
                                  if (val == true) {
                                    controller.selectedBrandIds.add(brand.id);
                                  } else {
                                    controller.selectedBrandIds.remove(brand.id);
                                  }
                                },
                              ));
                        }),
                        16.height,
                      ],
                    );
                  }),
                  // Product types section
                  Obx(() {
                    if (controller.availableProductTypes.isEmpty) {
                      return const SizedBox.shrink();
                    }
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(locale.value.selectProductTypes,
                            style: GoogleFonts.plusJakartaSans(
                                fontSize: 14, fontWeight: FontWeight.w600)),
                        8.height,
                        ...controller.availableProductTypes.map((type) {
                          return Obx(() => CheckboxListTile(
                                dense: true,
                                contentPadding: EdgeInsets.zero,
                                title: Text(type.name,
                                    style: GoogleFonts.plusJakartaSans(
                                        fontSize: 13)),
                                value: controller.selectedProductTypeIds
                                    .contains(type.id),
                                onChanged: (val) {
                                  if (val == true) {
                                    controller.selectedProductTypeIds
                                        .add(type.id);
                                  } else {
                                    controller.selectedProductTypeIds
                                        .remove(type.id);
                                  }
                                },
                              ));
                        }),
                        16.height,
                      ],
                    );
                  }),
                  // Apply button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        controller.applyFilters();
                        Get.back();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: appColorPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(locale.value.filterProducts,
                          style: GoogleFonts.plusJakartaSans(
                              color: Colors.white,
                              fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
