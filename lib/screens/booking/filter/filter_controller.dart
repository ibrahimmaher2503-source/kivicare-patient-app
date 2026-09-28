import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kivicare_patient/main.dart';
import 'package:kivicare_patient/screens/clinic/clinic_list_controller.dart';
import 'package:kivicare_patient/screens/service/model/service_list_model.dart';
import 'package:kivicare_patient/utils/app_common.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:stream_transform/stream_transform.dart';

import '../../../api/core_apis.dart';
import '../../../utils/constants.dart';
import '../../category/model/category_list_model.dart';
import '../../clinic/model/clinic_detail_model.dart';
import '../../clinic/model/clinics_res_model.dart';
import '../../doctor/doctor_list_controller.dart';
import '../../location_filter/models/city_model.dart';
import '../../location_filter/models/governorate_model.dart';
import '../../location_filter/service/location_cache_service.dart';
import '../../service/service_list_controller.dart';
import 'components/clinic_filter/filter_clinic_component.dart';
import 'components/filter_category.dart';
import 'components/filter_service.dart';
import 'components/price_filter/filter_price_component.dart';
import 'components/rating_filter.dart';
import 'components/service_type_filter/filter_service_type_component.dart';
import 'model/filter_params.dart';

class FilterController extends GetxController {
  static const double defaultMaximumPrice = 5000;
  static const double defaultMaximumRating = 5;

  int _clinicRequestGeneration = 0;
  int _serviceRequestGeneration = 0;
  int _categoryRequestGeneration = 0;
  RxString filterType = "".obs;

  //Clinic List
  Rx<Future<RxList<Clinic>>> clinicListFuture =
      Future(() => RxList<Clinic>()).obs;
  RxBool isClinicLoading = false.obs;
  RxList<Clinic> clinicList = RxList();
  RxBool isClinicLastPage = false.obs;
  RxInt clinicPage = 1.obs;
  RxBool isSearchClinicText = false.obs;
  TextEditingController searchClinicCont = TextEditingController();
  StreamController<String> searchClinicStream = StreamController<String>();
  Rx<Clinic> selectedClinicData = Clinic(clinicSession: ClinicSession()).obs;

  // Service
  Rx<Future<RxList<ServiceElement>>> serviceListFuture =
      Future(() => RxList<ServiceElement>()).obs;
  RxBool isServiceLoading = false.obs;
  RxList<ServiceElement> serviceList = RxList();
  RxBool isServiceLastPage = false.obs;
  RxInt servicePage = 1.obs;
  RxBool isSearchServiceText = false.obs;
  TextEditingController searchServiceCont = TextEditingController();
  StreamController<String> searchServiceStream = StreamController<String>();
  final scrollServiceController = ScrollController();
  Rx<CategoryElement> selectedCategoryData = CategoryElement().obs;

  // Service
  Rx<Future<RxList<CategoryElement>>> categoryListFuture =
      Future(() => RxList<CategoryElement>()).obs;
  RxBool isCategoryLoading = false.obs;
  RxList<CategoryElement> categoryList = RxList();
  RxBool isCategoryLastPage = false.obs;
  RxInt categoryPage = 1.obs;
  RxBool isSearchCategoryText = false.obs;
  TextEditingController searchCategoryCont = TextEditingController();
  StreamController<String> searchCategoryStream = StreamController<String>();
  final _scrollCategoryController = ScrollController();
  Rx<ServiceElement> selectedServiceData = ServiceElement().obs;

  RxDouble minimumPrice = (0.0).obs;
  RxDouble maximumPrice = defaultMaximumPrice.obs;
  final RxBool priceFilterTouched = false.obs;

  RxDouble minimumRating = (0.0).obs;
  RxDouble maximumRating = defaultMaximumRating.obs;
  Rx<RangeValues> rangeValues = const RangeValues(1, 5000).obs;
  Rx<RangeValues> rangeRatingValues = const RangeValues(1, 5).obs;

