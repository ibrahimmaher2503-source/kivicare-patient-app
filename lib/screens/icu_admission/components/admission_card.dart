import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../../main.dart';
import '../../../utils/colors.dart';
import '../../../utils/constants.dart';
import '../models/admission_request_model.dart';

class AdmissionCard extends StatelessWidget {
  final AdmissionRequest request;

  const AdmissionCard({super.key, required this.request});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.primaryColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(defaultRadius),
        border: Border.all(color: context.primaryColor.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.meeting_room_rounded, color: appColorPrimary),
              8.width,
              Text(locale.value.admissionDetails, style: boldTextStyle(color: appColorPrimary)),
            ],
          ),
          16.height,
          Row(
            children: [
              _buildInfoItem(locale.value.room, request.assignedRoom.validate(value: 'N/A')),
              16.width,
              _buildInfoItem(locale.value.bed, request.assignedBed.validate(value: 'N/A')),
            ],
          ),
          if (request.admittedAt != null) ...[
            16.height,
            _buildInfoItem(
              locale.value.admittedAt,
              DateFormat(DateFormatConst.EEEE_D_MMMM_At_HH_mm_a).format(request.admittedAt!),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: secondaryTextStyle(size: 12)),
        Text(value, style: boldTextStyle(size: 14)),
      ],
    );
  }
}
