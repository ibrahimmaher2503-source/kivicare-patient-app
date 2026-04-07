# Tasks: Location & Search

**Input**: Design documents from `/specs/008-location-search/`
**Prerequisites**: plan.md (required), spec.md (required), research.md, data-model.md, contracts/

**Tests**: Not requested — test tasks omitted.

**Organization**: Tasks grouped by user story. US2 (Browse Governorates/Cities) is already implemented via `GovernoratesCityPicker` and is merged into Foundational.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)
- Include exact file paths in descriptions

---

## Phase 1: Setup

**Purpose**: Create directory structure for the search module

- [x] T001 Create directory structure: `lib/screens/search/` and `lib/screens/search/components/`

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Locale strings, shared components, and search hub that ALL user stories depend on. US2 (Governorate/City browsing) is already implemented — `GovernoratesCityPicker` exists at `lib/components/governorates_city_picker.dart` with session caching, cascading dropdowns, and dark mode support. `getGovernorates()` and `getCities()` API methods exist in `lib/api/core_apis.dart`.

- [x] T002 [P] Add search locale string keys to abstract class in `lib/locale/languages.dart` — add ~20 new getters: `searchProviders`, `searchDoctors`, `searchClinics`, `searchNurses`, `searchLabs`, `searchRadiology`, `searchHomeHealthcare`, `specialty`, `scanType`, `serviceType`, `minPrice`, `maxPrice`, `noSearchResults`, `broadenFilters`, `homeHealthcare`, `radiologyCenter`, `allSpecialties`, `priceRange`, `filterByGender`, `filterByAvailability`
- [x] T003 [P] Add English search locale strings in `lib/locale/language_en.dart` — implement all getters added in T002
- [x] T004 [P] Add Arabic search locale strings in `lib/locale/language_ar.dart` — implement all getters added in T002
- [x] T005 [P] Add German search locale strings in `lib/locale/language_de.dart` — implement all getters added in T002
- [x] T006 [P] Add French search locale strings in `lib/locale/language_fr.dart` — implement all getters added in T002
- [x] T007 [P] Add Hindi search locale strings in `lib/locale/language_hi.dart` — implement all getters added in T002
- [x] T008 [P] Create reusable search filter chips component in `lib/screens/search/components/search_filter_chips.dart` — accepts list of `{key, label}` maps, selected key, onChanged callback; uses `AnimatedContainer` with gradient for selected state; follows nurse list filter chip pattern from `nurse_list_screen.dart`
- [x] T009 Create search hub screen in `lib/screens/search/search_hub_screen.dart` — grid/list of 6 provider type cards (Doctors, Clinics, Nurses, Labs, Radiology, Home Healthcare), each card navigates to its search screen via `Get.to()`; uses `AppScaffoldNew` with `locale.value.searchProviders` title; follows quick_services_component card style with gradient decorations

**Checkpoint**: Foundation ready — locale strings and shared components available for all user stories

---

## Phase 3: User Story 1 + User Story 2 - Doctor Search with Location (Priority: P1) MVP

**Goal**: Patients can search for doctors by governorate/city with filters for specialty, name, gender, and price range. Paginated results show doctor details. Location browsing (US2) is already implemented via `GovernoratesCityPicker`.

**Independent Test**: Open app → navigate to Search Hub → tap Doctors → select governorate Cairo → city Nasr City → apply specialty filter → verify matching doctors appear with pagination, empty state on no results.

### Implementation

- [x] T010 [US1] Extend `searchDoctors()` method in `lib/api/core_apis.dart` — add optional params: `int? specialtyId`, `String gender = ''`, `double? minPrice`, `double? maxPrice`; append corresponding query params (`&specialty_id=`, `&gender=`, `&min_price=`, `&max_price=`) when non-null/non-empty; keep existing `name`, `governorateId`, `cityId` params unchanged
- [x] T011 [US1] Create doctor search controller in `lib/screens/search/doctor_search_controller.dart` — follow nurse_list_controller pattern: `Rx<Future<RxList<Doctor>>> doctorsFuture`, `RxList<Doctor> doctors`, `RxBool isLoading/isLastPage`, `RxInt page`, `TextEditingController searchCont`, `RxString searchQuery` with 500ms debounce, `RxnInt selectedGovernorateId/selectedCityId/selectedSpecialtyId`, `RxString selectedGender`, `Rxn<double> minPrice/maxPrice`; `getDoctors()` calls `CoreServiceApis.searchDoctors()` with all filters; `onGovernorateChanged`, `onCityChanged`, `onSearchChanged`, `onGenderChanged`, `onSpecialtyChanged`, `onPriceChanged` methods that reset page to 1 and reload
- [x] T012 [US1] Create doctor search screen in `lib/screens/search/doctor_search_screen.dart` — `StatefulWidget` with `Get.put(DoctorSearchController())` in initState, `Get.delete` in dispose; `AppScaffoldNew` with search bar, `GovernoratesCityPicker`, specialty filter chips, gender filter chips (All/Male/Female), price range inputs, `SnapHelperWidget` wrapping `AnimatedScrollView` with doctor result cards showing name, specialty, experience, price, profile image, governorate/city; pagination via `onNextPage`/`onSwipeRefresh`; empty state when no results; handle null specialty/price gracefully
- [x] T013 [US1] Add Search/Discover entry point to home screen in `lib/screens/home/components/quick_services_component.dart` — add a new service card for "Search Providers" that navigates to `SearchHubScreen()` via `Get.to()`; no `doIfLoggedIn()` wrapper needed (public feature)

