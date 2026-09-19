import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:url_launcher/url_launcher.dart';

import '../configs.dart';
import '../main.dart';

Future<void> callEmergencyHotline() async {
  final hotline = EMERGENCY_HOTLINE.trim();
  if (hotline.isEmpty) return;

  final uri = Uri(scheme: 'tel', path: hotline);
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri);
    return;
  }

  await Clipboard.setData(ClipboardData(text: hotline));
  toast(locale.value.emergencyNumberCopied);
}

class GlobalEmergencyCallButton extends StatelessWidget {
  const GlobalEmergencyCallButton({super.key});

  @override
  Widget build(BuildContext context) {
    if (EMERGENCY_HOTLINE.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    return Semantics(
      container: true,
      button: true,
      label: '${locale.value.emergencyHotline}: $EMERGENCY_HOTLINE',
      child: ExcludeSemantics(
        child: Tooltip(
          message: '${locale.value.callNow}: $EMERGENCY_HOTLINE',
          child: FloatingActionButton(
            heroTag: 'global_emergency_hotline',
            onPressed: callEmergencyHotline,
            backgroundColor: errorColor,
            foregroundColor: Colors.white,
            child: const Icon(Icons.emergency_rounded),
          ),
        ),
      ),
    );
  }
}
