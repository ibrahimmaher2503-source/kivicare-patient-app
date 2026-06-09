import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../api/pharmacy_apis.dart';
import '../../components/app_scaffold.dart';
import '../../main.dart';
import '../../utils/colors.dart';
import '../../utils/empty_error_state_widget.dart';
import 'model/pharmacy_category_model.dart';
import 'model/pharmacy_product_model.dart';
import 'pharmacy_controller.dart';
import 'product_list_screen.dart';
import 'product_detail_screen.dart';
import 'prescription/prescription_upload_screen.dart';
import 'cart/cart_screen.dart';
import 'notification/pharmacy_notification_screen.dart';
import 'utils/pharmacy_icon_badge.dart';

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

  // Reuse the existing instance if already registered so the controller's
  // onInit() (which fetches categories/products/brands) runs only once, even
  // if GetX reconstructs this widget during the route transition.
  final PharmacyDashboardController controller =
      Get.isRegistered<PharmacyDashboardController>()
          ? Get.find<PharmacyDashboardController>()
          : Get.put(PharmacyDashboardController());
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
        _AppBarActionIcon(
          icon: Icons.notifications_none_outlined,
          onTap: () => Get.to(() => PharmacyNotificationScreen()),
          badgeCount: globalController.unreadNotificationsCount,
        ),
        const SizedBox(width: 4),
        _AppBarActionIcon(
          icon: Icons.shopping_cart_outlined,
          onTap: () => Get.to(() => CartScreen()),
          badgeCount: globalController.cartCount,
        ),
        const SizedBox(width: 8),
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
              _buildCatalogSections(),
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
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 12, right: 8),
            child: const PharmacyIconBadge(
              icon: Icons.search,
              size: PharmacyIconSize.sm,
              style: PharmacyIconStyle.tinted,
              circular: true,
            ),
          ),
          prefixIconConstraints:
              const BoxConstraints(minWidth: 52, minHeight: 36),
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
            Container(
              width: 22,
              height: 22,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: appColorSecondary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(7),
              ),
              child: const Icon(Icons.medical_services_outlined,
                  size: 12, color: appColorSecondary),
            ),
            const SizedBox(width: 8),
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
                      width: 56,
                      height: 56,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.35),
                          width: 1,
                        ),
                      ),
                      child: Container(
                        width: 38,
                        height: 38,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.95),
                          borderRadius: BorderRadius.circular(11),
                        ),
                        child: const Icon(Icons.upload_file_rounded,
                            color: gradientSecondaryEnd, size: 22),
                      ),
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

  /// Renders the catalog (categories / featured products / brands).
  /// Each section is hidden when its own data is empty, and a single
  /// consolidated empty state is shown when the whole catalog is empty
  /// (e.g. the backend has no pharmacy data seeded yet).
  Widget _buildCatalogSections() {
    return Obx(() {
      final loading = controller.isLoading.value;
      final hasCategories = controller.categories.isNotEmpty;
      final hasProducts = controller.featuredProducts.isNotEmpty;
      final hasBrands = controller.brands.isNotEmpty;

      if (!loading && !hasCategories && !hasProducts && !hasBrands) {
        return _buildEmptyCatalog();
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (hasCategories) _buildCategories(),
          if (hasProducts) _buildFeaturedProducts(),
          if (hasBrands) _buildBrands(),
        ],
      );
    });
  }

  Widget _buildEmptyCatalog() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
      child: Column(
        children: [
          const EmptyStateWidget(height: 160),
          const SizedBox(height: 16),
          Text(
            locale.value.noProductsFound,
            style: boldTextStyle(size: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            locale.value.needHelpUploadPrescription,
            style: secondaryTextStyle(size: 13),
            textAlign: TextAlign.center,
          ),
        ],
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
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              surfaceSubtle,
                              appColorSecondary.withValues(alpha: 0.06),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          border: Border.all(
                            color: appColorSecondary.withValues(alpha: 0.14),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: softShadowColor,
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: category.image != null
                            ? CachedNetworkImage(
                                    imageUrl: category.image!,
                                    width: 84,
                                    height: 84,
                                    fit: BoxFit.cover)
                                .cornerRadiusWithClipRRect(42)
                            : Container(
                                width: 44,
                                height: 44,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: appColorSecondary
                                      .withValues(alpha: 0.14),
                                ),
                                child: const Icon(Icons.category_rounded,
                                    color: appColorSecondary, size: 24),
                              ),
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
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      surfaceSubtle,
                                      appColorSecondary.withValues(alpha: 0.05),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                ),
                                child: const PharmacyIconBadge(
                                  icon: Icons.medication_outlined,
                                  size: PharmacyIconSize.lg,
                                  style: PharmacyIconStyle.tinted,
                                ),
                              ).cornerRadiusWithClipRRectOnly(
                                  topLeft: 16, topRight: 16),
                            if (product.isPrescriptionRequired ?? false)
                              Positioned(
                                top: 8,
                                left: 8,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 9, vertical: 5),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        gradientSecondaryStart,
                                        gradientSecondaryEnd,
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(999),
                                    boxShadow: [
                                      BoxShadow(
                                        color: softShadowColorMedium,
                                        blurRadius: 8,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                          Icons.medical_information_rounded,
                                          color: Colors.white,
                                          size: 12),
                                      const SizedBox(width: 4),
                                      Text('Rx',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 10,
                                              fontWeight: FontWeight.w700,
                                              letterSpacing: 0.4,
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

class _AppBarActionIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final RxInt badgeCount;

  const _AppBarActionIcon({
    required this.icon,
    required this.onTap,
    required this.badgeCount,
  });

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      radius: 26,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: appColorSecondary.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: appColorSecondary.withValues(alpha: 0.16),
                  width: 1,
                ),
              ),
              child: Icon(icon, size: 20, color: appColorSecondary),
            ),
            Obx(() => badgeCount.value > 0
                ? Positioned(
                    right: -4,
                    top: -4,
                    child: _PharmacyCountBadge(count: badgeCount.value),
                  )
                : const Offstage()),
          ],
        ),
      ),
    );
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
