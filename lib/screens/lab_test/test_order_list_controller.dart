import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../api/core_apis.dart';
import '../../main.dart';
import 'model/test_order_model.dart';

class TestOrderListController extends GetxController {
  // List state
  Rx<Future<RxList<TestOrder>>> orderFuture = Future(() => RxList<TestOrder>()).obs;
  RxList<TestOrder> orders = RxList<TestOrder>();
  RxBool isLoading = false.obs;
  RxBool isLastPage = false.obs;
  RxInt page = 1.obs;

  // Status filter
  RxString selectedStatus = ''.obs;
  RxList<Map<String, String>> statusFilters = RxList();

  @override
  void onInit() {
    statusFilters = [
      {'key': '', 'label': locale.value.all},
      {'key': 'pending', 'label': locale.value.pending},
      {'key': 'confirmed', 'label': locale.value.confirmed},
      {'key': 'sample_collected', 'label': locale.value.sampleCollected},
      {'key': 'processing', 'label': locale.value.processing},
      {'key': 'completed', 'label': locale.value.completed},
      {'key': 'delivered', 'label': locale.value.delivered},
      {'key': 'cancelled', 'label': locale.value.cancelled},
    ].obs;

    getTestOrders();
    super.onInit();
  }

  Future<void> getTestOrders({bool showLoader = true}) async {
    if (showLoader) {
      isLoading(true);
    }

    await orderFuture(
      CoreServiceApis.getTestOrderList(
        page: page.value,
        perPage: 15,
        orderList: orders,
        status: selectedStatus.value,
        lastPageCallBack: (isLast) => isLastPage(isLast),
      ),
    ).then((value) {
      log('Test orders fetched: ${value.length}');
    }).catchError((e) {
      log("getTestOrders error $e");
      toast(locale.value.somethingWentWrong);
    }).whenComplete(() => isLoading(false));
  }

  void onFilterChanged(String status) {
    selectedStatus(status);
    page(1);
    getTestOrders();
  }
}
