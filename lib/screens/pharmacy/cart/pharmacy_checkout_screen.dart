import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../../api/pharmacy_apis.dart';
import '../../../components/app_scaffold.dart';
import '../../../main.dart';
import '../../../utils/app_common.dart';
import '../../../utils/colors.dart';
import '../../../utils/common_base.dart';
import '../../../utils/constants.dart';
import '../model/pharmacy_cart_model.dart';
import '../model/pharmacy_model.dart';
import '../model/pharmacy_prescription_model.dart';
import '../pharmacy_controller.dart';
import '../prescription/prescription_upload_screen.dart';
import '../utils/pharmacy_constants.dart';
import 'order_success_screen.dart';

class PharmacyCheckoutController extends GetxController {
  final Pharmacy pharmacy;
  RxBool isLoading = false.obs;
  Rx<PharmacyCart?> cart = Rx<PharmacyCart?>(null);

  TextEditingController couponController = TextEditingController();
  RxDouble discount = 0.0.obs;
  RxString selectedPaymentMethod = PaymentMethods.PAYMENT_METHOD_CASH.obs;
  RxString selectedAddress = "".obs;

  RxList<PharmacyPrescription> prescriptions = <PharmacyPrescription>[].obs;
  Rx<PharmacyPrescription?> selectedPrescription =
      Rx<PharmacyPrescription?>(null);
  RxBool requiresPrescription = false.obs;
  RxBool hasAttemptedSubmit = false.obs;

  PharmacyCheckoutController({required this.pharmacy});

  @override
  void onInit() {
    super.onInit();
    selectedAddress(loginUserData.value.address);
    fetchCart();
    fetchPrescriptions();
  }

  Future<void> fetchCart() async {
    isLoading(true);
    try {
      final res = await PharmacyApis.getCart();
      if (res != null && res['data'] != null) {
        cart(PharmacyCart.fromJson(res['data']));
        discount(cart.value?.discount ?? 0.0);

        if (cart.value != null) {
          requiresPrescription(cart.value!.items.validate().any(
              (element) => element.product?.isPrescriptionRequired ?? false));
        }
      }
    } catch (e) {
      log('Error fetching cart: $e');
      toast(e.toString());
    } finally {
      isLoading(false);
    }
  }

  Future<void> fetchPrescriptions() async {
    try {
      final res = await PharmacyApis.getPrescriptions();
      if (res != null && res['data'] != null) {
        prescriptions((res['data'] as List)
            .map((e) => PharmacyPrescription.fromJson(e))
            .toList()
            .where((element) =>
                element.status != PharmacyConstants.prescriptionRejected)
            .toList());
        if (prescriptions.isNotEmpty) {
          selectedPrescription(prescriptions.first);
        }
      }
    } catch (e) {
      log('Error fetching prescriptions: $e');
    }
  }

  Future<void> applyCoupon() async {
    if (couponController.text.isEmpty) return;
    isLoading(true);
    try {
      final res = await PharmacyApis.validateCoupon(
          couponController.text, pharmacy.id!);
      if (res != null && res['status'] == true) {
        toast(locale.value.pharmacyCouponApplied);
        await fetchCart(); // Refresh cart to see new discount
      } else {
        toast(res['message'] ?? locale.value.pharmacyInvalidCoupon);
      }
    } catch (e) {
      toast(e.toString());
    } finally {
      isLoading(false);
    }
  }

  Future<void> placeOrder() async {
    hasAttemptedSubmit(true);
    if (selectedAddress.value.isEmpty) {
      toast(locale.value.pharmacyDeliveryAddressRequired);
      return;
    }
    if (requiresPrescription.value && selectedPrescription.value == null) {
      toast(locale.value.pharmacyPrescriptionRequired);
      return;
    }
    isLoading(true);
    try {
      final res = await PharmacyApis.placeOrder(
        pharmacyId: pharmacy.id!,
        deliveryAddress: selectedAddress.value,
        paymentMethod: selectedPaymentMethod.value,
        couponCode: cart.value?.couponCode,
        prescriptionId: selectedPrescription.value?.id,
      );
      if (res != null && res['status'] == true) {
        Get.find<PharmacyController>().resetCartCount();
        final data = res['data'] as Map<String, dynamic>? ?? {};
        final orderId = data['id'] as int? ?? 0;
        final orderNumber = data['order_number'] as String? ?? '';
        Get.offAll(() => OrderSuccessScreen(
            orderId: orderId,
            orderNumber: orderNumber));
      } else {
        toast(res['message'] ?? locale.value.orderFailed);
      }
    } catch (e) {
      toast(e.toString());
    } finally {
      isLoading(false);
    }
  }

  @override
  void onClose() {
    couponController.dispose();
    super.onClose();
  }
}

class PharmacyCheckoutScreen extends StatelessWidget {
  final Pharmacy pharmacy;

