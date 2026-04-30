import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../../api/pharmacy_apis.dart';
import '../../../components/app_scaffold.dart';
import '../../../utils/empty_error_state_widget.dart';
import '../../../main.dart';
import '../../../utils/colors.dart';
import '../model/pharmacy_prescription_model.dart';
import '../utils/pharmacy_constants.dart';
import 'prescription_detail_screen.dart';
import 'prescription_upload_screen.dart';

class PrescriptionListController extends GetxController {
  RxBool isLoading = false.obs;
  RxList<PharmacyPrescription> prescriptions = <PharmacyPrescription>[].obs;
  RxInt page = 1.obs;
  RxBool isLastPage = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchPrescriptions();
  }

  Future<void> fetchPrescriptions() async {
    if (isLoading.value) return;
    isLoading(true);

    try {
      final res = await PharmacyApis.getPrescriptions(page: page.value);
      if (res != null && res['data'] != null) {
        final List<PharmacyPrescription> newItems = (res['data'] as List)
            .map((e) => PharmacyPrescription.fromJson(e))
            .toList();
        if (page.value == 1) {
          prescriptions(newItems);
        } else {
          prescriptions.addAll(newItems);
        }
        isLastPage(newItems.length < 10);
      }
    } catch (e) {
      log('Error fetching prescriptions: $e');
    } finally {
      isLoading(false);
    }
  }

  Future<void> loadMore() async {
    if (!isLastPage.value && !isLoading.value) {
      page.value++;
      await fetchPrescriptions();
    }
  }

  @override
  Future<void> refresh() async {
    page(1);
    isLastPage(false);
    await fetchPrescriptions();
  }
}

class PrescriptionListScreen extends StatelessWidget {
  PrescriptionListScreen({super.key});

  final PrescriptionListController controller =
      Get.put(PrescriptionListController());

  @override
  Widget build(BuildContext context) {
    return AppScaffoldNew(
      appBartitleText: locale.value.prescriptions,
      isLoading: controller.isLoading,
      actions: [
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: () => Get.to(() => PrescriptionUploadScreen()),
        ),
      ],
      body: Obx(
          () => controller.prescriptions.isEmpty && !controller.isLoading.value
              ? NoDataWidget(
                  title: locale.value.pharmacyNoPrescriptions,
                  retryText: locale.value.uploadPrescription,
                  imageWidget: const ErrorStateWidget(),
                  onRetry: () => Get.to(() => PrescriptionUploadScreen()),
                ).center()
              : AnimatedScrollView(
                  padding: const EdgeInsets.all(16),
                  onSwipeRefresh: () => controller.refresh(),
                  onNextPage: () => controller.loadMore(),
                  children: [
                    ...controller.prescriptions.map((prescription) =>
                        _PrescriptionWidget(prescription: prescription)),
                  ],
                )),
    );
  }
}

class _PrescriptionWidget extends StatelessWidget {
  final PharmacyPrescription prescription;

  const _PrescriptionWidget({required this.prescription});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () =>
          Get.to(() => PrescriptionDetailScreen(prescription: prescription)),
      child: Container(
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
        child: Row(
          children: [
            Container(
              height: 60,
              width: 60,
              decoration: boxDecorationDefault(
                  color: lightPrimaryColor,
                  borderRadius: BorderRadius.circular(12)),
              child: prescription.images.validate().isNotEmpty
                  ? CachedNetworkImage(
                          imageUrl: prescription.images![0], fit: BoxFit.cover)
                      .cornerRadiusWithClipRRect(12)
                  : const Icon(Icons.assignment_outlined,
                      color: appColorPrimary),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${locale.value.pharmacyPrescriptionLabel} #${prescription.id}',
                      style: boldTextStyle()),
                  const SizedBox(height: 4),
                  Text(prescription.createdAt ?? '',
                      style: secondaryTextStyle(size: 12)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: boxDecorationDefault(
                color: PharmacyConstants.getPrescriptionStatusColor(
                        prescription.status ?? '')
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                prescription.status.validate().capitalizeFirstLetter(),
                style: boldTextStyle(
                  color: PharmacyConstants.getPrescriptionStatusColor(
                      prescription.status ?? ''),
                  size: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