  RxList filterList = [
    locale.value.clinic,
    locale.value.filterService,
    locale.value.filterRating
  ].obs;
  RxList serviceFilterList =
      [locale.value.clinic, locale.value.price, locale.value.category].obs;
  RxList clinicFilterList = [locale.value.filterService].obs;
  RxList categoryFilterList = [locale.value.clinic, locale.value.price].obs;

  RxList serviceTypeList = [
    {"title": locale.value.inClinic, "value": ServiceTypeConst.inClinic},
    {"title": locale.value.online, "value": ServiceTypeConst.online}
  ].obs;
  RxString selectedServiceType = "".obs;

  // Location filter fields — added for the location filter module
  final Rxn<int> selectedGovernorateId = Rxn<int>();
  final Rxn<int> selectedCityId = Rxn<int>();
  final Rxn<GovernorateModel> selectedGovernorate = Rxn<GovernorateModel>();
  final Rxn<CityModel> selectedCity = Rxn<CityModel>();
  final Rxn<int> selectedSpecialtyId = Rxn<int>();
  final RxString selectedGender = ''.obs;

  int get locationFilterCount => selectedGovernorateId.value != null ? 1 : 0;

  int get activeFilterCount {
    var count = locationFilterCount;
    if (selectedClinicData.value.id > 0) count++;
    if (selectedServiceData.value.id > 0) count++;
    if (selectedCategoryData.value.id > 0) count++;
    if (selectedServiceType.value.isNotEmpty) count++;
    if (isPriceFilterApplied) count++;
    if (minimumRating.value > 0 || maximumRating.value < 5) count++;
    if (selectedSpecialtyId.value != null) count++;
    if (selectedGender.value.isNotEmpty) count++;
    return count;
  }

  bool get isPriceFilterApplied =>
      priceFilterTouched.value &&
      (minimumPrice.value > 0 || maximumPrice.value < defaultMaximumPrice);

  Future<void> applyLocationSelection({
    required int? governorateId,
    required int? cityId,
    GovernorateModel? governorate,
    CityModel? city,
  }) async {
    selectedGovernorateId.value = governorateId;
    selectedCityId.value = cityId;
    selectedGovernorate.value = governorate;
    selectedCity.value = city;
    await LocationCacheService().saveLastSelection(
      governorateId: governorateId,
      cityId: cityId,
    );
  }

  Future<void> clearLocationSelection() async {
    selectedGovernorateId.value = null;
    selectedCityId.value = null;
    selectedGovernorate.value = null;
    selectedCity.value = null;
    await LocationCacheService().clearLastSelection();
  }

  @override
  void onInit() {
    // Hydrate persisted location selection
    final locationCache = LocationCacheService();
    selectedGovernorateId.value = locationCache.getLastSelectedGovernorateId();
    selectedCityId.value = locationCache.getLastSelectedCityId();

    if (Get.arguments is FilterParams) {
      final params = Get.arguments as FilterParams;

      // Determine filter type first — needed to interpret args[2]/[3] correctly
      final String typeArg = params.moduleType;
      if (typeArg == "service") {
        filterType(serviceFilterList[0]);
      } else if (typeArg == "clinic") {
        filterType(clinicFilterList[0]);
      } else if (typeArg == "category") {
        filterType(categoryFilterList[0]);
      } else {
        filterType(filterList[0]);
      }

      if (params.clinicId > 0) {
        selectedClinicData(
          Clinic(id: params.clinicId, clinicSession: ClinicSession()),
        );
        seleClinicFilterCount(1);
      }

      selectedServiceType(params.serviceType);
      selectedGovernorateId.value = params.governorateId;
      selectedCityId.value = params.cityId;
      selectedSpecialtyId.value = params.specialtyId;
      selectedGender.value = params.gender;

      if (typeArg == "doctor") {
        // args[2] and [3] carry ratingMin / ratingMax for the doctor filter
        if (params.ratingMin.isNotEmpty) {
          final v = double.tryParse(params.ratingMin) ?? 0;
          minimumRating(v > 0 ? v : 0.0);
        }
        if (params.ratingMax.isNotEmpty) {
          final v = double.tryParse(params.ratingMax) ?? 5;
          maximumRating(v > 0 ? v : 5.0);
        }
        rangeRatingValues(RangeValues(
          minimumRating.value > 0 ? minimumRating.value : 1,
          maximumRating.value > 0 ? maximumRating.value : 5,
        ));
      } else {
        // args[2] and [3] carry priceMin / priceMax for other filter types
        if (params.priceMin.isNotEmpty) {
          final value = double.tryParse(params.priceMin) ?? 0;
          minimumPrice(value > 0 ? value : 0);
          priceFilterTouched.value = true;
        }
        if (params.priceMax.isNotEmpty) {
          final value = double.tryParse(params.priceMax) ?? 0;
          maximumPrice(value > 0 ? value : 5000);
          priceFilterTouched.value = true;
        }
        rangeValues(RangeValues(
          minimumPrice.value > 0 ? minimumPrice.value : 1,
          maximumPrice.value,
        ));
      }

      // args[5] is categoryId — guard with length check
      if (params.categoryId > 0) {
        selectedCategoryData(CategoryElement(id: params.categoryId));
      }
    }

    getClinic();
    getCategory();
    getService();

    super.onInit();
  }

