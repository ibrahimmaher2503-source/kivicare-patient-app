import 'package:flutter/material.dart';
import 'package:kivicare_patient/utils/locale_formatters.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:kivicare_patient/screens/labs_radiology/labs_radiology_common.dart';
import '../../models/test_order_status_history_model.dart';

class StatusTimeline extends StatelessWidget {
  final List<TestOrderStatusHistoryModel> histories;

  const StatusTimeline({super.key, required this.histories});

  @override
  Widget build(BuildContext context) {
    if (histories.isEmpty) return const SizedBox.shrink();

    // Sort newest first for the list
    final sortedHistories = List<TestOrderStatusHistoryModel>.from(histories)
      ..sort((a, b) => b.changedAt.compareTo(a.changedAt));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(locale.value.statusTimeline, style: boldTextStyle()),
        16.height,
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: sortedHistories.length,
          itemBuilder: (context, index) {
            final history = sortedHistories[index];
            final isFirst = index == 0;
            final isLast = index == sortedHistories.length - 1;

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Container(
                      height: 12,
                      width: 12,
                      decoration: boxDecorationDefault(
                        shape: BoxShape.circle,
                        color: isFirst
                            ? context.primaryColor
                            : context.dividerColor,
                      ),
                    ),
                    if (!isLast)
                      Container(
                        height: 40,
                        width: 2,
                        color: context.dividerColor,
                      ),
                  ],
                ),
                16.width,
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      history.newStatus.displayLabel(locale.value),
                      style: boldTextStyle(
                          size: 14,
                          color: isFirst
                              ? context.primaryColor
                              : context.iconColor),
                    ),
                    4.height,
                    Text(
                      formatLocalizedDate(
                        history.changedAt,
                        'MMM d, yyyy - hh:mm a',
                      ),
                      style: secondaryTextStyle(size: 12),
                    ),
                    if (history.note.validate().isNotEmpty) ...[
                      4.height,
                      Text(history.note!,
                          style: secondaryTextStyle(
                              size: 12, color: context.iconColor)),
                    ],
                  ],
                ).expand(),
              ],
            );
          },
        ),
      ],
    );
  }
}
