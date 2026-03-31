# Vizita Platform — Flutter Specification

> **Companion to**: Laravel Backend Specification (Governorates, Search Services, Localization)
> **Flutter Project**: Espitalia Patient App (v1.8.1+20)
> **Package**: `com.espitalia.patient`
> **Stack**: Flutter 3.0+ / Dart 3.0+ / GetX / nb_utils
> **Design System**: Clinical Elegance (navy + teal, glass effects, gradient accents)

---

## Table of Contents

1. [Global Rules](#global-rules)
2. [Phase 1 — Foundation (Governorates & Cities)](#phase-1--foundation-governorates--cities)
3. [Phase 2 — Doctors & Clinics (Extend Existing)](#phase-2--doctors--clinics-extend-existing)
4. [Phase 3 — Nurses (Extend Existing)](#phase-3--nurses-extend-existing)
5. [Phase 4 — Home Healthcare (New Module)](#phase-4--home-healthcare-new-module)
6. [Phase 5 — Lab Tests (Extend Existing)](#phase-5--lab-tests-extend-existing)
7. [Phase 6 — Radiology (New Module)](#phase-6--radiology-new-module)
8. [Cross-Cutting: Home Screen & Navigation](#cross-cutting-home-screen--navigation)
9. [Unified Patterns Reference](#unified-patterns-reference)

---

## Global Rules

- **State Management**: GetX (`.obs`, `Obx()`, `GetxController`)
- **HTTP Client**: `buildHttpResponse()` / `handleResponse()` from `lib/network/network_utils.dart`
- **Fonts**: Google Fonts — Plus Jakarta Sans (body) + Outfit (display/headings)
- **Styling**: nb_utils helpers (`primaryTextStyle()`, `boldTextStyle()`, `boxDecorationDefault()`)
- **Localization**: All user-facing strings via `locale.value.<key>` — add to ALL 5 language files (en, ar, de, fr, hi)
- **Accept-Language**: Send current app locale in request headers so backend returns locale-aware names
- **Models**: Safe fromJson with default values, type-checked parsing (`json["field"] is Type ? ... : default`)
- **Pagination**: `page`/`perPage` params, `lastPageCallBack` for end detection, clear list on page 1
- **Search**: 500ms debounce on text input, reset to page 1 on filter/search change
- **UI Scaffold**: `AppScaffoldNew` + `SnapHelperWidget` + `AnimatedScrollView`
- **Clinical Elegance**: 16px card radius, 12px input radius, navy shadows, glass borders, gradient accents
- **Null Safety**: All governorate_id and city_id filters are nullable (not required)
- **No raw queries**: All API calls through `buildHttpResponse()` with query params
- **Pattern consistency**: Every new module mirrors the existing nurse/lab test pattern exactly
- **Imports**: Dart imports are NOT transitive — every file must import `governorate_model.dart` and `city_model.dart` directly when referencing `Governorate` or `City` types
- **Controller cleanup**: All new controllers must implement `onClose()` to dispose `TextEditingController` instances

### Endpoint Strategy — NEW vs Existing

The Laravel backend introduces **NEW search endpoints** that are separate from the existing ones:

| Module | Existing Flutter Endpoint | New Backend Endpoint | Strategy |
|--------|--------------------------|---------------------|----------|
| Governorates | *(none)* | `GET /api/governorates` | New API method |
| Cities | *(none)* | `GET /api/cities?governorate_id=` | New API method |
| Doctors | `get-doctor-list` | `GET /api/doctors/search` | **New** API method for search (keep existing for other uses) |
| Clinics | `get-clinic-list` | `GET /api/clinics/search` | **New** API method for search (keep existing for other uses) |
| Nurses | `v1/nurses` | `GET /api/nurses/search` | **New** API method for search (keep existing for other uses) |
| Home Healthcare | *(none)* | `GET /api/home-healthcare/search` | New module entirely |
| Lab Tests | `v1/lab-tests` | `GET /api/labs/search` | **New** API method for search (keep existing for other uses) |
| Radiology | *(none)* | `GET /api/radiology/search` | New module entirely |

**For "Extend" modules (Doctors, Clinics, Nurses, Lab Tests):** Add NEW endpoint constants and NEW API methods that call the new search endpoints. The existing API methods remain untouched for backward compatibility. List screens switch to using the new search methods.

**For "New" modules (Home Healthcare, Radiology):** Only the new endpoints. Detail and CRUD endpoints (e.g., `home-healthcare/{id}`, `home-healthcare-requests`) should be confirmed with the backend team — they are assumed to exist but not explicitly listed in the backend search spec.

---

## Phase 1 — Foundation (Governorates & Cities)

### New Files

```
lib/models/governorate_model.dart
lib/models/city_model.dart
lib/components/governorates_city_picker.dart
```

### Modified Files

```
lib/utils/api_end_points.dart          # Add endpoint constants
lib/api/core_apis.dart                 # Add API methods
lib/network/network_utils.dart         # Add Accept-Language header
lib/locale/languages.dart              # Add abstract string keys
lib/locale/language_en.dart            # English translations
lib/locale/language_ar.dart            # Arabic translations
lib/locale/language_de.dart            # German translations
lib/locale/language_fr.dart            # French translations
lib/locale/language_hi.dart            # Hindi translations
```

---

### Models

**`lib/models/governorate_model.dart`**

```dart
class GovernorateListResponse {
  bool status;
  List<Governorate> data;

  GovernorateListResponse({ this.status = false, this.data = const [] });

  factory GovernorateListResponse.fromJson(Map<String, dynamic> json) {
    // Backend unified format: { status, data: { items: [...] } }
    // But governorates may also return flat list: { status, data: [...] }
    // Handle both formats defensively:
    List<dynamic> items = [];
    if (json['data'] is Map && json['data']['items'] is List) {
      items = json['data']['items'];
    } else if (json['data'] is List) {
      items = json['data'];
    }

    return GovernorateListResponse(
      status: json['status'] is bool ? json['status'] : false,
      data: items.map((e) => Governorate.fromJson(e)).toList(),
    );
  }
}

class Governorate {
  int id;
  String name;

  Governorate({ this.id = -1, this.name = '' });

  factory Governorate.fromJson(Map<String, dynamic> json) {
    return Governorate(
      id: json['id'] is int ? json['id'] : -1,
      name: json['name'] is String ? json['name'] : '',
    );
  }

  Map<String, dynamic> toJson() => { 'id': id, 'name': name };
}
```

**`lib/models/city_model.dart`**

```dart
class CityListResponse {
  bool status;
  List<City> data;

  CityListResponse({ this.status = false, this.data = const [] });

  factory CityListResponse.fromJson(Map<String, dynamic> json) {
    // Handle both unified format { data: { items: [...] } } and flat { data: [...] }
    List<dynamic> items = [];
    if (json['data'] is Map && json['data']['items'] is List) {
      items = json['data']['items'];
    } else if (json['data'] is List) {
      items = json['data'];
    }

    return CityListResponse(
      status: json['status'] is bool ? json['status'] : false,
      data: items.map((e) => City.fromJson(e)).toList(),
    );
  }
}

class City {
  int id;
  String name;
  int governorateId;

  City({ this.id = -1, this.name = '', this.governorateId = -1 });

  factory City.fromJson(Map<String, dynamic> json) {
    return City(
      id: json['id'] is int ? json['id'] : -1,
      name: json['name'] is String ? json['name'] : '',
      governorateId: json['governorate_id'] is int ? json['governorate_id'] : -1,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'governorate_id': governorateId,
  };
}
```

---

### API Endpoints

**Add to `lib/utils/api_end_points.dart`:**

```dart
// Governorates & Cities (new backend endpoints)
static const String governorates = 'governorates';
static const String cities = 'cities'; // ?governorate_id=

// New search endpoints (separate from existing list endpoints)
static const String doctorsSearch = 'doctors/search';
static const String clinicsSearch = 'clinics/search';
static const String nursesSearch = 'nurses/search';
static const String labsSearch = 'labs/search';
```

---

### API Service Methods

**Add to `lib/api/core_apis.dart`:**

```dart
/// Fetch all governorates (no pagination — 27 items max)
static Future<List<Governorate>> getGovernorates() async {
  final res = GovernorateListResponse.fromJson(await handleResponse(
    await buildHttpResponse(APIEndPoints.governorates, method: HttpMethodType.GET),
  ));
  return res.data;
}

/// Fetch cities for a governorate (no pagination — ~50 items max)
static Future<List<City>> getCities({required int governorateId}) async {
  final res = CityListResponse.fromJson(await handleResponse(
    await buildHttpResponse(
      '${APIEndPoints.cities}?governorate_id=$governorateId',
      method: HttpMethodType.GET,
    ),
  ));
  return res.data;
}
```

---

### Accept-Language Header

**Modify `lib/network/network_utils.dart` — `buildHeaderTokens()`:**

The codebase already sends `'global-localization': selectedLanguageCode.value` in headers. Add `Accept-Language` **in addition** to the existing header so the new backend endpoints can read it:

```dart
// Inside buildHeaderTokens() — ADD alongside existing 'global-localization' header
headers['Accept-Language'] = selectedLanguageCode.value; // 'ar' or 'en'
```

**Note**: `selectedLanguageCode` is a top-level reactive variable (NOT `appStore.selectedLanguageCode` which does not exist). If `selectedLanguageCode` is not accessible in the network utils file, use:
```dart
headers['Accept-Language'] = Get.locale?.languageCode ?? 'en';
```

---

### Shared Widget: GovernoratesCityPicker

**`lib/components/governorates_city_picker.dart`**

A reusable cascading dropdown component used across all search/filter screens.

**Props:**
```dart
class GovernoratesCityPicker extends StatefulWidget {
  final int? selectedGovernorateId;
  final int? selectedCityId;
  final void Function(int? governorateId) onGovernorateChanged;
  final void Function(int? cityId) onCityChanged;
  final EdgeInsetsGeometry? padding;
}
```

**Behavior:**
- On init: fetch governorates once, cache in a reactive global (`RxList<Governorate>`)
- Governorate dropdown: shows "All" (null) + all 27 governorates
- When governorate changes: fetch cities for that governorate, reset city to null
- City dropdown: shows "All" (null) + cities for selected governorate
- City dropdown disabled when no governorate selected
- Loading shimmer while fetching

**Caching Strategy:**
- Governorates fetched once per app session, stored in a global `RxList<Governorate>` (e.g., in `common_base.dart` or a dedicated location service)
- Cities cached per governorate_id in a `Map<int, List<City>>` to avoid re-fetching

**Clinical Elegance Styling:**
```
- Container: glass-bordered (glassStrokeLight/Dark, 1px), surfaceSubtle background, 12px radius
- Dropdowns: inputFillColor background, 12px radius, Plus Jakarta Sans text
- Dropdown icons: gradient-masked (appColorPrimary -> appColorSecondary)
- Labels: secondaryTextStyle() with "Governorate" / "City" text
- Layout: Row with two Expanded dropdowns, 12px gap between them
- Dark mode: inputFillColorDark background, glassStrokeDark border
- Padding: 16px all sides inside the container
```

**Dropdown Item Styling:**
```
- Text: primaryTextStyle() size 14
- Selected item: appColorPrimary text color
- "All" option: slightly dimmed (secondaryTextStyle)
```

---

### Locale Strings

**Add to `lib/locale/languages.dart` (abstract keys):**
```dart
String get governorate;
String get city;
String get allGovernorates;
String get allCities;
String get selectGovernorate;
String get selectCity;
String get locationFilter;
```

**Add to `lib/locale/language_en.dart`:**
```dart
@override String get governorate => 'Governorate';
@override String get city => 'City';
@override String get allGovernorates => 'All Governorates';
@override String get allCities => 'All Cities';
@override String get selectGovernorate => 'Select Governorate';
@override String get selectCity => 'Select City';
@override String get locationFilter => 'Location';
```

**Add to `lib/locale/language_ar.dart`:**
```dart
@override String get governorate => 'المحافظة';
@override String get city => 'المدينة';
@override String get allGovernorates => 'كل المحافظات';
@override String get allCities => 'كل المدن';
@override String get selectGovernorate => 'اختر المحافظة';
@override String get selectCity => 'اختر المدينة';
@override String get locationFilter => 'الموقع';
```

**Add to `lib/locale/language_de.dart`:**
```dart
@override String get governorate => 'Gouvernement';
@override String get city => 'Stadt';
@override String get allGovernorates => 'Alle Gouvernements';
@override String get allCities => 'Alle Städte';
@override String get selectGovernorate => 'Gouvernement wählen';
@override String get selectCity => 'Stadt wählen';
@override String get locationFilter => 'Standort';
```

**Add to `lib/locale/language_fr.dart`:**
```dart
@override String get governorate => 'Gouvernorat';
@override String get city => 'Ville';
@override String get allGovernorates => 'Tous les gouvernorats';
@override String get allCities => 'Toutes les villes';
@override String get selectGovernorate => 'Sélectionner le gouvernorat';
@override String get selectCity => 'Sélectionner la ville';
@override String get locationFilter => 'Emplacement';
```

**Add to `lib/locale/language_hi.dart`:**
```dart
@override String get governorate => 'प्रांत';
@override String get city => 'शहर';
@override String get allGovernorates => 'सभी प्रांत';
@override String get allCities => 'सभी शहर';
@override String get selectGovernorate => 'प्रांत चुनें';
@override String get selectCity => 'शहर चुनें';
@override String get locationFilter => 'स्थान';
```

---

## Phase 2 — Doctors & Clinics (Extend Existing)

### Modified Files

```
lib/screens/doctor/                     # Doctor list controller + screen
lib/screens/clinic/                     # Clinic list controller + screen
lib/screens/booking/filter/             # Existing filter components
lib/api/core_apis.dart                  # Add governorate/city params to existing calls
lib/locale/language_*.dart              # Add locale strings (if needed)
```

---

### Doctor Search — Controller Changes

**Modify existing doctor list controller:**

Add reactive location filter vars:
```dart
RxnInt selectedGovernorateId = RxnInt();
RxnInt selectedCityId = RxnInt();
```

Update the doctor fetch method to pass location params:
```dart
// Add to existing API call query params:
String govParam = selectedGovernorateId.value != null
    ? '&governorate_id=${selectedGovernorateId.value}'
    : '';
String cityParam = selectedCityId.value != null
    ? '&city_id=${selectedCityId.value}'
    : '';
```

Reset page to 1 when location changes:
```dart
void onGovernorateChanged(int? id) {
  selectedGovernorateId.value = id;
  selectedCityId.value = null; // Reset city when governorate changes
  page(1);
  fetchDoctors();
}

void onCityChanged(int? id) {
  selectedCityId.value = id;
  page(1);
  fetchDoctors();
}
```

---

### Doctor Search — API Update

**Add NEW method to `core_apis.dart`** (keep existing `getDoctorList()` unchanged):

```dart
/// New search method using the new backend search endpoint
static Future<RxList<Doctor>> searchDoctors({
  int page = 1,
  int perPage = 20,
  required List<Doctor> doctorList,
  Function(bool)? lastPageCallBack,
  String name = '',
  int? governorateId,
  int? cityId,
  int? specialtyId,
  String gender = '',
  double? minPrice,
  double? maxPrice,
}) async {
  String nameParam = name.isNotEmpty ? '&name=${Uri.encodeQueryComponent(name)}' : '';
  String govParam = governorateId != null ? '&governorate_id=$governorateId' : '';
  String cityParam = cityId != null ? '&city_id=$cityId' : '';
  String specParam = specialtyId != null ? '&specialty_id=$specialtyId' : '';
  String genderParam = gender.isNotEmpty ? '&gender=${Uri.encodeQueryComponent(gender)}' : '';
  String minPriceParam = minPrice != null ? '&min_price=$minPrice' : '';
  String maxPriceParam = maxPrice != null ? '&max_price=$maxPrice' : '';

  // Uses NEW endpoint: doctors/search (not existing get-doctor-list)
  final res = DoctorListResponse.fromJson(await handleResponse(
    await buildHttpResponse(
      '${APIEndPoints.doctorsSearch}?per_page=$perPage&page=$page$nameParam$govParam$cityParam$specParam$genderParam$minPriceParam$maxPriceParam',
      method: HttpMethodType.GET,
    ),
  ));

  if (page == 1) doctorList.clear();
  doctorList.addAll(res.data);
  lastPageCallBack?.call(res.currentPage >= res.lastPage);

  return doctorList.obs;
}
```

**API endpoint consumed:**
```
GET /api/doctors/search?governorate_id=&city_id=&specialty_id=&name=&gender=&min_price=&max_price=
```

---

### Doctor Search — Model Update

**Add to existing Doctor model:**

```dart
Governorate? governorate;
City? city;
```

In `fromJson()`:
```dart
governorate: json['governorate'] is Map
    ? Governorate.fromJson(json['governorate'])
    : null,
city: json['city'] is Map
    ? City.fromJson(json['city'])
    : null,
```

---

### Doctor Search — Screen Update

**Add `GovernoratesCityPicker` to the doctor list/search screen:**

Position: Between search bar and existing filter chips (specialty, gender, price).

```dart
GovernoratesCityPicker(
  selectedGovernorateId: controller.selectedGovernorateId.value,
  selectedCityId: controller.selectedCityId.value,
  onGovernorateChanged: controller.onGovernorateChanged,
  onCityChanged: controller.onCityChanged,
),
```

Wrapped in a collapsible filter section:
```
- Container: glass border (glassStrokeLight), surfaceSubtle background, 12px radius
- Collapse toggle: "Location" label with chevron icon
- Padding: 12px inside
```

---

### Doctor Card — Location Badge

**Add location display to existing doctor card:**

```dart
// Below name/specialty, show location if available
if (doctor.governorate != null)
  Container(
    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: appColorSecondary.withOpacity(0.1),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Text(
      [doctor.governorate?.name, doctor.city?.name]
          .where((e) => e != null && e.isNotEmpty)
          .join(' - '),
      style: secondaryTextStyle(size: 11, color: appColorSecondary),
    ),
  ),
```

---

### Clinic Search — Same Pattern

Apply identical changes to clinic module:

**Controller:** Add `selectedGovernorateId`, `selectedCityId` reactive vars, pass to NEW `searchClinics()` API call.

**API:** Add NEW `searchClinics()` method in `core_apis.dart` (keep existing `getClinicList()` unchanged). Uses `APIEndPoints.clinicsSearch`. Same pattern as `searchDoctors()`.
```
GET /api/clinics/search?governorate_id=&city_id=&specialty_id=&name=
```

**Model:** Add optional `governorate` and `city` nested objects to Clinic model.

**Screen:** Add `GovernoratesCityPicker` to clinic list/search screen.

**Card:** Add location pill badge to clinic card (same styling as doctor card).

---

### Filter State Preservation

When navigating from list screen to detail screen and pressing back, filter state should be preserved:
- Use `Get.put()` with tag or permanent controller to persist across navigation
- Or pass filter state via `Get.arguments` on return

---

## Phase 3 — Nurses (Extend Existing)

### Modified Files

```
lib/screens/nurse/nurse_list_controller.dart
lib/screens/nurse/nurse_list_screen.dart
lib/screens/nurse/model/nurse_model.dart
lib/screens/nurse/components/nurse_card.dart
lib/api/core_apis.dart
```

---

### Controller Changes (`nurse_list_controller.dart`)

Add reactive location filter vars:
```dart
RxnInt selectedGovernorateId = RxnInt();
RxnInt selectedCityId = RxnInt();
```

Add location change handlers:
```dart
void onGovernorateChanged(int? id) {
  selectedGovernorateId.value = id;
  selectedCityId.value = null;
  page(1);
  getNurses();
}

void onCityChanged(int? id) {
  selectedCityId.value = id;
  page(1);
  getNurses();
}
```

Update `getNurses()` to call the NEW `searchNurses()` method:
```dart
await nurseFuture(
  CoreServiceApis.searchNurses(    // NEW method (not getNurseList)
    page: page.value,
    perPage: Constants.perPageItem,
    nurseList: nurses,
    search: searchCont.text.trim(),
    availability: selectedAvailability.value,
    governorateId: selectedGovernorateId.value,    // NEW
    cityId: selectedCityId.value,                   // NEW
    lastPageCallBack: (isLast) => isLastPage(isLast),
  ),
);
```

---

### API Call Update (`core_apis.dart`)

Add NEW `searchNurses()` method (keep existing `getNurseList()` unchanged for backward compatibility):
```dart
static Future<RxList<Nurse>> searchNurses({
  int page = 1,
  int perPage = 20,
  required List<Nurse> nurseList,
  Function(bool)? lastPageCallBack,
  String search = '',
  int? governorateId,
  int? cityId,
  String specialty = '',
  String gender = '',
  String availability = '',
}) async {
  String searchParam = search.isNotEmpty ? '&search=${Uri.encodeQueryComponent(search)}' : '';
  String govParam = governorateId != null ? '&governorate_id=$governorateId' : '';
  String cityParam = cityId != null ? '&city_id=$cityId' : '';
  String specParam = specialty.isNotEmpty ? '&specialty=${Uri.encodeQueryComponent(specialty)}' : '';
  String genderParam = gender.isNotEmpty ? '&gender=${Uri.encodeQueryComponent(gender)}' : '';
  String availParam = availability.isNotEmpty ? '&availability=${Uri.encodeQueryComponent(availability)}' : '';

  // Uses NEW endpoint: APIEndPoints.nursesSearch (not existing v1/nurses)
  final res = NurseListResponse.fromJson(await handleResponse(
    await buildHttpResponse(
      '${APIEndPoints.nursesSearch}?per_page=$perPage&page=$page$searchParam$govParam$cityParam$specParam$genderParam$availParam',
      method: HttpMethodType.GET,
    ),
  ));

  if (page == 1) nurseList.clear();
  nurseList.addAll(res.data);
  lastPageCallBack?.call(res.currentPage >= res.lastPage);

  return nurseList.obs;
}
```

**API endpoint consumed:**
```
GET /api/nurses/search?governorate_id=&city_id=&specialty=&gender=&availability=
```

---

### Model Update (`nurse_model.dart`)

Add to Nurse class:
```dart
Governorate? governorate;
City? city;
```

In `fromJson()`:
```dart
governorate: json['governorate'] is Map
    ? Governorate.fromJson(json['governorate'])
    : null,
city: json['city'] is Map
    ? City.fromJson(json['city'])
    : null,
```

---

### Screen Update (`nurse_list_screen.dart`)

Insert `GovernoratesCityPicker` between the premium search bar and existing availability filter chips:

```dart
// After search bar, before filter chips
GovernoratesCityPicker(
  selectedGovernorateId: controller.selectedGovernorateId.value,
  selectedCityId: controller.selectedCityId.value,
  onGovernorateChanged: controller.onGovernorateChanged,
  onCityChanged: controller.onCityChanged,
),
SizedBox(height: 12),
// Existing availability filter chips...
```

Wrapped in same collapsible glass-bordered filter section as Phase 2.

---

### Card Update (`nurse_card.dart`)

Add location pill below name/specialization:
```dart
if (nurse.governorate != null)
  Container(
    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: appColorSecondary.withOpacity(0.1),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Text(
      [nurse.governorate?.name, nurse.city?.name]
          .where((e) => e != null && e.isNotEmpty)
          .join(' - '),
      style: secondaryTextStyle(size: 11, color: appColorSecondary),
    ),
  ),
```

Same pill styling as doctor/clinic cards for visual consistency.

---

## Phase 4 — Home Healthcare (New Module)

### New Directory Structure

```
lib/screens/home_healthcare/
├── home_healthcare_list_controller.dart
├── home_healthcare_list_screen.dart
├── home_healthcare_detail_screen.dart
├── create_home_healthcare_request_controller.dart
├── create_home_healthcare_request_screen.dart
├── home_healthcare_request_list_controller.dart
├── home_healthcare_request_list_screen.dart
├── home_healthcare_request_detail_screen.dart
├── model/
│   ├── home_healthcare_model.dart
│   └── home_healthcare_request_model.dart
└── components/
    ├── home_healthcare_card.dart
    └── home_healthcare_request_card.dart
```

### Modified Files

```
lib/utils/api_end_points.dart
lib/api/core_apis.dart
lib/utils/constants.dart
lib/utils/colors.dart                  # Status colors if needed
lib/locale/languages.dart
lib/locale/language_en.dart
lib/locale/language_ar.dart
lib/locale/language_de.dart
lib/locale/language_fr.dart
lib/locale/language_hi.dart
```

---

### Models

**`lib/screens/home_healthcare/model/home_healthcare_model.dart`**

```dart
class HomeHealthcareListResponse {
  bool status;
  List<HomeHealthcare> data;
  int currentPage;
  int lastPage;
  int perPage;
  int total;

  HomeHealthcareListResponse({
    this.status = false,
    this.data = const [],
    this.currentPage = 1,
    this.lastPage = 1,
    this.perPage = 15,
    this.total = 0,
  });

  factory HomeHealthcareListResponse.fromJson(Map<String, dynamic> json) {
    return HomeHealthcareListResponse(
      status: json['status'] is bool ? json['status'] : false,
      data: json['data'] is Map && json['data']['items'] is List
          ? (json['data']['items'] as List)
              .map((e) => HomeHealthcare.fromJson(e))
              .toList()
          : [],
      currentPage: json['data'] is Map && json['data']['pagination'] is Map
          ? json['data']['pagination']['current_page'] ?? 1
          : 1,
      lastPage: json['data'] is Map && json['data']['pagination'] is Map
          ? json['data']['pagination']['last_page'] ?? 1
          : 1,
      perPage: json['data'] is Map && json['data']['pagination'] is Map
          ? json['data']['pagination']['per_page'] ?? 15
          : 15,
      total: json['data'] is Map && json['data']['pagination'] is Map
          ? json['data']['pagination']['total'] ?? 0
          : 0,
    );
  }
}

class HomeHealthcare {
  int id;
  String name;
  String description;
  String serviceType;
  String coverageArea;
  String contactNumber;
  String email;
  String profileImage;
  String status;
  double rating;
  String operatingHours;
  String pricing;
  List<HomeHealthcareService> services;
  Governorate? governorate;
  City? city;
  String createdAt;
  String updatedAt;

  HomeHealthcare({
    this.id = -1,
    this.name = '',
    this.description = '',
    this.serviceType = '',
    this.coverageArea = '',
    this.contactNumber = '',
    this.email = '',
    this.profileImage = '',
    this.status = '',
    this.rating = 0.0,
    this.operatingHours = '',
    this.pricing = '',
    this.services = const [],
    this.governorate,
    this.city,
    this.createdAt = '',
    this.updatedAt = '',
  });

  factory HomeHealthcare.fromJson(Map<String, dynamic> json) {
    return HomeHealthcare(
      id: json['id'] is int ? json['id'] : -1,
      name: json['name'] is String ? json['name'] : '',
      description: json['description'] is String ? json['description'] : '',
      serviceType: json['service_type'] is String ? json['service_type'] : '',
      coverageArea: json['coverage_area'] is String ? json['coverage_area'] : '',
      contactNumber: json['contact_number'] is String ? json['contact_number'] : '',
      email: json['email'] is String ? json['email'] : '',
      profileImage: json['profile_image'] is String ? json['profile_image'] : '',
      status: json['status'] is String ? json['status'] : '',
      rating: json['rating'] is num ? json['rating'].toDouble() : 0.0,
      operatingHours: json['operating_hours'] is String ? json['operating_hours'] : '',
      pricing: json['pricing'] is String ? json['pricing'] : '',
      services: json['services'] is List
          ? (json['services'] as List).map((e) => HomeHealthcareService.fromJson(e)).toList()
          : [],
      governorate: json['governorate'] is Map
          ? Governorate.fromJson(json['governorate'])
          : null,
      city: json['city'] is Map ? City.fromJson(json['city']) : null,
      createdAt: json['created_at'] is String ? json['created_at'] : '',
      updatedAt: json['updated_at'] is String ? json['updated_at'] : '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'service_type': serviceType,
    'coverage_area': coverageArea,
    'contact_number': contactNumber,
    'email': email,
    'profile_image': profileImage,
    'status': status,
    'rating': rating,
    'operating_hours': operatingHours,
    'pricing': pricing,
  };
}

class HomeHealthcareService {
  int id;
  String name;
  String description;
  double price;

  HomeHealthcareService({
    this.id = -1,
    this.name = '',
    this.description = '',
    this.price = 0.0,
  });

  factory HomeHealthcareService.fromJson(Map<String, dynamic> json) {
    return HomeHealthcareService(
      id: json['id'] is int ? json['id'] : -1,
      name: json['name'] is String ? json['name'] : '',
      description: json['description'] is String ? json['description'] : '',
      price: json['price'] is num ? json['price'].toDouble() : 0.0,
    );
  }
}
```

**`lib/screens/home_healthcare/model/home_healthcare_request_model.dart`**

```dart
class HomeHealthcareRequestListResponse {
  bool status;
  List<HomeHealthcareRequest> data;
  int currentPage;
  int lastPage;
  int perPage;
  int total;

  HomeHealthcareRequestListResponse({
    this.status = false,
    this.data = const [],
    this.currentPage = 1,
    this.lastPage = 1,
    this.perPage = 15,
    this.total = 0,
  });

  factory HomeHealthcareRequestListResponse.fromJson(Map<String, dynamic> json) {
    return HomeHealthcareRequestListResponse(
      status: json['status'] is bool ? json['status'] : false,
      data: json['data'] is Map && json['data']['items'] is List
          ? (json['data']['items'] as List)
              .map((e) => HomeHealthcareRequest.fromJson(e))
              .toList()
          : [],
      currentPage: json['data'] is Map && json['data']['pagination'] is Map
          ? json['data']['pagination']['current_page'] ?? 1
          : 1,
      lastPage: json['data'] is Map && json['data']['pagination'] is Map
          ? json['data']['pagination']['last_page'] ?? 1
          : 1,
      perPage: json['data'] is Map && json['data']['pagination'] is Map
          ? json['data']['pagination']['per_page'] ?? 15
          : 15,
      total: json['data'] is Map && json['data']['pagination'] is Map
          ? json['data']['pagination']['total'] ?? 0
          : 0,
    );
  }
}

class HomeHealthcareRequest {
  int id;
  int patientId;
  int homeHealthcareId;
  String serviceType;
  String serviceDescription;
  String requestDate;
  String preferredDate;
  String preferredTime;
  HomeHealthcareRequestAddress? address;
  String contactNumber;
  String patientNotes;
  String adminNotes;
  String status;        // pending, confirmed, in_progress, completed, cancelled
  String paymentStatus;
  double totalAmount;
  String cancelledBy;
  String cancellationReason;
  HomeHealthcareRequestProvider? homeHealthcare;
  HomeHealthcareRequestPatient? patient;
  String createdAt;
  String updatedAt;

  HomeHealthcareRequest({
    this.id = -1,
    this.patientId = -1,
    this.homeHealthcareId = -1,
    this.serviceType = '',
    this.serviceDescription = '',
    this.requestDate = '',
    this.preferredDate = '',
    this.preferredTime = '',
    this.address,
    this.contactNumber = '',
    this.patientNotes = '',
    this.adminNotes = '',
    this.status = '',
    this.paymentStatus = '',
    this.totalAmount = 0.0,
    this.cancelledBy = '',
    this.cancellationReason = '',
    this.homeHealthcare,
    this.patient,
    this.createdAt = '',
    this.updatedAt = '',
  });

  factory HomeHealthcareRequest.fromJson(Map<String, dynamic> json) {
    return HomeHealthcareRequest(
      id: json['id'] is int ? json['id'] : -1,
      patientId: json['patient_id'] is int ? json['patient_id'] : -1,
      homeHealthcareId: json['home_healthcare_id'] is int ? json['home_healthcare_id'] : -1,
      serviceType: json['service_type'] is String ? json['service_type'] : '',
      serviceDescription: json['service_description'] is String ? json['service_description'] : '',
      requestDate: json['request_date'] is String ? json['request_date'] : '',
      preferredDate: json['preferred_date'] is String ? json['preferred_date'] : '',
      preferredTime: json['preferred_time'] is String ? json['preferred_time'] : '',
      address: json['address'] is Map
          ? HomeHealthcareRequestAddress.fromJson(json['address'])
          : null,
      contactNumber: json['contact_number'] is String ? json['contact_number'] : '',
      patientNotes: json['patient_notes'] is String ? json['patient_notes'] : '',
      adminNotes: json['admin_notes'] is String ? json['admin_notes'] : '',
      status: json['status'] is String ? json['status'] : '',
      paymentStatus: json['payment_status'] is String ? json['payment_status'] : '',
      totalAmount: json['total_amount'] is num ? json['total_amount'].toDouble() : 0.0,
      cancelledBy: json['cancelled_by'] is String ? json['cancelled_by'] : '',
      cancellationReason: json['cancellation_reason'] is String ? json['cancellation_reason'] : '',
      homeHealthcare: json['home_healthcare'] is Map
          ? HomeHealthcareRequestProvider.fromJson(json['home_healthcare'])
          : null,
      patient: json['patient'] is Map
          ? HomeHealthcareRequestPatient.fromJson(json['patient'])
          : null,
      createdAt: json['created_at'] is String ? json['created_at'] : '',
      updatedAt: json['updated_at'] is String ? json['updated_at'] : '',
    );
  }

  Map<String, dynamic> toJson() => {
    'home_healthcare_id': homeHealthcareId,
    'service_type': serviceType,
    'service_description': serviceDescription,
    'preferred_date': preferredDate,
    'preferred_time': preferredTime,
    'contact_number': contactNumber,
    'patient_notes': patientNotes,
  };
}

class HomeHealthcareRequestAddress {
  String addressLine1;
  String addressLine2;
  String city;
  String state;
  String country;
  String postalCode;
  double? latitude;
  double? longitude;

  HomeHealthcareRequestAddress({
    this.addressLine1 = '',
    this.addressLine2 = '',
    this.city = '',
    this.state = '',
    this.country = '',
    this.postalCode = '',
    this.latitude,
    this.longitude,
  });

  factory HomeHealthcareRequestAddress.fromJson(Map<String, dynamic> json) {
    return HomeHealthcareRequestAddress(
      addressLine1: json['address_line_1'] is String ? json['address_line_1'] : '',
      addressLine2: json['address_line_2'] is String ? json['address_line_2'] : '',
      city: json['city'] is String ? json['city'] : '',
      state: json['state'] is String ? json['state'] : '',
      country: json['country'] is String ? json['country'] : '',
      postalCode: json['postal_code'] is String ? json['postal_code'] : '',
      latitude: json['latitude'] is num ? json['latitude'].toDouble() : null,
      longitude: json['longitude'] is num ? json['longitude'].toDouble() : null,
    );
  }
}

class HomeHealthcareRequestProvider {
  int id;
  String name;
  String serviceType;
  String profileImage;

  HomeHealthcareRequestProvider({
    this.id = -1,
    this.name = '',
    this.serviceType = '',
    this.profileImage = '',
  });

  factory HomeHealthcareRequestProvider.fromJson(Map<String, dynamic> json) {
    return HomeHealthcareRequestProvider(
      id: json['id'] is int ? json['id'] : -1,
      name: json['name'] is String ? json['name'] : '',
      serviceType: json['service_type'] is String ? json['service_type'] : '',
      profileImage: json['profile_image'] is String ? json['profile_image'] : '',
    );
  }
}

class HomeHealthcareRequestPatient {
  int id;
  String name;
  String email;
  String mobile;

  HomeHealthcareRequestPatient({
    this.id = -1,
    this.name = '',
    this.email = '',
    this.mobile = '',
  });

  factory HomeHealthcareRequestPatient.fromJson(Map<String, dynamic> json) {
    return HomeHealthcareRequestPatient(
      id: json['id'] is int ? json['id'] : -1,
      name: json['name'] is String ? json['name'] : '',
      email: json['email'] is String ? json['email'] : '',
      mobile: json['mobile'] is String ? json['mobile'] : '',
    );
  }
}
```

---

### API Endpoints

**Add to `lib/utils/api_end_points.dart`:**

```dart
// Home Healthcare
static const String homeHealthcareSearch = 'home-healthcare/search';
static const String homeHealthcareDetail = 'home-healthcare';                    // append /{id}
static const String homeHealthcareRequests = 'v1/home-healthcare-requests';
static const String homeHealthcareRequestDetail = 'v1/home-healthcare-requests'; // append /{id}
static const String homeHealthcareRequestCancel = 'v1/home-healthcare-requests'; // append /{id}/cancel
```

---

### API Service Methods

**Add to `lib/api/core_apis.dart`:**

```dart
// ==================== Home Healthcare ====================

/// Fetch paginated home healthcare providers with filters
static Future<RxList<HomeHealthcare>> getHomeHealthcareList({
  int page = 1,
  int perPage = 20,
  required List<HomeHealthcare> homeHealthcareList,
  Function(bool)? lastPageCallBack,
  String search = '',
  int? governorateId,
  int? cityId,
  String serviceType = '',
}) async {
  String searchParam = search.isNotEmpty
      ? '&search=${Uri.encodeQueryComponent(search)}'
      : '';
  String govParam = governorateId != null ? '&governorate_id=$governorateId' : '';
  String cityParam = cityId != null ? '&city_id=$cityId' : '';
  String serviceParam = serviceType.isNotEmpty
      ? '&service_type=${Uri.encodeQueryComponent(serviceType)}'
      : '';

  final res = HomeHealthcareListResponse.fromJson(await handleResponse(
    await buildHttpResponse(
      '${APIEndPoints.homeHealthcareSearch}?per_page=$perPage&page=$page$searchParam$govParam$cityParam$serviceParam',
      method: HttpMethodType.GET,
    ),
  ));

  if (page == 1) homeHealthcareList.clear();
  homeHealthcareList.addAll(res.data);
  lastPageCallBack?.call(res.currentPage >= res.lastPage);

  return homeHealthcareList.obs;
}

/// Fetch single home healthcare provider detail
static Future<HomeHealthcare> getHomeHealthcareDetail({required int id}) async {
  final res = await handleResponse(
    await buildHttpResponse(
      '${APIEndPoints.homeHealthcareDetail}/$id',
      method: HttpMethodType.GET,
    ),
  );
  return HomeHealthcare.fromJson(res['data']);
}

/// Fetch paginated home healthcare requests
static Future<RxList<HomeHealthcareRequest>> getHomeHealthcareRequestList({
  int page = 1,
  int perPage = 20,
  required List<HomeHealthcareRequest> requestList,
  Function(bool)? lastPageCallBack,
  String status = '',
}) async {
  String statusParam = status.isNotEmpty
      ? '&status=${Uri.encodeQueryComponent(status)}'
      : '';

  final res = HomeHealthcareRequestListResponse.fromJson(await handleResponse(
    await buildHttpResponse(
      '${APIEndPoints.homeHealthcareRequests}?per_page=$perPage&page=$page$statusParam',
      method: HttpMethodType.GET,
    ),
  ));

  if (page == 1) requestList.clear();
  requestList.addAll(res.data);
  lastPageCallBack?.call(res.currentPage >= res.lastPage);

  return requestList.obs;
}

/// Create a home healthcare request
static Future<void> createHomeHealthcareRequest({required Map request}) async {
  await handleResponse(
    await buildHttpResponse(
      APIEndPoints.homeHealthcareRequests,
      method: HttpMethodType.POST,
      request: request,
    ),
  );
}

/// Fetch single home healthcare request detail
static Future<HomeHealthcareRequest> getHomeHealthcareRequestDetail({required int id}) async {
  final res = await handleResponse(
    await buildHttpResponse(
      '${APIEndPoints.homeHealthcareRequestDetail}/$id',
      method: HttpMethodType.GET,
    ),
  );
  return HomeHealthcareRequest.fromJson(res['data']);
}

/// Cancel a home healthcare request
static Future<void> cancelHomeHealthcareRequest({required int id}) async {
  await handleResponse(
    await buildHttpResponse(
      '${APIEndPoints.homeHealthcareRequestCancel}/$id/cancel',
      method: HttpMethodType.POST,  // POST matches existing nurse request cancel pattern
    ),
  );
}
```

---

### Controllers

**`lib/screens/home_healthcare/home_healthcare_list_controller.dart`**

Mirrors `NurseListController` pattern:

```dart
class HomeHealthcareListController extends GetxController {
  // List state
  Rx<Future<RxList<HomeHealthcare>>> homeHealthcareFuture = Future(() => RxList<HomeHealthcare>()).obs;
  RxList<HomeHealthcare> homeHealthcares = RxList<HomeHealthcare>();
  RxBool isLoading = false.obs;
  RxBool isLastPage = false.obs;
  RxInt page = 1.obs;

  // Search
  TextEditingController searchCont = TextEditingController();
  RxString searchQuery = ''.obs;

  // Location filter
  RxnInt selectedGovernorateId = RxnInt();
  RxnInt selectedCityId = RxnInt();

  // Service type filter
  RxString selectedServiceType = ''.obs;
  RxList<Map<String, String>> serviceTypeFilters = RxList();

  @override
  void onInit() {
    serviceTypeFilters = [
      {'key': '', 'label': locale.value.all},
      {'key': 'nursing', 'label': locale.value.nursing},
      {'key': 'physiotherapy', 'label': locale.value.physiotherapy},
      {'key': 'elderly_care', 'label': locale.value.elderlyCare},
      {'key': 'post_surgery', 'label': locale.value.postSurgeryCare},
    ].obs;

    getHomeHealthcares();

    debounce(searchQuery, (_) {
      page(1);
      getHomeHealthcares();
    }, time: const Duration(milliseconds: 500));

    super.onInit();
  }

  Future<void> getHomeHealthcares({bool showLoader = true}) async {
    if (showLoader) isLoading(true);

    await homeHealthcareFuture(
      CoreServiceApis.getHomeHealthcareList(
        page: page.value,
        perPage: Constants.perPageItem,
        homeHealthcareList: homeHealthcares,
        search: searchCont.text.trim(),
        governorateId: selectedGovernorateId.value,
        cityId: selectedCityId.value,
        serviceType: selectedServiceType.value,
        lastPageCallBack: (isLast) => isLastPage(isLast),
      ),
    ).then((value) {
      log('Home healthcare fetched: ${value.length}');
    }).catchError((e) {
      log("getHomeHealthcares error $e");
    }).whenComplete(() => isLoading(false));
  }

  void onGovernorateChanged(int? id) {
    selectedGovernorateId.value = id;
    selectedCityId.value = null;
    page(1);
    getHomeHealthcares();
  }

  void onCityChanged(int? id) {
    selectedCityId.value = id;
    page(1);
    getHomeHealthcares();
  }

  void onServiceTypeChanged(String type) {
    selectedServiceType(type);
    page(1);
    getHomeHealthcares();
  }

  void onSearchChanged(String val) => searchQuery.value = val;

  @override
  void onClose() {
    searchCont.dispose();
    super.onClose();
  }
}
```

**`lib/screens/home_healthcare/create_home_healthcare_request_controller.dart`**

```dart
class CreateHomeHealthcareRequestController extends GetxController {
  // Form state
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  RxBool isLoading = false.obs;

  // Selections
  Rx<HomeHealthcare?> selectedProvider = Rx<HomeHealthcare?>(null);
  RxString selectedServiceType = ''.obs;

  // Form fields
  TextEditingController preferredDateCont = TextEditingController();
  TextEditingController preferredTimeCont = TextEditingController();
  TextEditingController addressCont = TextEditingController();
  TextEditingController contactNumberCont = TextEditingController();
  TextEditingController notesCont = TextEditingController();

  // Dates
  DateTime? preferredDate;
  TimeOfDay? preferredTime;

  @override
  void onInit() {
    if (Get.arguments is HomeHealthcare) {
      selectedProvider.value = Get.arguments;
    }
    super.onInit();
  }

  Future<void> submitRequest() async {
    if (!formKey.currentState!.validate()) return;

    isLoading(true);

    Map<String, dynamic> request = {
      'home_healthcare_id': selectedProvider.value?.id,
      'service_type': selectedServiceType.value,
      'preferred_date': preferredDate?.toString().split(' ').first,
      'preferred_time': preferredTime?.format(Get.context!),
      'address': addressCont.text.trim(),
      'contact_number': contactNumberCont.text.trim(),
      'patient_notes': notesCont.text.trim(),
    };

    await CoreServiceApis.createHomeHealthcareRequest(request: request).then((_) {
      toast(locale.value.requestSubmittedSuccessfully);
      Get.back(result: true);
    }).catchError((e) {
      toast(e.toString());
    }).whenComplete(() => isLoading(false));
  }

  @override
  void onClose() {
    preferredDateCont.dispose();
    preferredTimeCont.dispose();
    addressCont.dispose();
    contactNumberCont.dispose();
    notesCont.dispose();
    super.onClose();
  }
}
```

**`lib/screens/home_healthcare/home_healthcare_request_list_controller.dart`**

Mirrors `NurseRequestListController`:

```dart
class HomeHealthcareRequestListController extends GetxController {
  Rx<Future<RxList<HomeHealthcareRequest>>> requestFuture = Future(() => RxList<HomeHealthcareRequest>()).obs;
  RxList<HomeHealthcareRequest> requests = RxList<HomeHealthcareRequest>();
  RxBool isLoading = false.obs;
  RxBool isLastPage = false.obs;
  RxInt page = 1.obs;

  RxString selectedStatus = ''.obs;
  RxList<Map<String, String>> statusFilters = RxList();

  @override
  void onInit() {
    statusFilters = [
      {'key': '', 'label': locale.value.all},
      {'key': HomeHealthcareRequestStatusConst.pending, 'label': locale.value.homeHealthcareRequestPending},
      {'key': HomeHealthcareRequestStatusConst.confirmed, 'label': locale.value.homeHealthcareRequestConfirmed},
      {'key': HomeHealthcareRequestStatusConst.inProgress, 'label': locale.value.homeHealthcareRequestInProgress},
      {'key': HomeHealthcareRequestStatusConst.completed, 'label': locale.value.homeHealthcareRequestCompleted},
      {'key': HomeHealthcareRequestStatusConst.cancelled, 'label': locale.value.homeHealthcareRequestCancelled},
    ].obs;

    getRequests();
    super.onInit();
  }

  Future<void> getRequests({bool showLoader = true}) async {
    if (showLoader) isLoading(true);

    await requestFuture(
      CoreServiceApis.getHomeHealthcareRequestList(
        page: page.value,
        perPage: Constants.perPageItem,
        requestList: requests,
        status: selectedStatus.value,
        lastPageCallBack: (isLast) => isLastPage(isLast),
      ),
    ).then((value) {
      log('Requests fetched: ${value.length}');
    }).catchError((e) {
      log("getRequests error $e");
    }).whenComplete(() => isLoading(false));
  }

  void onStatusChanged(String status) {
    selectedStatus(status);
    page(1);
    getRequests();
  }
}
```

---

### Screens — Clinical Elegance UI

**`lib/screens/home_healthcare/home_healthcare_list_screen.dart`**

```
Structure:
├── AppScaffoldNew
│   ├── appBartitleText: locale.value.browseHomeHealthcare
│   ├── hasLeadingWidget: true
│   ├── appBarVerticalSize: Get.height * 0.12
│   ├── isLoading: controller.isLoading
│   └── body: Obx(() => SnapHelperWidget
│       ├── future: controller.homeHealthcareFuture.value
│       ├── errorBuilder: _buildEmptyState()
│       ├── loadingWidget: LoaderWidget()
│       └── onSuccess: AnimatedScrollView
│           ├── Decorative Header Gradient
│           │   └── Container with gradient: appColorPrimary -> appColorSecondary (20% opacity)
│           ├── Premium Search Bar
│           │   ├── Glass border (glassStrokeDark/Light, 1px)
│           │   ├── inputFillColor background, 12px radius
│           │   ├── Gradient search icon (ShaderMask)
│           │   ├── onChanged: controller.onSearchChanged
│           │   └── Suffix clear button when text present
│           ├── GovernoratesCityPicker
│           │   ├── Glass-bordered collapsible section
│           │   ├── selectedGovernorateId / selectedCityId from controller
│           │   └── onChanged callbacks to controller
│           ├── Service Type Filter Chips
│           │   ├── Horizontal scrollable row
│           │   ├── Each chip: selected = gradient background (primary->secondary), white text
│           │   ├── Unselected = surfaceSubtle background, secondaryTextColor
│           │   └── onTap: controller.onServiceTypeChanged
│           ├── Results Count Text
│           │   └── "${controller.homeHealthcares.length} results" in secondaryTextStyle
│           └── ListView.separated
│               ├── HomeHealthcareCard items with FadeIn animation (delay: index * 50ms)
│               └── onNextPage: increment page, fetch more
```

**`lib/screens/home_healthcare/components/home_healthcare_card.dart`**

```
Structure:
├── GestureDetector (onTap: navigate to detail)
└── Container
    ├── decoration:
    │   ├── color: isDarkMode ? surfaceElevatedDark : surfaceElevated
    │   ├── borderRadius: 16px
    │   └── boxShadow: softShadowColor
    └── Padding (16px)
        └── Row
            ├── CachedImageWidget (profile image)
            │   ├── 64x64, circular clip
            │   └── Gradient border ring (2px, primary->accent)
            ├── SizedBox(width: 12)
            └── Expanded Column
                ├── Text(name, boldTextStyle(size: 16)) — Outfit font
                ├── SizedBox(height: 4)
                ├── Text(serviceType, secondaryTextStyle(size: 13))
                ├── SizedBox(height: 6)
                ├── Location Pill (if governorate != null)
                │   ├── Container: appColorSecondary.withOpacity(0.1), 8px radius
                │   └── Text: "Governorate - City", secondaryTextStyle(size: 11, color: appColorSecondary)
                ├── SizedBox(height: 6)
                └── Row
                    ├── Rating Stars (if rating > 0)
                    └── Spacer + trailing icon
```

**`lib/screens/home_healthcare/home_healthcare_detail_screen.dart`**

```
Structure:
├── AppScaffoldNew
│   └── body: Stack
│       ├── Hero Header Section
│       │   ├── CachedImageWidget (full width, 250px height)
│       │   └── Gradient overlay (transparent -> appColorPrimary at bottom)
│       └── SingleChildScrollView (starting below header)
│           ├── Provider Name + Service Type
│           │   └── Outfit boldTextStyle(size: 22), below: serviceType pill
│           ├── Rating Row
│           │   └── Star icons + "4.5 (120 reviews)" text
│           ├── Location Section
│           │   └── Location pin icon + governorate - city text
│           ├── Glass Info Card: "About"
│           │   ├── Container: glass border, surfaceSubtle bg, 12px radius
│           │   └── description text, primaryTextStyle(size: 14)
│           ├── Glass Info Card: "Services Offered"
│           │   └── List of HomeHealthcareService items with name + price
│           ├── Glass Info Card: "Coverage Area"
│           │   └── coverageArea text + optional map widget
│           ├── Glass Info Card: "Operating Hours"
│           │   └── operatingHours text with clock icon
│           ├── Glass Info Card: "Contact"
│           │   └── Phone + Email with tappable action buttons
│           └── SizedBox(height: 80) — space for bottom CTA
│
├── Bottom CTA: "Request Service"
│   ├── Positioned at bottom, full width
│   ├── Gradient button (appColorPrimary -> appColorSecondary)
│   ├── Text: locale.value.requestService, white, bold
│   └── onTap: Get.to(() => CreateHomeHealthcareRequestScreen(), arguments: provider)
```

**`lib/screens/home_healthcare/create_home_healthcare_request_screen.dart`**

```
Structure:
├── AppScaffoldNew
│   ├── appBartitleText: locale.value.requestHomeHealthcare
│   └── body: Form(key: controller.formKey)
│       └── SingleChildScrollView(padding: 24px)
│           ├── Selected Provider Card (if pre-selected)
│           │   └── Mini card showing provider name + image
│           ├── Glass Section: "Service Details"
│           │   ├── Service Type Dropdown
│           │   └── Service Description (optional text area)
│           ├── Glass Section: "Schedule"
│           │   ├── Preferred Date Picker (AppTextField with date picker)
│           │   └── Preferred Time Picker (AppTextField with time picker)
│           ├── Glass Section: "Location"
│           │   ├── Address TextField
│           │   └── Optional: Map pin selector
│           ├── Glass Section: "Contact"
│           │   └── Contact Number TextField
│           ├── Glass Section: "Notes"
│           │   └── Patient Notes TextArea (multiline)
│           └── SizedBox(height: 80) — space for submit button
│
├── Bottom CTA: "Submit Request"
│   ├── Gradient button with loading state
│   └── onTap: controller.submitRequest()
```

**`lib/screens/home_healthcare/home_healthcare_request_list_screen.dart`**

Same pattern as `NurseRequestListScreen`:
```
├── AppScaffoldNew with gradient header
├── Status filter chips (all, pending, confirmed, in_progress, completed, cancelled)
├── AnimatedScrollView with HomeHealthcareRequestCard items
└── Empty state when no requests
```

**`lib/screens/home_healthcare/components/home_healthcare_request_card.dart`**

Same pattern as `NurseRequestCard`:
```
├── Glass-bordered card, 16px radius
├── Provider name + service type
├── Preferred date/time
├── Status badge with color coding:
│   ├── pending: pendingStatusColor (orange)
│   ├── confirmed: confirmedStatusColor (teal)
│   ├── in_progress: inProgressStatusColor (blue)
│   ├── completed: completedStatusColor (green)
│   └── cancelled: cancelledStatusColor (red)
├── Total amount (if applicable)
└── onTap: navigate to request detail
```

**`lib/screens/home_healthcare/home_healthcare_request_detail_screen.dart`**

Same pattern as `NurseRequestDetailScreen`:
```
├── AppScaffoldNew
├── Status badge header with colored background
├── Glass info cards: Provider, Schedule, Location, Contact, Notes, Payment
├── Cancel button (if status is pending/confirmed)
└── Confirmation dialog before cancel
```

---

### Status Constants

**Add to `lib/utils/constants.dart`:**

```dart
class HomeHealthcareRequestStatusConst {
  static const String pending = 'pending';
  static const String confirmed = 'confirmed';
  static const String inProgress = 'in_progress';
  static const String completed = 'completed';
  static const String cancelled = 'cancelled';
}

class HomeHealthcareServiceTypeConst {
  static const String nursing = 'nursing';
  static const String physiotherapy = 'physiotherapy';
  static const String elderlyCare = 'elderly_care';
  static const String postSurgery = 'post_surgery';
}
```

---

### Status Colors

**Add to `lib/utils/colors.dart` (if not already present):**

Home healthcare uses the same status color palette as nurse requests:
```dart
// Already defined — reuse existing:
// pendingStatusColor, confirmedStatusColor, inProgressStatusColor,
// completedStatusColor, cancelledStatusColor
```

---

### Locale Strings

**Add to `lib/locale/languages.dart`:**
```dart
// Home Healthcare
String get browseHomeHealthcare;
String get homeHealthcareServices;
String get serviceType;
String get requestHomeHealthcare;
String get requestService;
String get coverageArea;
String get operatingHours;
String get preferredDate;
String get preferredTime;
String get patientNotes;
String get myHomeHealthcareRequests;
String get homeHealthcareRequestDetail;
String get noHomeHealthcareFound;
String get noHomeHealthcareRequestsFound;
String get requestSubmittedSuccessfully;
String get homeHealthcareRequestPending;
String get homeHealthcareRequestConfirmed;
String get homeHealthcareRequestInProgress;
String get homeHealthcareRequestCompleted;
String get homeHealthcareRequestCancelled;
String get nursing;
String get physiotherapy;
String get elderlyCare;
String get postSurgeryCare;
String get contactProvider;
```

**Add to `lib/locale/language_en.dart`:**
```dart
@override String get browseHomeHealthcare => 'Home Healthcare';
@override String get homeHealthcareServices => 'Home Healthcare Services';
@override String get serviceType => 'Service Type';
@override String get requestHomeHealthcare => 'Request Home Healthcare';
@override String get requestService => 'Request Service';
@override String get coverageArea => 'Coverage Area';
@override String get operatingHours => 'Operating Hours';
@override String get preferredDate => 'Preferred Date';
@override String get preferredTime => 'Preferred Time';
@override String get patientNotes => 'Patient Notes';
@override String get myHomeHealthcareRequests => 'My Home Healthcare Requests';
@override String get homeHealthcareRequestDetail => 'Request Detail';
@override String get noHomeHealthcareFound => 'No home healthcare providers found';
@override String get noHomeHealthcareRequestsFound => 'No home healthcare requests found';
@override String get requestSubmittedSuccessfully => 'Request submitted successfully';
@override String get homeHealthcareRequestPending => 'Pending';
@override String get homeHealthcareRequestConfirmed => 'Confirmed';
@override String get homeHealthcareRequestInProgress => 'In Progress';
@override String get homeHealthcareRequestCompleted => 'Completed';
@override String get homeHealthcareRequestCancelled => 'Cancelled';
@override String get nursing => 'Nursing';
@override String get physiotherapy => 'Physiotherapy';
@override String get elderlyCare => 'Elderly Care';
@override String get postSurgeryCare => 'Post Surgery Care';
@override String get contactProvider => 'Contact Provider';
```

**Add to `lib/locale/language_ar.dart`:**
```dart
@override String get browseHomeHealthcare => 'الرعاية الصحية المنزلية';
@override String get homeHealthcareServices => 'خدمات الرعاية المنزلية';
@override String get serviceType => 'نوع الخدمة';
@override String get requestHomeHealthcare => 'طلب رعاية منزلية';
@override String get requestService => 'طلب خدمة';
@override String get coverageArea => 'منطقة التغطية';
@override String get operatingHours => 'ساعات العمل';
@override String get preferredDate => 'التاريخ المفضل';
@override String get preferredTime => 'الوقت المفضل';
@override String get patientNotes => 'ملاحظات المريض';
@override String get myHomeHealthcareRequests => 'طلبات الرعاية المنزلية';
@override String get homeHealthcareRequestDetail => 'تفاصيل الطلب';
@override String get noHomeHealthcareFound => 'لا توجد مقدمي رعاية منزلية';
@override String get noHomeHealthcareRequestsFound => 'لا توجد طلبات رعاية منزلية';
@override String get requestSubmittedSuccessfully => 'تم تقديم الطلب بنجاح';
@override String get homeHealthcareRequestPending => 'قيد الانتظار';
@override String get homeHealthcareRequestConfirmed => 'مؤكد';
@override String get homeHealthcareRequestInProgress => 'جاري التنفيذ';
@override String get homeHealthcareRequestCompleted => 'مكتمل';
@override String get homeHealthcareRequestCancelled => 'ملغي';
@override String get nursing => 'تمريض';
@override String get physiotherapy => 'علاج طبيعي';
@override String get elderlyCare => 'رعاية كبار السن';
@override String get postSurgeryCare => 'رعاية ما بعد الجراحة';
@override String get contactProvider => 'تواصل مع مقدم الخدمة';
```

**Add to `lib/locale/language_de.dart`:**
```dart
@override String get browseHomeHealthcare => 'Häusliche Pflege';
@override String get homeHealthcareServices => 'Häusliche Pflegedienste';
@override String get serviceType => 'Diensttyp';
@override String get requestHomeHealthcare => 'Häusliche Pflege anfordern';
@override String get requestService => 'Dienst anfordern';
@override String get coverageArea => 'Abdeckungsbereich';
@override String get operatingHours => 'Öffnungszeiten';
@override String get preferredDate => 'Bevorzugtes Datum';
@override String get preferredTime => 'Bevorzugte Zeit';
@override String get patientNotes => 'Patientennotizen';
@override String get myHomeHealthcareRequests => 'Meine Pflegeanfragen';
@override String get homeHealthcareRequestDetail => 'Anfragedetails';
@override String get noHomeHealthcareFound => 'Keine häuslichen Pflegedienste gefunden';
@override String get noHomeHealthcareRequestsFound => 'Keine Pflegeanfragen gefunden';
@override String get requestSubmittedSuccessfully => 'Anfrage erfolgreich eingereicht';
@override String get homeHealthcareRequestPending => 'Ausstehend';
@override String get homeHealthcareRequestConfirmed => 'Bestätigt';
@override String get homeHealthcareRequestInProgress => 'In Bearbeitung';
@override String get homeHealthcareRequestCompleted => 'Abgeschlossen';
@override String get homeHealthcareRequestCancelled => 'Storniert';
@override String get nursing => 'Pflege';
@override String get physiotherapy => 'Physiotherapie';
@override String get elderlyCare => 'Altenpflege';
@override String get postSurgeryCare => 'Nachoperative Pflege';
@override String get contactProvider => 'Anbieter kontaktieren';
```

**Add to `lib/locale/language_fr.dart`:**
```dart
@override String get browseHomeHealthcare => 'Soins à domicile';
@override String get homeHealthcareServices => 'Services de soins à domicile';
@override String get serviceType => 'Type de service';
@override String get requestHomeHealthcare => 'Demander des soins à domicile';
@override String get requestService => 'Demander un service';
@override String get coverageArea => 'Zone de couverture';
@override String get operatingHours => 'Heures d\'ouverture';
@override String get preferredDate => 'Date préférée';
@override String get preferredTime => 'Heure préférée';
@override String get patientNotes => 'Notes du patient';
@override String get myHomeHealthcareRequests => 'Mes demandes de soins';
@override String get homeHealthcareRequestDetail => 'Détails de la demande';
@override String get noHomeHealthcareFound => 'Aucun prestataire de soins trouvé';
@override String get noHomeHealthcareRequestsFound => 'Aucune demande de soins trouvée';
@override String get requestSubmittedSuccessfully => 'Demande soumise avec succès';
@override String get homeHealthcareRequestPending => 'En attente';
@override String get homeHealthcareRequestConfirmed => 'Confirmé';
@override String get homeHealthcareRequestInProgress => 'En cours';
@override String get homeHealthcareRequestCompleted => 'Terminé';
@override String get homeHealthcareRequestCancelled => 'Annulé';
@override String get nursing => 'Soins infirmiers';
@override String get physiotherapy => 'Physiothérapie';
@override String get elderlyCare => 'Soins aux personnes âgées';
@override String get postSurgeryCare => 'Soins post-opératoires';
@override String get contactProvider => 'Contacter le prestataire';
```

**Add to `lib/locale/language_hi.dart`:**
```dart
@override String get browseHomeHealthcare => 'होम हेल्थकेयर';
@override String get homeHealthcareServices => 'होम हेल्थकेयर सेवाएं';
@override String get serviceType => 'सेवा प्रकार';
@override String get requestHomeHealthcare => 'होम हेल्थकेयर अनुरोध';
@override String get requestService => 'सेवा अनुरोध';
@override String get coverageArea => 'कवरेज क्षेत्र';
@override String get operatingHours => 'कार्य समय';
@override String get preferredDate => 'पसंदीदा तारीख';
@override String get preferredTime => 'पसंदीदा समय';
@override String get patientNotes => 'मरीज़ की टिप्पणियां';
@override String get myHomeHealthcareRequests => 'मेरे हेल्थकेयर अनुरोध';
@override String get homeHealthcareRequestDetail => 'अनुरोध विवरण';
@override String get noHomeHealthcareFound => 'कोई होम हेल्थकेयर प्रदाता नहीं मिला';
@override String get noHomeHealthcareRequestsFound => 'कोई हेल्थकेयर अनुरोध नहीं मिला';
@override String get requestSubmittedSuccessfully => 'अनुरोध सफलतापूर्वक सबमिट किया गया';
@override String get homeHealthcareRequestPending => 'लंबित';
@override String get homeHealthcareRequestConfirmed => 'पुष्ट';
@override String get homeHealthcareRequestInProgress => 'प्रगति पर';
@override String get homeHealthcareRequestCompleted => 'पूर्ण';
@override String get homeHealthcareRequestCancelled => 'रद्द';
@override String get nursing => 'नर्सिंग';
@override String get physiotherapy => 'फिजियोथेरेपी';
@override String get elderlyCare => 'बुजुर्ग देखभाल';
@override String get postSurgeryCare => 'सर्जरी के बाद देखभाल';
@override String get contactProvider => 'प्रदाता से संपर्क करें';
```

---

## Phase 5 — Lab Tests (Extend Existing)

### Modified Files

```
lib/screens/lab_test/lab_test_list_controller.dart
lib/screens/lab_test/lab_test_list_screen.dart
lib/screens/lab_test/model/lab_test_model.dart
lib/screens/lab_test/components/lab_test_card.dart
lib/api/core_apis.dart
```

---

### Controller Changes (`lab_test_list_controller.dart`)

Add reactive location filter vars:
```dart
RxnInt selectedGovernorateId = RxnInt();
RxnInt selectedCityId = RxnInt();
```

Add location change handlers:
```dart
void onGovernorateChanged(int? id) {
  selectedGovernorateId.value = id;
  selectedCityId.value = null;
  page(1);
  getLabTests();
}

void onCityChanged(int? id) {
  selectedCityId.value = id;
  page(1);
  getLabTests();
}
```

Pass to API call:
```dart
governorateId: selectedGovernorateId.value,
cityId: selectedCityId.value,
```

---

### API Call Update (`core_apis.dart`)

Add NEW `searchLabs()` method (keep existing `getLabTestList()` unchanged):
```dart
static Future<RxList<LabTest>> searchLabs({
  int page = 1,
  int perPage = 20,
  required List<LabTest> labTestList,
  Function(bool)? lastPageCallBack,
  String testName = '',
  int? governorateId,
  int? cityId,
}) async {
  String nameParam = testName.isNotEmpty ? '&test_name=${Uri.encodeQueryComponent(testName)}' : '';
  String govParam = governorateId != null ? '&governorate_id=$governorateId' : '';
  String cityParam = cityId != null ? '&city_id=$cityId' : '';

  // Uses NEW endpoint: APIEndPoints.labsSearch (not existing v1/lab-tests)
  final res = LabTestListResponse.fromJson(await handleResponse(
    await buildHttpResponse(
      '${APIEndPoints.labsSearch}?per_page=$perPage&page=$page$nameParam$govParam$cityParam',
      method: HttpMethodType.GET,
    ),
  ));

  if (page == 1) labTestList.clear();
  labTestList.addAll(res.data);
  lastPageCallBack?.call(res.currentPage >= res.lastPage);

  return labTestList.obs;
}
```

**API endpoint consumed:**
```
GET /api/labs/search?governorate_id=&city_id=&test_name=
```

The `test_name` param on the new endpoint maps to the search text input.

---

### Model Update (`lab_test_model.dart`)

Add to LabTest class:
```dart
Governorate? governorate;
City? city;
```

In `fromJson()`:
```dart
governorate: json['governorate'] is Map
    ? Governorate.fromJson(json['governorate'])
    : null,
city: json['city'] is Map
    ? City.fromJson(json['city'])
    : null,
```

---

### Screen Update (`lab_test_list_screen.dart`)

Insert `GovernoratesCityPicker` between search bar and existing department filter chips:

```dart
GovernoratesCityPicker(
  selectedGovernorateId: controller.selectedGovernorateId.value,
  selectedCityId: controller.selectedCityId.value,
  onGovernorateChanged: controller.onGovernorateChanged,
  onCityChanged: controller.onCityChanged,
),
```

Same collapsible glass-bordered filter section as other modules.

---

### Card Update (`lab_test_card.dart`)

Add location pill (consistent with all other cards):
```dart
if (labTest.governorate != null)
  Container(
    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: appColorSecondary.withOpacity(0.1),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Text(
      [labTest.governorate?.name, labTest.city?.name]
          .where((e) => e != null && e.isNotEmpty)
          .join(' - '),
      style: secondaryTextStyle(size: 11, color: appColorSecondary),
    ),
  ),
```

---

## Phase 6 — Radiology (New Module)

### New Directory Structure

```
lib/screens/radiology/
├── radiology_list_controller.dart
├── radiology_list_screen.dart
├── radiology_detail_screen.dart
├── model/
│   └── radiology_center_model.dart
└── components/
    └── radiology_center_card.dart
```

### Modified Files

```
lib/utils/api_end_points.dart
lib/api/core_apis.dart
lib/utils/constants.dart
lib/locale/languages.dart
lib/locale/language_en.dart
lib/locale/language_ar.dart
lib/locale/language_de.dart
lib/locale/language_fr.dart
lib/locale/language_hi.dart
```

---

### Model

**`lib/screens/radiology/model/radiology_center_model.dart`**

```dart
class RadiologyCenterListResponse {
  bool status;
  List<RadiologyCenter> data;
  int currentPage;
  int lastPage;
  int perPage;
  int total;

  RadiologyCenterListResponse({
    this.status = false,
    this.data = const [],
    this.currentPage = 1,
    this.lastPage = 1,
    this.perPage = 15,
    this.total = 0,
  });

  factory RadiologyCenterListResponse.fromJson(Map<String, dynamic> json) {
    return RadiologyCenterListResponse(
      status: json['status'] is bool ? json['status'] : false,
      data: json['data'] is Map && json['data']['items'] is List
          ? (json['data']['items'] as List)
              .map((e) => RadiologyCenter.fromJson(e))
              .toList()
          : [],
      currentPage: json['data'] is Map && json['data']['pagination'] is Map
          ? json['data']['pagination']['current_page'] ?? 1
          : 1,
      lastPage: json['data'] is Map && json['data']['pagination'] is Map
          ? json['data']['pagination']['last_page'] ?? 1
          : 1,
      perPage: json['data'] is Map && json['data']['pagination'] is Map
          ? json['data']['pagination']['per_page'] ?? 15
          : 15,
      total: json['data'] is Map && json['data']['pagination'] is Map
          ? json['data']['pagination']['total'] ?? 0
          : 0,
    );
  }
}

class RadiologyCenter {
  int id;
  String name;
  String description;
  String address;
  String contactNumber;
  String email;
  String profileImage;
  String status;
  double rating;
  List<String> scanTypes;     // MRI, CT, X-Ray, Ultrasound, etc.
  String operatingHours;
  String pricing;
  Governorate? governorate;
  City? city;
  String createdAt;
  String updatedAt;

  RadiologyCenter({
    this.id = -1,
    this.name = '',
    this.description = '',
    this.address = '',
    this.contactNumber = '',
    this.email = '',
    this.profileImage = '',
    this.status = '',
    this.rating = 0.0,
    this.scanTypes = const [],
    this.operatingHours = '',
    this.pricing = '',
    this.governorate,
    this.city,
    this.createdAt = '',
    this.updatedAt = '',
  });

  factory RadiologyCenter.fromJson(Map<String, dynamic> json) {
    return RadiologyCenter(
      id: json['id'] is int ? json['id'] : -1,
      name: json['name'] is String ? json['name'] : '',
      description: json['description'] is String ? json['description'] : '',
      address: json['address'] is String ? json['address'] : '',
      contactNumber: json['contact_number'] is String ? json['contact_number'] : '',
      email: json['email'] is String ? json['email'] : '',
      profileImage: json['profile_image'] is String ? json['profile_image'] : '',
      status: json['status'] is String ? json['status'] : '',
      rating: json['rating'] is num ? json['rating'].toDouble() : 0.0,
      scanTypes: json['scan_types'] is List
          ? (json['scan_types'] as List).map((e) => e.toString()).toList()
          : [],
      operatingHours: json['operating_hours'] is String ? json['operating_hours'] : '',
      pricing: json['pricing'] is String ? json['pricing'] : '',
      governorate: json['governorate'] is Map
          ? Governorate.fromJson(json['governorate'])
          : null,
      city: json['city'] is Map ? City.fromJson(json['city']) : null,
      createdAt: json['created_at'] is String ? json['created_at'] : '',
      updatedAt: json['updated_at'] is String ? json['updated_at'] : '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'address': address,
    'contact_number': contactNumber,
    'email': email,
    'profile_image': profileImage,
    'status': status,
    'rating': rating,
    'scan_types': scanTypes,
    'operating_hours': operatingHours,
    'pricing': pricing,
  };
}
```

---

### API Endpoints

**Add to `lib/utils/api_end_points.dart`:**

```dart
// Radiology
static const String radiologySearch = 'radiology/search';
static const String radiologyDetail = 'radiology'; // append /{id}
```

---

### API Service Methods

**Add to `lib/api/core_apis.dart`:**

```dart
// ==================== Radiology ====================

/// Fetch paginated radiology centers with filters
static Future<RxList<RadiologyCenter>> getRadiologyCenterList({
  int page = 1,
  int perPage = 20,
  required List<RadiologyCenter> radiologyCenterList,
  Function(bool)? lastPageCallBack,
  String search = '',
  int? governorateId,
  int? cityId,
  String scanType = '',
}) async {
  String searchParam = search.isNotEmpty
      ? '&search=${Uri.encodeQueryComponent(search)}'
      : '';
  String govParam = governorateId != null ? '&governorate_id=$governorateId' : '';
  String cityParam = cityId != null ? '&city_id=$cityId' : '';
  String scanParam = scanType.isNotEmpty
      ? '&scan_type=${Uri.encodeQueryComponent(scanType)}'
      : '';

  final res = RadiologyCenterListResponse.fromJson(await handleResponse(
    await buildHttpResponse(
      '${APIEndPoints.radiologySearch}?per_page=$perPage&page=$page$searchParam$govParam$cityParam$scanParam',
      method: HttpMethodType.GET,
    ),
  ));

  if (page == 1) radiologyCenterList.clear();
  radiologyCenterList.addAll(res.data);
  lastPageCallBack?.call(res.currentPage >= res.lastPage);

  return radiologyCenterList.obs;
}

/// Fetch single radiology center detail
static Future<RadiologyCenter> getRadiologyCenterDetail({required int id}) async {
  final res = await handleResponse(
    await buildHttpResponse(
      '${APIEndPoints.radiologyDetail}/$id',
      method: HttpMethodType.GET,
    ),
  );
  return RadiologyCenter.fromJson(res['data']);
}
```

---

### Controller

**`lib/screens/radiology/radiology_list_controller.dart`**

```dart
class RadiologyListController extends GetxController {
  // List state
  Rx<Future<RxList<RadiologyCenter>>> radiologyFuture = Future(() => RxList<RadiologyCenter>()).obs;
  RxList<RadiologyCenter> radiologyCenters = RxList<RadiologyCenter>();
  RxBool isLoading = false.obs;
  RxBool isLastPage = false.obs;
  RxInt page = 1.obs;

  // Search
  TextEditingController searchCont = TextEditingController();
  RxString searchQuery = ''.obs;

  // Location filter
  RxnInt selectedGovernorateId = RxnInt();
  RxnInt selectedCityId = RxnInt();

  // Scan type filter
  RxString selectedScanType = ''.obs;
  RxList<Map<String, String>> scanTypeFilters = RxList();

  @override
  void onInit() {
    scanTypeFilters = [
      {'key': '', 'label': locale.value.all},
      {'key': ScanTypeConst.mri, 'label': locale.value.mriScan},
      {'key': ScanTypeConst.ct, 'label': locale.value.ctScan},
      {'key': ScanTypeConst.xray, 'label': locale.value.xRay},
      {'key': ScanTypeConst.ultrasound, 'label': locale.value.ultrasound},
      {'key': ScanTypeConst.mammogram, 'label': locale.value.mammogram},
      {'key': ScanTypeConst.dexa, 'label': locale.value.dexaScan},
    ].obs;

    getRadiologyCenters();

    debounce(searchQuery, (_) {
      page(1);
      getRadiologyCenters();
    }, time: const Duration(milliseconds: 500));

    super.onInit();
  }

  Future<void> getRadiologyCenters({bool showLoader = true}) async {
    if (showLoader) isLoading(true);

    await radiologyFuture(
      CoreServiceApis.getRadiologyCenterList(
        page: page.value,
        perPage: Constants.perPageItem,
        radiologyCenterList: radiologyCenters,
        search: searchCont.text.trim(),
        governorateId: selectedGovernorateId.value,
        cityId: selectedCityId.value,
        scanType: selectedScanType.value,
        lastPageCallBack: (isLast) => isLastPage(isLast),
      ),
    ).then((value) {
      log('Radiology centers fetched: ${value.length}');
    }).catchError((e) {
      log("getRadiologyCenters error $e");
    }).whenComplete(() => isLoading(false));
  }

  void onGovernorateChanged(int? id) {
    selectedGovernorateId.value = id;
    selectedCityId.value = null;
    page(1);
    getRadiologyCenters();
  }

  void onCityChanged(int? id) {
    selectedCityId.value = id;
    page(1);
    getRadiologyCenters();
  }

  void onScanTypeChanged(String type) {
    selectedScanType(type);
    page(1);
    getRadiologyCenters();
  }

  void onSearchChanged(String val) => searchQuery.value = val;

  @override
  void onClose() {
    searchCont.dispose();
    super.onClose();
  }
}
```

---

### Screens — Clinical Elegance UI

**`lib/screens/radiology/radiology_list_screen.dart`**

```
Structure:
├── AppScaffoldNew
│   ├── appBartitleText: locale.value.browseRadiology
│   ├── hasLeadingWidget: true
│   ├── appBarVerticalSize: Get.height * 0.12
│   ├── isLoading: controller.isLoading
│   └── body: Obx(() => SnapHelperWidget
│       ├── future: controller.radiologyFuture.value
│       ├── errorBuilder: _buildEmptyState()
│       ├── loadingWidget: LoaderWidget()
│       └── onSuccess: AnimatedScrollView
│           ├── Decorative Header Gradient
│           │   └── Container with gradient: appColorPrimary -> appColorSecondary (20% opacity)
│           ├── Premium Search Bar
│           │   ├── Glass border, inputFillColor bg, 12px radius
│           │   ├── Gradient search icon (ShaderMask)
│           │   └── onChanged: controller.onSearchChanged
│           ├── GovernoratesCityPicker (collapsible glass section)
│           ├── Scan Type Filter Chips
│           │   ├── Horizontal scrollable row
│           │   ├── Chips: All, MRI, CT, X-Ray, Ultrasound, Mammogram, DEXA
│           │   ├── Selected = gradient background, white text
│           │   ├── Unselected = surfaceSubtle background
│           │   └── onTap: controller.onScanTypeChanged
│           ├── Results Count Text
│           └── ListView.separated
│               ├── RadiologyCenterCard items with FadeIn animation
│               └── onNextPage: increment page, fetch more
```

**`lib/screens/radiology/components/radiology_center_card.dart`**

```
Structure:
├── GestureDetector (onTap: navigate to detail)
└── Container
    ├── decoration: surfaceElevated/Dark, 16px radius, softShadowColor
    └── Padding (16px)
        └── Column
            ├── Row
            │   ├── CachedImageWidget (profile image, 64x64, circular, gradient border ring)
            │   ├── SizedBox(width: 12)
            │   └── Expanded Column
            │       ├── Text(name, boldTextStyle(size: 16)) — Outfit
            │       ├── SizedBox(height: 4)
            │       ├── Location Pill (governorate - city)
            │       └── Rating Stars Row
            ├── SizedBox(height: 10)
            └── Scan Types Row
                └── Wrap of small pills for each scanType
                    ├── Container: appColorPrimary.withOpacity(0.08), 6px radius
                    └── Text: scanType label, primaryTextStyle(size: 10, color: appColorPrimary)
```

**`lib/screens/radiology/radiology_detail_screen.dart`**

```
Structure:
├── AppScaffoldNew
│   └── body: Stack
│       ├── Hero Header Section
│       │   ├── CachedImageWidget (full width, 250px height)
│       │   └── Gradient overlay (transparent -> appColorPrimary)
│       └── SingleChildScrollView
│           ├── Center Name + Rating
│           │   └── Outfit boldTextStyle(size: 22)
│           ├── Location Section
│           │   └── Pin icon + governorate - city
│           ├── Glass Info Card: "About"
│           │   └── description text
│           ├── Glass Info Card: "Available Scans"
│           │   └── Grid of scan type chips (larger, with icons)
│           │       ├── MRI: brain/magnet icon
│           │       ├── CT: scanner icon
│           │       ├── X-Ray: bone icon
│           │       ├── Ultrasound: wave icon
│           │       ├── Mammogram: medical icon
│           │       └── DEXA: bone density icon
│           ├── Glass Info Card: "Operating Hours"
│           │   └── Clock icon + hours text
│           ├── Glass Info Card: "Pricing"
│           │   └── Price info text
│           ├── Glass Info Card: "Contact"
│           │   └── Phone + Email with tappable buttons
│           └── Glass Info Card: "Location"
│               └── Address text + optional map widget
```

---

### Status Constants

**Add to `lib/utils/constants.dart`:**

```dart
class ScanTypeConst {
  static const String mri = 'mri';
  static const String ct = 'ct';
  static const String xray = 'xray';
  static const String ultrasound = 'ultrasound';
  static const String mammogram = 'mammogram';
  static const String dexa = 'dexa';
}
```

---

### Locale Strings

**Add to `lib/locale/languages.dart`:**
```dart
// Radiology
String get browseRadiology;
String get radiologyCenters;
String get scanType;
String get availableScans;
String get mriScan;
String get ctScan;
String get xRay;
String get ultrasound;
String get mammogram;
String get dexaScan;
String get noRadiologyCentersFound;
String get radiologyCenterDetail;
String get contactCenter;
```

**Add to `lib/locale/language_en.dart`:**
```dart
@override String get browseRadiology => 'Radiology Centers';
@override String get radiologyCenters => 'Radiology Centers';
@override String get scanType => 'Scan Type';
@override String get availableScans => 'Available Scans';
@override String get mriScan => 'MRI';
@override String get ctScan => 'CT Scan';
@override String get xRay => 'X-Ray';
@override String get ultrasound => 'Ultrasound';
@override String get mammogram => 'Mammogram';
@override String get dexaScan => 'DEXA Scan';
@override String get noRadiologyCentersFound => 'No radiology centers found';
@override String get radiologyCenterDetail => 'Center Details';
@override String get contactCenter => 'Contact Center';
```

**Add to `lib/locale/language_ar.dart`:**
```dart
@override String get browseRadiology => 'مراكز الأشعة';
@override String get radiologyCenters => 'مراكز الأشعة';
@override String get scanType => 'نوع الفحص';
@override String get availableScans => 'الفحوصات المتاحة';
@override String get mriScan => 'رنين مغناطيسي';
@override String get ctScan => 'أشعة مقطعية';
@override String get xRay => 'أشعة سينية';
@override String get ultrasound => 'موجات فوق صوتية';
@override String get mammogram => 'ماموجرام';
@override String get dexaScan => 'فحص كثافة العظام';
@override String get noRadiologyCentersFound => 'لا توجد مراكز أشعة';
@override String get radiologyCenterDetail => 'تفاصيل المركز';
@override String get contactCenter => 'تواصل مع المركز';
```

**Add to `lib/locale/language_de.dart`:**
```dart
@override String get browseRadiology => 'Radiologiezentren';
@override String get radiologyCenters => 'Radiologiezentren';
@override String get scanType => 'Untersuchungsart';
@override String get availableScans => 'Verfügbare Untersuchungen';
@override String get mriScan => 'MRT';
@override String get ctScan => 'CT-Scan';
@override String get xRay => 'Röntgen';
@override String get ultrasound => 'Ultraschall';
@override String get mammogram => 'Mammographie';
@override String get dexaScan => 'DEXA-Scan';
@override String get noRadiologyCentersFound => 'Keine Radiologiezentren gefunden';
@override String get radiologyCenterDetail => 'Zentrumdetails';
@override String get contactCenter => 'Zentrum kontaktieren';
```

**Add to `lib/locale/language_fr.dart`:**
```dart
@override String get browseRadiology => 'Centres de radiologie';
@override String get radiologyCenters => 'Centres de radiologie';
@override String get scanType => 'Type d\'examen';
@override String get availableScans => 'Examens disponibles';
@override String get mriScan => 'IRM';
@override String get ctScan => 'Scanner';
@override String get xRay => 'Radiographie';
@override String get ultrasound => 'Échographie';
@override String get mammogram => 'Mammographie';
@override String get dexaScan => 'Ostéodensitométrie';
@override String get noRadiologyCentersFound => 'Aucun centre de radiologie trouvé';
@override String get radiologyCenterDetail => 'Détails du centre';
@override String get contactCenter => 'Contacter le centre';
```

**Add to `lib/locale/language_hi.dart`:**
```dart
@override String get browseRadiology => 'रेडियोलॉजी केंद्र';
@override String get radiologyCenters => 'रेडियोलॉजी केंद्र';
@override String get scanType => 'स्कैन प्रकार';
@override String get availableScans => 'उपलब्ध स्कैन';
@override String get mriScan => 'एमआरआई';
@override String get ctScan => 'सीटी स्कैन';
@override String get xRay => 'एक्स-रे';
@override String get ultrasound => 'अल्ट्रासाउंड';
@override String get mammogram => 'मैमोग्राम';
@override String get dexaScan => 'डेक्सा स्कैन';
@override String get noRadiologyCentersFound => 'कोई रेडियोलॉजी केंद्र नहीं मिला';
@override String get radiologyCenterDetail => 'केंद्र विवरण';
@override String get contactCenter => 'केंद्र से संपर्क करें';
```

---

## Cross-Cutting: Home Screen & Navigation

### Modified Files

```
lib/screens/home/components/quick_services_component.dart
lib/screens/home/home_screen.dart
lib/screens/dashboard/                    # If dashboard has service shortcuts
lib/generated/assets.dart                 # If new icons added
```

---

### Quick Services Grid Update

**Modify `lib/screens/home/components/quick_services_component.dart`:**

Add two new entries to the quick services grid:

```dart
// Existing services:
// Doctors, Clinics, Nurses, Lab Tests, ...

// Add:
QuickServiceItem(
  icon: Icons.home_health_outlined,     // or custom asset icon
  label: locale.value.browseHomeHealthcare,
  onTap: () => Get.to(() => HomeHealthcareListScreen()),
  gradientColors: [appColorPrimary, appColorSecondary],
),
QuickServiceItem(
  icon: Icons.radiology_outlined,       // or custom asset icon
  label: locale.value.browseRadiology,
  onTap: () => Get.to(() => RadiologyListScreen()),
  gradientColors: [appColorPrimary, appColorAccent],
),
```

**Icon styling:**
- Each icon uses `ShaderMask` with `LinearGradient` for the Clinical Elegance gradient effect
- Icon container: `surfaceSubtle` background, 12px radius, 48x48 size
- Label: `primaryTextStyle(size: 12)` below icon, centered

### Navigation Routes

All new screens are navigated to via `Get.to()`:

```dart
// Home Healthcare
Get.to(() => HomeHealthcareListScreen());
Get.to(() => HomeHealthcareDetailScreen(), arguments: homeHealthcareId);
Get.to(() => CreateHomeHealthcareRequestScreen(), arguments: homeHealthcare);
Get.to(() => HomeHealthcareRequestListScreen());
Get.to(() => HomeHealthcareRequestDetailScreen(), arguments: requestId);

// Radiology
Get.to(() => RadiologyListScreen());
Get.to(() => RadiologyDetailScreen(), arguments: radiologyCenterId);
```

### Dashboard Integration (Optional)

If the dashboard has service shortcut cards, add:
- Home Healthcare request count badge
- Quick link to "My Home Healthcare Requests"

---

## Unified Patterns Reference

### Location Badge Widget (reusable inline)

Used on all cards (doctor, clinic, nurse, home healthcare, lab test, radiology):

```dart
Widget locationBadge(Governorate? governorate, City? city) {
  if (governorate == null) return const SizedBox.shrink();
  final text = [governorate.name, city?.name]
      .where((e) => e != null && e.isNotEmpty)
      .join(' - ');
  if (text.isEmpty) return const SizedBox.shrink();

  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: appColorSecondary.withOpacity(0.1),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Text(
      text,
      style: secondaryTextStyle(size: 11, color: appColorSecondary),
    ),
  );
}
```

Consider adding this as a shared component in `lib/components/location_badge.dart` to avoid duplication across cards.

### Glass Info Card (reusable in detail screens)

Used in all detail screens (home healthcare, radiology):

```dart
Widget glassInfoCard({required String title, required Widget child}) {
  return Container(
    width: double.infinity,
    margin: const EdgeInsets.only(bottom: 16),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: isDarkMode.value ? surfaceElevatedDark : surfaceSubtle,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: isDarkMode.value ? glassStrokeDark : glassStrokeLight,
      ),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: boldTextStyle(size: 16)),
        const SizedBox(height: 12),
        child,
      ],
    ),
  );
}
```

Consider adding this as a shared component in `lib/components/glass_info_card.dart`.

### Filter Chip Row (reusable across list screens)

All list screens use the same filter chip pattern. Consider extracting:

```dart
Widget filterChipRow({
  required List<Map<String, String>> filters,
  required String selectedKey,
  required void Function(String) onChanged,
}) {
  return SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Row(
      children: filters.map((filter) {
        final isSelected = filter['key'] == selectedKey;
        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: GestureDetector(
            onTap: () => onChanged(filter['key']!),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? LinearGradient(colors: [appColorPrimary, appColorSecondary])
                    : null,
                color: isSelected ? null : (isDarkMode.value ? surfaceElevatedDark : surfaceSubtle),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                filter['label']!,
                style: isSelected
                    ? boldTextStyle(size: 13, color: Colors.white)
                    : secondaryTextStyle(size: 13),
              ),
            ),
          ),
        );
      }).toList(),
    ),
  );
}
```

---

### Complete File Impact Summary

| Category | New Files | Modified Files |
|----------|-----------|----------------|
| **Phase 1 — Foundation** | 3 (governorate model, city model, picker widget) | 7 (endpoints, APIs, network_utils, 5 locale files) |
| **Phase 2 — Doctors & Clinics** | 0 | ~8 (doctor controller/screen/model/card, clinic controller/screen/model/card) |
| **Phase 3 — Nurses** | 0 | 4 (controller, screen, model, card) |
| **Phase 4 — Home Healthcare** | 12 (full module) | 7 (endpoints, APIs, constants, 5 locale files) |
| **Phase 5 — Lab Tests** | 0 | 4 (controller, screen, model, card) |
| **Phase 6 — Radiology** | 6 (browse module) | 7 (endpoints, APIs, constants, 5 locale files) |
| **Cross-cutting** | 2 (location_badge, glass_info_card shared components) | ~3 (home screen, quick services, dashboard) |
| **Total** | **~23 new files** | **~40 file modifications** |

### Shared Reusable Components (New)

```
lib/components/governorates_city_picker.dart    # Phase 1 — cascading location picker
lib/components/location_badge.dart              # Cross-cutting — location pill widget
lib/components/glass_info_card.dart             # Cross-cutting — glass-bordered info card
```

---

### Implementation Order (Recommended)

1. **Phase 1** first — Foundation provides the shared picker + models used by everything else
2. **Phase 3** (Nurses) — Simplest extension, validates the pattern works
3. **Phase 5** (Lab Tests) — Second extension, confirms consistency
4. **Phase 2** (Doctors & Clinics) — Third extension, may involve more existing code
5. **Phase 6** (Radiology) — New but simpler module (browse only, no requests)
6. **Phase 4** (Home Healthcare) — Largest new module, benefits from all previous patterns being proven
7. **Cross-cutting** — Home screen + shared components last, after all modules exist

---

### Error Handling (All Modules)

All API calls follow the existing error pattern:
```dart
.catchError((e) {
  toast(e.toString());    // nb_utils toast for user feedback
  log("methodName error $e");  // console log for debugging
}).whenComplete(() => isLoading(false));
```

API-level errors (401, 403, 404, 500) are handled by `handleResponse()` in `network_utils.dart`.
Token expiry (401) triggers automatic `reGenerateToken()`.

### Empty States (All List Screens)

All list screens show an empty state when no data:
```
- Centered column layout
- Lottie animation or placeholder icon (gradient-masked)
- "No [items] found" text in secondaryTextStyle(size: 16)
- Optional "Try adjusting your filters" subtitle
```

---

*End of Flutter Specification*
