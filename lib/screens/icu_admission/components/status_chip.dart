import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../../main.dart';
import '../../../utils/colors.dart';
import '../models/admission_request_model.dart';

class StatusChip extends StatelessWidget {
  final AdmissionStatus status;

  const StatusChip({super.key, required this.status});

  Color _getStatusColor() {
    switch (status) {
      case AdmissionStatus.pending:
        return icuStatusPendingColor;
      case AdmissionStatus.underReview:
        return icuStatusInfoRequestedColor;
      case AdmissionStatus.approved:
        return icuStatusAcceptedColor;
      case AdmissionStatus.admitted:
        return appColorPrimary;
      case AdmissionStatus.discharged:
        return icuStatusCancelledColor;
      case AdmissionStatus.rejected:
      case AdmissionStatus.cancelled:
        return icuStatusRejectedColor;
    }
  }

  String _getStatusLabel() {
    switch (status) {
      case AdmissionStatus.pending:
        return locale.value.pending;
      case AdmissionStatus.underReview:
        return locale.value.underReview;
      case AdmissionStatus.approved:
        return locale.value.approved;
      case AdmissionStatus.admitted:
        return locale.value.admitted;
      case AdmissionStatus.discharged:
        return locale.value.discharged;
      case AdmissionStatus.rejected:
        return locale.value.rejected;
      case AdmissionStatus.cancelled:
        return locale.value.cancelled;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getStatusColor();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Text(
        _getStatusLabel().toUpperCase(),
        style: boldTextStyle(color: color, size: 10),
      ),
    );
  }
}
