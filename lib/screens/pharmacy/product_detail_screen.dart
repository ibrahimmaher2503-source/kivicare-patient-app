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
            padding: const EdgeInsets.only(bottom: 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildImageCarousel(context),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(product.name ?? '',
                                    style: boldTextStyle(size: 20)),
                                Text(product.brandName ?? '',
                                    style: secondaryTextStyle(size: 14)),
                              ],
                            ),
                          ),
                          if (product.isPrescriptionRequired ?? false)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: boxDecorationDefault(
                                  color: Colors.orange.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8)),
                              child: Row(
                                children: [
                                  const Icon(Icons.assignment_outlined,
                                      color: Colors.orange, size: 16),
                                  const SizedBox(width: 4),
                                  Text(locale.value.prescriptionRequired,
                                      style: boldTextStyle(
                                          color: Colors.orange, size: 10)),
                                ],
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Text('${product.price} LE',
                              style: boldTextStyle(
                                  size: 22, color: appColorSecondary)),
                          if (product.referencePrice != null) ...[
                            const SizedBox(width: 8),
                            Text('${product.referencePrice} LE',
                                style: secondaryTextStyle(
                                    decoration: TextDecoration.lineThrough,
                                    size: 16)),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: boxDecorationDefault(
                                  color: Colors.green,
                                  borderRadius: BorderRadius.circular(4)),
                              child: Text(
                                '${(((product.referencePrice! - product.price!) / product.referencePrice!) * 100).toInt()}% OFF',
                                style: boldTextStyle(
                                    color: Colors.white, size: 10),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (product.stockQuantity != null)
                        Text(
                          product.stockQuantity! > 0
                              ? '${product.stockQuantity} ${locale.value.inStock}'
                              : locale.value.outOfStock,
                          style: secondaryTextStyle(
                              color: product.stockQuantity! > 0
                                  ? Colors.green
                                  : Colors.red),
                        ),
                      const Divider(height: 32),
                      Text(locale.value.description, style: boldTextStyle()),
                      const SizedBox(height: 8),
                      Text(product.description ?? locale.value.pharmacyNoDescription,
                          style: primaryTextStyle()),
                      const SizedBox(height: 16),
                      if (product.dosage != null ||
                          product.unit != null ||
                          product.manufacturer != null) ...[
                        Text(locale.value.productInfo, style: boldTextStyle()),
                        const SizedBox(height: 8),
                        if (product.manufacturer != null)
                          _buildInfoRow(
                              locale.value.manufacturer, product.manufacturer!),
                        if (product.dosage != null)
                          _buildInfoRow(locale.value.dosage, product.dosage!),
                        if (product.unit != null)
                          _buildInfoRow(locale.value.unit, product.unit!),
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
      padding: const EdgeInsets.all(16),
      decoration: boxDecorationDefault(
          color: context.cardColor,
          borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24), topRight: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
                color: softShadowColor,
                blurRadius: 10,
                offset: const Offset(0, -4))
          ]),
      child: Row(
        children: [
          Container(
            decoration: boxDecorationDefault(
                color: lightPrimaryColor,
                borderRadius: BorderRadius.circular(12)),
            child: Row(
              children: [
                IconButton(
                    onPressed: controller.decrementQuantity,
                    icon: const Icon(Icons.remove, color: appColorPrimary)),
                Obx(() => Text('${controller.quantity.value}',
                    style: boldTextStyle())),
                IconButton(
                    onPressed: controller.incrementQuantity,
                    icon: const Icon(Icons.add, color: appColorPrimary)),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: AppButton(
              text: locale.value.addToCart,
              color: appColorSecondary,
              textColor: Colors.white,
              shapeBorder: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              onTap: () => doIfLoggedIn(controller.addToCart),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageCarousel(BuildContext context) {
    final images = product.images.validate();
    if (images.isEmpty) {
      return Container(
          height: 300,
          width: Get.width,
          color: gray100,
          child: const Icon(Icons.image_outlined, color: gray400, size: 64));
    }

    final controller = Get.find<ProductDetailController>(
        tag: product.id.toString());

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
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
        if (images.length > 1) ...[
          const SizedBox(height: 10),
          Obx(() => Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(images.length, (i) {
                  final isActive = controller.currentImageIndex.value == i;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: isActive ? 16 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: isActive
                          ? appColorPrimary
                          : appColorPrimary.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              )),
          const SizedBox(height: 8),
        ],
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Text('$label: ', style: secondaryTextStyle()),
          Text(value, style: primaryTextStyle(size: 14)),
        ],
      ),
    );
  }
}
