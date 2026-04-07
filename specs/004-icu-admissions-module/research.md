# Research: ICU Admissions Module

**Branch**: `004-icu-admissions-module` | **Date**: 2026-03-29

## Key Finding: Brand New Module

Unlike labs, nurse, and request-service, no existing code exists for
ICU admissions. All code must be built from scratch following
established patterns from the other modules.

## Patterns to Follow (from existing modules)

### Model Pattern (from lab_test_model.dart, nurse_model.dart)
- `fromJson()` / `toJson()` with snake_case mapping
- List response wrapper with pagination meta
- Nested model classes in same or separate files

### Controller Pattern (from lab_test_list_controller.dart)
- `RxList<T>` for data, `RxBool isLoading`, `RxBool isLastPage`
- `RxInt page`, search with `debounce()` 500ms
- `Rx<Future<>>` for async future handling

### Screen Pattern (from lab_test_list_screen.dart)
- `StatefulWidget` with late controller init via `Get.put()`
- `AppScaffoldNew` wrapper, `Obx()` reactive bindings
- `AnimatedScrollView` with `onNextPage`/`onSwipeRefresh`
- `SnapHelperWidget` for future loading states

### API Pattern (from core_apis.dart)
- `buildHttpResponse()` for GET/POST
- `buildMultiPartResponse()` for file uploads (multipart/form-data)
- `handleResponse()` for JSON parsing
- Pagination via query string construction

## Decisions

### D1: File Upload Approach
- **Decision**: Use existing `buildMultiPartResponse()` from
  `network_utils.dart` for multipart form data.
- **Rationale**: Already used for profile image uploads. Supports
  multiple file attachments.
- **Alternatives**: Base64 encoding — rejected (larger payload,
  server expects multipart).

### D2: Multi-Section Form UX
- **Decision**: Single scrollable form with collapsible sections,
  not a stepper/wizard.
- **Rationale**: Consistent with create_nurse_request_screen.dart
  pattern. Simpler to implement, allows reviewing all sections
  before submission.
- **Alternatives**: Multi-step wizard — rejected per Constitution
  Principle VII (Simplicity).

### D3: Conditional Validation for Insurance
- **Decision**: Show/hide insurance fields reactively based on
  payment_method selection. Validate insurance_number and
  insurance_provider only when payment_method == "insurance".
- **Rationale**: API contract specifies conditional required fields.

### D4: Department Selection in Admission Form
- **Decision**: After selecting a hospital, optionally select a
  department from that hospital's departments list (loaded inline
  or via dropdown).
- **Rationale**: API makes icu_department_id optional and requires
  it to match the selected hospital_id.

### D5: No New Dependencies
- **Decision**: No new packages needed.
- **Rationale**: Existing packages cover all needs: http for API,
  image_picker/file_picker for uploads, path_provider for file paths.
