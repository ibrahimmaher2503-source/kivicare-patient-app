import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../main.dart';
import '../../../utils/app_common.dart';
import '../../../utils/colors.dart';

class LocationSearchBar extends StatelessWidget {
  final String hintText;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const LocationSearchBar({
    super.key,
    required this.hintText,
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final dark = isDarkMode.value;
      return Container(
        margin: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        decoration: BoxDecoration(
          color: dark ? inputFillColorDark : inputFillColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: ValueListenableBuilder<TextEditingValue>(
          valueListenable: controller,
          builder: (context, value, _) {
            return TextField(
              controller: controller,
              onChanged: onChanged,
              style: primaryTextStyle(size: 16),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: hintText,
                hintStyle: secondaryTextStyle(size: 14),
                prefixIcon: Icon(
                  Icons.search,
                  color: dark ? textTertiaryDark : appBodyColor,
                  size: 20,
                ),
                suffixIcon: value.text.isEmpty
                    ? null
                    : IconButton(
                        icon: Icon(
                          Icons.close,
                          color: dark ? textTertiaryDark : appBodyColor,
                          size: 18,
                        ),
                        onPressed: () {
                          controller.clear();
                          onChanged('');
                        },
                        tooltip: locale.value.clearSearch,
                      ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              ),
            );
          },
        ),
      );
    });
  }
}
