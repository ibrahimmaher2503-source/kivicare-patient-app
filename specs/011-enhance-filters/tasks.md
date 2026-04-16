# Tasks: Enhance Filter Screens & Controllers

**Input**: Design documents from `/specs/011-enhance-filters/`
**Prerequisites**: plan.md (required), spec.md (required), research.md, data-model.md, quickstart.md

**Tests**: Not explicitly requested — test tasks omitted.

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)
- Include exact file paths in descriptions

## Path Conventions

- **Flutter mobile app**: `lib/` at repository root
- All paths relative to `C:\Users\berog\StudioProjects\kivicare-laravel-patient-flutter-app-v1.8.1\`

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Create the FilterParams typed model class that replaces the fragile positional `Get.arguments` List [0..5] pattern. This is the foundation all other phases depend on.

- [x] T001 Create FilterParams model class with all named fields (clinicId, serviceType, priceMin, priceMax, moduleType, categoryId, governorateId, cityId, specialtyId, gender, ratingMin, ratingMax) per data-model.md entity definition in `lib/screens/booking/filter/model/filter_params.dart`

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Refactor FilterController to use FilterParams, consolidate the 9 counter variables into a single computed getter, create the shared badge widget, and update all list screens to use the new argument passing pattern.

**⚠️ CRITICAL**: No user story work can begin until this phase is complete

- [x] T002 Refactor FilterController.onInit() to read from FilterParams (via `Get.arguments as FilterParams`) instead of positional List indices [0..5], preserving all existing initialization logic in `lib/screens/booking/filter/filter_controller.dart`
- [x] T003 Replace the 9 counter variables (seleFilterCount, seleClinicFilterCount, selePriceFilterCount, seleRatingFilterCount, seleCategoryFilterCount, totalDoctorCount, totalServiceCount, totalCategoryCount, and their actual* variants) with a single `int get activeFilterCount` computed getter that checks each filter parameter against its default value per data-model.md ActiveFilterCount table in `lib/screens/booking/filter/filter_controller.dart`
- [x] T004 Update applyFilter() to return `activeFilterCount` consistently as int for all module types (doctor currently returns a Map, service and clinic return int) — standardize to always `Get.back(result: activeFilterCount)` in `lib/screens/booking/filter/filter_controller.dart`
- [x] T005 Update resetFilter() to clear all filter variables including new ones (governorateId, cityId, specialtyId, gender) and ensure activeFilterCount returns 0 after reset in `lib/screens/booking/filter/filter_controller.dart`
- [x] T006 Create FilterCountBadge shared widget — small gradient circle (gradientSecondaryStart/End) with count text, shown only when count > 0, using Positioned overlay pattern in `lib/components/filter_count_badge.dart`
- [x] T007 Update FilterScreen to read FilterParams from Get.arguments instead of passing displayName/filterType as constructor params, and use FilterParams.moduleType to determine which filter type list and widget to show in `lib/screens/booking/filter/filter_screen.dart`
- [x] T008 [P] Update doctor_list_screen.dart to construct and pass FilterParams via Get.arguments when opening FilterScreen, and use FilterCountBadge for the filter icon badge (replacing inline Positioned/Container badge) in `lib/screens/home/components/doctor_list_screen.dart`
- [x] T009 [P] Update clinic_list_screen.dart to construct and pass FilterParams via Get.arguments when opening FilterScreen, and use FilterCountBadge for the filter icon badge in `lib/screens/home/components/clinic_list_screen.dart`
- [x] T010 [P] Update popular_service_list.dart to construct and pass FilterParams via Get.arguments when opening FilterScreen, and use FilterCountBadge for the filter icon badge in `lib/screens/home/components/popular_service_list.dart`
- [x] T011 [P] Update services_list_screen.dart to construct and pass FilterParams via Get.arguments when opening FilterScreen, and use FilterCountBadge for the filter icon badge in `lib/screens/service/services_list_screen.dart`

**Checkpoint**: FilterParams refactor complete. All 4 list screens open FilterScreen with typed params and show unified badge. Filter count is accurate from a single computed getter. Existing filter behavior preserved.

---

## Phase 3: User Story 1 — Unified Location Filtering Across All Modules (Priority: P1) 🎯 MVP

**Goal**: Add governorate/city filtering to the booking filter modal so patients can narrow provider lists by location, matching the capability already available in dedicated search screens.

**Independent Test**: Open Doctor list → tap filter icon → select Location → pick a governorate → pick a city → Apply → verify only doctors from that city appear. Reset → all doctors return. Repeat for Clinic and Service lists.

### Implementation for User Story 1

- [x] T012 [P] [US1] Add `filterLocation` locale key to BaseLanguage abstract class in `lib/locale/languages.dart`, English value "Location" in `lib/locale/language_en.dart`, Arabic value "الموقع" in `lib/locale/language_ar.dart`
- [x] T013 [P] [US1] Create FilterLocationComponent that wraps GovernoratesCityPicker with filter modal styling (surfaceElevated background, glass border, 16px radius), reading selectedGovernorateId/cityId from FilterController and calling onGovernorateChanged/onCityChanged methods in `lib/screens/booking/filter/components/filter_location_component.dart`
- [x] T014 [US1] Add `RxnInt selectedGovernorateId = RxnInt()` and `RxnInt selectedCityId = RxnInt()` reactive vars to FilterController, initialize from FilterParams in onInit() in `lib/screens/booking/filter/filter_controller.dart`
- [x] T015 [US1] Add `locale.value.filterLocation` (or location key) to all four filter type lists (filterList, serviceFilterList, clinicFilterList, categoryFilterList) in FilterController so Location appears as a filter option for all modules in `lib/screens/booking/filter/filter_controller.dart`
- [x] T016 [US1] Update viewFilterWidget() switch statement to render FilterLocationComponent for the Location case in `lib/screens/booking/filter/filter_controller.dart`
- [x] T017 [US1] Add onGovernorateChanged(int? id) and onCityChanged(int? id) methods to FilterController that update the reactive vars and reset city when governorate changes in `lib/screens/booking/filter/filter_controller.dart`
- [x] T018 [US1] Update applyFilter('doctor') to set DoctorListController.selectedGovernorateId and selectedCityId from FilterController values in `lib/screens/booking/filter/filter_controller.dart`
- [x] T019 [US1] Update applyFilter('clinic') to set ClinicListController.selectedGovernorateId and selectedCityId from FilterController values in `lib/screens/booking/filter/filter_controller.dart`
- [x] T020 [US1] Update applyFilter('service') — add selectedGovernorateId/selectedCityId vars to ServiceListController if missing, and set them from FilterController values in `lib/screens/booking/filter/filter_controller.dart` and `lib/screens/service/service_list_controller.dart`
- [x] T021 [US1] Update FilterParams construction in all 4 list screens to pass current governorateId/cityId values from their respective list controllers back to FilterScreen when reopening in `lib/screens/home/components/doctor_list_screen.dart`, `lib/screens/home/components/clinic_list_screen.dart`, `lib/screens/home/components/popular_service_list.dart`, `lib/screens/service/services_list_screen.dart`

**Checkpoint**: Location filtering works in the filter modal for all modules. Patients can filter by governorate/city, reset clears location, and badge count includes location. This is the MVP.

---

## Phase 4: User Story 2 — Consistent Filter UI Across Booking Filter Modal and Search Screens (Priority: P2)

**Goal**: Align all 8 filter components with the Clinical Elegance design system so the filter modal matches the visual quality of the search screens (gradient accents, glass borders, navy-tinted shadows, 16px card radius).

**Independent Test**: Open filter modal → visually verify all components use consistent shadow/depth treatment, gradient accents on selection, glass-style borders. Compare with search screen filter chips — should match styling.

### Implementation for User Story 2

- [x] T022 [P] [US2] Update type_list_component.dart — add BoxShadow with `appColorSecondary.withValues(alpha: 0.15)` and gradient accent on selected item, use surfaceElevated background, apply 200ms AnimatedContainer transition in `lib/screens/booking/filter/components/type_list_component.dart`
- [x] T023 [P] [US2] Update filter_category.dart — add BoxShadow on selected chips following the pattern from filter_clinic_component.dart (blurRadius: 8, offset: Offset(0,2)), ensure 16px border radius in `lib/screens/booking/filter/components/filter_category.dart`
- [x] T024 [P] [US2] Update filter_service.dart — add BoxShadow on selected chips matching filter_category.dart pattern in `lib/screens/booking/filter/components/filter_service.dart`
- [x] T025 [P] [US2] Update filter_service_type_component.dart — add BoxShadow on selected chips and ensure gradient accent matches SearchFilterChips styling in `lib/screens/booking/filter/components/service_type_filter/filter_service_type_component.dart`
- [x] T026 [P] [US2] Update filter_clinic_component.dart — replace hardcoded `Colors.green.shade600` status badge color with appropriate design token (appColorSecondary or a semantic color) in `lib/screens/booking/filter/components/clinic_filter/filter_clinic_component.dart`
- [x] T027 [P] [US2] Update filter_search_clinic_component.dart — add inputFocusGlow border color on focus state for the search text field in `lib/screens/booking/filter/components/clinic_filter/filter_search_clinic_component.dart`
- [x] T028 [P] [US2] Update filter_price_component.dart — add softShadowColor BoxShadow to the price display container for visual depth in `lib/screens/booking/filter/components/price_filter/filter_price_component.dart`
- [x] T029 [P] [US2] Update rating_filter.dart — add softShadowColor BoxShadow to the rating display container for visual depth in `lib/screens/booking/filter/components/rating_filter.dart`

**Checkpoint**: All filter components share consistent design tokens. The filter modal visually matches the search screens' Clinical Elegance design.

---

## Phase 5: User Story 3 — Active Filter Count and Indicator Badges (Priority: P2)

**Goal**: Add per-category active indicators to the filter type sidebar so patients can see which filter categories have active selections at a glance. (Note: count consolidation and badge widget were created in Phase 2 Foundational; this phase adds the in-modal visual indicators.)

**Independent Test**: Open filter modal → apply a clinic filter → verify the "Clinic" item in the sidebar shows an active indicator (dot/checkmark). Apply a price filter → verify "Price" also shows active. Reset → all indicators clear.

### Implementation for User Story 3

- [x] T030 [US3] Add per-filter-type active status getters to FilterController (e.g., `bool get hasActiveLocationFilter => selectedGovernorateId.value != null`, `bool get hasActiveClinicFilter => selectedClinicData.value.id > 0`, etc.) — one getter per filter type in `lib/screens/booking/filter/filter_controller.dart`
- [x] T031 [US3] Update type_list_component.dart to show a small gradient dot or checkmark indicator next to filter type labels that have active selections, reading from FilterController's per-type active getters in `lib/screens/booking/filter/components/type_list_component.dart`

**Checkpoint**: Patients can see at a glance which filter categories have active values in the sidebar. Combined with Phase 2's badge widget, all US3 acceptance scenarios are met.

---

## Phase 6: User Story 4 — Module-Specific Advanced Filters (Priority: P3)

**Goal**: Add specialty and gender filter types to the filter modal, visible only when the doctor module is active, so patients can find the right doctor faster.

**Independent Test**: Open filter from Doctor list → verify Specialty and Gender types appear in sidebar. Select a specialty → Apply → verify filtered results. Open filter from Service list → verify Specialty and Gender do NOT appear.

### Implementation for User Story 4

- [x] T032 [P] [US4] Create FilterSpecialtyComponent — display list of specialties as selectable chips (using specialties from API or IcuSpecialtyConst constants), with selected state using gradient accent and shadow, reading/writing selectedSpecialtyId on FilterController in `lib/screens/booking/filter/components/filter_specialty_component.dart`
- [x] T033 [P] [US4] Create FilterGenderComponent — display 3 selectable chips (Male/Female/Other) using the `genders` reactive list from constants.dart, with selected state using gradient accent and shadow, reading/writing selectedGender on FilterController in `lib/screens/booking/filter/components/filter_gender_component.dart`
- [x] T034 [US4] Add `RxnInt selectedSpecialtyId = RxnInt()` and `RxString selectedGender = ''.obs` reactive vars to FilterController, initialize from FilterParams in onInit() in `lib/screens/booking/filter/filter_controller.dart`
- [x] T035 [US4] Add `locale.value.specialty` and `locale.value.gender` to `filterList` only (the doctor module filter type list) in FilterController — do NOT add to serviceFilterList, clinicFilterList, or categoryFilterList in `lib/screens/booking/filter/filter_controller.dart`
- [x] T036 [US4] Update viewFilterWidget() switch to render FilterSpecialtyComponent for Specialty case and FilterGenderComponent for Gender case in `lib/screens/booking/filter/filter_controller.dart`
- [x] T037 [US4] Update applyFilter('doctor') to set DoctorListController.selectedSpecialtyId and selectedGender from FilterController values in `lib/screens/booking/filter/filter_controller.dart`
- [x] T038 [US4] Add `RxnInt selectedSpecialtyId = RxnInt()` and `RxString selectedGender = ''.obs` to DoctorListController, pass both to CoreServiceApis.searchDoctors() in getDoctors() in `lib/screens/doctor/doctor_list_controller.dart`
- [x] T039 [US4] Update FilterParams construction in doctor_list_screen.dart to include specialtyId and gender from DoctorListController when reopening FilterScreen in `lib/screens/home/components/doctor_list_screen.dart`

**Checkpoint**: Doctor filter modal shows Specialty and Gender options. Service/Clinic modals do not. Specialty and gender filter results correctly via the existing searchDoctors API.

---

## Phase 7: User Story 5 — Localized and Accessible Filter Labels (Priority: P3)

**Goal**: Fix hardcoded English strings in filter components and ensure all new filter labels use the locale system for proper Arabic/RTL support.

**Independent Test**: Switch app to Arabic → open filter modal → verify all labels (including "In Clinic"/"Online", "Rating", "Location", "Specialty", "Gender") display in Arabic. Verify RTL layout is correct.

### Implementation for User Story 5

- [x] T040 [P] [US5] Replace hardcoded `"In Clinic"` and `"Online"` with `locale.value.inClinic` and `locale.value.online` in serviceTypeList definition at lines 79-80 of `lib/screens/booking/filter/filter_controller.dart`
- [x] T041 [P] [US5] Replace hardcoded `"Rating"` with `locale.value.filterRating` at line 23 of `lib/screens/booking/filter/components/rating_filter.dart`
- [x] T042 [US5] Verify all new filter components (FilterLocationComponent, FilterSpecialtyComponent, FilterGenderComponent) use `locale.value.<key>` for all user-facing labels and do not contain any hardcoded strings — audit and fix in `lib/screens/booking/filter/components/filter_location_component.dart`, `lib/screens/booking/filter/components/filter_specialty_component.dart`, `lib/screens/booking/filter/components/filter_gender_component.dart`

**Checkpoint**: All filter labels render correctly in both English and Arabic. No hardcoded English strings remain in filter components.

---

## Phase 8: Polish & Cross-Cutting Concerns

**Purpose**: Final validation, static analysis, and RTL verification across all stories

- [x] T043 Run `flutter analyze` and fix any new warnings introduced by filter changes
- [x] T044 Verify Arabic RTL layout in filter modal — check sidebar direction, dropdown alignment, chip flow direction, button placement
- [x] T045 Verify empty state displays correctly when filters return zero results — ensure the message suggests adjusting or clearing filters
- [x] T046 Run quickstart.md validation flow: Doctor list → filter by location → verify badge → reset → Arabic mode check

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies — can start immediately
- **Foundational (Phase 2)**: Depends on Phase 1 (T001) — BLOCKS all user stories
- **US1 (Phase 3)**: Depends on Phase 2 completion
- **US2 (Phase 4)**: Depends on Phase 2 completion — can run in parallel with US1
- **US3 (Phase 5)**: Depends on Phase 2 completion — can run in parallel with US1/US2
- **US4 (Phase 6)**: Depends on Phase 2 completion — can run in parallel with US1/US2/US3
- **US5 (Phase 7)**: Depends on US1 and US4 (needs the new components to exist before auditing locale)
- **Polish (Phase 8)**: Depends on all user stories being complete

### User Story Dependencies

- **US1 (P1)**: Can start after Phase 2 — No dependencies on other stories
- **US2 (P2)**: Can start after Phase 2 — Independent of US1
- **US3 (P2)**: Can start after Phase 2 — Benefits from US1 (location filter adds to count) but independently testable
- **US4 (P3)**: Can start after Phase 2 — Independent of US1/US2/US3
- **US5 (P3)**: Depends on US1 + US4 completion (audits their components for locale compliance)

### Within Each User Story

- Models/locale keys before components
- Controller logic before UI wiring
- Core implementation before list screen integration
- Story complete before checkpoint validation

### Parallel Opportunities

- **Phase 2**: T008, T009, T010, T011 can run in parallel (4 different list screen files)
- **Phase 3**: T012 and T013 can run in parallel (locale files vs component file)
- **Phase 4**: T022 through T029 can ALL run in parallel (8 different component files)
- **Phase 6**: T032 and T033 can run in parallel (2 different new component files)
- **Phase 7**: T040 and T041 can run in parallel (different files)
- **Cross-phase**: US1, US2, US3, US4 can all run in parallel after Phase 2

---

## Parallel Example: User Story 2

```text
# Launch all 8 component updates in parallel (all different files):
Task T022: "Update type_list_component.dart — shadow + gradient on selection"
Task T023: "Update filter_category.dart — shadow on selected chips"
Task T024: "Update filter_service.dart — shadow on selected chips"
Task T025: "Update filter_service_type_component.dart — shadow on selected chips"
Task T026: "Update filter_clinic_component.dart — replace hardcoded green"
Task T027: "Update filter_search_clinic_component.dart — inputFocusGlow"
Task T028: "Update filter_price_component.dart — shadow polish"
Task T029: "Update rating_filter.dart — shadow polish"
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup (T001)
2. Complete Phase 2: Foundational (T002–T011)
3. Complete Phase 3: User Story 1 (T012–T021)
4. **STOP and VALIDATE**: Test location filtering independently on all list screens
5. Deploy/demo if ready — patients can now filter by governorate/city

