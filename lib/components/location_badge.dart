import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

import '../models/governorate_model.dart';
import '../models/city_model.dart';
import '../utils/colors.dart';

Widget locationBadge(Governorate? governorate, City? city) {
  if (governorate == null) return const SizedBox.shrink();
  final text = [governorate.name, city?.name]
      .where((e) => e != null && e.isNotEmpty)
      .join(' - ');
  if (text.isEmpty) return const SizedBox.shrink();

  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: appColorSecondary.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Text(
      text,
      style: secondaryTextStyle(size: 11, color: appColorSecondary),
    ),
  );
}
