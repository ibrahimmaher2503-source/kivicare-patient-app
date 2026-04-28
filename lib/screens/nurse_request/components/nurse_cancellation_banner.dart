import 'package:flutter/material.dart';
import 'package:kivicare_patient/main.dart';
import 'package:nb_utils/nb_utils.dart';

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
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.cancel_outlined, color: Colors.red.shade700, size: 18),
              8.width,
              Text(
                locale.value.cancellationReason,
                style: boldTextStyle(size: 14, color: Colors.red.shade700),
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
