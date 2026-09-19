---
description: "Task list for ICU Admission (Intensive Care) Module implementation"
---

# Tasks: ICU Admission (Intensive Care) Module

**Input**: Design documents from `specs/021-icu-admission-module/`
**Prerequisites**: plan.md ✅, spec.md ✅, research.md ✅, data-model.md ✅, contracts/icu-api.md ✅, quickstart.md ✅
**Branch**: `021-icu-admission-module`

**Tests**: Recommended widget tests are included for the form validators, status timeline, and cancel-eligibility predicate (per Constitution VI — RECOMMENDED for healthcare flows). Other test tasks are omitted unless triggered by complexity.

**Organization**: Tasks are grouped by user story to enable independent implementation and testing.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Different file, no dependencies on incomplete tasks → parallelizable
- **[Story]**: US1 / US2 / US3 / US4 — maps to spec.md user stories
- File paths are absolute from repo root

## Path Conventions

- Source: `lib/screens/icu_admission/` (feature module), plus shared edits in `lib/api/`, `lib/utils/`, `lib/locale/`, `lib/configs.dart`
- Tests: `test/screens/icu_admission/`

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Project-level scaffolding, configuration, and shared constants needed by every user story.

- [x] T001 Create the feature module directory tree under `lib/screens/icu_admission/` with subfolders `components/`, `hospitals/`, `departments/`, `filter/`, `form/`, `form/components/`, `success/`, `requests/`, `requests/components/`, `models/` (empty placeholder `.gitkeep` if needed) — matches plan.md §Project Structure.
- [x] T002 Add the `EMERGENCY_HOTLINE` constant in `lib/configs.dart` (e.g. `const EMERGENCY_HOTLINE = '+20XXXXXXXXXX';`) following the existing `HELP_LINE_NUMBER` pattern (research.md §7).
- [x] T003 Add `lastIcuRequestReferenceKey = 'lastIcuRequestReference'` to `lib/utils/constants.dart` next to existing `SharedPreferenceConst`/`SettingsLocalConst` groups (research.md §5).
- [x] T004 [P] Add the 10 ICU endpoint constants in `lib/utils/api_end_points.dart` exactly matching `contracts/icu-api.md` §1: `icuHospitals`, `icuHospitalDepartments` helper, `icuDepartments`, `icuAdmissionRequests`, plus the path-builder helpers for `/icu-hospitals/{id}`, `/icu-admission-requests/{id}`, `/icu-admission-requests/{id}/cancel`.
- [x] T005 [P] Add ~80 abstract getters for new ICU strings in `lib/locale/languages.dart` (group: hospital list, hospital detail, departments, form labels, urgency labels, status labels, validation messages, success screen, cancel dialog, emergency banner).
- [x] T006 [P] Add English values for every new key in `lib/locale/language_en.dart`.
- [x] T007 [P] Add Arabic values (or English placeholder + `// TODO: translate`) for every new key in `lib/locale/language_ar.dart` (Constitution V).

**Checkpoint**: `flutter analyze` passes with zero new warnings; all locale subclasses implement the new abstract getters. ✅

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Models, the API service, the push-notification deep link, and shared visual components used by every story.

**⚠️ CRITICAL**: No user story phase can begin until this phase completes.

### Models (data-model.md §§2–9)

