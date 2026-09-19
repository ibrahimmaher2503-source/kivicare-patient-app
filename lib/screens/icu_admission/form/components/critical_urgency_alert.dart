import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../configs.dart';
import '../../../../main.dart';

class CriticalUrgencyAlert extends StatelessWidget {
  const CriticalUrgencyAlert({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: errorColor),
          8.width,
          Text(locale.value.criticalUrgencyAlertTitle, style: boldTextStyle(color: errorColor)),
        ],
      ),
      content: Text(locale.value.criticalUrgencyAlertMessage),
      actions: [
        TextButton(
          onPressed: () => finish(context),
          child: Text(locale.value.continueForm),
        ),
        if (EMERGENCY_HOTLINE.trim().isNotEmpty)
          AppButton(
            text: locale.value.callEmergencyHotline,
            color: errorColor,
            textStyle: boldTextStyle(color: Colors.white, size: 14),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            onTap: () async {
              final uri = Uri.parse('tel:$EMERGENCY_HOTLINE');
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri);
              }
              if (context.mounted) finish(context);
            },
          ),
      ],
    );
  }
}