**Checkpoint**: MVP complete — Doctor search with full location + filter support is functional and testable

---

## Phase 4: User Story 3 - Clinic Search (Priority: P2)

**Goal**: Patients can search for clinics by location with name and specialty filters. Paginated results show clinic name, image, and location.

**Independent Test**: Navigate to Search Hub → tap Clinics → select location → type partial clinic name → verify matching clinics appear with pagination.

### Implementation

- [x] T014 [US3] Extend `searchClinics()` method in `lib/api/core_apis.dart` — add optional param: `int? specialtyId`; append `&specialty_id=$specialtyId` when non-null; keep existing `name`, `governorateId`, `cityId` params unchanged
- [x] T015 [US3] Create clinic search controller in `lib/screens/search/clinic_search_controller.dart` — same pattern as doctor controller but simpler: `Rx<Future<RxList<Clinic>>>`, search + governorate/city + specialty filters; calls `CoreServiceApis.searchClinics()` with all params
- [x] T016 [US3] Create clinic search screen in `lib/screens/search/clinic_search_screen.dart` — `AppScaffoldNew` with search bar, `GovernoratesCityPicker`, specialty filter chips, clinic result cards showing name, profile image, governorate/city; pagination; empty/error states

**Checkpoint**: Clinic search functional alongside Doctor search

---

## Phase 5: User Story 4 - Nurse Search (Priority: P2)

**Goal**: Patients can search for nurses by location with specialization, gender, and availability filters. Results show nurse details including hourly rate and availability status.

**Independent Test**: Navigate to Search Hub → tap Nurses → select location → filter by availability "available" → verify matching nurses appear with correct details.

### Implementation

- [x] T017 [US4] Create nurse search controller in `lib/screens/search/nurse_search_controller.dart` — `searchNurses()` API method already complete; controller has: search + governorate/city + specialty (partial match) + gender + availability filters; availability options: `[{'key': '', 'label': all}, {'key': 'available', ...}, {'key': 'busy', ...}, {'key': 'off_duty', ...}]`; calls `CoreServiceApis.searchNurses()` with all params
- [x] T018 [US4] Create nurse search screen in `lib/screens/search/nurse_search_screen.dart` — `AppScaffoldNew` with search bar, `GovernoratesCityPicker`, availability filter chips (using `SearchFilterChips` from T008), gender filter chips, nurse result cards showing name, specialization, gender, availability badge (color-coded), hourly rate, profile image (default avatar if null), governorate/city; pagination; empty/error states

**Checkpoint**: Nurse search functional alongside Doctor and Clinic search

---

## Phase 6: User Story 5 - Lab Search (Priority: P3)

**Goal**: Patients can search for labs by location and name. Results show lab name and location.

**Independent Test**: Navigate to Search Hub → tap Labs → select location → search by name → verify matching labs appear.

### Implementation

- [x] T019 [P] [US5] Create lab search controller in `lib/screens/search/lab_search_controller.dart` — `searchLabs()` API method already complete; controller has: search (test_name param) + governorate/city filters; calls `CoreServiceApis.searchLabs()` with `testName`, `governorateId`, `cityId`
- [x] T020 [US5] Create lab search screen in `lib/screens/search/lab_search_screen.dart` — `AppScaffoldNew` with search bar, `GovernoratesCityPicker`, lab result cards showing name and governorate/city; pagination; empty/error states

**Checkpoint**: Lab search functional

---

## Phase 7: User Story 6 - Radiology Center Search (Priority: P3)

**Goal**: Patients can search for radiology centers by location and scan type (exact match). Results show center name, scan type, and location.

**Independent Test**: Navigate to Search Hub → tap Radiology → select location → select scan type "MRI" → verify only MRI centers in that area appear.

### Implementation

