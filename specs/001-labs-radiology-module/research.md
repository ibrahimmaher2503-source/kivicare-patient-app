# Research: Labs & Radiology Module

**Branch**: `001-labs-radiology-module` | **Date**: 2026-03-29

## Key Finding: Module Already Exists

The codebase already contains a nearly complete Labs & Radiology module
at `lib/screens/lab_test/` with models, controllers, screens,
components, API methods, locale keys, and status colors. The git status
shows these files as **modified** (not new), confirming prior work.

## Existing Implementation Inventory

### Files Present

```
lib/screens/lab_test/
├── lab_test_categories_controller.dart
├── lab_test_categories_screen.dart
├── lab_test_list_controller.dart
├── lab_test_list_screen.dart
├── lab_test_detail_screen.dart
├── create_test_order_controller.dart
├── create_test_order_screen.dart
├── test_order_detail_screen.dart
├── test_order_list_controller.dart
├── test_order_list_screen.dart
├── model/
│   ├── lab_test_model.dart
│   ├── lab_test_category_model.dart
│   └── test_order_model.dart
└── components/
    ├── lab_test_card.dart
    ├── lab_test_category_card.dart
    └── test_order_card.dart
```

### API Integration

- **Endpoints**: All 8 defined in `api_end_points.dart`
- **API methods**: Implemented in `core_apis.dart`
  - `getLabTestCategories()`
  - `getLabTestList()` with pagination, search, category, department
  - `getTestOrderList()` with pagination and status filter
  - `createTestOrder()`
- **Missing/TBD**: Cancel order and report download API methods need
  verification

### Models

- `LabTestCategory` — matches API contract
- `LabTest` — matches API contract
- `TestOrder` with `TestOrderItem` — matches API contract
- Models include `fromJson()` / `toJson()`

### Locale Keys

Comprehensive lab test keys already defined in all 5 language files
(EN, AR, DE, FR, HI), including:
- Screen titles, button labels, status labels
- Priority labels (routine, urgent, stat)
- Result status labels (normal, abnormal, critical)
- Empty state messages

### Design System

- Lab-specific status colors defined in `colors.dart`
- Home screen integration in `quick_services_component.dart`
- Department filtering (laboratory/radiology) implemented

## Decisions

### D1: Build vs Verify Approach

- **Decision**: Verify and complete existing implementation
- **Rationale**: The module is already implemented. Building from
  scratch would duplicate work and risk regressions.
- **Alternatives**: Full rewrite — rejected because existing code
  follows established patterns and is mostly complete.

### D2: Report Download Strategy

- **Decision**: Use platform file download with progress indicator.
  Download binary PDF via authenticated GET, save to device storage,
  and open with platform PDF viewer.
- **Rationale**: API returns raw PDF binary. No external package
  needed — use `dart:io` HttpClient or existing network layer for
  binary download.
- **Alternatives**: In-app PDF viewer — rejected for simplicity;
  patients can use their preferred viewer.

### D3: Cancel Order UX

- **Decision**: Confirmation dialog with required reason text field.
  Show cancel button only when status is "pending" or "confirmed".
- **Rationale**: Matches API validation rules. Prevents accidental
  cancellation.

### D4: No New Dependencies Required

- **Decision**: No new packages needed.
- **Rationale**: The existing `http` package, `nb_utils`,
  `path_provider`, and `open_filex` (or `url_launcher`) cover all
  requirements. PDF download is a binary HTTP response saved to file.
- **Alternatives**: Adding `flutter_pdfview` — rejected per
  Constitution Principle VII (Simplicity).
