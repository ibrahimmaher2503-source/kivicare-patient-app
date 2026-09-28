import 'package:flutter_test/flutter_test.dart';
import 'package:kivicare_patient/screens/booking/filter/filter_controller.dart';
import 'package:kivicare_patient/screens/clinic/clinic_list_controller.dart';
import 'package:kivicare_patient/screens/clinic/model/clinics_res_model.dart';
import 'package:kivicare_patient/screens/service/model/service_list_model.dart';
import 'package:kivicare_patient/utils/app_common.dart';

void main() {
  test('clinic parser uses the current locale with a safe fallback', () {
    selectedLanguageCode.value = 'ar';
    final clinic = Clinic.fromJson({
      'id': 9,
      'name': 'Default clinic',
      'name_ar': 'عيادة الاختبار',
      'name_en': 'QA Clinic',
      'description_ar': 'وصف عربي',
      'description_en': 'English description',
    });

    expect(clinic.name, 'عيادة الاختبار');
    expect(clinic.description, 'وصف عربي');

    selectedLanguageCode.value = 'en';
    final fallback = Clinic.fromJson({
      'name_ar': 'عيادة بديلة',
      'description_ar': 'وصف بديل',
    });
    expect(fallback.name, 'عيادة بديلة');
    expect(fallback.description, 'وصف بديل');
  });

  test('clinic filter counts service, price, governorate, and city once each',
      () {
    final list = ClinicListController();
    list.service(ServiceElement(id: 1));
    list.priceMin('100');
    list.governorateId.value = 2;
    list.cityId.value = 3;
    expect(list.activeFilterCount, 4);
    list.onClose();

    final filter = FilterController();
    filter.selectedGovernorateId.value = 2;
    filter.selectedCityId.value = 3;
    expect(filter.actualClinicFilterCount.value, 2);
    filter.onClose();
  });
}