- [x] T021 [US6] Add `searchRadiology()` method to `lib/api/core_apis.dart` — new static method with params: `page`, `perPage` (default 15), `required List<RadiologyCenter> centerList`, `Function(bool)? lastPageCallBack`, `int? governorateId`, `int? cityId`, `String scanType = ''`; builds query string with `&scan_type=` (exact match); calls `buildHttpResponse('${APIEndPoints.radiologySearch}?...')` → `RadiologyCenterListResponse.fromJson()`; follows exact pattern of `searchLabs()`
- [x] T022 [US6] Create radiology search controller in `lib/screens/search/radiology_search_controller.dart` — controller has: governorate/city + scan type filter (exact match, not debounced); scan type options as filter chips: `['', 'MRI', 'CT', 'X-ray', 'Ultrasound']`; calls `CoreServiceApis.searchRadiology()` with `scanType`, `governorateId`, `cityId`
- [x] T023 [US6] Create radiology search screen in `lib/screens/search/radiology_search_screen.dart` — `AppScaffoldNew` with `GovernoratesCityPicker`, scan type filter chips (using `SearchFilterChips`), radiology center result cards showing name, scan types, governorate/city; pagination; empty/error states

**Checkpoint**: Radiology search functional

---

## Phase 8: User Story 7 - Home Healthcare Search (Priority: P3)

**Goal**: Patients can search for home healthcare providers by location and service type (exact match). Results show provider name, service type, and location.

**Independent Test**: Navigate to Search Hub → tap Home Healthcare → select location → select service type "physiotherapy" → verify matching providers appear.

### Implementation

- [x] T024 [P] [US7] Create `HomeHealthcareProvider` model and `HomeHealthcareListResponse` in `lib/models/home_healthcare_provider_model.dart` — follow exact pattern from `RadiologyCenterListResponse` / `RadiologyCenter` in `lib/screens/radiology/model/radiology_center_model.dart`; fields: `id` (int), `name` (String), `serviceType` (String), `profileImage` (String), `governorate` (Governorate?), `city` (City?), `createdAt` (String), `updatedAt` (String); type-safe `fromJson()` with nested governorate/city parsing; `HomeHealthcareListResponse` with flexible pagination parsing (data.items+data.pagination OR data[]+meta{})
- [x] T025 [US7] Add `searchHomeHealthcare()` method to `lib/api/core_apis.dart` — new static method with params: `page`, `perPage` (default 15), `required List<HomeHealthcareProvider> providerList`, `Function(bool)? lastPageCallBack`, `int? governorateId`, `int? cityId`, `String serviceType = ''`; builds query string with `&service_type=` (exact match); calls `buildHttpResponse('${APIEndPoints.homeHealthcareSearch}?...')` → `HomeHealthcareListResponse.fromJson()`; follows exact pattern of `searchRadiology()` from T021
- [x] T026 [US7] Create home healthcare search controller in `lib/screens/search/home_healthcare_search_controller.dart` — controller has: governorate/city + service type filter (exact match); service type options as filter chips: `['', 'physiotherapy', 'elderly_care', 'post_surgery', 'chronic_care']`; calls `CoreServiceApis.searchHomeHealthcare()` with `serviceType`, `governorateId`, `cityId`
- [x] T027 [US7] Create home healthcare search screen in `lib/screens/search/home_healthcare_search_screen.dart` — `AppScaffoldNew` with `GovernoratesCityPicker`, service type filter chips (using `SearchFilterChips`), provider result cards showing name, service type, profile image (default if null), governorate/city; pagination; empty/error states

**Checkpoint**: All 6 search types functional

---

## Phase 9: Polish & Cross-Cutting Concerns

**Purpose**: Final validation and cleanup

- [x] T028 Verify search hub screen links to all 6 search screens and each returns results correctly in `lib/screens/search/search_hub_screen.dart`
- [x] T029 Run `flutter analyze` and fix any new warnings introduced by this feature
- [ ] T030 Verify Arabic locale — test that governorate/city names, filter labels, and UI strings display in Arabic when language is set to Arabic
- [ ] T031 Verify empty states display correctly across all 6 search screens when filters return zero results
- [ ] T032 Verify pagination works for all 6 search types — load more results, no duplicates, stops at last page

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies — start immediately
- **Foundational (Phase 2)**: Depends on Phase 1 (directory exists)
- **US1+US2 (Phase 3)**: Depends on Phase 2 (locale strings, shared components)
- **US3 (Phase 4)**: Depends on Phase 2 only — can run parallel with Phase 3
- **US4 (Phase 5)**: Depends on Phase 2 only — can run parallel with Phase 3/4
- **US5 (Phase 6)**: Depends on Phase 2 only — can run parallel with Phase 3/4/5
- **US6 (Phase 7)**: Depends on Phase 2 only — can run parallel with others
- **US7 (Phase 8)**: Depends on Phase 2 only — can run parallel with others
- **Polish (Phase 9)**: Depends on all user story phases complete

