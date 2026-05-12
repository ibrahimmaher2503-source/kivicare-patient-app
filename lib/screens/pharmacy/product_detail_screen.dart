import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../api/pharmacy_apis.dart';
import '../../components/app_scaffold.dart';
import '../../main.dart';
import '../../utils/colors.dart';
import '../../utils/common_base.dart';
import 'model/pharmacy_product_model.dart';
import 'pharmacy_controller.dart';
import 'utils/pharmacy_constants.dart';

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
      toast('Product unavailable');
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
      toast(e.toString());
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
                          style: boldTextStyle(
                              size: 22, color: appColorPrimary)),
                      const SizedBox(height: 4),
                      Text(product.brandName ?? '',
                          style: secondaryTextStyle(size: 14)),
                      if (product.isPrescriptionRequired ?? false) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: pendingStatusColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.warning_amber_rounded,
                                  color: pendingStatusColor, size: 14),
                              const SizedBox(width: 6),
                              Text(locale.value.prescriptionRequired,
                                  style: boldTextStyle(
                                      color: pendingStatusColor, size: 11)),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 20),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('${product.price} LE',
                              style: boldTextStyle(
                                  size: 26, color: appColorSecondary)),
                          if (product.referencePrice != null) ...[
                            const SizedBox(width: 10),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Text('${product.referencePrice} LE',
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
                                  color: completedStatusColor
                                      .withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  '${(((product.referencePrice! - product.price!) / product.referencePrice!) * 100).toInt()}% OFF',
                                  style: boldTextStyle(
                                      color: completedStatusColor, size: 10),
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
                      Container(
                          height: 1,
                          color: whiteBorderColor),
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
                                _buildInfoRow(
                                    locale.value.unit, product.unit!),
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
            decoration: BoxDecoration(
                color: surfaceSubtle,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: whiteBorderColor, width: 1)),
            child: Row(
              children: [
                SizedBox(
                  width: 36,
                  height: 36,
                  child: IconButton(
                      padding: EdgeInsets.zero,
                      onPressed: controller.decrementQuantity,
                      icon: const Icon(Icons.remove_rounded,
                          color: appColorSecondary, size: 20)),
                ),
                Obx(() => SizedBox(
                      width: 28,
                      child: Text('${controller.quantity.value}',
                          textAlign: TextAlign.center,
                          style: boldTextStyle(size: 16)),
                    )),
                SizedBox(
                  width: 36,
                  height: 36,
                  child: IconButton(
                      padding: EdgeInsets.zero,
                      onPressed: controller.incrementQuantity,
                      icon: const Icon(Icons.add_rounded,
                          color: appColorSecondary, size: 20)),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: GestureDetector(
              onTap: () => doIfLoggedIn(controller.addToCart),
              child: Container(
                height: 52,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [gradientSecondaryStart, gradientSecondaryEnd],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                        color: softShadowColor,
                        blurRadius: 12,
                        offset: const Offset(0, 4)),
                  ],
                ),
                child: Text(
                  locale.value.addToCart,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2,
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
            color: surfaceSubtle,
            child: const Icon(Icons.medication_outlined,
                color: gray400, size: 64)),
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
