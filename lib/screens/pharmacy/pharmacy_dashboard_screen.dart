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
                    right: 6,
                    top: 6,
                    child: _PharmacyCountBadge(
                      count: globalController.unreadNotificationsCount.value,
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
                    right: 6,
                    top: 6,
                    child: _PharmacyCountBadge(
                      count: globalController.cartCount.value,
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
              const SizedBox(height: 12),
              _buildSearchBar(context),
              _buildPrescriptionHint(),
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
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: surfaceElevated,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: softShadowColor,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: AppTextField(
        textFieldType: TextFieldType.NAME,
        readOnly: true,
        onTap: () => Get.to(() => ProductListScreen()),
        decoration: InputDecoration(
          hintText: locale.value.searchProducts,
          hintStyle: secondaryTextStyle(),
          filled: true,
          fillColor: surfaceElevated,
          prefixIcon: const Icon(Icons.search, color: appColorSecondary),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildPrescriptionHint() {
    return GestureDetector(
      onTap: () => Get.to(() => PrescriptionUploadScreen()),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 6, 20, 2),
        child: Row(
          children: [
            const Icon(Icons.medical_services_outlined,
                size: 14, color: appColorSecondary),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                locale.value.needHelpUploadPrescription,
                style: secondaryTextStyle(size: 12, color: appColorSecondary),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrescriptionCTA() {
    return GestureDetector(
      onTap: () => Get.to(() => PrescriptionUploadScreen()),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
              colors: [gradientSecondaryStart, gradientSecondaryEnd]),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: softShadowColorMedium,
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              Positioned(
                right: -20,
                top: -20,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.08),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(18),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.upload_file_outlined,
                          color: Colors.white, size: 32),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(locale.value.uploadPrescription,
                              style: boldTextStyle(
                                  color: Colors.white, size: 15)),
                          const SizedBox(height: 4),
                          Text(locale.value.uploadPrescriptionInstructions,
                              style: secondaryTextStyle(
                                  color:
                                      Colors.white.withValues(alpha: 0.85),
                                  size: 12)),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_rounded,
                        color: Colors.white, size: 18),
                  ],
                ),
              ),
            ],
          ),
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
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(locale.value.viewAll,
                      style: boldTextStyle(
                          color: appColorSecondary, size: 13)),
                  const Icon(Icons.chevron_right_rounded,
                      size: 16, color: appColorSecondary),
                ],
              ),
            ),
          ],
        ).paddingSymmetric(horizontal: 16),
        Obx(() => HorizontalList(
              itemCount: controller.categories.length,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              spacing: 12,
              itemBuilder: (context, index) {
                final category = controller.categories[index];
                return GestureDetector(
                  onTap: () => Get.to(() => ProductListScreen(
                      categoryId: category.id, title: category.name)),
                  child: Column(
                    children: [
                      Container(
                        width: 84,
                        height: 84,
                        decoration: BoxDecoration(
                          color: surfaceSubtle,
                          shape: BoxShape.circle,
                          border: Border.all(color: whiteBorderColor, width: 1),
                        ),
                        alignment: Alignment.center,
                        child: category.image != null
                            ? CachedNetworkImage(
                                    imageUrl: category.image!,
                                    width: 84,
                                    height: 84,
                                    fit: BoxFit.cover)
                                .cornerRadiusWithClipRRect(42)
                            : const Icon(Icons.category_outlined,
                                color: appColorSecondary, size: 28),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                          width: 84,
                          child: Text(category.name ?? '',
                              style: primaryTextStyle(
                                  size: 12, weight: FontWeight.w600),
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
                    width: 168,
                    decoration: BoxDecoration(
                      color: surfaceElevated,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: whiteBorderColor, width: 1),
                      boxShadow: [
                        BoxShadow(
                            color: softShadowColor,
                            blurRadius: 16,
                            offset: const Offset(0, 6)),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Stack(
                          children: [
                            if (product.images.validate().isNotEmpty)
                              CachedNetworkImage(
                                      imageUrl: product.images![0],
                                      height: 132,
                                      width: 168,
                                      fit: BoxFit.cover)
                                  .cornerRadiusWithClipRRectOnly(
                                      topLeft: 16, topRight: 16)
                            else
                              Container(
                                      height: 132,
                                      width: 168,
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
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: appColorSecondary
                                        .withValues(alpha: 0.95),
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.assignment_outlined,
                                          color: Colors.white, size: 12),
                                      const SizedBox(width: 3),
                                      Text('Rx',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 10,
                                              fontWeight: FontWeight.w700,
                                              height: 1.0)),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(10, 10, 10, 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(product.name ?? '',
                                  style: boldTextStyle(size: 14),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis),
                              const SizedBox(height: 2),
                              Text(product.brandName ?? '',
                                  style: secondaryTextStyle(size: 12)),
                              const SizedBox(height: 6),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text('${product.price} LE',
                                      style: boldTextStyle(
                                          color: appColorPrimary, size: 15)),
                                  if (product.referencePrice != null) ...[
                                    const SizedBox(width: 6),
                                    Text('${product.referencePrice} LE',
                                        style: secondaryTextStyle(
                                            decoration:
                                                TextDecoration.lineThrough,
                                            size: 11,
                                            color: gray400)),
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
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: surfaceSubtle,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: whiteBorderColor, width: 1),
                    ),
                    child: Text(brandName,
                        style: primaryTextStyle(
                            size: 13, weight: FontWeight.w600)),
                  ),
                );
              },
            )),
      ],
    ).paddingSymmetric(vertical: 16);
  }
}

class _PharmacyCountBadge extends StatelessWidget {
  final int count;
  const _PharmacyCountBadge({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
            colors: [gradientSecondaryStart, gradientSecondaryEnd]),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white, width: 1.5),
        boxShadow: [
          BoxShadow(
              color: softShadowColor,
              blurRadius: 6,
              offset: const Offset(0, 2)),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        count > 99 ? '99+' : '$count',
        style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.w700,
            height: 1.1),
        textAlign: TextAlign.center,
      ),
    );
  }
}
