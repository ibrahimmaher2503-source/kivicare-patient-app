import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../api/pharmacy_apis.dart';
import '../../components/app_scaffold.dart';
import '../../main.dart';
import '../../utils/colors.dart';
import '../../utils/common_base.dart';
import 'model/pharmacy_category_model.dart';
import 'model/pharmacy_product_model.dart';
import 'pharmacy_controller.dart';
import 'product_list_screen.dart';
import 'product_detail_screen.dart';
import 'prescription/prescription_upload_screen.dart';
import 'cart/cart_screen.dart';
import 'notification/pharmacy_notification_screen.dart';

class PharmacyDashboardController extends GetxController {
  RxBool isLoading = false.obs;
  RxList<PharmacyCategory> categories = <PharmacyCategory>[].obs;
  RxList<PharmacyProduct> featuredProducts = <PharmacyProduct>[].obs;
  // TODO(pharmacy): banners field is unused — awaiting backend banner endpoint
  // implementation. Do NOT call fetchBanners() until the endpoint exists.
  RxList<dynamic> banners = <dynamic>[].obs;
  RxList<dynamic> brands = <dynamic>[].obs;

  @override
  void onInit() {
    super.onInit();
    init();
  }

  Future<void> init() async {
    isLoading(true);
    await Future.wait([
      fetchCategories(),
      fetchFeaturedProducts(),
      fetchBrands(),
    ]).whenComplete(() => isLoading(false));
  }

  Future<void> fetchCategories() async {
    try {
      final res = await PharmacyApis.getPharmacyCategories();
      if (res != null && res['data'] != null) {
        categories((res['data'] as List)
            .map((e) => PharmacyCategory.fromJson(e))
            .toList());
      }
    } catch (e) {
      log('Error fetching categories: $e');
    }
  }

  Future<void> fetchFeaturedProducts() async {
    try {
      final res =
          await PharmacyApis.getPharmacyProducts(perPage: 6, sort: 'popular');
      if (res != null && res['data'] != null) {
        featuredProducts((res['data'] as List)
            .map((e) => PharmacyProduct.fromJson(e))
            .toList());
      }
    } catch (e) {
      log('Error fetching featured products: $e');
    }
  }

  Future<void> fetchBrands() async {
    try {
      final res = await PharmacyApis.getBrands();
      if (res != null && res['data'] != null) {
        brands(res['data'] as List);
      }
    } catch (e) {
      log('Error fetching brands: $e');
    }
  }
}

class PharmacyDashboardScreen extends StatelessWidget {
  PharmacyDashboardScreen({super.key});

  final PharmacyDashboardController controller =
      Get.put(PharmacyDashboardController());
  // PharmacyController is registered as permanent via
  // PharmacyController.ensureRegistered() — safe to find directly.
  final PharmacyController globalController =
      PharmacyController.ensureRegistered();

