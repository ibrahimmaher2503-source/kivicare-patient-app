# Implementation Plan: Enhance Filter Screens & Controllers

**Branch**: `011-enhance-filters` | **Date**: 2026-04-05 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `/specs/011-enhance-filters/spec.md`

## Summary

Enhance the booking filter system to add location filtering (governorate/city) to the filter modal, unify filter UI with the Clinical Elegance design system, consolidate the fragmented filter count logic into a single computed getter, add module-specific filters (specialty/gender for doctors), and fix hardcoded locale strings. The backend already supports all needed filter parameters — this is purely a frontend wiring and UI enhancement effort.

## Technical Context

**Language/Version**: Dart 3.0+ / Flutter 3.0+
**Primary Dependencies**: GetX 4.7.2 (state management), nb_utils (UI helpers), Google Fonts, stream_transform
**Storage**: GetStorage (local preferences) — not directly involved in this feature
**Testing**: flutter test (recommended for filter count logic)
**Target Platform**: Android (primary), iOS, Web
**Project Type**: Mobile app (Flutter)
**Performance Goals**: Filter results update in < 2 seconds, 60fps animations on filter interactions
**Constraints**: Must work in Arabic RTL mode, must use existing backend search APIs without modifications
**Scale/Scope**: ~15 files modified, ~3 new files, affects 4 list screens + 8 filter components + 6 search screens

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Status | Notes |
|-----------|--------|-------|
| I. Platform Parity | PASS | All changes are pure Flutter/Dart — no platform-specific code. Filter UI renders identically on Android/iOS/Web. |
| II. Patient Data Security | PASS | Filters don't handle sensitive data. Location filters use governorate/city IDs, not patient GPS coordinates. |
| III. GetX Architecture | PASS | All new state uses `.obs` observables. FilterParams replaces positional List but still passes via `Get.arguments`. Controllers use `Get.put()`. |
| IV. Backend Contract Fidelity | PASS | No API changes. All search endpoints already accept governorate_id, city_id, specialty_id, gender params. Endpoints registered in api_end_points.dart. |
| V. Localization-First | PASS | Fix 2 existing hardcoded strings. Add 1 new locale key (`filterLocation`). All labels via `locale.value.<key>`. |
| VI. Testing | PASS | Recommended: unit test for filter count computation logic. |
| VII. Simplicity | PASS | FilterParams class replaces brittle positional list (simpler, not more complex). Consolidated count replaces 9 counters (simpler). No new packages. |

**Post-Phase 1 Re-check**: All principles remain PASS. No new abstractions, packages, or platform-specific code introduced in the design.

## Project Structure

### Documentation (this feature)

```text
specs/011-enhance-filters/
├── plan.md              # This file
├── research.md          # Phase 0: resolved unknowns
├── data-model.md        # Phase 1: FilterParams, FilterTypeConfig, ActiveFilterCount
├── quickstart.md        # Phase 1: developer setup guide
└── tasks.md             # Phase 2 output (created by /speckit.tasks)
```

### Source Code (repository root)

