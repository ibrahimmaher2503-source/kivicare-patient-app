import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:kivicare_patient/screens/labs_radiology/labs_radiology_common.dart';
import '../../models/lab_test_model.dart';

class LabTestCard extends StatelessWidget {
  final LabTestModel test;
  final VoidCallback onTap;

  const LabTestCard({super.key, required this.test, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: boxDecorationDefault(
        color: context.cardColor,
        borderRadius: radius(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(test.name,
                      style: boldTextStyle(),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis)
                  .expand(),
              16.width,
              Text(
                '${test.price?.toStringAsFixed(0)} ${test.currency}',
                style: primaryTextStyle(
                    color: context.primaryColor, weight: FontWeight.bold),
              ),
            ],
          ),
          if (test.category != null) ...[
            8.height,
            Text(test.category!.name, style: secondaryTextStyle(size: 12)),
          ],
          12.height,
          Row(
            children: [
              if (test.turnaroundHours != null) ...[
                const Icon(Icons.timer_outlined,
                    size: 14, color: secondaryTextColor),
                4.width,
                Text(locale.value.xHoursTurnaround(test.turnaroundHours!),
                    style: secondaryTextStyle(size: 12)),
                16.width,
              ],
              if (test.isImaging) ...[
                const Icon(Icons.image_outlined,
                    size: 14, color: secondaryTextColor),
                4.width,
                Text(locale.value.imaging, style: secondaryTextStyle(size: 12)),
              ],
            ],
          ),
        ],
      ),
    ).onTap(onTap, borderRadius: radius(12));
  }
}
