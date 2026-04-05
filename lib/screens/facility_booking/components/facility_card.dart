import 'package:flutter/material.dart';
import 'package:kivicare_patient/utils/colors.dart';
import 'package:kivicare_patient/utils/common_base.dart';
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
        margin: EdgeInsets.symmetric(vertical: 8.w),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: isSelected
              ? primaryColor.withOpacity(0.1)
              : (isDarkMode.value ? cardDarkColor : Colors.white),
          border: Border.all(
            color: isSelected ? primaryColor : (isDarkMode.value ? gray700 : gray200),
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12.w),
        ),
        child: Row(
          children: [
            // Leading Icon
            Container(
              width: 48.w,
              height: 48.w,
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(
                  Icons.local_hospital,
                  size: 24.w,
                  color: primaryColor,
                ),
              ),
            ),
            SizedBox(width: 12.w),

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
                    SizedBox(height: 4.w),
                    Text(
                      address!,
                      style: secondaryTextStyle(size: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  if (description != null && description!.isNotEmpty) ...[
                    SizedBox(height: 4.w),
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
            SizedBox(width: 12.w),

            // Selection Indicator
            if (isSelected)
              Icon(
                Icons.check_circle,
                size: 24.w,
                color: primaryColor,
              )
            else
              Icon(
                Icons.radio_button_unchecked,
                size: 24.w,
                color: gray400,
              ),
          ],
        ),
      ),
    );
  }
}
