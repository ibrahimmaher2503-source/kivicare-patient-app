import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:kivicare_patient/screens/labs_radiology/labs_radiology_common.dart';
import 'package:kivicare_patient/components/loader_widget.dart';
import 'package:kivicare_patient/components/no_data_found_widget.dart';
import 'lab_tests_list_controller.dart';
import 'components/lab_test_card.dart';
import '../facility_detail/components/test_detail_bottom_sheet.dart';
import '../hub/labs_radiology_hub_screen.dart';

class LabTestsListScreen extends StatelessWidget {
  final int? categoryId;
  final String? categoryName;
  final int? facilityId;

  const LabTestsListScreen(
      {super.key, this.categoryId, this.categoryName, this.facilityId});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(
        LabTestsListController(categoryId: categoryId, facilityId: facilityId));

    return Scaffold(
      appBar: appBarWidget(
        categoryName ?? locale.value.allTestsTitle,
        textColor: Colors.white,
        systemUiOverlayStyle: defaultSystemUiOverlayStyle(context),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            child: AppTextField(
              textFieldType: TextFieldType.NAME,
              onChanged: (v) => controller.updateSearch(v),
              decoration: inputDecoration(
                context,
                labelText: locale.value.searchHere,
                prefixIcon: const Icon(Icons.search, color: secondaryTextColor),
              ),
            ),
          ),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.tests.isEmpty) {
                return const LoaderWidget().center();
              }

              if (controller.tests.isEmpty) {
                return NoDataFoundWidget(text: locale.value.noDataFound)
                    .center();
              }

              return RefreshIndicator(
                onRefresh: () async {
                  controller.page.value = 1;
                  await controller.fetchTests(showLoader: false);
                },
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: controller.tests.length,
                  itemBuilder: (context, index) {
                    final test = controller.tests[index];

                    if (index == controller.tests.length - 1 &&
                        !controller.isLastPage.value) {
                      controller.loadMore();
                    }

                    return LabTestCard(
                      test: test,
                      onTap: () => showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (_) => TestDetailBottomSheet(
                          test: test,
                          onBook: () {
                            Get.back();
                            Get.to(
                              () => LabsRadiologyHubScreen(
                                initialTest: test,
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
