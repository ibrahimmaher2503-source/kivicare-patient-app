import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kivicare_patient/components/app_scaffold.dart';
import 'package:kivicare_patient/components/loader_widget.dart';
import 'package:kivicare_patient/locale/languages.dart';
import 'package:kivicare_patient/screens/lab_test/create_test_order_controller.dart';
import 'package:kivicare_patient/screens/lab_test/components/order_summary_section.dart';
import 'package:kivicare_patient/screens/lab_test/components/test_priority_selector.dart';
import 'package:kivicare_patient/screens/lab_test/lab_test_list_screen.dart';
import 'package:kivicare_patient/utils/colors.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../main.dart';
class CreateTestOrderScreen extends StatefulWidget {
  const CreateTestOrderScreen({Key? key}) : super(key: key);

  @override
  State<CreateTestOrderScreen> createState() => _CreateTestOrderScreenState();
}

class _CreateTestOrderScreenState extends State<CreateTestOrderScreen> {
  late CreateTestOrderController controller;
  late TextEditingController notesController;

  @override
  void initState() {
    super.initState();
    controller = Get.put(CreateTestOrderController());
    notesController = TextEditingController();
  }

  @override
  void dispose() {
    notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBarTitle: locale.value.createOrder ?? 'Create Order',
      body: GetBuilder<CreateTestOrderController>(
        builder: (controller) {
          return Obx(
            () => controller.isLoading.value
                ? const LoaderWidget()
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (!controller.isOrderReady)
                          InkWell(
                            onTap: () => Get.to(() => const LabTestListScreen()),
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: appColorPrimary.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: appColorPrimary.withOpacity(0.3)),
                              ),
                              child: Center(
                                child: Column(
                                  children: [
                                    Icon(Icons.add_circle, size: 40, color: appColorPrimary),
                                    const SizedBox(height: 8),
                                    Text('Add Tests to Order', style: boldTextStyle(size: 14, color: appColorPrimary)),
                                  ],
                                ),
                              ),
                            ),
                          )
                        else ...[
                          Text('Selected Tests', style: boldTextStyle(size: 14)),
                          const SizedBox(height: 12),
                          OrderSummarySection(
                            selectedTests: controller.selectedTests,
                            totalAmount: controller.totalAmount.value,
                            discountAmount: controller.discountAmount.value,
                            finalAmount: controller.finalAmount.value,
                            onRemoveTest: (testId) => controller.removeTest(testId),
                          ),
                          const SizedBox(height: 20),
                          Text('Clinical Notes', style: boldTextStyle(size: 14)),
                          const SizedBox(height: 8),
                          TextField(
                            controller: notesController,
                            maxLines: 4,
                            maxLength: 2000,
                            onChanged: (value) => controller.setClinicalNotes(value),
                            decoration: InputDecoration(
                              hintText: 'Add any clinical notes...',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                          const SizedBox(height: 20),
                          TestPrioritySelector(
                            selectedPriority: controller.priority.value,
                            onPriorityChanged: (priority) => controller.setPriority(priority),
                          ),
                          const SizedBox(height: 20),
                          if (controller.hasError)
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.cancelStatusColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.cancelStatusColor.withOpacity(0.3)),
                              ),
                              child: Text(controller.errorMessage.value ?? 'Error', style: primaryTextStyle(size: 12, color: Colors.cancelStatusColor)),
                            ),
                          if (controller.hasError) const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: AppButton(text: 'Create Order', onTap: controller.createOrder, color: appColorPrimary),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: AppButton(
                              text: 'Add More Tests',
                              onTap: () => Get.to(() => const LabTestListScreen()),
                              color: appColorPrimary.withOpacity(0.1),
                              textColor: appColorPrimary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
          );
        },
      ),
    );
  }
}
