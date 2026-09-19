# Location Filter Module Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a Vezeeta-style two-step location filter (Governorate → City) for the Espitalia Patient App that integrates with the existing `FilterController` so doctor / clinic / service / category list screens can be filtered by location.

**Architecture:** A self-contained module under `lib/screens/location_filter/` with its own models, API layer, GetStorage-backed cache service, and two GetX-driven full-screen flows. Returns a typed `LocationFilterResult` to the caller via `Get.back(result: ...)`. Integrates by extending the existing `FilterController` with new reactive fields and adding a tappable Location tile to `FilterScreen`. Aggressive caching (7-day TTL) makes subsequent loads instant.

**Tech Stack:** Flutter 3.0+, Dart 3.0+, GetX 4.7.2, GetStorage, nb_utils, Plus Jakarta Sans + Outfit (Google Fonts), existing project design tokens (16px card radius, 12px input radius, navy/teal palette).

---

## Spec Divergence Notes (Important — Read First)

The reference spec (`LOCATION_FILTER_MODULE.md`) and `CLAUDE.md` describe an existing filter system that does not match the actual code on this branch. Specifically:

| Spec Claim | Reality |
| --- | --- |
| `FilterController` has `selectedGovernorateId` / `selectedCityId` reactive vars | Does not exist. Current vars: `selectedClinicData`, `selectedServiceData`, `selectedCategoryData`, `selectedServiceType`, price/rating ranges. |
| `FilterController` has `activeFilterCount` getter | Does not exist. Counts are scattered across `seleClinicFilterCount`, `seleFilterCount`, `selePriceFilterCount`, `seleRatingFilterCount`, `seleCategoryFilterCount`. |
| `FilterController` has `applyFilters()` method | Has `applyFilter(String type)` (singular) instead. |
| `lib/screens/booking/filter/model/filter_params.dart` exists | File and `model/` directory do not exist. |
| `lib/screens/booking/filter/components/filter_location_component.dart` exists | Does not exist. |
| `lib/components/filter_count_badge.dart` is unified across modules | File was deleted on this branch (see `git status`). |
| `FilterController.onInit` reads `FilterParams` from `Get.arguments` | Reads a positional `List` from `Get.arguments`. |
| Doctor / clinic / service / category list controllers already accept governorate/city filters | They do not — `DoctorListController` has only `clinicId`, `specialtyId`, `serviceType`, rating fields. `core_apis.dart` `getDoctors()` / `getClinics()` / `getServiceList()` do not accept governorate or city query params. |

**How this plan handles the divergence:**

1. **Build the module (Phases 1–3) exactly as specified** — the location module itself stands alone with no dependency on the (non-existent) `FilterParams` or `FilterLocationComponent`.
2. **Phase 4 integration is additive** — extend `FilterController` with new reactive fields (`selectedGovernorateId`, `selectedCityId`, `selectedGovernorateName`, `selectedCityName`) plus a `locationFilterCount` getter; add a tappable Location tile to `FilterScreen`. No existing FilterController fields or call sites are modified.
3. **End-to-end API filtering is Phase 5 (optional, gated on backend support)** — the spec's section 19 says "do not modify list screens because they already read FilterController." That is false on this branch, so passing `governorate_id` / `city_id` through to `core_apis.dart` and list controllers is documented in Phase 5 as a follow-on. Phases 1–4 deliver a complete location selection UX with persisted state, even if the list screens themselves do not yet send the filter to the backend.

**Engineer instruction:** After Phase 4 ends, ask the user whether to proceed with Phase 5 (API wiring) or stop. Phases 1–4 are the spec's intent; Phase 5 is the part the spec quietly assumed was already done.

---

## File Structure

### New files (created by this plan)

```
docs/superpowers/plans/2026-04-28-location-filter-module.md   # this file

lib/api/
└── location_apis.dart                                         # LocationApis class

lib/screens/location_filter/
├── governorate_selection_screen.dart
├── governorate_selection_controller.dart
├── city_selection_screen.dart
├── city_selection_controller.dart
├── components/
│   ├── location_search_bar.dart
│   ├── governorate_list_tile.dart
│   ├── city_list_tile.dart
│   ├── selected_governorate_header.dart
│   ├── all_locations_tile.dart
│   ├── location_count_badge.dart
│   ├── empty_cities_widget.dart
│   └── location_shimmer.dart
├── service/
│   └── location_cache_service.dart
└── models/
    ├── governorate_model.dart
    ├── city_model.dart
    ├── governorates_response.dart
    ├── cities_response.dart
    └── location_filter_result.dart
```

### Modified files

```
lib/utils/api_end_points.dart                                  # add 2 endpoint constants
lib/locale/languages.dart                                      # add ~24 abstract getters
lib/locale/language_en.dart                                    # implement keys (English copy)
lib/locale/language_ar.dart                                    # implement keys (Arabic copy)
lib/locale/language_hi.dart                                    # implement keys (English fallback)
lib/locale/language_fr.dart                                    # implement keys (English fallback)
lib/locale/language_de.dart                                    # implement keys (English fallback)
lib/screens/booking/filter/filter_controller.dart              # add location reactive fields + getter
lib/screens/booking/filter/filter_screen.dart                  # add Location tile entry point
lib/main.dart                                                  # call LocationCacheService.init() on app start
```

### Optional Phase 5 modifications (gated on backend support)

```
lib/api/core_apis.dart                                         # add governorate_id / city_id query params to getDoctors, getClinics, getServiceList
lib/screens/doctor/doctor_list_controller.dart                 # add governorateId/cityId reactive fields
lib/screens/clinic/clinic_list_controller.dart                 # same
lib/screens/service/service_list_controller.dart               # same
lib/screens/booking/filter/filter_controller.dart              # extend applyFilter() to push governorate/city to list controllers
```

---

# Phase 1 — Foundation (no UI yet)

Goal: endpoint constants, models, cache service, API layer, locale keys. Result: `flutter analyze` clean, no UI.

## Task 1: Add endpoint constants

**Files:**
- Modify: `lib/utils/api_end_points.dart` (add 2 lines)

- [ ] **Step 1: Append constants to `APIEndPoints` class**

Open `lib/utils/api_end_points.dart`. After the line `static const String updateIncidentStatus = 'update-incident-status';` and before the closing `}`, insert:

```dart

  //Location
  static const String governorates = 'governorates';
  static const String cities = 'cities';
```

- [ ] **Step 2: Run analyzer**

```bash
flutter analyze lib/utils/api_end_points.dart
```

Expected: No issues found.

- [ ] **Step 3: Commit**

```bash
git add lib/utils/api_end_points.dart
git commit -m "feat(location): add governorates and cities endpoint constants"
```

## Task 2: Create GovernorateModel

**Files:**
- Create: `lib/screens/location_filter/models/governorate_model.dart`

- [ ] **Step 1: Create model file**

Create `lib/screens/location_filter/models/governorate_model.dart`:

```dart
class GovernorateModel {
  final int id;
  final String name;
  final String? nameAr;
  final String? nameEn;
  final int doctorsCount;
  final int citiesCount;

  const GovernorateModel({
    required this.id,
    required this.name,
    this.nameAr,
    this.nameEn,
    this.doctorsCount = 0,
    this.citiesCount = 0,
  });

  factory GovernorateModel.fromJson(Map<String, dynamic> json) {
    return GovernorateModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: (json['name'] ?? json['name_en'] ?? json['name_ar'] ?? '') as String,
      nameAr: json['name_ar'] as String?,
      nameEn: json['name_en'] as String?,
      doctorsCount: (json['doctors_count'] as num?)?.toInt() ?? 0,
      citiesCount: (json['cities_count'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'name_ar': nameAr,
        'name_en': nameEn,
        'doctors_count': doctorsCount,
        'cities_count': citiesCount,
      };

  String displayName(String localeCode) {
    if (localeCode == 'ar' && (nameAr ?? '').isNotEmpty) return nameAr!;
    if ((nameEn ?? '').isNotEmpty) return nameEn!;
    return name;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is GovernorateModel && other.id == id);

  @override
  int get hashCode => id.hashCode;
}
```

- [ ] **Step 2: Run analyzer**

```bash
flutter analyze lib/screens/location_filter/models/governorate_model.dart
```

Expected: No issues found.

- [ ] **Step 3: Commit**

```bash
git add lib/screens/location_filter/models/governorate_model.dart
git commit -m "feat(location): add GovernorateModel"
```

## Task 3: Create CityModel

**Files:**
- Create: `lib/screens/location_filter/models/city_model.dart`

- [ ] **Step 1: Create model file**

Create `lib/screens/location_filter/models/city_model.dart`:

```dart
class CityModel {
  final int id;
  final int governorateId;
  final String name;
  final String? nameAr;
  final String? nameEn;
  final int doctorsCount;

  const CityModel({
    required this.id,
    required this.governorateId,
    required this.name,
    this.nameAr,
    this.nameEn,
    this.doctorsCount = 0,
  });

  factory CityModel.fromJson(Map<String, dynamic> json) {
    return CityModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      governorateId: (json['governorate_id'] as num?)?.toInt() ?? 0,
      name: (json['name'] ?? json['name_en'] ?? json['name_ar'] ?? '') as String,
      nameAr: json['name_ar'] as String?,
      nameEn: json['name_en'] as String?,
      doctorsCount: (json['doctors_count'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'governorate_id': governorateId,
        'name': name,
        'name_ar': nameAr,
        'name_en': nameEn,
        'doctors_count': doctorsCount,
      };

  String displayName(String localeCode) {
    if (localeCode == 'ar' && (nameAr ?? '').isNotEmpty) return nameAr!;
    if ((nameEn ?? '').isNotEmpty) return nameEn!;
    return name;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is CityModel && other.id == id);

  @override
  int get hashCode => id.hashCode;
}
```

