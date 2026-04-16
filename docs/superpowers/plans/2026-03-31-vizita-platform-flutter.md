# Vizita Platform Flutter — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add location-aware search (governorates/cities), extend 4 existing modules (doctors, clinics, nurses, lab tests), and build 2 new modules (home healthcare, radiology) across the Espitalia Flutter patient app.

**Architecture:** Foundation-first — shared `GovernoratesCityPicker` widget and models are built in Phase 1, then consumed by all 6 feature phases. Each "extend" phase adds `searchX()` API methods alongside existing ones (never replacing). New modules mirror the nurse/lab test pattern exactly.

**Tech Stack:** Flutter 3.0+ / Dart 3.0+, GetX (.obs / Obx / GetxController), nb_utils, Google Fonts (Plus Jakarta Sans + Outfit), Clinical Elegance design tokens (16px card radius, navy shadows, glass borders)

**Spec:** `specs/007-vizita-platform-flutter/spec.md`

---

## File Structure

### New Files (~23)

```
lib/models/governorate_model.dart
lib/models/city_model.dart
lib/components/governorates_city_picker.dart
lib/components/location_badge.dart
lib/components/glass_info_card.dart
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
lib/screens/radiology/
├── radiology_list_controller.dart
├── radiology_list_screen.dart
├── radiology_detail_screen.dart
├── model/
│   └── radiology_center_model.dart
└── components/
    └── radiology_center_card.dart
```

### Modified Files (~40)

```
lib/utils/api_end_points.dart           # New endpoint constants
lib/utils/constants.dart                # HomeHealthcareRequestStatusConst, HomeHealthcareServiceTypeConst, ScanTypeConst
lib/utils/colors.dart                   # Verify status colors exist (no-op if already present)
lib/network/network_utils.dart          # Accept-Language header
lib/api/core_apis.dart                  # 9 new API methods
lib/locale/languages.dart               # ~50 new abstract keys
lib/locale/language_en.dart             # English translations
lib/locale/language_ar.dart             # Arabic translations
lib/locale/language_de.dart             # German translations
lib/locale/language_fr.dart             # French translations
lib/locale/language_hi.dart             # Hindi translations
lib/screens/nurse/model/nurse_model.dart          # governorate, city fields
lib/screens/nurse/nurse_list_controller.dart      # location filters + searchNurses()
lib/screens/nurse/nurse_list_screen.dart          # GovernoratesCityPicker
lib/screens/nurse/components/nurse_card.dart      # location pill
lib/screens/lab_test/model/lab_test_model.dart    # governorate, city fields
lib/screens/lab_test/lab_test_list_controller.dart # location filters + searchLabs()
lib/screens/lab_test/lab_test_list_screen.dart    # GovernoratesCityPicker
lib/screens/lab_test/components/lab_test_card.dart # location pill
lib/screens/doctor/model/doctor_list_res.dart     # governorate, city fields
lib/screens/doctor/doctor_list_controller.dart    # location filters + searchDoctors()
lib/screens/doctor/doctor_list_screen.dart        # GovernoratesCityPicker
lib/screens/clinic/model/clinics_res_model.dart   # governorate, city fields
lib/screens/clinic/clinic_list_controller.dart    # location filters + searchClinics()
lib/screens/clinic/clinics_list_screen.dart       # GovernoratesCityPicker
lib/screens/home/components/quick_services_component.dart  # Home Healthcare + Radiology entries
```

---

## Implementation Order

Follow this order — each phase depends on the previous:
1. **Phase 1** — Foundation (models, picker, API, locale, header)
2. **Phase 3** — Nurses (simplest extension, validates the pattern)
3. **Phase 5** — Lab Tests (confirms consistency)
4. **Phase 2** — Doctors & Clinics (more complex existing controllers)
5. **Phase 6** — Radiology (new browse-only module)
6. **Phase 4** — Home Healthcare (largest new module)
7. **Cross-cutting** — Quick Services grid

---

## Verification Commands

All verify steps use:
```bash
flutter analyze
```
Full build check (run at end of each phase):
```bash
flutter build apk --debug
```

---

## Phase 1: Foundation (Spec Phase 1)

### Task 1: New Endpoint Constants

**Files:**
- Modify: `lib/utils/api_end_points.dart`

- [ ] **Step 1: Add endpoint constants**

  Open `lib/utils/api_end_points.dart` and add after the existing Nurse block (around line 79):

  ```dart
  // Location
  static const String governorates = 'governorates';
  static const String cities = 'cities'; // ?governorate_id=

  // New search endpoints (additive — existing endpoints remain)
  static const String doctorsSearch = 'doctors/search';
  static const String clinicsSearch = 'clinics/search';
  static const String nursesSearch = 'nurses/search';
  static const String labsSearch = 'labs/search';

  // Home Healthcare
  static const String homeHealthcareSearch = 'home-healthcare/search';
  static const String homeHealthcareDetail = 'home-healthcare';    // append /{id}
  static const String homeHealthcareRequests = 'v1/home-healthcare-requests';
  static const String homeHealthcareRequestDetail = 'v1/home-healthcare-requests'; // append /{id}
  static const String homeHealthcareRequestCancel = 'v1/home-healthcare-requests'; // append /{id}/cancel

  // Radiology
  static const String radiologySearch = 'radiology/search';
  static const String radiologyDetail = 'radiology'; // append /{id}
  ```

- [ ] **Step 2: Verify**

  ```bash
  flutter analyze lib/utils/api_end_points.dart
  ```
  Expected: No issues.

- [ ] **Step 3: Commit**

  ```bash
  git add lib/utils/api_end_points.dart
  git commit -m "feat: add new search and module endpoint constants"
  ```

---

### Task 2: Accept-Language Header

**Files:**
- Modify: `lib/network/network_utils.dart`

- [ ] **Step 1: Add Accept-Language alongside existing global-localization**

  In `lib/network/network_utils.dart`, inside `buildHeaderTokens()`, the existing header map (around line 30-35) already has:
  ```dart
  'global-localization': selectedLanguageCode.value,
  ```
  Add `Accept-Language` on the next line:
  ```dart
  'global-localization': selectedLanguageCode.value,
  'Accept-Language': selectedLanguageCode.value,
  ```

- [ ] **Step 2: Verify**

  ```bash
  flutter analyze lib/network/network_utils.dart
  ```
  Expected: No issues.

- [ ] **Step 3: Commit**

  ```bash
  git add lib/network/network_utils.dart
  git commit -m "feat: add Accept-Language header for backend locale-aware responses"
  ```

---

### Task 3: Governorate & City Models

**Files:**
- Create: `lib/models/governorate_model.dart`
- Create: `lib/models/city_model.dart`

- [ ] **Step 1: Create `lib/models/governorate_model.dart`**

  ```dart
  class GovernorateListResponse {
    bool status;
    List<Governorate> data;

    GovernorateListResponse({this.status = false, this.data = const []});

    factory GovernorateListResponse.fromJson(Map<String, dynamic> json) {
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

    Governorate({this.id = -1, this.name = ''});

    factory Governorate.fromJson(Map<String, dynamic> json) {
      return Governorate(
        id: json['id'] is int ? json['id'] : -1,
        name: json['name'] is String ? json['name'] : '',
      );
    }

    Map<String, dynamic> toJson() => {'id': id, 'name': name};
  }
  ```

- [ ] **Step 2: Create `lib/models/city_model.dart`**

  ```dart
  class CityListResponse {
    bool status;
    List<City> data;

    CityListResponse({this.status = false, this.data = const []});

    factory CityListResponse.fromJson(Map<String, dynamic> json) {
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

    City({this.id = -1, this.name = '', this.governorateId = -1});

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

- [ ] **Step 3: Verify**

  ```bash
  flutter analyze lib/models/
  ```
  Expected: No issues.

- [ ] **Step 4: Commit**

  ```bash
  git add lib/models/governorate_model.dart lib/models/city_model.dart
  git commit -m "feat: add Governorate and City models"
  ```

---

### Task 4: Governorate/City API Methods

**Files:**
- Modify: `lib/api/core_apis.dart`

- [ ] **Step 1: Add getGovernorates() and getCities() methods**

  Open `lib/api/core_apis.dart`. Add these imports at the top if not already present:
  ```dart
  import '../models/governorate_model.dart';
  import '../models/city_model.dart';
  ```

  Then add these two methods (place them near other GET-only methods):

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

- [ ] **Step 2: Verify**

  ```bash
  flutter analyze lib/api/core_apis.dart
  ```
  Expected: No issues.

- [ ] **Step 3: Commit**

  ```bash
  git add lib/api/core_apis.dart
  git commit -m "feat: add getGovernorates and getCities API methods"
  ```

---

### Task 5: Shared Components — LocationBadge & GlassInfoCard

**Files:**
- Create: `lib/components/location_badge.dart`
- Create: `lib/components/glass_info_card.dart`

- [ ] **Step 1: Create `lib/components/location_badge.dart`**

  ```dart
  import 'package:flutter/material.dart';
  import 'package:nb_utils/nb_utils.dart';

  import '../models/governorate_model.dart';
  import '../models/city_model.dart';
  import '../utils/colors.dart';
  import '../utils/app_common.dart';

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