- [x] T008 [P] Create `Hospital` model in `lib/screens/icu_admission/models/hospital_model.dart` with `fromJson` covering both list-mode and detail-mode shapes from `contracts/icu-api.md` §2/§3.
- [x] T009 [P] Create `IcuDepartment` model in `lib/screens/icu_admission/models/icu_department_model.dart` (handles nullable `availableBeds`/`totalBeds`).
- [x] T010 [P] Create `StatusHistoryEntry` model in `lib/screens/icu_admission/models/status_history_model.dart`.
- [x] T011 [P] Create `AdmissionStatus` and `UrgencyLevel` enums plus their `fromWire`/`toWire` helpers in `lib/screens/icu_admission/models/admission_request_model.dart` (alongside the request class).
- [x] T012 [US1] [US2] [US3] Create `AdmissionRequest` model in `lib/screens/icu_admission/models/admission_request_model.dart` with `fromJson` for both lightweight (list) and full (detail) shapes per contracts §7/§8; include the `canCancel`, `showAdmissionCard`, `showDischargeInfo`, `showCancelOrRejectionBanner` predicates from data-model.md §6 (depends on T008–T011).
- [x] T013 [P] Create `AdmissionRequestFormPayload` (outbound DTO) in `lib/screens/icu_admission/models/admission_request_form_payload.dart` with an explicit `toJson()` that whitelists only the fields in data-model.md §8 (FR-023 enforcement).
- [x] T014 [P] Create `IcuPaginatedResponse<T>` in `lib/screens/icu_admission/models/icu_paginated_response.dart` (envelope: `data`, `currentPage`, `lastPage`, `total`, `hasMore`).

### API service (contracts/icu-api.md §§2–9)

- [x] T015 Create `IcuApis` static service in `lib/api/icu_apis.dart` with methods: `getHospitals(...)`, `getHospitalDetail(int id)`, `getDepartments()`, `getHospitalDepartments(int hospitalId)`, `submitAdmissionRequest(AdmissionRequestFormPayload)`, `getAdmissionRequests({page, status})`, `getAdmissionRequestDetail(int id)`, `cancelAdmissionRequest(int id, String? reason)` — all following `buildHttpResponse() → handleResponse() → Model.fromJson()` per research.md §9 (depends on T004, T008–T014).

### Push-notification deep link (research.md §3)

- [x] T016 In `lib/utils/push_notification_service.dart`, add an `else if (notificationType == 'icu_admission_status_changed')` branch in `handleNotificationClick()` that parses `request_id` and navigates via `Get.to(() => AdmissionRequestDetailScreen(requestId: requestId))` — mirroring the existing `nurse_request_status_changed` pattern at lines 101–107.

### Shared visual components

- [x] T017 [P] Create non-dismissible `EmergencyBanner` in `lib/screens/icu_admission/components/emergency_banner.dart` consuming `EMERGENCY_HOTLINE`, with a `tel:` launcher guarded by `canLaunchUrl` and a clipboard fallback (FR-032..034, research.md §6).
- [x] T018 [P] Create `IcuShimmer` in `lib/screens/icu_admission/components/icu_shimmer.dart` replicating the `LocationShimmer` `AnimatedBuilder` + `LinearGradient` pattern with `shimmerBase`/`shimmerHighlight` color tokens (research.md §2). Expose card-height variants (≈110/90/80px).
- [x] T019 [P] Create `IcuEmptyState` in `lib/screens/icu_admission/components/icu_empty_state.dart` (icon + title + subtitle + retry CTA) using design tokens (`surfaceElevated`, `softShadowColor`).
- [x] T020 [P] Create `StatusChip` in `lib/screens/icu_admission/components/status_chip.dart` mapping each `AdmissionStatus` to a colour from the design tokens, with localised label (depends on T011).
- [x] T021 [P] Create `UrgencyRadioGroup` in `lib/screens/icu_admission/components/urgency_radio_group.dart` with three visually differentiated options (FR-014) and exposes a `ValueChanged<UrgencyLevel>` (depends on T011).

**Checkpoint**: Models compile, `IcuApis` is reachable, shared components render in isolation, push handler routes a synthetic payload to the (still-stub) detail screen. ✅

---

## Phase 3: User Story 1 — Submit ICU Admission Request (Priority: P1) 🎯 MVP

**Goal**: A patient or family member can complete the admission form (with required validation, urgency-critical alert, and hospital→department cascade) and submit it, receiving a unique `ICU-YYYY-NNNN` reference number that survives an app restart.

**Independent Test**: Open the form (deep-linked from any hospital detail), fill required fields, submit, verify the success screen shows a copyable reference number, force-close the app, reopen, and verify the reference is still recoverable from `GetStorage`.

