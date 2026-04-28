import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../main.dart';
import '../../../utils/app_common.dart';
import '../../../utils/colors.dart';
import '../models/governorate_model.dart';

class SelectedGovernorateHeader extends StatelessWidget {
  final GovernorateModel governorate;

  const SelectedGovernorateHeader({super.key, required this.governorate});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final dark = isDarkMode.value;
      final lang = selectedLanguageCode.value;
      return Container(
        margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
            Icon(Icons.location_on, color: appColorSecondary, size: 22),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    governorate.displayName(lang),
                    style: boldTextStyle(size: 16),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    locale.value.showingCitiesInGovernorate,
                    style: secondaryTextStyle(size: 13),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}
