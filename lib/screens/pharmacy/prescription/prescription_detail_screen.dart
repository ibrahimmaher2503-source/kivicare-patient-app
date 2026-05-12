import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../../components/app_scaffold.dart';
import '../../../main.dart';
import '../../../utils/colors.dart';
import '../model/pharmacy_prescription_model.dart';
import '../utils/pharmacy_constants.dart';

class PrescriptionDetailScreen extends StatelessWidget {
  final PharmacyPrescription prescription;

  const PrescriptionDetailScreen({super.key, required this.prescription});

  @override
  Widget build(BuildContext context) {
    return AppScaffoldNew(
      appBartitleText:
          '${locale.value.pharmacyPrescriptionLabel} #${prescription.id}',
      scaffoldBackgroundColor: appLayoutBackground,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatusCard(context),
            const SizedBox(height: 20),
            Text(locale.value.pharmacyPrescriptionImages,
                style: boldTextStyle(size: 16)),
            const SizedBox(height: 12),
            _PrescriptionImageGallery(images: prescription.images ?? []),
            const SizedBox(height: 20),
            if (prescription.notes.validate().isNotEmpty) ...[
              Text(locale.value.notes, style: boldTextStyle(size: 16)),
              const SizedBox(height: 8),
              Container(
                width: Get.width,
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
                child:
                    Text(prescription.notes!, style: primaryTextStyle(size: 14)),
              ),
              const SizedBox(height: 20),
            ],
            if (prescription.status == PharmacyConstants.prescriptionRejected &&
                prescription.rejectionReason.validate().isNotEmpty) ...[
              Text(locale.value.pharmacyRejectionReason,
                  style: boldTextStyle(size: 16, color: cancelStatusColor)),
              const SizedBox(height: 8),
              Container(
                width: Get.width,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cancelStatusColor.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(prescription.rejectionReason!,
                    style: primaryTextStyle(color: cancelStatusColor, size: 14)),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(BuildContext context) {
    Color statusColor =
        PharmacyConstants.getPrescriptionStatusColor(prescription.status ?? '');
    return Container(
      padding: const EdgeInsets.all(20),
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
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 8,
                  width: 8,
                  decoration: BoxDecoration(
                      color: statusColor, shape: BoxShape.circle),
                ),
                const SizedBox(width: 8),
                Text(
                  prescription.status.validate().capitalizeFirstLetter(),
                  style: boldTextStyle(color: statusColor, size: 13),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
              '${locale.value.pharmacyUploadedOn} ${prescription.createdAt ?? ''}',
              style: secondaryTextStyle(size: 12)),
        ],
      ),
    );
  }
}

class _PrescriptionImageGallery extends StatefulWidget {
  final List<String> images;
  const _PrescriptionImageGallery({required this.images});

  @override
  State<_PrescriptionImageGallery> createState() =>
      _PrescriptionImageGalleryState();
}

class _PrescriptionImageGalleryState extends State<_PrescriptionImageGallery> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.images.isEmpty) {
      return Container(
        height: 200,
        width: Get.width,
        decoration: BoxDecoration(
            color: surfaceSubtle, borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.image_outlined, color: gray400, size: 48),
      );
    }
    return Column(
      children: [
        SizedBox(
          height: 320,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (i) => setState(() => _currentPage = i),
            itemCount: widget.images.length,
            itemBuilder: (context, index) {
              return Container(
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
                child: CachedNetworkImage(
                  imageUrl: widget.images[index],
                  fit: BoxFit.cover,
                  width: Get.width,
                ).cornerRadiusWithClipRRect(16),
              ).paddingSymmetric(horizontal: 4);
            },
          ),
        ),
        if (widget.images.length > 1) ...[
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(widget.images.length, (i) {
              final bool active = i == _currentPage;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                height: 6,
                width: active ? 18 : 6,
                decoration: BoxDecoration(
                  color: active ? appColorSecondary : whiteBorderColor,
                  borderRadius: BorderRadius.circular(999),
                ),
              );
            }),
          ),
        ],
      ],
    );
  }
}
