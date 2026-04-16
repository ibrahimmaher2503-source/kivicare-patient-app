# Research: Enhance Filter Screens & Controllers

**Branch**: `011-enhance-filters` | **Date**: 2026-04-05

## R1: FilterScreen Arguments Pattern

**Decision**: The current `Get.arguments` positional List [0..5] pattern is fragile and must be refactored when adding new filter types (location, specialty, gender).

**Current pattern**:
| Index | Type | Meaning |
|-------|------|---------|
| [0] | int | Clinic ID |
| [1] | String | Service Type ("In Clinic" / "Online" / "") |
| [2] | String | Min Price (as string) |
| [3] | String | Max Price (as string) |
| [4] | String | Module type ("doctor" / "service" / "clinic" / "category") |
| [5] | int | Category ID |

**Problem**: Adding location (governorateId, cityId), specialty, and gender would push to [6..9] — increasingly error-prone. Also, index [5] access is outside the `if (Get.arguments is List)` guard, causing potential crashes.

**Rationale**: A typed parameter class provides compile-time safety and self-documenting named fields. GetX supports passing any object via `Get.arguments`.

**Alternatives considered**:
- Keep positional list, extend to [9] → rejected: too error-prone
- Use a Map<String, dynamic> → rejected: no compile-time safety
- Use a typed class → **chosen**: safe, extensible, readable

---

## R2: Filter Count Consolidation

**Decision**: Replace the 9 separate counter variables with a single computed getter that derives count from actual filter state.

**Current counters** (all in FilterController):
- `seleFilterCount`, `seleClinicFilterCount`, `selePriceFilterCount`, `seleRatingFilterCount`, `seleCategoryFilterCount`
- Computed: `totalDoctorCount`, `totalServiceCount`, `totalCategoryCount`
- Computed (actual): `actualDoctorFilterCount`, `actualServiceFilterCount`, `actualCategoryFilterCount`

**Problem**: The `sele*Count` variables increment on first interaction but don't decrement on deselection. The `actual*Count` getters properly check state but aren't used consistently. Badge display uses 4 different approaches across screens.

**Rationale**: A single `activeFilterCount` computed getter that checks each filter parameter against its default eliminates all desync bugs.

**Alternatives considered**:
- Fix increment/decrement logic on existing counters → rejected: still 9 variables to maintain
- Single computed getter per module → **chosen**: one getter, works for all modules by checking which params are non-default

---

## R3: API Layer — What Backend Already Supports

**Decision**: No new API methods needed. All search endpoints already accept the parameters we need.

| API Method | Location | Specialty | Gender | Price | Scan Type |
|------------|----------|-----------|--------|-------|-----------|
| searchDoctors | governorate_id, city_id | specialty_id (int) | gender (string) | min_price, max_price (double) | - |
| searchClinics | governorate_id, city_id | specialty_id (int) | - | - | - |
| searchLabFacilities | governorate_id, city_id | - | - | - | - |
| searchRadiologyCenters | governorate_id, city_id | - | - | - | scan_type (string) |
| searchNurses | governorate_id, city_id | specialty (string) | gender (string) | - | - |
| searchHomeHealthcare | governorate_id, city_id | - | - | - | - |
| getServiceList | - (uses clinicId) | - | - | price_min, price_max | - |

**Key finding**: `DoctorListController.getDoctors()` already calls `searchDoctors` with governorate/city params but never passes specialty, gender, or price. The wiring exists — we just need to expose the UI and pass the params through.

---

## R4: Locale Key Audit

**Decision**: Only 2 hardcoded strings need fixing. All other filter locale keys (67 total) already exist in both EN and AR.

**Hardcoded strings found**:
1. `rating_filter.dart` line 23: `"Rating"` → should be `locale.value.filterRating`
2. `filter_controller.dart` lines 79-80: `"In Clinic"` / `"Online"` → should be `locale.value.inClinic` / `locale.value.online`

**New locale keys needed** (for new filter types in filter modal):
- `filterLocation` / `تصفية الموقع` — for the filter type sidebar label
- None others — `specialty`, `gender`, `governorate`, `city`, `allGovernorates`, `allCities`, `selectGovernorate` all already exist

---

## R5: UI Component Status

**Decision**: 4 of 8 filter components need shadow/depth updates. All already use Google Fonts and partial design tokens.

| Component | Status | Work Needed |
|-----------|--------|-------------|
| type_list_component | Partial | Add shadow elevation on selected state, subtle gradient |
| filter_clinic_component | Good | Minor: replace hardcoded green with token |
| filter_search_clinic_component | Good | Minor: add inputFocusGlow on focus |
| filter_category | Partial | Add shadow on selected chips |
| filter_service | Partial | Add shadow on selected chips |
| filter_price_component | Good | Minor polish |
| rating_filter | Good | Minor polish |
| filter_service_type_component | Partial | Add shadow on selected chips |

**Pattern to follow**: `filter_clinic_component.dart` lines 103-111 has the correct shadow pattern — apply to other chip components.

---

## R6: Filter State Persistence

**Decision**: GetX controller lifecycle already handles this. Controllers created with `Get.put()` persist until explicitly deleted. The current pattern where FilterController is created fresh each time FilterScreen opens is intentional — list controllers (DoctorListController, etc.) retain the applied filter values.

**How it works today**: FilterController applies values to the list controller, then FilterScreen pops. The list controller retains the filter values. When FilterScreen reopens, it reads current values from the list controller via Get.arguments.

**No change needed** for persistence — just ensure the new filter params (location, specialty, gender) follow the same pattern of being stored on the list controller.
