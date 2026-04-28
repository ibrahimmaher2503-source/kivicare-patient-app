import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../main.dart';
import '../../../utils/app_common.dart';
import '../../../utils/colors.dart';
import '../models/city_model.dart';
import 'location_count_badge.dart';

class CityListTile extends StatelessWidget {
  final CityModel city;
  final bool selected;
  final VoidCallback onTap;

  const CityListTile({
    super.key,
    required this.city,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final dark = isDarkMode.value;
      final lang = selectedLanguageCode.value;
      final bgColor = selected
          ? (dark ? appColorSecondary.withValues(alpha: 0.15) : lightAccentColor)
          : Colors.transparent;
      final borderColorRes = selected
          ? appColorSecondary
          : (dark ? borderColorDark : whiteBorderColor);
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColorRes, width: selected ? 1.5 : 1),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      city.displayName(lang),
                      style: selected
                          ? boldTextStyle(size: 16, color: appColorSecondary)
                          : primaryTextStyle(size: 16),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (city.doctorsCount > 0) ...[
                      const SizedBox(height: 6),
                      LocationCountBadge(
                        count: city.doctorsCount,
                        labelTemplate: locale.value.xDoctors,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                selected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                color: selected
                    ? appColorSecondary
                    : (dark ? textTertiaryDark : appBodyColor),
                size: 22,
              ),
            ],
          ),
        ),
      );
    });
  }
}
