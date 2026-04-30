import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../../api/pharmacy_apis.dart';
import '../../../components/app_scaffold.dart';
import '../../../utils/empty_error_state_widget.dart';
import '../../../main.dart';
import '../../../utils/colors.dart';
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
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: boxDecorationDefault(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: softShadowColor,
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 60,
                width: 60,
                decoration: boxDecorationDefault(
                    color: lightPrimaryColor, shape: BoxShape.circle),
                child: pharmacy.image != null
                    ? CachedNetworkImage(
                            imageUrl: pharmacy.image!, fit: BoxFit.cover)
                        .cornerRadiusWithClipRRect(30)
                    : const Icon(Icons.local_pharmacy_outlined,
                        color: appColorPrimary),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(pharmacy.name ?? '', style: boldTextStyle(size: 16)),
                    Text(pharmacy.address ?? '',
                        style: secondaryTextStyle(size: 12),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.star, color: ratingColor, size: 14),
                        const SizedBox(width: 4),
                        Text('${pharmacy.rating ?? 0.0}',
                            style: secondaryTextStyle(size: 12)),
                        const SizedBox(width: 12),
                        const Icon(Icons.location_on_outlined,
                            color: secondaryTextColor, size: 14),
                        const SizedBox(width: 4),
                        Text('${pharmacy.distance?.toStringAsFixed(1)} km',
                            style: secondaryTextStyle(size: 12)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(locale.value.deliveryFee,
                      style: secondaryTextStyle(size: 10)),
                  Text('${pharmacy.deliveryFee} LE',
                      style: boldTextStyle(size: 14, color: appColorSecondary)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(Icons.access_time,
                      size: 14, color: secondaryTextColor),
                  Text(pharmacy.estimatedDeliveryTime ?? '-',
                      style: primaryTextStyle(size: 12)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: boxDecorationDefault(
                  color: (pharmacy.canFulfillFullCart ?? false)
                      ? Colors.green.withValues(alpha: 0.1)
                      : Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  (pharmacy.canFulfillFullCart ?? false)
                      ? locale.value.fulfillFullCart
                      : locale.value.fulfillPartialCart,
                  style: boldTextStyle(
                      color: (pharmacy.canFulfillFullCart ?? false)
                          ? Colors.green
                          : Colors.orange,
                      size: 10),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          AppButton(
            text: locale.value.select,
            color: appColorPrimary,
            textColor: Colors.white,
            width: Get.width,
            padding: const EdgeInsets.symmetric(vertical: 8),
            shapeBorder:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            onTap: () {
              if (pharmacy.canFulfillFullCart ?? false) {
                Get.to(() => PharmacyCheckoutScreen(pharmacy: pharmacy));
              } else {
                showConfirmDialog(
                  context,
                  locale.value.partialFulfillWarning,
                  positiveText: locale.value.proceed,
                  negativeText: locale.value.chooseAnother,
                  onAccept: () {
                    Get.to(() => PharmacyCheckoutScreen(pharmacy: pharmacy));
                  },
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
