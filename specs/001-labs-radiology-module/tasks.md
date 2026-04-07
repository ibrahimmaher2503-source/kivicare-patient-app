# Tasks: Labs & Radiology Module

**Input**: Design documents from `/specs/001-labs-radiology-module/`
**Prerequisites**: plan.md (required), spec.md (required), research.md, data-model.md, contracts/

**Tests**: Not requested. Tests are OPTIONAL per constitution.

**Context**: The module is already fully implemented at `lib/screens/lab_test/`.
Tasks focus on verifying API contract compliance, ensuring Clinical Elegance
design token usage, validating translations, and confirming dark mode + RTL support.

**Organization**: Tasks grouped by user story for independent verification.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (US1–US5)
- Exact file paths included in descriptions

---

## Phase 1: Setup (Contract & Endpoint Verification)

**Purpose**: Verify API layer matches the backend contract exactly

- [x] T001 Verify all 8 endpoint constants match API contract paths in lib/utils/api_end_points.dart — confirm getLabTestCategories, getLabTests, getLabTestDetail, getTestOrders, createTestOrder, getTestOrderDetail, cancelTestOrder, downloadTestReport use correct v1/ paths
- [x] T002 [P] Verify getLabTestCategories() API method in lib/api/core_apis.dart parses response as {status, data[]} with LabTestCategoryListResponse
- [x] T003 [P] Verify getLabTestList() API method in lib/api/core_apis.dart sends correct query params: per_page, page, category_id, department, search — and handles pagination meta (current_page, last_page)
- [x] T004 [P] Verify getLabTestDetail() API method in lib/api/core_apis.dart calls GET v1/lab-tests/{id} and returns single LabTest object
- [x] T005 [P] Verify getTestOrderList() API method in lib/api/core_apis.dart sends correct query params: per_page, page, status — and handles pagination meta
- [x] T006 [P] Verify createTestOrder() API method in lib/api/core_apis.dart sends POST with items[].lab_test_id, clinical_notes, priority, doctor_id fields and parses 201 response
- [x] T007 [P] Verify cancelTestOrder() API method in lib/api/core_apis.dart sends POST to v1/test-orders/{id}/cancel with cancellation_reason body field
- [x] T008 [P] Verify downloadTestReport() API method in lib/api/core_apis.dart calls GET v1/test-orders/{id}/report/download and handles binary PDF response

**Checkpoint**: All API methods confirmed to match backend contract

---

## Phase 2: Foundational (Model & Locale Verification)

**Purpose**: Verify models deserialize all API fields and locale keys are complete

- [x] T009 Verify LabTestCategory model in lib/screens/lab_test/model/lab_test_category_model.dart has fromJson() mapping for all snake_case API fields: id, name, slug, description, icon, display_order, test_count, status
- [x] T010 [P] Verify LabTest model in lib/screens/lab_test/model/lab_test_model.dart has fromJson() mapping for all snake_case API fields: id, name, code, slug, category (nested), department, sample_type, description, preparation_instructions, default_price, turnaround_time, status
- [x] T011 [P] Verify TestOrder model in lib/screens/lab_test/model/test_order_model.dart has fromJson() mapping for all snake_case API fields: id, order_number, patient (nested), doctor (nested), lab_technician (nested), items (list), clinical_notes, priority, order_date, status, payment_status, total_amount, discount_amount, final_amount, reports, created_at
- [x] T012 [P] Verify TestOrderItem model in lib/screens/lab_test/model/test_order_model.dart has fromJson() mapping for: id, lab_test (nested), price, status, result_value, result_unit, reference_range, result_status, result_notes, result_date
- [x] T013 Verify all lab-test locale keys exist in lib/locale/languages.dart abstract class — check for: labTests, labTestCategories, labTestDetails, browseLabTests, myTestOrders, createTestOrder, testOrderDetails, selectTests, laboratory, radiology, clinicalNotes, priority, priorityRoutine, priorityUrgent, priorityStat, cancellationReason, downloadReport, reportDownloaded, testOrderCreated, testOrderCancelled, noTestCategoriesAvailable, noTestOrdersFound, sampleType, turnaroundTime, defaultPrice, preparationInstructions, pending, confirmed, sampleCollected, processing, completed, delivered, cancelled, resultNormal, resultAbnormal, resultCritical
- [x] T014 [P] Verify all locale keys from T013 have translations in lib/locale/language_en.dart
- [x] T015 [P] Verify all locale keys from T013 have translations in lib/locale/language_ar.dart
- [x] T016 [P] Verify all locale keys from T013 have translations in lib/locale/language_de.dart
- [x] T017 [P] Verify all locale keys from T013 have translations in lib/locale/language_fr.dart
- [x] T018 [P] Verify all locale keys from T013 have translations in lib/locale/language_hi.dart
- [x] T019 Verify lab status colors exist in lib/utils/colors.dart for all 7 statuses: labStatusPendingColor, labStatusConfirmedColor, labStatusSampleCollectedColor, labStatusProcessingColor, labStatusCompletedColor, labStatusDeliveredColor, labStatusCancelledColor — plus result colors: resultNormalColor, resultAbnormalColor, resultCriticalColor

