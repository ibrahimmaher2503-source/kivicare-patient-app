# Tasks: Labs & Radiology Centers Browse

**Input**: Design documents from `/specs/009-labs-radiology-browse/`
**Prerequisites**: plan.md (required), spec.md (required), research.md, data-model.md, contracts/api-endpoints.md, quickstart.md

**Tests**: Not requested (constitution marks tests as recommended, not mandatory for UI browse screens).

**Organization**: Tasks grouped by user story to enable independent implementation and testing.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3, US4)
- Include exact file paths in descriptions

---

## Phase 1: Foundational (Data Layer + API + Locale Scaffolding)

**Purpose**: Create the data model, API methods, and locale keys that all user stories depend on. Screens cannot compile without these.

**⚠️ CRITICAL**: No screen work can begin until this phase is complete.

- [x] T001 [P] Create Lab model and LabListResponse classes in `lib/screens/lab_test/model/lab_model.dart` — fields: `id` (int), `name` (String), `governorate` (Governorate?), `city` (City?). LabListResponse parses `data.items[]` + `data.pagination{}` (currentPage, lastPage, perPage, total). Import Governorate from `lib/models/governorate_model.dart` and City from `lib/models/city_model.dart`. Include `fromJson()` and `toJson()` methods.

- [x] T002 [P] Add new locale keys to the BaseLanguage abstract class in `lib/locale/languages.dart` and English implementation in `lib/locale/language_en.dart`: `labs` ("Labs"), `browseLabs` ("Browse Labs"), `noLabsFound` ("No labs found"), `scanType` ("Scan Type"). Also add English placeholder getters to `lib/locale/language_ar.dart`, `lib/locale/language_de.dart`, `lib/locale/language_fr.dart`, `lib/locale/language_hi.dart` with `// TODO: translate` comments so the app compiles. Check which keys already exist (e.g., `radiologyCenters`, `noRadiologyCentersFound`) and only add missing ones.

- [x] T003 Add `searchLabFacilities()` static method to `lib/api/core_apis.dart` — follow the existing `searchLabs()` pattern but parse into `Lab` model from `lab_model.dart` instead of `LabTest`. Use endpoint `APIEndPoints.labsSearch`. Params: `page`, `perPage`, `testName` (maps to `test_name` query param), `governorateId`, `cityId`. On page 1, clear the list; otherwise append. Use `lastPageCallBack` for pagination status. URL-encode `testName`.

- [x] T004 Add `searchRadiologyCenters()` static method to `lib/api/core_apis.dart` — use endpoint `APIEndPoints.radiologySearch`. Params: `page`, `perPage`, `scanType` (maps to `scan_type` query param, exact match), `governorateId`, `cityId`. Parse into `RadiologyCenterListResponse` from `lib/screens/radiology/model/radiology_center_model.dart`. Same pagination pattern as T003.

**Checkpoint**: Data layer complete — Lab model, both API methods, and locale keys exist. App compiles.

---

## Phase 2: User Story 1 — Browse Physical Labs by Location (Priority: P1) 🎯 MVP

**Goal**: Patients can search and filter physical lab facilities by location, with paginated results.

**Independent Test**: Open Labs screen → select governorate/city → verify matching labs appear in a scrollable list. Type a lab name → verify filtered results after debounce. Scroll to bottom → verify next page loads.

### Implementation for User Story 1

- [x] T005 [P] [US1] Create LabsListController (GetxController) in `lib/screens/lab_test/labs_list_controller.dart` — clone pattern from `lib/screens/lab_test/lab_test_list_controller.dart`. State: `RxList<Lab> labs`, `RxBool isLoading`, `RxBool isLastPage`, `RxInt page` (starts at 1), `TextEditingController searchCont`, `RxString searchQuery`, `RxnInt selectedGovernorateId`, `RxnInt selectedCityId`. In `onInit()`: call `getLabs()` and setup 500ms debounce on `searchQuery`. Method `getLabs()` calls `CoreServiceApis.searchLabFacilities()`. Methods: `onGovernorateChanged(int?)`, `onCityChanged(int?)` — reset page to 1 and re-fetch. No department filter needed.

