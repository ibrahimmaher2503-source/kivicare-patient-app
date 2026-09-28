import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../../components/global_emergency_call_button.dart';
import '../../../configs.dart';
import '../../../main.dart';

class EmergencyBanner extends StatelessWidget {
  const EmergencyBanner({super.key});

  @override
  Widget build(BuildContext context) {
    if (EMERGENCY_HOTLINE.trim().isEmpty) {
      return const SizedBox.shrink();
    }
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: errorColor.withValues(alpha: 0.1),
        border: Border(
            bottom: BorderSide(color: errorColor.withValues(alpha: 0.2))),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: errorColor, size: 24),
          12.width,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  locale.value.emergencyHotline,
                  style: boldTextStyle(color: errorColor, size: 14),
                ),
                Text(
                  EMERGENCY_HOTLINE,
                  style: secondaryTextStyle(size: 12),
                ),
              ],
            ),
          ),
          AppButton(
            text: locale.value.callNow,
            color: errorColor,
            textStyle: boldTextStyle(color: Colors.white, size: 12),
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            onTap: callEmergencyHotline,
          ),
        ],
      ),
    );
  }
}
