# Tasks: Request Service Module

**Input**: Design documents from `/specs/003-request-service-module/`
**Prerequisites**: plan.md (required), spec.md (required), research.md, data-model.md, contracts/

**Tests**: Not requested. Tests are OPTIONAL per constitution.

**Context**: The module is already fully implemented at `lib/screens/request_service/`.
Tasks focus on verifying API contract compliance, ensuring Clinical Elegance
design token usage, validating translations, and confirming dark mode + RTL support.

**Organization**: Tasks grouped by user story for independent verification.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (US1–US2)
- Exact file paths included in descriptions

---

## Phase 1: Setup (Contract & Endpoint Verification)

**Purpose**: Verify API layer matches the backend contract exactly

- [x] T001 Verify both endpoint constants match API contract paths in lib/utils/api_end_points.dart — confirm saveRequestService = 'v1/save-request-service' and getRequestService = 'v1/get-request-service'
- [x] T002 [P] Verify getRequestServiceList() API method in lib/api/core_apis.dart sends correct query params: per_page, page, is_status, search — and handles pagination meta (currentPage, lastPage)
- [x] T003 [P] Verify saveRequestService() API method in lib/api/core_apis.dart sends POST with name, description, type fields — and parses response from json["data"]

**Checkpoint**: Both API methods confirmed to match backend contract

---

## Phase 2: Foundational (Model & Locale Verification)

**Purpose**: Verify model deserializes all API fields and locale keys are complete

- [x] T004 Verify RequestService model in lib/screens/request_service/model/request_service_model.dart has fromJson() mapping for all 12 snake_case API fields: id, name, description, type, status, is_status, created_by, updated_by, deleted_by, created_at, updated_at, deleted_at — plus RequestServiceListResponse with pagination meta (current_page, last_page, per_page, total)
- [x] T005 Verify all request-service locale keys exist in lib/locale/languages.dart abstract class — check for: requestService, myServiceRequests, createServiceRequest, serviceRequestSubmitted, serviceStatusPending, serviceStatusAccepted, serviceStatusRejected, myRequests, fillDetailsBelow, serviceName, quickServices
- [x] T006 [P] Verify all locale keys from T005 have translations in lib/locale/language_en.dart
- [x] T007 [P] Verify all locale keys from T005 have translations in lib/locale/language_ar.dart
- [x] T008 [P] Verify all locale keys from T005 have translations in lib/locale/language_de.dart
- [x] T009 [P] Verify all locale keys from T005 have translations in lib/locale/language_fr.dart
- [x] T010 [P] Verify all locale keys from T005 have translations in lib/locale/language_hi.dart
- [x] T011 Verify status colors exist in lib/utils/colors.dart: serviceStatusPendingColor, serviceStatusAcceptColor, serviceStatusRejectColor
- [x] T012 Verify status constants exist in lib/utils/constants.dart: ServiceRequestStatusConst with pending, accept, reject

**Checkpoint**: Model parses all API fields correctly; all locale keys and constants present

---

## Phase 3: User Story 1 — View My Service Requests (Priority: P1) MVP

**Goal**: Verify request list with search, status filter, and pagination

**Independent Test**: Open Request Service from home, view list, search, filter by status

### Implementation for User Story 1

- [x] T013 [P] [US1] Verify request_service_list_controller.dart fetches via CoreServiceApis.getRequestServiceList() with search debounce (500ms), status filter (pending/accept/reject/all), pagination with isLastPage — all .obs reactive state
- [x] T014 [P] [US1] Verify request_service_list_screen.dart displays request cards with search field, status filter chips, pagination via AnimatedScrollView onNextPage, pull-to-refresh, empty state with CTA to create, "Add" button in app bar — uses AppScaffoldNew, Obx()
- [x] T015 [P] [US1] Verify request_service_card.dart in lib/screens/request_service/components/ shows: name, type with icon (mapped by keyword: nurse/lab/home/emergency/default), description preview, status badge (colored per serviceStatus*Color), creation date — uses Clinical Elegance tokens (16px radius, softShadowColor, surfaceElevated/Dark)
- [x] T016 [US1] Verify home screen integration in lib/screens/home/components/quick_services_component.dart has "Request Service" entry navigating to RequestServiceListScreen via Get.to() with doIfLoggedIn(), plus "My Service Requests" tile

**Checkpoint**: Patient can view request list, search, filter by status

---

## Phase 4: User Story 2 — Create a Service Request (Priority: P2)

**Goal**: Verify create form with name validation and submission

**Independent Test**: Open create form, fill name, submit, verify success

### Implementation for User Story 2

- [x] T017 [P] [US2] Verify create_request_service_controller.dart manages: nameCont, descriptionCont, typeCont TextEditingControllers, submitRequest() validates name is not empty, calls CoreServiceApis.saveRequestService(), shows success toast, navigates back
- [x] T018 [US2] Verify create_request_service_screen.dart has: name field (required, with validation), description field (optional, max 500 chars, multiline), type field (optional), gradient submit button — uses Clinical Elegance tokens (12px input radius, inputFillColor/Dark)
- [x] T019 [US2] Verify request body sent by controller matches API contract: {name: "...", description: "...", type: "..."} — only non-empty fields included
- [x] T020 [US2] Verify error handling preserves form data on API error — catchError shows toast without clearing fields

**Checkpoint**: Patient can create a service request and see it in the list

---

## Phase 5: Polish & Cross-Cutting Concerns

**Purpose**: Design compliance, dark mode, RTL, and static analysis

- [x] T021 [P] Verify all request_service screens use Clinical Elegance design tokens: 16px card radius, 12px input radius, 24px body padding, navy-tinted shadows (softShadowColor) — check list screen, create screen, and card component
- [x] T022 [P] Verify all request_service screens support dark mode: isDarkMode.value checks with surfaceElevated/surfaceElevatedDark, inputFillColor/inputFillColorDark — check all 3 UI files
- [x] T023 [P] Verify Arabic RTL layout works for list and create screens
- [x] T024 Run flutter analyze and confirm zero new warnings in request_service module files
- [x] T025 Run quickstart.md verification: walk through all 4 steps on an Android device/emulator

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies — can start immediately
- **Foundational (Phase 2)**: Can run in parallel with Phase 1
- **User Stories (Phase 3–4)**: Depend on Phase 1 + Phase 2 completion
  - US1 (Phase 3): No story dependencies
  - US2 (Phase 4): No story dependencies (can parallel with US1)
- **Polish (Phase 5)**: Depends on both user stories complete

### Parallel Opportunities

- T002–T003: Both API method verifications in parallel
- T006–T010: All 5 language file verifications in parallel
- T013–T016: Most US1 tasks in parallel
- T017–T020: US2 controller + screen in parallel
- T021–T023: All polish tasks in parallel
- US1 and US2 can run in parallel (different files)

---

## Implementation Strategy

### Full Delivery (Recommended — Module Already Complete)

Since all code exists, run all phases in parallel:
1. Phase 1 + Phase 2 in parallel
2. Phase 3 + Phase 4 in parallel
3. Phase 5 (polish)
4. Final: flutter analyze

### Estimated Scope

All tasks are verification/audit tasks on existing code. This is the
simplest of the three modules — only 6 source files to verify.

---

## Notes

- [P] tasks = different files, no dependencies
- [Story] label maps task to specific user story
- All tasks are verify-and-fix
- No new files to create — module is fully implemented
- No edit/cancel features — simpler than labs and nurse modules
