import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../components/app_scaffold.dart';
import '../../../main.dart';
import '../../../utils/colors.dart';
import '../components/doctor_info_card.dart';
import '../components/offer_discount_card.dart';
import '../components/status_history_tile.dart';
import '../components/visit_status_chip.dart';
import '../components/visit_status_timeline.dart';
import '../models/visit_status.dart';
import 'visit_request_detail_controller.dart';

class VisitRequestDetailScreen extends StatelessWidget {
  final String referenceNumber;

  const VisitRequestDetailScreen({super.key, required this.referenceNumber});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(
      VisitRequestDetailController(referenceNumber: referenceNumber),
      tag: referenceNumber,
    );

    return AppScaffold(
      appBartitleText: locale.value.requestDetails,
      hasLeadingWidget: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh_outlined),
          onPressed: controller.refresh,
          tooltip: locale.value.refresh,
        ),
      ],
      body: Obx(() {
        if (controller.isLoading.value && controller.request.value == null) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.error.value.isNotEmpty && controller.request.value == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: cancelStatusColor),
                const SizedBox(height: 12),
                Text(locale.value.somethingWentWrong, style: boldTextStyle()),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: controller.fetchRequest,
                  child: Text(locale.value.retry),
                ),
              ],
            ),
          );
        }

        final req = controller.request.value;
        if (req == null) return const SizedBox.shrink();

        return RefreshIndicator(
          onRefresh: controller.refresh,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Header card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [gradientStart, gradientEnd],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              Clipboard.setData(ClipboardData(text: req.referenceNumber));
                              toast(locale.value.referenceCopied);
                            },
                            child: Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    req.referenceNumber,
                                    style: boldTextStyle(size: 18, color: white),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Icon(Icons.copy_outlined, size: 16, color: Colors.white70),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        VisitStatusChip(status: req.status),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${locale.value.submittedOn}: ${DateFormat('d MMM yyyy').format(req.createdAt.toLocal())}',
                      style: secondaryTextStyle(size: 12, color: Colors.white70),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Status timeline
              _SectionHeader(title: locale.value.statusTimeline),
              const SizedBox(height: 12),
              VisitStatusTimeline(request: req),

              const SizedBox(height: 20),

              // Cancellation banner
              if (req.status == VisitStatus.cancelled && req.cancellationReason != null)
                Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: cancelStatusColor.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: cancelStatusColor.withValues(alpha: 0.28)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.info_outline, color: cancelStatusColor, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              locale.value.cancellationReason,
                              style: boldTextStyle(size: 13, color: cancelStatusColor),
                            ),
                            const SizedBox(height: 4),
                            Text(req.cancellationReason!, style: primaryTextStyle(size: 13)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

              // Visit info
              _SectionHeader(title: locale.value.visitInformation),
              const SizedBox(height: 12),
              _InfoTile(
                icon: Icons.notes_outlined,
                label: locale.value.visitReason,
                value: req.visitReason,
              ),
              _InfoTile(
                icon: Icons.calendar_today_outlined,
                label: locale.value.preferredDate,
                value: DateFormat('EEEE, d MMMM yyyy').format(req.preferredDate),
              ),
              _InfoTile(
                icon: Icons.phone_outlined,
                label: locale.value.contactPhone,
                value: req.contactPhone,
              ),
              if (req.additionalNotes != null && req.additionalNotes!.isNotEmpty)
                _InfoTile(
                  icon: Icons.comment_outlined,
                  label: locale.value.additionalNotes,
                  value: req.additionalNotes!,
                ),

              const SizedBox(height: 20),

              // Preferred doctor
              if (req.preferredDoctor != null) ...[
                _SectionHeader(title: locale.value.preferredDoctor),
                const SizedBox(height: 12),
                DoctorInfoCard(doctor: req.preferredDoctor!),
                const SizedBox(height: 20),
              ],

              // Assigned doctor
              _SectionHeader(title: locale.value.assignedDoctor),
              const SizedBox(height: 12),
              if (req.assignedDoctor != null)
                DoctorInfoCard(
                  doctor: req.assignedDoctor!,
                  subtitle: locale.value.yourVisitingDoctor,
                )
              else
                Text(
                  locale.value.noDoctorAssignedYet,
                  style: secondaryTextStyle(size: 13),
                ),

              const SizedBox(height: 20),

              // Offer / discount
              if (req.offerId != null && req.offerDiscount != null)
                Column(
                  children: [
                    OfferDiscountCard(
                      offerCode: req.offerCode ?? '',
                      discount: req.offerDiscount!,
                    ),
                    const SizedBox(height: 20),
                  ],
                ),

              // Completed at
              if (req.status == VisitStatus.completed && req.completedAt != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: completedStatusColor.withValues(alpha: 0.09),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: completedStatusColor.withValues(alpha: 0.28)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.task_alt, color: completedStatusColor, size: 20),
                      const SizedBox(width: 10),
                      Text(
                        '${locale.value.visitCompletedAt}: ${DateFormat('d MMM yyyy').format(req.completedAt!.toLocal())}',
                        style: boldTextStyle(size: 13, color: completedStatusColor),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],

              // Status history
              _SectionHeader(title: locale.value.statusHistory),
              const SizedBox(height: 12),
              ...req.statusHistories.reversed
                  .map((h) => StatusHistoryTile(history: h)),

              const SizedBox(height: 32),
            ],
          ),
        );
      }),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: boldTextStyle(size: 15, color: appColorPrimary),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoTile({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: appColorSecondary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: secondaryTextStyle(size: 11)),
                const SizedBox(height: 2),
                Text(value, style: primaryTextStyle(size: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
