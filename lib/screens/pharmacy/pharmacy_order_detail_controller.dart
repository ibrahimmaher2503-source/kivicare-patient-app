import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../api/core_apis.dart';
import '../../main.dart';
import 'model/pharmacy_order_model.dart';

class PharmacyOrderDetailController extends GetxController {
  Rx<PharmacyOrderDetail?> order = Rx<PharmacyOrderDetail?>(null);
  RxBool isLoading = false.obs;
  RxBool isCancelling = false.obs;

  @override
  void onInit() {
    super.onInit();
    final id = Get.arguments;
    if (id is int) loadOrder(id);
  }

  Future<void> loadOrder(int id) async {
    isLoading(true);
    try {
      final res = await CoreServiceApis.getPharmacyOrderDetail(id);
      order.value = res.data;
    } catch (e) {
      toast(e.toString());
    } finally {
      isLoading(false);
    }
  }

  void cancelOrder(BuildContext context) {
    final id = order.value?.id;
    if (id == null) return;
    showConfirmDialogCustom(
      context,
      dialogType: DialogType.DELETE,
      title: locale.value.cancelOrder,
      subTitle: locale.value.cannotCancelOrder,
      positiveText: locale.value.yes,
      negativeText: locale.value.no,
      onAccept: (ctx) async {
        isCancelling(true);
        try {
          await CoreServiceApis.cancelPharmacyOrder(id);
          toast(locale.value.orderCancelledSuccess);
          await loadOrder(id);
        } catch (e) {
          toast(e.toString());
        } finally {
          isCancelling(false);
        }
      },
    );
  }
}
