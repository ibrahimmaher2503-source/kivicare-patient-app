import 'package:flutter/material.dart';
import 'package:kivicare_patient/main.dart';
import 'package:kivicare_patient/utils/colors.dart';
import 'package:nb_utils/nb_utils.dart';

import 'nurse_request_design.dart';

class NurseCancellationBanner extends StatelessWidget {
  final String? reason;

  const NurseCancellationBanner({super.key, this.reason});

  @override
  Widget build(BuildContext context) {
    if (reason == null || reason!.isEmpty) return const SizedBox.shrink();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: nurseStatusCancelledColor.withValues(
          alpha: nurseRequestIsDark ? 0.18 : 0.08,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: nurseStatusCancelledColor.withValues(alpha: 0.28),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.cancel_outlined,
                color: nurseStatusCancelledColor,
                size: 18,
              ),
              8.width,
              Text(
                locale.value.cancellationReason,
                style: boldTextStyle(
                  size: 14,
                  color: nurseStatusCancelledColor,
                ),
              ),
            ],
          ),
          8.height,
          Text(reason!, style: primaryTextStyle(size: 13)),
        ],
      ),
    );
  }
}
