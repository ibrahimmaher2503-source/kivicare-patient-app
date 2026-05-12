import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../../api/pharmacy_apis.dart';
import '../../../components/app_scaffold.dart';
import '../../../main.dart';
import '../../../utils/colors.dart';
import '../model/pharmacy_cart_model.dart';
import '../pharmacy_controller.dart';
import '../utils/pharmacy_constants.dart';
import '../prescription/prescription_upload_screen.dart';
import '../utils/pharmacy_empty_state.dart';
import 'available_pharmacies_screen.dart';

class CartController extends GetxController {
  RxBool isLoading = false.obs;
  Rx<PharmacyCart?> cart = Rx<PharmacyCart?>(null);

  @override
  void onInit() {
    super.onInit();
    fetchCart();
  }

  Future<void> fetchCart() async {
    isLoading(true);
    try {
      final res = await PharmacyApis.getCart();
      if (res != null && res['data'] != null) {
        cart(PharmacyCart.fromJson(res['data']));
        Get.find<PharmacyController>()
            .cartCount(cart.value?.items?.length ?? 0);
      } else {
        cart(null);
      }
    } catch (e) {
      log('Error fetching cart: $e');
    } finally {
      isLoading(false);
    }
  }

  Future<void> updateQuantity(int itemId, int quantity) async {
    final oldCart = cart.value;
    if (oldCart == null) return;

    // Optimistic update
    final newItems = oldCart.items.validate().map((item) {
      if (item.id == itemId) {
        final newItem = PharmacyCartItem.fromJson(item.toJson());
        newItem.quantity = quantity;
        newItem.lineTotal = (newItem.unitPrice ?? 0) * quantity;
        return newItem;
      }
      return item;
    }).toList();

    double newSubtotal =
        newItems.fold(0, (sum, item) => sum + (item.lineTotal ?? 0));

    cart(PharmacyCart(
      items: newItems,
      subtotal: newSubtotal,
      discount: oldCart.discount,
      couponCode: oldCart.couponCode,
    ));

    try {
      final res = await PharmacyApis.updateCartItem(itemId, quantity: quantity);
      if (res != null) {
        // Fetch fresh data to ensure server sync
        fetchCart();
      }
    } catch (e) {
      toast(e.toString());
      // Revert on failure
      cart(oldCart);
    }
  }

  Future<void> removeItem(int itemId) async {
    final oldCart = cart.value;
    if (oldCart == null) return;

    // Optimistic remove
    final newItems =
        oldCart.items.validate().where((item) => item.id != itemId).toList();
    double newSubtotal =
        newItems.fold(0, (sum, item) => sum + (item.lineTotal ?? 0));

    cart(PharmacyCart(
      items: newItems,
      subtotal: newSubtotal,
      discount: oldCart.discount,
      couponCode: oldCart.couponCode,
    ));

    try {
      final res = await PharmacyApis.removeCartItem(itemId);
      if (res != null) {
        fetchCart();
      }
    } catch (e) {
      toast(e.toString());
      cart(oldCart);
    }
  }
}

class CartScreen extends StatelessWidget {
  CartScreen({super.key});

  final CartController controller = Get.put(CartController());

