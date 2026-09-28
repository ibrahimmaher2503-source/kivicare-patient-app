import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../../api/pharmacy_apis.dart';
import '../../../components/app_scaffold.dart';
import '../../../main.dart';
import '../../../utils/colors.dart';
import '../model/pharmacy_prescription_model.dart';
import '../utils/pharmacy_constants.dart';
import '../utils/pharmacy_empty_state.dart';
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
      scaffoldBackgroundColor: appLayoutBackground,
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 12, top: 6, bottom: 6),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => Get.to(() => PrescriptionUploadScreen()),
              child: Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: appColorSecondary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: appColorSecondary.withValues(alpha: 0.18),
                    width: 1,
                  ),
                ),
                child: const Icon(Icons.add_rounded,
                    color: appColorSecondary, size: 20),
              ),
            ),
          ),
        ),
      ],
      body: Obx(
          () => controller.prescriptions.isEmpty && !controller.isLoading.value
              ? PharmacyEmptyState(
                  icon: Icons.description_outlined,
                  title: locale.value.pharmacyNoPrescriptions,
                  primaryLabel: locale.value.uploadPrescription,
                  onPrimary: () => Get.to(() => PrescriptionUploadScreen()),
                )
              : AnimatedScrollView(
                  padding: const EdgeInsets.all(16),
                  onSwipeRefresh: () => controller.refresh(),
                  onNextPage: () => controller.loadMore(),
                  children: [
                    ...controller.prescriptions.map((prescription) =>
                        _PrescriptionWidget(prescription: prescription)),
                  ],
                )),
      fabWidget: Container(
        height: 56,
        width: 56,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [gradientSecondaryStart, gradientSecondaryEnd],
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
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: () => Get.to(() => PrescriptionUploadScreen()),
            child: const Icon(Icons.file_upload_outlined,
                color: Colors.white, size: 26),
          ),
        ),
      ),
    );
  }
}

class _PrescriptionWidget extends StatelessWidget {
  final PharmacyPrescription prescription;

  const _PrescriptionWidget({required this.prescription});

  @override
  Widget build(BuildContext context) {
    final Color statusColor =
        PharmacyConstants.getPrescriptionStatusColor(prescription.status ?? '');
    return GestureDetector(
      onTap: () =>
          Get.to(() => PrescriptionDetailScreen(prescription: prescription)),
      child: Container(
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
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              height: 56,
              width: 56,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                gradient: prescription.images.validate().isEmpty
                    ? const LinearGradient(
                        colors: [
                          gradientSecondaryStart,
                          gradientSecondaryEnd,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: prescription.images.validate().isEmpty
                    ? null
                    : surfaceSubtle,
                boxShadow: prescription.images.validate().isEmpty
                    ? [
                        BoxShadow(
                          color: appColorSecondary.withValues(alpha: 0.22),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: prescription.images.validate().isNotEmpty
                  ? CachedNetworkImage(
                          imageUrl: prescription.images![0], fit: BoxFit.cover)
                      .cornerRadiusWithClipRRect(14)
                  : const Icon(Icons.medical_information_rounded,
                      color: Colors.white, size: 28),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                      '${locale.value.pharmacyPrescriptionLabel} #${prescription.id}',
                      style: boldTextStyle(size: 14)),
                  const SizedBox(height: 4),
                  Text(prescription.createdAt ?? '',
                      style: secondaryTextStyle(size: 12)),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    height: 6,
                    width: 6,
                    decoration: BoxDecoration(
                        color: statusColor, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    PharmacyConstants.prescriptionStatusLabel(
                      locale.value,
                      prescription.status.validate(),
                    ),
                    style: boldTextStyle(color: statusColor, size: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
