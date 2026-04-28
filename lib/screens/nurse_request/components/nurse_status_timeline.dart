import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kivicare_patient/main.dart';
import 'package:kivicare_patient/utils/colors.dart';
import 'package:nb_utils/nb_utils.dart';

import '../models/nurse_request_model.dart';
import '../models/nurse_status.dart';
import '../models/status_history_entry.dart';

class NurseStatusTimeline extends StatelessWidget {
  final NurseRequestModel request;

  const NurseStatusTimeline({super.key, required this.request});

  static const _forwardSteps = [
    NurseStatus.pending,
    NurseStatus.assigned,
    NurseStatus.confirmed,
    NurseStatus.inProgress,
    NurseStatus.completed,
  ];

  @override
  Widget build(BuildContext context) {
    final currentStatus = NurseStatusExtension.fromString(request.status);
    final isCancelled = currentStatus == NurseStatus.cancelled;

    final steps = isCancelled ? [..._forwardSteps, NurseStatus.cancelled] : _forwardSteps;

    return Column(
      children: List.generate(steps.length, (i) {
        final step = steps[i];
        final isCancelledStep = step == NurseStatus.cancelled;
        final isReached = _isReached(step, currentStatus, isCancelled);
        final isLast = i == steps.length - 1;
        final timestamp = _timestampFor(step, request.statusHistory);

        return _TimelineStep(
          label: step.displayLabel(locale.value),
          timestamp: timestamp,
          isReached: isReached,
          isCancelled: isCancelledStep,
          showLine: !isLast,
          nextReached: !isLast && _isReached(steps[i + 1], currentStatus, isCancelled),
        );
      }),
    );
  }

  bool _isReached(NurseStatus step, NurseStatus current, bool isCancelled) {
    if (step == NurseStatus.cancelled) return isCancelled;
    if (isCancelled) {
      final cancelledIdx = _forwardSteps.indexOf(current);
      final stepIdx = _forwardSteps.indexOf(step);
      return stepIdx <= cancelledIdx;
    }
    final currentIdx = _forwardSteps.indexOf(current);
    final stepIdx = _forwardSteps.indexOf(step);
    return stepIdx <= currentIdx;
  }

  String? _timestampFor(NurseStatus step, List<StatusHistoryEntry> history) {
    for (final entry in history.reversed) {
      if (NurseStatusExtension.fromString(entry.newStatus) == step) {
        return DateFormat('dd MMM HH:mm').format(entry.changedAt);
      }
    }
    return null;
  }
}

class _TimelineStep extends StatelessWidget {
  final String label;
  final String? timestamp;
  final bool isReached;
  final bool isCancelled;
  final bool showLine;
  final bool nextReached;

  const _TimelineStep({
    required this.label,
    this.timestamp,
    required this.isReached,
    required this.isCancelled,
    required this.showLine,
    required this.nextReached,
  });

  @override
  Widget build(BuildContext context) {
    final activeColor = isCancelled ? Colors.red : gradientStart;
    final circleColor = isReached ? activeColor : Colors.grey.shade300;
    final lineColor = nextReached ? gradientStart : Colors.grey.shade300;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: isReached ? activeColor : Colors.transparent,
                  shape: BoxShape.circle,
                  border: Border.all(color: circleColor, width: 2),
                ),
                child: isReached
                    ? const Icon(Icons.check, color: Colors.white, size: 12)
                    : null,
              ),
              if (showLine)
                Expanded(child: Container(width: 2, color: lineColor)),
            ],
          ),
          12.width,
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: boldTextStyle(
                      size: 14,
                      color: isReached ? activeColor : Colors.grey,
                    ),
                  ),
                  if (timestamp != null)
                    Text(timestamp!, style: secondaryTextStyle(size: 11)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
