import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../api/pharmacy_apis.dart';
import '../../components/app_scaffold.dart';
import '../../main.dart';
import '../../network/network_utils.dart';
import '../../utils/colors.dart';
import '../../utils/common_base.dart';
import '../../utils/price_widget.dart';
import 'model/pharmacy_product_model.dart';
import 'pharmacy_controller.dart';
import 'utils/pharmacy_constants.dart';
import 'utils/pharmacy_product_rules.dart';

class ProductDetailController extends GetxController {
  final PharmacyProduct product;
  RxInt quantity = 1.obs;
  RxBool isAddingToCart = false.obs;
  RxInt currentImageIndex = 0.obs;
  late final PageController pageController;

  ProductDetailController({required this.product});

  @override
  void onInit() {
    super.onInit();
    pageController = PageController();
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }

  void incrementQuantity() {
    int max = product.maxOrderQuantity ?? PharmacyConstants.defaultMaxQuantity;
    if (quantity.value < max &&
        quantity.value < (product.stockQuantity ?? 100)) {
      quantity.value++;
    } else {
      toast(locale.value.maximumQuantityReached);
    }
  }

  void decrementQuantity() {
    if (quantity.value > 1) {
      quantity.value--;
    }
  }

  Future<void> addToCart() async {
    if (product.id == null) {
      toast(locale.value.productUnavailable);
      return;
    }
    if (pharmacyProductIsOutOfStock(product.stockQuantity)) {
      toast(locale.value.outOfStock);
      return;
    }
    if (isAddingToCart.value) return;
    isAddingToCart(true);

    try {
      final res = await PharmacyApis.addToCart(
          productId: product.id!, quantity: quantity.value);
      if (res != null) {
        toast(locale.value.successfullyAdded);
        Get.find<PharmacyController>().updateCartCount();
        Get.back();
      }
    } catch (e) {
      toast(sanitizeBackendMessage(e, locale.value.somethingWentWrong));
    } finally {
      isAddingToCart(false);
    }
  }
}

class ProductDetailScreen extends StatelessWidget {
  final PharmacyProduct product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final discountPercentage = pharmacyDiscountPercentage(
      price: product.price,
      referencePrice: product.referencePrice,
    );
    final controller = Get.put(ProductDetailController(product: product),
        tag: product.id.toString());