  void setMaxPrice(double val) {
    maximumPrice(val);
  }

  void setMinPrice(double val) {
    minimumPrice(val);
  }

  void setMaxRating(double val) {
    maximumRating(val);
  }

  void setMinRating(double val) {
    minimumRating(val);
  }

  //get Clinic Info
  void getClinic() {
    searchClinicStream.stream.debounce(const Duration(seconds: 1)).listen((s) {
      clinicPage(1);
      getClinicsList(search: s);
    });
    getClinicsList();
  }

  void getService() {
    scrollServiceController.addListener(
        () => Get.context != null ? hideKeyboard(Get.context) : null);
    searchServiceStream.stream.debounce(const Duration(seconds: 1)).listen((s) {
      servicePage(1);
      getServicesList(search: s);
    });
    getServicesList();
  }

  void getCategory() {
    _scrollCategoryController.addListener(
        () => Get.context != null ? hideKeyboard(Get.context) : null);
    searchCategoryStream.stream
        .debounce(const Duration(seconds: 1))
        .listen((s) {
      categoryPage(1);
      getCategoryList(search: s);
    });
    getCategoryList();
  }

  Future<void> getClinicsList(
      {bool showLoader = true, String search = ""}) async {
    final requestGeneration = ++_clinicRequestGeneration;
    final requestedPage = clinicPage.value;
    final requestList = requestedPage == 1 ? <Clinic>[] : clinicList.toList();
    var isLastPage = false;
    if (showLoader) {
      isClinicLoading(true);
    }
    await clinicListFuture(
      CoreServiceApis.getClinics(
        page: requestedPage,
        search: search.isEmpty ? searchClinicCont.text.trim() : search.trim(),
        clinics: requestList,
        lastPageCallBack: (p0) {
          isLastPage = p0;
        },
      ),
    ).then((value) {
      if (requestGeneration != _clinicRequestGeneration) return;
      clinicList.assignAll(value);
      isClinicLastPage(isLastPage);
      log('value.length ==> ${value.length}');
    }).catchError((e) {
      isClinicLoading(false);
      log('getClinics: $e');
    }).whenComplete(() => isClinicLoading(false));
  }

  Future<void> getServicesList(
      {bool showLoader = true, String search = ""}) async {
    final requestGeneration = ++_serviceRequestGeneration;
    final requestedPage = servicePage.value;
    final requestList =
        requestedPage == 1 ? <ServiceElement>[] : serviceList.toList();
    var isLastPage = false;
    if (showLoader) {
      isServiceLoading(true);
    }
    await serviceListFuture(
      CoreServiceApis.getServiceList(
        serviceList: requestList,
        page: requestedPage,
        search: search.isEmpty ? searchServiceCont.text.trim() : search.trim(),
        lastPageCallBack: (p0) {
          isLastPage = p0;
        },
      ),
    ).then((value) {
      if (requestGeneration != _serviceRequestGeneration) return;
      serviceList.assignAll(value);
      isServiceLastPage(isLastPage);
      log('value.length ==> ${value.length}');
    }).catchError((e) {
      isServiceLoading(false);
      log('getClinics: $e');
    }).whenComplete(() => isServiceLoading(false));
  }

