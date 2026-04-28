import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kivicare_patient/main.dart';
import 'package:kivicare_patient/utils/colors.dart';
import 'package:nb_utils/nb_utils.dart';

import '../models/nurse_request_model.dart';

class ScheduleSummaryCard extends StatelessWidget {
  final NurseRequestModel request;

  const ScheduleSummaryCard({super.key, required this.request});

  @override
  Widget build(BuildContext context) {
    // preferredDate is wall-clock in Africa/Cairo — render as-is without timezone conversion
    final dateStr = DateFormat('dd MMM yyyy').format(request.preferredDate);
    final durationStr = locale.value.durationHoursValue(request.durationHours);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: softShadowColor, blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Row(locale.value.preferredDate, dateStr),
          if (request.preferredTime != null && request.preferredTime!.isNotEmpty)
            _Row(locale.value.preferredTime, request.preferredTime!),
          _Row(locale.value.durationHours, durationStr),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;

  const _Row(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text('$label:', style: secondaryTextStyle(size: 13)),
          ),
          Expanded(child: Text(value, style: primaryTextStyle(size: 13))),
        ],
      ),
    );
  }
}