### User Story Dependencies

- **US1+US2 (P1)**: After Foundational — no inter-story dependencies. Includes home screen integration (T013).
- **US3 (P2)**: After Foundational — independent of US1
- **US4 (P2)**: After Foundational — independent of US1/US3
- **US5 (P3)**: After Foundational — independent
- **US6 (P3)**: After Foundational — independent
- **US7 (P3)**: After Foundational — independent

### Within Each User Story

- API method changes/additions first (data layer)
- Controller second (business logic)
- Screen last (UI layer)
- Integration (home screen link) only in US1

### Parallel Opportunities

**Phase 2 (all [P] tasks):**
```
T002, T003, T004, T005, T006, T007, T008 — all modify different files, run in parallel
```

**After Phase 2 completes — all stories can start in parallel:**
```
Agent 1: Phase 3 (US1 - Doctor Search)     — T010 → T011 → T012 → T013
Agent 2: Phase 4 (US3 - Clinic Search)     — T014 → T015 → T016
Agent 3: Phase 5 (US4 - Nurse Search)      — T017 → T018
Agent 4: Phase 6 (US5 - Lab Search)        — T019 → T020
Agent 5: Phase 7 (US6 - Radiology Search)  — T021 → T022 → T023
Agent 6: Phase 8 (US7 - Home Healthcare)   — T024 → T025 → T026 → T027
```

**Within US7:**
```
T024 [P] (model) can run parallel with T025 (API method) since they're different files
— but T025 imports the model, so T024 should complete first
```

---

## Parallel Example: Phase 2 (Foundational)

```
# Launch all locale tasks in parallel (different files):
Task T002: "Add locale keys to lib/locale/languages.dart"
Task T003: "Add English strings to lib/locale/language_en.dart"
Task T004: "Add Arabic strings to lib/locale/language_ar.dart"
Task T005: "Add German strings to lib/locale/language_de.dart"
Task T006: "Add French strings to lib/locale/language_fr.dart"
Task T007: "Add Hindi strings to lib/locale/language_hi.dart"
Task T008: "Create filter chips component in lib/screens/search/components/search_filter_chips.dart"
```

## Parallel Example: All User Stories (after Foundational)

```
# Launch all user stories in parallel (completely independent directories/files):
Story US1: T010 → T011 → T012 → T013 (Doctor Search + Home integration)
Story US3: T014 → T015 → T016 (Clinic Search)
Story US4: T017 → T018 (Nurse Search)
Story US5: T019 → T020 (Lab Search)
Story US6: T021 → T022 → T023 (Radiology Search)
Story US7: T024 → T025 → T026 → T027 (Home Healthcare Search)
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup (T001)
2. Complete Phase 2: Foundational (T002–T009)
3. Complete Phase 3: US1 Doctor Search (T010–T013)
4. **STOP and VALIDATE**: Open app → Search Hub → Doctor Search → test all filters + pagination
5. Deploy/demo if ready

### Incremental Delivery

1. Setup + Foundational → Foundation ready
2. US1 Doctor Search → Test → Demo (MVP!)
3. US3 Clinic Search + US4 Nurse Search → Test → Demo (P2 complete)
4. US5 Lab + US6 Radiology + US7 Home Healthcare → Test → Demo (P3 complete)
5. Polish → Final validation → Ship

### Parallel Agent Strategy

1. Complete Setup + Foundational sequentially
2. Once Foundational done, dispatch 6 parallel agents (one per story)
3. All stories complete independently
4. Run Polish phase to validate cross-cutting concerns

---

## Notes

- US2 (Browse Governorates/Cities) is already implemented — `GovernoratesCityPicker` at `lib/components/governorates_city_picker.dart` with `getGovernorates()` and `getCities()` in `core_apis.dart`
- All search endpoints are **public** (no auth token needed) — `buildHttpResponse()` works as-is
- Base URL is `BASE_URL` = `https://espitalia.net/api/` — search endpoints use no `v1/` prefix
- All 8 API endpoint constants already exist in `lib/utils/api_end_points.dart:82-101`
- `searchNurses()` and `searchLabs()` are already complete — no API changes needed for US4/US5
- Only `searchDoctors()` and `searchClinics()` need param extensions; `searchRadiology()` and `searchHomeHealthcare()` are new
- Only 1 new model needed: `HomeHealthcareProvider` — all others exist
- Avoid modifying `lib/network/network_utils.dart` — use existing patterns as-is
