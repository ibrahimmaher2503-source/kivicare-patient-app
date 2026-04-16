import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../components/app_scaffold.dart';
import '../../main.dart';
import '../../utils/colors.dart';
import '../../utils/app_common.dart';
import '../../utils/empty_error_state_widget.dart';
import 'components/available_pharmacy_card.dart';
import 'pharmacy_checkout_controller.dart';
import 'pharmacy_order_detail_screen.dart';

class PharmacyCheckoutScreen extends StatelessWidget {
  const PharmacyCheckoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetX<PharmacyCheckoutController>(
      init: PharmacyCheckoutController(),
      builder: (controller) {
        return AppScaffold(
          appBarTitle: Text(locale.value.proceedToCheckout),
          body: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Step 1: Address input
                _sectionTitle(locale.value.selectDeliveryAddress),
                8.height,
                // TODO: replace with address picker when address API is available
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: isDarkMode.value
                              ? surfaceElevatedDark
                              : surfaceElevated,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isDarkMode.value
                                ? Colors.white12
                                : appColorPrimary.withValues(alpha: 0.08),
                          ),
                        ),
                        child: TextField(
                          keyboardType: TextInputType.number,
                          onChanged: (v) =>
                              controller.addressId.value = int.tryParse(v) ?? 0,
                          decoration: InputDecoration(
                            hintText: locale.value.enterAddressId,
                            hintStyle: GoogleFonts.plusJakartaSans(
                                fontSize: 14, color: secondaryTextColor),
                            prefixIcon: const Icon(Icons.location_on_outlined,
                                size: 20),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 14, horizontal: 8),
                          ),
                        ),
                      ),
                    ),
                    12.width,
                    Obx(() => ElevatedButton(
                          onPressed: controller.isLoadingPharmacies.value
                              ? null
                              : controller.findPharmacies,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: appColorPrimary,
                            padding: const EdgeInsets.symmetric(
                                vertical: 14, horizontal: 16),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          child: controller.isLoadingPharmacies.value
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                      color: Colors.white, strokeWidth: 2),
                                )
                              : Text(locale.value.findPharmacies,
                                  style: GoogleFonts.plusJakartaSans(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13)),
                        )),
                  ],
                ),
                24.height,

                // Step 2: Available pharmacies
                Obx(() {
                  if (controller.availablePharmacies.isEmpty &&
                      controller.matchMessage.value == null) {
                    return const SizedBox.shrink();
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _sectionTitle(locale.value.availablePharmacies),
                      8.height,
                      if (controller.matchMessage.value != null)
                        Center(
                          child: EmptyErrorStateWidget(
                            title: locale.value.noPharmaciesAvailable,
                            subTitle: controller.matchMessage.value,
                          ),
                        )
                      else
                        ...controller.availablePharmacies.map((pharmacy) {
                          return Obx(() => AvailablePharmacyCard(
                                pharmacy: pharmacy,
                                isSelected:
                                    controller.selectedPharmacy.value?.id ==
                                        pharmacy.id,
                                onTap: () =>
                                    controller.selectedPharmacy.value =
                                        pharmacy,
                              ));
                        }),
                    ],
                  );
                }),

                // Step 3: Confirm order button
                Obx(() {
                  if (controller.availablePharmacies.isEmpty) {
                    return const SizedBox.shrink();
                  }
                  return Column(
                    children: [
                      16.height,
                      _sectionTitle(locale.value.placeOrder),
                      8.height,
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: controller.isPlacingOrder.value ||
                                  controller.selectedPharmacy.value == null
                              ? null
                              : () async {
                                  final orderId =
                                      await controller.placeOrder();
                                  if (orderId != null) {
                                    toast(locale.value.orderPlacedMessage);
                                    Get.off(() => PharmacyOrderDetailScreen(),
                                        arguments: orderId);
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: appColorPrimary,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
                          ),
                          child: controller.isPlacingOrder.value
                              ? const CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2)
                              : Text(
                                  locale.value.placeOrder,
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
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: GoogleFonts.outfit(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
        color: isDarkMode.value ? Colors.white : primaryTextColor,
      ),
    );
  }
}
