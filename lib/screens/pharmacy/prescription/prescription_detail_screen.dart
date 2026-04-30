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
      appBartitleText: '${locale.value.pharmacyPrescriptionLabel} #${prescription.id}',
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatusCard(context),
            const SizedBox(height: 24),
            Text(locale.value.pharmacyPrescriptionImages, style: boldTextStyle(size: 18)),
            const SizedBox(height: 16),
            _buildImageCarousel(context),
            const SizedBox(height: 24),
            if (prescription.notes.validate().isNotEmpty) ...[
              Text(locale.value.notes, style: boldTextStyle(size: 18)),
              const SizedBox(height: 8),
              Container(
                width: Get.width,
                padding: const EdgeInsets.all(16),
                decoration: boxDecorationDefault(
                    color: context.cardColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: context.dividerColor)),
                child: Text(prescription.notes!, style: primaryTextStyle()),
              ),
              const SizedBox(height: 24),
            ],
            if (prescription.status == PharmacyConstants.prescriptionRejected &&
                prescription.rejectionReason.validate().isNotEmpty) ...[
              Text(locale.value.pharmacyRejectionReason,
                  style: boldTextStyle(size: 18, color: Colors.red)),
              const SizedBox(height: 8),
              Container(
                width: Get.width,
                padding: const EdgeInsets.all(16),
                decoration: boxDecorationDefault(
                    color: Colors.red.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red.withValues(alpha: 0.2))),
                child: Text(prescription.rejectionReason!,
                    style: primaryTextStyle(color: Colors.red)),
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
      padding: const EdgeInsets.all(16),
      decoration: boxDecorationDefault(
        color: statusColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: statusColor.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: statusColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    '${locale.value.status}: ${prescription.status.validate().capitalizeFirstLetter()}',
                    style: boldTextStyle(color: statusColor)),
                Text('${locale.value.pharmacyUploadedOn} ${prescription.createdAt ?? ''}',
                    style: secondaryTextStyle(size: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageCarousel(BuildContext context) {
    if (prescription.images.validate().isEmpty) {
      return Container(
        height: 200,
        width: Get.width,
        decoration: boxDecorationDefault(
            color: gray100, borderRadius: BorderRadius.circular(12)),
        child: const Icon(Icons.image_outlined, color: gray400, size: 48),
      );
    }
    return SizedBox(
      height: 400,
      child: PageView.builder(
        itemCount: prescription.images!.length,
        itemBuilder: (context, index) {
          return CachedNetworkImage(
            imageUrl: prescription.images![index],
            fit: BoxFit.contain,
            width: Get.width,
          ).cornerRadiusWithClipRRect(12).paddingSymmetric(horizontal: 4);
        },
      ),
    );
  }
}