- [ ] **Step 2: Create `lib/components/glass_info_card.dart`**

  ```dart
  import 'package:flutter/material.dart';
  import 'package:nb_utils/nb_utils.dart';

  import '../utils/colors.dart';
  import '../utils/app_common.dart';

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

- [ ] **Step 3: Verify**

  ```bash
  flutter analyze lib/components/location_badge.dart lib/components/glass_info_card.dart
  ```
  Expected: No issues.

- [ ] **Step 4: Commit**

  ```bash
  git add lib/components/location_badge.dart lib/components/glass_info_card.dart
  git commit -m "feat: add LocationBadge and GlassInfoCard shared components"
  ```

---

### Task 6: GovernoratesCityPicker Widget

**Files:**
- Create: `lib/components/governorates_city_picker.dart`

- [ ] **Step 1: Create the widget**

  Create `lib/components/governorates_city_picker.dart`:

  ```dart
  import 'package:flutter/material.dart';
  import 'package:get/get.dart';
  import 'package:nb_utils/nb_utils.dart';

  import '../api/core_apis.dart';
  import '../main.dart';
  import '../models/governorate_model.dart';
  import '../models/city_model.dart';
  import '../utils/app_common.dart';
  import '../utils/colors.dart';

  // Session-level cache — filled once per app launch
  final RxList<Governorate> _cachedGovernorates = RxList<Governorate>();
  final Map<int, List<City>> _citiesCache = {};

  class GovernoratesCityPicker extends StatefulWidget {
    final int? selectedGovernorateId;
    final int? selectedCityId;
    final void Function(int? governorateId) onGovernorateChanged;
    final void Function(int? cityId) onCityChanged;
    final EdgeInsetsGeometry? padding;

    const GovernoratesCityPicker({
      super.key,
      this.selectedGovernorateId,
      this.selectedCityId,
      required this.onGovernorateChanged,
      required this.onCityChanged,
      this.padding,
    });

    @override
    State<GovernoratesCityPicker> createState() => _GovernoratesCityPickerState();
  }

  class _GovernoratesCityPickerState extends State<GovernoratesCityPicker> {
    bool _isLoadingGovernorates = false;
    bool _isLoadingCities = false;
    List<City> _cities = [];

    @override
    void initState() {
      super.initState();
      _loadGovernorates();
      if (widget.selectedGovernorateId != null) {
        _loadCities(widget.selectedGovernorateId!);
      }
    }

    Future<void> _loadGovernorates() async {
      if (_cachedGovernorates.isNotEmpty) return;
      setState(() => _isLoadingGovernorates = true);
      try {
        final list = await CoreServiceApis.getGovernorates();
        _cachedGovernorates.assignAll(list);
      } catch (e) {
        log('GovernoratesCityPicker: error loading governorates: $e');
      } finally {
        if (mounted) setState(() => _isLoadingGovernorates = false);
      }
    }

    Future<void> _loadCities(int governorateId) async {
      if (_citiesCache.containsKey(governorateId)) {
        if (mounted) setState(() => _cities = _citiesCache[governorateId]!);
        return;
      }
      setState(() => _isLoadingCities = true);
      try {
        final list = await CoreServiceApis.getCities(governorateId: governorateId);
        _citiesCache[governorateId] = list;
        if (mounted) setState(() => _cities = list);
      } catch (e) {
        log('GovernoratesCityPicker: error loading cities: $e');
      } finally {
        if (mounted) setState(() => _isLoadingCities = false);
      }
    }

    void _onGovernorateChanged(int? id) {
      setState(() => _cities = []);
      widget.onGovernorateChanged(id);
      if (id != null) _loadCities(id);
    }

    @override
    Widget build(BuildContext context) {
      return Padding(
        padding: widget.padding ?? EdgeInsets.zero,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDarkMode.value ? inputFillColorDark : inputFillColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDarkMode.value ? glassStrokeDark : glassStrokeLight,
            ),
          ),
          child: Obx(() => Row(
            children: [
              Expanded(child: _buildGovernorateDropdown()),
              const SizedBox(width: 12),
              Expanded(child: _buildCityDropdown()),
            ],
          )),
        ),
      );
    }

    Widget _buildGovernorateDropdown() {
      if (_isLoadingGovernorates) {
        return const SizedBox(height: 40, child: Center(child: LinearProgressIndicator()));
      }
      final items = <DropdownMenuItem<int?>>[
        DropdownMenuItem<int?>(
          value: null,
          child: Text(locale.value.allGovernorates, style: secondaryTextStyle(size: 13)),
        ),
        ..._cachedGovernorates.map((g) => DropdownMenuItem<int?>(
          value: g.id,
          child: Text(g.name, style: primaryTextStyle(size: 13)),
        )),
      ];
      return DropdownButtonFormField<int?>(
        value: widget.selectedGovernorateId,
        items: items,
        onChanged: _onGovernorateChanged,
        decoration: InputDecoration(
          labelText: locale.value.governorate,
          labelStyle: secondaryTextStyle(size: 12),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          isDense: true,
        ),
        isExpanded: true,
      );
    }

    Widget _buildCityDropdown() {
      if (_isLoadingCities) {
        return const SizedBox(height: 40, child: Center(child: LinearProgressIndicator()));
      }
      final isEnabled = widget.selectedGovernorateId != null && _cities.isNotEmpty;
      final items = <DropdownMenuItem<int?>>[
        DropdownMenuItem<int?>(
          value: null,
          child: Text(locale.value.allCities, style: secondaryTextStyle(size: 13)),
        ),
        ..._cities.map((c) => DropdownMenuItem<int?>(
          value: c.id,
          child: Text(c.name, style: primaryTextStyle(size: 13)),
        )),
      ];
      return DropdownButtonFormField<int?>(
        value: widget.selectedCityId,
        items: isEnabled ? items : null,
        onChanged: isEnabled ? widget.onCityChanged : null,
        decoration: InputDecoration(
          labelText: locale.value.city,
          labelStyle: secondaryTextStyle(size: 12),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          isDense: true,
        ),
        isExpanded: true,
        disabledHint: Text(locale.value.selectGovernorate, style: secondaryTextStyle(size: 12)),
      );
    }
  }
  ```

- [ ] **Step 2: Verify**

  ```bash
  flutter analyze lib/components/governorates_city_picker.dart
  ```
  Expected: No issues.

- [ ] **Step 3: Commit**

  ```bash
  git add lib/components/governorates_city_picker.dart
  git commit -m "feat: add GovernoratesCityPicker cascading dropdown widget"
  ```

---

### Task 7: Foundation Locale Strings

**Files:**
- Modify: `lib/locale/languages.dart`
- Modify: `lib/locale/language_en.dart`
- Modify: `lib/locale/language_ar.dart`
- Modify: `lib/locale/language_de.dart`
- Modify: `lib/locale/language_fr.dart`
- Modify: `lib/locale/language_hi.dart`

- [ ] **Step 1: Add abstract keys to `lib/locale/languages.dart`**

  Add these keys in the abstract class body (place near geographically-related or utility keys):

  ```dart
  // Location
  String get governorate;
  String get city;
  String get allGovernorates;
  String get allCities;
  String get selectGovernorate;
  String get selectCity;
  String get locationFilter;
  ```

- [ ] **Step 2: Add English translations to `lib/locale/language_en.dart`**

  ```dart
  @override String get governorate => 'Governorate';
  @override String get city => 'City';
  @override String get allGovernorates => 'All Governorates';
  @override String get allCities => 'All Cities';
  @override String get selectGovernorate => 'Select Governorate';
  @override String get selectCity => 'Select City';
  @override String get locationFilter => 'Location';
  ```

- [ ] **Step 3: Add Arabic translations to `lib/locale/language_ar.dart`**

  ```dart
  @override String get governorate => 'المحافظة';
  @override String get city => 'المدينة';
  @override String get allGovernorates => 'كل المحافظات';
  @override String get allCities => 'كل المدن';
  @override String get selectGovernorate => 'اختر المحافظة';
  @override String get selectCity => 'اختر المدينة';
  @override String get locationFilter => 'الموقع';
  ```

- [ ] **Step 4: Add German translations to `lib/locale/language_de.dart`**

  ```dart
  @override String get governorate => 'Gouvernement';
  @override String get city => 'Stadt';
  @override String get allGovernorates => 'Alle Gouvernements';
  @override String get allCities => 'Alle Städte';
  @override String get selectGovernorate => 'Gouvernement wählen';
  @override String get selectCity => 'Stadt wählen';
  @override String get locationFilter => 'Standort';
  ```

- [ ] **Step 5: Add French translations to `lib/locale/language_fr.dart`**

  ```dart
  @override String get governorate => 'Gouvernorat';
  @override String get city => 'Ville';
  @override String get allGovernorates => 'Tous les gouvernorats';
  @override String get allCities => 'Toutes les villes';
  @override String get selectGovernorate => 'Sélectionner le gouvernorat';
  @override String get selectCity => 'Sélectionner la ville';
  @override String get locationFilter => 'Emplacement';
  ```

- [ ] **Step 6: Add Hindi translations to `lib/locale/language_hi.dart`**

  ```dart
  @override String get governorate => 'प्रांत';
  @override String get city => 'शहर';
  @override String get allGovernorates => 'सभी प्रांत';
  @override String get allCities => 'सभी शहर';
  @override String get selectGovernorate => 'प्रांत चुनें';
  @override String get selectCity => 'शहर चुनें';
  @override String get locationFilter => 'स्थान';
  ```

- [ ] **Step 7: Verify**

  ```bash
  flutter analyze lib/locale/
  ```
  Expected: No issues (all 5 language classes implement the new abstract keys).

- [ ] **Step 8: Build check and commit**

  ```bash
  flutter build apk --debug
  git add lib/locale/
  git commit -m "feat: add location filter locale strings (Phase 1)"
  ```

---

## Phase 2: Nurses Extension (Spec Phase 3 — validates the pattern)

### Task 8: Nurse Model — Add Governorate/City Fields

**Files:**
- Modify: `lib/screens/nurse/model/nurse_model.dart`

The `Nurse` class currently has `id`, `nurseId`, `name`, etc. (no governorate/city). We add nullable fields.

- [ ] **Step 1: Add imports to nurse_model.dart**

  At the top of `lib/screens/nurse/model/nurse_model.dart`, add:
  ```dart
  import '../../../models/governorate_model.dart';
  import '../../../models/city_model.dart';
  ```

- [ ] **Step 2: Add fields to Nurse class**

  In the `Nurse` class field declarations, add after `updatedAt`:
  ```dart
  Governorate? governorate;
  City? city;
  ```

  In `Nurse({...})` constructor, add:
  ```dart
  this.governorate,
  this.city,
  ```

  In `Nurse.fromJson()`, add after `updatedAt`:
  ```dart
  governorate: json['governorate'] is Map
      ? Governorate.fromJson(json['governorate'])
      : null,
  city: json['city'] is Map ? City.fromJson(json['city']) : null,
  ```

- [ ] **Step 3: Verify**

  ```bash
  flutter analyze lib/screens/nurse/model/nurse_model.dart
  ```
  Expected: No issues.

- [ ] **Step 4: Commit**

  ```bash
  git add lib/screens/nurse/model/nurse_model.dart
  git commit -m "feat: add governorate/city fields to Nurse model"
  ```

---

### Task 9: searchNurses() API Method

**Files:**
- Modify: `lib/api/core_apis.dart`

Keep existing `getNurseList()` untouched. Add new method using `APIEndPoints.nursesSearch`.

- [ ] **Step 1: Add searchNurses() to core_apis.dart**

  Add after the existing `getNurseList()` method. Ensure `nurse_model.dart` is imported (it should be already).

  ```dart
  /// New search method using the new backend search endpoint.
  /// Keep getNurseList() for backward compatibility.
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

  **Note:** `NurseListResponse` currently parses pagination from `json["meta"]`. The new backend uses `json["data"]["pagination"]`. After adding this method, also update `NurseListResponse.fromJson()` to handle the new format:

  ```dart
  // In NurseListResponse.fromJson(), update pagination parsing to handle both formats:
  data: json["data"] is List
      ? List<Nurse>.from(json["data"].map((x) => Nurse.fromJson(x)))
      : json["data"] is Map && json["data"]["items"] is List
          ? (json["data"]["items"] as List).map((x) => Nurse.fromJson(x)).toList()
          : [],
  currentPage: json["meta"] is Map
      ? (json["meta"]["current_page"] ?? 1)
      : json["data"] is Map && json["data"]["pagination"] is Map
          ? (json["data"]["pagination"]["current_page"] ?? 1)
          : 1,
  lastPage: json["meta"] is Map
      ? (json["meta"]["last_page"] ?? 1)
      : json["data"] is Map && json["data"]["pagination"] is Map
          ? (json["data"]["pagination"]["last_page"] ?? 1)
          : 1,
  ```

