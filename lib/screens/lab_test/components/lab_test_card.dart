import 'package:flutter/material.dart';
import 'package:kivicare_patient/models/lab_test_model.dart';
import 'package:kivicare_patient/utils/colors.dart';
import 'package:kivicare_patient/utils/price_widget.dart';
import 'package:nb_utils/nb_utils.dart';

/// Card component for displaying a single lab test in a list
class LabTestCard extends StatelessWidget {
  final LabTest test;
  final VoidCallback onTap;

  const LabTestCard({
    Key? key,
    required this.test,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: appStore.isDarkMode ? cardDarkColor : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: appStore.isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200,
          ),
          boxShadow: [
            BoxShadow(
              color: softShadowColor.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with name and price
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        test.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: boldTextStyle(size: 14),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Code: ${test.code}',
                        style: secondaryTextStyle(size: 12),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Price badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: PriceWidget(
                    price: test.defaultPrice,
                    textStyle: boldTextStyle(
                      size: 13,
                      color: primaryColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Sample type and turnaround time
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    test.sampleType,
                    style: primaryTextStyle(
                      size: 11,
                      color: primaryColor,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    '⏱ ${test.turnaroundTime}',
                    style: secondaryTextStyle(size: 11),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Department badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: test.department == 'radiology'
                    ? Colors.orange.withOpacity(0.1)
                    : Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                test.department.toUpperCase(),
                style: primaryTextStyle(
                  size: 10,
                  color: test.department == 'radiology'
                      ? Colors.orange.shade700
                      : Colors.blue.shade700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
