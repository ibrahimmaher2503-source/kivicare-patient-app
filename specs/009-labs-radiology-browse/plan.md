# Implementation Plan: Labs & Radiology Centers Browse

**Branch**: `009-labs-radiology-browse` | **Date**: 2026-04-02 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `/specs/009-labs-radiology-browse/spec.md`

## Summary

Add two new browse screens — **Labs List** and **Radiology Centers** — to the existing lab test module. Both screens provide paginated, searchable, location-filterable lists of physical facilities. The Radiology Centers screen adds scan type chip filters. Navigation integrates into the existing Lab Test section via `Get.to()` calls. Localization keys are added to all 5 language files.

## Technical Context

**Language/Version**: Dart 3.0+ / Flutter 3.0+
**Primary Dependencies**: GetX 4.7.2+, nb_utils, google_fonts, http
**Storage**: N/A (read-only browse screens, no local persistence)
**Testing**: Recommended per constitution (not mandatory for UI screens)
**Target Platform**: Android, iOS, Web
**Project Type**: Mobile app (Flutter)
**Performance Goals**: Results visible within 2 seconds of filter change; smooth scroll pagination
**Constraints**: Must follow GetX patterns, localization-first, Clinical Elegance design tokens
**Scale/Scope**: 2 new screens, 2 new controllers, 1 new model (Lab), 1 existing model (RadiologyCenter), 3 new card components, ~5 modified files for navigation/locale

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Status | Notes |
|-----------|--------|-------|
| I. Platform Parity | PASS | Both screens are standard Flutter widgets with no platform-specific code. GovernoratesCityPicker is already cross-platform. |
| II. Patient Data Security | PASS | Both APIs are public (no auth required). No patient data displayed or stored. |
| III. GetX Architecture Consistency | PASS | Controllers use `GetxController`, `.obs`, `Obx()`. Navigation via `Get.to()`. No new state patterns introduced. |
| IV. Backend Contract Fidelity | PASS | New endpoints added to `api_end_points.dart`. Follow `buildHttpResponse()` → `handleResponse()` → model pattern. |
| V. Localization-First | PASS | All new strings added to all 5 language files via `locale.value.<key>`. |
| VI. Testing Discipline | N/A | UI browse screens — tests recommended but not required. |
| VII. Simplicity & Maintainability | PASS | Follows existing patterns exactly (LabTestListController blueprint). No new abstractions. |

**Gate Result**: ALL PASS — proceed to Phase 0.

## Project Structure

### Documentation (this feature)

```text
specs/009-labs-radiology-browse/
├── plan.md              # This file
├── research.md          # Phase 0 output
├── data-model.md        # Phase 1 output
├── quickstart.md        # Phase 1 output
├── contracts/           # Phase 1 output
│   └── api-endpoints.md
├── checklists/
│   └── requirements.md  # Spec quality checklist
└── tasks.md             # Phase 2 output (created by /speckit.tasks)
```

### Source Code (repository root)

```text
lib/
├── api/
│   └── core_apis.dart                          # ADD: searchRadiologyCenters() method
├── screens/
│   └── lab_test/
│       ├── model/
│       │   └── lab_model.dart                  # NEW: Lab model + LabListResponse
│       ├── components/
│       │   ├── lab_card.dart                   # NEW: Lab facility card
│       │   └── radiology_center_card.dart      # NEW: Radiology center card
│       ├── labs_list_controller.dart            # NEW: GetX controller for labs
│       ├── labs_list_screen.dart                # NEW: Labs browse screen
│       ├── radiology_centers_controller.dart    # NEW: GetX controller for radiology
│       ├── radiology_centers_screen.dart        # NEW: Radiology centers browse screen
│       └── lab_test_categories_screen.dart      # MODIFY: Smart routing for radiology categories
├── locale/
│   ├── language_en.dart                        # MODIFY: Add new locale keys
│   ├── language_ar.dart                        # MODIFY: Add new locale keys
│   ├── language_de.dart                        # MODIFY: Add new locale keys
│   ├── language_fr.dart                        # MODIFY: Add new locale keys
│   └── language_hi.dart                        # MODIFY: Add new locale keys
└── screens/
    └── home/
        └── components/
            └── quick_services_component.dart    # MODIFY: Add Labs & Radiology nav cards
```

**Structure Decision**: All new files go under the existing `lib/screens/lab_test/` directory since Labs and Radiology Centers are conceptually part of the lab test module. No new top-level directories needed.

## Key Design Decisions

### D1: Lab Model — New file, not reusing LabTest

The existing `LabTest` model has many fields irrelevant to physical labs (code, sampleType, preparationInstructions, defaultPrice). The Lab entity from the API is simpler: `{id, name, governorate, city}`. A dedicated `Lab` model keeps things clean.

### D2: RadiologyCenter Model — Reuse existing

The `RadiologyCenter` model already exists at `lib/screens/radiology/model/radiology_center_model.dart` with proper pagination response handling. Reuse it directly — no need to duplicate.

### D3: Navigation — Direct Get.to() calls, not named routes

The project has no `app_routes.dart` or `app_pages.dart`. All navigation uses `Get.to()` with arguments. The user's request for named routes `/labs` and `/radiology-centers` will be implemented as direct navigation to match the existing convention.

### D4: API Methods — Follow searchLabs() pattern exactly

The existing `CoreServiceApis.searchLabs()` method is the blueprint. The new `searchRadiologyCenters()` method will follow the same pattern: build query params, call `buildHttpResponse()`, parse with model's `fromJson()`, manage pagination via `lastPageCallBack`.

### D5: Scan Type Chips — Use existing ScanTypeConst

`ScanTypeConst` already exists in `lib/utils/constants.dart` with values: mri, ct, xray, ultrasound, mammogram, dexa. Reuse these constants for the filter chips.

### D6: Labs API already has an endpoint

`APIEndPoints.labsSearch = 'labs/search'` and `APIEndPoints.radiologySearch = 'radiology/search'` already exist. No new endpoints needed in `api_end_points.dart`.

## Complexity Tracking

No constitution violations. No complexity justifications needed.
