import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kivicare_patient/components/app_scaffold.dart';
import 'package:kivicare_patient/utils/empty_error_state_widget.dart';
import 'package:kivicare_patient/components/loader_widget.dart';
import 'package:kivicare_patient/locale/languages.dart';
import 'package:kivicare_patient/screens/lab_test/components/lab_test_card.dart';
import 'package:kivicare_patient/screens/lab_test/lab_test_list_controller.dart';
import 'package:kivicare_patient/screens/lab_test/lab_test_detail_screen.dart';
import 'package:kivicare_patient/utils/colors.dart';
import 'package:kivicare_patient/utils/lab_test_constants.dart';
import 'package:nb_utils/nb_utils.dart';

/// Screen for browsing and searching lab tests with filtering
import '../../main.dart';
class LabTestListScreen extends StatefulWidget {
  final int? selectedCategoryId;

  const LabTestListScreen({
    Key? key,
    this.selectedCategoryId,
  }) : super(key: key);

  @override
  State<LabTestListScreen> createState() => _LabTestListScreenState();
}

class _LabTestListScreenState extends State<LabTestListScreen> {
  late LabTestListController controller;
  late TextEditingController searchController;
  String? selectedDepartment;

  @override
  void initState() {
    super.initState();
    controller = Get.put(LabTestListController());
    searchController = TextEditingController();

    // Load tests with pre-selected category if provided
    if (widget.selectedCategoryId != null) {
      controller.filterByCategory(widget.selectedCategoryId);
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBarTitle: Text(locale.value.labTests),
      body: GetBuilder<LabTestListController>(
        builder: (controller) {
          return Column(
            children: [
              // Search bar
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    hintText: locale.value.search ?? 'Search tests...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onChanged: (value) {
                    controller.searchTests(value);
                  },
                ),
              ),

              // Department filters
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Obx(
                  () => SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        FilterChip(
                          label: Text(locale.value.all ?? 'All'),
                          selected: selectedDepartment == null,
                          onSelected: (selected) {
                            setState(() => selectedDepartment = null);
                            controller.filterByDepartment(null);
                          },
                        ),
                        const SizedBox(width: 8),
                        FilterChip(
                          label: Text(locale.value.laboratory ?? 'Laboratory'),
                          selected: selectedDepartment == FacilityType.lab,
                          onSelected: (selected) {
                            setState(() => selectedDepartment = FacilityType.lab);
                            controller.filterByDepartment(FacilityType.lab);
                          },
                        ),
                        const SizedBox(width: 8),
                        FilterChip(
                          label: Text(locale.value.radiology ?? 'Radiology'),
                          selected: selectedDepartment == FacilityType.radiology,
                          onSelected: (selected) {
                            setState(() => selectedDepartment = FacilityType.radiology);
                            controller.filterByDepartment(FacilityType.radiology);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Tests list
              Expanded(
                child: Obx(
                  () => controller.isLoadingTests.value
                      ? const LoaderWidget()
                      : controller.hasTestError
                          ? EmptyErrorStateWidget(
                              title: locale.value.error ?? 'Error',
                              subTitle: controller.testErrorMessage.value ?? 'Failed to load tests',
                              onRetry: controller.retryLoadTests,
                            )
                          : controller.hasTestsLoaded
                              ? ListView.builder(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  itemCount: controller.tests.length,
                                  itemBuilder: (context, index) {
                                    final test = controller.tests[index];
                                    return LabTestCard(
                                      test: test,
                                      onTap: () {
                                        Get.to(() => LabTestDetailScreen(
                                          testId: test.id,
                                        ));
                                      },
                                    );
                                  },
                                )
                              : EmptyErrorStateWidget(
                                  title: locale.value.noData ?? 'No Tests',
                                  subTitle: locale.value.noDataFound ?? 'No tests found',
                                  onRetry: controller.retryLoadTests,
                                ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
