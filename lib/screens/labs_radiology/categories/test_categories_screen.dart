import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:kivicare_patient/screens/labs_radiology/labs_radiology_common.dart';
import 'package:kivicare_patient/components/loader_widget.dart';
import 'package:kivicare_patient/components/no_data_found_widget.dart';
import 'test_categories_controller.dart';
import 'components/test_category_card.dart';
import '../tests/lab_tests_list_screen.dart'; // Will be created next

class TestCategoriesScreen extends StatelessWidget {
  const TestCategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(TestCategoriesController());

    return Scaffold(
      appBar: appBarWidget(
        locale.value.testCategories,
        textColor: Colors.white,
        systemUiOverlayStyle: defaultSystemUiOverlayStyle(context),
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.categories.isEmpty) {
          return const LoaderWidget().center();
        }

        if (controller.categories.isEmpty) {
          return NoDataFoundWidget(text: locale.value.noCategoriesFound)
              .center();
        }

        return RefreshIndicator(
          onRefresh: () => controller.fetchCategories(),
          child: AnimatedScrollView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                locale.value.browseTestCategories,
                style: boldTextStyle(size: 18),
              ),
              24.height,
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.0,
                ),
                itemCount: controller.categories.length,
                itemBuilder: (context, index) {
                  final category = controller.categories[index];
                  return TestCategoryCard(
                    category: category,
                    onTap: () {
                      // Navigate to tests list by category
                      Get.to(() => LabTestsListScreen(
                          categoryId: category.id,
                          categoryName: category.name));
                    },
                  );
                },
              ),
            ],
          ),
        );
      }),
    );
  }
}
