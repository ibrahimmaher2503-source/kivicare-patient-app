import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

import '../utils/colors.dart';
import '../utils/app_common.dart';

Widget glassInfoCard({required String title, required Widget child}) {
  return Container(
    width: double.infinity,
    margin: const EdgeInsets.only(bottom: 16),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: isDarkMode.value ? surfaceElevatedDark : surfaceSubtle,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: isDarkMode.value ? glassStrokeDark : glassStrokeLight,
      ),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: boldTextStyle(size: 16)),
        const SizedBox(height: 12),
        child,
      ],
    ),
  );
}
