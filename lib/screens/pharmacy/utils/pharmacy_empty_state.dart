import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../../utils/colors.dart';

class PharmacyEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? hint;
  final String? primaryLabel;
  final VoidCallback? onPrimary;
  final String? secondaryLabel;
  final VoidCallback? onSecondary;

  const PharmacyEmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.hint,
    this.primaryLabel,
    this.onPrimary,
    this.secondaryLabel,
    this.onSecondary,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(32, 24, 32, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: surfaceSubtle,
                shape: BoxShape.circle,
                border: Border.all(color: whiteBorderColor, width: 1),
              ),
              alignment: Alignment.center,
              child: Icon(icon, size: 36, color: appColorSecondary),
            ),
            const SizedBox(height: 20),
            Text(title,
                style: boldTextStyle(size: 18, color: appColorPrimary),
                textAlign: TextAlign.center),
            if (hint != null) ...[
              const SizedBox(height: 8),
              Text(hint!,
                  style: secondaryTextStyle(size: 13),
                  textAlign: TextAlign.center),
            ],
            if (primaryLabel != null) ...[
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    gradient: const LinearGradient(
                      colors: [gradientSecondaryStart, gradientSecondaryEnd],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                          color: softShadowColorMedium,
                          blurRadius: 14,
                          offset: const Offset(0, 6)),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: onPrimary,
                      child: Center(
                        child: Text(primaryLabel!,
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 15)),
                      ),
                    ),
                  ),
                ),
              ),
            ],
            if (secondaryLabel != null) ...[
              const SizedBox(height: 10),
              TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: appColorSecondary,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                ),
                onPressed: onSecondary,
                child: Text(secondaryLabel!,
                    style: boldTextStyle(size: 14, color: appColorSecondary)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