    return AppScaffoldNew(
      appBartitleText: product.name ?? '',
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 140),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildImageCarousel(context),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(product.name ?? '',
                          style:
                              boldTextStyle(size: 22, color: appColorPrimary)),
                      const SizedBox(height: 4),
                      Text(product.brandName ?? '',
                          style: secondaryTextStyle(size: 14)),
                      if (product.isPrescriptionRequired ?? false) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsetsDirectional.only(
                              start: 6, end: 12, top: 6, bottom: 6),
                          decoration: BoxDecoration(
                            color: pendingStatusColor.withValues(alpha: 0.10),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                              color: pendingStatusColor.withValues(alpha: 0.22),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 22,
                                height: 22,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: pendingStatusColor,
                                ),
                                child: const Icon(
                                    Icons.medical_information_rounded,
                                    color: Colors.white,
                                    size: 13),
                              ),
                              const SizedBox(width: 8),
                              Text(locale.value.prescriptionRequired,
                                  style: boldTextStyle(
                                      color: pendingStatusColor, size: 12)),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 20),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(formatCurrencyValue(product.price),
                              style: boldTextStyle(
                                  size: 26, color: appColorSecondary)),
                          if (discountPercentage != null) ...[
                            const SizedBox(width: 10),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Text(
                                  formatCurrencyValue(product.referencePrice),
                                  style: secondaryTextStyle(
                                      decoration: TextDecoration.lineThrough,
                                      size: 14,
                                      color: gray400)),
                            ),
                            const SizedBox(width: 8),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: completedStatusColor.withValues(
                                      alpha: 0.15),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  '$discountPercentage% ${locale.value.off}',
                                  style: boldTextStyle(
                                      color: completedStatusColor, size: 12),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (product.stockQuantity != null)
                        Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: product.stockQuantity! > 0
                                    ? completedStatusColor
                                    : cancelStatusColor,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              product.stockQuantity! > 0
                                  ? '${product.stockQuantity} ${locale.value.inStock}'
                                  : locale.value.outOfStock,
                              style: boldTextStyle(
                                  size: 13,
                                  color: product.stockQuantity! > 0
                                      ? completedStatusColor
                                      : cancelStatusColor),
                            ),
                          ],
                        ),
                      const SizedBox(height: 24),
                      Container(height: 1, color: whiteBorderColor),
                      const SizedBox(height: 20),
                      Text(locale.value.description,
                          style:
                              boldTextStyle(size: 16, color: appColorPrimary)),
                      const SizedBox(height: 10),
                      Text(
                          product.description ??
                              locale.value.pharmacyNoDescription,
                          style: primaryTextStyle(size: 14, height: 1.6)),
                      const SizedBox(height: 20),
                      if (product.dosage != null ||
                          product.unit != null ||
                          product.manufacturer != null) ...[
                        Text(locale.value.productInfo,
                            style: boldTextStyle(
                                size: 16, color: appColorPrimary)),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: surfaceSubtle,
                            borderRadius: BorderRadius.circular(16),
                            border:
                                Border.all(color: whiteBorderColor, width: 1),
                          ),
                          child: Column(
                            children: [
                              if (product.manufacturer != null)
                                _buildInfoRow(locale.value.manufacturer,
                                    product.manufacturer!),
                              if (product.dosage != null)
                                _buildInfoRow(
                                    locale.value.dosage, product.dosage!),
                              if (product.unit != null)
                                _buildInfoRow(locale.value.unit, product.unit!),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _buildBottomBar(context, controller)),
        ],
      ),
    );
  }

  Widget _buildBottomBar(
      BuildContext context, ProductDetailController controller) {
    final isOutOfStock =
        pharmacyProductIsOutOfStock(controller.product.stockQuantity);
    return Container(
      padding: EdgeInsets.fromLTRB(
          16, 16, 16, 16 + MediaQuery.paddingOf(context).bottom),
      decoration: BoxDecoration(
          color: surfaceElevated,
          borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24), topRight: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
                color: softShadowColor,
                blurRadius: 16,
                offset: const Offset(0, -4))
          ]),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: appColorSecondary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: appColorSecondary.withValues(alpha: 0.18),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Material(
                  color: surfaceElevated,
                  shape: const CircleBorder(),
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: isOutOfStock ? null : controller.decrementQuantity,
                    child: Container(
                      width: 32,
                      height: 32,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: appColorSecondary.withValues(alpha: 0.25),
                          width: 1,
                        ),
                      ),
                      child: const Icon(Icons.remove_rounded,
                          color: appColorSecondary, size: 18),
                    ),
                  ),
                ),
                Obx(() => SizedBox(
                      width: 36,
                      child: Text('${controller.quantity.value}',
                          textAlign: TextAlign.center,
                          style:
                              boldTextStyle(size: 16, color: appColorPrimary)),
                    )),
                Material(
                  color: appColorSecondary,
                  shape: const CircleBorder(),
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: isOutOfStock ? null : controller.incrementQuantity,
                    child: Container(
                      width: 32,
                      height: 32,
                      alignment: Alignment.center,
                      child: const Icon(Icons.add_rounded,
                          color: Colors.white, size: 18),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Semantics(
              button: true,
              enabled: !isOutOfStock,
              label: isOutOfStock
                  ? locale.value.outOfStock
                  : locale.value.addToCart,
              child: GestureDetector(
                onTap: isOutOfStock
                    ? null
                    : () => doIfLoggedIn(controller.addToCart),
                child: Container(
                  height: 52,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    gradient: isOutOfStock
                        ? null
                        : const LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [
                              gradientSecondaryStart,
                              gradientSecondaryEnd,
                            ],
                          ),
                    color: isOutOfStock ? gray400 : null,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                          color: softShadowColor,
                          blurRadius: 12,
                          offset: const Offset(0, 4)),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.shopping_cart_rounded,
                          color: Colors.white, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        isOutOfStock
                            ? locale.value.outOfStock
                            : locale.value.addToCart,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageCarousel(BuildContext context) {
    final images = product.images.validate();
    if (images.isEmpty) {
      return ClipRRect(
        borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(24), bottomRight: Radius.circular(24)),
        child: Container(
          height: 300,
          width: Get.width,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                surfaceSubtle,
                appColorSecondary.withValues(alpha: 0.08),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Container(
            width: 110,
            height: 110,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [gradientSecondaryStart, gradientSecondaryEnd],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: appColorSecondary.withValues(alpha: 0.25),
                  blurRadius: 22,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: const Icon(Icons.medication_rounded,
                color: Colors.white, size: 50),
          ),
        ),
      );
    }

    final controller =
        Get.find<ProductDetailController>(tag: product.id.toString());

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(24),
              bottomRight: Radius.circular(24)),
          child: SizedBox(
            height: 300,
            child: PageView.builder(
              controller: controller.pageController,
              itemCount: images.length,
              onPageChanged: (index) => controller.currentImageIndex(index),
              itemBuilder: (context, index) {
                return CachedNetworkImage(
                    imageUrl: images[index],
                    fit: BoxFit.cover,
                    width: Get.width);
              },
            ),
          ),
        ),
        if (images.length > 1) ...[
          const SizedBox(height: 14),
          Obx(() => Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(images.length, (i) {
                  final isActive = controller.currentImageIndex.value == i;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: isActive ? 20 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: isActive
                          ? appColorSecondary
                          : appColorSecondary.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  );
                }),
              )),
        ],
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(label, style: secondaryTextStyle(size: 13)),
          ),
          Expanded(
            child: Text(value,
                style: boldTextStyle(size: 13, color: appColorPrimary)),
          ),
        ],
      ),
    );
  }
}