- [ ] **Step 2: Run analyzer**

```bash
flutter analyze lib/screens/location_filter/models/city_model.dart
```

Expected: No issues found.

- [ ] **Step 3: Commit**

```bash
git add lib/screens/location_filter/models/city_model.dart
git commit -m "feat(location): add CityModel"
```

## Task 4: Create response models

**Files:**
- Create: `lib/screens/location_filter/models/governorates_response.dart`
- Create: `lib/screens/location_filter/models/cities_response.dart`

- [ ] **Step 1: Create governorates response**

Create `lib/screens/location_filter/models/governorates_response.dart`:

```dart
import 'governorate_model.dart';

class GovernoratesResponse {
  final bool status;
  final String message;
  final List<GovernorateModel> data;

  const GovernoratesResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory GovernoratesResponse.fromJson(Map<String, dynamic> json) {
    final raw = json['data'];
    final list = raw is List
        ? raw
            .whereType<Map>()
            .map((e) => GovernorateModel.fromJson(Map<String, dynamic>.from(e)))
            .toList()
        : <GovernorateModel>[];
    return GovernoratesResponse(
      status: json['status'] as bool? ?? false,
      message: (json['message'] as String?) ?? '',
      data: list,
    );
  }
}
```

- [ ] **Step 2: Create cities response**

Create `lib/screens/location_filter/models/cities_response.dart`:

```dart
import 'city_model.dart';

class CitiesResponse {
  final bool status;
  final String message;
  final List<CityModel> data;

  const CitiesResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory CitiesResponse.fromJson(Map<String, dynamic> json) {
    final raw = json['data'];
    final list = raw is List
        ? raw
            .whereType<Map>()
            .map((e) => CityModel.fromJson(Map<String, dynamic>.from(e)))
            .toList()
        : <CityModel>[];
    return CitiesResponse(
      status: json['status'] as bool? ?? false,
      message: (json['message'] as String?) ?? '',
      data: list,
    );
  }
}
```

- [ ] **Step 3: Run analyzer**

```bash
flutter analyze lib/screens/location_filter/models/
```

Expected: No issues found.

- [ ] **Step 4: Commit**

```bash
git add lib/screens/location_filter/models/governorates_response.dart lib/screens/location_filter/models/cities_response.dart
git commit -m "feat(location): add governorate/city response wrappers"
```

## Task 5: Create LocationFilterResult

**Files:**
- Create: `lib/screens/location_filter/models/location_filter_result.dart`

- [ ] **Step 1: Create result file**

Create `lib/screens/location_filter/models/location_filter_result.dart`:

```dart
import 'city_model.dart';
import 'governorate_model.dart';

class LocationFilterResult {
  final int? governorateId;
  final int? cityId;
  final GovernorateModel? governorate;
  final CityModel? city;
  final bool cleared;

  const LocationFilterResult({
    this.governorateId,
    this.cityId,
    this.governorate,
    this.city,
    this.cleared = false,
  });

  const LocationFilterResult.cleared()
      : governorateId = null,
        cityId = null,
        governorate = null,
        city = null,
        cleared = true;
}
```

- [ ] **Step 2: Run analyzer**

```bash
flutter analyze lib/screens/location_filter/models/location_filter_result.dart
```

Expected: No issues found.

- [ ] **Step 3: Commit**

```bash
git add lib/screens/location_filter/models/location_filter_result.dart
git commit -m "feat(location): add LocationFilterResult"
```

## Task 6: Create LocationCacheService

**Files:**
- Create: `lib/screens/location_filter/service/location_cache_service.dart`

- [ ] **Step 1: Create cache service**

Create `lib/screens/location_filter/service/location_cache_service.dart`:

```dart
import 'package:get_storage/get_storage.dart';

import '../models/city_model.dart';
import '../models/governorate_model.dart';

class LocationCacheService {
  static const String _govKey = 'location_cache.governorates';
  static const String _govCachedAtKey = 'location_cache.governorates.cached_at';
  static String _citiesKey(int govId) => 'location_cache.cities.$govId';
  static String _citiesCachedAtKey(int govId) =>
      'location_cache.cities.$govId.cached_at';
  static const String _lastGovKey = 'location_cache.last_selected_governorate_id';
  static const String _lastCityKey = 'location_cache.last_selected_city_id';

  static const Duration _ttl = Duration(days: 7);

  late final GetStorage _box;
  bool _initialized = false;

  static final LocationCacheService _instance = LocationCacheService._();
  factory LocationCacheService() => _instance;
  LocationCacheService._();

  Future<void> init() async {
    if (_initialized) return;
    await GetStorage.init('location_cache');
    _box = GetStorage('location_cache');
    _initialized = true;
  }

  bool _isFresh(int? cachedAtMillis) {
    if (cachedAtMillis == null) return false;
    final cachedAt = DateTime.fromMillisecondsSinceEpoch(cachedAtMillis);
    return DateTime.now().difference(cachedAt) < _ttl;
  }

  List<GovernorateModel>? getCachedGovernorates() {
    if (!_initialized) return null;
    final cachedAt = _box.read<int>(_govCachedAtKey);
    if (!_isFresh(cachedAt)) return null;
    final raw = _box.read<List>(_govKey);
    if (raw == null) return null;
    return raw
        .whereType<Map>()
        .map((e) => GovernorateModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<void> cacheGovernorates(List<GovernorateModel> list) async {
    if (!_initialized) return;
    await _box.write(_govKey, list.map((g) => g.toJson()).toList());
    await _box.write(_govCachedAtKey, DateTime.now().millisecondsSinceEpoch);
  }

  List<CityModel>? getCachedCitiesFor(int governorateId) {
    if (!_initialized) return null;
    final cachedAt = _box.read<int>(_citiesCachedAtKey(governorateId));
    if (!_isFresh(cachedAt)) return null;
    final raw = _box.read<List>(_citiesKey(governorateId));
    if (raw == null) return null;
    return raw
        .whereType<Map>()
        .map((e) => CityModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<void> cacheCitiesFor(int governorateId, List<CityModel> list) async {
    if (!_initialized) return;
    await _box.write(
        _citiesKey(governorateId), list.map((c) => c.toJson()).toList());
    await _box.write(
        _citiesCachedAtKey(governorateId), DateTime.now().millisecondsSinceEpoch);
  }

  int? getLastSelectedGovernorateId() {
    if (!_initialized) return null;
    return _box.read<int>(_lastGovKey);
  }

  int? getLastSelectedCityId() {
    if (!_initialized) return null;
    return _box.read<int>(_lastCityKey);
  }

  Future<void> saveLastSelection({int? governorateId, int? cityId}) async {
    if (!_initialized) return;
    if (governorateId == null) {
      await _box.remove(_lastGovKey);
    } else {
      await _box.write(_lastGovKey, governorateId);
    }
    if (cityId == null) {
      await _box.remove(_lastCityKey);
    } else {
      await _box.write(_lastCityKey, cityId);
    }
  }

  Future<void> clearLastSelection() async {
    if (!_initialized) return;
    await _box.remove(_lastGovKey);
    await _box.remove(_lastCityKey);
  }
}
```

- [ ] **Step 2: Run analyzer**

```bash
flutter analyze lib/screens/location_filter/service/location_cache_service.dart
```

Expected: No issues found.

- [ ] **Step 3: Commit**

```bash
git add lib/screens/location_filter/service/location_cache_service.dart
git commit -m "feat(location): add GetStorage-backed LocationCacheService with 7-day TTL"
```

## Task 7: Initialize cache service on app start

**Files:**
- Modify: `lib/main.dart` (add init call)

- [ ] **Step 1: Locate the init block in main.dart**

Open `lib/main.dart` and find the `main()` function. The existing app initialization calls `await GetStorage.init();` near the top. Immediately after that line (before the app starts running), add:

```dart
  await LocationCacheService().init();
```

And add the import at the top of `lib/main.dart`:

```dart
import 'screens/location_filter/service/location_cache_service.dart';
```

