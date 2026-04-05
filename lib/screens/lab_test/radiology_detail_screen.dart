import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kivicare_patient/screens/lab_test/lab_test_detail_controller.dart';
import 'package:kivicare_patient/screens/lab_test/create_test_order_screen.dart';
import 'package:kivicare_patient/utils/colors.dart';
import 'package:kivicare_patient/utils/common_base.dart';
import 'package:kivicare_patient/components/app_scaffold.dart';
import 'package:kivicare_patient/components/loader_widget.dart';
import 'package:nb_utils/nb_utils.dart';

class RadiologyDetailScreen extends StatelessWidget {
  final int testId;

  RadiologyDetailScreen({required this.testId});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(
      LabTestDetailController(testId: testId),
      tag: 'radiology_$testId',
    );

    return AppScaffold(
      appBarTitle: locale.value.radiologyScan,
      body: GetBuilder<LabTestDetailController>(
        tag: 'radiology_$testId',
        init: controller,
        builder: (controller) {
          return Obx(
            () => controller.isLoading.value
                ? Center(child: LoaderWidget())
                : controller.selectedTest.value == null
                    ? Center(
                        child: Text(
                          locale.value.testNotFound,
                          style: secondaryTextStyle(),
                        ),
                      )
                    : SingleChildScrollView(
                        padding: EdgeInsets.all(24.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header
                            _HeaderSection(test: controller.selectedTest.value!),
                            SizedBox(height: 24.w),

                            // Description
                            _SectionCard(
                              title: locale.value.description,
                              content: controller.selectedTest.value!.description,
                            ),
                            SizedBox(height: 16.w),

                            // Imaging Format
                            _SectionCard(
                              title: locale.value.imagingFormat,
                              content: controller.selectedTest.value!.sampleType
                                  .replaceAll('_', ' ')
                                  .capitalize(),
                            ),
                            SizedBox(height: 16.w),

                            // Preparation Instructions
                            _SectionCard(
                              title: locale.value.preparationInstructions,
                              content: controller.selectedTest.value!.preparationInstructions.isEmpty
                                  ? locale.value.noSpecialPreparation
                                  : controller.selectedTest.value!.preparationInstructions,
                            ),
                            SizedBox(height: 16.w),

                            // Safety Information
                            _SectionCard(
                              title: locale.value.safetyInformation,
                              content: _getSafetyInfo(controller.selectedTest.value!),
                            ),
                            SizedBox(height: 16.w),

                            // Turnaround Time
                            _InfoRow(
                              icon: Icons.schedule,
                              label: locale.value.turnaroundTime,
                              value: controller.selectedTest.value!.turnaroundTime,
                            ),
                            SizedBox(height: 8.w),

                            // Price
                            _InfoRow(
                              icon: Icons.attach_money,
                              label: locale.value.price,
                              value: '${currencySymbol}${controller.selectedTest.value!.defaultPrice.toStringAsFixed(2)}',
                            ),
                            SizedBox(height: 8.w),

                            // Category
                            if (controller.selectedTest.value!.category != null)
                              _InfoRow(
                                icon: Icons.category,
                                label: locale.value.category,
                                value: controller.selectedTest.value!.category!.name,
                              ),

                            SizedBox(height: 32.w),

                            // Add to Cart Button
                            SizedBox(
                              width: double.infinity,
                              height: 56.w,
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  controller.addToCart();
                                  Get.to(() => CreateTestOrderScreen());
                                },
                                icon: Icon(Icons.add_shopping_cart, size: 20.w),
                                label: Text(
                                  locale.value.addToCart,
                                  style: boldTextStyle(color: Colors.white, size: 16),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12.w),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
          );
        },
      ),
    );
  }

  String _getSafetyInfo(dynamic test) {
    // Radiology-specific safety information
    return '''• This is an imaging procedure that uses radiation
• Pregnant women should inform staff before the procedure
• Metal implants should be reported to the technician
• Contrast agents may be used - inform staff of allergies
• Results are typically available within ${test.turnaroundTime}''';
  }
}

class _HeaderSection extends StatelessWidget {
  final dynamic test;

  const _HeaderSection({required this.test});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.w),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(test.name, style: boldTextStyle(size: 18)),
                    SizedBox(height: 4.w),
                    Text(test.code, style: secondaryTextStyle()),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.w),
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.circular(8.w),
                ),
                child: Text(
                  '${currencySymbol}${test.defaultPrice.toStringAsFixed(0)}',
                  style: boldTextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final String content;

  const _SectionCard({
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isDarkMode.value ? cardDarkColor : gray50,
        border: Border.all(color: isDarkMode.value ? gray700 : gray200),
        borderRadius: BorderRadius.circular(12.w),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: boldTextStyle(size: 14)),
          SizedBox(height: 8.w),
          Text(
            content,
            style: primaryTextStyle(size: 13),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20.w, color: primaryColor),
        SizedBox(width: 12.w),
        Text(label, style: secondaryTextStyle()),
        Spacer(),
        Text(value, style: boldTextStyle()),
      ],
    );
  }
}
