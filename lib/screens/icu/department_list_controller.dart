import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../api/core_apis.dart';
import '../../main.dart';
import '../../utils/constants.dart';
import 'model/hospital_model.dart';

class DepartmentListController extends GetxController {
  // List state
  Rx<Future<RxList<IcuDepartment>>> departmentFuture = Future(() => RxList<IcuDepartment>()).obs;
  RxList<IcuDepartment> departments = RxList<IcuDepartment>();
  RxBool isLoading = false.obs;
  RxBool isLastPage = false.obs;
  RxInt page = 1.obs;

  // Filters
  RxnInt hospitalId = RxnInt();
  RxString selectedSpecialty = ''.obs;
  RxBool availableOnly = false.obs;
  RxBool ventilatorOnly = false.obs;

  RxList<Map<String, String>> specialtyFilters = RxList();

  @override
  void onInit() {
    specialtyFilters = [
      {'key': '', 'label': locale.value.all},
      {'key': IcuSpecialtyConst.cardiac, 'label': locale.value.specialtyCardiac},
      {'key': IcuSpecialtyConst.neurology, 'label': locale.value.specialtyNeurology},
      {'key': IcuSpecialtyConst.pediatric, 'label': locale.value.specialtyPediatric},
      {'key': IcuSpecialtyConst.neonatal, 'label': locale.value.specialtyNeonatal},
      {'key': IcuSpecialtyConst.burns, 'label': locale.value.specialtyBurns},
      {'key': IcuSpecialtyConst.chest, 'label': locale.value.specialtyChest},
      {'key': IcuSpecialtyConst.surgical, 'label': locale.value.specialtySurgical},
      {'key': IcuSpecialtyConst.general, 'label': locale.value.specialtyGeneral},
    ].obs;

    getDepartments();
    super.onInit();
  }

  Future<void> getDepartments({bool showLoader = true}) async {
    if (showLoader) {
      isLoading(true);
    }

    await departmentFuture(
      CoreServiceApis.getIcuDepartmentList(
        page: page.value,
        perPage: Constants.perPageItem,
        departmentList: departments,
        hospitalId: hospitalId.value,
        specialty: selectedSpecialty.value,
        available: availableOnly.value ? 'true' : '',
        ventilator: ventilatorOnly.value ? 'true' : '',
        lastPageCallBack: (isLast) => isLastPage(isLast),
      ),
    ).then((value) {
      log('Departments fetched: ${value.length}');
    }).catchError((e) {
      log("getDepartments error $e");
    }).whenComplete(() => isLoading(false));
  }

  void onSpecialtyChanged(String specialty) {
    selectedSpecialty(specialty);
    page(1);
    getDepartments();
  }

  void toggleAvailableOnly() {
    availableOnly(!availableOnly.value);
    page(1);
    getDepartments();
  }

  void toggleVentilatorOnly() {
    ventilatorOnly(!ventilatorOnly.value);
    page(1);
    getDepartments();
  }
}
