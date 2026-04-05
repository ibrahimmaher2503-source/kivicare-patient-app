import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../api/core_apis.dart';
import '../../main.dart';
import 'model/lab_test_category_model.dart';

class LabTestCategoriesController extends GetxController {
  Rx<Future<List<LabTestCategory>>> categoriesFuture = Future(() => <LabTestCategory>[]).obs;
  RxList<LabTestCategory> categories = RxList<LabTestCategory>();
  RxBool isLoading = false.obs;

  @override
  void onInit() {
    getCategories();
    super.onInit();
  }

  Future<void> getCategories() async {
    isLoading(true);

    await categoriesFuture(
      CoreServiceApis.getLabTestCategories(),
    ).then((value) {
      categories.assignAll(value);
      log('Lab test categories fetched: ${value.length}');
    }).catchError((e) {
      log("getCategories error $e");
      toast(locale.value.somethingWentWrong);
    }).whenComplete(() => isLoading(false));
  }
}
