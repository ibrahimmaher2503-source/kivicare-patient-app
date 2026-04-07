# Research: Location & Search

**Feature**: `008-location-search` | **Date**: 2026-04-02

## Research Summary

All NEEDS CLARIFICATION items resolved through codebase research. No external unknowns remain.

---

## R1: Unauthenticated Request Handling

**Decision**: Use existing `buildHttpResponse()` as-is — the header builder already skips the Bearer token when `isLoggedIn.value == false`. For logged-in users, the token is harmlessly included; the backend accepts it but doesn't require it for public endpoints.

**Rationale**: `buildHeaderTokens()` in `network_utils.dart` only adds `Authorization: Bearer` when `isLoggedIn.value == true`. The search endpoints are public — an extra token header doesn't break anything. No special handling needed.

**Alternatives considered**:
- Temporarily setting `isLoggedIn.value = false` before search calls → Rejected: risky side effects on concurrent requests
- Adding an `isPublic` flag to `buildHttpResponse()` → Rejected: unnecessary complexity per Constitution VII

---

## R2: Base URL Compatibility

**Decision**: No change needed. The spec says search endpoints use `{APP_URL}/api` (NOT `/api/v1`). The existing `BASE_URL = '$DOMAIN_URL/api/'` in `configs.dart` already matches. The search endpoint constants in `api_end_points.dart` (e.g., `'doctors/search'`, `'governorates'`) are relative and prepended with `BASE_URL`, resulting in `https://espitalia.net/api/doctors/search` — exactly correct.

**Rationale**: Verified `BASE_URL = '$DOMAIN_URL/api/'` and `buildBaseUrl()` prepends it to relative endpoints. All 8 search endpoints already defined without `v1/` prefix.

**Alternatives considered**: None — existing setup works perfectly.

---

## R3: Existing Search API Method Gap Analysis

**Decision**: Extend 2 existing methods, add 2 new methods.

| Method | Status | Action Needed |
| ------ | ------ | ------------- |
| `searchDoctors()` | Partial | Add: `specialtyId`, `gender`, `minPrice`, `maxPrice` params |
| `searchClinics()` | Partial | Add: `specialtyId` param |
| `searchNurses()` | Complete | None |
| `searchLabs()` | Complete | None |
| `searchRadiology()` | Missing | Create new method |
| `searchHomeHealthcare()` | Missing | Create new method |

**Rationale**: The existing methods were added incrementally (prior features) but didn't include all filter params from the API spec. The nurse and lab methods are already complete.

---

## R4: Model Availability

**Decision**: Create only `HomeHealthcareProvider` model. All other models exist.

| Model | Exists? | Location |
| ----- | ------- | -------- |
| `Governorate` | Yes | `lib/models/governorate_model.dart` |
| `City` | Yes | `lib/models/city_model.dart` |
| `Doctor` + `DoctorSearchListResponse` | Yes | `lib/screens/doctor/model/doctor_list_res.dart` |
| `Clinic` + `ClinicSearchListResponse` | Yes | `lib/screens/clinic/model/clinics_res_model.dart` |
| `Nurse` + `NurseListResponse` | Yes | `lib/screens/nurse/model/nurse_model.dart` (via nurse_list_controller import chain) |
| `LabTest` + `LabTestListResponse` | Yes | `lib/screens/lab_test/model/` |
| `RadiologyCenter` + `RadiologyCenterListResponse` | Yes | `lib/screens/radiology/model/radiology_center_model.dart` |
| `HomeHealthcareProvider` | **No** | Needs creation |

**Rationale**: Codebase search confirmed all models except `HomeHealthcareProvider`. The search response for home healthcare follows the same envelope pattern as other search endpoints — the list response model can follow the exact same pattern as `RadiologyCenterListResponse`.

---

## R5: GovernoratesCityPicker Reusability

**Decision**: Reuse the existing `GovernoratesCityPicker` component in all 6 search screens without modification.

**Rationale**: The component already:
- Has session-level caching for governorates and per-governorate city caching
- Cascading dropdowns (city depends on governorate)
- Loading states with `LinearProgressIndicator`
- Dark mode support via `isDarkMode.value`
- Callbacks: `onGovernorateChanged(int?)`, `onCityChanged(int?)`
- "All Governorates" / "All Cities" null options for clearing filters
- "Select Governorate" disabled hint on city dropdown

No modifications needed.

---

## R6: Controller Pattern Selection

**Decision**: Use the nurse list controller pattern (debounced `RxString` with `debounce()`) for all 6 search controllers.

**Rationale**: Compared three existing patterns:
1. **Nurse controller**: `debounce(searchQuery, ..., Duration(500ms))` — cleanest, most readable
2. **Clinic controller**: `StreamController<String>` with manual debounce — more complex, same result
3. **Independent doctor controller**: Same as nurse pattern

The nurse pattern is the most recent and cleanest implementation. All 6 controllers follow this exact pattern.

---

## R7: Search Screen Entry Point

**Decision**: Create a `SearchHubScreen` accessible from the home screen's quick services section, providing cards for each of the 6 provider types.

**Rationale**: The home screen's `QuickServicesComponent` already navigates to feature-specific list screens (Nurse → `NurseListScreen`, Lab Tests → `LabTestCategoriesScreen`, etc.). A search hub screen provides a unified entry point that maintains the existing navigation hierarchy. Each card navigates to the specific search screen.

**Alternatives considered**:
- Adding 6 individual search entries to the home screen → Rejected: too crowded, clutters the quick services section
- Adding search tabs to existing list screens → Rejected: existing screens are authenticated (My Requests); search is public
- Bottom navigation tab for search → Rejected: changes dashboard structure, high blast radius

---

## R8: Locale String Keys

**Decision**: Add ~20 new locale keys following existing naming conventions. Prefix search-specific keys with `search` or use descriptive names matching existing patterns.

**New keys needed**:
- `searchProviders` / `discoverProviders`
- `searchDoctors`, `searchClinics`, `searchNurses`, `searchLabs`, `searchRadiology`, `searchHomeHealthcare`
- `specialty`, `gender`, `minPrice`, `maxPrice`, `scanType`, `serviceType`, `availability`
- `male`, `female` (may already exist)
- `available`, `busy`, `offDuty`
- `noResultsFound`, `broadenFilters`
- `homeHealthcare`, `radiologyCenter`

**Rationale**: Follows existing pattern of descriptive camelCase keys in `BaseLanguage` abstract class. Will check for existing keys (like `male`/`female`) before adding duplicates.
