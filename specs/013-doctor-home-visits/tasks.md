# Tasks: Doctor Home Visit Requests

**Input**: Design documents from `/specs/013-doctor-home-visits/`
**Prerequisites**: plan.md (required), spec.md (required), research.md, data-model.md, contracts/

**Tests**: Included — constitution recommends testing for healthcare patient data features (Principle VI).

**Organization**: Tasks grouped by user story for independent implementation and testing.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)
- Include exact file paths in descriptions

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Create feature directory structure, register API endpoints, add localization keys

- [x] T001 Create feature directory structure: `lib/screens/doctor_visit/`, `lib/screens/doctor_visit/model/`, `lib/screens/doctor_visit/components/`
- [x] T002 [P] Add 5 doctor visit API endpoint constants to `lib/utils/api_end_points.dart` — `doctorVisitRequests`, `doctorVisitRequestDetail(String reference)`, `adminDoctorVisitRequests`, `adminDoctorVisitRequestStatus(String reference)`, `adminDoctorVisitRequestAssignDoctor(String reference)` per contracts/api-contracts.md
- [x] T003 [P] Add ~20 localization keys to `lib/locale/languages.dart` (abstract getters), `lib/locale/language_en.dart` (English), and `lib/locale/language_ar.dart` (Arabic) — feature labels (`doctorHomeVisit`, `visitRequests`, `submitVisitRequest`), form labels (`visitReason`, `preferredDate`, `contactPhone`, `preferredDoctor`, `additionalNotes`), status labels (`statusPending`, `statusConfirmed`, `statusCancelled`, `statusCompleted`), messages (`visitRequestSubmitted`, `visitRequestUpdated`, `noVisitRequests`), admin labels (`assignDoctor`, `updateStatus`, `cancellationReason`, `adminNotes`)

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Model classes and shared components that ALL user stories depend on

**CRITICAL**: No user story work can begin until this phase is complete

- [x] T004 Create all model classes in `lib/screens/doctor_visit/model/doctor_visit_request_model.dart` — `DoctorSummary` (id, name), `PatientSummary` (id, name, email), `DoctorVisitRequest` (14 fields with fromJson/toJson per data-model.md), `DoctorVisitRequestListResponse` (paginated wrapper with meta) — follow existing patterns: `?? defaultValue` for null safety, `is Map`/`is List` checks before nested deserialization, camelCase Dart properties mapping to snake_case JSON keys
- [x] T005 [P] Create `DoctorVisitStatusBadge` widget in `lib/screens/doctor_visit/components/doctor_visit_status_badge.dart` — color-coded badge for pending (amber), confirmed (blue), cancelled (red), completed (green) statuses, following pattern from existing `test_order_status_badge.dart`, using localized status labels via `locale.value`

**Checkpoint**: Models and shared components ready — user story implementation can begin

---

## Phase 3: User Story 1 — Patient Submits a Home Visit Request (Priority: P1) MVP

**Goal**: A patient fills out a form (visit reason, preferred date, contact phone, optional preferred doctor, optional notes) and submits a home visit request, receiving a confirmation with reference number.

**Independent Test**: Fill out the visit request form, submit it, verify a reference number is returned with status "pending".

### Implementation for User Story 1

- [x] T006 [US1] Add `submitDoctorVisitRequest` API method to `lib/api/core_apis.dart` — POST to `APIEndPoints.doctorVisitRequests` with request body map, return `DoctorVisitRequest.fromJson()`, follow existing `buildHttpResponse()` -> `handleResponse()` pattern
- [x] T007 [US1] Create `DoctorVisitRequestController` in `lib/screens/doctor_visit/doctor_visit_request_controller.dart` — extends `GetxController`, manages form state with `TextEditingController` for visitReason/contactPhone/additionalNotes, `Rx<DateTime?>` for preferredDate, `RxnInt` for preferredDoctorId, `RxBool isLoading`, `GlobalKey<FormState> formKey`, client-side validation (required fields, date >= today, max lengths per FR-001 through FR-006), `submitRequest()` method that calls API and navigates on success, `loadDoctors()` method reusing existing `getDoctorList` endpoint for preferred doctor picker
- [x] T008 [US1] Create `DoctorVisitRequestScreen` in `lib/screens/doctor_visit/doctor_visit_request_screen.dart` — StatefulWidget using `AppScaffold`, Form with: TextFormField for visit reason (max 1000, required), date picker field using `showDatePicker(firstDate: DateTime.now(), lastDate: DateTime.now().add(Duration(days: 90)))`, TextFormField for contact phone (max 20, required, pre-filled from `loginUserData.value.mobileNumber`), dropdown for preferred doctor (optional, populated from getDoctorList), TextFormField for additional notes (max 2000, optional), submit button with loading state, success toast with reference number on completion

