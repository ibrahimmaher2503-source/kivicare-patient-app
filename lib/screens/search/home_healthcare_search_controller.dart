import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../api/core_apis.dart';
import '../../main.dart';
import '../../models/home_healthcare_provider_model.dart';

class HomeHealthcareSearchController extends GetxController {
  Rx<Future<RxList<HomeHealthcareProvider>>> itemsFuture = Future.value(RxList<HomeHealthcareProvider>()).obs;
  RxList<HomeHealthcareProvider> items = RxList<HomeHealthcareProvider>();
  RxBool isLoading = false.obs;
  RxBool isLastPage = false.obs;
  RxInt page = 1.obs;

  RxnInt selectedGovernorateId = RxnInt();
  RxnInt selectedCityId = RxnInt();
  RxString selectedServiceType = ''.obs;

  List<Map<String, String>> get serviceTypeFilters => [
    {'key': '', 'label': locale.value.all},
    {'key': 'physiotherapy', 'label': locale.value.physiotherapy},
    {'key': 'elderly_care', 'label': locale.value.elderlyCare},
    {'key': 'post_surgery', 'label': locale.value.postSurgery},
    {'key': 'chronic_care', 'label': locale.value.chronicCare},
  ];

  @override
  void onInit() {
    super.onInit();
    getItems();
  }

  Future<void> getItems({bool showLoader = true}) async {
    if (showLoader) isLoading(true);
    await itemsFuture(CoreServiceApis.searchHomeHealthcare(
      page: page.value,
      perPage: 15,
      providerList: items,
      governorateId: selectedGovernorateId.value,
      cityId: selectedCityId.value,
      serviceType: selectedServiceType.value,
      lastPageCallBack: (isLast) => isLastPage(isLast),
    )).then((v) {}).catchError((e) { toast(e.toString()); }).whenComplete(() => isLoading(false));
  }

  void onGovernorateChanged(int? id) { selectedGovernorateId.value = id; selectedCityId.value = null; page(1); getItems(); }
  void onCityChanged(int? id) { selectedCityId.value = id; page(1); getItems(); }
  void onServiceTypeChanged(String val) { selectedServiceType.value = val; page(1); getItems(); }
}
