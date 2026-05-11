import 'dart:ui' as ui;

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
import '../components/nurse_request_design.dart';
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
          return Text(
            req?.referenceNumber ?? locale.value.myRequests,
            style: boldTextStyle(size: 16, color: whiteTextColor),
          );
        }),
        backgroundColor: gradientStart,
        foregroundColor: whiteTextColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: whiteTextColor),
            onPressed: controller.fetch,
            tooltip: locale.value.retry,
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.request.value == null) {
          return const _DetailLoadingState();
        }
        if (controller.error.value != null &&
            controller.request.value == null) {
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

  Widget _buildBody(
    BuildContext context,
    NurseRequestModel req,
    NurseRequestDetailController controller,
  ) {
    final localeCode = locale.value.language == 'Ø§Ù„Ø¹Ø±Ø¨ÙŠØ©' ? 'ar' : 'en';
    final description = req.serviceDescriptionLocalized(localeCode) ?? '';
    final status = NurseStatusExtension.fromString(req.status);

    return RefreshIndicator(
      onRefresh: controller.fetch,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _DetailHeader(request: req, status: status),
            16.height,
            NurseStatusTimeline(request: req),
            if (description.isNotEmpty) ...[
              18.height,
              _SectionTitle(
                title: locale.value.description,
                icon: Icons.description_outlined,
              ),
              8.height,
              _TextPanel(text: description),
            ],
            18.height,
            _SectionTitle(
              title: locale.value.preferredDate,
              icon: Icons.event_available_outlined,
            ),
            8.height,
            ScheduleSummaryCard(request: req),
            18.height,
            _SectionTitle(
              title: locale.value.address,
              icon: Icons.location_on_outlined,
            ),
            8.height,
            AddressSummaryCard(request: req),
            18.height,
            _SectionTitle(
              title: locale.value.contactPhone,
              icon: Icons.call_outlined,
            ),
            8.height,
            _CallPanel(phone: req.contactPhone),
            if (req.patientNotes != null && req.patientNotes!.isNotEmpty) ...[
              18.height,
              _SectionTitle(
                title: locale.value.patientNotes,
                icon: Icons.notes_outlined,
              ),
              8.height,
              _TextPanel(text: req.patientNotes!),
            ],
            if (req.assignedNurse != null) ...[
              18.height,
              _SectionTitle(
                title: locale.value.assignedNurse,
                icon: Icons.medical_services_outlined,
              ),
              8.height,
              AssignedNurseCard(nurse: req.assignedNurse!),
            ],
            if (req.totalAmount != null) ...[
              18.height,
              _SectionTitle(
                title: locale.value.estimatedTotal,
                icon: Icons.payments_outlined,
              ),
              8.height,
              PricingCard(
                totalAmount: req.totalAmount!,
                currency: req.currency,
                paymentStatus: req.paymentStatus,
              ),
            ],
            if (status == NurseStatus.cancelled) ...[
              18.height,
              NurseCancellationBanner(reason: req.cancellationReason),
            ],
            if (status == NurseStatus.completed && req.completedAt != null) ...[
              18.height,
              _CompletedPanel(completedAt: req.completedAt!),
            ],
            if (req.statusHistory.isNotEmpty) ...[
              18.height,
              _SectionTitle(
                title: locale.value.statusHistory,
                icon: Icons.history_outlined,
              ),
              8.height,
              ...req.statusHistory.map((e) => NurseStatusHistoryTile(entry: e)),
            ],
          ],
        ),
      ),
    );
  }
}

class _DetailHeader extends StatelessWidget {
  final NurseRequestModel request;
  final NurseStatus status;

  const _DetailHeader({required this.request, required this.status});

  @override
  Widget build(BuildContext context) {
    final submittedDate = DateFormat('dd MMM yyyy').format(request.createdAt);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [gradientStart, gradientEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: nurseRequestIsDark
            ? const []
            : [
                BoxShadow(
                  color: softShadowColorMedium,
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      locale.value.referenceNumber,
                      style: secondaryTextStyle(
                        size: 12,
                        color: whiteTextColor.withValues(alpha: 0.76),
                      ),
                    ),
                    4.height,
                    Text(
                      request.referenceNumber,
                      style: boldTextStyle(size: 22, color: whiteTextColor),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              12.width,
              NurseStatusChip(status: status),
            ],
          ),
          14.height,
          Row(
            children: [
              Expanded(
                child: Text(
                  '${locale.value.date}: $submittedDate',
                  style: secondaryTextStyle(
                    size: 13,
                    color: whiteTextColor.withValues(alpha: 0.78),
                  ),
                ),
              ),
              10.width,
              InkWell(
                onTap: () => copyReferenceToClipboard(request.referenceNumber),
                borderRadius: BorderRadius.circular(22),
                child: Container(
                  constraints: const BoxConstraints(
                    minWidth: 44,
                    minHeight: 44,
                  ),
                  decoration: BoxDecoration(
                    color: whiteTextColor.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: whiteTextColor.withValues(alpha: 0.18),
                    ),
                  ),
                  child: const Icon(
                    Icons.copy,
                    color: whiteTextColor,
                    size: 18,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CallPanel extends StatelessWidget {
  final String phone;

  const _CallPanel({required this.phone});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: nurseRequestCardDecoration(context),
      child: Material(
        color: appTransparentColor,
        child: InkWell(
          onTap: () => launchDialer(phone),
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: gradientSecondaryStart.withValues(alpha: 0.13),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.call,
                    color: gradientSecondaryStart,
                    size: 20,
                  ),
                ),
                12.width,
                Expanded(
                  child: Text(
                    phone,
                    style: boldTextStyle(size: 15, color: gradientStart),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(
                  Directionality.of(context) == ui.TextDirection.rtl
                      ? Icons.arrow_back_ios
                      : Icons.arrow_forward_ios,
                  color: gradientStart,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TextPanel extends StatelessWidget {
  final String text;

  const _TextPanel({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: nurseRequestCardDecoration(context),
      child: Text(text, style: primaryTextStyle(size: 14)),
    );
  }
}

class _CompletedPanel extends StatelessWidget {
  final DateTime completedAt;

  const _CompletedPanel({required this.completedAt});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: completedStatusColor.withValues(
          alpha: nurseRequestIsDark ? 0.18 : 0.09,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: completedStatusColor.withValues(alpha: 0.28)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.check_circle_outline,
            color: completedStatusColor,
            size: 20,
          ),
          10.width,
          Expanded(
            child: Text(
              '${locale.value.completedOn}: ${DateFormat('dd MMM yyyy').format(completedAt)}',
              style: boldTextStyle(size: 14, color: completedStatusColor),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final IconData icon;

  const _SectionTitle({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: gradientSecondaryStart, size: 18),
        8.width,
        Expanded(
          child: Text(
            title,
            style: boldTextStyle(size: 14),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _DetailLoadingState extends StatelessWidget {
  const _DetailLoadingState();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _SkeletonBlock(height: 138, radius: 20),
        16.height,
        _SkeletonBlock(height: 188),
        16.height,
        _SkeletonBlock(height: 96),
        16.height,
        _SkeletonBlock(height: 118),
      ],
    );
  }
}

class _SkeletonBlock extends StatelessWidget {
  final double height;
  final double radius;

  const _SkeletonBlock({required this.height, this.radius = 18});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: nurseRequestSkeletonColor(context),
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}