```text
lib/
├── screens/booking/filter/
│   ├── filter_controller.dart                          # MODIFY: FilterParams, location/specialty/gender vars, consolidated count
│   ├── filter_screen.dart                              # MODIFY: Accept FilterParams, design token updates
│   ├── model/
│   │   └── filter_params.dart                          # NEW: Typed parameter class
│   └── components/
│       ├── type_list_component.dart                    # MODIFY: Shadow/gradient on selection
│       ├── filter_location_component.dart              # NEW: GovernoratesCityPicker wrapper
│       ├── filter_specialty_component.dart             # NEW: Specialty picker (doctor module)
│       ├── filter_gender_component.dart                # NEW: Gender selector (doctor module)
│       ├── filter_category.dart                        # MODIFY: Add shadow on selected chips
│       ├── filter_service.dart                         # MODIFY: Add shadow on selected chips
│       ├── rating_filter.dart                          # MODIFY: Fix hardcoded "Rating" string
│       ├── service_type_filter/
│       │   └── filter_service_type_component.dart      # MODIFY: Add shadow on selected chips
│       ├── clinic_filter/
│       │   ├── filter_clinic_component.dart            # MODIFY: Minor — hardcoded green → token
│       │   └── filter_search_clinic_component.dart     # MODIFY: Minor — add inputFocusGlow
│       └── price_filter/
│           └── filter_price_component.dart             # MODIFY: Minor polish
├── screens/home/components/
│   ├── doctor_list_screen.dart                         # MODIFY: Pass FilterParams, unified badge widget
│   ├── clinic_list_screen.dart                         # MODIFY: Pass FilterParams, unified badge widget
│   └── popular_service_list.dart                       # MODIFY: Pass FilterParams, unified badge widget
├── screens/service/
│   └── services_list_screen.dart                       # MODIFY: Pass FilterParams, unified badge widget
├── screens/doctor/
│   └── doctor_list_controller.dart                     # MODIFY: Add specialtyId, gender; pass to searchDoctors()
├── screens/clinic/
│   └── clinic_list_controller.dart                     # VERIFY: Already has location vars — ensure FilterController wires them
├── locale/
│   ├── languages.dart                                  # MODIFY: Add filterLocation to BaseLanguage
│   ├── language_en.dart                                # MODIFY: Add filterLocation English value
│   └── language_ar.dart                                # MODIFY: Add filterLocation Arabic value
└── components/
    └── filter_count_badge.dart                         # NEW: Shared badge widget for filter icon overlay
```

**Structure Decision**: Flutter mobile app — all changes within existing `lib/` structure. New files limited to 4 (FilterParams model, 3 new filter components, 1 shared badge widget). No new directories needed beyond `filter/model/`.

## Implementation Phases

### Phase 1: Foundation — FilterParams & Count Consolidation (P1 prerequisite)

**Goal**: Replace fragile positional arguments with typed FilterParams. Consolidate 9 counter variables into a single computed getter. Create shared badge widget.

**Files**:
- NEW: `lib/screens/booking/filter/model/filter_params.dart`
- MODIFY: `lib/screens/booking/filter/filter_controller.dart`
- MODIFY: `lib/screens/booking/filter/filter_screen.dart`
- NEW: `lib/components/filter_count_badge.dart`
- MODIFY: 4 list screens (doctor_list_screen, clinic_list_screen, popular_service_list, services_list_screen)

**Key changes**:
1. Create `FilterParams` class with all named fields (clinicId, serviceType, priceMin, priceMax, moduleType, categoryId, governorateId, cityId, specialtyId, gender, ratingMin, ratingMax)
2. Update `FilterController.onInit()` to read from `FilterParams` instead of positional list
3. Replace 9 counter vars with single `int get activeFilterCount` computed getter
4. Update `applyFilter()` to return `activeFilterCount` consistently (always int, not sometimes Map)
5. Create `FilterCountBadge` widget — small gradient circle with count text
6. Update all 4 list screens to: (a) pass `FilterParams` via Get.arguments, (b) use `FilterCountBadge`

**Validation**: Open each list screen → filter icon → apply a filter → verify badge shows "1" → apply second filter → shows "2" → reset → shows nothing.

### Phase 2: Location Filter in Filter Modal (P1 core delivery)

**Goal**: Add governorate/city filtering to the filter modal, wired through to search APIs.

**Files**:
- NEW: `lib/screens/booking/filter/components/filter_location_component.dart`
- MODIFY: `lib/screens/booking/filter/filter_controller.dart` (add governorateId, cityId reactive vars, add "Location" to all filter lists)
- MODIFY: `lib/screens/booking/filter/filter_controller.dart` `applyFilter()` (pass governorateId/cityId to list controllers)
- MODIFY: `lib/screens/doctor/doctor_list_controller.dart` (ensure governorateId/cityId are set from FilterController)
- MODIFY: `lib/screens/service/service_list_controller.dart` (add governorateId/cityId if not present)

**Key changes**:
1. Create `FilterLocationComponent` — wraps `GovernoratesCityPicker` with filter modal styling
2. Add `selectedGovernorateId` and `selectedCityId` reactive vars to FilterController
3. Add `locale.value.location` (or new `filterLocation`) to all four filter type lists (filterList, serviceFilterList, clinicFilterList, categoryFilterList)
4. Update `viewFilterWidget()` switch to render FilterLocationComponent for "Location" case
5. Update `applyFilter()` for each module type to pass location params to the target controller
6. Update `resetFilter()` to clear location vars

