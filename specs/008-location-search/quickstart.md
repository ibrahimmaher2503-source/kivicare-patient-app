# Quickstart: Location & Search

**Feature**: `008-location-search` | **Branch**: `008-location-search`

## Prerequisites

- Flutter 3.0+ / Dart 3.0+ installed
- Android emulator or physical device connected
- Backend at `https://espitalia.net/api/` accessible (search endpoints are public)

## Build & Run

```bash
git checkout 008-location-search
flutter pub get
flutter run
```

## Implementation Order

### Layer 1: Data (models + API methods)
1. Create `HomeHealthcareProvider` model at `lib/models/home_healthcare_provider_model.dart`
2. Extend `searchDoctors()` in `core_apis.dart` — add `specialtyId`, `gender`, `minPrice`, `maxPrice` params
3. Extend `searchClinics()` in `core_apis.dart` — add `specialtyId` param
4. Add `searchRadiology()` method to `core_apis.dart`
5. Add `searchHomeHealthcare()` method to `core_apis.dart`

### Layer 2: Locale strings
6. Add ~20 new string keys to `languages.dart` (abstract) and all 5 language files

### Layer 3: Controllers
7. Create 6 search controllers in `lib/screens/search/` following the nurse controller pattern:
   - `doctor_search_controller.dart`
   - `clinic_search_controller.dart`
   - `nurse_search_controller.dart`
   - `lab_search_controller.dart`
   - `radiology_search_controller.dart`
   - `home_healthcare_search_controller.dart`

### Layer 4: Screens
8. Create 6 search screens in `lib/screens/search/` following the nurse list screen pattern
9. Create `search_hub_screen.dart` — unified entry with cards for each type

### Layer 5: Integration
10. Add Search/Discover entry point to home screen (`quick_services_component.dart`)

## Key Patterns to Follow

**Controller template** (from nurse_list_controller.dart):
```dart
class XxxSearchController extends GetxController {
  Rx<Future<RxList<Model>>> itemsFuture = Future.value(RxList<Model>()).obs;
  RxList<Model> items = RxList<Model>();
  RxBool isLoading = false.obs;
  RxBool isLastPage = false.obs;
  RxInt page = 1.obs;
  TextEditingController searchCont = TextEditingController();
  RxString searchQuery = ''.obs;
  RxnInt selectedGovernorateId = RxnInt();
  RxnInt selectedCityId = RxnInt();

  @override
  void onInit() {
    super.onInit();
    debounce(searchQuery, (_) => getItems(), time: const Duration(milliseconds: 500));
    getItems();
  }

  Future<void> getItems({bool showLoader = true}) async {
    if (showLoader) isLoading(true);
    await itemsFuture(CoreServiceApis.searchXxx(
      page: page.value,
      perPage: 15,
      itemList: items,
      lastPageCallBack: (isLast) => isLastPage(isLast),
      // ... filters
    )).then((value) {}).catchError((e) {
      toast(e.toString());
    }).whenComplete(() => isLoading(false));
  }

  void onGovernorateChanged(int? id) {
    selectedGovernorateId.value = id;
    selectedCityId.value = null;
    page(1);
    getItems();
  }

  void onCityChanged(int? id) {
    selectedCityId.value = id;
    page(1);
    getItems();
  }

  void onSearchChanged(String val) => searchQuery.value = val;
}
```

**API method template** (from existing search methods):
```dart
static Future<RxList<Model>> searchXxx({
  int page = 1,
  int perPage = 15,
  required List<Model> itemList,
  Function(bool)? lastPageCallBack,
  // ... filter params
}) async {
  String queryParams = 'per_page=$perPage&page=$page';
  // ... append filter params

  final res = XxxListResponse.fromJson(await handleResponse(
    await buildHttpResponse('${APIEndPoints.xxxSearch}?$queryParams', method: HttpMethodType.GET),
  ));
  if (page == 1) itemList.clear();
  itemList.addAll(res.data);
  lastPageCallBack?.call(res.currentPage >= res.lastPage);
  return itemList.obs;
}
```

## Verification

After implementation, verify each search endpoint:
1. Open the app (no login required)
2. Navigate to Search Hub from home screen
3. For each provider type: select governorate → city → apply type-specific filter → verify results display with pagination
4. Switch language to Arabic → verify localized names
5. Apply filters that return 0 results → verify empty state
6. Disconnect network → verify error state with retry
