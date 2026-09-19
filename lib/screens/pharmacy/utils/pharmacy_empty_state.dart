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
            SizedBox(
              width: 152,
              height: 152,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 152,
                    height: 152,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: appColorSecondary.withValues(alpha: 0.05),
                    ),
                  ),
                  Container(
                    width: 116,
                    height: 116,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: appColorSecondary.withValues(alpha: 0.08),
                      border: Border.all(
                        color: appColorSecondary.withValues(alpha: 0.12),
                        width: 1,
                      ),
                    ),
                  ),
                  Container(
                    width: 76,
                    height: 76,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [gradientSecondaryStart, gradientSecondaryEnd],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: appColorSecondary.withValues(alpha: 0.25),
                          blurRadius: 22,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Icon(icon, size: 36, color: Colors.white),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
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
