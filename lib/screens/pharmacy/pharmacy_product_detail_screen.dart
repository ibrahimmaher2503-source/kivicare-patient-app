import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../components/app_scaffold.dart';
import '../../components/cached_image_widget.dart';
import '../../main.dart';
import '../../utils/colors.dart';
import '../../utils/app_common.dart';
import 'pharmacy_cart_controller.dart';
import 'pharmacy_product_detail_controller.dart';

class PharmacyProductDetailScreen extends StatelessWidget {
  const PharmacyProductDetailScreen({super.key});

  PharmacyCartController get _cartController {
    if (!Get.isRegistered<PharmacyCartController>()) {
      Get.put<PharmacyCartController>(PharmacyCartController());
    }
    return Get.find<PharmacyCartController>();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<PharmacyProductDetailController>(
      init: PharmacyProductDetailController(),
      builder: (controller) {
        return AppScaffold(
          appBarTitle: Text(locale.value.productDetails),
          isLoading: controller.isLoading,
          body: Obx(() {
            if (controller.isLoading.value) return const SizedBox.shrink();
            final product = controller.product.value;
            if (product == null) {
              return Center(
                child: Text(locale.value.noData,
                    style: GoogleFonts.plusJakartaSans(fontSize: 14)),
              );
            }
            return SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product image
                  product.image != null && product.image!.isNotEmpty
                      ? CachedImageWidget(
                          url: product.image!,
                          height: 250,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          height: 250,
                          width: double.infinity,
                          color: isDarkMode.value
                              ? Colors.white10
                              : appColorPrimary.withValues(alpha: 0.06),
                          child: Icon(Icons.medication_outlined,
                              size: 80,
                              color: appColorPrimary.withValues(alpha: 0.35)),
                        ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Name
                        Text(
                          product.name,
                          style: GoogleFonts.outfit(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: isDarkMode.value
                                ? Colors.white
                                : primaryTextColor,
                            letterSpacing: -0.5,
                          ),
                        ),
                        12.height,
                        // Badges row
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            if (!product.isInStock)
                              _badge(locale.value.outOfStock,
                                  Colors.red.shade600),
                            if (product.requiresPrescription)
                              _badge(locale.value.requiresPrescription,
                                  Colors.orange.shade700),
                          ],
                        ),
                        if (!product.isInStock || product.requiresPrescription)
                          16.height,
                        // Price
                        Row(
                          children: [
                            Text(
                              '${locale.value.priceFrom} ',
                              style: GoogleFonts.plusJakartaSans(
                                  fontSize: 14, color: secondaryTextColor),
                            ),
                            Text(
                              product.priceFrom.toStringAsFixed(2),
                              style: GoogleFonts.outfit(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                color: appColorPrimary,
                              ),
                            ),
                          ],
                        ),
                        16.height,
                        // Meta info
                        if (product.brand != null)
                          _metaRow(locale.value.brand, product.brand!.name),
                        if (product.productType != null)
                          _metaRow(locale.value.type, product.productType!.name),
                        if (product.category != null)
                          _metaRow(locale.value.category, product.category!.name),
                        if (product.description != null &&
                            product.description!.isNotEmpty) ...[
                          16.height,
                          Text(
                            product.description!,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              height: 1.6,
                              color: isDarkMode.value
                                  ? Colors.white70
                                  : secondaryTextColor,
                            ),
                          ),
                        ],
                        24.height,
                        // Quantity stepper
                        Row(
                          children: [
                            Text(locale.value.quantity,
                                style: GoogleFonts.plusJakartaSans(
                                    fontSize: 15, fontWeight: FontWeight.w600)),
                            const Spacer(),
                            _quantityStepper(controller),
                          ],
                        ),
                        24.height,
                        // Add to Cart button
                        SizedBox(
                          width: double.infinity,
                          child: Obx(() => ElevatedButton.icon(
                                onPressed: product.isInStock
                                    ? () async {
                                        try {
                                          await _cartController.addToCart(
                                            product.id,
                                            controller.selectedQuantity.value,
                                          );
                                          toast(locale.value.addToCart);
                                        } catch (_) {}
                                      }
                                    : null,
                                icon: const Icon(Icons.shopping_cart_outlined,
                                    size: 18),
                                label: Text(
                                  product.isInStock
                                      ? locale.value.addToCart
                                      : locale.value.outOfStock,
                                  style: GoogleFonts.plusJakartaSans(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: product.isInStock
                                      ? appColorPrimary
                                      : Colors.grey,
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 16),
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(14)),
                                ),
                              )),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        );
      },
    );
  }

  Widget _badge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(label,
          style: GoogleFonts.plusJakartaSans(
              fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white)),
    );
  }

  Widget _metaRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Text('$label: ',
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: secondaryTextColor)),
          Text(value,
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  color: isDarkMode.value ? Colors.white70 : primaryTextColor)),
        ],
      ),
    );
  }

  Widget _quantityStepper(PharmacyProductDetailController controller) {
    return Obx(() => Container(
          decoration: BoxDecoration(
            border: Border.all(
                color: appColorPrimary.withValues(alpha: 0.3)),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.remove_rounded),
                onPressed: controller.decrementQuantity,
                iconSize: 18,
                padding: const EdgeInsets.all(8),
                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  '${controller.selectedQuantity.value}',
                  style: GoogleFonts.outfit(
                      fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add_rounded),
                onPressed: controller.incrementQuantity,
                iconSize: 18,
                padding: const EdgeInsets.all(8),
                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
              ),
            ],
          ),
        ));
  }
}
