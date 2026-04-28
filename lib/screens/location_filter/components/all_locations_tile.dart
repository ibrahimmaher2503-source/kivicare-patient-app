import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../utils/app_common.dart';
import '../../../utils/colors.dart';

class AllLocationsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const AllLocationsTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final dark = isDarkMode.value;
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: dark ? surfaceElevatedDark : surfaceSubtle,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: dark ? borderColorDark : whiteBorderColor,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: lightAccentColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: appColorSecondary, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(title, style: boldTextStyle(size: 16)),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: secondaryTextStyle(size: 13),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: dark ? textTertiaryDark : appBodyColor,
                size: 14,
              ),
            ],
          ),
        ),
      );
    });
  }
}
