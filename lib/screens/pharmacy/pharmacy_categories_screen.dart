import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../components/app_scaffold.dart';
import '../../main.dart';
import '../../utils/empty_error_state_widget.dart';
import '../../utils/colors.dart';
import 'components/pharmacy_category_card.dart';
import 'pharmacy_cart_controller.dart';
import 'pharmacy_cart_screen.dart';
import 'pharmacy_categories_controller.dart';
import 'pharmacy_order_list_screen.dart';
import 'pharmacy_product_list_screen.dart';

class PharmacyCategoriesScreen extends StatelessWidget {
  const PharmacyCategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetX<PharmacyCategoriesController>(
      init: PharmacyCategoriesController(),
      builder: (controller) {
        // Ensure cart controller is registered
        final cartController = Get.isRegistered<PharmacyCartController>()
            ? Get.find<PharmacyCartController>()
            : Get.put(PharmacyCartController());
        return AppScaffold(
          appBarTitle: Text(
            controller.showingSubcategories.value
                ? (controller.selectedParent.value?.name ?? locale.value.pharmacySubCategories)
                : locale.value.pharmacyMarketplace,
          ),
          isLoading: controller.isLoading,
          leadingWidget: controller.showingSubcategories.value
              ? IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded),
                  onPressed: controller.goBack,
                )
              : null,
          actions: [
            // Order history
            IconButton(
              icon: const Icon(Icons.receipt_long_outlined),
              onPressed: () => Get.to(() => const PharmacyOrderListScreen()),
              tooltip: locale.value.myPharmacyOrders,
            ),
            // Cart icon with badge
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
                      constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
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
          body: controller.isLoading.value
              ? const SizedBox.shrink()
              : controller.errorMessage.value != null
                  ? Center(
                      child: EmptyErrorStateWidget(
                        title: locale.value.error,
                        subTitle: controller.errorMessage.value,
                        onRetry: controller.loadCategories,
                      ),
                    )
                  : controller.categories.isEmpty
                      ? Center(
                          child: EmptyErrorStateWidget(
                            title: locale.value.noData,
                            subTitle: controller.showingSubcategories.value
                                ? locale.value.pharmacySubCategories
                                : locale.value.pharmacyCategories,
                            onRetry: controller.loadCategories,
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: () async {
                            if (controller.showingSubcategories.value &&
                                controller.selectedParent.value != null) {
                              await controller.loadSubcategories(
                                  controller.selectedParent.value!.id);
                            } else {
                              await controller.loadCategories();
                            }
                          },
                          child: GridView.builder(
                            padding: const EdgeInsets.all(16),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              childAspectRatio: 0.85,
                            ),
                            itemCount: controller.categories.length,
                            itemBuilder: (context, index) {
                              final category = controller.categories[index];
                              return PharmacyCategoryCard(
                                name: category.name,
                                imageUrl: category.image,
                                onTap: () {
                                  if (!controller.showingSubcategories.value) {
                                    controller.selectedParent.value = category;
                                    controller.loadSubcategories(category.id);
                                  } else {
                                    Get.to(() => PharmacyProductListScreen(
                                          subcategoryId: category.id,
                                          subcategoryName: category.name,
                                        ));
                                  }
                                },
                              );
                            },
                          ),
                        ),
        );
      },
    );
  }
}