  Future<void> getCategoryList(
      {bool showLoader = true, String search = ""}) async {
    final requestGeneration = ++_categoryRequestGeneration;
    final requestedPage = categoryPage.value;
    final requestList =
        requestedPage == 1 ? <CategoryElement>[] : categoryList.toList();
    var isLastPage = false;
    if (showLoader) {
      isCategoryLoading(true);
    }
    await categoryListFuture(
      CoreServiceApis.getCategoryList(
        categories: requestList,
        page: requestedPage,
        search: search.isEmpty ? searchCategoryCont.text.trim() : search.trim(),
        lastPageCallBack: (p0) {
          isLastPage = p0;
        },
      ),
    ).then((value) {
      if (requestGeneration != _categoryRequestGeneration) return;
      categoryList.assignAll(value);
      isCategoryLastPage(isLastPage);
      log('value.length ==> ${value.length}');
    }).catchError((e) {
      isCategoryLoading(false);
      log('getClinics: $e');
    }).whenComplete(() => isCategoryLoading(false));
  }

  RxInt appliedFilterCount = 0.obs;

  void resetFilter(String moduleType, String filterType) {
    selectedClinicData(Clinic(clinicSession: ClinicSession()));
    totalServiceCount(0).obs;
    totalDoctorCount(0).obs;
    seleFilterCount(0).obs;
    selePriceFilterCount(0).obs;
    seleRatingFilterCount(0).obs;
    seleClinicFilterCount(0).obs;
    seleCategoryFilterCount(0).obs;
    selectedServiceType("");
    selectedSpecialtyId.value = null;
    selectedGender.value = '';
    clearLocationSelection();
    minimumPrice(0.0);
    maximumPrice(defaultMaximumPrice);
    priceFilterTouched(false);
    minimumRating(0.0);
    maximumRating(defaultMaximumRating);
    rangeValues(const RangeValues(1, 5000));
    rangeRatingValues(const RangeValues(1, 5));

    if (filterType != 'category') {
      selectedCategoryData(CategoryElement());
      selectedServiceData(ServiceElement());
    }

    applyFilter(moduleType, isReset: true);
  }

  bool _isFilterType(String value, List<String> labels) {
    return labels.any((label) => label == value);
  }

  Widget viewFilterWidget(String displayValue) {
    final selectedFilterType = filterType.value;
    log("filter type--------------$selectedFilterType");

    if (_isFilterType(selectedFilterType, ["Price", locale.value.price])) {
      return displayValue == 'service' || displayValue == 'category'
          ? FilterPriceComponent().expand(flex: 3)
          : SizedBox();
    }

    if (_isFilterType(selectedFilterType, ["Clinic", locale.value.clinic])) {
      return FilterClinicComponent().expand(flex: 3).visible(
          displayValue == "doctor" ||
              displayValue == "service" ||
              displayValue == 'category');
    }

    if (_isFilterType(
        selectedFilterType, ["Service Type", locale.value.serviceType])) {
      return FilterServiceTypeComponent().expand(flex: 3);
    }

    if (_isFilterType(selectedFilterType,
        ["Category", locale.value.category, locale.value.filterCategory])) {
      return FilterServiceComponent()
          .expand(flex: 3)
          .visible(displayValue == "service");
    }

    if (_isFilterType(
        selectedFilterType, ["Service", locale.value.filterService])) {
      return displayValue == 'doctor' ||
              displayValue == 'clinic' ||
              displayValue == 'category'
          ? FilterCategoryComponent().expand(flex: 3).visible(
              displayValue == 'doctor' ||
                  displayValue == 'clinic' ||
                  displayValue == 'category')
          : SizedBox().expand(flex: 3).visible(displayValue == 'doctor');
    }

    if (_isFilterType(
        selectedFilterType, ["Rating", locale.value.filterRating])) {
      return FilterRatingComponent()
          .expand(flex: 3)
          .visible(displayValue == 'doctor');
    }

    return FilterServiceComponent().expand(flex: 3);
  }