  const PharmacyCheckoutScreen({super.key, required this.pharmacy});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(PharmacyCheckoutController(pharmacy: pharmacy));

    return AppScaffoldNew(
      appBartitleText: locale.value.checkout,
      isLoading: controller.isLoading,
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle(locale.value.deliveryAddress),
                _buildAddressSection(context, controller),
                const SizedBox(height: 24),
                _buildSectionTitle(locale.value.selectPharmacy),
                _buildPharmacySummary(context),
                const SizedBox(height: 24),
                Obx(() => controller.requiresPrescription.value
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionTitle(locale.value.prescriptions),
                          _buildPrescriptionSection(context, controller),
                          const SizedBox(height: 24),
                        ],
                      )
                    : const Offstage()),
                _buildSectionTitle(locale.value.applyCoupon),
                _buildCouponSection(context, controller),
                const SizedBox(height: 24),
                _buildSectionTitle(locale.value.paymentMethod),
                _buildPaymentSection(context, controller),
                const SizedBox(height: 24),
                _buildOrderSummary(context, controller),
              ],
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: boxDecorationDefault(
                  color: context.cardColor,
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24)),
                  boxShadow: [
                    BoxShadow(
                        color: softShadowColor,
                        blurRadius: 10,
                        offset: const Offset(0, -4))
                  ]),
              child: AppButton(
                text: locale.value.placeOrder,
                color: appColorSecondary,
                textColor: Colors.white,
                width: Get.width,
                shapeBorder: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                onTap: controller.placeOrder,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, style: boldTextStyle(size: 16)).paddingOnly(bottom: 12);
  }

  Widget _buildAddressSection(
      BuildContext context, PharmacyCheckoutController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: boxDecorationDefault(
              color: context.cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: context.dividerColor)),
          child: Row(
            children: [
              const Icon(Icons.location_on_outlined, color: appColorSecondary),
              const SizedBox(width: 12),
              Expanded(
                child: Obx(() => Text(
                      controller.selectedAddress.value.isEmpty
                          ? locale.value.pharmacySelectDeliveryAddress
                          : controller.selectedAddress.value,
                      style: primaryTextStyle(size: 14),
                    )),
              ),
              IconButton(
                  onPressed: () => _editAddress(context, controller),
                  icon: const Icon(Icons.edit_outlined,
                      size: 20, color: secondaryTextColor)),
            ],
          ),
        ),
        Obx(() {
          if (controller.hasAttemptedSubmit.value &&
              controller.selectedAddress.value.trim().isEmpty) {
            return Padding(
              padding: const EdgeInsets.only(top: 6, left: 4),
              child: Text(
                locale.value.pharmacyDeliveryAddressRequired,
                style: primaryTextStyle(size: 12, color: Colors.red),
              ),
            );
          }
          return const SizedBox.shrink();
        }),
      ],
    );
  }

  Future<void> _editAddress(
      BuildContext context, PharmacyCheckoutController controller) async {
    final addressController =
        TextEditingController(text: controller.selectedAddress.value);
    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(locale.value.deliveryAddress, style: boldTextStyle()),
          content: AppTextField(
            controller: addressController,
            textFieldType: TextFieldType.MULTILINE,
            minLines: 3,
            maxLines: 5,
            decoration: inputDecoration(dialogContext,
                hintText: locale.value.deliveryAddress),
          ),
          actions: [
            TextButton(
                onPressed: () => Get.back(),
                child: Text(locale.value.cancel)),
            TextButton(
                onPressed: () =>
                    Get.back(result: addressController.text.trim()),
                child: Text(locale.value.save)),
          ],
        );
      },
    );
    if (result != null) {
      controller.selectedAddress(result);
    }
    addressController.dispose();
  }

  Widget _buildPharmacySummary(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: boxDecorationDefault(
          color: context.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: context.dividerColor)),
      child: Row(
        children: [
          Container(
            height: 40,
            width: 40,
            decoration: boxDecorationDefault(
                color: lightPrimaryColor, shape: BoxShape.circle),
            child: pharmacy.image != null
                ? CachedNetworkImage(
                        imageUrl: pharmacy.image!, fit: BoxFit.cover)
                    .cornerRadiusWithClipRRect(20)
                : const Icon(Icons.local_pharmacy_outlined,
                    color: appColorPrimary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(pharmacy.name ?? '', style: boldTextStyle(size: 14)),
                Text(pharmacy.address ?? '',
                    style: secondaryTextStyle(size: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrescriptionSection(
      BuildContext context, PharmacyCheckoutController controller) {
    return Obx(() {
      if (controller.prescriptions.isEmpty) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: boxDecorationDefault(
              color: Colors.orange.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange.withValues(alpha: 0.2))),
          child: Column(
            children: [
              Text(locale.value.pharmacyCartPrescriptionWarning,
                  style: primaryTextStyle(size: 14)),
              const SizedBox(height: 12),
              AppButton(
                text: locale.value.uploadPrescription,
                color: Colors.orange,
                textColor: Colors.white,
                onTap: () => Get.to(() => PrescriptionUploadScreen()),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
            ],
          ),
        );
      }
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: boxDecorationDefault(
            color: context.cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: context.dividerColor)),
        child: Column(
          children: [
            DropdownButtonFormField<PharmacyPrescription>(
              value: controller.selectedPrescription.value,
              isExpanded: true,
              decoration: const InputDecoration(
                  border: InputBorder.none, contentPadding: EdgeInsets.zero),
              items: controller.prescriptions
                  .map((e) => DropdownMenuItem(
                        value: e,
                        child: Text('${locale.value.pharmacyPrescriptionLabel} #${e.id} (${e.status})',
                            style: primaryTextStyle(size: 14)),
                      ))
                  .toList(),
              onChanged: (val) => controller.selectedPrescription(val),
              hint: Text(locale.value.pharmacySelectPrescription),
            ),
            const Divider(),
            TextButton(
              onPressed: () => Get.to(() => PrescriptionUploadScreen()),
              child: Text(locale.value.pharmacyUploadNewPrescription,
                  style: boldTextStyle(color: appColorSecondary, size: 14)),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildCouponSection(
      BuildContext context, PharmacyCheckoutController controller) {
    return Row(
      children: [
        Expanded(
          child: AppTextField(
            controller: controller.couponController,
            textFieldType: TextFieldType.NAME,
            decoration:
                inputDecoration(context, hintText: locale.value.couponCode),
          ),
        ),
        const SizedBox(width: 12),
        AppButton(
          text: locale.value.apply,
          color: appColorPrimary,
          textColor: Colors.white,
          onTap: controller.applyCoupon,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ],
    );
  }

  Widget _buildPaymentSection(
      BuildContext context, PharmacyCheckoutController controller) {
    return Column(
      children: [
        _buildPaymentOption(
            context,
            controller,
            PaymentMethods.PAYMENT_METHOD_CASH,
            locale.value.pharmacyCashOnDelivery,
            Icons.money),
        const SizedBox(height: 8),
        _buildPaymentOption(
            context,
            controller,
            PaymentMethods.PAYMENT_METHOD_WALLET,
            locale.value.pharmacyWallet,
            Icons.account_balance_wallet_outlined),
      ],
    );
  }

  Widget _buildPaymentOption(
      BuildContext context,
      PharmacyCheckoutController controller,
      String value,
      String label,
      IconData icon) {
    return Obx(() => Container(
          decoration: boxDecorationDefault(
              color: context.cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: controller.selectedPaymentMethod.value == value
                      ? appColorSecondary
                      : context.dividerColor)),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => controller.selectedPaymentMethod(value),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
              children: [
                Icon(icon,
                    size: 20,
                    color: controller.selectedPaymentMethod.value == value
                        ? appColorSecondary
                        : secondaryTextColor),
                const SizedBox(width: 12),
                Expanded(child: Text(label, style: primaryTextStyle(size: 14))),
                Icon(
                  controller.selectedPaymentMethod.value == value
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                  color: controller.selectedPaymentMethod.value == value
                      ? appColorSecondary
                      : secondaryTextColor,
                ),
              ],
            ),
            ),
          ),
        ));
  }

  Widget _buildOrderSummary(
      BuildContext context, PharmacyCheckoutController controller) {
    return Obx(() {
      final cart = controller.cart.value;
      if (cart == null) return const Offstage();
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: boxDecorationDefault(
            color: context.cardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                  color: softShadowColor,
                  blurRadius: 10,
                  offset: const Offset(0, 4))
            ]),
        child: Column(
          children: [
            _buildSummaryRow(locale.value.subtotal, '${cart.subtotal} LE'),
            if (controller.discount.value > 0)
              _buildSummaryRow(
                  locale.value.discount, '- ${controller.discount.value} LE',
                  color: Colors.green),
            _buildSummaryRow(
                locale.value.deliveryFee, '${pharmacy.deliveryFee} LE'),
            const Divider(height: 24),
            _buildSummaryRow(locale.value.total,
                '${cart.subtotal! - controller.discount.value + (pharmacy.deliveryFee ?? 0)} LE',
                isBold: true, size: 18, color: appColorSecondary),
          ],
        ),
      );
    });
  }

  Widget _buildSummaryRow(String label, String value,
      {bool isBold = false, double size = 14, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: isBold
                  ? boldTextStyle(size: size.toInt())
                  : secondaryTextStyle(size: size.toInt())),
          Text(value, style: boldTextStyle(size: size.toInt(), color: color)),
        ],
      ),
    );
  }
}
