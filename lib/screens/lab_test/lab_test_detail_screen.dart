import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kivicare_patient/components/app_scaffold.dart';
import 'package:kivicare_patient/utils/empty_error_state_widget.dart';
import 'package:kivicare_patient/components/loader_widget.dart';
import 'package:kivicare_patient/locale/languages.dart';
import 'package:kivicare_patient/screens/lab_test/lab_test_detail_controller.dart';
import 'package:kivicare_patient/utils/app_common.dart';
import 'package:kivicare_patient/utils/colors.dart';
import 'package:kivicare_patient/utils/price_widget.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../main.dart';
class LabTestDetailScreen extends StatelessWidget {
  final int testId;

  const LabTestDetailScreen({Key? key, required this.testId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<LabTestDetailController>(
      init: LabTestDetailController(testId: testId),
      builder: (controller) {
        return AppScaffold(
          appBarTitle: Text(locale.value.testDetail),
          body: Obx(
            () => controller.isLoading.value
                ? const LoaderWidget()
                : controller.hasError
                    ? EmptyErrorStateWidget(
                        title: locale.value.error ?? 'Error',
                        subTitle: controller.errorMessage.value ?? 'Failed to load test',
                        onRetry: controller.retry,
                      )
                    : controller.hasTestLoaded
                        ? SingleChildScrollView(
                            padding: const EdgeInsets.all(16),
                            child: _DetailContent(controller: controller),
                          )
                        : EmptyErrorStateWidget(
                            title: locale.value.noData ?? 'No Data',
                            subTitle: locale.value.noDataFound ?? 'Test not found',
                            onRetry: controller.retry,
                          ),
          ),
        );
      },
    );
  }
}

class _DetailContent extends StatelessWidget {
  final LabTestDetailController controller;
  const _DetailContent({required this.controller});

  @override
  Widget build(BuildContext context) {
    final test = controller.selectedTest.value;
    if (test == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: appColorPrimary.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: appColorPrimary.withOpacity(0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(test.name, style: boldTextStyle(size: 18)),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Code: ${test.code}', style: secondaryTextStyle(size: 12)),
                  PriceWidget(price: test.defaultPrice, size: 16, color: appColorPrimary, isBoldText: true),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        if (test.description.isNotEmpty) _SectionTitle(title: 'Description'),
        if (test.description.isNotEmpty) _SectionContent(content: test.description),
        if (test.preparationInstructions.isNotEmpty) _SectionTitle(title: 'Preparation'),
        if (test.preparationInstructions.isNotEmpty) _HighlightedContent(content: test.preparationInstructions),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.3,
          children: [
            _DetailCard(title: 'Sample Type', value: test.sampleType),
            _DetailCard(title: 'Department', value: test.department.toUpperCase()),
            _DetailCard(title: 'Turnaround', value: test.turnaroundTime),
            _DetailCard(title: 'Category', value: test.category?.name ?? 'N/A'),
          ],
        ),
        const SizedBox(height: 16),
        if (test.referenceRange.isNotEmpty) _SectionTitle(title: 'Reference Range'),
        if (test.referenceRange.isNotEmpty) _SectionContent(content: test.referenceRange),
        Row(children: [Expanded(child: AppButton(text: 'Book Now', onTap: controller.navigateToOrder, color: appColorPrimary))]),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});
  @override
  Widget build(BuildContext context) => Text(title, style: boldTextStyle(size: 14));
}

class _SectionContent extends StatelessWidget {
  final String content;
  const _SectionContent({required this.content});
  @override
  Widget build(BuildContext context) => Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Text(content, style: secondaryTextStyle(size: 13)));
}

class _HighlightedContent extends StatelessWidget {
  final String content;
  const _HighlightedContent({required this.content});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(color: Colors.orange.withOpacity(0.1), borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.orange.withOpacity(0.2))),
    child: Text(content, style: secondaryTextStyle(size: 13)),
  );
}

class _DetailCard extends StatelessWidget {
  final String title, value;
  const _DetailCard({required this.title, required this.value});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(color: isDarkMode.value ? cardDarkColor : Colors.grey.shade50, borderRadius: BorderRadius.circular(8), border: Border.all(color: isDarkMode.value ? Colors.grey.shade800 : Colors.grey.shade200)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [Text(title, style: secondaryTextStyle(size: 11), maxLines: 1, overflow: TextOverflow.ellipsis), const SizedBox(height: 6), Text(value, style: boldTextStyle(size: 12), maxLines: 2, overflow: TextOverflow.ellipsis)]),
  );
}
