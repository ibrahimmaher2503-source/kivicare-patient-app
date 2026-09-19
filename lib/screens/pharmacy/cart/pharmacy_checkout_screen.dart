import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../../api/pharmacy_apis.dart';
import '../../../components/app_scaffold.dart';
import '../../../components/operation_verification_screen.dart';
import '../../../main.dart';
import '../../../utils/app_common.dart';
import '../../../utils/colors.dart';
import '../../../utils/common_base.dart';
import '../../../utils/constants.dart';
import '../../../network/critical_operation.dart';
import '../../../network/network_utils.dart';
import '../../../utils/price_widget.dart';
import '../model/pharmacy_cart_model.dart';
import '../model/pharmacy_model.dart';
import '../model/pharmacy_order_receipt.dart';
import '../model/pharmacy_prescription_model.dart';
import '../pharmacy_controller.dart';
import '../prescription/prescription_upload_screen.dart';
import '../utils/pharmacy_constants.dart';
import 'order_success_screen.dart';
import '../order/pharmacy_order_list_screen.dart';

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
      toast(sanitizeBackendMessage(e, locale.value.somethingWentWrong));
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

  void attachUploadedPrescription(PharmacyPrescription prescription) {
    final id = prescription.id ?? 0;
    if (id <= 0 ||
        prescription.status == PharmacyConstants.prescriptionRejected) {
      return;
    }
    prescriptions.removeWhere((item) => item.id == id);
    prescriptions.insert(0, prescription);
    selectedPrescription(prescription);
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
      toast(sanitizeBackendMessage(e, locale.value.somethingWentWrong));
    } finally {
      isLoading(false);
    }
  }

  Future<void> placeOrder() async {
    if (isLoading.value) return;
    if (!await requireAuthenticated()) return;
    hasAttemptedSubmit(true);
    if (selectedAddress.value.isEmpty) {
      toast(locale.value.pharmacyDeliveryAddressRequired);
      return;
    }
    if (requiresPrescription.value && selectedPrescription.value == null) {
      toast(locale.value.pharmacyPrescriptionRequired);
      return;
    }
    final requestFingerprint = criticalOperationFingerprint({
      'pharmacy_id': pharmacy.id,
      'delivery_address': selectedAddress.value,
      'payment_method': selectedPaymentMethod.value,
      'coupon_code': cart.value?.couponCode,
      'prescription_id': selectedPrescription.value?.id,
    });
    isLoading(true);
    String? operationKey;
    try {
      operationKey = await CriticalOperationStore.begin(
        CriticalOperationType.pharmacyOrder,
        requestFingerprint: requestFingerprint,
      );
      final res = await PharmacyApis.placeOrder(
        pharmacyId: pharmacy.id!,
        deliveryAddress: selectedAddress.value,
        paymentMethod: selectedPaymentMethod.value,
        couponCode: cart.value?.couponCode,
        prescriptionId: selectedPrescription.value?.id,
        idempotencyKey: operationKey,
      );
      final receipt = parsePharmacyOrderReceipt(res);
      await CriticalOperationStore.complete(
        CriticalOperationType.pharmacyOrder,
      );
      Get.find<PharmacyController>().clearCartAfterOrder();
      Get.offAll(() => OrderSuccessScreen(
            orderId: receipt.orderId,
            orderNumber: receipt.orderNumber,
          ));
    } on AmbiguousRequestOutcomeException catch (_) {
      Get.off(
        () => OperationVerificationScreen(
          recordsScreen: () => PharmacyOrderListScreen(),
          operationType: CriticalOperationType.pharmacyOrder,
          operationKey: operationKey,
        ),
      );
    } on PendingCriticalOperationException catch (_) {
      Get.off(
        () => OperationVerificationScreen(
          recordsScreen: () => PharmacyOrderListScreen(),
          operationType: CriticalOperationType.pharmacyOrder,
          operationKey: operationKey ??
              CriticalOperationStore.pendingKey(
                  CriticalOperationType.pharmacyOrder),
        ),
      );
    } on FormatException catch (_) {
      Get.off(
        () => OperationVerificationScreen(
          recordsScreen: () => PharmacyOrderListScreen(),
          operationType: CriticalOperationType.pharmacyOrder,
          operationKey: operationKey ??
              CriticalOperationStore.pendingKey(
                  CriticalOperationType.pharmacyOrder),
        ),
      );
    } catch (e) {
      await CriticalOperationStore.complete(
        CriticalOperationType.pharmacyOrder,
      );
      toast(sanitizeBackendMessage(e, locale.value.somethingWentWrong));
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
              padding: EdgeInsets.fromLTRB(
                  16, 16, 16, 16 + MediaQuery.of(context).padding.bottom),
              decoration: BoxDecoration(
                  color: context.cardColor,
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24)),
                  boxShadow: [
                    BoxShadow(
                        color: softShadowColorMedium,
                        blurRadius: 20,
                        offset: const Offset(0, -6))
                  ]),
              child: Container(
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
                    onTap: controller.placeOrder,
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Flexible(
                            child: Text(
                              locale.value.placeOrder,
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_forward_rounded,
                              color: Colors.white, size: 18),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, style: boldTextStyle(size: 16, color: appColorPrimary))
        .paddingOnly(bottom: 12);
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: surfaceElevated,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
            color: softShadowColor, blurRadius: 16, offset: const Offset(0, 6))
      ],
    );
  }

  Widget _buildAddressSection(
      BuildContext context, PharmacyCheckoutController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: _cardDecoration(),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: appColorSecondary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.location_on_rounded,
                    color: appColorSecondary, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Obx(() => Text(
                      controller.selectedAddress.value.isEmpty
                          ? locale.value.pharmacySelectDeliveryAddress
                          : controller.selectedAddress.value,
                      style: primaryTextStyle(size: 14),
                    )),
              ),
              Material(
                color: Colors.transparent,
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: () => _editAddress(context, controller),
                  child: Container(
                    width: 36,
                    height: 36,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: surfaceSubtle,
                      border: Border.all(color: whiteBorderColor, width: 1),
                    ),
                    child: const Icon(Icons.edit_rounded,
                        size: 16, color: appColorSecondary),
                  ),
                ),
              ),
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
                style: primaryTextStyle(size: 12, color: cancelStatusColor),
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
                onPressed: () => Get.back(), child: Text(locale.value.cancel)),
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
      decoration: _cardDecoration(),
      child: Row(
        children: [
          Container(
            height: 44,
            width: 44,
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
                  color: appColorSecondary.withValues(alpha: 0.22),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: pharmacy.image != null
                ? CachedNetworkImage(
                        imageUrl: pharmacy.image!, fit: BoxFit.cover)
                    .cornerRadiusWithClipRRect(22)
                : const Icon(Icons.local_pharmacy_rounded,
                    color: Colors.white, size: 22),
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
          decoration: BoxDecoration(
              color: pendingStatusColor.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                  color: pendingStatusColor.withValues(alpha: 0.25))),
          child: Column(
            children: [
              Text(locale.value.pharmacyCartPrescriptionWarning,
                  style: primaryTextStyle(size: 14)),
              const SizedBox(height: 12),
              AppButton(
                text: locale.value.uploadPrescription,
                color: pendingStatusColor,
                textColor: Colors.white,
                onTap: () => _uploadPrescription(controller),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
            ],
          ),
        );
      }
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: _cardDecoration(),
        child: Column(
          children: [
            DropdownButtonFormField<PharmacyPrescription>(
              initialValue: controller.selectedPrescription.value,
              isExpanded: true,
              decoration: const InputDecoration(
                  border: InputBorder.none, contentPadding: EdgeInsets.zero),
              items: controller.prescriptions
                  .map((e) => DropdownMenuItem(
                        value: e,
                        child: Text(
                            '${locale.value.pharmacyPrescriptionLabel} #${e.id} (${PharmacyConstants.prescriptionStatusLabel(locale.value, e.status.validate())})',
                            style: primaryTextStyle(size: 14),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis),
                      ))
                  .toList(),
              onChanged: (val) => controller.selectedPrescription(val),
              hint: Text(locale.value.pharmacySelectPrescription),
            ),
            const Divider(),
            TextButton(
              onPressed: () => _uploadPrescription(controller),
              child: Text(locale.value.pharmacyUploadNewPrescription,
                  style: boldTextStyle(color: appColorSecondary, size: 14)),
            ),
          ],
        ),
      );
    });
  }

  Future<void> _uploadPrescription(
      PharmacyCheckoutController controller) async {
    final prescription = await Get.to<PharmacyPrescription>(
      () => PrescriptionUploadScreen(returnResult: true),
    );
    if (prescription != null) {
      controller.attachUploadedPrescription(prescription);
    }
  }

  Widget _buildCouponSection(
      BuildContext context, PharmacyCheckoutController controller) {
    final couponField = AppTextField(
      controller: controller.couponController,
      textFieldType: TextFieldType.NAME,
      decoration: inputDecoration(context, hintText: locale.value.couponCode),
    );
    final applyButton = AppButton(
      text: locale.value.apply,
      color: appColorPrimary,
      textColor: Colors.white,
      onTap: controller.applyCoupon,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    );
    return LayoutBuilder(
      builder: (context, constraints) {
        final useVerticalLayout = constraints.maxWidth < 340 ||
            MediaQuery.textScalerOf(context).scale(1) > 1.3;
        if (useVerticalLayout) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              couponField,
              const SizedBox(height: 12),
              applyButton,
            ],
          );
        }
        return Row(
          children: [
            Expanded(child: couponField),
            const SizedBox(width: 12),
            applyButton,
          ],
        );
      },
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
      ],
    );
  }

  Widget _buildPaymentOption(
      BuildContext context,
      PharmacyCheckoutController controller,
      String value,
      String label,
      IconData icon) {
    return Obx(() {
      final selected = controller.selectedPaymentMethod.value == value;
      return Container(
        decoration: BoxDecoration(
            color: selected ? lightSecondaryColor : surfaceSubtle,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: selected ? appColorSecondary : whiteBorderColor,
                width: selected ? 1.5 : 1)),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => controller.selectedPaymentMethod(value),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(11),
                      color: selected
                          ? appColorSecondary.withValues(alpha: 0.18)
                          : surfaceElevated,
                      border: Border.all(
                        color: selected
                            ? appColorSecondary.withValues(alpha: 0.32)
                            : whiteBorderColor,
                        width: 1,
                      ),
                    ),
                    child: Icon(icon,
                        size: 20,
                        color:
                            selected ? appColorSecondary : secondaryTextColor),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                      child: Text(label, style: primaryTextStyle(size: 14))),
                  Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: selected ? appColorSecondary : Colors.transparent,
                      border: Border.all(
                          color: selected ? appColorSecondary : gray400,
                          width: 1.5),
                    ),
                    child: selected
                        ? const Icon(Icons.check, size: 14, color: Colors.white)
                        : const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildOrderSummary(
      BuildContext context, PharmacyCheckoutController controller) {
    return Obx(() {
      final cart = controller.cart.value;
      if (cart == null) return const Offstage();
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: _cardDecoration(),
        child: Column(
          children: [
            _buildSummaryRow(
                locale.value.subtotal, formatCurrencyValue(cart.subtotal)),
            if (controller.discount.value > 0)
              _buildSummaryRow(locale.value.discount,
                  '- ${formatCurrencyValue(controller.discount.value)}',
                  color: completedStatusColor),
            _buildSummaryRow(locale.value.deliveryFee,
                formatCurrencyValue(pharmacy.deliveryFee)),
            const SizedBox(height: 12),
            Container(height: 1, color: whiteBorderColor),
            const SizedBox(height: 12),
            _buildSummaryRow(
                locale.value.total,
                formatCurrencyValue(cart.subtotal! -
                    controller.discount.value +
                    (pharmacy.deliveryFee ?? 0)),
                isBold: true,
                size: 22,
                color: appColorPrimary,
                labelSize: 15),
          ],
        ),
      );
    });
  }

  Widget _buildSummaryRow(String label, String value,
      {bool isBold = false,
      double size = 14,
      Color? color,
      double? labelSize}) {
    final lblSize = labelSize ?? (isBold ? size : 13);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: isBold
                  ? boldTextStyle(size: lblSize.toInt())
                  : secondaryTextStyle(size: lblSize.toInt()),
            ),
          ),
          const SizedBox(width: 16),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: boldTextStyle(size: size.toInt(), color: color),
            ),
          ),
        ],
      ),
    );
  }
}