(If the imports section uses package-prefixed paths, use `package:kivicare_patient/screens/location_filter/service/location_cache_service.dart` instead. Match the file's existing convention.)

- [ ] **Step 2: Run analyzer**

```bash
flutter analyze lib/main.dart
```

Expected: No issues found.

- [ ] **Step 3: Commit**

```bash
git add lib/main.dart
git commit -m "feat(location): initialize LocationCacheService on app start"
```

## Task 8: Create LocationApis

**Files:**
- Create: `lib/api/location_apis.dart`

- [ ] **Step 1: Create API class**

Create `lib/api/location_apis.dart`:

```dart
import 'package:nb_utils/nb_utils.dart';

import '../network/network_utils.dart';
import '../screens/location_filter/models/cities_response.dart';
import '../screens/location_filter/models/city_model.dart';
import '../screens/location_filter/models/governorate_model.dart';
import '../screens/location_filter/models/governorates_response.dart';
import '../utils/api_end_points.dart';

class LocationApis {
  static Future<List<GovernorateModel>> getGovernorates() async {
    final res = GovernoratesResponse.fromJson(
      await handleResponse(
        await buildHttpResponse(
          APIEndPoints.governorates,
          method: HttpMethodType.GET,
        ),
      ),
    );
    return res.data;
  }

  static Future<List<CityModel>> getCitiesByGovernorate(
    int governorateId, {
    String? search,
  }) async {
    final searchQ = (search ?? '').trim();
    final searchPart = searchQ.isEmpty ? '' : '&search=$searchQ';
    final endpoint =
        '${APIEndPoints.cities}?governorate_id=$governorateId$searchPart';
    final res = CitiesResponse.fromJson(
      await handleResponse(
        await buildHttpResponse(endpoint, method: HttpMethodType.GET),
      ),
    );
    return res.data;
  }
}
```

- [ ] **Step 2: Run analyzer**

```bash
flutter analyze lib/api/location_apis.dart
```

Expected: No issues found.

- [ ] **Step 3: Commit**

```bash
git add lib/api/location_apis.dart
git commit -m "feat(location): add LocationApis with getGovernorates and getCitiesByGovernorate"
```

## Task 9: Add localization keys (abstract definitions)

**Files:**
- Modify: `lib/locale/languages.dart` (add abstract getters)

- [ ] **Step 1: Append abstract getters**

Open `lib/locale/languages.dart`. Inside the `BaseLanguage` abstract class, before the closing `}`, append these abstract getters (alphabetized for ease of merging):

```dart

  // Location filter
  String get selectGovernorate;
  String get selectCity;
  String get searchGovernorate;
  String get searchCity;
  String get clearSearch;
  String get allGovernorates;
  String get allCities;
  String get showDoctorsFromAllGovernorates;
  String get showAllCitiesInGovernorate;
  String get showingCitiesInGovernorate;
  String get xDoctors; // template: "{count} doctors"
  String get xCities; // template: "{count} cities"
  String get noGovernoratesFound;
  String get noCitiesFound;
  String get noResultsFor; // template: 'No results for "{query}"'
  String get noCitiesAvailable;
  String get applyGovernorateOnly;
  String get changeGovernorate;
  String get clear;
  String get change;
  String get retry;
  String get failedToLoadGovernorates;
  String get failedToLoadCities;
  String get allLocations;
  String get locationFilterFormat; // template: "{governorate} > {city}"
```

- [ ] **Step 2: Run analyzer (expect failures)**

```bash
flutter analyze lib/locale/
```

Expected: Errors in `language_en.dart`, `language_ar.dart`, `language_hi.dart`, `language_fr.dart`, `language_de.dart` saying each must implement the missing getters. This is expected — Tasks 10–14 fix it.

- [ ] **Step 3: Do not commit yet** — leave the working tree dirty until all 5 language files are filled in (Tasks 10–14). A single commit covers them all.

## Task 10: Implement EN locale keys

**Files:**
- Modify: `lib/locale/language_en.dart`

- [ ] **Step 1: Append implementations**

Open `lib/locale/language_en.dart`. Before the closing `}` of `LanguageEn`, append:

```dart

  @override
  String get selectGovernorate => 'Select Governorate';

  @override
  String get selectCity => 'Select City';

  @override
  String get searchGovernorate => 'Search governorate';

  @override
  String get searchCity => 'Search city';

  @override
  String get clearSearch => 'Clear search';

  @override
  String get allGovernorates => 'All Governorates';

  @override
  String get allCities => 'All Cities';

  @override
  String get showDoctorsFromAllGovernorates => 'Show doctors from all governorates';

  @override
  String get showAllCitiesInGovernorate => 'Show all cities in this governorate';

  @override
  String get showingCitiesInGovernorate => 'Showing cities in this governorate';

  @override
  String get xDoctors => '{count} doctors';

  @override
  String get xCities => '{count} cities';

  @override
  String get noGovernoratesFound => 'No governorates found';

  @override
  String get noCitiesFound => 'No cities found';

  @override
  String get noResultsFor => 'No results for "{query}"';

  @override
  String get noCitiesAvailable => 'No cities available';

  @override
  String get applyGovernorateOnly => 'Apply Governorate Only';

  @override
  String get changeGovernorate => 'Change Governorate';

  @override
  String get clear => 'Clear';

  @override
  String get change => 'Change';

  @override
  String get retry => 'Retry';

  @override
  String get failedToLoadGovernorates => 'Failed to load governorates';

  @override
  String get failedToLoadCities => 'Failed to load cities';

  @override
  String get allLocations => 'All Locations';

  @override
  String get locationFilterFormat => '{governorate} > {city}';
```

- [ ] **Step 2: Run analyzer (expect failures still)**

```bash
flutter analyze lib/locale/language_en.dart
```

Expected: Errors only in the other 4 language files, not in `language_en.dart`.

## Task 11: Implement AR locale keys

**Files:**
- Modify: `lib/locale/language_ar.dart`

- [ ] **Step 1: Append implementations**

Open `lib/locale/language_ar.dart`. Before the closing `}`, append:

```dart

  @override
  String get selectGovernorate => 'اختر المحافظة';

  @override
  String get selectCity => 'اختر المدينة';

  @override
  String get searchGovernorate => 'ابحث عن محافظة';

  @override
  String get searchCity => 'ابحث عن مدينة';

  @override
  String get clearSearch => 'مسح البحث';

  @override
  String get allGovernorates => 'كل المحافظات';

  @override
  String get allCities => 'كل المدن';

  @override
  String get showDoctorsFromAllGovernorates => 'عرض الأطباء من كل المحافظات';

  @override
  String get showAllCitiesInGovernorate => 'عرض كل المدن في هذه المحافظة';

  @override
  String get showingCitiesInGovernorate => 'عرض المدن في هذه المحافظة';

  @override
  String get xDoctors => '{count} طبيب';

  @override
  String get xCities => '{count} مدينة';

  @override
  String get noGovernoratesFound => 'لم يتم العثور على محافظات';

  @override
  String get noCitiesFound => 'لم يتم العثور على مدن';

  @override
  String get noResultsFor => 'لا توجد نتائج لـ "{query}"';

  @override
  String get noCitiesAvailable => 'لا توجد مدن متاحة';

  @override
  String get applyGovernorateOnly => 'تطبيق المحافظة فقط';

  @override
  String get changeGovernorate => 'تغيير المحافظة';

  @override
  String get clear => 'مسح';

  @override
  String get change => 'تغيير';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get failedToLoadGovernorates => 'تعذر تحميل المحافظات';

  @override
  String get failedToLoadCities => 'تعذر تحميل المدن';

  @override
  String get allLocations => 'كل المواقع';

  @override
  String get locationFilterFormat => '{governorate} > {city}';
```

- [ ] **Step 2: Run analyzer (expect failures still in hi/fr/de)**

```bash
flutter analyze lib/locale/language_ar.dart
```

## Task 12–14: Implement HI, FR, DE locale keys (English fallback)

**Files:**
- Modify: `lib/locale/language_hi.dart`
- Modify: `lib/locale/language_fr.dart`
- Modify: `lib/locale/language_de.dart`

PRODUCT.md only commits to EN and AR. The other three locale classes exist in code (they're routed through `app_localizations.dart`) so they must compile, but the strings can use the English copy as a placeholder. This avoids blocking the build while documenting that those translations are out of scope here.

- [ ] **Step 1: Append the same English block from Task 10 to each file**

Open `lib/locale/language_hi.dart`, `lib/locale/language_fr.dart`, and `lib/locale/language_de.dart`. To each, before the closing `}`, append the **exact same block of overrides from Task 10**. Do this verbatim — the strings are identical English fallbacks for now.

- [ ] **Step 2: Run analyzer over the whole locale folder**

```bash
flutter analyze lib/locale/
```

Expected: No issues found.

- [ ] **Step 3: Commit Tasks 9–14 as one atomic locale change**

```bash
git add lib/locale/languages.dart lib/locale/language_en.dart lib/locale/language_ar.dart
git commit -m "feat(location): add localization keys for governorate/city filter"
```

## Task 15: Phase 1 verification

- [ ] **Step 1: Run full analyzer**

```bash
flutter analyze
```

Expected: No new issues. Pre-existing warnings in `payment_screen.dart` (Radio deprecation) and theme files (AppBarTheme color) are acceptable per CLAUDE.md.

- [ ] **Step 2: Confirm files exist**

```bash
ls lib/screens/location_filter/models/ lib/screens/location_filter/service/ lib/api/location_apis.dart
```

Expected output should include: `governorate_model.dart`, `city_model.dart`, `governorates_response.dart`, `cities_response.dart`, `location_filter_result.dart`, `location_cache_service.dart`, `location_apis.dart`.

- [ ] **Step 3: Stop and report**

Report Phase 1 complete. List files created. Show analyzer output. Wait for user to say "continue Phase 2" before proceeding.

---

# Phase 2 — Governorate Selection Screen

Goal: full UI flow to browse, search, and select a governorate, with cache-first rendering and pre-highlight of previous selection.

## Task 16: Build LocationShimmer component

**Files:**
- Create: `lib/screens/location_filter/components/location_shimmer.dart`

- [ ] **Step 1: Create shimmer widget**

Create `lib/screens/location_filter/components/location_shimmer.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

import '../../../utils/app_common.dart';
import '../../../utils/colors.dart';

class LocationShimmer extends StatelessWidget {
  final int itemCount;
  const LocationShimmer({super.key, this.itemCount = 6});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final dark = isDarkMode.value;
      return Shimmer.fromColors(
        baseColor: dark ? shimmerBaseDark : shimmerBase,
        highlightColor: dark ? shimmerHighlightDark : shimmerHighlight,
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          itemCount: itemCount,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (_, __) => Container(
            height: 64,
            decoration: BoxDecoration(
              color: dark ? surfaceElevatedDark : surfaceElevated,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      );
    });
  }
}
```

- [ ] **Step 2: Run analyzer**

```bash
flutter analyze lib/screens/location_filter/components/location_shimmer.dart
```

Expected: No issues found.

- [ ] **Step 3: Commit**

```bash
git add lib/screens/location_filter/components/location_shimmer.dart
git commit -m "feat(location): add LocationShimmer placeholder component"
```

## Task 17: Build LocationSearchBar component

**Files:**
- Create: `lib/screens/location_filter/components/location_search_bar.dart`

- [ ] **Step 1: Create search bar**

Create `lib/screens/location_filter/components/location_search_bar.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../main.dart';
import '../../../utils/app_common.dart';
import '../../../utils/colors.dart';

class LocationSearchBar extends StatelessWidget {
  final String hintText;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const LocationSearchBar({
    super.key,
    required this.hintText,
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final dark = isDarkMode.value;
      return Container(
        margin: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        decoration: BoxDecoration(
          color: dark ? inputFillColorDark : inputFillColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: TextField(
          controller: controller,
          onChanged: onChanged,
          style: primaryTextStyle(size: 16),
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: hintText,
            hintStyle: secondaryTextStyle(size: 14),
            prefixIcon: Icon(
              Icons.search,
              color: dark ? textTertiaryDark : appBodyColor,
              size: 20,
            ),
            suffixIcon: controller.text.isEmpty
                ? null
                : IconButton(
                    icon: Icon(
                      Icons.close,
                      color: dark ? textTertiaryDark : appBodyColor,
                      size: 18,
                    ),
                    onPressed: () {
                      controller.clear();
                      onChanged('');
                    },
                    tooltip: locale.value.clearSearch,
                  ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          ),
        ),
      );
    });
  }
}
```

- [ ] **Step 2: Run analyzer**

```bash
flutter analyze lib/screens/location_filter/components/location_search_bar.dart
```

Expected: No issues found.

- [ ] **Step 3: Commit**

```bash
git add lib/screens/location_filter/components/location_search_bar.dart
git commit -m "feat(location): add LocationSearchBar"
```

## Task 18: Build LocationCountBadge component

**Files:**
- Create: `lib/screens/location_filter/components/location_count_badge.dart`

- [ ] **Step 1: Create badge**

Create `lib/screens/location_filter/components/location_count_badge.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../utils/colors.dart';

class LocationCountBadge extends StatelessWidget {
  final int count;
  final String labelTemplate; // e.g., "{count} doctors"

  const LocationCountBadge({
    super.key,
    required this.count,
    required this.labelTemplate,
  });

  @override
  Widget build(BuildContext context) {
    if (count <= 0) return const SizedBox.shrink();
    final label = labelTemplate.replaceAll('{count}', count.toString());
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: lightAccentColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: secondaryTextStyle(size: 12, color: appColorSecondary),
      ),
    );
  }
}
```

- [ ] **Step 2: Run analyzer**

```bash
flutter analyze lib/screens/location_filter/components/location_count_badge.dart
```

Expected: No issues found.

- [ ] **Step 3: Commit**

```bash
git add lib/screens/location_filter/components/location_count_badge.dart
git commit -m "feat(location): add LocationCountBadge"
```

## Task 19: Build AllLocationsTile component

**Files:**
- Create: `lib/screens/location_filter/components/all_locations_tile.dart`

- [ ] **Step 1: Create tile**

Create `lib/screens/location_filter/components/all_locations_tile.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../utils/app_common.dart';
import '../../../utils/colors.dart';

class AllLocationsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const AllLocationsTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final dark = isDarkMode.value;
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: dark ? surfaceElevatedDark : surfaceSubtle,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: dark ? borderColorDark : whiteBorderColor,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: lightAccentColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: appColorSecondary, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(title, style: boldTextStyle(size: 16)),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: secondaryTextStyle(size: 13),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: dark ? textTertiaryDark : appBodyColor,
                size: 14,
              ),
            ],
          ),
        ),
      );
    });
  }
}
```

- [ ] **Step 2: Run analyzer**

```bash
flutter analyze lib/screens/location_filter/components/all_locations_tile.dart
```

Expected: No issues found.

- [ ] **Step 3: Commit**

```bash
git add lib/screens/location_filter/components/all_locations_tile.dart
git commit -m "feat(location): add AllLocationsTile"
```

## Task 20: Build GovernorateListTile component

**Files:**
- Create: `lib/screens/location_filter/components/governorate_list_tile.dart`

- [ ] **Step 1: Create tile**

Create `lib/screens/location_filter/components/governorate_list_tile.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../main.dart';
import '../../../utils/app_common.dart';
import '../../../utils/colors.dart';
import '../models/governorate_model.dart';
import 'location_count_badge.dart';

class GovernorateListTile extends StatelessWidget {
  final GovernorateModel governorate;
  final bool selected;
  final VoidCallback onTap;

  const GovernorateListTile({
    super.key,
    required this.governorate,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final lang = languageConfiguration.value.languageCode;
    return Obx(() {
      final dark = isDarkMode.value;
      final bgColor = selected
          ? (dark ? appColorSecondary.withOpacity(0.15) : lightAccentColor)
          : Colors.transparent;
      final borderColorRes = selected
          ? appColorSecondary
          : (dark ? borderColorDark : whiteBorderColor);
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColorRes, width: selected ? 1.5 : 1),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      governorate.displayName(lang),
                      style: selected
                          ? boldTextStyle(size: 16, color: appColorSecondary)
                          : primaryTextStyle(size: 16),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (governorate.doctorsCount > 0) ...[
                      const SizedBox(height: 6),
                      LocationCountBadge(
                        count: governorate.doctorsCount,
                        labelTemplate: locale.value.xDoctors,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                selected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                color: selected
                    ? appColorSecondary
                    : (dark ? textTertiaryDark : appBodyColor),
                size: 22,
              ),
            ],
          ),
        ),
      );
    });
  }
}
```

> **Note:** `languageConfiguration` is the existing reactive in `lib/main.dart` exposing `languageCode`. If the actual variable name differs in your code, replace `languageConfiguration.value.languageCode` with the project's accessor (commonly `selectedLanguageCode.value` from `lib/utils/app_common.dart` per `network_utils.dart` line 34). Use the same accessor used elsewhere for consistency.

- [ ] **Step 2: Verify the locale-code accessor**

```bash
grep -rn "selectedLanguageCode" lib/main.dart lib/utils/app_common.dart | head -5
```

Use whichever is currently exported (likely `selectedLanguageCode` from `app_common.dart`). Update the import and the call in the tile if needed.

- [ ] **Step 3: Run analyzer**

```bash
flutter analyze lib/screens/location_filter/components/governorate_list_tile.dart
```

Expected: No issues found.

- [ ] **Step 4: Commit**

```bash
git add lib/screens/location_filter/components/governorate_list_tile.dart
git commit -m "feat(location): add GovernorateListTile with selected/unselected states"
```

## Task 21: Build GovernorateSelectionController

**Files:**
- Create: `lib/screens/location_filter/governorate_selection_controller.dart`

- [ ] **Step 1: Create controller**

Create `lib/screens/location_filter/governorate_selection_controller.dart`:

```dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../api/location_apis.dart';
import '../../utils/app_common.dart';
import 'models/governorate_model.dart';
import 'service/location_cache_service.dart';

class GovernorateSelectionController extends GetxController {
  final int? initiallySelectedId;

  GovernorateSelectionController({this.initiallySelectedId});

  final RxList<GovernorateModel> governorates = <GovernorateModel>[].obs;
  final RxList<GovernorateModel> filteredGovernorates =
      <GovernorateModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;
  final RxString searchQuery = ''.obs;
  final Rxn<int> currentSelectedId = Rxn<int>();

  final TextEditingController searchTextController = TextEditingController();

  Timer? _searchDebounce;
  final LocationCacheService _cache = LocationCacheService();

  @override
  void onInit() {
    super.onInit();
    if (initiallySelectedId != null) {
      currentSelectedId.value = initiallySelectedId;
    } else {
      currentSelectedId.value = _cache.getLastSelectedGovernorateId();
    }
    loadGovernorates();
  }

  @override
  void onClose() {
    _searchDebounce?.cancel();
    searchTextController.dispose();
    super.onClose();
  }

  Future<void> loadGovernorates({bool forceNetwork = false}) async {
    error.value = '';
    final cached = _cache.getCachedGovernorates();
    if (!forceNetwork && cached != null && cached.isNotEmpty) {
      governorates.assignAll(cached);
      _applyFilter();
      _refreshFromNetworkSilently();
      return;
    }
    isLoading.value = true;
    try {
      final list = await LocationApis.getGovernorates();
      governorates.assignAll(list);
      _applyFilter();
      await _cache.cacheGovernorates(list);
    } catch (e) {
      error.value = e.toString();
      log('GovernorateSelectionController.loadGovernorates: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _refreshFromNetworkSilently() async {
    try {
      final list = await LocationApis.getGovernorates();
      governorates.assignAll(list);
      _applyFilter();
      await _cache.cacheGovernorates(list);
    } catch (e) {
      log('GovernorateSelectionController.refreshSilently: $e');
    }
  }

  void onSearchChanged(String query) {
    searchQuery.value = query;
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 200), _applyFilter);
  }

  void _applyFilter() {
    final q = _normalize(searchQuery.value);
    if (q.isEmpty) {
      filteredGovernorates.assignAll(governorates);
      return;
    }
    final lang = selectedLanguageCode.value;
    filteredGovernorates.assignAll(
      governorates.where((g) {
        final display = _normalize(g.displayName(lang));
        final en = _normalize(g.nameEn ?? '');
        final ar = _normalize(g.nameAr ?? '');
        return display.contains(q) || en.contains(q) || ar.contains(q);
      }),
    );
  }

  String _normalize(String s) {
    var n = s.toLowerCase().trim();
    // Arabic letter-form normalization
    n = n
        .replaceAll(RegExp('[إأآا]'), 'ا')
        .replaceAll('ى', 'ي')
        .replaceAll('ة', 'ه')
        .replaceAll(RegExp('[ً-ٟ]'), ''); // remove diacritics
    return n;
  }
}
```

- [ ] **Step 2: Run analyzer**

```bash
flutter analyze lib/screens/location_filter/governorate_selection_controller.dart
```

Expected: No issues found.

- [ ] **Step 3: Commit**

```bash
git add lib/screens/location_filter/governorate_selection_controller.dart
git commit -m "feat(location): add GovernorateSelectionController with cache-first load and Arabic-aware search"
```

## Task 22: Build GovernorateSelectionScreen

**Files:**
- Create: `lib/screens/location_filter/governorate_selection_screen.dart`

- [ ] **Step 1: Create screen**

Create `lib/screens/location_filter/governorate_selection_screen.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../components/app_scaffold.dart';
import '../../main.dart';
import '../../utils/app_common.dart';
import '../../utils/colors.dart';
import 'city_selection_screen.dart';
import 'components/all_locations_tile.dart';
import 'components/governorate_list_tile.dart';
import 'components/location_search_bar.dart';
import 'components/location_shimmer.dart';
import 'governorate_selection_controller.dart';
import 'models/governorate_model.dart';
import 'models/location_filter_result.dart';

class GovernorateSelectionScreen extends StatelessWidget {
  final int? initiallySelectedId;
  final int? initiallySelectedCityId;

  GovernorateSelectionScreen({
    super.key,
    this.initiallySelectedId,
    this.initiallySelectedCityId,
  });

  late final GovernorateSelectionController c = Get.put(
    GovernorateSelectionController(initiallySelectedId: initiallySelectedId),
    tag: 'governorate-selection',
  );

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBartitleText: locale.value.selectGovernorate,
      automaticallyImplyLeading: true,
      hasLeadingWidget: true,
      actions: [
        Obx(() {
          if (c.currentSelectedId.value == null) return const SizedBox.shrink();
          return TextButton(
            onPressed: () =>
                Get.back(result: const LocationFilterResult.cleared()),
            child: Text(
              locale.value.clear,
              style: boldTextStyle(size: 14, color: appColorSecondary),
            ),
          );
        }),
      ],
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LocationSearchBar(
            hintText: locale.value.searchGovernorate,
            controller: c.searchTextController,
            onChanged: c.onSearchChanged,
          ),
          Expanded(
            child: Obx(() {
              if (c.isLoading.value && c.governorates.isEmpty) {
                return const LocationShimmer();
              }
              if (c.error.value.isNotEmpty && c.governorates.isEmpty) {
                return _ErrorView(
                  message: c.error.value,
                  onRetry: () => c.loadGovernorates(forceNetwork: true),
                );
              }
              return RefreshIndicator(
                onRefresh: () => c.loadGovernorates(forceNetwork: true),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                  children: [
                    AllLocationsTile(
                      icon: Icons.public,
                      title: locale.value.allGovernorates,
                      subtitle: locale.value.showDoctorsFromAllGovernorates,
                      onTap: () =>
                          Get.back(result: const LocationFilterResult.cleared()),
                    ),
                    const SizedBox(height: 16),
                    if (c.filteredGovernorates.isEmpty)
                      _EmptySearchView(query: c.searchQuery.value, onClear: () {
                        c.searchTextController.clear();
                        c.onSearchChanged('');
                      })
                    else
                      ...List.generate(c.filteredGovernorates.length, (i) {
                        final g = c.filteredGovernorates[i];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: GovernorateListTile(
                            governorate: g,
                            selected: c.currentSelectedId.value == g.id,
                            onTap: () => _onGovernorateTap(g),
                          ),
                        );
                      }),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Future<void> _onGovernorateTap(GovernorateModel g) async {
    final result = await Get.to<LocationFilterResult>(
      () => CitySelectionScreen(
        governorate: g,
        initiallySelectedCityId:
            c.currentSelectedId.value == g.id ? initiallySelectedCityId : null,
      ),
    );
    if (result == null) return;
    Get.back(result: result);
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off, color: appBodyColor, size: 48),
            const SizedBox(height: 12),
            Text(
              locale.value.failedToLoadGovernorates,
              style: boldTextStyle(size: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              message,
              style: secondaryTextStyle(size: 13),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: appColorSecondary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(locale.value.retry),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptySearchView extends StatelessWidget {
  final String query;
  final VoidCallback onClear;
  const _EmptySearchView({required this.query, required this.onClear});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
      child: Column(
        children: [
          Icon(Icons.search_off, color: appBodyColor, size: 48),
          const SizedBox(height: 12),
          Text(
            locale.value.noGovernoratesFound,
            style: boldTextStyle(size: 16),
          ),
          const SizedBox(height: 4),
          Text(
            locale.value.noResultsFor.replaceAll('{query}', query),
            style: secondaryTextStyle(size: 13),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          TextButton(onPressed: onClear, child: Text(locale.value.clearSearch)),
        ],
      ),
    );
  }
}
```

> **Note on `CitySelectionScreen` import:** the file does not exist yet — Phase 3 creates it. The compiler will flag this as a missing file until Task 27. That is expected; do not commit until Phase 3 starts. Alternatively, comment out the navigation block now and uncomment after Task 27. The plan handles this by deferring the commit to after Phase 3 Task 27 (see Task 28).

- [ ] **Step 2: Stub out the CitySelectionScreen import to allow Phase 2 to compile standalone**

Until the city screen exists, stub the navigation. Replace the `_onGovernorateTap` body with:

```dart
  Future<void> _onGovernorateTap(GovernorateModel g) async {
    // Placeholder: city screen wired in Phase 3
    Get.back(
      result: LocationFilterResult(
        governorateId: g.id,
        governorate: g,
      ),
    );
  }
```

And remove the `import 'city_selection_screen.dart';` line for now. (Task 28 restores both.)

- [ ] **Step 3: Run analyzer**

```bash
flutter analyze lib/screens/location_filter/governorate_selection_screen.dart
```

Expected: No issues found.

- [ ] **Step 4: Commit**

```bash
git add lib/screens/location_filter/governorate_selection_screen.dart
git commit -m "feat(location): add GovernorateSelectionScreen with cache-first render and search"
```

## Task 23: Phase 2 verification

- [ ] **Step 1: Run full analyzer**

```bash
flutter analyze
```

Expected: No new issues.

- [ ] **Step 2: Smoke test on emulator**

Temporarily wire a debug entry. In `lib/main.dart` or any easy-access screen, add a button that calls:

```dart
Get.to(() => GovernorateSelectionScreen())
```

Run the app. Verify:
- The screen opens with shimmer, then renders the governorates list (assuming the backend `/governorates` endpoint exists; if it 404s, the error state will show — that is expected and confirms the integration).
- Search filters the list.
- Tapping "All Governorates" pops back.
- Tapping a governorate pops back with placeholder result (Phase 3 will wire city navigation).

Remove the debug entry before committing.

- [ ] **Step 3: Stop and report**

Phase 2 complete. List components built. Show screenshot if available. Wait for "continue Phase 3".

---

# Phase 3 — City Selection Screen

Goal: full UI flow to browse, search, and select a city for a chosen governorate, with empty-state handling.

## Task 24: Build SelectedGovernorateHeader component

**Files:**
- Create: `lib/screens/location_filter/components/selected_governorate_header.dart`

- [ ] **Step 1: Create header**

Create `lib/screens/location_filter/components/selected_governorate_header.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../main.dart';
import '../../../utils/app_common.dart';
import '../../../utils/colors.dart';
import '../models/governorate_model.dart';

class SelectedGovernorateHeader extends StatelessWidget {
  final GovernorateModel governorate;

  const SelectedGovernorateHeader({super.key, required this.governorate});

  @override
  Widget build(BuildContext context) {
    final lang = selectedLanguageCode.value;
    return Obx(() {
      final dark = isDarkMode.value;
      return Container(
        margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: dark ? surfaceElevatedDark : surfaceSubtle,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: dark ? borderColorDark : whiteBorderColor,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(Icons.location_on, color: appColorSecondary, size: 22),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    governorate.displayName(lang),
                    style: boldTextStyle(size: 16),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    locale.value.showingCitiesInGovernorate,
                    style: secondaryTextStyle(size: 13),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}
```

- [ ] **Step 2: Run analyzer**

```bash
flutter analyze lib/screens/location_filter/components/selected_governorate_header.dart
```

Expected: No issues found.

- [ ] **Step 3: Commit**

```bash
git add lib/screens/location_filter/components/selected_governorate_header.dart
git commit -m "feat(location): add SelectedGovernorateHeader"
```

## Task 25: Build CityListTile and EmptyCitiesWidget

**Files:**
- Create: `lib/screens/location_filter/components/city_list_tile.dart`
- Create: `lib/screens/location_filter/components/empty_cities_widget.dart`

- [ ] **Step 1: Create CityListTile** (mirrors `GovernorateListTile`)

Create `lib/screens/location_filter/components/city_list_tile.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../main.dart';
import '../../../utils/app_common.dart';
import '../../../utils/colors.dart';
import '../models/city_model.dart';
import 'location_count_badge.dart';

class CityListTile extends StatelessWidget {
  final CityModel city;
  final bool selected;
  final VoidCallback onTap;

  const CityListTile({
    super.key,
    required this.city,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final lang = selectedLanguageCode.value;
    return Obx(() {
      final dark = isDarkMode.value;
      final bgColor = selected
          ? (dark ? appColorSecondary.withOpacity(0.15) : lightAccentColor)
          : Colors.transparent;
      final borderColorRes = selected
          ? appColorSecondary
          : (dark ? borderColorDark : whiteBorderColor);
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColorRes, width: selected ? 1.5 : 1),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      city.displayName(lang),
                      style: selected
                          ? boldTextStyle(size: 16, color: appColorSecondary)
                          : primaryTextStyle(size: 16),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (city.doctorsCount > 0) ...[
                      const SizedBox(height: 6),
                      LocationCountBadge(
                        count: city.doctorsCount,
                        labelTemplate: locale.value.xDoctors,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                selected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                color: selected
                    ? appColorSecondary
                    : (dark ? textTertiaryDark : appBodyColor),
                size: 22,
              ),
            ],
          ),
        ),
      );
    });
  }
}
```

- [ ] **Step 2: Create EmptyCitiesWidget**

Create `lib/screens/location_filter/components/empty_cities_widget.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../main.dart';
import '../../../utils/colors.dart';

class EmptyCitiesWidget extends StatelessWidget {
  final VoidCallback onApplyGovernorateOnly;
  final VoidCallback onChangeGovernorate;

  const EmptyCitiesWidget({
    super.key,
    required this.onApplyGovernorateOnly,
    required this.onChangeGovernorate,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.location_off, color: appBodyColor, size: 56),
            const SizedBox(height: 12),
            Text(
              locale.value.noCitiesAvailable,
              style: boldTextStyle(size: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              locale.value.showAllCitiesInGovernorate,
              style: secondaryTextStyle(size: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onApplyGovernorateOnly,
                style: ElevatedButton.styleFrom(
                  backgroundColor: appColorSecondary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(locale.value.applyGovernorateOnly),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: onChangeGovernorate,
                style: OutlinedButton.styleFrom(
                  foregroundColor: appColorSecondary,
                  side: BorderSide(color: appColorSecondary),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(locale.value.changeGovernorate),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 3: Run analyzer**

```bash
flutter analyze lib/screens/location_filter/components/city_list_tile.dart lib/screens/location_filter/components/empty_cities_widget.dart
```

Expected: No issues found.

- [ ] **Step 4: Commit**

```bash
git add lib/screens/location_filter/components/city_list_tile.dart lib/screens/location_filter/components/empty_cities_widget.dart
git commit -m "feat(location): add CityListTile and EmptyCitiesWidget"
```

## Task 26: Build CitySelectionController

**Files:**
- Create: `lib/screens/location_filter/city_selection_controller.dart`

- [ ] **Step 1: Create controller**

Create `lib/screens/location_filter/city_selection_controller.dart`:

```dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../api/location_apis.dart';
import '../../utils/app_common.dart';
import 'models/city_model.dart';
import 'models/governorate_model.dart';
import 'service/location_cache_service.dart';

class CitySelectionController extends GetxController {
  final GovernorateModel governorate;
  final int? initiallySelectedCityId;

  CitySelectionController({
    required this.governorate,
    this.initiallySelectedCityId,
  });

  final RxList<CityModel> cities = <CityModel>[].obs;
  final RxList<CityModel> filteredCities = <CityModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;
  final RxString searchQuery = ''.obs;
  final Rxn<int> currentSelectedCityId = Rxn<int>();

  final TextEditingController searchTextController = TextEditingController();

  Timer? _searchDebounce;
  final LocationCacheService _cache = LocationCacheService();

  @override
  void onInit() {
    super.onInit();
    if (initiallySelectedCityId != null) {
      currentSelectedCityId.value = initiallySelectedCityId;
    } else {
      final lastGov = _cache.getLastSelectedGovernorateId();
      if (lastGov == governorate.id) {
        currentSelectedCityId.value = _cache.getLastSelectedCityId();
      }
    }
    loadCities();
  }

  @override
  void onClose() {
    _searchDebounce?.cancel();
    searchTextController.dispose();
    super.onClose();
  }

  Future<void> loadCities({bool forceNetwork = false}) async {
    error.value = '';
    final cached = _cache.getCachedCitiesFor(governorate.id);
    if (!forceNetwork && cached != null && cached.isNotEmpty) {
      cities.assignAll(cached);
      _applyFilter();
      _refreshFromNetworkSilently();
      return;
    }
    isLoading.value = true;
    try {
      final list = await LocationApis.getCitiesByGovernorate(governorate.id);
      cities.assignAll(list);
      _applyFilter();
      await _cache.cacheCitiesFor(governorate.id, list);
    } catch (e) {
      error.value = e.toString();
      log('CitySelectionController.loadCities: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _refreshFromNetworkSilently() async {
    try {
      final list = await LocationApis.getCitiesByGovernorate(governorate.id);
      cities.assignAll(list);
      _applyFilter();
      await _cache.cacheCitiesFor(governorate.id, list);
    } catch (e) {
      log('CitySelectionController.refreshSilently: $e');
    }
  }

  void onSearchChanged(String query) {
    searchQuery.value = query;
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 200), _applyFilter);
  }

  void _applyFilter() {
    final q = _normalize(searchQuery.value);
    if (q.isEmpty) {
      filteredCities.assignAll(cities);
      return;
    }
    final lang = selectedLanguageCode.value;
    filteredCities.assignAll(
      cities.where((c) {
        final display = _normalize(c.displayName(lang));
        final en = _normalize(c.nameEn ?? '');
        final ar = _normalize(c.nameAr ?? '');
        return display.contains(q) || en.contains(q) || ar.contains(q);
      }),
    );
  }

  String _normalize(String s) {
    var n = s.toLowerCase().trim();
    n = n
        .replaceAll(RegExp('[إأآا]'), 'ا')
        .replaceAll('ى', 'ي')
        .replaceAll('ة', 'ه')
        .replaceAll(RegExp('[ً-ٟ]'), '');
    return n;
  }
}
```

- [ ] **Step 2: Run analyzer**

```bash
flutter analyze lib/screens/location_filter/city_selection_controller.dart
```

Expected: No issues found.

- [ ] **Step 3: Commit**

```bash
git add lib/screens/location_filter/city_selection_controller.dart
git commit -m "feat(location): add CitySelectionController"
```

## Task 27: Build CitySelectionScreen

**Files:**
- Create: `lib/screens/location_filter/city_selection_screen.dart`

- [ ] **Step 1: Create screen**

Create `lib/screens/location_filter/city_selection_screen.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../components/app_scaffold.dart';
import '../../main.dart';
import '../../utils/app_common.dart';
import '../../utils/colors.dart';
import 'city_selection_controller.dart';
import 'components/all_locations_tile.dart';
import 'components/city_list_tile.dart';
import 'components/empty_cities_widget.dart';
import 'components/location_search_bar.dart';
import 'components/location_shimmer.dart';
import 'components/selected_governorate_header.dart';
import 'models/city_model.dart';
import 'models/governorate_model.dart';
import 'models/location_filter_result.dart';

class CitySelectionScreen extends StatelessWidget {
  final GovernorateModel governorate;
  final int? initiallySelectedCityId;

  CitySelectionScreen({
    super.key,
    required this.governorate,
    this.initiallySelectedCityId,
  });

  late final CitySelectionController c = Get.put(
    CitySelectionController(
      governorate: governorate,
      initiallySelectedCityId: initiallySelectedCityId,
    ),
    tag: 'city-selection-${governorate.id}',
  );

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBartitleText: locale.value.selectCity,
      automaticallyImplyLeading: true,
      hasLeadingWidget: true,
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: Text(
            locale.value.change,
            style: boldTextStyle(size: 14, color: appColorSecondary),
          ),
        ),
      ],
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SelectedGovernorateHeader(governorate: governorate),
          LocationSearchBar(
            hintText: locale.value.searchCity,
            controller: c.searchTextController,
            onChanged: c.onSearchChanged,
          ),
          Expanded(
            child: Obx(() {
              if (c.isLoading.value && c.cities.isEmpty) {
                return const LocationShimmer();
              }
              if (c.error.value.isNotEmpty && c.cities.isEmpty) {
                return _ErrorView(
                  message: c.error.value,
                  onRetry: () => c.loadCities(forceNetwork: true),
                );
              }
              if (c.cities.isEmpty) {
                return EmptyCitiesWidget(
                  onApplyGovernorateOnly: () => Get.back(
                    result: LocationFilterResult(
                      governorateId: governorate.id,
                      governorate: governorate,
                    ),
                  ),
                  onChangeGovernorate: () => Get.back(),
                );
              }
              return RefreshIndicator(
                onRefresh: () => c.loadCities(forceNetwork: true),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                  children: [
                    AllLocationsTile(
                      icon: Icons.location_city,
                      title: locale.value.allCities,
                      subtitle: locale.value.showAllCitiesInGovernorate,
                      onTap: () => Get.back(
                        result: LocationFilterResult(
                          governorateId: governorate.id,
                          governorate: governorate,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (c.filteredCities.isEmpty)
                      _EmptySearchView(
                        query: c.searchQuery.value,
                        onClear: () {
                          c.searchTextController.clear();
                          c.onSearchChanged('');
                        },
                      )
                    else
                      ...List.generate(c.filteredCities.length, (i) {
                        final city = c.filteredCities[i];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: CityListTile(
                            city: city,
                            selected: c.currentSelectedCityId.value == city.id,
                            onTap: () => _onCityTap(city),
                          ),
                        );
                      }),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  void _onCityTap(CityModel city) {
    Get.back(
      result: LocationFilterResult(
        governorateId: governorate.id,
        cityId: city.id,
        governorate: governorate,
        city: city,
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off, color: appBodyColor, size: 48),
            const SizedBox(height: 12),
            Text(
              locale.value.failedToLoadCities,
              style: boldTextStyle(size: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              message,
              style: secondaryTextStyle(size: 13),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: appColorSecondary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(locale.value.retry),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptySearchView extends StatelessWidget {
  final String query;
  final VoidCallback onClear;
  const _EmptySearchView({required this.query, required this.onClear});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
      child: Column(
        children: [
          Icon(Icons.search_off, color: appBodyColor, size: 48),
          const SizedBox(height: 12),
          Text(locale.value.noCitiesFound, style: boldTextStyle(size: 16)),
          const SizedBox(height: 4),
          Text(
            locale.value.noResultsFor.replaceAll('{query}', query),
            style: secondaryTextStyle(size: 13),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          TextButton(onPressed: onClear, child: Text(locale.value.clearSearch)),
        ],
      ),
    );
  }
}
```

- [ ] **Step 2: Run analyzer**

```bash
flutter analyze lib/screens/location_filter/city_selection_screen.dart
```

Expected: No issues found.

- [ ] **Step 3: Commit**

```bash
git add lib/screens/location_filter/city_selection_screen.dart
git commit -m "feat(location): add CitySelectionScreen with empty/error/search states"
```

## Task 28: Restore real CitySelectionScreen navigation in GovernorateSelectionScreen

**Files:**
- Modify: `lib/screens/location_filter/governorate_selection_screen.dart`

- [ ] **Step 1: Re-add the import**

At the top of `lib/screens/location_filter/governorate_selection_screen.dart`, restore:

```dart
import 'city_selection_screen.dart';
```

- [ ] **Step 2: Replace `_onGovernorateTap` with the real flow**

Replace the placeholder body added in Task 22 Step 2 with:

```dart
  Future<void> _onGovernorateTap(GovernorateModel g) async {
    final result = await Get.to<LocationFilterResult>(
      () => CitySelectionScreen(
        governorate: g,
        initiallySelectedCityId:
            c.currentSelectedId.value == g.id ? initiallySelectedCityId : null,
      ),
    );
    if (result == null) return;
    Get.back(result: result);
  }
```

- [ ] **Step 3: Run analyzer**

```bash
flutter analyze lib/screens/location_filter/
```

Expected: No issues found.

- [ ] **Step 4: Commit**

```bash
git add lib/screens/location_filter/governorate_selection_screen.dart
git commit -m "feat(location): wire CitySelectionScreen navigation from governorate screen"
```

## Task 29: Phase 3 verification

- [ ] **Step 1: Run full analyzer**

```bash
flutter analyze
```

Expected: No new issues.

- [ ] **Step 2: Smoke test on emulator**

Re-add the temporary debug entry from Task 23 (or keep it if you didn't remove it). Verify the full two-step flow works: Governorate → City → result returned. Test:
- Selecting "All Governorates" returns cleared
- Selecting a governorate then "All Cities" returns governorate-only
- Selecting governorate + city returns both
- Empty cities state shows two action buttons
- AppBar "Change" on city screen pops back to governorate screen

Remove debug entry.

- [ ] **Step 3: Stop and report**

Phase 3 complete. Wait for "continue Phase 4".

---

# Phase 4 — Integration with Existing FilterController

Goal: extend `FilterController` with location reactive fields, persist last selection, and add a tappable Location tile to `FilterScreen` so users can launch the location flow from the existing filter sheet.

## Task 30: Extend FilterController with location reactive fields

**Files:**
- Modify: `lib/screens/booking/filter/filter_controller.dart`

- [ ] **Step 1: Add imports at the top of the file**

Add:

```dart
import '../../location_filter/models/city_model.dart';
import '../../location_filter/models/governorate_model.dart';
import '../../location_filter/service/location_cache_service.dart';
```

- [ ] **Step 2: Add reactive fields and getter**

In `FilterController`, after the existing `selectedServiceType` declaration (around line 82) and before `onInit()` (around line 85), insert:

```dart
  // Location filter
  final Rxn<int> selectedGovernorateId = Rxn<int>();
  final Rxn<int> selectedCityId = Rxn<int>();
  final Rxn<GovernorateModel> selectedGovernorate = Rxn<GovernorateModel>();
  final Rxn<CityModel> selectedCity = Rxn<CityModel>();

  int get locationFilterCount {
    int n = 0;
    if (selectedGovernorateId.value != null) n++;
    if (selectedCityId.value != null) n++;
    return n;
  }

  void applyLocationSelection({
    required int? governorateId,
    required int? cityId,
    GovernorateModel? governorate,
    CityModel? city,
  }) {
    selectedGovernorateId.value = governorateId;
    selectedCityId.value = cityId;
    selectedGovernorate.value = governorate;
    selectedCity.value = city;
    LocationCacheService().saveLastSelection(
      governorateId: governorateId,
      cityId: cityId,
    );
  }

  void clearLocationSelection() {
    selectedGovernorateId.value = null;
    selectedCityId.value = null;
    selectedGovernorate.value = null;
    selectedCity.value = null;
    LocationCacheService().clearLastSelection();
  }
```

- [ ] **Step 3: Hydrate from cache on init**

At the start of the existing `onInit()` method (right after `super.onInit();` is reached or as the first lines before `Get.arguments` checks — earliest practical point), add:

```dart
    // Hydrate persisted location selection on first init
    final cache = LocationCacheService();
    selectedGovernorateId.value = cache.getLastSelectedGovernorateId();
    selectedCityId.value = cache.getLastSelectedCityId();
```

(Place these lines as the first statements inside `onInit()` so they run before the `Get.arguments` block. Do not modify existing code in `onInit()`.)

- [ ] **Step 4: Run analyzer**

```bash
flutter analyze lib/screens/booking/filter/filter_controller.dart
```

Expected: No issues found.

- [ ] **Step 5: Commit**

```bash
git add lib/screens/booking/filter/filter_controller.dart
git commit -m "feat(location): extend FilterController with governorate/city reactive fields"
```

## Task 31: Add Location tile to FilterScreen

**Files:**
- Modify: `lib/screens/booking/filter/filter_screen.dart`

- [ ] **Step 1: Add imports**

Add at the top of `filter_screen.dart`:

```dart
import '../../location_filter/governorate_selection_screen.dart';
import '../../location_filter/models/location_filter_result.dart';
```

- [ ] **Step 2: Insert the Location tile above the type list / filter row**

In the `build()` method, find the `Column` containing `16.height,` and the `Row` (the row with `FilterTypeListComponent`). Replace the `16.height,` entry with the following block (placed before the `Row`):

```dart
            const SizedBox(height: 16),
            _LocationFilterTile(filterCont: filterCont).paddingSymmetric(horizontal: 16),
            const SizedBox(height: 12),
```

- [ ] **Step 3: Append the `_LocationFilterTile` widget at the bottom of `filter_screen.dart`**

After the closing brace of the `FilterScreen` class, append:

```dart
class _LocationFilterTile extends StatelessWidget {
  final FilterController filterCont;
  const _LocationFilterTile({required this.filterCont});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final dark = isDarkMode.value;
      final govId = filterCont.selectedGovernorateId.value;
      final gov = filterCont.selectedGovernorate.value;
      final city = filterCont.selectedCity.value;
      final lang = selectedLanguageCode.value;

      String label;
      if (govId == null) {
        label = locale.value.allLocations;
      } else if (city != null) {
        label = locale.value.locationFilterFormat
            .replaceAll('{governorate}', gov?.displayName(lang) ?? '')
            .replaceAll('{city}', city.displayName(lang));
      } else if (gov != null) {
        label = gov.displayName(lang);
      } else {
        label = locale.value.allLocations;
      }

      return InkWell(
        onTap: () => _openLocationFlow(filterCont),
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: dark ? surfaceElevatedDark : surfaceElevated,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: govId == null
                  ? (dark ? borderColorDark : whiteBorderColor)
                  : appColorSecondary,
              width: govId == null ? 1 : 1.5,
            ),
          ),
          child: Row(
            children: [
              Icon(Icons.location_on, color: appColorSecondary, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(locale.value.location,
                        style: secondaryTextStyle(size: 12)),
                    const SizedBox(height: 2),
                    Text(
                      label,
                      style: boldTextStyle(size: 15),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios,
                  color: dark ? textTertiaryDark : appBodyColor, size: 14),
            ],
          ),
        ),
      );
    });
  }

  Future<void> _openLocationFlow(FilterController c) async {
    final result = await Get.to<LocationFilterResult>(
      () => GovernorateSelectionScreen(
        initiallySelectedId: c.selectedGovernorateId.value,
        initiallySelectedCityId: c.selectedCityId.value,
      ),
    );
    if (result == null) return;
    if (result.cleared) {
      c.clearLocationSelection();
    } else {
      c.applyLocationSelection(
        governorateId: result.governorateId,
        cityId: result.cityId,
        governorate: result.governorate,
        city: result.city,
      );
    }
  }
}
```

- [ ] **Step 4: Run analyzer**

```bash
flutter analyze lib/screens/booking/filter/filter_screen.dart
```

Expected: No issues found. If `selectedLanguageCode`, `whiteBorderColor`, `borderColorDark`, `textTertiaryDark`, or `surfaceElevated*` are missing imports, add them from `lib/utils/colors.dart` and `lib/utils/app_common.dart`.

- [ ] **Step 5: Commit**

```bash
git add lib/screens/booking/filter/filter_screen.dart
git commit -m "feat(location): add Location tile entry point to FilterScreen"
```

## Task 32: Phase 4 verification

- [ ] **Step 1: Run full analyzer**

```bash
flutter analyze
```

Expected: No new issues. Pre-existing payment_screen.dart and AppBarTheme warnings are OK.

- [ ] **Step 2: End-to-end smoke test**

Run the app on emulator. Open any list screen that exposes the filter (doctor list, clinic list, service list, category list). Tap the filter icon. The filter sheet should now show a "Location" tile at the top. Tap it:
- Verify the governorate screen opens
- Tap a governorate → city screen opens
- Tap a city → returns to filter sheet
- Verify the Location tile now displays "Cairo > Maadi" (or chosen pair)
- Tap "Apply" on the filter sheet — it closes (existing behavior)
- Reopen the filter sheet — verify the Location tile still shows the previous selection
- Quit and relaunch the app — verify the persistence (last selection auto-loaded via `LocationCacheService`)

If any of these fail, debug before proceeding.

- [ ] **Step 3: Verify dark mode**

Toggle dark mode in the app. Reopen the filter sheet. Confirm:
- Location tile background uses `surfaceElevatedDark`
- Selected tile borders use `appColorSecondary` (teal)
- Search bars use `inputFillColorDark`
- Shimmer uses dark variants

- [ ] **Step 4: Verify Arabic RTL**

Switch language to Arabic. Repeat the smoke test. Confirm:
- Search hints show Arabic strings
- List alignment flips RTL
- Arabic-aware search works (try typing `قاهر` and verify Cairo matches)
- The location tile label shows `{governorate} > {city}` in Arabic-friendly direction (the `>` separator may need replacement with `<` for RTL — note this for design polish if it looks off)

- [ ] **Step 5: Stop and report**

Phase 4 complete. The location filter is fully functional from a UX perspective: selection, persistence, search, cache, integration with existing FilterController. The list screens themselves do **not yet** send `governorate_id` or `city_id` query params to the backend — that is Phase 5.

Ask the user: **"Proceed with Phase 5 (wire governorate_id/city_id query params through `core_apis.dart` and list controllers, gated on backend support) or stop here?"**

---

# Phase 5 — End-to-End API Filtering (Optional)

Goal: pass `governorate_id` and `city_id` query parameters from list controllers through `CoreServiceApis.getDoctors()` / `getClinics()` / `getServiceList()` so list results actually filter by the chosen location.

**Prerequisite:** Confirm with backend team that `/get-doctor-list`, `/get-clinic-list`, and `/get-service-list` accept `governorate_id` and `city_id` query parameters. If not, this phase is blocked on backend work.

## Task 33: Add governorate/city params to CoreServiceApis methods

**Files:**
- Modify: `lib/api/core_apis.dart`

- [ ] **Step 1: Update `getDoctors()` signature and query string**

In `getDoctors()` (line 193), add to the parameter list:

```dart
    int? governorateId,
    int? cityId,
```

In the body, before the final `await buildHttpResponse(...)` call, add:

```dart
    String govId = (governorateId != null && governorateId > 0) ? '&governorate_id=$governorateId' : '';
    String ctyId = (cityId != null && cityId > 0) ? '&city_id=$cityId' : '';
```

Append `$govId$ctyId` to the URL template.

- [ ] **Step 2: Update `getClinics()` signature and query string**

Same pattern: add `governorateId` and `cityId` named params, add the query-string fragments, append to URL.

- [ ] **Step 3: Update `getServiceList()` signature and query string**

Same pattern.

- [ ] **Step 4: Run analyzer**

```bash
flutter analyze lib/api/core_apis.dart
```

Expected: No issues found.

- [ ] **Step 5: Commit**

```bash
git add lib/api/core_apis.dart
git commit -m "feat(location): accept governorate_id and city_id query params in list APIs"
```

## Task 34: Add governorate/city fields to list controllers

**Files:**
- Modify: `lib/screens/doctor/doctor_list_controller.dart`
- Modify: `lib/screens/clinic/clinic_list_controller.dart`
- Modify: `lib/screens/service/service_list_controller.dart`

For each controller:

- [ ] **Step 1: Add reactive fields**

Add near the existing filter fields:

```dart
  RxnInt governorateId = RxnInt();
  RxnInt cityId = RxnInt();
```

- [ ] **Step 2: Pass them to the API call**

In the `getDoctors()` / `getClinicList()` / `getServiceList()` method body, add to the API call:

```dart
        governorateId: governorateId.value,
        cityId: cityId.value,
```

- [ ] **Step 3: Run analyzer per file**

```bash
flutter analyze lib/screens/doctor/doctor_list_controller.dart lib/screens/clinic/clinic_list_controller.dart lib/screens/service/service_list_controller.dart
```

Expected: No issues found.

- [ ] **Step 4: Commit**

```bash
git add lib/screens/doctor/doctor_list_controller.dart lib/screens/clinic/clinic_list_controller.dart lib/screens/service/service_list_controller.dart
git commit -m "feat(location): add governorate/city fields to doctor/clinic/service list controllers"
```

## Task 35: Push location filter from FilterController to list controllers

**Files:**
- Modify: `lib/screens/booking/filter/filter_controller.dart`

- [ ] **Step 1: Extend `applyFilter()` to push location**

Inside `applyFilter()` (around line 404), in each of the three branches (`type == "service"`, `type == "doctor"`, `type == "clinic"`), after the existing assignments to the list controller and before `applyFilterCount()`, add:

```dart
      <controllerVar>.governorateId(selectedGovernorateId.value);
      <controllerVar>.cityId(selectedCityId.value);
```

Where `<controllerVar>` is `serviceCont` / `doctorConte` / `clinicCont` per branch.

- [ ] **Step 2: Run analyzer**

```bash
flutter analyze lib/screens/booking/filter/filter_controller.dart
```

Expected: No issues found.

- [ ] **Step 3: End-to-end test**

Run the app, set a location filter, apply, observe the list refetches. Inspect the network log (the project prints API URLs via `apiPrint`) and confirm `governorate_id` and `city_id` are present in the request URL.

- [ ] **Step 4: Commit**

```bash
git add lib/screens/booking/filter/filter_controller.dart
git commit -m "feat(location): push governorate/city to list controllers on apply"
```

## Task 36: Phase 5 verification

- [ ] **Step 1: Run full analyzer**

```bash
flutter analyze
```

Expected: No new issues.

- [ ] **Step 2: Final smoke test**

Run the entire acceptance criteria from spec section 20 against the app. Mark each one pass/fail.

- [ ] **Step 3: Done**

Report final status. Module is production-ready.

---

## Self-Review Checklist (engineer's reference)

Before declaring the plan done, verify:

- [ ] All file paths in the plan are absolute relative to repo root and match real Flutter project conventions (`lib/...`).
- [ ] No `TODO`, `TBD`, or "fill in" placeholders remain except the explicit Phase 5 prerequisite note about backend support.
- [ ] Every code block compiles in isolation (the engineer should be able to copy-paste and run analyzer).
- [ ] Every imported symbol (`appColorSecondary`, `lightAccentColor`, `whiteBorderColor`, `borderColorDark`, `surfaceElevated`, `surfaceElevatedDark`, `surfaceSubtle`, `inputFillColor`, `inputFillColorDark`, `shimmerBase*`, `appBodyColor`, `textTertiaryDark`, `selectedLanguageCode`, `isDarkMode`, `locale`) actually exists in the project — verified against `lib/utils/colors.dart`, `lib/utils/app_common.dart`, and `lib/main.dart`.
- [ ] Localization keys added to `BaseLanguage` are implemented in all 5 language files (en, ar, hi, fr, de).
- [ ] Method signatures used in later tasks match what was defined in earlier tasks (e.g., `applyLocationSelection`, `clearLocationSelection`, `getCachedGovernorates`, `getCitiesByGovernorate`).
- [ ] Each task ends with a commit; commits are scoped to one logical change.
- [ ] Every TDD-style step is **not used here** because Flutter UI work is harder to TDD without a test harness for screens; the plan trades formal TDD for tight verification steps + smoke tests + analyzer gates per phase. This is an acceptable deviation given the project has no widget tests on screens of this category.

---

**End of Plan**