### Recommended widget tests (Constitution VI)

- [x] T022 [P] [US1] Form validator widget test in `test/screens/icu_admission/form/admission_request_form_validators_test.dart` covering: empty required fields (FR-011), 2,000-char limit (FR-013), phone regex `^\+?\d{7,20}$` (FR-018), date in `[today, today+30d]` (FR-019). ✅

### Implementation

- [x] T023 [US1] Create `CriticalUrgencyAlert` widget in `lib/screens/icu_admission/form/components/critical_urgency_alert.dart` — non-blocking dialog/snackbar shown when urgency switches to Critical, offering an emergency-call CTA (FR-015).
- [x] T024 [US1] Create `HospitalLockField` widget in `lib/screens/icu_admission/form/components/hospital_lock_field.dart` — pre-filled hospital display with an explicit "Change" action that opens the hospital picker (FR-017).
- [x] T025 [US1] Create `AdmissionRequestFormController` in `lib/screens/icu_admission/form/admission_request_form_controller.dart` with: reactive controllers for every field in data-model.md §4, `selectedHospital`/`selectedDepartment` `.obs`, cascade logic that clears `selectedDepartment` when `selectedHospital` changes and calls `IcuApis.getHospitalDepartments` (FR-016), validators matching data-model.md §10, `submit()` building `AdmissionRequestFormPayload` and calling `IcuApis.submitAdmissionRequest`, on-success `setValueToLocal(lastIcuRequestReferenceKey, ref)` then `Get.off(AdmissionSuccessScreen(...))` (depends on T015, T013).
- [x] T026 [US1] Create `AdmissionRequestFormScreen` in `lib/screens/icu_admission/form/admission_request_form_screen.dart` rendering all fields with inline validation errors, character counters on the 2,000-char fields (FR-013), `UrgencyRadioGroup`, `HospitalLockField`, date picker bounded to `[today, today+30d]`, Submit button disabled while `isLoading` (depends on T021, T023, T024, T025). Wire `onUrgencyChanged: critical → CriticalUrgencyAlert`.
- [x] T027 [US1] Create `AdmissionSuccessController` in `lib/screens/icu_admission/success/admission_success_controller.dart` exposing the reference number and a `copyToClipboard()` action (FR-021).
- [x] T028 [US1] Create `AdmissionSuccessScreen` in `lib/screens/icu_admission/success/admission_success_screen.dart` — Lottie animation (asset referenced via `lib/generated/assets.dart`), `ReferenceNumberCard`, "Track this request" CTA, `EmergencyBanner` (FR-020..022, research.md §10).
- [x] T029 [P] [US1] Create `ReferenceNumberCard` in `lib/screens/icu_admission/components/reference_number_card.dart` — copyable reference display with `Clipboard.setData` + toast (FR-021).
- [x] T030 [US1] Implement reference recovery: in `IcuDashboardController` (placeholder created in Phase 2 or here if not yet) read `getValueFromLocal(lastIcuRequestReferenceKey)` on init and expose it; surface a "Last reference" affordance on the success screen and dashboard (FR-022, SC-004).
- [x] T031 [US1] Wire FR-023 enforcement: confirm via the `AdmissionRequestFormPayload.toJson()` whitelist that none of `status`, `reference_number`, `assigned_*`, `admitted_at`, `discharged_at`, payment, or commission fields can be sent. Add an inline assertion or comment referencing FR-023 in `admission_request_form_payload.dart`.

**Checkpoint**: User Story 1 is independently shippable — submit flow, success screen, reference persistence, and the critical-urgency alert all work end-to-end against the staging API. ✅

---

## Phase 4: User Story 2 — Browse Hospitals and Find ICU Availability (Priority: P1)

**Goal**: A patient can browse, search, filter (by governorate/city, ICU department type, available beds), and inspect partner hospitals, then launch the admission form with the hospital pre-filled.