**Checkpoint**: Patient can submit a visit request and receive confirmation. US1 is independently testable.

---

## Phase 4: User Story 2 — Patient Views Their Visit Requests (Priority: P1)

**Goal**: A patient sees a paginated list of their visit requests (most recent first) and can tap into any request to see full details.

**Independent Test**: Open visit requests list, verify pagination works, tap a request to see full detail including all fields.

### Implementation for User Story 2

- [x] T009 [P] [US2] Add `getDoctorVisitRequests` API method to `lib/api/core_apis.dart` — GET `APIEndPoints.doctorVisitRequests` with page/perPage query params, return paginated list, handle `lastPageCallBack` for infinite scroll per existing pattern
- [x] T010 [P] [US2] Add `getDoctorVisitRequestDetail` API method to `lib/api/core_apis.dart` — GET `APIEndPoints.doctorVisitRequestDetail(reference)`, return single `DoctorVisitRequest`, handle 403 (access denied) and 404 (not found)
- [x] T011 [P] [US2] Create `DoctorVisitCard` widget in `lib/screens/doctor_visit/components/doctor_visit_card.dart` — displays reference number, visit reason (truncated), preferred date, status badge, preferred/assigned doctor name, created_at formatted with intl; onTap navigates to detail screen; follows card styling with 16px radius per design tokens
- [x] T012 [US2] Create `DoctorVisitListController` in `lib/screens/doctor_visit/doctor_visit_list_controller.dart` — extends `GetxController`, manages `RxList<DoctorVisitRequest> requests`, `RxBool isLoading`, `RxInt page = 1`, `RxBool isLastPage = false`, `loadRequests()` with pagination, `refreshRequests()` for pull-to-refresh, calls `getDoctorVisitRequests` API method
- [x] T013 [US2] Create `DoctorVisitListScreen` in `lib/screens/doctor_visit/doctor_visit_list_screen.dart` — uses `AppScaffold` with title from `locale.value.visitRequests`, ListView.builder with `DoctorVisitCard` items, pull-to-refresh, infinite scroll pagination, empty state with `locale.value.noVisitRequests`, FAB or appbar action to navigate to `DoctorVisitRequestScreen` for new submission, `LoaderWidget` for loading state
- [x] T014 [US2] Create `DoctorVisitDetailController` in `lib/screens/doctor_visit/doctor_visit_detail_controller.dart` — extends `GetxController`, accepts `String referenceNumber` parameter, `Rx<DoctorVisitRequest?> request`, `RxBool isLoading`, `loadDetail()` calling `getDoctorVisitRequestDetail`, error handling for 403/404
- [x] T015 [US2] Create `DoctorVisitDetailScreen` in `lib/screens/doctor_visit/doctor_visit_detail_screen.dart` — uses `AppScaffold`, displays all fields: reference number, status badge, visit reason, preferred date (formatted), contact phone, additional notes, preferred doctor, assigned doctor, admin notes, cancellation reason (if cancelled), completed_at (if completed), created_at; uses `Obx()` for reactive updates; `LoaderWidget` while loading

**Checkpoint**: Patient can list and view details of their visit requests. US2 is independently testable.

---

## Phase 5: User Story 3 — Admin Lists and Filters Visit Requests (Priority: P2)

**Goal**: Admin/receptionist/doctor users see all patient visit requests with filtering by status, date range, and assigned doctor.

**Independent Test**: Log in as admin, open admin visit requests list, verify all requests show with patient details, apply filters and confirm results update.

**Dependencies**: Reuses `DoctorVisitListController` and `DoctorVisitListScreen` from US2 (extended with admin mode)

### Implementation for User Story 3

- [x] T016 [US3] Add `getAdminDoctorVisitRequests` API method to `lib/api/core_apis.dart` — GET `APIEndPoints.adminDoctorVisitRequests` with query params: status, date_from, date_to, assigned_doctor_id, page, per_page; return paginated list with patient details
- [x] T017 [US3] Extend `DoctorVisitListController` in `lib/screens/doctor_visit/doctor_visit_list_controller.dart` — add `RxBool isAdminMode` (derived from `loginUserData.value.userRole`), add filter observables: `RxnString selectedStatus`, `Rx<DateTime?> dateFrom`, `Rx<DateTime?> dateTo`, `RxnInt assignedDoctorId`, `RxInt activeFilterCount` computed getter, `applyFilters()` method that reloads with filter params, `clearFilters()` method; when admin mode, call `getAdminDoctorVisitRequests` instead of patient endpoint
- [x] T018 [US3] Extend `DoctorVisitListScreen` in `lib/screens/doctor_visit/doctor_visit_list_screen.dart` — add filter bar (visible only in admin mode): status dropdown (pending/confirmed/cancelled/completed), date range picker (from/to), assigned doctor picker; filter count badge; `DoctorVisitCard` shows patient name when in admin mode; role check using `loginUserData.value.userRole` to determine admin vs. patient view