- [x] T006 [P] [US1] Create LabCard widget in `lib/screens/lab_test/components/lab_card.dart` — display lab name (Outfit font, bold), governorate name, and city name. Follow existing `LabTestCard` styling: 16px card radius, soft shadow (`softShadowColor`), gradient top border (2px, using `gradientStart`/`gradientEnd`). Show location with `Icons.location_on_outlined` icon. Accepts `Lab` object as constructor parameter. Dark mode support using `isDarkMode` from `app_common.dart`.

- [x] T007 [US1] Create LabsListScreen (StatefulWidget) in `lib/screens/lab_test/labs_list_screen.dart` — uses AppScaffold. Layout (top to bottom): search bar with `locale.value.searchHere` hint, GovernoratesCityPicker (pass controller's `selectedGovernorateId`/`selectedCityId` and callbacks), paginated list of LabCards using AnimatedScrollView. Pagination: `onNextPage` increments page and calls `controller.getLabs()` when `!isLastPage`. `onSwipeRefresh` resets page to 1. Empty state: icon + `locale.value.noLabsFound`. Loading state: `Obx()` wrapping loader. Init: `Get.put(LabsListController())`, dispose: `Get.delete<LabsListController>()`.

**Checkpoint**: Labs browse screen fully functional — search, location filters, pagination, empty/loading states all work.

---

## Phase 3: User Story 2 — Browse Radiology Centers with Scan Type Filter (Priority: P1)

**Goal**: Patients can search and filter radiology centers by scan type and location, with paginated results.

**Independent Test**: Open Radiology Centers screen → tap "MRI" chip → verify only MRI centers shown. Select location → verify combined filtering. Scroll → verify pagination.

### Implementation for User Story 2

- [x] T008 [P] [US2] Create RadiologyCentersController (GetxController) in `lib/screens/lab_test/radiology_centers_controller.dart` — same base pattern as LabsListController but add: `RxString selectedScanType = ''.obs` and `RxList<Map<String, String>> scanTypeFilters` built from `ScanTypeConst` values in `lib/utils/constants.dart` (All, MRI, CT, X-ray, Ultrasound). State: `RxList<RadiologyCenter> centers`, pagination vars, search vars, location vars. Method `getCenters()` calls `CoreServiceApis.searchRadiologyCenters()` with `scanType`. Method `onScanTypeChanged(String)` resets page and re-fetches. Default scan type is empty string (All).

- [x] T009 [P] [US2] Create RadiologyCenterCard widget in `lib/screens/lab_test/components/radiology_center_card.dart` — display center name (Outfit font, bold), scan type badge (gradient pill using department color `Color(0xFF7C4DFF)`), governorate, and city. Follow LabCard styling pattern (16px radius, soft shadows). Show scan type with appropriate icon (MRI → `Icons.psychology_outlined`, CT → `Icons.scanner_outlined`, X-ray → `Icons.radiography_outlined`, default → `Icons.medical_services_outlined`). Accepts `RadiologyCenter` as constructor param. Dark mode support.

- [x] T010 [US2] Create RadiologyCentersScreen (StatefulWidget) in `lib/screens/lab_test/radiology_centers_screen.dart` — uses AppScaffold. Layout: search bar, horizontal scroll scan type filter chips (selected chip gets gradient fill using `gradientSecondaryStart`/`gradientSecondaryEnd`, unselected gets outline), GovernoratesCityPicker, paginated list of RadiologyCenterCards. Same pagination pattern as LabsListScreen. Empty state: `locale.value.noRadiologyCentersFound`. Init/dispose: Get.put/delete RadiologyCentersController.

**Checkpoint**: Radiology Centers browse screen fully functional — scan type chips, search, location filters, pagination all work.

---

## Phase 4: User Story 3 — Navigate to Labs or Radiology from Lab Test Module (Priority: P2)

**Goal**: Patients can discover and navigate to Labs and Radiology Centers screens from the existing Lab Test section.

**Independent Test**: Open Lab Test Categories → tap a radiology category → verify it opens RadiologyCentersScreen. Check quick services → verify "Labs" and "Radiology Centers" cards are visible and navigate correctly.

**Dependencies**: Requires US1 (T007) and US2 (T010) to be complete — screens must exist to navigate to them.

### Implementation for User Story 3

- [x] T011 [US3] Update category tap logic in `lib/screens/lab_test/lab_test_categories_screen.dart` — in the LabTestCategoryCard's onTap handler, add condition: if `categoryData.department == 'radiology'` or `categoryData.slug.contains('radiology')`, navigate to `RadiologyCentersScreen()` instead of `LabTestListScreen()`. Import RadiologyCentersScreen. Keep existing behavior for non-radiology categories.

- [x] T012 [US3] Add "Labs" and "Radiology Centers" navigation cards to `lib/screens/home/components/quick_services_component.dart` — add two new `_buildServiceCard()` entries after the existing "Lab Tests" card. Labs card: icon `Icons.science_outlined`, label `locale.value.labs`, gradient using lab colors, onTap navigates to `LabsListScreen()`. Radiology Centers card: icon `Icons.radiography_outlined`, label `locale.value.radiologyCenters`, gradient using radiology purple colors, onTap navigates to `RadiologyCentersScreen()`. Import both screens.

**Checkpoint**: Navigation integration complete — all entry points work correctly.

---

## Phase 5: User Story 4 — Multi-language Support (Priority: P3)

**Goal**: All new screen labels display correctly in Arabic, German, French, and Hindi.

**Independent Test**: Switch app language to Arabic → verify Labs screen title reads "المعامل", Radiology Centers reads "مراكز الأشعة", scan type chips in Arabic. Repeat for DE, FR, HI.

**Dependencies**: Requires T002 (locale scaffolding with English placeholders).

### Implementation for User Story 4

- [x] T013 [P] [US4] Replace English placeholder translations with Arabic in `lib/locale/language_ar.dart` — `labs`: "المعامل", `browseLabs`: "تصفح المعامل", `noLabsFound`: "لم يتم العثور على معامل", `scanType`: "نوع الفحص". Remove `// TODO: translate` comments.

- [x] T014 [P] [US4] Replace English placeholder translations with German in `lib/locale/language_de.dart` — `labs`: "Labore", `browseLabs`: "Labore durchsuchen", `noLabsFound`: "Keine Labore gefunden", `scanType`: "Scan-Typ". Remove `// TODO: translate` comments.

- [x] T015 [P] [US4] Replace English placeholder translations with French in `lib/locale/language_fr.dart` — `labs`: "Laboratoires", `browseLabs`: "Parcourir les laboratoires", `noLabsFound`: "Aucun laboratoire trouvé", `scanType`: "Type de scan". Remove `// TODO: translate` comments.

- [x] T016 [P] [US4] Replace English placeholder translations with Hindi in `lib/locale/language_hi.dart` — `labs`: "प्रयोगशालाएं", `browseLabs`: "प्रयोगशालाएं ब्राउज़ करें", `noLabsFound`: "कोई प्रयोगशाला नहीं मिली", `scanType`: "स्कैन प्रकार". Remove `// TODO: translate` comments.

**Checkpoint**: All 5 languages display correct translations on both screens.

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Verify edge cases and overall quality.

- [x] T017 Verify empty states and error handling on both screens — test with no network, empty search results, all filters cleared, rapid typing in search field. Confirm debounce works (500ms), last page stops loading, error toast shows on network failure.

- [x] T018 Run `flutter analyze` from project root and fix any new warnings introduced by this feature. Do not fix pre-existing warnings (Radio groupValue/onChanged deprecation in payment_screen.dart, AppBarTheme color deprecation).

---

## Dependencies & Execution Order

### Phase Dependencies

- **Foundational (Phase 1)**: No dependencies — start immediately
- **US1 (Phase 2)**: Depends on Phase 1 completion (T001-T004)
- **US2 (Phase 3)**: Depends on Phase 1 completion (T001-T004)
- **US3 (Phase 4)**: Depends on US1 (T007) AND US2 (T010) — screens must exist
- **US4 (Phase 5)**: Depends on Phase 1 (T002) — locale scaffolding must exist
- **Polish (Phase 6)**: Depends on all phases complete

### User Story Dependencies

- **US1 (P1)**: Can start after Foundational — independent of other stories
- **US2 (P1)**: Can start after Foundational — independent of US1, **can run in parallel with US1**
- **US3 (P2)**: Depends on US1 + US2 completion (needs both screens to exist for navigation)
- **US4 (P3)**: Can start after Foundational T002 — independent of US1/US2/US3, **can run in parallel**

### Within Each User Story

- Controller and Card can be created in parallel ([P] tasks)
- Screen depends on its controller and card
- Each story is independently testable at its checkpoint

### Parallel Opportunities

- **Phase 1**: T001 and T002 can run in parallel (different files)
- **Phase 2 + Phase 3**: US1 and US2 can run in parallel (completely different files)
- **Phase 2/3 + Phase 5**: US4 translations can run in parallel with US1/US2 (different files)
- **Within US1**: T005 and T006 can run in parallel
- **Within US2**: T008 and T009 can run in parallel
- **Within US4**: T013, T014, T015, T016 all run in parallel (different files)

---

## Parallel Example: US1 + US2 Simultaneously

```bash
# After Phase 1 completes, launch US1 and US2 in parallel:

# Agent A: US1 - Labs
Task T005: "Create LabsListController in lib/screens/lab_test/labs_list_controller.dart"
Task T006: "Create LabCard in lib/screens/lab_test/components/lab_card.dart"
# Then T007 (depends on T005 + T006)

# Agent B: US2 - Radiology Centers
Task T008: "Create RadiologyCentersController in lib/screens/lab_test/radiology_centers_controller.dart"
Task T009: "Create RadiologyCenterCard in lib/screens/lab_test/components/radiology_center_card.dart"
# Then T010 (depends on T008 + T009)

# Agent C: US4 - Translations (can also run in parallel)
Task T013: "Arabic translations in lib/locale/language_ar.dart"
Task T014: "German translations in lib/locale/language_de.dart"
Task T015: "French translations in lib/locale/language_fr.dart"
Task T016: "Hindi translations in lib/locale/language_hi.dart"
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Foundational (T001-T004)
2. Complete Phase 2: US1 — Labs Browse (T005-T007)
3. **STOP and VALIDATE**: Open Labs screen, test search/filters/pagination
4. Deliverable: Patients can find lab facilities by location

### Incremental Delivery

1. Phase 1 (Foundational) → Data layer ready
2. US1 (Labs Browse) → Test independently → **MVP deliverable**
3. US2 (Radiology Centers) → Test independently → Second screen live
4. US3 (Navigation) → Test entry points → Full discoverability
5. US4 (Translations) → Test all languages → Localization parity
6. Polish → flutter analyze clean → Production ready

### Parallel Team Strategy

With multiple agents/developers:

1. Complete Phase 1 together (4 tasks, 2 parallel)
2. Once Phase 1 done:
   - Agent A: US1 (Labs) — 3 tasks
   - Agent B: US2 (Radiology Centers) — 3 tasks
   - Agent C: US4 (Translations) — 4 tasks (all parallel)
3. After US1 + US2: US3 (Navigation) — 2 tasks
4. Polish phase

---

## Notes

- [P] tasks = different files, no dependencies on incomplete tasks
- [Story] label maps task to specific user story for traceability
- Existing models reused: `RadiologyCenter` (from `lib/screens/radiology/model/`), `Governorate`, `City`
- Existing components reused: `GovernoratesCityPicker`, `AppScaffold`, `AnimatedScrollView`
- Existing constants reused: `ScanTypeConst`, `APIEndPoints.labsSearch`, `APIEndPoints.radiologySearch`
- No new packages required — all dependencies already in `pubspec.yaml`
- Commit after each task or logical group
- Stop at any checkpoint to validate story independently
