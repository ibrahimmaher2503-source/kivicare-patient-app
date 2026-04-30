import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../../main.dart';

class ReferenceNumberCard extends StatelessWidget {
  final String referenceNumber;
  final bool showCopyButton;

  const ReferenceNumberCard({
    super.key,
    required this.referenceNumber,
    this.showCopyButton = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.primaryColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(defaultRadius),
        border: Border.all(color: context.primaryColor.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          Text(locale.value.referenceNumber, style: secondaryTextStyle()),
          8.height,
          Text(
            referenceNumber,
            style: boldTextStyle(size: 24, color: context.primaryColor, letterSpacing: 2),
          ),
          if (showCopyButton) ...[
            12.height,
            TextButton.icon(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: referenceNumber));
                toast(locale.value.referenceCopied);
              },
              icon: const Icon(Icons.copy_rounded, size: 18),
              label: Text(locale.value.copyReference),
            ),
          ],
        ],
      ),
    );
  }
}