**Checkpoint**: Admin users can see and filter all visit requests. US3 is independently testable.

---

## Phase 6: User Story 4 — Admin Updates Visit Request Status (Priority: P2)

**Goal**: Admin/receptionist can update a visit request's status to confirmed, cancelled, or completed, with optional notes and cancellation reason.

**Independent Test**: Open a pending request as admin, change status to confirmed with a note, verify status updates. Cancel a request with a reason, verify cancellation reason is stored.

**Dependencies**: Extends detail screen from US2

### Implementation for User Story 4

- [x] T019 [US4] Add `updateDoctorVisitRequestStatus` API method to `lib/api/core_apis.dart` — PUT to `APIEndPoints.adminDoctorVisitRequestStatus(reference)` with request body: status, cancellation_reason (optional), note (optional); return updated `DoctorVisitRequest`
- [x] T020 [US4] Extend `DoctorVisitDetailController` in `lib/screens/doctor_visit/doctor_visit_detail_controller.dart` — add `updateStatus(String newStatus, {String? cancellationReason, String? note})` method, validate status transitions client-side (pending->confirmed/cancelled, confirmed->completed/cancelled), reload detail after success, show toast on success/error
- [x] T021 [US4] Extend `DoctorVisitDetailScreen` in `lib/screens/doctor_visit/doctor_visit_detail_screen.dart` — add admin action buttons section (visible only for admin/receptionist/assigned-doctor roles): "Confirm" button (when pending), "Complete" button (when confirmed), "Cancel" button (when pending or confirmed) that shows dialog for cancellation reason and optional note; buttons disabled for invalid transitions; use `locale.value` for all button labels

**Checkpoint**: Admin users can manage visit request lifecycle. US4 is independently testable.

---

## Phase 7: User Story 5 — Admin Assigns a Doctor to a Visit Request (Priority: P2)

**Goal**: Admin/receptionist assigns a doctor to a visit request. Doctors cannot self-assign.

**Independent Test**: Open a request as admin, assign a doctor, verify assigned doctor appears in detail. Try as doctor role, verify assignment action is hidden.

**Dependencies**: Extends detail screen from US2

### Implementation for User Story 5

- [x] T022 [US5] Add `assignDoctorToVisitRequest` API method to `lib/api/core_apis.dart` — PUT to `APIEndPoints.adminDoctorVisitRequestAssignDoctor(reference)` with request body: `{ "doctor_id": int }`, return updated `DoctorVisitRequest`
- [x] T023 [US5] Extend `DoctorVisitDetailController` in `lib/screens/doctor_visit/doctor_visit_detail_controller.dart` — add `assignDoctor(int doctorId)` method, `RxList doctors` for doctor picker populated via existing `getDoctorList` endpoint, reload detail after success
- [x] T024 [US5] Extend `DoctorVisitDetailScreen` in `lib/screens/doctor_visit/doctor_visit_detail_screen.dart` — add "Assign Doctor" button (visible only for admin/receptionist roles, hidden for doctor role per FR-019), shows bottom sheet with doctor list picker, displays currently assigned doctor with option to reassign

**Checkpoint**: Admin/receptionist can assign doctors to visit requests. US5 is independently testable.

---

## Phase 8: Polish & Cross-Cutting Concerns

**Purpose**: Dashboard integration, testing, and final verification

