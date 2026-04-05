# Tasks: Nurse Request Module

**Input**: Design documents from `/specs/002-nurse-request-module/`
**Prerequisites**: plan.md (required), spec.md (required), research.md, data-model.md, contracts/

**Tests**: Not requested. Tests are OPTIONAL per constitution.

**Context**: The module is already fully implemented at `lib/screens/nurse/`.
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

- [x] T001 Verify all 7 endpoint constants match API contract paths in lib/utils/api_end_points.dart — confirm getNurses, getNurseDetail, getNurseRequests, createNurseRequest, getNurseRequestDetail, updateNurseRequest, cancelNurseRequest use correct v1/ paths
- [x] T002 [P] Verify getNurseList() API method in lib/api/core_apis.dart sends correct query params: per_page, page, availability_status, service_area, specialization, search — and handles pagination meta
- [x] T003 [P] Verify getNurseDetail() API method in lib/api/core_apis.dart calls GET v1/nurses/{nurseId} using the User ID and returns single Nurse object
- [x] T004 [P] Verify getNurseRequestList() API method in lib/api/core_apis.dart sends correct query params: per_page, page, status, search — and handles pagination meta
- [x] T005 [P] Verify createNurseRequest() API method in lib/api/core_apis.dart sends POST with service_description, preferred_date, preferred_time, duration_hours, address fields, contact_number, patient_notes, nurse_id — and parses 201 response
- [x] T006 [P] Verify updateNurseRequest() API method in lib/api/core_apis.dart sends PUT to v1/nurse-requests/{id} with same fields as create — and parses response
- [x] T007 [P] Verify cancelNurseRequest() API method in lib/api/core_apis.dart sends POST to v1/nurse-requests/{id}/cancel with cancellation_reason body field (not 'reason')

**Checkpoint**: All API methods confirmed to match backend contract

---

## Phase 2: Foundational (Model & Locale Verification)

**Purpose**: Verify models deserialize all API fields and locale keys are complete

- [x] T008 Verify Nurse model in lib/screens/nurse/model/nurse_model.dart has fromJson() mapping for all 17 snake_case API fields: id, nurse_id, name, first_name, last_name, email, mobile, specialization, experience, about, hourly_rate, availability_status, service_area, profile_image, status, created_at, updated_at — plus NurseListResponse with pagination meta
- [x] T009 [P] Verify NurseRequest model in lib/screens/nurse/model/nurse_request_model.dart has fromJson() mapping for all 19 fields: id, patient (nested NurseRequestPatient), nurse (nested NurseRequestNurse), service_description, request_date, preferred_date, preferred_time, duration_hours, address (nested NurseRequestAddress with 8 fields), contact_number, status, payment_status, total_amount, patient_notes, admin_notes, cancelled_by, cancellation_reason, created_at, updated_at
- [x] T010 [P] Verify NurseRequestAddress nested model maps all 8 fields: address_line_1, address_line_2, city, state, country, postal_code, latitude, longitude, full_address
- [x] T011 Verify all nurse locale keys exist in lib/locale/languages.dart abstract class — check for: requestNurse, nurses, nurseDetails, browseNurses, myNurseRequests, createNurseRequest, editNurseRequest, selectNurse, nurseAvailable, nurseBusy, nurseOffDuty, nurseRequestSubmitted, nurseRequestUpdated, nurseRequestCancelled, nurseRequestPending, nurseRequestConfirmed, nurseRequestInProgress, nurseRequestCompleted, noNurseRequestsYet, hours, adminNotes
- [x] T012 [P] Verify all locale keys from T011 have translations in lib/locale/language_en.dart
- [x] T013 [P] Verify all locale keys from T011 have translations in lib/locale/language_ar.dart
- [x] T014 [P] Verify all locale keys from T011 have translations in lib/locale/language_de.dart
- [x] T015 [P] Verify all locale keys from T011 have translations in lib/locale/language_fr.dart
- [x] T016 [P] Verify all locale keys from T011 have translations in lib/locale/language_hi.dart
- [x] T017 Verify nurse status colors exist in lib/utils/colors.dart: nurseStatusPendingColor, nurseStatusConfirmedColor, nurseStatusInProgressColor, nurseStatusCompletedColor, nurseStatusCancelledColor — plus availability colors: nurseAvailableColor, nurseBusyColor, nurseOffDutyColor
- [x] T018 Verify nurse status/availability constants exist in lib/utils/constants.dart: NurseRequestStatusConst (pending, confirmed, inProgress, completed, cancelled) and NurseAvailabilityConst (available, busy, offDuty)

