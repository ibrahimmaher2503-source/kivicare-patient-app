# Research: Nurse Request Module

**Branch**: `002-nurse-request-module` | **Date**: 2026-03-29

## Key Finding: Module Already Exists

The codebase contains a fully implemented Nurse Request module at
`lib/screens/nurse/` with 12 files, 7 API methods, 2 main models
+ 4 nested, locale keys in all 5 languages, 8 color constants,
status/availability enums, and home screen integration.

## Existing Implementation Inventory

### Files (12 total)

```
lib/screens/nurse/
├── model/nurse_model.dart
├── model/nurse_request_model.dart
├── components/nurse_card.dart
├── components/nurse_request_card.dart
├── nurse_list_controller.dart
├── nurse_list_screen.dart
├── nurse_detail_screen.dart
├── create_nurse_request_controller.dart
├── create_nurse_request_screen.dart
├── nurse_request_list_controller.dart
├── nurse_request_list_screen.dart
└── nurse_request_detail_screen.dart
```

### API (7 methods in core_apis.dart)

- getNurseList() — paginated with search, availability, area, specialization filters
- getNurseDetail() — single nurse by user ID
- getNurseRequestList() — paginated with status filter
- createNurseRequest() — POST with form data
- getNurseRequestDetail() — single request
- updateNurseRequest() — PUT for pending requests
- cancelNurseRequest() — POST with cancellation_reason

### Infrastructure

- 7 endpoint constants in api_end_points.dart
- 19 locale keys in all 5 languages
- 5 request status colors + 3 availability colors
- Status/availability enums in constants.dart
- 2 home screen entry points

## Decisions

### D1: Build vs Verify

- **Decision**: Verify and complete existing implementation
- **Rationale**: Module fully implemented. Rebuilding would duplicate
  work and risk regressions.

### D2: No New Dependencies

- **Decision**: No new packages needed.
- **Rationale**: Existing http, nb_utils, GetX, and google_fonts
  cover all requirements.