- [x] T025 Add doctor visit entry point to home screen — add "Doctor Home Visit" tile to Quick Services or My Requests section in appropriate `lib/screens/home/` component, with navigation to `DoctorVisitListScreen`, gated by `doIfLoggedIn()`, using `locale.value.doctorHomeVisit` label
- [ ] T026 [P] Create unit test for model serialization in `test/unit/models/doctor_visit_request_model_test.dart` — test DoctorVisitRequest.fromJson with complete JSON, test with null optional fields, test DoctorVisitRequestListResponse.fromJson with pagination meta, test toJson for submit request body
- [ ] T027 [P] Create integration test for request submission flow in `test/integration/doctor_visit_request_flow_test.dart` — mock API responses, test form validation (required fields, date in past), test successful submission, test list loading and pagination, test detail view
- [x] T028 Run `flutter analyze` and fix any new warnings introduced by this feature
- [ ] T029 Run quickstart.md verification steps — manual testing on Android + one additional platform (iOS or Web)

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies — can start immediately
- **Foundational (Phase 2)**: Depends on Phase 1 (T001 for directory structure) — BLOCKS all user stories
- **US1 (Phase 3)**: Depends on Phase 2 — No dependencies on other stories
- **US2 (Phase 4)**: Depends on Phase 2 — No dependencies on other stories. Can run in parallel with US1.
- **US3 (Phase 5)**: Depends on US2 (extends list controller/screen)
- **US4 (Phase 6)**: Depends on US2 (extends detail controller/screen). Can run in parallel with US3.
- **US5 (Phase 7)**: Depends on US2 (extends detail controller/screen). Can run in parallel with US3 and US4.
- **Polish (Phase 8)**: Depends on all user stories being complete

### User Story Dependencies

```
Phase 1 (Setup) ──► Phase 2 (Foundational) ──┬──► US1 (P1: Submit)
                                              │
                                              ├──► US2 (P1: List/Detail) ──┬──► US3 (P2: Admin List)
                                              │                            │
                                              │                            ├──► US4 (P2: Status Update)
                                              │                            │
                                              │                            └──► US5 (P2: Assign Doctor)
                                              │
                                              └──► Phase 8 (Polish) ◄── all US complete
```

### Within Each User Story

- API methods before controllers
- Controllers before screens
- Shared components before screens that use them
- Core implementation before UI integration

### Parallel Opportunities

- **Phase 1**: T002 and T003 can run in parallel (different files)
- **Phase 2**: T004 and T005 can run in parallel (different files)
- **Phase 3-4**: US1 and US2 can run in parallel after Phase 2 (independent stories)
- **Phase 4**: T009, T010, T011 can all run in parallel (different files)
- **Phase 5-7**: US3, US4, US5 can all run in parallel after US2 (they extend different aspects of the detail/list screens)
- **Phase 8**: T026 and T027 can run in parallel (different test files)

---

## Parallel Example: User Story 2

```
# Launch API methods and card component in parallel (different files):
Task T009: "Add getDoctorVisitRequests API method to lib/api/core_apis.dart"
Task T010: "Add getDoctorVisitRequestDetail API method to lib/api/core_apis.dart"
Task T011: "Create DoctorVisitCard widget in lib/screens/doctor_visit/components/doctor_visit_card.dart"

# Then sequentially: controller → screen (same dependency chain)
Task T012: "Create DoctorVisitListController" (needs T009)
Task T013: "Create DoctorVisitListScreen" (needs T011, T012)
Task T014: "Create DoctorVisitDetailController" (needs T010)
Task T015: "Create DoctorVisitDetailScreen" (needs T014)
```

---

## Implementation Strategy

### MVP First (User Stories 1 + 2 Only)

1. Complete Phase 1: Setup (T001-T003)
2. Complete Phase 2: Foundational (T004-T005)
3. Complete Phase 3: US1 — Submit Request (T006-T008)
4. Complete Phase 4: US2 — List/Detail View (T009-T015)
5. **STOP and VALIDATE**: Patient can submit, list, and view visit requests
6. Deploy/demo if ready — this is a functional MVP

### Incremental Delivery

1. Setup + Foundational -> Infrastructure ready
2. US1 (Submit) -> Patients can create requests -> Demo
3. US2 (List/Detail) -> Patients can track requests -> Demo (MVP!)
4. US3 (Admin List) -> Admins can see all requests -> Demo
5. US4 (Status Updates) -> Admins can manage lifecycle -> Demo
6. US5 (Assign Doctor) -> Full admin workflow -> Demo
7. Polish -> Dashboard integration, tests, verification -> Release

### Sequential Execution (Single Developer)

Phase 1 -> Phase 2 -> US1 -> US2 -> US3 -> US4 -> US5 -> Polish

Estimated: 29 tasks total

---

## Notes

- [P] tasks = different files, no dependencies on in-progress tasks
- [Story] label maps task to specific user story for traceability
- US3, US4, US5 extend existing files from US2 (controller/screen) — they add methods and UI sections, not replace
- API methods go in `lib/api/core_apis.dart` per plan ADR (not a new file)
- Reference number (String) used for detail/status/assign endpoints, not numeric id
- All UI strings MUST use `locale.value.<key>` — never hardcode English strings
- Pre-fill contact phone from `loginUserData.value.mobileNumber` in submit form
- Role check: `loginUserData.value.userRole` determines admin vs patient view