**Checkpoint**: Models parse all API fields correctly; all locale keys present in all 5 languages

---

## Phase 3: User Story 1 — Browse Lab Test Catalog (Priority: P1) MVP

**Goal**: Verify categories screen, test list with search/filter, and test detail screen

**Independent Test**: Open Labs section from home, browse categories, filter by department, search by name, view test detail

### Implementation for User Story 1

- [x] T020 [P] [US1] Verify lab_test_categories_controller.dart fetches categories via CoreServiceApis.getLabTestCategories() and stores in reactive list with loading state
- [x] T021 [P] [US1] Verify lab_test_categories_screen.dart displays category cards with name, icon, description, test count — uses AppScaffoldNew, Obx(), empty state for no categories
- [x] T022 [P] [US1] Verify lab_test_category_card.dart in lib/screens/lab_test/components/ uses Clinical Elegance design tokens: 16px card radius, navy-tinted shadows (softShadowColor), surfaceElevated/Dark for dark mode
- [x] T023 [US1] Verify lab_test_list_controller.dart implements search with debounce, department filter (laboratory/radiology/all), category filter, pagination with isLastPage tracking — all using .obs reactive state
- [x] T024 [P] [US1] Verify lab_test_list_screen.dart displays test cards with search field, department filter chips, pagination via AnimatedScrollView onNextPage, pull-to-refresh, empty state
- [x] T025 [P] [US1] Verify lab_test_card.dart in lib/screens/lab_test/components/ shows test name, code, department badge, sample type, turnaround time, price — uses Clinical Elegance tokens
- [x] T026 [US1] Verify lab_test_detail_screen.dart displays all test fields: name, code, category, department, sample type, description, preparation instructions, price (via PriceWidget), turnaround time, status — uses locale.value for all text labels
- [x] T027 [US1] Verify home screen integration in lib/screens/home/components/quick_services_component.dart navigates to LabTestCategoriesScreen via Get.to() with doIfLoggedIn() wrapper

**Checkpoint**: Patient can browse categories → filter/search tests → view test details (3 taps from home)

---

## Phase 4: User Story 2 — Place a Lab Test Order (Priority: P2)

**Goal**: Verify order creation form with test selection, clinical notes, priority, and submission

**Independent Test**: Select tests from catalog, fill order form, submit, verify confirmation

### Implementation for User Story 2