  @override
  Widget build(BuildContext context) {
    return AppScaffoldNew(
      appBartitleText: locale.value.cart,
      isLoading: controller.isLoading,
      body: Obx(() {
        if (controller.cart.value == null ||
            controller.cart.value!.items.validate().isEmpty) {
          return _buildEmptyCart(context);
        }
        return Stack(
          children: [
            AnimatedScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              onSwipeRefresh: () => controller.fetchCart(),
              children: [
                ...controller.cart.value!.items!.map((item) =>
                    _CartItemWidget(item: item, controller: controller)),
                const SizedBox(height: 220),
              ],
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _buildCartSummary(context),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildEmptyCart(BuildContext context) {
    return PharmacyEmptyState(
      icon: Icons.shopping_bag_outlined,
      title: locale.value.cartEmpty,
      hint: locale.value.cartEmptyHint,
      primaryLabel: locale.value.browsePharmacy,
      onPrimary: () => Get.back(),
      secondaryLabel: locale.value.uploadPrescription,
      onSecondary: () => Get.to(() => PrescriptionUploadScreen()),
    );
  }

  Widget _buildCartSummary(BuildContext context) {
    final cart = controller.cart.value!;
    return Container(
      padding: EdgeInsets.fromLTRB(
          16, 20, 16, 16 + MediaQuery.of(context).padding.bottom),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24), topRight: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
              color: softShadowColorMedium,
              blurRadius: 20,
              offset: const Offset(0, -6))
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: surfaceElevated,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                    color: softShadowColor,
                    blurRadius: 16,
                    offset: const Offset(0, 6)),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(locale.value.subtotal,
                        style: secondaryTextStyle(size: 13)),
                    Text('${cart.subtotal} LE',
                        style: boldTextStyle(size: 14)),
                  ],
                ),
                const SizedBox(height: 12),
                Container(height: 1, color: whiteBorderColor),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(locale.value.total, style: boldTextStyle(size: 15)),
                    Text('${(cart.subtotal ?? 0) - (cart.discount ?? 0)} LE',
                        style:
                            boldTextStyle(size: 22, color: appColorPrimary)),
                  ],
                ),
                const SizedBox(height: 6),
                Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: Text(
                    locale.value.deliveryAtCheckout,
                    style: secondaryTextStyle(size: 11),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: Get.width,
            height: 52,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              gradient: const LinearGradient(
                colors: [gradientSecondaryStart, gradientSecondaryEnd],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              boxShadow: [
                BoxShadow(
                    color: softShadowColorMedium,
                    blurRadius: 16,
                    offset: const Offset(0, 6)),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () => Get.to(() => AvailablePharmaciesScreen()),
                child: Center(
                  child: Text(
                    locale.value.selectPharmacy,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 15),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// W10: Quantity updates replace the entire cart.value, re-rendering all items.
// _CartItemWidget is const-constructable to allow Flutter to skip unchanged
// items during diffing, but the CartController arg prevents const at call sites.
// To eliminate O(n) rebuilds, PharmacyCartItem would need per-item RxInt
// quantity observables — left for a future model refactor.
class _CartItemWidget extends StatelessWidget {
  final PharmacyCartItem item;
  final CartController controller;

  const _CartItemWidget({required this.item, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: surfaceElevated,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: softShadowColor,
              blurRadius: 16,
              offset: const Offset(0, 6))
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          (item.image.validate().isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: item.image!,
                      height: 72,
                      width: 72,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      height: 72,
                      width: 72,
                      color: surfaceSubtle,
                      child: const Icon(Icons.image_outlined, color: gray400)))
              .cornerRadiusWithClipRRect(12),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name ?? '',
                    style:
                        boldTextStyle(size: 14, color: appColorPrimary),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text(item.brandName ?? '',
                    style: secondaryTextStyle(size: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text('${item.unitPrice} LE',
                        style: boldTextStyle(
                            color: appColorSecondary, size: 14)),
                    Container(
                      decoration: BoxDecoration(
                          color: surfaceSubtle,
                          borderRadius: BorderRadius.circular(999)),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            height: 32,
                            width: 32,
                            child: IconButton(
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              onPressed: () {
                                if (item.quantity! > 1) {
                                  controller.updateQuantity(
                                      item.id!, item.quantity! - 1);
                                }
                              },
                              icon: const Icon(Icons.remove,
                                  size: 18, color: appColorSecondary),
                            ),
                          ),
                          Text('${item.quantity}',
                                  style: boldTextStyle(size: 14))
                              .paddingSymmetric(horizontal: 4),
                          SizedBox(
                            height: 32,
                            width: 32,
                            child: IconButton(
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              onPressed: () {
                                int max = item.product?.maxOrderQuantity ??
                                    PharmacyConstants.defaultMaxQuantity;
                                if (item.quantity! < max) {
                                  controller.updateQuantity(
                                      item.id!, item.quantity! + 1);
                                }
                              },
                              icon: const Icon(Icons.add,
                                  size: 18, color: appColorSecondary),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => controller.removeItem(item.id!),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 4, vertical: 2),
                      child: Text(
                        locale.value.delete,
                        style: secondaryTextStyle(
                            size: 12,
                            color: cancelStatusColor.withValues(alpha: 0.85),
                            weight: FontWeight.w600),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
