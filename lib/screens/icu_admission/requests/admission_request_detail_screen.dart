import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../api/icu_apis.dart';
import '../../../components/operation_verification_screen.dart';
import '../../../main.dart';
import '../../../network/critical_operation.dart';
import '../../../network/network_utils.dart';
import '../../../utils/colors.dart';
import '../../../utils/constants.dart';
import '../components/admission_card.dart';
import '../components/icu_empty_state.dart';
import '../components/icu_shimmer.dart';
import '../components/reference_number_card.dart';
import '../components/status_chip.dart';
import '../components/status_timeline.dart';
import '../models/admission_request_model.dart';

class AdmissionRequestDetailScreen extends StatefulWidget {
  final int requestId;

  const AdmissionRequestDetailScreen({super.key, required this.requestId});

  @override
  State<AdmissionRequestDetailScreen> createState() =>
      _AdmissionRequestDetailScreenState();
}

class _AdmissionRequestDetailScreenState
    extends State<AdmissionRequestDetailScreen> {
  late Future<AdmissionRequest> _requestFuture;
  bool _cancelling = false;

  @override
  void initState() {
    super.initState();
    _requestFuture = IcuApis.getAdmissionRequestDetail(widget.requestId);
  }

  Future<void> _reload() async {
    final future = IcuApis.getAdmissionRequestDetail(widget.requestId);
    setState(() => _requestFuture = future);
    await future;
  }

  Future<void> _cancelRequest() async {
    final reasonController = TextEditingController();
    final reason = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(locale.value.cancelConfirmation),
        content: TextField(
          controller: reasonController,
          maxLines: 3,
          maxLength: 500,
          decoration: InputDecoration(labelText: locale.value.cancelReason),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(locale.value.keepRequest),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.pop(dialogContext, reasonController.text.trim()),
            child: Text(locale.value.confirmCancellation),
          ),
        ],
      ),
    );
    reasonController.dispose();
    if (reason == null || !mounted) return;
    if (reason.trim().isEmpty) {
      toast(locale.value.thisFieldIsRequired);
      return;
    }

    setState(() => _cancelling = true);
    String? operationKey;
    try {
      operationKey = await CriticalOperationStore.begin(
        CriticalOperationType.icuCancellation,
        scope: widget.requestId.toString(),
        requestFingerprint: criticalOperationFingerprint({
          'request_id': widget.requestId,
          'reason': reason,
        }),
      );
      await IcuApis.cancelAdmissionRequest(
        widget.requestId,
        reason,
        idempotencyKey: operationKey,
      );
      await CriticalOperationStore.complete(
        CriticalOperationType.icuCancellation,
        scope: widget.requestId.toString(),
      );
      if (!mounted) return;
      toast(locale.value.requestCancelled);
      await _reload();
    } catch (error) {
      if (mounted) {
        if (error is AmbiguousRequestOutcomeException && operationKey != null) {
          Get.to(() => OperationVerificationScreen(
                operationType: CriticalOperationType.icuCancellation,
                operationKey: operationKey,
              ));
        } else {
          toast(sanitizeBackendMessage(
              error, locale.value.somethingWentWrongPleaseTryAgainLater));
        }
      }
    } finally {
      if (mounted) setState(() => _cancelling = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(locale.value.admissionDetails)),
      body: FutureBuilder<AdmissionRequest>(
        future: _requestFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const IcuShimmer(itemCount: 4, height: 100);
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return IcuEmptyState(
              title: locale.value.somethingWentWrong,
              subtitle: locale.value.somethingWentWrongPleaseTryAgainLater,
              onRetry: _reload,
            );
          }

          final request = snapshot.data!;
          return Stack(
            children: [
              RefreshIndicator(
                onRefresh: _reload,
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            request.hospital.name,
                            style: boldTextStyle(size: 20),
                          ),
                        ),
                        StatusChip(status: request.status),
                      ],
                    ),
                    if (request.department.name.trim().isNotEmpty) ...[
                      6.height,
                      Text(
                        request.department.name,
                        style: secondaryTextStyle(),
                      ),
                    ],
                    16.height,
                    ReferenceNumberCard(
                      referenceNumber: request.referenceNumber,
                    ),
                    20.height,
                    _DetailSection(
                      title: locale.value.basicInformation,
                      children: [
                        _DetailRow(
                          label: locale.value.patientName,
                          value: request.patientName,
                        ),
                        _DetailRow(
                          label: locale.value.patientAge,
                          value: request.patientAge.toString(),
                        ),
                        _DetailRow(
                          label: locale.value.patientGender,
                          value: request.patientGender,
                        ),
                        _DetailRow(
                          label: locale.value.diagnosis,
                          value: request.diagnosis,
                        ),
                        if (request.currentCondition.validate().isNotEmpty)
                          _DetailRow(
                            label: locale.value.currentCondition,
                            value: request.currentCondition!,
                          ),
                      ],
                    ),
                    if (request.showAdmissionCard) ...[
                      16.height,
                      AdmissionCard(request: request),
                    ],
                    if (request.showDischargeInfo) ...[
                      16.height,
                      _DetailSection(
                        title: locale.value.dischargeDetails,
                        children: [
                          if (request.dischargedAt != null)
                            _DetailRow(
                              label: locale.value.dischargedAt,
                              value: DateFormat(
                                DateFormatConst.EEEE_D_MMMM_At_HH_mm_a,
                              ).format(request.dischargedAt!),
                            ),
                          if (request.dischargeSummary.validate().isNotEmpty)
                            _DetailRow(
                              label: locale.value.dischargeSummary,
                              value: request.dischargeSummary!,
                            ),
                        ],
                      ),
                    ],
                    if (request.showCancelOrRejectionBanner) ...[
                      16.height,
                      _StatusMessage(request: request),
                    ],
                    if (request.statusHistory.isNotEmpty) ...[
                      24.height,
                      StatusTimeline(history: request.statusHistory),
                    ],
                    if (request.canCancel) ...[
                      24.height,
                      OutlinedButton.icon(
                        onPressed: _cancelling ? null : _cancelRequest,
                        icon: const Icon(Icons.cancel_outlined),
                        label: Text(locale.value.cancelRequest),
                      ),
                    ],
                    24.height,
                  ],
                ),
              ),
              if (_cancelling)
                const Positioned.fill(
                  child: ColoredBox(
                    color: Color(0x2208234F),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _DetailSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _DetailSection({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: whiteBorderColor),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: boldTextStyle(size: 18)),
            12.height,
            ...children,
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: Text(label, style: secondaryTextStyle())),
          12.width,
          Expanded(
            child: Text(
              value.trim().isEmpty ? '-' : value,
              textAlign: TextAlign.end,
              style: primaryTextStyle(),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusMessage extends StatelessWidget {
  final AdmissionRequest request;

  const _StatusMessage({required this.request});

  @override
  Widget build(BuildContext context) {
    final rejected = request.status == AdmissionStatus.rejected;
    final reason = rejected ? request.rejectionReason : request.cancelReason;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: cancelStatusColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: cancelStatusColor.withValues(alpha: 0.25),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.info_outline, color: cancelStatusColor),
            10.width,
            Expanded(
              child: Text(
                reason.validate().isEmpty ? '-' : reason!,
                style: primaryTextStyle(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
