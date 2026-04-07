import 'package:flutter/material.dart';
import 'package:kivicare_patient/utils/colors.dart';
import 'package:kivicare_patient/utils/common_base.dart';
import 'package:kivicare_patient/utils/app_common.dart';
import 'package:nb_utils/nb_utils.dart';

class FacilityCard extends StatelessWidget {
  final int id;
  final String name;
  final String? address;
  final String? description;
  final bool isSelected;
  final VoidCallback onTap;

  const FacilityCard({
    required this.id,
    required this.name,
    this.address,
    this.description,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: isSelected
              ? appColorPrimary.withValues(alpha: 0.1)
              : (isDarkMode.value ? cardDarkColor : Colors.white),
          border: Border.all(
            color: isSelected ? appColorPrimary : (isDarkMode.value ? gray700 : gray200),
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Row(
          children: [
            // Leading Icon
            Container(
              width: 48.0,
              height: 48.0,
              decoration: BoxDecoration(
                color: appColorPrimary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(
                  Icons.local_hospital,
                  size: 24.0,
                  color: appColorPrimary,
                ),
              ),
            ),
            const SizedBox(width: 12.0),

            // Facility Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: boldTextStyle(size: 14),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (address != null && address!.isNotEmpty) ...[
                    const SizedBox(height: 4.0),
                    Text(
                      address!,
                      style: secondaryTextStyle(size: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  if (description != null && description!.isNotEmpty) ...[
                    const SizedBox(height: 4.0),
                    Text(
                      description!,
                      style: secondaryTextStyle(size: 11),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 12.0),

            // Selection Indicator
            if (isSelected)
              Icon(
                Icons.check_circle,
                size: 24.0,
                color: appColorPrimary,
              )
            else
              Icon(
                Icons.radio_button_unchecked,
                size: 24.0,
                color: gray400,
              ),
          ],
        ),
      ),
    );
  }
}