- [x] T028 [P] [US2] Verify create_test_order_controller.dart manages selected tests list (.obs), clinical notes, priority selection (routine/urgent/stat), and submitOrder() method that calls CoreServiceApis.createTestOrder()
- [x] T029 [US2] Verify create_test_order_screen.dart has: test selection UI (add/remove tests), clinical notes text field (max 2000 chars), priority selector (3 options with gradient active state), order summary with total amount, submit button disabled when no tests selected
- [x] T030 [US2] Verify order submission request body matches API contract: items[].lab_test_id, clinical_notes, priority — and handles 201 success response with order confirmation display (order number, items, total)
- [x] T031 [US2] Verify client-side validation: at least 1 test required, clinical notes max 2000 chars — with localized error messages via toast() or inline validation
- [x] T032 [US2] Verify error handling preserves form data on API error — catchError shows toast(locale.value.somethingWentWrong) without clearing selected tests or notes

**Checkpoint**: Patient can select tests, fill form, submit order, see confirmation with order number

---

## Phase 5: User Story 3 — View & Track Orders (Priority: P3)

**Goal**: Verify order list with status filter and order detail with result display

**Independent Test**: Open My Orders, filter by status, tap order, verify detail fields

### Implementation for User Story 3

- [x] T033 [P] [US3] Verify test_order_list_controller.dart fetches orders via CoreServiceApis.getTestOrderList() with status filter and pagination — reactive state with .obs
- [x] T034 [P] [US3] Verify test_order_list_screen.dart displays order cards with status filter chips, pagination via AnimatedScrollView, empty state with CTA to browse tests
- [x] T035 [P] [US3] Verify test_order_card.dart in lib/screens/lab_test/components/ shows order number, date, status badge (colored per labStatus*Color), priority, item count, total amount
- [x] T036 [US3] Verify test_order_detail_screen.dart displays full order details: order number, status badge, patient, doctor, lab technician, clinical notes, priority, order date, payment status, total/discount/final amounts, created_at — all with localized labels
- [x] T037 [US3] Verify test_order_detail_screen.dart displays per-item details: test name, price, individual status, and result fields when available (result_value, result_unit, reference_range, result_status with color, result_notes, result_date)

**Checkpoint**: Patient can view order list, filter by status, see full order details with results

---

## Phase 6: User Story 4 — Cancel a Pending Order (Priority: P4)

**Goal**: Verify cancel button visibility logic and cancellation dialog with reason

**Independent Test**: Open pending/confirmed order, tap cancel, enter reason, confirm cancellation

### Implementation for User Story 4

- [x] T038 [US4] Verify test_order_detail_screen.dart shows cancel button ONLY when order status is "pending" or "confirmed" — hidden for sample_collected, processing, completed, delivered, cancelled
- [x] T039 [US4] Verify cancel button triggers confirmation dialog with text field for cancellation_reason (required, max 500 chars) — uses localized strings (locale.value.cancellationReason)
- [x] T040 [US4] Verify cancel submission calls CoreServiceApis.cancelTestOrder() with {cancellation_reason: "..."} body — on success shows toast and refreshes order detail to reflect "cancelled" status

**Checkpoint**: Patient can cancel pending/confirmed orders with reason; button hidden for other statuses

---

## Phase 7: User Story 5 — Download Test Report (Priority: P5)

**Goal**: Verify download button visibility and PDF download/save/open flow

**Independent Test**: Open completed/delivered order, tap download, verify PDF opens

### Implementation for User Story 5

- [x] T041 [US5] Verify test_order_detail_screen.dart shows download report button ONLY when order status is "completed" or "delivered" — hidden for pending, confirmed, sample_collected, processing, cancelled
- [x] T042 [US5] Verify download flow calls CoreServiceApis.downloadTestReport() with orderId, saves binary PDF to app documents directory (path_provider), and shows progress indicator during download
- [x] T043 [US5] Verify downloaded PDF file is opened with platform viewer or shows toast(locale.value.reportDownloaded) on success — with error handling and retry on network failure

**Checkpoint**: Patient can download and view PDF report for completed orders

---

## Phase 8: Polish & Cross-Cutting Concerns

**Purpose**: Design compliance, dark mode, RTL, and static analysis

