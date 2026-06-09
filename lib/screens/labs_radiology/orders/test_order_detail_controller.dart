import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:kivicare_patient/screens/labs_radiology/labs_radiology_common.dart';
import '../../../api/labs_radiology_apis.dart';
import '../models/test_order_model.dart';
import '../shared/service/report_download_service.dart';

class TestOrderDetailController extends GetxController {
  final int orderId;

  var isLoading = false.obs;
  var isDownloading = false.obs;
  var order = Rxn<TestOrderModel>();

  final downloadService = ReportDownloadService();

  TestOrderDetailController({required this.orderId});

  @override
  void onInit() {
    super.onInit();
    fetchOrderDetail();
  }

  Future<void> fetchOrderDetail({bool showLoader = true}) async {
    if (showLoader) isLoading.value = true;
    try {
      final res = await LabsRadiologyApis.getTestOrderById(orderId);
      order.value = res;
    } catch (e) {
      toast(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> cancelOrder(String? reason) async {
    isLoading.value = true;
    try {
      final res =
          await LabsRadiologyApis.cancelTestOrder(orderId, reason: reason);
      order.value = res;
      toast(locale.value.requestCancelled);
    } catch (e) {
      toast(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> downloadReport() async {
    if (order.value?.reportUrl == null) {
      toast(locale.value.reportNotReady);
      return;
    }

    isDownloading.value = true;
    try {
      await downloadService.download(orderId, order.value!.referenceNumber);
    } catch (e) {
      toast(locale.value.downloadFailed);
    } finally {
      isDownloading.value = false;
    }
  }
}
