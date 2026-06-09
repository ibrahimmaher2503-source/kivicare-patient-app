import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../../api/labs_radiology_apis.dart';
import '../models/test_order_model.dart';
import '../models/test_order_status.dart';

class TestOrdersListController extends GetxController {
  var isLoading = false.obs;
  var orders = <TestOrderModel>[].obs;
  var page = 1.obs;
  var isLastPage = false.obs;
  var statusFilter = Rxn<TestOrderStatus>();

  @override
  void onInit() {
    super.onInit();
    fetchOrders();
  }

  Future<void> fetchOrders({bool showLoader = true}) async {
    if (showLoader) isLoading.value = true;
    try {
      final res = await LabsRadiologyApis.getTestOrders(
        page: page.value,
        statusFilter: statusFilter.value,
      );

      if (page.value == 1) {
        orders.assignAll(res.data);
      } else {
        orders.addAll(res.data);
      }

      isLastPage.value = !res.hasMore;
    } catch (e) {
      toast(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadMore() async {
    if (isLoading.value || isLastPage.value) return;
    page.value++;
    fetchOrders(showLoader: false);
  }

  void updateStatusFilter(TestOrderStatus? status) {
    statusFilter.value = status;
    page.value = 1;
    fetchOrders();
  }
}