**Checkpoint**: Models parse all API fields correctly; all locale keys and constants present

---

## Phase 3: User Story 1 — Browse Available Nurses (Priority: P1) MVP

**Goal**: Verify nurse list with search/filter and nurse detail profile screen

**Independent Test**: Open Nurse section from home, browse list, filter by availability, search, view nurse profile

### Implementation for User Story 1

- [x] T019 [P] [US1] Verify nurse_list_controller.dart fetches via CoreServiceApis.getNurseList() with search debounce, availability filter, service area filter, specialization filter, pagination with isLastPage — all .obs reactive state
- [x] T020 [P] [US1] Verify nurse_list_screen.dart displays nurse cards with search field, availability filter chips, pagination via AnimatedScrollView onNextPage, pull-to-refresh, empty state — uses AppScaffoldNew, Obx()
- [x] T021 [P] [US1] Verify nurse_card.dart in lib/screens/nurse/components/ shows name, profile image, specialization, experience, hourly rate, availability badge (colored per nurseAvailable/Busy/OffDuty colors), service area — uses Clinical Elegance tokens (16px radius, softShadowColor)
- [x] T022 [US1] Verify nurse_detail_screen.dart displays all nurse fields: name, profile image (with fallback placeholder), specialization, experience, about, hourly rate, availability status, service area, email, mobile — uses locale.value for all labels, has "Request Nurse" action button
- [x] T023 [US1] Verify home screen integration in lib/screens/home/components/quick_services_component.dart has "Request Nurse" entry navigating to NurseListScreen via Get.to() with doIfLoggedIn()

**Checkpoint**: Patient can browse nurses, search/filter, view full profile (3 taps from home)

---

## Phase 4: User Story 2 — Create a Nurse Request (Priority: P2)

**Goal**: Verify request creation form with all fields, validation, total calculation, and submission

**Independent Test**: Fill request form, submit, verify confirmation with calculated total

### Implementation for User Story 2

- [x] T024 [P] [US2] Verify create_nurse_request_controller.dart manages: 12 TextEditingControllers for form fields, nurse selection state, priority defaults, submitOrder() calling CoreServiceApis.createNurseRequest() — builds request body with address fields as flat keys (address_line_1, city, etc.), includes nurse_id if selected
- [x] T025 [US2] Verify create_nurse_request_screen.dart in create mode has: nurse selector (optional), service description field (max 1000), preferred date picker (today or later), preferred time picker, duration hours input (1-24), address form (line 1 required, line 2, city required, state, country, postal code), contact number (required, max 20), patient notes (optional), total display when nurse selected
- [x] T026 [US2] Verify client-side validation: service_description required max 1000, preferred_date required and >= today, duration_hours required min 1 max 24, address_line_1 required max 255, city required max 100, contact_number required max 20 — with localized error messages
- [x] T027 [US2] Verify total calculation display: if nurse is selected, show hourly_rate x duration_hours as estimated total. If no nurse, show "To be determined" or equivalent localized text
- [x] T028 [US2] Verify error handling preserves form data on API error — catchError shows toast without clearing form fields

**Checkpoint**: Patient can fill form, see calculated total, submit, see confirmation

---

## Phase 5: User Story 3 — View & Track Nurse Requests (Priority: P3)

**Goal**: Verify request list with status filter and request detail with all fields

**Independent Test**: Open My Nurse Requests, filter by status, tap request, verify detail

### Implementation for User Story 3

- [x] T029 [P] [US3] Verify nurse_request_list_controller.dart fetches via CoreServiceApis.getNurseRequestList() with status filter (5 statuses + all), pagination — .obs reactive state
- [x] T030 [P] [US3] Verify nurse_request_list_screen.dart displays request cards with status filter chips, pagination via AnimatedScrollView, empty state with CTA to browse nurses, FAB or action for "Create New"
- [x] T031 [P] [US3] Verify nurse_request_card.dart in lib/screens/nurse/components/ shows service description, preferred date, status badge (colored per nurseStatus*Color), nurse name (if assigned), total amount, progress indicator
- [x] T032 [US3] Verify nurse_request_detail_screen.dart displays all fields: service description, nurse info (name, specialization), preferred date/time, duration hours, full address (all address fields), contact number, status badge, payment status, total amount, patient notes, admin notes, cancelled_by, cancellation_reason (if cancelled), created_at, updated_at — all with localized labels
- [x] T033 [US3] Verify home screen has "My Nurse Requests" entry navigating to NurseRequestListScreen via Get.to() with doIfLoggedIn()

