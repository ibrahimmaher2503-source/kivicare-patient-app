import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:kivicare_patient/api/core_apis.dart';
import 'package:kivicare_patient/screens/lab_test/model/test_order_model.dart';
import 'package:kivicare_patient/screens/lab_test/components/cancellation_reason_dialog.dart';

class TestOrderDetailController extends GetxController {
  final int orderId;

  final Rx<TestOrder?> order = Rx<TestOrder?>(null);
  final RxBool isLoading = false.obs;
  final Rx<String?> errorMessage = Rx<String?>(null);

  TestOrderDetailController({required this.orderId});

  @override
  void onInit() {
    super.onInit();
    loadOrderDetail();
  }

  Future<void> loadOrderDetail() async {
    try {
      isLoading(true);
      errorMessage(null);

      final loadedOrder = await CoreServiceApis.getTestOrderDetail(orderId: orderId);
      order.value = loadedOrder;
    } catch (e) {
      errorMessage.value = e.toString();
      debugPrint('Error loading order detail: $e');
    } finally {
      isLoading(false);
    }
  }

  Future<void> cancelOrder(String reason) async {
    try {
      isLoading(true);
      errorMessage(null);

      await CoreServiceApis.cancelTestOrder(
        orderId: orderId,
        request: {'reason': reason},
      );

      toast('Order cancelled successfully');
      await loadOrderDetail();
    } catch (e) {
      errorMessage.value = e.toString();
      debugPrint('Error cancelling order: $e');
      toast('Error: ${e.toString()}');
    } finally {
      isLoading(false);
    }
  }

  Future<void> cancelOrderWithReason(BuildContext context) async {
    await showCancellationReasonDialog(context, (reason) {
      cancelOrder(reason);
    });
  }

  Future<void> downloadReport() async {
    try {
      isLoading(true);
      errorMessage(null);

      await CoreServiceApis.downloadTestReport(orderId: orderId);
      toast('Report downloaded successfully');
      debugPrint('Report downloaded for order $orderId');
    } catch (e) {
      errorMessage.value = e.toString();
      debugPrint('Error downloading report: $e');
      toast('Error: ${e.toString()}');
    } finally {
      isLoading(false);
    }
  }

  Future<void> retry() async {
    await loadOrderDetail();
  }

  bool get hasOrderLoaded => order.value != null;
  bool get hasError => errorMessage.value != null;
  bool get canCancel => order.value != null && (order.value!.status == 'pending' || order.value!.status == 'confirmed');
  bool get canDownloadReport => order.value != null && (order.value!.status == 'completed' || order.value!.status == 'delivered');
}