- [x] T044 [P] Verify all lab_test screens use Clinical Elegance design tokens: 16px card radius (BorderRadius.circular(16)), 12px input radius, 24px body padding, navy-tinted shadows (softShadowColor) — check all 6 screen files in lib/screens/lab_test/
- [x] T045 [P] Verify all lab_test screens support dark mode: use isDarkMode.value checks with surfaceElevated/surfaceElevatedDark, inputFillColor/inputFillColorDark — check all 6 screen files and 3 component files
- [x] T046 [P] Verify Arabic RTL layout works for all lab_test screens: text alignment, icon positions, padding direction — spot-check categories, list, and detail screens
- [x] T047 [P] Verify zero-price tests display "Free" instead of 0.00 in lab_test_card.dart and test_order_detail_screen.dart
- [x] T048 Run flutter analyze and confirm zero new warnings introduced by lab_test module files
- [x] T049 Run quickstart.md verification: walk through all 7 verification steps manually on an Android device/emulator

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies — can start immediately
- **Foundational (Phase 2)**: Can run in parallel with Phase 1
- **User Stories (Phase 3–7)**: Depend on Phase 1 + Phase 2 completion
  - US1 (Phase 3): No story dependencies
  - US2 (Phase 4): No story dependencies (can parallel with US1)
  - US3 (Phase 5): No story dependencies (can parallel with US1/US2)
  - US4 (Phase 6): No story dependencies (can parallel)
  - US5 (Phase 7): No story dependencies (can parallel)
- **Polish (Phase 8)**: Depends on all user stories complete

### Within Each User Story

- Controller verification before screen verification
- Component verification can parallel with screen verification
- All [P] tasks within a phase can run simultaneously

### Parallel Opportunities

- T002–T008: All API method verifications can run in parallel
- T009–T012: All model verifications can run in parallel
- T014–T018: All language file verifications can run in parallel
- T020–T027: Most US1 tasks can run in parallel (except T026 depends on model verification)
- T044–T047: All polish tasks can run in parallel
- US1–US5 story phases can run in parallel (different screen files)

---

## Parallel Example: Phase 2 (Foundational)

```bash
# Launch all model verifications together:
Task: "Verify LabTestCategory model fromJson() in lib/screens/lab_test/model/lab_test_category_model.dart"
Task: "Verify LabTest model fromJson() in lib/screens/lab_test/model/lab_test_model.dart"
Task: "Verify TestOrder model fromJson() in lib/screens/lab_test/model/test_order_model.dart"
Task: "Verify TestOrderItem model fromJson() in lib/screens/lab_test/model/test_order_model.dart"

# Launch all locale verifications together:
Task: "Verify locale keys in lib/locale/language_en.dart"
Task: "Verify locale keys in lib/locale/language_ar.dart"
Task: "Verify locale keys in lib/locale/language_de.dart"
Task: "Verify locale keys in lib/locale/language_fr.dart"
Task: "Verify locale keys in lib/locale/language_hi.dart"
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup (endpoint verification)
2. Complete Phase 2: Foundational (model + locale verification)
3. Complete Phase 3: User Story 1 (browse catalog)
4. **STOP and VALIDATE**: Test browsing flow end-to-end
5. Proceed to remaining stories

### Full Delivery (Recommended — Module Already Complete)

Since all code exists, run all verification phases in parallel:
1. Phase 1 + Phase 2 in parallel (setup + foundational)
2. Phase 3–7 in parallel (all user stories — different files)
3. Phase 8 (polish — cross-cutting)
4. Final: flutter analyze + quickstart.md walkthrough

### Estimated Scope

All tasks are verification/audit tasks on existing code. Fixes are
applied inline when discrepancies are found. No new files to create.

---

## Notes

- [P] tasks = different files, no dependencies
- [Story] label maps task to specific user story
- All tasks are verify-and-fix: read existing code, compare to contract, fix if needed
- No new files to create — module is fully implemented
- Commit after each phase or logical group of fixes
- Stop at any checkpoint to validate story independently