### Incremental Delivery

1. Phase 1 + Phase 2 → Foundation ready (FilterParams, count consolidation, badge widget)
2. Add US1 (Phase 3) → Location filtering works → **MVP deployed**
3. Add US2 (Phase 4) → Filter UI matches Clinical Elegance design
4. Add US3 (Phase 5) → Per-category active indicators in sidebar
5. Add US4 (Phase 6) → Doctor-specific specialty/gender filters
6. Add US5 (Phase 7) → All hardcoded strings fixed, full Arabic support
7. Phase 8 → Final polish and validation

### Parallel Strategy

With multiple agents working simultaneously:

1. All agents complete Phase 1 + Phase 2 together (sequential, shared files)
2. Once Phase 2 is done:
   - Agent A: US1 (location filtering) — highest priority
   - Agent B: US2 (UI modernization) — all 8 files in parallel
   - Agent C: US3 + US4 (badges + specialty/gender)
3. US5 runs after US1 + US4 complete (audits their components)
4. Phase 8 polish runs last

---

## Notes

- [P] tasks = different files, no dependencies on incomplete tasks in same phase
- [Story] label maps task to specific user story for traceability
- Each user story is independently completable and testable after Phase 2
- Commit after each task or logical group
- Stop at any checkpoint to validate the story independently
- FilterController is modified across multiple phases — execute T002–T005 as a group, then T014–T020 as a group, then T030, T034–T037, T040 sequentially to avoid merge conflicts
