import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:kivicare_patient/screens/labs_radiology/labs_radiology_common.dart';
import '../../models/lab_test_model.dart';

class TestDetailBottomSheet extends StatelessWidget {
  final LabTestModel test;
  final VoidCallback onBook;

  const TestDetailBottomSheet(
      {super.key, required this.test, required this.onBook});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: boxDecorationWithRoundedCorners(
        backgroundColor: context.scaffoldBackgroundColor,
        borderRadius: radiusOnly(topLeft: 20, topRight: 20),
      ),
      child: AnimatedScrollView(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(test.name, style: boldTextStyle(size: 18)).expand(),
              IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => finish(context)),
            ],
          ),
          16.height,
          _buildInfoSection(
              locale.value.testCategoryLabel, test.category?.name ?? 'N/A'),
          12.height,
          _buildInfoSection(locale.value.priceLabel,
              '${test.price?.toStringAsFixed(0)} ${test.currency}'),
          if (test.turnaroundHours != null) ...[
            12.height,
            _buildInfoSection(locale.value.turnaroundTime,
                locale.value.xHoursTurnaround(test.turnaroundHours!)),
          ],
          if (test.preparationInstructions.validate().isNotEmpty) ...[
            24.height,
            Text(locale.value.preparationInstructions, style: boldTextStyle()),
            8.height,
            Text(test.preparationInstructions!, style: secondaryTextStyle()),
          ],
          if (test.description.validate().isNotEmpty) ...[
            24.height,
            Text(locale.value.description, style: boldTextStyle()),
            8.height,
            Text(test.description!, style: secondaryTextStyle()),
          ],
          32.height,
          AppButton(
            width: double.infinity,
            text: locale.value.bookThisTest,
            color: context.primaryColor,
            textStyle: boldTextStyle(color: Colors.white),
            onTap: () {
              finish(context);
              onBook();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: secondaryTextStyle()),
        Text(value, style: boldTextStyle(size: 14)),
      ],
    );
  }
}
