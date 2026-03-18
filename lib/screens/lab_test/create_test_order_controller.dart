import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../api/core_apis.dart';
import '../../main.dart';
import 'model/lab_test_model.dart';
import 'model/test_order_model.dart';

class CreateTestOrderController extends GetxController {
  // Selected tests (cart)
  RxList<LabTest> selectedTests = RxList<LabTest>();

  // Clinical notes
  TextEditingController clinicalNotesCont = TextEditingController();

  // Priority
  RxString priority = 'routine'.obs;
  RxList<Map<String, String>> priorityOptions = RxList();

  // Loading
  RxBool isLoading = false.obs;

  // Computed total
  RxDouble totalAmount = 0.0.obs;

  @override
  void onInit() {
    priorityOptions.assignAll([
      {'key': 'routine', 'label': locale.value.priorityRoutine},
      {'key': 'urgent', 'label': locale.value.priorityUrgent},
      {'key': 'stat', 'label': locale.value.priorityStat},
    ]);

    // Check if a lab test was passed via arguments
    if (Get.arguments is Map && Get.arguments['labTest'] != null) {
      addTest(Get.arguments['labTest'] as LabTest);
    }

    super.onInit();
  }

  @override
  void dispose() {
    clinicalNotesCont.dispose();
    super.dispose();
  }

  void addTest(LabTest test) {
    // Avoid duplicates
    if (!selectedTests.any((t) => t.id == test.id)) {
      selectedTests.add(test);
      _recalculateTotal();
    }
  }

  void removeTest(LabTest test) {
    selectedTests.removeWhere((t) => t.id == test.id);
    _recalculateTotal();
  }

  void _recalculateTotal() {
    double total = 0.0;
    for (var test in selectedTests) {
      total += test.defaultPrice;
    }
    totalAmount(total);
  }

  void onPriorityChanged(String value) {
    priority(value);
  }

  Future<void> submitOrder() async {
    if (selectedTests.isEmpty) {
      toast(locale.value.selectTests);
      return;
    }

    isLoading(true);

    final request = {
      'items': selectedTests.map((test) => {
        'lab_test_id': test.id,
        'price': test.defaultPrice,
      }).toList(),
      'clinical_notes': clinicalNotesCont.text.trim(),
      'priority': priority.value,
    };

    try {
      await CoreServiceApis.createTestOrder(request: request);
      toast(locale.value.testOrderCreated);
      Get.back(result: true);
    } catch (e) {
      log("submitOrder error: $e");
      toast(locale.value.somethingWentWrong);
    } finally {
      isLoading(false);
    }
  }
}
