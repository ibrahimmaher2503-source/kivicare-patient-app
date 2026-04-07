import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../api/core_apis.dart';
import 'model/pharmacy_order_model.dart';

class PharmacyOrderListController extends GetxController {
  RxList<PharmacyOrderSummary> orders = <PharmacyOrderSummary>[].obs;
  RxBool isLoading = false.obs;
  RxBool isLoadingMore = false.obs;

  int currentPage = 1;
  bool isLastPage = false;

  @override
  void onInit() {
    super.onInit();
    loadOrders();
  }

  Future<void> loadOrders({bool isRefresh = false}) async {
    if (isRefresh) {
      currentPage = 1;
      isLastPage = false;
    }
    isLoading(true);
    try {
      await CoreServiceApis.getPharmacyOrders(
        list: orders,
        page: currentPage,
        lastPageCallback: (isLast) => isLastPage = isLast,
      );
    } catch (e) {
      toast(e.toString());
    } finally {
      isLoading(false);
    }
  }

  Future<void> loadMore() async {
    if (isLastPage || isLoadingMore.value) return;
    isLoadingMore(true);
    currentPage++;
    try {
      await CoreServiceApis.getPharmacyOrders(
        list: orders,
        page: currentPage,
        lastPageCallback: (isLast) => isLastPage = isLast,
      );
    } catch (e) {
      currentPage--;
      toast(e.toString());
    } finally {
      isLoadingMore(false);
    }
  }
}
