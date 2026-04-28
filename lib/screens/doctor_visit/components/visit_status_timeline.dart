import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../main.dart';
import '../../../utils/colors.dart';
import '../models/visit_request_model.dart';
import '../models/visit_status.dart';

class VisitStatusTimeline extends StatelessWidget {
  final VisitRequestModel request;

  const VisitStatusTimeline({super.key, required this.request});

  @override
  Widget build(BuildContext context) {
    final steps = _buildSteps(request);
    return Column(
      children: List.generate(steps.length, (i) {
        return _TimelineRow(step: steps[i], isLast: i == steps.length - 1);
      }),
    );
  }

  List<_Step> _buildSteps(VisitRequestModel r) {
    bool reached(VisitStatus s) => r.statusHistories.any((h) => h.newStatus == s);
    DateTime? at(VisitStatus s) {
      for (final h in r.statusHistories) {
        if (h.newStatus == s) return h.changedAt;
      }
      return null;
    }

    final list = <_Step>[
      _Step(
        label: locale.value.pending,
        time: at(VisitStatus.pending),
        reached: reached(VisitStatus.pending),
        active: r.status == VisitStatus.pending,
      ),
      _Step(
        label: locale.value.confirmed,
        time: at(VisitStatus.confirmed),
        reached: reached(VisitStatus.confirmed),
        active: r.status == VisitStatus.confirmed,
      ),
    ];

    if (r.status == VisitStatus.cancelled) {
      list.add(_Step(
        label: locale.value.cancelled,
        time: at(VisitStatus.cancelled),
        reached: true,
        active: true,
        cancelled: true,
      ));
    } else {
      list.add(_Step(
        label: locale.value.completed,
        time: at(VisitStatus.completed),
        reached: reached(VisitStatus.completed),
        active: r.status == VisitStatus.completed,
      ));
    }

    return list;
  }
}

class _Step {
  final String label;
  final DateTime? time;
  final bool reached;
  final bool active;
  final bool cancelled;

  _Step({
    required this.label,
    this.time,
    required this.reached,
    required this.active,
    this.cancelled = false,
  });
}

class _TimelineRow extends StatelessWidget {
  final _Step step;
  final bool isLast;

  const _TimelineRow({required this.step, required this.isLast});

  @override
  Widget build(BuildContext context) {
    final dotColor = step.cancelled
        ? Colors.red.shade600
        : step.reached
            ? gradientSecondaryStart
            : Colors.grey.shade300;

    final lineColor = step.reached ? gradientSecondaryStart : Colors.grey.shade200;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: dotColor,
                shape: BoxShape.circle,
                border: Border.all(color: dotColor.withValues(alpha: 0.3), width: 3),
              ),
              child: step.reached
                  ? Icon(
                      step.cancelled ? Icons.close : Icons.check,
                      size: 10,
                      color: Colors.white,
                    )
                  : null,
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 40,
                color: lineColor,
              ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(bottom: isLast ? 0 : 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  step.label,
                  style: boldTextStyle(
                    size: 13,
                    color: step.active
                        ? (step.cancelled ? Colors.red.shade700 : gradientSecondaryStart)
                        : step.reached
                            ? appColorPrimary
                            : Colors.grey.shade400,
                  ),
                ),
                if (step.time != null)
                  Text(
                    DateFormat('d MMM yyyy, hh:mm a').format(step.time!.toLocal()),
                    style: secondaryTextStyle(size: 11),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
