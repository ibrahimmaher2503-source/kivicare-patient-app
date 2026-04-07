import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../api/core_apis.dart';
import '../../main.dart';
import '../../screens/radiology/model/radiology_center_model.dart';

class RadiologySearchController extends GetxController {
  Rx<Future<RxList<RadiologyCenter>>> itemsFuture = Future.value(RxList<RadiologyCenter>()).obs;
  RxList<RadiologyCenter> items = RxList<RadiologyCenter>();
  RxBool isLoading = false.obs;
  RxBool isLastPage = false.obs;
  RxInt page = 1.obs;

  RxnInt selectedGovernorateId = RxnInt();
  RxnInt selectedCityId = RxnInt();
  RxString selectedScanType = ''.obs;

  List<Map<String, String>> get scanTypeFilters => [
    {'key': '', 'label': locale.value.all},
    {'key': 'MRI', 'label': locale.value.mriScan},
    {'key': 'CT', 'label': locale.value.ctScan},
    {'key': 'X-ray', 'label': locale.value.xRay},
    {'key': 'Ultrasound', 'label': locale.value.ultrasound},
  ];

  @override
  void onInit() {
    super.onInit();
    getItems();
  }

  Future<void> getItems({bool showLoader = true}) async {
    if (showLoader) isLoading(true);
    await itemsFuture(CoreServiceApis.searchRadiologyCenters(
      page: page.value,
      perPage: 15,
      centerList: items,
      governorateId: selectedGovernorateId.value,
      cityId: selectedCityId.value,
      scanType: selectedScanType.value,
      lastPageCallBack: (isLast) => isLastPage(isLast),
    )).then((v) {}).catchError((e) { toast(e.toString()); }).whenComplete(() => isLoading(false));
  }

  void onGovernorateChanged(int? id) { selectedGovernorateId.value = id; selectedCityId.value = null; page(1); getItems(); }
  void onCityChanged(int? id) { selectedCityId.value = id; page(1); getItems(); }
  void onScanTypeChanged(String val) { selectedScanType.value = val; page(1); getItems(); }
}