- [ ] **Step 2: Verify**

  ```bash
  flutter analyze lib/api/core_apis.dart
  ```
  Expected: No issues.

- [ ] **Step 3: Commit**

  ```bash
  git add lib/api/core_apis.dart lib/screens/nurse/model/nurse_model.dart
  git commit -m "feat: add searchNurses API method and dual-format NurseListResponse parsing"
  ```

---

### Task 10: NurseListController — Add Location Filters

**Files:**
- Modify: `lib/screens/nurse/nurse_list_controller.dart`

- [ ] **Step 1: Add imports**

  The controller already imports `nurse_model.dart` and `core_apis.dart`. Add imports for governorate/city types if not transitive:
  ```dart
  // These imports are needed if RxnInt usage requires it — RxnInt is from get package, already imported
  ```
  (No new imports needed for RxnInt — it's in `get` which is already imported.)

- [ ] **Step 2: Add reactive location filter vars**

  In `NurseListController`, after `selectedAvailability`:
  ```dart
  RxnInt selectedGovernorateId = RxnInt();
  RxnInt selectedCityId = RxnInt();
  ```

- [ ] **Step 3: Add location change handlers**

  After `onFilterChanged()`:
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

- [ ] **Step 4: Switch getNurses() to call searchNurses()**

  Replace the existing `CoreServiceApis.getNurseList(...)` call inside `getNurses()` with:
  ```dart
  CoreServiceApis.searchNurses(
    page: page.value,
    perPage: Constants.perPageItem,
    nurseList: nurses,
    search: searchCont.text.trim(),
    availability: selectedAvailability.value,
    governorateId: selectedGovernorateId.value,
    cityId: selectedCityId.value,
    lastPageCallBack: (isLast) => isLastPage(isLast),
  ),
  ```

- [ ] **Step 5: Verify**

  ```bash
  flutter analyze lib/screens/nurse/nurse_list_controller.dart
  ```
  Expected: No issues.

- [ ] **Step 6: Commit**

  ```bash
  git add lib/screens/nurse/nurse_list_controller.dart
  git commit -m "feat: add location filter vars and searchNurses to NurseListController"
  ```

---

### Task 11: Nurse List Screen & Card Updates

**Files:**
- Modify: `lib/screens/nurse/nurse_list_screen.dart`
- Modify: `lib/screens/nurse/components/nurse_card.dart`

- [ ] **Step 1: Add GovernoratesCityPicker to nurse_list_screen.dart**

  Add the import at the top:
  ```dart
  import '../../../components/governorates_city_picker.dart';
  ```

  Locate the section after the search bar in the `AnimatedScrollView` body. Insert the picker between the search bar and existing availability filter chips:
  ```dart
  GovernoratesCityPicker(
    selectedGovernorateId: controller.selectedGovernorateId.value,
    selectedCityId: controller.selectedCityId.value,
    onGovernorateChanged: controller.onGovernorateChanged,
    onCityChanged: controller.onCityChanged,
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  ),
  ```

  Wrap with `Obx(() => ...)` since it reads reactive state:
  ```dart
  Obx(() => GovernoratesCityPicker(
    selectedGovernorateId: controller.selectedGovernorateId.value,
    selectedCityId: controller.selectedCityId.value,
    onGovernorateChanged: controller.onGovernorateChanged,
    onCityChanged: controller.onCityChanged,
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  )),
  ```

- [ ] **Step 2: Add location pill to nurse_card.dart**

  Add imports:
  ```dart
  import '../../../components/location_badge.dart';
  ```

  After the name/specialization row in `NurseCard`, add:
  ```dart
  if (nurse.governorate != null) ...[
    const SizedBox(height: 6),
    locationBadge(nurse.governorate, nurse.city),
  ],
  ```

- [ ] **Step 3: Verify**

  ```bash
  flutter analyze lib/screens/nurse/
  ```
  Expected: No issues.

- [ ] **Step 4: Commit**

  ```bash
  git add lib/screens/nurse/nurse_list_screen.dart lib/screens/nurse/components/nurse_card.dart
  git commit -m "feat: add location filter UI to NurseList screen and location pill to NurseCard"
  ```

---

## Phase 3: Lab Tests Extension (Spec Phase 5)

### Task 12: LabTest Model — Add Governorate/City Fields

**Files:**
- Modify: `lib/screens/lab_test/model/lab_test_model.dart`

- [ ] **Step 1: Add imports to lab_test_model.dart**

  ```dart
  import '../../../models/governorate_model.dart';
  import '../../../models/city_model.dart';
  ```

- [ ] **Step 2: Add fields to LabTest class**

  In `LabTest` class, add after `updatedAt`:
  ```dart
  Governorate? governorate;
  City? city;
  ```
  In constructor and `fromJson()`:
  ```dart
  // Constructor
  this.governorate,
  this.city,

  // fromJson
  governorate: json['governorate'] is Map
      ? Governorate.fromJson(json['governorate'])
      : null,
  city: json['city'] is Map ? City.fromJson(json['city']) : null,
  ```

- [ ] **Step 3: Verify and commit**

  ```bash
  flutter analyze lib/screens/lab_test/model/lab_test_model.dart
  git add lib/screens/lab_test/model/lab_test_model.dart
  git commit -m "feat: add governorate/city fields to LabTest model"
  ```

---

### Task 13: searchLabs() API Method

**Files:**
- Modify: `lib/api/core_apis.dart`

- [ ] **Step 1: Add searchLabs() to core_apis.dart**

  Keep existing `getLabTestList()` unchanged. Add after it:

  ```dart
  /// New search method using the new backend labs/search endpoint.
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

- [ ] **Step 2: Verify and commit**

  ```bash
  flutter analyze lib/api/core_apis.dart
  git add lib/api/core_apis.dart
  git commit -m "feat: add searchLabs API method"
  ```

---

### Task 14: LabTestListController — Add Location Filters

**Files:**
- Modify: `lib/screens/lab_test/lab_test_list_controller.dart`

- [ ] **Step 1: Add reactive location filter vars**

  After `selectedDepartment` declaration:
  ```dart
  RxnInt selectedGovernorateId = RxnInt();
  RxnInt selectedCityId = RxnInt();
  ```

- [ ] **Step 2: Add location change handlers**

  After `onFilterChanged()`:
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

- [ ] **Step 3: Switch getLabTests() to call searchLabs()**

  Replace `CoreServiceApis.getLabTestList(...)` with:
  ```dart
  CoreServiceApis.searchLabs(
    page: page.value,
    perPage: Constants.perPageItem,
    labTestList: labTests,
    testName: searchCont.text.trim(),
    governorateId: selectedGovernorateId.value,
    cityId: selectedCityId.value,
    lastPageCallBack: (isLast) => isLastPage(isLast),
  ),
  ```
  **Note:** The `department` and `categoryId` filters are dropped in the new search endpoint. If these need to be preserved, add them as query params to `searchLabs()` or keep calling the old method for department-filtered queries. Check with the backend team if `labs/search` supports `department` param.

- [ ] **Step 4: Verify and commit**

  ```bash
  flutter analyze lib/screens/lab_test/lab_test_list_controller.dart
  git add lib/screens/lab_test/lab_test_list_controller.dart
  git commit -m "feat: add location filters to LabTestListController"
  ```

---

### Task 15: Lab Test List Screen & Card Updates

**Files:**
- Modify: `lib/screens/lab_test/lab_test_list_screen.dart`
- Modify: `lib/screens/lab_test/components/lab_test_card.dart`

- [ ] **Step 1: Add GovernoratesCityPicker to lab_test_list_screen.dart**

  Add import:
  ```dart
  import '../../../components/governorates_city_picker.dart';
  ```

  Insert after the search bar, before existing department filter chips:
  ```dart
  Obx(() => GovernoratesCityPicker(
    selectedGovernorateId: controller.selectedGovernorateId.value,
    selectedCityId: controller.selectedCityId.value,
    onGovernorateChanged: controller.onGovernorateChanged,
    onCityChanged: controller.onCityChanged,
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  )),
  ```

- [ ] **Step 2: Add location pill to lab_test_card.dart**

  Add import and location badge:
  ```dart
  import '../../../components/location_badge.dart';

  // In card body, after name/description:
  if (labTest.governorate != null) ...[
    const SizedBox(height: 6),
    locationBadge(labTest.governorate, labTest.city),
  ],
  ```

- [ ] **Step 3: Verify and commit**

  ```bash
  flutter analyze lib/screens/lab_test/
  git add lib/screens/lab_test/lab_test_list_screen.dart lib/screens/lab_test/components/lab_test_card.dart
  git commit -m "feat: add location filter UI to LabTest screen and card"
  ```

---

## Phase 4: Doctors & Clinics Extension (Spec Phase 2)

### Task 16: Doctor Model — Add Governorate/City Fields

**Files:**
- Modify: `lib/screens/doctor/model/doctor_list_res.dart`

The `Doctor` class already has `cityId`/`cityName` fields (old-style text fields). We add separate nullable `Governorate?`/`City?` fields for the new nested objects from the new endpoint.

- [ ] **Step 1: Add imports to doctor_list_res.dart**

  ```dart
  import '../../../models/governorate_model.dart';
  import '../../../models/city_model.dart';
  ```

- [ ] **Step 2: Add new nullable fields to Doctor class**

  After `services` declaration, add:
  ```dart
  Governorate? governorate;
  City? governorateCity; // named to avoid conflict with existing cityId/cityName
  ```

  **Note:** The `Doctor` class already has a `cityId` int field and a `clinicId` / `cityName` string field. Name the new `City?` field `governorateCity` (or `locationCity`) to avoid collision with the existing `cityId` int field.

  In constructor:
  ```dart
  this.governorate,
  this.governorateCity,
  ```

  In `fromJson()`, after existing fields:
  ```dart
  governorate: json['governorate'] is Map
      ? Governorate.fromJson(json['governorate'])
      : null,
  governorateCity: json['city'] is Map
      ? City.fromJson(json['city'])
      : null,
  ```

- [ ] **Step 3: Verify and commit**

  ```bash
  flutter analyze lib/screens/doctor/model/doctor_list_res.dart
  git add lib/screens/doctor/model/doctor_list_res.dart
  git commit -m "feat: add governorate/city fields to Doctor model"
  ```

---

### Task 17: searchDoctors() API Method

**Files:**
- Modify: `lib/api/core_apis.dart`

- [ ] **Step 1: Add searchDoctors() to core_apis.dart**

  The existing `getDoctors()` method should remain unchanged. Add:

  ```dart
  /// New search method using the new backend doctors/search endpoint.
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

  **Note:** This requires a `DoctorListResponse` class that parses the new backend format (`data.items` + `data.pagination`). Check `lib/screens/doctor/model/doctor_list_res.dart` — the existing response class may use a different format. If it uses the old format, add dual-format parsing similar to what was done for `NurseListResponse` in Task 9.

- [ ] **Step 2: Verify and commit**

  ```bash
  flutter analyze lib/api/core_apis.dart
  git add lib/api/core_apis.dart
  git commit -m "feat: add searchDoctors API method"
  ```

---

### Task 18: DoctorListController — Add Location Filters

**Files:**
- Modify: `lib/screens/doctor/doctor_list_controller.dart`

The existing `DoctorListController` uses `searchDoctorCont` (not `searchCont`), a stream-based search, and doesn't have `debounce()`. It also uses `serviceId`, `clinicId`, `ratingMin`/`ratingMax` filters.

- [ ] **Step 1: Add reactive location filter vars**

  After `ratingMax` declaration:
  ```dart
  RxnInt selectedGovernorateId = RxnInt();
  RxnInt selectedCityId = RxnInt();
  ```

- [ ] **Step 2: Add location change handlers**

  After the existing filter methods:
  ```dart
  void onGovernorateChanged(int? id) {
    selectedGovernorateId.value = id;
    selectedCityId.value = null;
    page(1);
    getDoctors();
  }

  void onCityChanged(int? id) {
    selectedCityId.value = id;
    page(1);
    getDoctors();
  }
  ```

- [ ] **Step 3: Update getDoctors() to call searchDoctors()**

  Replace `CoreServiceApis.getDoctors(...)` with `CoreServiceApis.searchDoctors(...)`, passing location params:
  ```dart
  CoreServiceApis.searchDoctors(
    page: page.value,
    perPage: 20,
    doctorList: doctors,
    name: searchDoctorCont.text.trim(),
    governorateId: selectedGovernorateId.value,
    cityId: selectedCityId.value,
    lastPageCallBack: (p0) => isLastPage(p0),
  ),
  ```

- [ ] **Step 4: Verify and commit**

  ```bash
  flutter analyze lib/screens/doctor/doctor_list_controller.dart
  git add lib/screens/doctor/doctor_list_controller.dart
  git commit -m "feat: add location filters to DoctorListController"
  ```

---

### Task 19: Doctor List Screen & Card Updates

**Files:**
- Modify: `lib/screens/doctor/doctor_list_screen.dart`
- Modify: `lib/screens/doctor/search_doctor_widget.dart` (if doctor card is defined here)

- [ ] **Step 1: Add GovernoratesCityPicker to doctor list screen**

  Read `lib/screens/doctor/doctor_list_screen.dart` first to find where the search UI is. Add:
  ```dart
  import '../../components/governorates_city_picker.dart';

  // After search bar:
  Obx(() => GovernoratesCityPicker(
    selectedGovernorateId: controller.selectedGovernorateId.value,
    selectedCityId: controller.selectedCityId.value,
    onGovernorateChanged: controller.onGovernorateChanged,
    onCityChanged: controller.onCityChanged,
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  )),
  ```

- [ ] **Step 2: Add location pill to doctor card**

  Find the doctor card widget (likely in `search_doctor_widget.dart` or `doctor_list_screen.dart`). Add location badge:
  ```dart
  import '../../components/location_badge.dart';

  // After name/specialty:
  if (doctor.governorate != null) ...[
    const SizedBox(height: 6),
    locationBadge(doctor.governorate, doctor.governorateCity),
  ],
  ```

- [ ] **Step 3: Verify and commit**

  ```bash
  flutter analyze lib/screens/doctor/
  git add lib/screens/doctor/
  git commit -m "feat: add location filter UI to Doctor list screen and card"
  ```

---

### Task 20: Clinic Model — Add Governorate/City Fields

**Files:**
- Modify: `lib/screens/clinic/model/clinics_res_model.dart`

The `Clinic` class already has `cityId`/`cityName`. Add new nullable `Governorate?`/`City?` fields.

- [ ] **Step 1: Add imports**

  ```dart
  import '../../../models/governorate_model.dart';
  import '../../../models/city_model.dart';
  ```

- [ ] **Step 2: Add new fields to Clinic class**

  After `satisfactionPercentage` (or any safe location):
  ```dart
  Governorate? governorate;
  City? governorateCity;
  ```

  In constructor and `fromJson()`:
  ```dart
  this.governorate,
  this.governorateCity,

  // fromJson:
  governorate: json['governorate'] is Map
      ? Governorate.fromJson(json['governorate'])
      : null,
  governorateCity: json['city'] is Map
      ? City.fromJson(json['city'])
      : null,
  ```

- [ ] **Step 3: Verify and commit**

  ```bash
  flutter analyze lib/screens/clinic/model/clinics_res_model.dart
  git add lib/screens/clinic/model/clinics_res_model.dart
  git commit -m "feat: add governorate/city fields to Clinic model"
  ```

---

### Task 21: searchClinics() API Method

**Files:**
- Modify: `lib/api/core_apis.dart`

- [ ] **Step 1: Add searchClinics() — keep existing getClinics() unchanged**

  ```dart
  /// New search method using the new backend clinics/search endpoint.
  static Future<RxList<Clinic>> searchClinics({
    int page = 1,
    int perPage = 20,
    required List<Clinic> clinicList,
    Function(bool)? lastPageCallBack,
    String name = '',
    int? governorateId,
    int? cityId,
    int? specialtyId,
  }) async {
    String nameParam = name.isNotEmpty ? '&name=${Uri.encodeQueryComponent(name)}' : '';
    String govParam = governorateId != null ? '&governorate_id=$governorateId' : '';
    String cityParam = cityId != null ? '&city_id=$cityId' : '';
    String specParam = specialtyId != null ? '&specialty_id=$specialtyId' : '';

    final res = ClinicsResModel.fromJson(await handleResponse(
      await buildHttpResponse(
        '${APIEndPoints.clinicsSearch}?per_page=$perPage&page=$page$nameParam$govParam$cityParam$specParam',
        method: HttpMethodType.GET,
      ),
    ));

    if (page == 1) clinicList.clear();
    clinicList.addAll(res.data);
    lastPageCallBack?.call(res.currentPage >= res.lastPage);

    return clinicList.obs;
  }
  ```

  **Note:** Find the actual response class name used by `getClinics()` in `core_apis.dart` and use the same class. Update its `fromJson` to handle dual pagination format if needed.

- [ ] **Step 2: Verify and commit**

  ```bash
  flutter analyze lib/api/core_apis.dart
  git add lib/api/core_apis.dart
  git commit -m "feat: add searchClinics API method"
  ```

---

### Task 22: ClinicListController — Add Location Filters

**Files:**
- Modify: `lib/screens/clinic/clinic_list_controller.dart`

- [ ] **Step 1: Add reactive location filter vars**

  After `priceMax` declaration:
  ```dart
  RxnInt selectedGovernorateId = RxnInt();
  RxnInt selectedCityId = RxnInt();
  ```

- [ ] **Step 2: Add location change handlers**

  ```dart
  void onGovernorateChanged(int? id) {
    selectedGovernorateId.value = id;
    selectedCityId.value = null;
    page(1);
    getClinicList();
  }

  void onCityChanged(int? id) {
    selectedCityId.value = id;
    page(1);
    getClinicList();
  }
  ```

- [ ] **Step 3: Switch getClinicList() to call searchClinics()**

  Replace `CoreServiceApis.getClinics(...)` with:
  ```dart
  CoreServiceApis.searchClinics(
    page: page.value,
    perPage: 20,
    clinicList: clinics,
    name: searchClinicCont.text.trim(),
    governorateId: selectedGovernorateId.value,
    cityId: selectedCityId.value,
    lastPageCallBack: (p0) => isLastPage(p0),
  ),
  ```

- [ ] **Step 4: Verify and commit**

  ```bash
  flutter analyze lib/screens/clinic/clinic_list_controller.dart
  git add lib/screens/clinic/clinic_list_controller.dart
  git commit -m "feat: add location filters to ClinicListController"
  ```

---

### Task 23: Clinic List Screen & Card Updates

**Files:**
- Modify: `lib/screens/clinic/clinics_list_screen.dart`
- Modify: `lib/screens/clinic/components/popular_clinic_card.dart`

- [ ] **Step 1: Add GovernoratesCityPicker to clinics_list_screen.dart**

  Add import and picker widget (same pattern as nurse/lab):
  ```dart
  import '../../components/governorates_city_picker.dart';

  Obx(() => GovernoratesCityPicker(
    selectedGovernorateId: controller.selectedGovernorateId.value,
    selectedCityId: controller.selectedCityId.value,
    onGovernorateChanged: controller.onGovernorateChanged,
    onCityChanged: controller.onCityChanged,
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  )),
  ```

- [ ] **Step 2: Add location pill to popular_clinic_card.dart**

  ```dart
  import '../../components/location_badge.dart';

  // After clinic name:
  if (clinic.governorate != null) ...[
    const SizedBox(height: 6),
    locationBadge(clinic.governorate, clinic.governorateCity),
  ],
  ```

- [ ] **Step 3: Verify and Phase 4 build check**

  ```bash
  flutter analyze lib/screens/clinic/
  flutter build apk --debug
  git add lib/screens/clinic/
  git commit -m "feat: add location filter UI to Clinic list screen and card"
  ```

---

## Phase 5: Radiology (Spec Phase 6 — New Browse Module)

### Task 24: Radiology Constants & Locale Strings

**Files:**
- Modify: `lib/utils/constants.dart`
- Modify: `lib/locale/languages.dart` + 5 language files

- [ ] **Step 1: Add ScanTypeConst to constants.dart**

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

- [ ] **Step 2: Add abstract locale keys to languages.dart**

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

- [ ] **Step 3: Add translations to all 5 language files**

  **language_en.dart:**
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

  **language_ar.dart:**
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

  **language_de.dart:**
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

  **language_fr.dart:**
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

  **language_hi.dart:**
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

- [ ] **Step 4: Verify and commit**

  ```bash
  flutter analyze lib/locale/ lib/utils/constants.dart
  git add lib/utils/constants.dart lib/locale/
  git commit -m "feat: add ScanTypeConst and radiology locale strings"
  ```

---

### Task 25: RadiologyCenter Model

**Files:**
- Create: `lib/screens/radiology/model/radiology_center_model.dart`

- [ ] **Step 1: Create the model file**

  ```dart
  import '../../../models/governorate_model.dart';
  import '../../../models/city_model.dart';

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
    List<String> scanTypes;
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

- [ ] **Step 2: Verify and commit**

  ```bash
  flutter analyze lib/screens/radiology/model/radiology_center_model.dart
  git add lib/screens/radiology/model/radiology_center_model.dart
  git commit -m "feat: add RadiologyCenter model"
  ```

---

### Task 26: Radiology API Methods

**Files:**
- Modify: `lib/api/core_apis.dart`

- [ ] **Step 1: Add radiology import and methods**

  Add import:
  ```dart
  import '../screens/radiology/model/radiology_center_model.dart';
  ```

  Add methods:
  ```dart
  // ==================== Radiology ====================

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

- [ ] **Step 2: Verify and commit**

  ```bash
  flutter analyze lib/api/core_apis.dart
  git add lib/api/core_apis.dart
  git commit -m "feat: add radiology API methods"
  ```

---

### Task 27: RadiologyListController

**Files:**
- Create: `lib/screens/radiology/radiology_list_controller.dart`

- [ ] **Step 1: Create the controller**

  ```dart
  import 'package:flutter/material.dart';
  import 'package:get/get.dart';
  import 'package:nb_utils/nb_utils.dart';

  import '../../api/core_apis.dart';
  import '../../main.dart';
  import '../../utils/constants.dart';
  import 'model/radiology_center_model.dart';

  class RadiologyListController extends GetxController {
    Rx<Future<RxList<RadiologyCenter>>> radiologyFuture =
        Future(() => RxList<RadiologyCenter>()).obs;
    RxList<RadiologyCenter> radiologyCenters = RxList<RadiologyCenter>();
    RxBool isLoading = false.obs;
    RxBool isLastPage = false.obs;
    RxInt page = 1.obs;

    TextEditingController searchCont = TextEditingController();
    RxString searchQuery = ''.obs;

    RxnInt selectedGovernorateId = RxnInt();
    RxnInt selectedCityId = RxnInt();

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

- [ ] **Step 2: Verify and commit**

  ```bash
  flutter analyze lib/screens/radiology/radiology_list_controller.dart
  git add lib/screens/radiology/radiology_list_controller.dart
  git commit -m "feat: add RadiologyListController"
  ```

---

### Task 28: Radiology List Screen & Card

**Files:**
- Create: `lib/screens/radiology/components/radiology_center_card.dart`
- Create: `lib/screens/radiology/radiology_list_screen.dart`

- [ ] **Step 1: Create `lib/screens/radiology/components/radiology_center_card.dart`**

  Pattern mirrors `NurseCard`. Key structure:
  ```dart
  import 'package:flutter/material.dart';
  import 'package:nb_utils/nb_utils.dart';
  import 'package:google_fonts/google_fonts.dart';

  import '../../../components/cached_image_widget.dart';
  import '../../../components/location_badge.dart';
  import '../../../utils/colors.dart';
  import '../../../utils/app_common.dart';
  import '../model/radiology_center_model.dart';

  class RadiologyCenterCard extends StatelessWidget {
    final RadiologyCenter center;
    final VoidCallback onTap;

    const RadiologyCenterCard({super.key, required this.center, required this.onTap});

    @override
    Widget build(BuildContext context) {
      return GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDarkMode.value ? surfaceElevatedDark : surfaceElevated,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: softShadowColor,
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(32),
                    child: CachedImageWidget(
                      url: center.profileImage,
                      height: 64,
                      width: 64,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          center.name,
                          style: boldTextStyle(
                            size: 16,
                            fontFamily: GoogleFonts.outfit().fontFamily,
                          ),
                        ),
                        const SizedBox(height: 4),
                        locationBadge(center.governorate, center.city),
                        const SizedBox(height: 6),
                        if (center.rating > 0)
                          Row(
                            children: [
                              Icon(Icons.star, color: Colors.amber, size: 14),
                              const SizedBox(width: 4),
                              Text(
                                center.rating.toStringAsFixed(1),
                                style: secondaryTextStyle(size: 12),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              if (center.scanTypes.isNotEmpty) ...[
                const SizedBox(height: 10),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: center.scanTypes.map((type) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: appColorPrimary.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      type.toUpperCase(),
                      style: primaryTextStyle(size: 10, color: appColorPrimary),
                    ),
                  )).toList(),
                ),
              ],
            ],
          ),
        ),
      );
    }
  }
  ```

- [ ] **Step 2: Create `lib/screens/radiology/radiology_list_screen.dart`**

  Pattern mirrors `NurseListScreen`. Key structure:
  ```dart
  import 'package:flutter/material.dart';
  import 'package:get/get.dart';
  import 'package:nb_utils/nb_utils.dart';

  import '../../components/app_scaffold.dart';
  import '../../components/governorates_city_picker.dart';
  import '../../components/loader_widget.dart';
  import '../../main.dart';
  import '../../utils/colors.dart';
  import 'components/radiology_center_card.dart';
  import 'radiology_detail_screen.dart';
  import 'radiology_list_controller.dart';

  class RadiologyListScreen extends StatelessWidget {
    const RadiologyListScreen({super.key});

    @override
    Widget build(BuildContext context) {
      final controller = Get.put(RadiologyListController());

      return AppScaffoldNew(
        appBartitleText: locale.value.browseRadiology,
        hasLeadingWidget: true,
        appBarVerticalSize: Get.height * 0.12,
        isLoading: controller.isLoading,
        body: Obx(() => SnapHelperWidget<RxList<RadiologyCenter>>(
          future: controller.radiologyFuture.value,
          errorBuilder: (error) => _buildEmptyState(controller),
          loadingWidget: const LoaderWidget(),
          onSuccess: (centers) => AnimatedScrollView(
            listAnimationType: ListAnimationType.FadeIn,
            fadeInConfiguration: FadeInConfiguration(duration: 300.milliseconds),
            onNextPage: () {
              if (!controller.isLastPage.value) {
                controller.page.value++;
                controller.getRadiologyCenters(showLoader: false);
              }
            },
            children: [
              // Search bar
              _buildSearchBar(controller),
              const SizedBox(height: 8),
              // Location picker
              Obx(() => GovernoratesCityPicker(
                selectedGovernorateId: controller.selectedGovernorateId.value,
                selectedCityId: controller.selectedCityId.value,
                onGovernorateChanged: controller.onGovernorateChanged,
                onCityChanged: controller.onCityChanged,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              )),
              // Scan type filter chips
              Obx(() => _buildScanTypeFilters(controller)),
              const SizedBox(height: 8),
              // Results
              ...controller.radiologyCenters.mapIndexed((index, center) =>
                RadiologyCenterCard(
                  center: center,
                  onTap: () => Get.to(() => RadiologyDetailScreen(), arguments: center.id),
                ),
              ),
              if (controller.radiologyCenters.isEmpty && !controller.isLoading.value)
                _buildEmptyState(controller),
            ],
          ),
        )),
      );
    }

    Widget _buildSearchBar(RadiologyListController controller) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: AppTextField(
          controller: controller.searchCont,
          textFieldType: TextFieldType.NAME,
          decoration: InputDecoration(
            hintText: locale.value.search,
            prefixIcon: const Icon(Icons.search),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onChanged: controller.onSearchChanged,
        ),
      );
    }

    Widget _buildScanTypeFilters(RadiologyListController controller) {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: controller.scanTypeFilters.map((filter) {
            final isSelected = filter['key'] == controller.selectedScanType.value;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () => controller.onScanTypeChanged(filter['key']!),
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

    Widget _buildEmptyState(RadiologyListController controller) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.blur_circular_outlined, size: 64, color: appColorSecondary.withOpacity(0.4)),
            const SizedBox(height: 16),
            Text(
              locale.value.noRadiologyCentersFound,
              style: secondaryTextStyle(size: 16),
            ),
          ],
        ),
      );
    }
  }
  ```

- [ ] **Step 3: Verify and commit**

  ```bash
  flutter analyze lib/screens/radiology/
  git add lib/screens/radiology/
  git commit -m "feat: add Radiology list screen and card"
  ```

---

### Task 29: Radiology Detail Screen

**Files:**
- Create: `lib/screens/radiology/radiology_detail_screen.dart`

- [ ] **Step 1: Create the detail screen**

  Pattern mirrors nurse/lab test detail screens. Key structure:

  ```dart
  import 'package:flutter/material.dart';
  import 'package:get/get.dart';
  import 'package:nb_utils/nb_utils.dart';
  import 'package:google_fonts/google_fonts.dart';
  import 'package:url_launcher/url_launcher.dart';

  import '../../api/core_apis.dart';
  import '../../components/app_scaffold.dart';
  import '../../components/cached_image_widget.dart';
  import '../../components/glass_info_card.dart';
  import '../../components/loader_widget.dart';
  import '../../main.dart';
  import '../../utils/colors.dart';
  import '../../utils/app_common.dart';
  import 'model/radiology_center_model.dart';

  class RadiologyDetailScreen extends StatefulWidget {
    const RadiologyDetailScreen({super.key});

    @override
    State<RadiologyDetailScreen> createState() => _RadiologyDetailScreenState();
  }

  class _RadiologyDetailScreenState extends State<RadiologyDetailScreen> {
    RadiologyCenter? center;
    bool isLoading = true;
    String? error;

    @override
    void initState() {
      super.initState();
      _loadDetail();
    }

    Future<void> _loadDetail() async {
      final id = Get.arguments as int;
      try {
        final result = await CoreServiceApis.getRadiologyCenterDetail(id: id);
        if (mounted) setState(() { center = result; isLoading = false; });
      } catch (e) {
        if (mounted) setState(() { error = e.toString(); isLoading = false; });
      }
    }

    @override
    Widget build(BuildContext context) {
      if (isLoading) return const Scaffold(body: Center(child: LoaderWidget()));
      if (error != null || center == null) {
        return Scaffold(
          body: Center(child: Text(error ?? locale.value.somethingWentWrong)),
        );
      }

      return AppScaffoldNew(
        appBartitleText: center!.name,
        hasLeadingWidget: true,
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero image
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: CachedImageWidget(
                  url: center!.profileImage,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 16),
              // Name + rating
              Text(
                center!.name,
                style: boldTextStyle(size: 22, fontFamily: GoogleFonts.outfit().fontFamily),
              ),
              if (center!.rating > 0) ...[
                const SizedBox(height: 8),
                Row(children: [
                  Icon(Icons.star, color: Colors.amber, size: 16),
                  const SizedBox(width: 4),
                  Text(center!.rating.toStringAsFixed(1), style: secondaryTextStyle(size: 14)),
                ]),
              ],
              // Location
              if (center!.governorate != null) ...[
                const SizedBox(height: 8),
                Row(children: [
                  Icon(Icons.location_on_outlined, color: appColorSecondary, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    [center!.governorate?.name, center!.city?.name]
                        .where((e) => e != null && e.isNotEmpty)
                        .join(' - '),
                    style: secondaryTextStyle(size: 14),
                  ),
                ]),
              ],
              const SizedBox(height: 16),
              // About
              glassInfoCard(
                title: locale.value.about,
                child: Text(center!.description, style: primaryTextStyle(size: 14)),
              ),
              // Available Scans
              if (center!.scanTypes.isNotEmpty)
                glassInfoCard(
                  title: locale.value.availableScans,
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: center!.scanTypes.map((type) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: appColorPrimary.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        type.toUpperCase(),
                        style: boldTextStyle(size: 12, color: appColorPrimary),
                      ),
                    )).toList(),
                  ),
                ),
              // Operating Hours
              if (center!.operatingHours.isNotEmpty)
                glassInfoCard(
                  title: locale.value.operatingHours,
                  child: Text(center!.operatingHours, style: primaryTextStyle(size: 14)),
                ),
              // Pricing
              if (center!.pricing.isNotEmpty)
                glassInfoCard(
                  title: locale.value.pricing,
                  child: Text(center!.pricing, style: primaryTextStyle(size: 14)),
                ),
              // Contact
              glassInfoCard(
                title: locale.value.contactCenter,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (center!.contactNumber.isNotEmpty)
                      GestureDetector(
                        onTap: () => launchUrl(Uri.parse('tel:${center!.contactNumber}')),
                        child: Row(children: [
                          Icon(Icons.phone_outlined, color: appColorPrimary, size: 18),
                          const SizedBox(width: 8),
                          Text(center!.contactNumber, style: primaryTextStyle(size: 14, color: appColorPrimary)),
                        ]),
                      ),
                    if (center!.email.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () => launchUrl(Uri.parse('mailto:${center!.email}')),
                        child: Row(children: [
                          Icon(Icons.email_outlined, color: appColorPrimary, size: 18),
                          const SizedBox(width: 8),
                          Text(center!.email, style: primaryTextStyle(size: 14, color: appColorPrimary)),
                        ]),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      );
    }
  }
  ```

  **Note:** Before writing this screen, run `grep -n "get about\|get pricing" lib/locale/languages.dart` to verify `locale.value.about` and `locale.value.pricing` keys exist. If either is missing, add the abstract getter to `languages.dart` and implementations to all 5 language files before this step — missing locale keys cause compile errors.

- [ ] **Step 2: Verify and phase build check**

  ```bash
  flutter analyze lib/screens/radiology/
  flutter build apk --debug
  git add lib/screens/radiology/
  git commit -m "feat: add Radiology detail screen (Phase 5 complete)"
  ```

---

## Phase 6: Home Healthcare (Spec Phase 4 — New Full Module)

### Task 30: Home Healthcare Constants & Locale Strings

**Files:**
- Modify: `lib/utils/constants.dart`
- Modify: `lib/locale/languages.dart` + 5 language files

- [ ] **Step 1: Add status and service type constants to constants.dart**

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

- [ ] **Step 2: Add abstract keys to languages.dart**

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

  **Note:** Check if `operatingHours`, `serviceType`, `preferredDate`, `preferredTime` already exist in `languages.dart` from the radiology phase. Only add keys that don't exist yet.

- [ ] **Step 3: Add translations to all 5 language files**

  Add all translations from the spec (see spec.md Phase 4 locale section, lines 1735–1878) to each language file. Make sure not to duplicate any keys already added in Task 24.

- [ ] **Step 4: Verify and commit**

  ```bash
  flutter analyze lib/locale/ lib/utils/constants.dart
  git add lib/locale/ lib/utils/constants.dart
  git commit -m "feat: add HomeHealthcare constants and locale strings"
  ```

---

### Task 31: Home Healthcare Models

**Files:**
- Create: `lib/screens/home_healthcare/model/home_healthcare_model.dart`
- Create: `lib/screens/home_healthcare/model/home_healthcare_request_model.dart`

- [ ] **Step 1: Create `home_healthcare_model.dart`**

  Full code is in spec.md lines 775–921. Create the file with:
  - `HomeHealthcareListResponse` (paginated, uses `data.items` + `data.pagination`)
  - `HomeHealthcare` (all provider fields + nested `Governorate?`/`City?`)
  - `HomeHealthcareService` (id, name, description, price)

  Don't forget imports:
  ```dart
  import '../../../models/governorate_model.dart';
  import '../../../models/city_model.dart';
  ```

- [ ] **Step 2: Create `home_healthcare_request_model.dart`**

  Full code is in spec.md lines 927–1137. Create the file with:
  - `HomeHealthcareRequestListResponse`
  - `HomeHealthcareRequest` (all request fields including nested address/provider/patient)
  - `HomeHealthcareRequestAddress`
  - `HomeHealthcareRequestProvider`
  - `HomeHealthcareRequestPatient`

- [ ] **Step 3: Verify and commit**

  ```bash
  flutter analyze lib/screens/home_healthcare/model/
  git add lib/screens/home_healthcare/model/
  git commit -m "feat: add HomeHealthcare and HomeHealthcareRequest models"
  ```

---

### Task 32: Home Healthcare API Methods

**Files:**
- Modify: `lib/api/core_apis.dart`

- [ ] **Step 1: Add imports**

  ```dart
  import '../screens/home_healthcare/model/home_healthcare_model.dart';
  import '../screens/home_healthcare/model/home_healthcare_request_model.dart';
  ```

- [ ] **Step 2: Add 6 API methods**

  Full code in spec.md lines 1162–1265:
  - `getHomeHealthcareList()` — paginated search with filters
  - `getHomeHealthcareDetail()` — single provider
  - `getHomeHealthcareRequestList()` — paginated requests
  - `createHomeHealthcareRequest()` — POST request
  - `getHomeHealthcareRequestDetail()` — single request
  - `cancelHomeHealthcareRequest()` — POST to `/{id}/cancel`

- [ ] **Step 3: Verify and commit**

  ```bash
  flutter analyze lib/api/core_apis.dart
  git add lib/api/core_apis.dart
  git commit -m "feat: add Home Healthcare API methods (list, detail, requests CRUD)"
  ```

---

### Task 33: HomeHealthcareListController

**Files:**
- Create: `lib/screens/home_healthcare/home_healthcare_list_controller.dart`

- [ ] **Step 1: Create the controller**

  Full code in spec.md lines 1277–1364. Key aspects:
  - Mirrors `NurseListController` pattern exactly
  - Has `searchQuery`, `selectedGovernorateId`, `selectedCityId`, `selectedServiceType` reactive vars
  - `onGovernorateChanged`, `onCityChanged`, `onServiceTypeChanged` handlers
  - `debounce(searchQuery, ...)` for 500ms search delay
  - `onClose()` disposes `searchCont`
  - `serviceTypeFilters` uses `HomeHealthcareServiceTypeConst` keys and locale labels

- [ ] **Step 2: Verify and commit**

  ```bash
  flutter analyze lib/screens/home_healthcare/home_healthcare_list_controller.dart
  git add lib/screens/home_healthcare/home_healthcare_list_controller.dart
  git commit -m "feat: add HomeHealthcareListController"
  ```

---

### Task 34: Request Controllers

**Files:**
- Create: `lib/screens/home_healthcare/create_home_healthcare_request_controller.dart`
- Create: `lib/screens/home_healthcare/home_healthcare_request_list_controller.dart`

- [ ] **Step 1: Create `create_home_healthcare_request_controller.dart`**

  Full code in spec.md lines 1368–1430. Key aspects:
  - Has `formKey`, form field `TextEditingController`s (date, time, address, contactNumber, notes)
  - Reads `selectedProvider` from `Get.arguments` in `onInit()`
  - `submitRequest()` validates form and POSTs to API
  - `onClose()` disposes all 5 `TextEditingController`s

- [ ] **Step 2: Create `home_healthcare_request_list_controller.dart`**

  Full code in spec.md lines 1432–1487. Key aspects:
  - Mirrors `NurseRequestListController` pattern
  - Has `selectedStatus` filter with all 5 status options
  - No search, just status filter + pagination

- [ ] **Step 3: Verify and commit**

  ```bash
  flutter analyze lib/screens/home_healthcare/
  git add lib/screens/home_healthcare/create_home_healthcare_request_controller.dart
  git add lib/screens/home_healthcare/home_healthcare_request_list_controller.dart
  git commit -m "feat: add CreateHomeHealthcareRequest and HomeHealthcareRequestList controllers"
  ```

---

### Task 35: Home Healthcare List Screen & Card

**Files:**
- Create: `lib/screens/home_healthcare/components/home_healthcare_card.dart`
- Create: `lib/screens/home_healthcare/home_healthcare_list_screen.dart`

- [ ] **Step 1: Create `home_healthcare_card.dart`**

  UI structure from spec.md lines 1532–1558. Key elements:
  - `GestureDetector` → `Container` with `surfaceElevated`/`Dark` bg, 16px radius, `softShadowColor` shadow
  - `CachedImageWidget` (64x64, circular) + column with name (Outfit bold 16), service type, location pill, rating
  - Uses `locationBadge(card.governorate, card.city)` from shared component

- [ ] **Step 2: Create `home_healthcare_list_screen.dart`**

  UI structure from spec.md lines 1493–1529. Key elements:
  - `AppScaffoldNew` → `SnapHelperWidget` → `AnimatedScrollView`
  - Search bar + `GovernoratesCityPicker` + service type filter chips
  - `HomeHealthcareCard` items with navigation to detail screen
  - Empty state widget

- [ ] **Step 3: Verify and commit**

  ```bash
  flutter analyze lib/screens/home_healthcare/
  git add lib/screens/home_healthcare/components/home_healthcare_card.dart
  git add lib/screens/home_healthcare/home_healthcare_list_screen.dart
  git commit -m "feat: add HomeHealthcare list screen and card"
  ```

---

### Task 36: Home Healthcare Detail Screen

**Files:**
- Create: `lib/screens/home_healthcare/home_healthcare_detail_screen.dart`

- [ ] **Step 1: Create the detail screen**

  UI structure from spec.md lines 1562–1594. Key elements:
  - Hero image header (full width, 250px, gradient overlay)
  - Provider name + service type pill
  - Location section
  - `glassInfoCard` sections: About, Services Offered, Coverage Area, Operating Hours, Contact
  - Bottom CTA: "Request Service" gradient button → `CreateHomeHealthcareRequestScreen`

- [ ] **Step 2: Verify and commit**

  ```bash
  flutter analyze lib/screens/home_healthcare/home_healthcare_detail_screen.dart
  git add lib/screens/home_healthcare/home_healthcare_detail_screen.dart
  git commit -m "feat: add HomeHealthcare detail screen with service request CTA"
  ```

---

### Task 37: Create Home Healthcare Request Screen

**Files:**
- Create: `lib/screens/home_healthcare/create_home_healthcare_request_screen.dart`

- [ ] **Step 1: Create the screen**

  UI structure from spec.md lines 1598–1625. Key elements:
  - `AppScaffoldNew` → `Form(key: controller.formKey)` → `SingleChildScrollView`
  - Pre-selected provider mini-card (from `Get.arguments`)
  - Glass sections: Service Details (type dropdown + description), Schedule (date/time pickers), Location (address), Contact (phone), Notes (multiline)
  - Bottom CTA: "Submit Request" gradient button with loading state

- [ ] **Step 2: Verify and commit**

  ```bash
  flutter analyze lib/screens/home_healthcare/create_home_healthcare_request_screen.dart
  git add lib/screens/home_healthcare/create_home_healthcare_request_screen.dart
  git commit -m "feat: add CreateHomeHealthcareRequest screen"
  ```

---

### Task 38: Request List Screen & Card

**Files:**
- Create: `lib/screens/home_healthcare/components/home_healthcare_request_card.dart`
- Create: `lib/screens/home_healthcare/home_healthcare_request_list_screen.dart`

- [ ] **Step 1: Create `home_healthcare_request_card.dart`**

  Pattern mirrors `NurseRequestCard`. Key elements:
  - Glass-bordered card, 16px radius
  - Provider name + service type
  - Preferred date/time
  - Status badge with color coding (pending=orange, confirmed=teal, in_progress=blue, completed=green, cancelled=red)
  - Total amount if > 0
  - `onTap` navigates to detail screen

- [ ] **Step 2: Create `home_healthcare_request_list_screen.dart`**

  Pattern mirrors `NurseRequestListScreen`. Key elements:
  - `AppScaffoldNew` with gradient header
  - Status filter chips row
  - `AnimatedScrollView` with `HomeHealthcareRequestCard` items
  - Empty state when no requests

- [ ] **Step 3: Verify and commit**

  ```bash
  flutter analyze lib/screens/home_healthcare/
  git add lib/screens/home_healthcare/components/home_healthcare_request_card.dart
  git add lib/screens/home_healthcare/home_healthcare_request_list_screen.dart
  git commit -m "feat: add HomeHealthcareRequestList screen and card"
  ```

---

### Task 39: Request Detail Screen

**Files:**
- Create: `lib/screens/home_healthcare/home_healthcare_request_detail_screen.dart`

- [ ] **Step 1: Create the detail screen**

  Pattern mirrors `NurseRequestDetailScreen`. Key elements:
  - Status badge header with colored background matching status color
  - `glassInfoCard` sections: Provider info, Schedule (preferred date/time), Location (address), Contact, Patient Notes, Admin Notes, Payment info
  - Cancel button (visible only if status is `pending` or `confirmed`)
  - Confirmation dialog before cancel: shows AlertDialog, calls `CoreServiceApis.cancelHomeHealthcareRequest()`

- [ ] **Step 2: Verify and phase build check**

  ```bash
  flutter analyze lib/screens/home_healthcare/
  flutter build apk --debug
  git add lib/screens/home_healthcare/
  git commit -m "feat: add HomeHealthcare request detail screen with cancel (Phase 6 complete)"
  ```

---

## Phase 7: Cross-Cutting — Quick Services Grid

### Task 40: Add New Services to Quick Services Component

**Files:**
- Modify: `lib/screens/home/components/quick_services_component.dart`

- [ ] **Step 1: Add imports**

  ```dart
  import '../../home_healthcare/home_healthcare_list_screen.dart';
  import '../../radiology/radiology_list_screen.dart';
  ```

- [ ] **Step 2: Add Home Healthcare and Radiology service entries**

  Find the existing service list in `quick_services_component.dart`. The file already imports other screens (nurse, lab test, etc.) following the same pattern. Add two new entries to the services list:

  ```dart
  // Home Healthcare entry
  QuickServiceItem(
    icon: Icons.home_health_outlined,
    label: locale.value.browseHomeHealthcare,
    onTap: () => Get.to(() => const HomeHealthcareListScreen()),
    gradientColors: [appColorPrimary, appColorSecondary],
  ),
  // Radiology entry
  QuickServiceItem(
    icon: Icons.biotech_outlined,
    label: locale.value.browseRadiology,
    onTap: () => Get.to(() => const RadiologyListScreen()),
    gradientColors: [appColorPrimary, appColorAccent],
  ),
  ```

  **Note:** If `Icons.home_health_outlined` or `Icons.biotech_outlined` don't exist on the Flutter version in use, use `Icons.medical_services_outlined` and `Icons.blur_circular_outlined` as fallbacks. Also confirm what type `QuickServiceItem` expects by reading the existing service items in the file first.

- [ ] **Step 3: Verify**

  ```bash
  flutter analyze lib/screens/home/components/quick_services_component.dart
  ```
  Expected: No issues.

- [ ] **Step 4: Commit**

  ```bash
  git add lib/screens/home/components/quick_services_component.dart
  git commit -m "feat: add Home Healthcare and Radiology to quick services grid"
  ```

---

### Task 41: Final Analysis & Build Check

- [ ] **Step 1: Run full analysis**

  ```bash
  flutter analyze
  ```
  Expected: No errors. Fix any issues before proceeding.

- [ ] **Step 2: Run debug build**

  ```bash
  flutter build apk --debug
  ```
  Expected: BUILD SUCCESSFUL. Fix any compilation errors before proceeding.

- [ ] **Step 3: Final commit**

  ```bash
  git add -A
  git commit -m "feat: Vizita Platform — location search, home healthcare, radiology (6-phase complete)"
  ```

---

## Common Pitfalls & Notes

### Import Non-Transitivity
Every file that uses `Governorate` or `City` types must import them directly:
```dart
import '../../../models/governorate_model.dart';
import '../../../models/city_model.dart';
```
This applies to models, cards, and any widget that accesses `nurse.governorate`, `labTest.city`, etc.

### Dual Pagination Formats
The new backend search endpoints return: `{ data: { items: [...], pagination: { current_page, last_page, per_page, total } } }`

The existing endpoints use different formats. When updating existing response classes (NurseListResponse, DoctorListResponse, ClinicListResponse, LabTestListResponse), handle both formats defensively as shown in Task 9.

### GoogleFonts Usage
```dart
// CORRECT:
style: boldTextStyle(size: 16, fontFamily: GoogleFonts.outfit().fontFamily)
// WRONG:
style: GoogleFonts.outfit().textStyle  // .textStyle does not exist
```

### RxnInt for Nullable Int Filters
Use `RxnInt()` (not `RxInt(-1).obs`) for optional filter IDs. `RxnInt().value` is `null` when unset, making null checks clean:
```dart
if (governorateId != null) params.add('governorate_id=$governorateId');
```

### Controller Disposal
All new controllers with `TextEditingController` must override `onClose()`:
```dart
@override
void onClose() {
  searchCont.dispose();
  super.onClose();
}
```

### Existing Doctor/Clinic Models
The `Doctor` and `Clinic` classes already have `cityId`/`cityName` fields from the old location system. The new `Governorate?`/`City?` fields are ADDITIONS — name them `governorate`/`governorateCity` to avoid field name collisions with the existing `cityId` int field.
