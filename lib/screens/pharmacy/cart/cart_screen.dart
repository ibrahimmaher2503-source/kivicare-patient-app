import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../../api/pharmacy_apis.dart';
import '../../../components/app_scaffold.dart';
import '../../../utils/empty_error_state_widget.dart';
import '../../../main.dart';
import '../../../utils/colors.dart';
import '../model/pharmacy_cart_model.dart';
import '../pharmacy_controller.dart';
import '../utils/pharmacy_constants.dart';
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
          return NoDataWidget(
            title: locale.value.cartEmpty,
            imageWidget: const ErrorStateWidget(),
            onRetry: () => controller.fetchCart(),
          ).center();
        }
        return Stack(
          children: [
            AnimatedScrollView(
              padding: const EdgeInsets.all(16),
              onSwipeRefresh: () => controller.fetchCart(),
              children: [
                ...controller.cart.value!.items!.map((item) =>
                    _CartItemWidget(item: item, controller: controller)),
                const SizedBox(height: 150),
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

  Widget _buildCartSummary(BuildContext context) {
    final cart = controller.cart.value!;
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
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(locale.value.subtotal, style: secondaryTextStyle()),
              Text('${cart.subtotal} LE', style: boldTextStyle()),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(locale.value.total, style: boldTextStyle(size: 18)),
              Text('${(cart.subtotal ?? 0) - (cart.discount ?? 0)} LE',
                  style: boldTextStyle(size: 18, color: appColorSecondary)),
            ],
          ),
          const SizedBox(height: 16),
          AppButton(
            text: locale.value.selectPharmacy,
            color: appColorSecondary,
            textColor: Colors.white,
            width: Get.width,
            shapeBorder:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            onTap: () => Get.to(() => AvailablePharmaciesScreen()),
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
      decoration: boxDecorationDefault(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: softShadowColor, blurRadius: 8, offset: const Offset(0, 2))
        ],
      ),
      child: Row(
        children: [
          (item.image.validate().isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: item.image!,
                      height: 80,
                      width: 80,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      height: 80,
                      width: 80,
                      color: gray100,
                      child: const Icon(Icons.image_outlined, color: gray400)))
              .cornerRadiusWithClipRRect(12),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                        child: Text(item.name ?? '',
                            style: boldTextStyle(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis)),
                    IconButton(
                      icon: const Icon(Icons.delete_outline,
                          color: Colors.red, size: 20),
                      onPressed: () => controller.removeItem(item.id!),
                    ),
                  ],
                ),
                Text(item.brandName ?? '', style: secondaryTextStyle(size: 12)),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${item.unitPrice} LE',
                        style: boldTextStyle(color: appColorSecondary)),
                    Container(
                      decoration: boxDecorationDefault(
                          color: lightPrimaryColor,
                          borderRadius: BorderRadius.circular(8)),
                      child: Row(
                        children: [
                          IconButton(
                            constraints: const BoxConstraints(),
                            padding: const EdgeInsets.all(4),
                            onPressed: () {
                              if (item.quantity! > 1) {
                                controller.updateQuantity(
                                    item.id!, item.quantity! - 1);
                              }
                            },
                            icon: const Icon(Icons.remove,
                                size: 18, color: appColorPrimary),
                          ),
                          Text('${item.quantity}',
                                  style: boldTextStyle(size: 14))
                              .paddingSymmetric(horizontal: 4),
                          IconButton(
                            constraints: const BoxConstraints(),
                            padding: const EdgeInsets.all(4),
                            onPressed: () {
                              int max = item.product?.maxOrderQuantity ??
                                  PharmacyConstants.defaultMaxQuantity;
                              if (item.quantity! < max) {
                                controller.updateQuantity(
                                    item.id!, item.quantity! + 1);
                              }
                            },
                            icon: const Icon(Icons.add,
                                size: 18, color: appColorPrimary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