  Rx<ServiceElement> filterServiceData = ServiceElement().obs;
  RxInt seleFilterCount = 0.obs;

  void selectedServiceDataFunc(ServiceElement service) {
    if (filterServiceData.value.id != service.id) {
      filterServiceData.value = service;
      selectedServiceData(service);
    } else {
      filterServiceData.value = ServiceElement();
      selectedServiceData(ServiceElement());
    }
    if (seleFilterCount.value == 0) seleFilterCount++;
  }

  Rx<Clinic> filterClinicData = Clinic(clinicSession: ClinicSession()).obs;
  RxInt seleClinicFilterCount = 0.obs;

  void selectedClinicDataFunc(Clinic clinic) {
    if (filterClinicData.value.id != clinic.id) {
      filterClinicData.value = clinic;
      selectedClinicData(clinic);
    } else {
      filterClinicData.value = Clinic(clinicSession: ClinicSession());
      selectedClinicData(Clinic(clinicSession: ClinicSession()));
    }
    if (seleClinicFilterCount.value == 0) seleClinicFilterCount++;
  }

  RxInt get totalDoctorCount => (seleFilterCount.value +
          seleClinicFilterCount.value +
          seleRatingFilterCount.value)
      .obs;

  RxInt get actualDoctorFilterCount {
    int count = 0;

    if (selectedServiceData.value.id > 0) {
      count++;
    }

    if (selectedClinicData.value.id > 0) {
      count++;
    }
    if (minimumRating.value > 0.0 ||
        maximumRating.value < defaultMaximumRating) {
      count++;
    }

    return count.obs;
  }

  Rx<CategoryElement> filterCategoryData = CategoryElement().obs;
  RxInt seleCategoryFilterCount = 0.obs;

  void selectedCategoryDataFunc(CategoryElement category) {
    if (filterCategoryData.value.id != category.id) {
      filterCategoryData.value = category;
      selectedCategoryData(category);
    } else {
      filterCategoryData.value = CategoryElement();
      selectedCategoryData(CategoryElement());
    }
    if (seleCategoryFilterCount.value == 0) seleCategoryFilterCount++;
  }

  RxInt get totalServiceCount => (seleCategoryFilterCount.value +
          seleClinicFilterCount.value +
          selePriceFilterCount.value)
      .obs;

  /// Proper count calculation for service filter
  RxInt get actualServiceFilterCount {
    int count = 0;

    // Count category filter if applied
    if (selectedCategoryData.value.id > 0) {
      count++;
    }

    // Count clinic filter if applied
    if (selectedClinicData.value.id > 0) {
      count++;
    }

    // Count price filter if applied (only if not default range)
    if (isPriceFilterApplied) {
      count++;
    }

    if (selectedGovernorateId.value != null) count++;
    if (selectedCityId.value != null) count++;

    return count.obs;
  }

  /// Proper count calculation for clinic filter
  RxInt get actualClinicFilterCount {
    int count = 0;

    // Count service filter if applied
    if (selectedServiceData.value.id > 0) {
      count++;
    }

    // Count price filter if applied (only if not default range)
    if (isPriceFilterApplied) {
      count++;
    }

    if (selectedGovernorateId.value != null) {
      count++;
    }

    if (selectedCityId.value != null) {
      count++;
    }

    return count.obs;
  }

  RxInt seleRatingFilterCount = 0.obs;
  RxInt selePriceFilterCount = 0.obs;

  void applyFilterCount() {
    // Reset counts first
    seleRatingFilterCount(0);
    selePriceFilterCount(0);

    // Only count if rating range is actually set (not default)
    if (minimumRating.value > 0.0 ||
        maximumRating.value < defaultMaximumRating) {
      seleRatingFilterCount(1);
    }

    // Only count if price range is actually set (not default)
    if (isPriceFilterApplied) {
      selePriceFilterCount(1);
    }
  }

  RxInt get totalCategoryCount =>
      (seleClinicFilterCount.value + selePriceFilterCount.value).obs;

