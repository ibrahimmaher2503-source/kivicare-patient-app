# Implementation Plan: Location & Search

**Branch**: `008-location-search` | **Date**: 2026-04-02 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `/specs/008-location-search/spec.md`

## Summary

Add a unified location-based search module that enables patients to discover healthcare providers (doctors, clinics, nurses, labs, radiology centers, home healthcare) by governorate/city with type-specific filters. Leverages 8 existing unauthenticated REST endpoints (`/api/*`), the existing `GovernoratesCityPicker` component, and 4 of 6 existing `search*()` API service methods. Requires extending 2 existing API methods with missing filter params, adding 2 new API methods (radiology, home healthcare), creating a `HomeHealthcareProvider` model, building 6 new search screens with controllers, and adding a search hub screen for navigation.

## Technical Context

**Language/Version**: Dart 3.0+ / Flutter 3.0+
**Primary Dependencies**: GetX 4.7.2+ (state management), nb_utils (UI helpers), Google Fonts (Plus Jakarta Sans + Outfit), http (networking)
**Storage**: N/A (all data from API; governorate/city cache is session-level in-memory via `GovernoratesCityPicker`)
**Testing**: flutter test (recommended, not mandatory per constitution)
**Target Platform**: Android (primary), iOS, Web
**Project Type**: Mobile app (Flutter)
**Performance Goals**: Search results within 2 seconds, location picker interactive within 1 second
**Constraints**: All search endpoints are unauthenticated (no bearer token); base URL is `/api/` (same as `BASE_URL`); 15 items per page
**Scale/Scope**: 6 search screens + 1 hub screen, ~20 new files

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Status | Notes |
| --------- | ------ | ----- |
| I. Platform Parity | PASS | All search screens use standard Flutter widgets; no platform-specific code needed. `GovernoratesCityPicker` already works cross-platform. |
| II. Patient Data Security | PASS | All search endpoints are public/unauthenticated — no patient data exposed. HTTPS enforced via `BASE_URL`. No credentials involved. |
| III. GetX Architecture Consistency | PASS | Controllers use `.obs` + `Obx()`, navigation via `Get.to()`, DI via `Get.put()`/`Get.delete()`. Follows existing nurse/clinic/lab patterns exactly. |
| IV. Backend Contract Fidelity | PASS | API endpoints already defined in `api_end_points.dart`. New API methods follow `buildHttpResponse()` → `handleResponse()` → model pattern. |
| V. Localization-First | PASS | All new UI strings added to all 5 language files via `locale.value.<key>`. Search endpoints already respect `Accept-Language` header (sent via `global-localization` in `buildHeaderTokens()`). |
| VI. Testing Discipline | PASS | Tests recommended but not mandatory. Search is read-only, low-risk. |
| VII. Simplicity & Maintainability | PASS | Reuses existing `GovernoratesCityPicker`, existing model patterns, existing controller patterns. No new abstractions — each search screen is self-contained. |

## Project Structure

### Documentation (this feature)

```text
specs/008-location-search/
├── plan.md              # This file
├── research.md          # Phase 0 output
├── data-model.md        # Phase 1 output
├── quickstart.md        # Phase 1 output
├── contracts/           # Phase 1 output (API contracts)
└── tasks.md             # Phase 2 output (/speckit.tasks)
```

### Source Code (repository root)

