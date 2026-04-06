import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kivicare_patient/components/app_scaffold.dart';
import 'package:kivicare_patient/components/empty_error_state_widget.dart';
import 'package:kivicare_patient/components/loader_widget.dart';
import 'package:kivicare_patient/locale/languages.dart';
import 'package:kivicare_patient/screens/lab_test/components/lab_test_category_card.dart';
import 'package:kivicare_patient/screens/lab_test/lab_test_categories_controller.dart';
import 'package:kivicare_patient/screens/lab_test/lab_test_list_screen.dart';
import 'package:kivicare_patient/utils/colors.dart';
import 'package:nb_utils/nb_utils.dart';

/// Screen for browsing available lab test categories
import '../../main.dart';
class LabTestCategoriesScreen extends StatelessWidget {
  const LabTestCategoriesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<LabTestCategoriesController>(
      init: LabTestCategoriesController(),
      builder: (controller) {
        return AppScaffold(
          appBarTitle: locale.value.labTestCategories ?? 'Lab Test Categories',
          body: Obx(
            () => controller.isLoading.value
                ? const LoaderWidget()
                : controller.hasError
                    ? EmptyErrorStateWidget(
                        title: locale.value.error ?? 'Error',
                        subTitle: controller.errorMessage.value ?? 'Something went wrong',
                        onRetry: controller.retry,
                      )
                    : controller.hasCategoriesLoaded
                        ? RefreshIndicator(
                            onRefresh: () => controller.refreshCategories(),
                            child: GridView.builder(
                              padding: const EdgeInsets.all(16),
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                                childAspectRatio: 0.95,
                              ),
                              itemCount: controller.categories.length,
                              itemBuilder: (context, index) {
                                final category = controller.categories[index];
                                return LabTestCategoryCard(
                                  category: category,
                                  onTap: () {
                                    Get.to(() => LabTestListScreen(
                                      selectedCategoryId: category.id,
                                    ));
                                  },
                                );
                              },
                            ),
                          )
                        : EmptyErrorStateWidget(
                            title: locale.value.noData ?? 'No Categories',
                            subTitle: locale.value.noDataFound ?? 'No test categories available',
                            onRetry: controller.retry,
                          ),
          ),
        );
      },
    );
  }
}
