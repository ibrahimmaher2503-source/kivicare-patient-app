import 'package:flutter/services.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../main.dart';

Future<void> launchDialer(String phone) async {
  final uri = Uri(scheme: 'tel', path: phone);
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri);
  } else {
    toast(locale.value.noDialerAvailable);
  }
}

Future<void> copyReferenceToClipboard(String reference) async {
  await Clipboard.setData(ClipboardData(text: reference));
  toast(locale.value.copied);
}
