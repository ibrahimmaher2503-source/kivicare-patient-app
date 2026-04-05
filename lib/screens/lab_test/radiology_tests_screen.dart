import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kivicare_patient/screens/lab_test/radiology_detail_screen.dart';
import 'package:kivicare_patient/screens/lab_test/radiology_tests_controller.dart';
import 'package:kivicare_patient/screens/lab_test/components/lab_test_card.dart';
import 'package:kivicare_patient/screens/lab_test/lab_test_categories_controller.dart';
import 'package:kivicare_patient/utils/colors.dart';
import 'package:kivicare_patient/utils/common_base.dart';
import 'package:kivicare_patient/utils/constants.dart';
import 'package:kivicare_patient/components/app_scaffold.dart';
import 'package:kivicare_patient/components/loader_widget.dart';
import 'package:kivicare_patient/components/empty_error_state_widget.dart';
import 'package:nb_utils/nb_utils.dart';

class RadiologyTestsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final radiologyController = Get.put(RadiologyTestsController());
    final categoryController = Get.find<LabTestCategoriesController>();

    return AppScaffold(
      appBarTitle: locale.value.radiologyScan,
      body: GetBuilder<RadiologyTestsController>(
        init: radiologyController,
        builder: (controller) {
          return SingleChildScrollView(
            padding: EdgeInsets.all(24.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search Bar
                Container(
                  decoration: BoxDecoration(
                    color: isDarkMode.value ? cardDarkColor : gray50,
                    border: Border.all(color: isDarkMode.value ? gray700 : gray200),
                    borderRadius: BorderRadius.circular(12.w),
                  ),
                  child: TextField(
                    onChanged: (value) {
                      if (value.isEmpty) {
                        controller.resetFilters();
                      } else {
                        controller.searchTests(value);
                      }
                    },
                    decoration: InputDecoration(
                      hintText: locale.value.searchRadiology,
                      hintStyle: secondaryTextStyle(color: gray400),
                      prefixIcon: Icon(Icons.search, color: gray500, size: 20.w),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 16.w, horizontal: 16.w),
                    ),
                    style: primaryTextStyle(),
                  ),
                ),
                SizedBox(height: 24.w),

                // Category Filter Chips
                if (categoryController.categories.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(locale.value.category, style: boldTextStyle(size: 14)),
                      SizedBox(height: 12.w),
                      Wrap(
                        spacing: 8.w,
                        runSpacing: 8.w,
                        children: categoryController.categories.map((category) {
                          final isSelected = controller.filter.value.categoryId == category.id;
                          return FilterChip(
                            label: Text(
                              category.name,
                              style: boldTextStyle(
                                size: 12,
                                color: isSelected ? Colors.white : (isDarkMode.value ? whiteColor : blackColor),
                              ),
                            ),
                            selected: isSelected,
                            onSelected: (selected) {
                              if (selected) {
                                controller.filterByCategory(category.id);
                              } else {
                                controller.filterByCategory(null);
                              }
                            },
                            backgroundColor: isDarkMode.value ? cardDarkColor : gray100,
                            selectedColor: appColorPrimary,
                            side: BorderSide(
                              color: isSelected ? appColorPrimary : (isDarkMode.value ? gray700 : gray200),
                            ),
                          );
                        }).toList(),
                      ),
                      SizedBox(height: 24.w),
                    ],
                  ),

                // Radiology Tests List
                Obx(
                  () => controller.isLoading.value
                      ? Center(child: LoaderWidget())
                      : controller.tests.isEmpty
                          ? EmptyErrorStateWidget(
                              title: locale.value.noRadiologyTests,
                              subTitle: locale.value.tryAdjustingYourFilters,
                              onRetry: controller.loadTests,
                            )
                          : ListView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: controller.tests.length,
                              itemBuilder: (context, index) {
                                final test = controller.tests[index];
                                return GestureDetector(
                                  onTap: () => Get.to(
                                    () => RadiologyDetailScreen(testId: test.id),
                                  ),
                                  child: LabTestCard(
                                    test: test,
                                    isRadiology: true,
                                  ),
                                );
                              },
                            ),
                ),

                // Load More Button
                if (!controller.isLastPage.value && controller.tests.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 24.w),
                    child: Center(
                      child: ElevatedButton(
                        onPressed: () => controller.loadMoreTests(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: appColorPrimary,
                          padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 12.w),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.w),
                          ),
                        ),
                        child: Text(
                          locale.value.loadMore,
                          style: boldTextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