```text
lib/
├── api/
│   └── core_apis.dart                           # MODIFY: extend searchDoctors/searchClinics, add searchRadiology/searchHomeHealthcare
├── utils/
│   └── api_end_points.dart                      # ALREADY DONE: all 8 endpoints defined
├── models/
│   ├── governorate_model.dart                   # EXISTS: Governorate, GovernorateListResponse
│   ├── city_model.dart                          # EXISTS: City, CityListResponse
│   └── home_healthcare_provider_model.dart      # NEW: HomeHealthcareProvider, HomeHealthcareListResponse
├── screens/
│   ├── radiology/
│   │   └── model/
│   │       └── radiology_center_model.dart      # EXISTS: RadiologyCenter, RadiologyCenterListResponse
│   ├── search/                                  # NEW: search hub
│   │   ├── search_hub_screen.dart               # NEW: unified search entry point
│   │   ├── doctor_search_screen.dart            # NEW: doctor search with filters
│   │   ├── doctor_search_controller.dart        # NEW: doctor search controller
│   │   ├── clinic_search_screen.dart            # NEW: clinic search with filters
│   │   ├── clinic_search_controller.dart        # NEW: clinic search controller
│   │   ├── nurse_search_screen.dart             # NEW: nurse search with filters
│   │   ├── nurse_search_controller.dart         # NEW: nurse search controller
│   │   ├── lab_search_screen.dart               # NEW: lab search with filters
│   │   ├── lab_search_controller.dart           # NEW: lab search controller
│   │   ├── radiology_search_screen.dart         # NEW: radiology search with filters
│   │   ├── radiology_search_controller.dart     # NEW: radiology search controller
│   │   ├── home_healthcare_search_screen.dart   # NEW: home healthcare search
│   │   ├── home_healthcare_search_controller.dart # NEW: home healthcare controller
│   │   └── components/                          # NEW: shared search UI components
│   │       ├── search_result_card.dart           # NEW: generic provider card (or per-type cards)
│   │       └── search_filter_chips.dart          # NEW: reusable filter chip row
│   └── home/
│       └── components/
│           └── quick_services_component.dart     # MODIFY: add Search/Discover entry point
├── components/
│   └── governorates_city_picker.dart            # EXISTS: reusable location picker
└── locale/
    ├── languages.dart                           # MODIFY: add new string keys
    ├── language_en.dart                         # MODIFY: add English strings
    ├── language_ar.dart                         # MODIFY: add Arabic strings
    ├── language_de.dart                         # MODIFY: add German strings
    ├── language_fr.dart                         # MODIFY: add French strings
    └── language_hi.dart                         # MODIFY: add Hindi strings
```

**Structure Decision**: New search screens go under `lib/screens/search/` as a dedicated feature module, following the existing pattern of feature-grouped directories (nurse/, lab_test/, request_service/, etc.). The search hub provides a single entry point for all provider search types.

## Existing Assets Inventory

### Already Implemented (reuse as-is)

| Asset | Location | Status |
| ----- | -------- | ------ |
| API endpoints (all 8) | `api_end_points.dart:82-101` | Complete |
| `GovernoratesCityPicker` | `components/governorates_city_picker.dart` | Complete with caching |
| `Governorate` model | `models/governorate_model.dart` | Complete |
| `City` model | `models/city_model.dart` | Complete |
| `RadiologyCenter` model | `screens/radiology/model/radiology_center_model.dart` | Complete |
| `searchClinics()` API method | `core_apis.dart:214` | Partial — missing `specialty_id` param |
| `searchDoctors()` API method | `core_apis.dart:283` | Partial — missing `specialty_id`, `gender`, `min_price`, `max_price` |
| `searchNurses()` API method | `core_apis.dart:581` | Complete |
| `searchLabs()` API method | `core_apis.dart:690` | Complete |
| `getGovernorates()` API method | `core_apis.dart` | Complete |
| `getCities()` API method | `core_apis.dart` | Complete |

### Needs Creation

| Asset | Description |
| ----- | ----------- |
| `searchRadiology()` API method | New method in `core_apis.dart` |
| `searchHomeHealthcare()` API method | New method in `core_apis.dart` |
| `HomeHealthcareProvider` model | New model file |
| 6 search controllers | One per provider type |
| 6 search screens | One per provider type |
| 1 search hub screen | Unified entry point |
| Locale strings | ~20 new keys across 5 languages |

### Needs Extension

| Asset | What to add |
| ----- | ----------- |
| `searchDoctors()` | `specialty_id`, `gender`, `min_price`, `max_price` params |
| `searchClinics()` | `specialty_id` param |

## Complexity Tracking

No constitution violations. No complexity tracking needed.
