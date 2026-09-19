import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../../api/pharmacy_apis.dart';
import '../../../components/app_scaffold.dart';
import '../../../utils/empty_error_state_widget.dart';
import '../../../main.dart';
import '../../../utils/colors.dart';
import '../../../utils/common_base.dart';
import '../../../utils/price_widget.dart';
import '../model/pharmacy_model.dart';
import 'pharmacy_checkout_screen.dart';

class AvailablePharmaciesController extends GetxController {
  RxBool isLoading = false.obs;
  RxList<Pharmacy> pharmacies = <Pharmacy>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchPharmacies();
  }

  Future<void> fetchPharmacies() async {
    isLoading(true);
    try {
      final res = await PharmacyApis.getAvailablePharmacies();
      if (res != null && res['data'] != null) {
        pharmacies(
            (res['data'] as List).map((e) => Pharmacy.fromJson(e)).toList());
      }
    } catch (e) {
      log('Error fetching available pharmacies: $e');
    } finally {
      isLoading(false);
    }
  }
}

class AvailablePharmaciesScreen extends StatelessWidget {
  AvailablePharmaciesScreen({super.key});

  final AvailablePharmaciesController controller =
      Get.put(AvailablePharmaciesController());

  @override
  Widget build(BuildContext context) {
    return AppScaffoldNew(
      appBartitleText: locale.value.availablePharmacies,
      isLoading: controller.isLoading,
      body:
          Obx(() => controller.pharmacies.isEmpty && !controller.isLoading.value
              ? NoDataWidget(
                  title: locale.value.pharmacyNoPharmaciesAvailable,
                  imageWidget: const ErrorStateWidget(),
                  onRetry: () => controller.fetchPharmacies(),
                ).paddingAll(16)
              : AnimatedScrollView(
                  padding: const EdgeInsets.all(16),
                  onSwipeRefresh: () => controller.fetchPharmacies(),
                  children: [
                    ...controller.pharmacies
                        .map((pharmacy) => _PharmacyWidget(pharmacy: pharmacy)),
                  ],
                )),
    );
  }
}

class _PharmacyWidget extends StatelessWidget {
  final Pharmacy pharmacy;

  const _PharmacyWidget({required this.pharmacy});

  @override
  Widget build(BuildContext context) {
    final canFulfill = pharmacy.canFulfillFullCart ?? false;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 56,
                width: 56,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  gradient: const LinearGradient(
                    colors: [gradientSecondaryStart, gradientSecondaryEnd],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: appColorSecondary.withValues(alpha: 0.22),
                      blurRadius: 12,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: pharmacy.image != null
                    ? CachedNetworkImage(
                            imageUrl: pharmacy.image!, fit: BoxFit.cover)
                        .cornerRadiusWithClipRRect(14)
                    : const Icon(Icons.local_pharmacy_rounded,
                        color: Colors.white, size: 26),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(pharmacy.name ?? '',
                        style: boldTextStyle(size: 15, color: appColorPrimary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined,
                            color: appColorSecondary, size: 14),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(pharmacy.address ?? '',
                              style: secondaryTextStyle(size: 12),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.star, color: ratingColor, size: 14),
                        const SizedBox(width: 4),
                        Text('${pharmacy.rating ?? 0.0}',
                            style: secondaryTextStyle(size: 12)),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsetsDirectional.only(
                    start: 8, end: 10, top: 4, bottom: 4),
                decoration: BoxDecoration(
                  color: appColorSecondary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: appColorSecondary.withValues(alpha: 0.18),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.near_me_rounded,
                        size: 12, color: appColorSecondary),
                    const SizedBox(width: 4),
                    Text(
                      '${pharmacy.distance?.toStringAsFixed(1) ?? "-"} km',
                      style: boldTextStyle(size: 12, color: appColorSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(height: 1, color: whiteBorderColor),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(locale.value.deliveryFee,
                      style: secondaryTextStyle(size: 12)),
                  const SizedBox(height: 2),
                  Text(formatCurrencyValue(pharmacy.deliveryFee),
                      style: boldTextStyle(size: 14, color: appColorSecondary)),
                ],
              ),
              Row(
                children: [
                  const Icon(Icons.access_time,
                      size: 14, color: secondaryTextColor),
                  const SizedBox(width: 4),
                  Text(pharmacy.estimatedDeliveryTime ?? '-',
                      style: primaryTextStyle(size: 12)),
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color:
                      (canFulfill ? completedStatusColor : pendingStatusColor)
                          .withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  canFulfill
                      ? locale.value.fulfillFullCart
                      : locale.value.fulfillPartialCart,
                  style: boldTextStyle(
                      color: canFulfill
                          ? completedStatusColor
                          : pendingStatusColor,
                      size: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              gradient: const LinearGradient(
                colors: [gradientSecondaryStart, gradientSecondaryEnd],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              boxShadow: [
                BoxShadow(
                    color: softShadowColor,
                    blurRadius: 12,
                    offset: const Offset(0, 4)),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(14),
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () {
                  if (canFulfill) {
                    doIfLoggedIn(() => Get.to(
                          () => PharmacyCheckoutScreen(pharmacy: pharmacy),
                        ));
                  } else {
                    showConfirmDialog(
                      context,
                      locale.value.partialFulfillWarning,
                      positiveText: locale.value.proceed,
                      negativeText: locale.value.chooseAnother,
                      onAccept: () {
                        doIfLoggedIn(() => Get.to(
                              () => PharmacyCheckoutScreen(pharmacy: pharmacy),
                            ));
                      },
                    );
                  }
                },
                child: Container(
                  height: 48,
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        locale.value.select,
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 14),
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
        ],
      ),
    );
  }
}
