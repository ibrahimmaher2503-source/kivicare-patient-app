import 'package:flutter_test/flutter_test.dart';
import 'package:kivicare_patient/screens/booking/filter/filter_controller.dart';
import 'package:kivicare_patient/screens/category/model/category_list_model.dart';
import 'package:kivicare_patient/screens/service/model/service_list_model.dart';
import 'package:kivicare_patient/screens/service/service_list_controller.dart';
import 'package:kivicare_patient/utils/app_common.dart';
import 'package:kivicare_patient/locale/language_ar.dart';
import 'package:kivicare_patient/locale/language_en.dart';

void main() {
  test('service parser keeps localized copy and safe image fallback', () {
    selectedLanguageCode.value = 'ar';
    final service = ServiceElement.fromJson({
      'id': 7,
      'name_en': 'QA Service',
      'name_ar': 'خدمة اختبار',
      'description_en': 'English description',
      'description_ar': 'وصف عربي',
      'service_image': '',
      'system_service_id': 11,
    });

    expect(service.name, 'خدمة اختبار');
    expect(service.description, 'وصف عربي');
    expect(service.serviceImage, isEmpty);
    expect(service.systemServiceId, 11);

    final priced = ServiceElement.fromJson({
      'id': 8,
      'name_ar': 'خدمة مدفوعة',
      'charges': '300.00',
      'payable_amount': '275.50',
    });
    expect(priced.charges, 300);
    expect(priced.payableAmount, 275.5);
  });

  test('service filters count category, price, governorate, and city', () {
    final list = ServiceListController();
    list.category(CategoryElement(id: 1));
    list.priceMax('500');
    list.governorateId.value = 2;
    list.cityId.value = 3;
    expect(list.activeFilterCount, 4);
    list.onClose();

    final filter = FilterController();
    filter.selectedGovernorateId.value = 2;
    filter.selectedCityId.value = 3;
    expect(filter.actualServiceFilterCount.value, 2);
    expect(filter.isPriceFilterApplied, isFalse);
    filter.setMinPrice(300);
    filter.priceFilterTouched(true);
    expect(filter.isPriceFilterApplied, isTrue);
    filter.onClose();
  });

  test('service empty state copy is localized and actionable', () {
    expect(
        LanguageAr().noServicesMatchFilters, 'لا توجد خدمات مطابقة لاختياراتك');
    expect(LanguageAr().tryChangingFiltersOrSearchAgain,
        'جرّب تغيير الاختيارات أو البحث عن خدمة أخرى.');
    expect(
        LanguageEn().noServicesMatchFilters, 'No services match your filters');
    expect(LanguageEn().tryChangingFiltersOrSearchAgain,
        'Try changing the filters or searching for another service.');
  });
}