  @override
  Widget build(BuildContext context) {
    return AppScaffoldNew(
      appBartitleText: locale.value.pharmacy,
      isLoading: controller.isLoading,
      actions: [
        Stack(
          alignment: Alignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.notifications_none_outlined),
              onPressed: () => Get.to(() => PharmacyNotificationScreen()),
            ),
            Obx(() => globalController.unreadNotificationsCount.value > 0
                ? Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10)),
                      constraints:
                          const BoxConstraints(minWidth: 16, minHeight: 16),
                      child: Text(
                        '${globalController.unreadNotificationsCount.value}',
                        style:
                            const TextStyle(color: Colors.white, fontSize: 10),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                : const Offstage()),
          ],
        ),
        Stack(
          alignment: Alignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.shopping_cart_outlined),
              onPressed: () => Get.to(() => CartScreen()),
            ),
            Obx(() => globalController.cartCount.value > 0
                ? Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                          color: appColorSecondary,
                          borderRadius: BorderRadius.circular(10)),
                      constraints:
                          const BoxConstraints(minWidth: 16, minHeight: 16),
                      child: Text(
                        '${globalController.cartCount.value}',
                        style:
                            const TextStyle(color: Colors.white, fontSize: 10),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                : const Offstage()),
          ],
        ),
      ],
      body: RefreshIndicator(
        onRefresh: () => controller.init(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSearchBar(context),
              _buildPrescriptionCTA(),
              _buildCategories(),
              _buildFeaturedProducts(),
              _buildBrands(),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return AppTextField(
      textFieldType: TextFieldType.NAME,
      readOnly: true,
      onTap: () => Get.to(() => ProductListScreen()),
      decoration: inputDecoration(
        context,
        hintText: locale.value.searchProducts,
        prefixIcon: const Icon(Icons.search, color: secondaryTextColor),
      ),
    ).paddingAll(16);
  }

  Widget _buildPrescriptionCTA() {
    return GestureDetector(
      onTap: () => Get.to(() => PrescriptionUploadScreen()),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(16),
        decoration: boxDecorationDefault(
          gradient: const LinearGradient(
              colors: [gradientSecondaryStart, gradientSecondaryEnd]),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: boxDecorationDefault(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.upload_file_outlined,
                  color: Colors.white, size: 32),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(locale.value.uploadPrescription,
                      style: boldTextStyle(color: Colors.white)),
                  const SizedBox(height: 4),
                  Text(locale.value.uploadPrescriptionInstructions,
                      style: secondaryTextStyle(
                          color: Colors.white.withValues(alpha: 0.8), size: 12)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildCategories() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(locale.value.categories, style: boldTextStyle(size: 18)),
            TextButton(
                onPressed: () => Get.to(
                    () => ProductListScreen(title: locale.value.pharmacy)),
                child: Text(locale.value.viewAll,
                    style: secondaryTextStyle(color: appColorSecondary))),
          ],
        ).paddingSymmetric(horizontal: 16),
        Obx(() => HorizontalList(
              itemCount: controller.categories.length,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemBuilder: (context, index) {
                final category = controller.categories[index];
                return GestureDetector(
                  onTap: () => Get.to(() => ProductListScreen(
                      categoryId: category.id, title: category.name)),
                  child: Column(
                    children: [
                      Container(
                        width: 70,
                        height: 70,
                        decoration: boxDecorationDefault(
                            color: lightPrimaryColor, shape: BoxShape.circle),
                        child: category.image != null
                            ? CachedNetworkImage(
                                    imageUrl: category.image!,
                                    fit: BoxFit.cover)
                                .cornerRadiusWithClipRRect(35)
                            : const Icon(Icons.category_outlined,
                                color: appColorPrimary),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                          width: 80,
                          child: Text(category.name ?? '',
                              style: primaryTextStyle(size: 12),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis)),
                    ],
                  ),
                );
              },
            )),
      ],
    ).paddingSymmetric(vertical: 16);
  }

  Widget _buildFeaturedProducts() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(locale.value.featuredProducts, style: boldTextStyle(size: 18))
            .paddingSymmetric(horizontal: 16, vertical: 8),
        Obx(() => HorizontalList(
              itemCount: controller.featuredProducts.length,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemBuilder: (context, index) {
                final product = controller.featuredProducts[index];
                return GestureDetector(
                  onTap: () =>
                      Get.to(() => ProductDetailScreen(product: product)),
                  child: Container(
                    width: 160,
                    decoration: boxDecorationDefault(
                        color: context.cardColor,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                              color: softShadowColor,
                              blurRadius: 10,
                              offset: const Offset(0, 4))
                        ]),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Stack(
                          children: [
                            if (product.images.validate().isNotEmpty)
                              CachedNetworkImage(
                                      imageUrl: product.images![0],
                                      height: 120,
                                      width: 160,
                                      fit: BoxFit.cover)
                                  .cornerRadiusWithClipRRectOnly(
                                      topLeft: 16, topRight: 16)
                            else
                              Container(
                                      height: 120,
                                      width: 160,
                                      color: gray100,
                                      child: const Icon(Icons.image_outlined,
                                          color: gray400))
                                  .cornerRadiusWithClipRRectOnly(
                                      topLeft: 16, topRight: 16),
                            if (product.isPrescriptionRequired ?? false)
                              Positioned(
                                top: 8,
                                left: 8,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: boxDecorationDefault(
                                      color: Colors.orange.withValues(alpha: 0.9),
                                      borderRadius: BorderRadius.circular(4)),
                                  child: const Icon(Icons.assignment_outlined,
                                      color: Colors.white, size: 14),
                                ),
                              ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(product.name ?? '',
                                  style: boldTextStyle(size: 14),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis),
                              Text(product.brandName ?? '',
                                  style: secondaryTextStyle(size: 12)),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Text('${product.price} LE',
                                      style: boldTextStyle(
                                          color: appColorSecondary)),
                                  if (product.referencePrice != null) ...[
                                    const SizedBox(width: 4),
                                    Text('${product.referencePrice} LE',
                                        style: secondaryTextStyle(
                                            decoration:
                                                TextDecoration.lineThrough,
                                            size: 10)),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            )),
      ],
    ).paddingSymmetric(vertical: 16);
  }

  Widget _buildBrands() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(locale.value.brands, style: boldTextStyle(size: 18))
            .paddingSymmetric(horizontal: 16, vertical: 8),
        Obx(() => HorizontalList(
              itemCount: controller.brands.length,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemBuilder: (context, index) {
                final brand = controller.brands[index];
                final brandId = brand['id'] as int? ?? 0;
                final brandName = brand['name'] as String? ?? '';
                return GestureDetector(
                  onTap: () => Get.to(() => ProductListScreen(
                      brandId: brandId, title: brandName)),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: boxDecorationDefault(
                        color: context.cardColor,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: context.dividerColor)),
                    child: Text(brandName,
                        style: primaryTextStyle(size: 14)),
                  ),
                );
              },
            )),
      ],
    ).paddingSymmetric(vertical: 16);
  }
}
