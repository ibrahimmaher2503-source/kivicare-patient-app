import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../components/app_scaffold.dart';
import '../../main.dart';
import '../../utils/colors.dart';
import '../../utils/app_common.dart';
import '../../utils/empty_error_state_widget.dart';
import 'components/pharmacy_cart_item_tile.dart';
import 'pharmacy_cart_controller.dart';
import 'pharmacy_checkout_screen.dart';

class PharmacyCartScreen extends StatelessWidget {
  const PharmacyCartScreen({super.key});

  PharmacyCartController get _cartController {
    if (!Get.isRegistered<PharmacyCartController>()) {
      Get.put<PharmacyCartController>(PharmacyCartController());
    }
    return Get.find<PharmacyCartController>();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _cartController;
    return AppScaffold(
      appBarTitle: Obx(() => Text(
            '${locale.value.cart} (${controller.itemCount})',
          )),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        final cart = controller.cart.value;
        if (cart == null || cart.items.isEmpty) {
          return Center(
            child: EmptyErrorStateWidget(
              title: locale.value.cartEmpty,
              subTitle: locale.value.cartEmptyMessage,
              onRetry: () => Get.back(),
            ),
          );
        }
        return Column(
          children: [
            Expanded(
              child: RefreshIndicator(
                onRefresh: controller.loadCart,
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  itemCount: cart.items.length,
                  itemBuilder: (context, index) {
                    return PharmacyCartItemTile(
                      item: cart.items[index],
                      cartController: controller,
                    );
                  },
                ),
              ),
            ),
            // Checkout button
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              decoration: BoxDecoration(
                color:
                    isDarkMode.value ? surfaceElevatedDark : Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: softShadowColorMedium,
                    blurRadius: 16,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: () => Get.to(() => const PharmacyCheckoutScreen()),
                style: ElevatedButton.styleFrom(
                  backgroundColor: appColorPrimary,
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: Text(
                  locale.value.proceedToCheckout,
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}