**Checkpoint**: Patient can view request list, filter by status, see full request details

---

## Phase 6: User Story 4 — Edit a Pending Request (Priority: P4)

**Goal**: Verify edit button visibility and pre-filled edit form

**Independent Test**: Open pending request, tap edit, modify fields, save, verify updates

### Implementation for User Story 4

- [x] T034 [US4] Verify nurse_request_detail_screen.dart shows "Edit" button ONLY when request status is "pending" — hidden for confirmed, in_progress, completed, cancelled
- [x] T035 [US4] Verify edit navigation passes existing request data to create_nurse_request_screen.dart in edit mode — controller's initForEdit() pre-fills all form fields with current values
- [x] T036 [US4] Verify create_nurse_request_controller.dart in edit mode calls CoreServiceApis.updateNurseRequest() with PUT method — same field validation as create, on success shows toast and navigates back

**Checkpoint**: Patient can edit pending requests; edit hidden for other statuses

---

## Phase 7: User Story 5 — Cancel a Request (Priority: P5)

**Goal**: Verify cancel button visibility and cancellation dialog with user-typed reason

**Independent Test**: Open pending/confirmed request, tap cancel, enter reason, confirm

### Implementation for User Story 5

- [x] T037 [US5] Verify nurse_request_detail_screen.dart shows cancel button ONLY when status is "pending" or "confirmed" — hidden for in_progress, completed, cancelled
- [x] T038 [US5] Verify cancel button triggers dialog with text input field for cancellation_reason (required, max 500 chars) — uses locale.value.cancellationReason label. Must NOT use hardcoded reason — user MUST type their own
- [x] T039 [US5] Verify cancel submission calls CoreServiceApis.cancelNurseRequest() with {cancellation_reason: "user-typed-text"} body — on success shows toast and refreshes detail to reflect "cancelled" status

**Checkpoint**: Patient can cancel pending/confirmed requests with reason; button hidden for other statuses

---

## Phase 8: Polish & Cross-Cutting Concerns

**Purpose**: Design compliance, dark mode, RTL, and static analysis

- [x] T040 [P] Verify all nurse screens use Clinical Elegance design tokens: 16px card radius (BorderRadius.circular(16)), 12px input radius, 24px body padding, navy-tinted shadows (softShadowColor) — check all 6 screen files in lib/screens/nurse/
- [x] T041 [P] Verify all nurse screens support dark mode: isDarkMode.value checks with surfaceElevated/surfaceElevatedDark, inputFillColor/inputFillColorDark — check all 6 screen files and 2 component files
- [x] T042 [P] Verify Arabic RTL layout works for all nurse screens: text alignment, icon positions, padding direction — spot-check list, detail, and form screens
- [x] T043 [P] Verify nurse with no profile image displays default avatar placeholder in nurse_card.dart and nurse_detail_screen.dart
- [x] T044 [P] Verify zero total (no nurse selected) displays "To be determined" localized text in create_nurse_request_screen.dart and nurse_request_detail_screen.dart
- [x] T045 Run flutter analyze and confirm zero new warnings introduced by nurse module files
- [x] T046 Run quickstart.md verification: walk through all 7 verification steps manually on an Android device/emulator

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies — can start immediately
- **Foundational (Phase 2)**: Can run in parallel with Phase 1
- **User Stories (Phase 3–7)**: Depend on Phase 1 + Phase 2 completion
  - US1 (Phase 3): No story dependencies
  - US2 (Phase 4): No story dependencies (can parallel with US1)
  - US3 (Phase 5): No story dependencies (can parallel)
  - US4 (Phase 6): No story dependencies (can parallel)
  - US5 (Phase 7): No story dependencies (can parallel)
- **Polish (Phase 8)**: Depends on all user stories complete

### Within Each User Story

- Controller verification before screen verification
- Component verification can parallel with screen verification
- All [P] tasks within a phase can run simultaneously

### Parallel Opportunities

- T002–T007: All API method verifications in parallel
- T008–T010: All model verifications in parallel
- T012–T016: All language file verifications in parallel
- T019–T023: Most US1 tasks in parallel
- T040–T044: All polish tasks in parallel
- US1–US5 story phases can run in parallel (different screen files)

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup (endpoint verification)
2. Complete Phase 2: Foundational (model + locale verification)
3. Complete Phase 3: User Story 1 (browse nurses)
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
- **CRITICAL from labs experience**: Verify cancel dialog has user text input (not hardcoded reason)