**Independent Test**: Open the hospital list, search by partial name (results within ~1s), apply each filter, scroll to load page 2, open a hospital detail, tap "Request ICU Admission Here" — the form opens with that hospital pre-selected and locked (FR-017).

### Implementation

- [x] T032 [US2] Create `HospitalListController` in `lib/screens/icu_admission/hospitals/hospital_list_controller.dart` with: `RxList<Hospital> hospitals`, paging state (`currentPage`, `lastPage`, `isLoadingMore`), `searchTerm.obs` debounced ~400 ms (FR-001), filter state delegated to `HospitalFilterController`, `loadFirstPage()`, `loadNextPage()`, `refresh()`, all calling `IcuApis.getHospitals(...)` (depends on T015).
- [x] T033 [US2] Create `HospitalListScreen` in `lib/screens/icu_admission/hospitals/hospital_list_screen.dart` — search field at top, `FilterButton + FilterCountBadge` opening the filter sheet, `RefreshIndicator` (FR-006), `ListView.builder` with infinite scroll trigger (FR-005), `IcuShimmer` skeleton on first load, `IcuEmptyState` on empty/error, `EmergencyBanner` at top (depends on T017–T019, T032).
- [x] T034 [P] [US2] Create `HospitalCard` in `lib/screens/icu_admission/components/hospital_card.dart` — image, name, governorate/city, "Has available beds" pill, "View" CTA, on-tap navigation to detail.
- [x] T035 [US2] Create `HospitalFilterController` in `lib/screens/icu_admission/filter/hospital_filter_controller.dart` exposing `selectedGovernorateId`, `selectedCityId`, `selectedDepartmentTypeId`, `hasAvailableBedsOnly`, `activeFilterCount` getter, `apply()`/`clear()`. Cascade: changing governorate clears city.
- [x] T036 [US2] Create `HospitalFilterScreen` in `lib/screens/icu_admission/filter/hospital_filter_screen.dart` opening the existing `GovernorateSelectionScreen` and `CitySelectionScreen` from `lib/screens/location_filter/` via callbacks (research.md §4), an ICU department-type dropdown (sourced from `IcuApis.getDepartments`), and a "Show only hospitals with available beds" toggle.
- [x] T037 [US2] Create `HospitalDetailController` in `lib/screens/icu_admission/hospitals/hospital_detail_controller.dart` — fetch via `IcuApis.getHospitalDetail`, expose `Hospital` and loading/error state, `callPhone()` and `callEmergencyPhone()` (`tel:` with `canLaunchUrl` guard + clipboard fallback, FR-008), `openInMaps()` when lat/lng present (FR-010).
- [x] T038 [US2] Create `HospitalDetailScreen` in `lib/screens/icu_admission/hospitals/hospital_detail_screen.dart` — image header, name, address, departments grid (with bed counts), separate "Call Hospital" and "Call Emergency" buttons, "Open in Maps" if coordinates present, prominent "Request ICU Admission Here" CTA → `Get.to(AdmissionRequestFormScreen(initialHospital: ...))`, `EmergencyBanner`, `IcuShimmer` skeleton (FR-007..010, depends on T037).
- [x] T039 [P] [US2] Create `DepartmentChip` in `lib/screens/icu_admission/components/department_chip.dart` — used on the hospital detail and (later) in the filter; shows name + bed badge.

**Checkpoint**: User Story 2 is independently shippable — list, search, filters, detail, and form deep-link all work; combined with US1 a user can discover-and-submit end to end. ✅

---

## Phase 5: User Story 3 — Track and Manage Admission Requests (Priority: P2)

**Goal**: A patient can view all their requests filtered by status, open any request to see status timeline + medical details + assignment info (when admitted/discharged) + cancel reason banner (when applicable), and cancel any Pending or Under Review request.

**Independent Test**: From "My Admission Requests", apply each status filter, open a Pending request, verify the Cancel button is shown; open an Admitted request, verify the assignment card is shown and Cancel is hidden; cancel a Pending request via the dialog and verify the list updates.

