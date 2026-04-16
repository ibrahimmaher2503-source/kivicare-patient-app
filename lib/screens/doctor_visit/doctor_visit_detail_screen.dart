import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../components/app_scaffold.dart';
import '../../components/loader_widget.dart';
import '../../main.dart';
import 'components/doctor_visit_status_badge.dart';
import 'doctor_visit_detail_controller.dart';
import 'model/doctor_visit_request_model.dart';

class DoctorVisitDetailScreen extends StatefulWidget {
  final String referenceNumber;

  const DoctorVisitDetailScreen({super.key, required this.referenceNumber});

  @override
  State<DoctorVisitDetailScreen> createState() => _DoctorVisitDetailScreenState();
}

class _DoctorVisitDetailScreenState extends State<DoctorVisitDetailScreen> {
  late DoctorVisitDetailController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(DoctorVisitDetailController(referenceNumber: widget.referenceNumber));
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBartitleText: locale.value.visitRequestDetail,
      body: Obx(() {
        if (controller.isLoading.value && controller.request.value == null) {
          return const LoaderWidget();
        }

        if (controller.errorMessage.value.isNotEmpty && controller.request.value == null) {
          return Center(
            child: Text(controller.errorMessage.value, style: secondaryTextStyle()),
          );
        }

        final req = controller.request.value;
        if (req == null) return const SizedBox.shrink();

        return RefreshIndicator(
          onRefresh: controller.loadDetail,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Expanded(child: Text(req.referenceNumber, style: boldTextStyle(size: 20))),
                    DoctorVisitStatusBadge(status: req.status),
                  ],
                ),
                const SizedBox(height: 20),

                _buildInfoSection(locale.value.visitReason, req.visitReason),
                _buildInfoRow(locale.value.preferredDate, req.preferredDate),
                _buildInfoRow(locale.value.contactPhone, req.contactPhone),

                if (req.additionalNotes.isNotEmpty) _buildInfoSection(locale.value.additionalNotes, req.additionalNotes),

                if (req.preferredDoctor != null) _buildInfoRow(locale.value.preferredDoctorLabel, req.preferredDoctor!.name),

                if (req.assignedDoctor != null) _buildInfoRow(locale.value.assignDoctor, req.assignedDoctor!.name),

                if (req.adminNotes.isNotEmpty) _buildInfoSection(locale.value.adminNotes, req.adminNotes),

                if (req.cancellationReason.isNotEmpty) _buildInfoSection(locale.value.cancellationReason, req.cancellationReason),

                if (req.completedAt.isNotEmpty) _buildInfoRow(locale.value.statusCompletedLabel, req.completedAt.split('T').first),

                _buildInfoRow(locale.value.date, req.createdAt.split('T').first),

                // Admin Actions
                if (controller.canUpdateStatus) ...[
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 16),
                  _buildAdminActions(req),
                ],

                // Assign Doctor
                if (controller.canAssignDoctor) ...[
                  const SizedBox(height: 16),
                  _buildAssignDoctorAction(req),
                ],
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildInfoSection(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: secondaryTextStyle(size: 12)),
          const SizedBox(height: 4),
          Text(value, style: primaryTextStyle()),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 140, child: Text(label, style: secondaryTextStyle(size: 13))),
          Expanded(child: Text(value, style: primaryTextStyle(size: 14))),
        ],
      ),
    );
  }

  Widget _buildAdminActions(DoctorVisitRequest req) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(locale.value.updateStatusLabel, style: boldTextStyle(size: 16)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            if (req.status == 'pending')
              ElevatedButton.icon(
                onPressed: () => _showStatusDialog('confirmed'),
                icon: const Icon(Icons.check_circle, size: 18),
                label: Text(locale.value.confirmVisit),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              ),
            if (req.status == 'confirmed')
              ElevatedButton.icon(
                onPressed: () => _showStatusDialog('completed'),
                icon: const Icon(Icons.task_alt, size: 18),
                label: Text(locale.value.completeVisit),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              ),
            if (req.status == 'pending' || req.status == 'confirmed')
              ElevatedButton.icon(
                onPressed: () => _showCancelDialog(),
                icon: const Icon(Icons.cancel, size: 18),
                label: Text(locale.value.cancelVisit),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildAssignDoctorAction(DoctorVisitRequest req) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () => _showAssignDoctorDialog(),
        icon: const Icon(Icons.person_add),
        label: Text(req.assignedDoctor != null ? locale.value.reassignDoctor : locale.value.assignDoctor),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  void _showStatusDialog(String newStatus) {
    final noteCont = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(locale.value.updateStatusLabel),
        content: TextField(
          controller: noteCont,
          decoration: InputDecoration(
            hintText: locale.value.addNote,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(locale.value.cancel)),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              controller.updateStatus(newStatus, note: noteCont.text.trim());
            },
            child: Text(locale.value.update),
          ),
        ],
      ),
    );
  }

  void _showCancelDialog() {
    final reasonCont = TextEditingController();
    final noteCont = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(locale.value.cancelVisit),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: reasonCont,
              decoration: InputDecoration(
                hintText: locale.value.enterCancellationReason,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: noteCont,
              decoration: InputDecoration(
                hintText: locale.value.addNote,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(locale.value.cancel)),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              controller.updateStatus(
                'cancelled',
                cancellationReason: reasonCont.text.trim(),
                note: noteCont.text.trim(),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(locale.value.cancelVisit),
          ),
        ],
      ),
    );
  }

  void _showAssignDoctorDialog() {
    final doctorIdCont = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(locale.value.assignDoctor),
        content: TextField(
          controller: doctorIdCont,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: 'Doctor ID',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(locale.value.cancel)),
          ElevatedButton(
            onPressed: () {
              final id = int.tryParse(doctorIdCont.text.trim());
              if (id != null) {
                Navigator.pop(ctx);
                controller.assignDoctor(id);
              }
            },
            child: Text(locale.value.assignDoctor),
          ),
        ],
      ),
    );
  }
}