  /// Proper count calculation that only counts actually applied filters
  RxInt get actualCategoryFilterCount {
    int count = 0;

    // Count clinic filter if applied
    if (selectedClinicData.value.id > 0) {
      count++;
    }

    // Count price filter if applied (only if not default range)
    if (isPriceFilterApplied) {
      count++;
    }

    // Count category filter if applied
    if (selectedCategoryData.value.id > 0) {
      count++;
    }

    return count.obs;
  }

  Future<void> applyFilter(String type,
      {bool isReset = false,
      String newFilterType = '',
      ServiceListController? serviceController}) async {
    if (type == "service") {
      final serviceCont =
          serviceController ?? Get.find<ServiceListController>();
      serviceCont.clinicId(selectedClinicData.value.id);
      serviceCont.serviceType(selectedServiceType.value);

      final hasPriceFilter = isPriceFilterApplied;
      serviceCont.priceMin(hasPriceFilter ? minimumPrice.value.toString() : "");
      serviceCont.priceMax(hasPriceFilter ? maximumPrice.value.toString() : "");
      serviceCont.serviceData(selectedServiceData.value);
      serviceCont.category(selectedCategoryData.value);
      serviceCont.categoryId(selectedCategoryData.value.id);
      serviceCont.governorateId.value = selectedGovernorateId.value;
      serviceCont.cityId.value = selectedCityId.value;
      applyFilterCount();
      serviceCont.refresh();
      Get.back(result: actualServiceFilterCount.value);
      serviceCont.getServiceList();
    } else if (type == 'doctor') {
      DoctorListController doctorConte = Get.find();
      doctorConte.clinicId(selectedClinicData.value.id);
      doctorConte.serviceType(selectedServiceType.value);
      doctorConte.ratingMin(
          minimumRating.value > 0 ? minimumRating.value.toString() : "");
      doctorConte.ratingMax(
          maximumRating.value > 0 ? maximumRating.value.toString() : "");
      doctorConte.governorateId.value = selectedGovernorateId.value;
      doctorConte.cityId.value = selectedCityId.value;
      currentSelectedService(selectedServiceData.value);
      applyFilterCount();
      Get.back(
        result: {
          'totalDoctorCount': actualDoctorFilterCount.value,
        },
      );

      doctorConte.getDoctors();
    } else if (type == 'clinic') {
      ClinicListController clinicCont = Get.find();
      clinicCont.clinicId(selectedClinicData.value.id);
      clinicCont.service(selectedServiceData.value);

      final hasPriceFilter = isPriceFilterApplied;
      clinicCont.priceMin(hasPriceFilter ? minimumPrice.value.toString() : "");
      clinicCont.priceMax(hasPriceFilter ? maximumPrice.value.toString() : "");
      clinicCont.governorateId.value = selectedGovernorateId.value;
      clinicCont.cityId.value = selectedCityId.value;
      applyFilterCount();
      Get.back(result: actualClinicFilterCount.value);
      clinicCont.page(1);
      clinicCont.getClinicList();
    } else if (type == 'category') {
      final serviceCont =
          serviceController ?? Get.find<ServiceListController>();
      serviceCont.clinicId(selectedClinicData.value.id);
      final hasPriceFilter = isPriceFilterApplied;
      serviceCont.priceMin(hasPriceFilter ? minimumPrice.value.toString() : "");
      serviceCont.priceMax(hasPriceFilter ? maximumPrice.value.toString() : "");
      serviceCont.governorateId.value = selectedGovernorateId.value;
      serviceCont.cityId.value = selectedCityId.value;
      applyFilterCount();
      serviceCont.refresh();
      Get.back(result: actualCategoryFilterCount.value);
      serviceCont.getServiceList();
    }
  }

  @override
  void onClose() {
    searchClinicStream.close();
    searchServiceStream.close();
    searchCategoryStream.close();
    searchClinicCont.dispose();
    searchServiceCont.dispose();
    searchCategoryCont.dispose();
    scrollServiceController.dispose();
    _scrollCategoryController.dispose();
    super.onClose();
  }
}
