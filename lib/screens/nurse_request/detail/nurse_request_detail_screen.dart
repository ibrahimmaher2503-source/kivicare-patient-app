import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:kivicare_patient/main.dart';
import 'package:kivicare_patient/utils/colors.dart';
import 'package:kivicare_patient/utils/empty_error_state_widget.dart';
import 'package:nb_utils/nb_utils.dart';

import '../components/address_summary_card.dart';
import '../components/assigned_nurse_card.dart';
import '../components/nurse_cancellation_banner.dart';
import '../components/nurse_request_phone_actions.dart';
import '../components/nurse_status_chip.dart';
import '../components/nurse_status_history_tile.dart';
import '../components/nurse_status_timeline.dart';
import '../components/pricing_card.dart';
import '../components/schedule_summary_card.dart';
import '../models/nurse_request_model.dart';
import '../models/nurse_status.dart';
import 'nurse_request_detail_controller.dart';

class NurseRequestDetailScreen extends StatelessWidget {
  final int requestId;

  const NurseRequestDetailScreen({super.key, required this.requestId});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(
      NurseRequestDetailController(requestId: requestId),
      tag: 'detail_$requestId',
      permanent: false,
    );

    return Scaffold(
      backgroundColor: context.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Obx(() {
          final req = controller.request.value;
          return Text(req?.referenceNumber ?? locale.value.myRequests, style: boldTextStyle(size: 16, color: Colors.white));
        }),
        backgroundColor: gradientStart,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          Obx(() {
            final ref = controller.request.value?.referenceNumber;
            if (ref == null) return const SizedBox.shrink();
            return IconButton(
              icon: const Icon(Icons.copy, color: Colors.white),
              tooltip: locale.value.copyReferenceNumber,
              onPressed: () => copyReferenceToClipboard(ref),
            );
          }),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: controller.fetch,
            tooltip: locale.value.retry,
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.request.value == null) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.error.value != null && controller.request.value == null) {
          return NoDataWidget(
            title: controller.error.value!,
            retryText: locale.value.retry,
            imageWidget: const ErrorStateWidget(),
            onRetry: controller.fetch,
          ).paddingSymmetric(horizontal: 16);
        }
        final req = controller.request.value;
        if (req == null) return const SizedBox.shrink();
        return _buildBody(context, req, controller);
      }),
    );
  }

  Widget _buildBody(BuildContext context, NurseRequestModel req, NurseRequestDetailController controller) {
    final localeCode = locale.value.language == 'العربية' ? 'ar' : 'en';
    final description = req.serviceDescriptionLocalized(localeCode) ?? '';
    final status = NurseStatusExtension.fromString(req.status);

    return RefreshIndicator(
      onRefresh: controller.fetch,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: reference + status chip
            Row(
              children: [
                GestureDetector(
                  onTap: () => copyReferenceToClipboard(req.referenceNumber),
                  child: Row(
                    children: [
                      Text(req.referenceNumber, style: boldTextStyle(size: 18, color: gradientStart)),
                      4.width,
                      Icon(Icons.copy, color: gradientStart, size: 16),
                    ],
                  ),
                ),
                const Spacer(),
                NurseStatusChip(status: status),
              ],
            ),
            4.height,
            Text(
              '${locale.value.date}: ${DateFormat('dd MMM yyyy').format(req.createdAt)}',
              style: secondaryTextStyle(size: 12),
            ),
            16.height,

            // Timeline
            NurseStatusTimeline(request: req),
            16.height,

            // Service description
            if (description.isNotEmpty) ...[
              _SectionTitle(locale.value.serviceDescriptionEnglish.split('(').first.trim()),
              8.height,
              Text(description, style: primaryTextStyle(size: 14)),
              16.height,
            ],

            // Schedule
            _SectionTitle(locale.value.preferredDate),
            8.height,
            ScheduleSummaryCard(request: req),
            16.height,

            // Address
            _SectionTitle(locale.value.addressLine1),
            8.height,
            AddressSummaryCard(request: req),
            16.height,

            // Contact phone
            _SectionTitle(locale.value.contactPhone),
            8.height,
            GestureDetector(
              onTap: () => launchDialer(req.contactPhone),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: context.cardColor,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [BoxShadow(color: softShadowColor, blurRadius: 6, offset: const Offset(0, 2))],
                ),
                child: Row(
                  children: [
                    Icon(Icons.call, color: gradientStart, size: 20),
                    8.width,
                    Text(req.contactPhone, style: primaryTextStyle(size: 14, color: gradientStart)),
                  ],
                ),
              ),
            ),
            16.height,

            // Patient notes
            if (req.patientNotes != null && req.patientNotes!.isNotEmpty) ...[
              _SectionTitle(locale.value.patientNotes),
              8.height,
              Text(req.patientNotes!, style: primaryTextStyle(size: 14)),
              16.height,
            ],

            // Assigned nurse (shown only when non-null)
            if (req.assignedNurse != null) ...[
              _SectionTitle(locale.value.assignedNurse),
              8.height,
              AssignedNurseCard(nurse: req.assignedNurse!),
              16.height,
            ],

            // Pricing (shown only when totalAmount != null)
            if (req.totalAmount != null) ...[
              _SectionTitle(locale.value.estimatedTotal),
              8.height,
              PricingCard(
                totalAmount: req.totalAmount!,
                currency: req.currency,
                paymentStatus: req.paymentStatus,
              ),
              16.height,
            ],

            // Cancellation banner
            if (status == NurseStatus.cancelled) ...[
              NurseCancellationBanner(reason: req.cancellationReason),
              16.height,
            ],

            // Completed on
            if (status == NurseStatus.completed && req.completedAt != null) ...[
              Text(
                '${locale.value.completedOn}: ${DateFormat('dd MMM yyyy').format(req.completedAt!)}',
                style: boldTextStyle(size: 14, color: Colors.green),
              ),
              16.height,
            ],

            // Status history accordion
            if (req.statusHistory.isNotEmpty) ...[
              _SectionTitle(locale.value.statusHistory),
              8.height,
              ...req.statusHistory.map((e) => NurseStatusHistoryTile(entry: e)),
              16.height,
            ],
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) => Text(title, style: boldTextStyle(size: 14));
}
