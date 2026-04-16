import 'package:flutter/material.dart';
import 'package:kivicare_patient/screens/lab_test/model/lab_test_model.dart';
import 'package:kivicare_patient/utils/colors.dart';
import 'package:kivicare_patient/utils/common_base.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../main.dart';
import '../../../utils/app_common.dart';
class RadiologyServiceCard extends StatelessWidget {
  final LabTest test;
  final VoidCallback? onTap;

  const RadiologyServiceCard({
    required this.test,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 12.0),
        padding: EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: isDarkMode.value ? cardDarkColor : Colors.white,
          border: Border.all(color: isDarkMode.value ? gray700 : gray200),
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Test Name & Code
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        test.name,
                        style: boldTextStyle(size: 14),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4.0),
                      Text(
                        test.code,
                        style: secondaryTextStyle(size: 12),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 12.0),
                // Price Badge
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                  decoration: BoxDecoration(
                    color: appColorPrimary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Text(
                    '${appCurrency.value.currencySymbol}${test.defaultPrice.toStringAsFixed(0)}',
                    style: boldTextStyle(size: 13, color: appColorPrimary),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.0),

            // Radiology-specific info
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Sample Type (Imaging format for radiology)
                _DetailItem(
                  icon: Icons.image,
                  label: locale.value.imagingFormat,
                  value: (test.sampleType.replaceAll('_', ' ')).isNotEmpty
                      ? '${test.sampleType.replaceAll('_', ' ')[0].toUpperCase()}${test.sampleType.replaceAll('_', ' ').substring(1)}'
                      : '',
                ),
                SizedBox(height: 8.0),

                // Turnaround Time
                _DetailItem(
                  icon: Icons.schedule,
                  label: locale.value.turnaroundTime,
                  value: test.turnaroundTime,
                ),
                SizedBox(height: 8.0),

                // Description
                Text(
                  test.description,
                  style: secondaryTextStyle(size: 12),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
            SizedBox(height: 12.0),

            // Category Chip
            if (test.category != null)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                decoration: BoxDecoration(
                  color: isDarkMode.value ? gray800 : gray100,
                  borderRadius: BorderRadius.circular(6.0),
                ),
                child: Text(
                  test.category!.name,
                  style: secondaryTextStyle(size: 11),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _DetailItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16.0, color: appColorPrimary),
        SizedBox(width: 8.0),
        Text(label, style: secondaryTextStyle(size: 11)),
        SizedBox(width: 4.0),
        Expanded(
          child: Text(
            value,
            style: boldTextStyle(size: 11),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
}
