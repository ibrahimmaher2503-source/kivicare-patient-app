import 'package:get/get.dart';

class HospitalFilterController extends GetxController {
  final selectedGovernorateId = Rxn<int>();
  final selectedGovernorateName = Rxn<String>();

  final selectedCityId = Rxn<int>();
  final selectedCityName = Rxn<String>();

  final selectedDepartmentTypeId = Rxn<int>();
  final selectedDepartmentTypeName = Rxn<String>();

  final hasAvailableBedsOnly = false.obs;

  int get activeFilterCount {
    int count = 0;
    if (selectedGovernorateId.value != null) count++;
    if (selectedCityId.value != null) count++;
    if (selectedDepartmentTypeId.value != null) count++;
    if (hasAvailableBedsOnly.value) count++;
    return count;
  }

  void clear() {
    selectedGovernorateId.value = null;
    selectedGovernorateName.value = null;
    selectedCityId.value = null;
    selectedCityName.value = null;
    selectedDepartmentTypeId.value = null;
    selectedDepartmentTypeName.value = null;
    hasAvailableBedsOnly.value = false;
  }

  void setGovernorate(int? id, String? name) {
    if (selectedGovernorateId.value != id) {
      selectedGovernorateId.value = id;
      selectedGovernorateName.value = name;
      // Clear city if governorate changes
      selectedCityId.value = null;
      selectedCityName.value = null;
    }
  }

  void setCity(int? id, String? name) {
    selectedCityId.value = id;
    selectedCityName.value = name;
  }
}