### Recommended widget tests (Constitution VI)

- [ ] T040 [P] [US3] Status-timeline widget test in `test/screens/icu_admission/components/status_timeline_test.dart` verifying ordered rendering of `statusHistory` with timestamps and notes.
- [ ] T041 [P] [US3] Cancel-eligibility predicate test in `test/screens/icu_admission/requests/cancel_eligibility_test.dart` — `canCancel` is true only for Pending/Under Review, false for the other 5 states (FR-030).

### Implementation

- [ ] T042 [US3] Create `AdmissionRequestListController` in `lib/screens/icu_admission/requests/admission_request_list_controller.dart` — `RxList<AdmissionRequest> requests`, status filter `.obs` (All + 7 statuses, FR-025), pagination via `IcuApis.getAdmissionRequests`, `refresh()` (depends on T015).
- [ ] T043 [US3] Create `AdmissionRequestListScreen` in `lib/screens/icu_admission/requests/admission_request_list_screen.dart` — horizontally scrolling status filter chips, `ListView.builder` of request cards (status chip + urgency badge + hospital + patient name + preferred date, newest-first per FR-024), `IcuShimmer` skeleton, `IcuEmptyState` for empty filters, `RefreshIndicator`, `EmergencyBanner` (depends on T020, T017–T019, T042).
- [ ] T044 [US3] Create `AdmissionRequestDetailController` in `lib/screens/icu_admission/requests/admission_request_detail_controller.dart` — fetch via `IcuApis.getAdmissionRequestDetail`, expose `request.obs`, `cancel(String? reason)` calling `IcuApis.cancelAdmissionRequest`, refresh-on-pull, surface 409 cancel-conflicts via `toast()` then re-fetch (contracts §9).
- [ ] T045 [US3] Create `StatusTimeline` widget in `lib/screens/icu_admission/components/status_timeline.dart` rendering `statusHistory` as a vertical timeline with localised labels and timestamps (FR-026, depends on T010, T020).
- [ ] T046 [P] [US3] Create `AdmissionCard` widget in `lib/screens/icu_admission/components/admission_card.dart` — room/bed/admitted-date display, only used by detail screen (FR-027).
- [ ] T047 [US3] Create `CancelConfirmationDialog` in `lib/screens/icu_admission/requests/components/cancel_confirmation_dialog.dart` — confirmation copy + optional 500-char reason field with counter, returns `(confirmed: bool, reason: String?)` (FR-031).
- [ ] T048 [US3] Create `AdmissionRequestDetailScreen` in `lib/screens/icu_admission/requests/admission_request_detail_screen.dart` — header (reference number + status chip + urgency badge), `StatusTimeline`, patient/medical sections, conditional `AdmissionCard` (when `showAdmissionCard`), conditional discharge info (when `showDischargeInfo`), conditional reason banner (when `showCancelOrRejectionBanner`), "Cancel Request" button only when `canCancel` opens `CancelConfirmationDialog`, `EmergencyBanner`, pull-to-refresh (FR-026..031, depends on T044–T047).

**Checkpoint**: User Story 3 is independently shippable — full lifecycle visibility and patient-side cancellation work; the deep link from push notifications (T016) lands on the detail screen.

---

## Phase 6: User Story 4 — Browse ICU Department Types (Priority: P3)

**Goal**: A patient who knows the type of care they need (but not a specific hospital) can browse ICU department types with descriptions, and tap one to see all hospitals offering it.

**Independent Test**: Open "Browse ICU Departments", verify each department appears with icon + description, tap one and verify the hospital list opens pre-filtered to that department type.

### Implementation

- [ ] T049 [US4] Create `DepartmentListController` in `lib/screens/icu_admission/departments/department_list_controller.dart` — fetches via `IcuApis.getDepartments`, exposes `RxList<IcuDepartment>` and loading/error state.
- [ ] T050 [US4] Create `DepartmentListScreen` in `lib/screens/icu_admission/departments/department_list_screen.dart` — grid/list of department cards (icon + name + description), on-tap navigates to `HospitalListScreen` with `HospitalFilterController.selectedDepartmentTypeId` pre-set, `EmergencyBanner` (depends on T035, T049).