**Validation**: Doctor list → filter → select Location → pick governorate → pick city → Apply → verify only doctors from that city appear. Reset → all doctors return.

### Phase 3: UI Modernization — Filter Components (P2)

**Goal**: Align all filter components with Clinical Elegance design tokens.

**Files** (all MODIFY):
- `type_list_component.dart` — Add BoxShadow + gradient accent on selected item
- `filter_category.dart` — Add BoxShadow on selected chips
- `filter_service.dart` — Add BoxShadow on selected chips
- `filter_service_type_component.dart` — Add BoxShadow on selected chips
- `filter_clinic_component.dart` — Replace hardcoded `Colors.green.shade600` with design token
- `filter_search_clinic_component.dart` — Add `inputFocusGlow` on focus state
- `filter_price_component.dart` — Minor shadow polish
- `rating_filter.dart` — Minor shadow polish

**Pattern**: Apply the shadow pattern from `filter_clinic_component.dart` lines 103-111:
```dart
boxShadow: isSelected ? [
  BoxShadow(
    color: appColorSecondary.withValues(alpha: 0.15),
    blurRadius: 8,
    offset: const Offset(0, 2),
  ),
] : [],
```

**Validation**: Visual comparison — open filter modal, verify all components have consistent shadow/depth treatment, match the search screen chip styling.

### Phase 4: Module-Specific Filters — Specialty & Gender (P3)

**Goal**: Add specialty and gender filter types to the filter modal, visible only for doctor module.

**Files**:
- NEW: `lib/screens/booking/filter/components/filter_specialty_component.dart`
- NEW: `lib/screens/booking/filter/components/filter_gender_component.dart`
- MODIFY: `lib/screens/booking/filter/filter_controller.dart` (add specialtyId, gender vars; add to doctor filterList; update viewFilterWidget switch; update applyFilter for doctors)
- MODIFY: `lib/screens/doctor/doctor_list_controller.dart` (add specialtyId, gender; pass to searchDoctors())

**Key changes**:
1. FilterSpecialtyComponent — list of specialties from API or constants, selectable chips
2. FilterGenderComponent — 3 chips (Male/Female/Other) using `genders` reactive list from constants.dart
3. Add "Specialty" and "Gender" to `filterList` only (doctor module list)
4. Update `viewFilterWidget()` switch cases
5. Update `applyFilter('doctor')` to pass specialtyId and gender to DoctorListController
6. Update DoctorListController.getDoctors() to pass specialtyId and gender to searchDoctors()

**Validation**: Doctor list → filter → verify Specialty and Gender types visible → select a specialty → Apply → verify filtered results. Service list → filter → verify Specialty/Gender NOT visible.

### Phase 5: Locale Fixes & New Keys (P3)

**Goal**: Fix hardcoded English strings, add new locale key for Location filter type.

**Files**:
- MODIFY: `lib/screens/booking/filter/filter_controller.dart` line 79-80 — replace `"In Clinic"` / `"Online"` with `locale.value.inClinic` / `locale.value.online`
- MODIFY: `lib/screens/booking/filter/components/rating_filter.dart` line 23 — replace `"Rating"` with `locale.value.filterRating`
- MODIFY: `lib/locale/languages.dart` — add `String get filterLocation;`
- MODIFY: `lib/locale/language_en.dart` — add `String get filterLocation => 'Location';`
- MODIFY: `lib/locale/language_ar.dart` — add `String get filterLocation => 'الموقع';`

**Validation**: Switch app to Arabic → open filter modal → verify all labels display in Arabic with RTL layout. Switch back to English → verify English labels.

## Risk Assessment

| Risk | Impact | Mitigation |
|------|--------|------------|
| FilterParams refactor breaks existing screens | High | Phase 1 is purely structural — test all 4 list screens after refactor |
| Location filter API returns no results for some governorates | Low | Empty state already handled; backend APIs tested in search screens |
| Filter count getter doesn't update reactively | Medium | Use `Obx()` on badge widget; computed getter reads `.value` of all reactive vars |
| Design token changes look inconsistent across components | Low | Follow established pattern from filter_clinic_component.dart |

## Complexity Tracking

> No constitution violations — this section is empty.
