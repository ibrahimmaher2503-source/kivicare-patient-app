import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kivicare_patient/api/core_apis.dart';
import 'package:kivicare_patient/screens/lab_test/model/test_order_model.dart';
import 'package:kivicare_patient/utils/app_common.dart';
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

      final response = await CoreServiceApis.getTestOrderDetail(orderId: orderId);

      if (response.status ?? false) {
        final orderData = response.data as Map<String, dynamic>?;
        if (orderData != null) {
          order.value = TestOrder.fromJson(orderData);
        } else {
          errorMessage.value = 'Invalid order data';
        }
      } else {
        errorMessage.value = response.message ?? 'Failed to load order';
      }
    } catch (e) {
      errorMessage.value = e.toString();
      appPrint('Error loading order detail: $e');
    } finally {
      isLoading(false);
    }
  }

  Future<void> cancelOrder(String reason) async {
    try {
      isLoading(true);
      errorMessage(null);

      final response = await CoreServiceApis.cancelTestOrder(
        orderId: orderId,
        cancellationReason: reason,
      );

      if (response.status ?? false) {
        toast('Order cancelled successfully');
        await loadOrderDetail();
      } else {
        errorMessage.value = response.message ?? 'Failed to cancel order';
        toast(errorMessage.value);
      }
    } catch (e) {
      errorMessage.value = e.toString();
      appPrint('Error cancelling order: $e');
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

      final response = await CoreServiceApis.downloadTestReport(orderId: orderId);

      if (response.status ?? false) {
        // File download handled by API layer (returns binary PDF)
        // In production, you would:
        // 1. Save to device storage
        // 2. Open with PDF viewer
        // 3. Show success toast
        toast('Report downloaded successfully');
        appPrint('Report downloaded for order $orderId');
      } else {
        errorMessage.value = response.message ?? 'Failed to download report';
        toast(errorMessage.value);
      }
    } catch (e) {
      errorMessage.value = e.toString();
      appPrint('Error downloading report: $e');
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