**Checkpoint**: User Story 4 is independently shippable — department-first discovery path works.

---

## Phase 7: Module Entry & Polish

**Purpose**: ICU dashboard wiring (the patient's first surface of the module) and cross-cutting polish.

- [ ] T051 Create `IcuDashboardController` in `lib/screens/icu_admission/icu_dashboard_controller.dart` exposing the recovered `lastIcuReference` from `GetStorage` (depends on T003) and quick-action handlers.
- [ ] T052 Create `IcuDashboardScreen` in `lib/screens/icu_admission/icu_dashboard_screen.dart` — entry tiles for "Browse Hospitals" → `HospitalListScreen`, "Browse ICU Departments" → `DepartmentListScreen`, "My Admission Requests" → `AdmissionRequestListScreen`, "Submit New Request" → `AdmissionRequestFormScreen`, top-of-screen `EmergencyBanner`, "Last reference: ICU-..." affordance when present (depends on T017, T028, T033, T043, T050, T051).
- [ ] T053 Wire the ICU module into the main app dashboard so users can reach `IcuDashboardScreen` (single tile/route — exact location depends on host dashboard layout; modify only the host dashboard screen file).
- [ ] T054 [P] Run `flutter analyze`; fix any new warnings introduced under `lib/screens/icu_admission/`, `lib/api/icu_apis.dart`, `lib/configs.dart`, `lib/utils/api_end_points.dart`, `lib/utils/constants.dart`, `lib/utils/push_notification_service.dart`, and the `lib/locale/` files until the count is zero (SC-010).
- [ ] T055 [P] Verify Arabic RTL: launch the app in Arabic, walk through dashboard → list → detail → form → success → request list → request detail; fix any truncation, alignment, or missed strings (FR-035, SC-009).
- [ ] T056 [P] Verify dark mode: toggle dark mode, walk the same surfaces; fix any contrast or invisible-text regressions (FR-036).
- [ ] T057 [P] Cross-platform check: run the smoke flow on Android plus iOS-or-Web (Chrome). Confirm `tel:` falls back to "copied to clipboard" toast on Web (Constitution I, research.md §6).
- [ ] T058 Push-notification deep-link verification: send a test FCM payload `{ "type": "icu_admission_status_changed", "request_id": <id> }`; tap → app routes to the request detail (T016).
- [ ] T059 Reference recovery verification: submit a request, force-close within 2s, reopen — reference appears within 5s (SC-004).
- [ ] T060 Run `quickstart.md` end-to-end (all 4 stories' smoke tests + cross-cutting checks) and tick off the per-story Definition of Done in §10.

---

## Dependencies & Execution Order

### Phase Dependencies

- **Phase 1 (Setup)**: No dependencies — start immediately.
- **Phase 2 (Foundational)**: Depends on Phase 1 — BLOCKS all user stories.
- **Phase 3 (US1, P1 — MVP)**: Depends on Phase 2.
- **Phase 4 (US2, P1)**: Depends on Phase 2. Can run in parallel with Phase 3 (different files).
- **Phase 5 (US3, P2)**: Depends on Phase 2. Can run in parallel with Phases 3 & 4.
- **Phase 6 (US4, P3)**: Depends on Phase 2 AND on T035/T036 from Phase 4 (reuses the hospital filter to apply the department-type filter).
- **Phase 7 (Polish)**: Depends on whichever stories are being shipped.

### Within-Story Dependencies

- US1: T022 (test) → T023, T024 (widgets) → T025 (controller, depends on T015 + T013) → T026 (screen) → T027 → T028 (success screen, depends on T029) → T030 → T031.
- US2: T032 (controller) → T033 (screen, depends on T034) → T035 (filter controller) → T036 (filter screen) → T037 (detail controller) → T038 (detail screen, depends on T039).
- US3: T040, T041 (tests) → T042 (controller) → T043 (list screen) → T044 (detail controller) → T045, T046, T047 (widgets) → T048 (detail screen, depends on T044–T047).
- US4: T049 (controller) → T050 (screen, depends on Phase 4 filter controller).

### Parallel Opportunities

- All `[P]` tasks within a phase touch independent files and may run in parallel.
- After Phase 2: US1, US2, and US3 can be developed by different engineers in parallel; US4 starts after US2's filter controller (T035) is in place.
- Locale tasks T005, T006, T007 can run in parallel.
- Model tasks T008–T014 can run in parallel (T012 depends on T008–T011).
- Polish tasks T054–T057 can run in parallel.

---

## Parallel Example: Phase 2 — Foundational Models

```bash
# Launch model tasks together (different files, no shared state):
Task: "T008 [P] Create Hospital model in lib/screens/icu_admission/models/hospital_model.dart"
Task: "T009 [P] Create IcuDepartment model in lib/screens/icu_admission/models/icu_department_model.dart"
Task: "T010 [P] Create StatusHistoryEntry model in lib/screens/icu_admission/models/status_history_model.dart"
Task: "T011 [P] Create enums (UrgencyLevel, AdmissionStatus) in admission_request_model.dart"
Task: "T013 [P] Create AdmissionRequestFormPayload outbound DTO"
Task: "T014 [P] Create IcuPaginatedResponse<T> envelope wrapper"
# T012 runs after these (same file as T011 + composes T008–T011).
```

## Parallel Example: Phase 2 — Shared Components

```bash
Task: "T017 [P] Create EmergencyBanner"
Task: "T018 [P] Create IcuShimmer"
Task: "T019 [P] Create IcuEmptyState"
Task: "T020 [P] Create StatusChip"
Task: "T021 [P] Create UrgencyRadioGroup"
```

---

## Implementation Strategy

### MVP First (User Story 1 only)

1. Phase 1 (Setup) — T001–T007.
2. Phase 2 (Foundational) — T008–T021.
3. Phase 3 (US1 — Submit) — T022–T031.
4. **STOP & VALIDATE**: complete the §4 smoke test in `quickstart.md`. The patient can submit a request and recover its reference.

### Incremental Delivery (recommended)

1. MVP (Phase 1 + 2 + 3) → patient can submit a request with a known hospital id (via the Submit-from-dashboard tile created in Phase 7 step T052 if needed).
2. Add Phase 4 (US2) → patient can discover hospitals and submit from a hospital detail page.
3. Add Phase 5 (US3) → patient gains visibility and cancellation control.
4. Add Phase 6 (US4) → department-first discovery is enabled.
5. Add Phase 7 (Polish) → dashboard wiring + cross-cutting verification.

### Parallel Team Strategy

With 3 engineers after Phase 2 completes:
- Engineer A: Phase 3 (US1).
- Engineer B: Phase 4 (US2).
- Engineer C: Phase 5 (US3).
- Then any of the three picks up Phase 6 + Phase 7.

---

## Notes

- `[P]` = different files, no incomplete-task dependencies.
- `[Story]` traces the task to a user story for cross-checking against `spec.md`.
- Each user story phase ends in an independently testable state — do not skip the checkpoint.
- Constitution V (Localisation): every new user-facing string must reach the UI via `locale.value.<key>` — adding it to one language file without the other breaks the build.
- Constitution I (Platform parity): the only platform-specific behaviour is `tel:` which has a documented clipboard fallback (research.md §6).
- Constitution IV (Backend contract): all 10 endpoints live in `lib/utils/api_end_points.dart`; do not hardcode URLs in screens or services.
- FR-023: only the `AdmissionRequestFormPayload.toJson()` whitelist may be transmitted on submit — never send status/assignment/payment fields.
- Commit per task or logical group; verify `flutter analyze` is clean before each commit (SC-010).
