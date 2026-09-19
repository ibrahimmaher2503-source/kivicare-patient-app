---

description: "Implementation task list for the Nurse Request (Home Nursing) Module"
---

# Tasks: Nurse Request (Home Nursing) Module

**Input**: Design documents from `/specs/020-nurse-request-module/`
**Prerequisites**: plan.md âœ“, spec.md âœ“ (with 5 clarifications), research.md âœ“, data-model.md âœ“, contracts/api-endpoints.md âœ“, quickstart.md âœ“

**Tests**: Tests are NOT mandatory per project Constitution (Principle VI is RECOMMENDED). Three small test suites are still included as optional `[P]` tasks under Polish â€” they cover the highest-risk pieces (request body builder, status enum, bilingual cross-field rule). Skip them only if velocity is the priority.

**Organization**: Tasks are grouped by user story. P1 stories form the MVP; P2/P3 stories add depth and polish. After each user-story phase, the module is independently testable from the patient app.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Parallelizable â€” different file, no dependency on incomplete tasks.
- **[Story]**: User story this task implements (US1â€“US5). Setup, Foundational, and Polish phases have NO story label.
- All file paths are relative to repo root: `C:\Users\berog\StudioProjects\kivicare-laravel-patient-flutter-app-v1.8.1\`.

## Path Conventions

- **Mobile (Flutter)**: `lib/` for source, `test/` for optional tests.
- New module folder: `lib/screens/nurse_request/`
- Model directory uses plural `models/` to match the existing `lib/screens/doctor_visit/models/` convention (Constitution VII).
- Cross-cutting touches: `lib/api/`, `lib/utils/api_end_points.dart`, `lib/locale/language_en.dart`, `lib/locale/language_ar.dart`, `lib/utils/push_notification_service.dart`, `lib/screens/home/components/quick_service_card.dart`.

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Create the module directory tree and confirm the workspace builds before any code is written.

- [X] T001 Create the module directory tree at `lib/screens/nurse_request/` with subfolders `components/`, `models/`, `request_form/components/`, `detail/`, `success/` (use `mkdir -p`; no `.dart` files yet).
- [X] T002 Confirm `pubspec.yaml` already includes `get`, `nb_utils`, `http`, `google_fonts`, `intl`, `url_launcher`, `lottie`. No new packages should be added (Constitution VII). If any are missing, STOP and re-evaluate `plan.md`.
- [X] T003 [P] Run `flutter analyze` once and capture the baseline warning count to a scratch note (e.g., `/tmp/analyze-baseline-020.txt`). This number is the bar that must not be exceeded after the module lands (SC-012).

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Endpoint constants, all five models + the status enum, the API service, the localization key set, and the genuinely-shared components used across more than one user story. This phase MUST complete before any user-story phase begins.

**âš ï¸ CRITICAL**: No user-story work can begin until Phase 2 is complete.

### Endpoints + API service

- [X] T004 Add the 3 nurse-request endpoint constants to `lib/utils/api_end_points.dart` under a clearly-commented "NURSE REQUEST MODULE" block: `getNurseRequests = 'nurse-requests'`, `createNurseRequest = 'nurse-requests'`, `getNurseRequestDetail = 'nurse-requests'` (callers append `/{id}`). Do NOT include the `v1/` prefix â€” commit `173ae10` and `postman_collection_full.json` confirm the canonical paths are un-prefixed (research.md R1). Also confirm or add `governorates = 'governorates'` and `cities = 'cities'`.
- [X] T005 Create `lib/api/nurse_request_apis.dart` with three static methods following the canonical `buildHttpResponse` â†’ `handleResponse` â†’ `Model.fromJson(json['data'] ?? json)` pattern from `lib/api/doctor_visit_apis.dart`. Method signatures match `contracts/api-endpoints.md` Â§"API service method signatures": `Future<NurseRequestModel> create({required NurseRequestFormPayload payload})`, `Future<NurseRequestListResponse> list({required int page, int perPage = 15, String? status})`, `Future<NurseRequestModel> detail({required int id})`. Each method MUST throw on error so callers can `.catchError(toast)`.

### Models

- [X] T006 [P] Create `lib/screens/nurse_request/models/nurse_status.dart` defining the 6-value enum `NurseStatus { pending, assigned, confirmed, inProgress, completed, cancelled }` with: `static NurseStatus fromString(String?)` (default `pending`), `String get apiValue` (returns `in_progress` for `inProgress`, otherwise `name`), `bool get isTerminal` (true for `completed` and `cancelled`), and `String displayLabel(BaseLanguage locale)` mapping each value to its `nurseStatus*` localization key (FR-040; research.md R3).
- [X] T007 [P] Create `lib/screens/nurse_request/models/assigned_nurse_model.dart` for `AssignedNurseModel` per `data-model.md` Â§"Entity: AssignedNurse" (`id`, `displayName`, `avatarUrl?`, `phone?`, `rating?`, `bio?`). Null-safe `fromJson` only â€” no `toJson` (server-only entity).
- [X] T008 [P] Create `lib/screens/nurse_request/models/status_history_entry.dart` for `StatusHistoryEntry` per `data-model.md` Â§"Entity: StatusHistoryEntry" (`previousStatus?`, `newStatus`, `note?`, `changedAt`). Actor identity is intentionally NOT exposed.
- [X] T009 [P] Create `lib/screens/nurse_request/models/nurse_request_list_response.dart` for `NurseRequestListResponse` per `data-model.md` Â§"Entity: NurseRequestListResponse" (`data`, `currentPage`, `lastPage`, `perPage`, `total`); expose computed `bool get hasMore => currentPage < lastPage`.
- [X] T010 [P] Create `lib/screens/nurse_request/models/nurse_request_form_payload.dart` for the **typed allow-list builder** used by `NurseRequestApis.create`. Its `toJson()` MUST: (a) trim every string, (b) omit null or empty optional fields, (c) NEVER serialize any of `id`, `reference_number`, `status`, `assigned_nurse`, `total_amount`, `currency`, `payment_status`, `cancellation_reason`, `completed_at`, `created_at`, `updated_at`, `status_history`, (d) format `preferred_date` as `yyyy-MM-dd`, (e) send `governorate_id` and `city_id` only when set, (f) always send the `city` free-text value (FR-022, FR-021, SC-009; clarification C1 â€” no `patient_id`/`patient_for`).
- [X] T011 [P] Create `lib/screens/nurse_request/models/nurse_request_model.dart` for `NurseRequestModel` per `data-model.md` Â§"Entity: NurseRequest". Implement `fromJson` with null-safe defaults; ISO-8601 â†” `DateTime` round-trip for `preferredDate`, `completedAt`, `createdAt`, `updatedAt`. Expose helper `String? serviceDescriptionLocalized(String localeCode)` returning Arabic when `localeCode == 'ar'` and Arabic is non-empty, else English, else the other (research.md R3, spec Â§7). NO `toJson` for submission â€” the wire body is built by `NurseRequestFormPayload`.

### Localization

- [X] T012 Add the full key set listed in `quickstart.md` Â§6 to `lib/locale/language_en.dart`. Every key listed there MUST be present. Implement `String durationHoursValue(int n)` using `Intl.plural(n, locale: 'en', one: '$n hour', other: '$n hours')`. Add the new key `unknownSubmitOutcomeBanner` ("Please confirm your request was created before submitting again.") and `quickServiceHomeNursing` ("Home Nursing") used by the dashboard entry (clarification C2; research.md R11).
- [X] T013 Mirror every key added in T012 into `lib/locale/language_ar.dart`. Provide proper Arabic translations (placeholder `// TODO: translate` comments allowed only where translation is genuinely unknown â€” never for the status labels, the form section headers, or the verify banner). Implement `durationHoursValue(int n)` with full CLDR plural categories (`zero`, `one`, `two`, `few`, `many`, `other`) so 1 â†’ "Ø³Ø§Ø¹Ø©"ØŒ 2 â†’ "Ø³Ø§Ø¹ØªØ§Ù†"ØŒ 5 â†’ "Ø®Ù…Ø³ Ø³Ø§Ø¹Ø§Øª" (FR-011).

### Truly-shared components and helpers

- [X] T014 [P] Create `lib/screens/nurse_request/components/nurse_status_chip.dart`. Maps the 6 status enum values to (tint, text) color pairs per research.md R3 for both light and dark mode; reads `isDarkMode` from `lib/utils/app_common.dart` (NOT `common_base.dart`). Renders the localized label via `locale.value.<key>` from T006's `displayLabel` (FR-040, FR-041).
- [X] T015 [P] Create `lib/screens/nurse_request/components/nurse_request_phone_actions.dart` exposing two helpers: `Future<void> launchDialer(String phone)` (uses `url_launcher`'s `tel:` scheme; falls back to a localized "no dialer" toast on `canLaunchUrl == false`) and `Future<void> copyReferenceToClipboard(String reference)` (writes via `Clipboard.setData(ClipboardData(text: reference))` from `package:flutter/services.dart` and shows the localized "Copied" toast). These are reused by US1 success, US3 detail, and US5 actions.
- [X] T016 [P] Create `lib/screens/nurse_request/components/cairo_time.dart` exposing `DateTime nowInCairo()` returning `DateTime.now().toUtc().add(const Duration(hours: 2))` and `DateTime cairoTodayMidnight()` and `DateTime cairoMaxBookableDate()` (= today + 90 days). All schedule-section validation MUST go through these helpers (clarification C5; research.md R5b). Document the DST assumption in a one-line comment so a future Egypt DST change is easy to find.
- [X] T017 Add a `case "nurse_request_status_changed":` branch to the existing dispatcher in `lib/utils/push_notification_service.dart` that calls `Get.to(() => NurseRequestDetailScreen(requestId: payload['request_id'] as int))` (FR-004). Forward-declare `NurseRequestDetailScreen` via a relative import inside the case body so the file still compiles before the screen class is created in US3.

### Dashboard entry

- [X] T018 Modify the existing `buildQuickServices()` in `lib/screens/home/components/quick_service_card.dart`: locate the "Home Care" entry currently flagged `isComingSoon: true` and either (a) replace it with a live "Home Nursing" entry whose `onTap` does `Get.to(() => const NurseRequestListScreen())` and whose label is `locale.value.quickServiceHomeNursing`, OR (b) leave the "Home Care" entry alone and insert a new live "Home Nursing" entry adjacent to it. Choose option (a) unless a separate Home Care module is queued. Keep the `isComingSoon` boolean removed (or set to `false`) so the entry is tappable. Use `Icons.medical_services_outlined` (already used by Doctor Visit) or a more nurse-specific icon if available in `lib/generated/assets.dart`.

**Checkpoint**: Foundation ready â€” endpoint constants, API service, all 6 models (5 entities + status enum), localization keys, status chip, phone-action helpers, Cairo time helpers, push deep-link, and dashboard entry are all in place. User-story implementation can now begin.

---

## Phase 3: User Story 1 â€” Submit a home-nursing request (Priority: P1) ðŸŽ¯ MVP

**Goal**: A logged-in patient navigates from the dashboard to a single sectioned form, fills the required fields (with at least one of EN/AR description), and submits. On success they see a confirmation screen with their `NR-YYYY-NNNN` reference number, a copy-to-clipboard control, and clear pathways to view the request or return to the dashboard.

**Independent Test**: From a clean account, dashboard â†’ "Home Nursing" â†’ "New Request" â†’ fill English description "Daily wound dressing" + tomorrow's date + 2h + "12 Test St." + "Cairo" + "+201001234567" â†’ Submit â†’ verify success screen shows a reference number formatted `NR-YYYY-NNNN`. Re-submit empty form â†’ verify both descriptions empty is blocked client-side with a single inline error. Re-submit with phone "+12" â†’ verify phone field error and no submission. Pick yesterday's date in the picker â†’ verify it's disabled. Pick a day 100 days from now â†’ verify it's disabled.

### Implementation for User Story 1

- [X] T019 [P] [US1] Create `lib/screens/nurse_request/request_form/components/service_description_section.dart` rendering two parallel `TextField`s, each wrapped in its own `Directionality` widget â€” `TextDirection.ltr` for the English field, `TextDirection.rtl` for the Arabic field â€” regardless of the surrounding app locale (FR-006, research.md R5). Each field is multiline with a visible character counter capped at 2,000 (FR-005). The cross-field "at least one required" check (FR-007) is exposed as a `bool isValid()` method or a Rx flag for `NurseRequestFormController` to consume; on submit-failure the section renders a single top-level inline error keyed `atLeastOneDescriptionRequired`.
- [X] T020 [P] [US1] Create `lib/screens/nurse_request/request_form/components/duration_stepper.dart`. Integer stepper with 44-pt minimum tap targets for both `-` and `+` buttons (FR-046). Range [1, 24] (FR-010); `-` disabled at 1, `+` disabled at 24. Label uses `locale.value.durationHoursValue(value)` so plural forms render correctly per active locale (FR-011).
- [X] T021 [P] [US1] Create `lib/screens/nurse_request/request_form/components/schedule_section.dart`. Renders a date-picker tile (`showDatePicker` with `firstDate = cairoTodayMidnight()` and `lastDate = cairoMaxBookableDate()` from T016 â€” FR-008, clarification C5), an optional time picker tile with a "Clear" affordance (FR-009), and embeds the duration stepper (T020). The themed primary color is `gradientStart` from `lib/utils/colors.dart`.
- [X] T022 [P] [US1] Create `lib/screens/nurse_request/request_form/components/governorate_city_picker.dart`. Loads governorates from `APIEndPoints.governorates` and cities from `APIEndPoints.cities?governorate_id=...` via `buildHttpResponse`. Fail-open behaviour (FR-014, research.md R11): if governorate fetch fails or returns empty, the picker stays empty and the city field becomes a free-text `TextFormField`; if cities fail or return empty for a chosen governorate, the city field becomes free-text. Selecting a different governorate clears any previously selected city (FR-015). Exposes `Rxn<int> governorateId`, `Rxn<int> cityId`, `RxString city` (always set â€” free-text or copied display name). Module-local for now per Constitution VII; can be promoted to a shared component later.
- [X] T023 [P] [US1] Create `lib/screens/nurse_request/request_form/components/address_section.dart` rendering: `addressLine1` (required, max 255, FR-012), `addressLine2` (optional, max 255), the governorate-city picker (T022), and a "More address details" expansion toggle (FR-017) that reveals optional `state` (max 100), `country` (max 100), and `postalCode` (max 20) fields.
- [X] T024 [P] [US1] Create `lib/screens/nurse_request/request_form/components/contact_section.dart` rendering a single `TextField` for `contactPhone` defaulting to `+20` (FR-018), max 20 chars, with regex validation `^\+?[0-9]{7,20}$`.
- [X] T025 [P] [US1] Create `lib/screens/nurse_request/request_form/components/notes_field.dart` rendering an optional multiline `TextField` for `patientNotes` with a counter capped at 2,000 (FR-019).
- [X] T026 [US1] Create `lib/screens/nurse_request/request_form/nurse_request_form_controller.dart` (`GetxController`). Hold all `TextEditingController`s and Rx state listed in `plan.md` Technical Context. State includes: `serviceEnController`, `serviceArController`, `addressLine1Controller`, `addressLine2Controller`, `cityController`, `stateController`, `countryController`, `postalCodeController`, `phoneController` (preloaded with `+20`), `notesController`; `Rxn<DateTime> preferredDate`; `Rxn<TimeOfDay> preferredTime`; `RxInt durationHours = 1.obs`; `Rxn<int> governorateId`; `Rxn<int> cityId`; `RxBool isSubmitting = false.obs`; `RxnString topLevelError`; `RxMap<String, String> fieldErrors = <String, String>{}.obs`. Implement `Future<void> submit()` that: (1) validates all fields per `data-model.md` Â§"Validation rules" â€” including the bilingual cross-field rule (FR-007); (2) builds a `NurseRequestFormPayload`; (3) sets `isSubmitting(true)` while in flight (clarification C2 â€” disables submit); (4) calls `NurseRequestApis.create(payload: ...)`; (5) on HTTP 422 maps each `errors.{field}: [...]` to `fieldErrors` and surfaces cross-field errors via `topLevelError` (FR-023); (6) on success navigates with `Get.off(() => NurseRequestSuccessScreen(request: result))` and clears the form; (7) on any non-2xx, non-422 outcome (timeout, dropped connection, 5xx without a parsed body) executes the **verify-list flow** from clarification C2 â€” see T027.
- [X] T027 [US1] Inside `nurse_request_form_controller.dart` (T026), implement the duplicate-submit-safety branch: when `submit()` ends in an unknown outcome, route via `Get.off(() => const NurseRequestListScreen())` carrying a `Get.arguments` flag `showVerifyBanner: true`. The form controller MUST NOT auto-retry. Document in a header comment that the form draft is preserved on the controller's `Get.lazyPut(... fenix: false)` registration so the patient can use the system back gesture to return and resubmit if no record was created (clarification C2).
- [X] T028 [US1] Create `lib/screens/nurse_request/request_form/nurse_request_form_screen.dart` composing all five form-section components (T019, T021, T023, T024, T025) inside a single `Form` with a sticky bottom-aligned gradient "Submit Request" button that is disabled while `isSubmitting.value == true` (FR-020). Register the form controller via `Get.lazyPut<NurseRequestFormController>(() => NurseRequestFormController(), fenix: false)` in the screen's `build`-time guard (clarification C3 â€” in-memory only, no GetStorage).
- [X] T029 [US1] Create `lib/screens/nurse_request/success/nurse_request_success_screen.dart`. Lottie checkmark (reuse an existing animation under `assets/lottie/` if present; otherwise add a generic checkmark via package only if pre-existing â€” Constitution VII). Show the reference number prominently with `Clipboard.setData` on tap via `copyReferenceToClipboard` (T015) and a localized "Copied" toast (FR-024). Localized notice "Our team will assign a nurse and confirm details soon" via `locale.value.notifyTeamWillAssign` (FR-024). Two actions: "View Request" â†’ `Get.off(() => NurseRequestDetailScreen(requestId: result.id))` so back-navigation lands on the list, not the form (FR-025); "Back to Home" â†’ `Get.offAll(() => const DashboardScreen())` (FR-026).

**Checkpoint**: User Story 1 is independently functional. A patient can submit a request and see a confirmation. The list and detail screens do not yet exist â€” tapping "View Request" routes to a placeholder `NurseRequestDetailScreen` stub (created as a one-liner in T028 if needed) until US3 lands. Validate Story 1's seven acceptance scenarios from `spec.md` Â§10 manually before proceeding.

---

## Phase 4: User Story 2 â€” View the list of my nurse requests with their status (Priority: P1)

**Goal**: After at least one submission, the patient returns to the Home Nursing entry and sees a paginated list (newest first) of all their requests, each card showing reference number, color-coded status chip, localized service description, schedule, address summary, and â€” once admin has acted â€” assigned nurse name and final price. Pull-to-refresh and infinite scroll are present. Status filter persists across detail-back-to-list within the session and resets when leaving the module (clarification C4). On entering the list with `Get.arguments['showVerifyBanner'] == true` (from T027), a non-blocking banner reads `locale.value.unknownSubmitOutcomeBanner` until the patient taps to dismiss.

**Independent Test**: Submit at least 2 requests via US1. Open Home Nursing â†’ verify newest is at the top. Pull down â†’ verify re-fetch. Scroll to bottom on a 16+-entry account â†’ verify next page loads automatically. Tap a status filter chip â†’ verify list narrows; tap a request â†’ drill into the (placeholder) detail â†’ press back â†’ verify the same filter is still active. Leave to dashboard, re-enter Home Nursing â†’ verify filter has reset to "All". With zero requests, verify the empty-state CTA appears.

### Implementation for User Story 2

- [X] T030 [P] [US2] Create `lib/screens/nurse_request/components/nurse_status_filter_bar.dart`. Horizontally-scrollable chip row with 7 chips (All / Pending / Assigned / Confirmed / In Progress / Completed / Cancelled â€” FR-029, research.md R8). Selected chip uses `gradientSecondaryStartâ†’End` background; others use `surfaceSubtle`. Each chip's tap target is at least 44 pt (FR-046). Exposes `selectedStatus: Rxn<NurseStatus>` (null = "All") and a callback for the controller.
- [X] T031 [P] [US2] Create `lib/screens/nurse_request/components/nurse_request_card.dart`. Single list cell rendering: reference number (top-leading, bold), status chip (T014, top-trailing), service description in active locale via `serviceDescriptionLocalized` (1â€“2-line ellipsis), schedule line ("date Â· time? Â· Nh" using `intl` formatters and `durationHoursValue`), address summary ("addressLine1, city"), assigned nurse name (only when `assignedNurse != null` â€” FR-030), total amount via `lib/utils/price_widget.dart` (only when `totalAmount != null`). 16-px card radius and navy soft shadow per design tokens.
- [X] T032 [P] [US2] Create `lib/screens/nurse_request/components/empty_nurse_requests_widget.dart`. Reuses `lib/utils/empty_error_state_widget.dart` to render the empty state with localized title `emptyRequestsTitle`, subtitle `emptyRequestsSubtitle`, and a primary "Request Home Nursing" CTA that calls `Get.to(() => const NurseRequestFormScreen())` (FR-031).
- [X] T033 [US2] Create `lib/screens/nurse_request/nurse_request_list_controller.dart`. State: `RxList<NurseRequestModel> items = <NurseRequestModel>[].obs`, `RxBool isLoading = false.obs`, `RxBool isLoadingMore = false.obs`, `RxnString error`, `RxInt currentPage = 1.obs`, `RxBool hasMore = true.obs`, `Rxn<NurseStatus> selectedStatus`, plus a `ScrollController scrollController`. Methods: `Future<void> fetchFirstPage()`, `Future<void> loadMore()`, `Future<void> refresh()`, `void applyStatusFilter(NurseStatus?)` â€” the filter setter resets to page 1 and re-fetches. The `scrollController` listener triggers `loadMore()` within 200 px of `maxScrollExtent` while `hasMore && !isLoadingMore` (research.md R9). Uses `NurseRequestApis.list(page, perPage: 15, status: selectedStatus.value?.apiValue)`. On 5xx with cached entries, retain them and surface a non-blocking toast â€” do NOT clear the list (FR-033). Document in a header comment that the controller is registered via `Get.lazyPut(... permanent: false)` so the filter survives detail-back-to-list within the module but resets on module re-entry (clarification C4).
- [X] T034 [US2] Create `lib/screens/nurse_request/nurse_request_list_screen.dart`. App scaffold with title `locale.value.myRequests`, primary action `locale.value.newRequest` â†’ `Get.to(() => const NurseRequestFormScreen())`. Body composition: filter bar (T030) + `RefreshIndicator` wrapping a `ListView.builder` of cards (T031) + a bottom-of-list spinner while `isLoadingMore`. Empty state via T032. Read `Get.arguments` on `onInit`: if `showVerifyBanner == true`, render a dismissible banner at the top of the list showing `locale.value.unknownSubmitOutcomeBanner` until the patient taps dismiss (clarification C2). Tap a card â†’ `Get.to(() => NurseRequestDetailScreen(requestId: item.id))`. Register the controller in `initState` / `onInit` via `Get.lazyPut(() => NurseRequestListController(), fenix: false)`.
- [X] T035 [US2] Verify the dashboard entry from T018 lands on `NurseRequestListScreen` now that the screen exists; replace any temporary stub. Also verify FR-032: after a successful submission in US1, navigating back to the list (e.g., via "Back to Home" then re-entering, or via the system back gesture from detail) shows the new request at the top. Implement the simpler of: (a) `Get.find<NurseRequestListController>().refresh()` from the success screen's "View Request" path before navigating, OR (b) rely on the controller's `onInit` re-fetch when the list screen rebuilds. Document the chosen approach in the controller header comment.

**Checkpoint**: User Stories 1 AND 2 are independently functional. A patient can submit, list, paginate, refresh, filter, and see admin-side updates after a manual refresh. The verify-list banner from clarification C2 is reachable.

---

## Phase 5: User Story 3 â€” Track a request's full lifecycle on the detail screen (Priority: P2)

**Goal**: Tapping a list item opens a single-screen view with the reference number (with copy-to-clipboard), current status chip, vertical 5-step timeline (or terminal cancelled node), full localized service description, schedule, full address, contact phone (tap-to-call), patient notes, the assigned-nurse card (only when present), the pricing card (only when present), the cancellation banner (only when cancelled), the chronological status history, and pull-to-refresh.

**Independent Test**: From the list, tap any pending request â†’ verify only "Pending" step is highlighted, no assigned-nurse or pricing cards. Have admin assign a nurse â†’ pull-to-refresh â†’ verify assigned-nurse card appears, no pricing yet. Have admin add pricing â†’ refresh â†’ verify pricing card. Cancel via admin â†’ refresh â†’ verify cancellation banner with reason + timeline terminates at the cancelled step. For a completed request, verify "Completed on" line and all 5 forward steps marked complete. Tap contact phone â†’ device dialer opens. Tap assigned nurse phone (when present) â†’ device dialer opens.

### Implementation for User Story 3

- [X] T036 [P] [US3] Create `lib/screens/nurse_request/components/nurse_status_timeline.dart`. Vertical 5-step timeline (Pending â†’ Assigned â†’ Confirmed â†’ In Progress â†’ Completed) reading from `NurseRequestModel.status` and `statusHistories`. Each step has a circle (filled gradient if reached, neutral outline if not yet) and a connecting line (gradient if next step is reached, neutral otherwise). On `cancelled` status, render a terminal "Cancelled" node in red instead of advancing forward (FR-035). Step labels via `locale.value.nurseStatus*`. Each step shows the corresponding `changedAt` timestamp from `statusHistories` when present.
- [X] T037 [P] [US3] Create `lib/screens/nurse_request/components/nurse_status_history_tile.dart` rendering a single `StatusHistoryEntry` with: `previousStatus â†’ newStatus`, optional `note`, and a formatted timestamp via `intl` in the active locale. Actor identity is NOT shown (data-model invariant). Used by the detail screen's status-history accordion.
- [X] T038 [P] [US3] Create `lib/screens/nurse_request/components/assigned_nurse_card.dart`. Shows avatar (`lib/components/cached_image_widget.dart` with a generic nurse-silhouette fallback when `avatarUrl == null`), `displayName`, optional rating row, optional bio. If `phone != null`, render a tap-to-call action wired to `launchDialer(...)` from T015. Renders only when the model's `assignedNurse` is non-null (FR-036).
- [X] T039 [P] [US3] Create `lib/screens/nurse_request/components/pricing_card.dart`. Shows `totalAmount` formatted via `lib/utils/price_widget.dart` (currency-aware), the localized payment-status label (`paymentStatusUnpaid` / `paymentStatusPaid` / `paymentStatusRefunded`), and a brief explanatory line. Renders only when `totalAmount != null` (FR-036).
- [X] T040 [P] [US3] Create `lib/screens/nurse_request/components/address_summary_card.dart` rendering the full address breakdown: `addressLine1`, optional `addressLine2`, governorate name (when populated), `city`, optional `state`, `country`, `postalCode`. Localized labels for each line.
- [X] T041 [P] [US3] Create `lib/screens/nurse_request/components/schedule_summary_card.dart` rendering the schedule on the detail screen: localized "Preferred date" + formatted date, optional "Preferred time" + `HH:mm`, and "Duration" + `durationHoursValue(durationHours)`. The `preferredTime` MUST render as wall-clock without device-time-zone shifting (clarification C5; data-model.md cross-field invariants).
- [X] T042 [US3] Create `lib/screens/nurse_request/detail/nurse_request_detail_controller.dart`. State: `final int requestId; Rxn<NurseRequestModel> request; RxBool isLoading = false.obs; RxnString error;`. Method: `Future<void> fetch()` calls `NurseRequestApis.detail(id: requestId)`. Pull-to-refresh and a manual refresh control both call `fetch()` (FR-038). On 5xx with cached data already loaded, retain the cached snapshot and surface a non-blocking toast â€” do NOT clear the screen (US3 acceptance scenario 6). Register via `Get.lazyPut(() => NurseRequestDetailController(...), fenix: false)`.
- [X] T043 [US3] Create `lib/screens/nurse_request/detail/nurse_request_detail_screen.dart`. Header: reference number (tap to copy via `copyReferenceToClipboard` from T015) + status chip (T014) + "Submitted on {date}". Body sections (each conditional per `data-model.md` invariants and FR-036): timeline (T036), service description (active-locale text via `serviceDescriptionLocalized`), schedule (T041), address (T040), contact phone with tap-to-call via `launchDialer` (T015), patient notes (only when present), assigned-nurse card (T038), pricing card (T039), cancellation banner (T044), "Completed on" line for completed requests (FR-037), status-history accordion using T037 tiles. Wrap everything in `RefreshIndicator(onRefresh: controller.fetch)`. AppBar action: a manual refresh icon also calls `controller.fetch()`.
- [X] T044 [P] [US3] Create `lib/screens/nurse_request/components/nurse_cancellation_banner.dart`. Red-tinted full-width banner showing the localized "Request cancelled" header (`locale.value.cancellationReason` as section title) and the `cancellationReason` body. Renders only when `status == NurseStatus.cancelled` (FR-036).
- [X] T045 [US3] Replace any placeholder routing target used in US1's success screen "View Request" action so it now points to the real `NurseRequestDetailScreen`. Verify push-notification deep-linking from T017 reaches this screen with the correct `requestId`.

**Checkpoint**: User Stories 1, 2, AND 3 are all independently functional. Patients can submit, browse, and track the full request lifecycle through to terminal completion or cancellation.

---

## Phase 6: User Story 4 â€” Use the module in Arabic (RTL) and dark mode (Priority: P2)

**Goal**: Every screen in the module renders correctly in Arabic with proper RTL layout, full localization, correct Arabic plural forms for the duration label, and bilingual description fields that keep their per-field direction. Every screen also renders correctly in dark mode with no contrast regressions.

**Independent Test**: Switch the app to Arabic; walk through dashboard â†’ list â†’ form â†’ success â†’ detail. Verify (a) all labels/buttons/empty states are in Arabic, (b) layout fully mirrored, (c) on the form, the English description field still flows LTR while the Arabic field flows RTL regardless of app locale, (d) duration labels render correct Arabic plurals at 1, 2, 3, 5, 11, 24 hours. Toggle dark mode and repeat â€” verify all chips, banners, timelines, gradients, and surfaces stay readable.

### Implementation for User Story 4

- [X] T046 [P] [US4] Hardcoded-string audit on `lib/screens/nurse_request/**/*.dart` and `lib/api/nurse_request_apis.dart`. Use `Grep` for English-letter `String` literals that aren't `locale.value.<key>`, asset paths from `lib/generated/assets.dart`, or test fixtures. Every offender MUST be rerouted through localization (FR-043, SC-004). Add or expand keys in BOTH `language_en.dart` and `language_ar.dart` as needed.
- [X] T047 [P] [US4] Manually verify duration plural rendering in Arabic at the values 1, 2, 3, 5, 11, 24 hours. Snapshot the rendered strings (screenshots or copy-paste) and compare against CLDR-correct Arabic plural categories. Fix `language_ar.dart`'s `durationHoursValue` if any case is wrong. Document the verified outputs in a comment at the top of `language_ar.dart` (FR-011).
- [ ] T048 [US4] Per-screen RTL verification on form, list, success, and detail with the app set to Arabic. Confirm: back arrows mirror; status chips render correctly; the bilingual description fields keep their per-field direction (research.md R5); the timeline progresses right-to-left visually but text inside each step still reads in its own direction; date pickers, time pickers, and dropdowns mirror correctly. File any mirror-side regressions as inline fixes in the affected screen file.
- [ ] T049 [US4] Per-screen dark-mode verification on form, list, success, and detail. For every status chip, banner, timeline accent, gradient, surface, input fill, focus ring, and text color: confirm contrast against the dark background using the `*Dark` variant tokens from `lib/utils/colors.dart`. Fix any low-contrast token usage by switching to the dark-mode variant. Pay particular attention to status chip backgrounds (research.md R3) and the cancellation banner (T044).

**Checkpoint**: The module is shippable for Arabic-speaking patients in both light and dark mode.

---

## Phase 7: User Story 5 â€” Filter, copy reference, and call from the module (Priority: P3)

**Goal**: Three convenience capabilities. (1) Status filtering on the list narrows correctly and resets cleanly per clarification C4. (2) Tapping the reference number on the success screen or detail header copies it to the clipboard with a confirmation toast. (3) Tapping the contact phone on the detail screen, or the assigned nurse phone, opens the device dialer prepopulated.

**Independent Test**: From the list, apply each of the 6 status filters and verify the list narrows correctly. Tap the reference number on the success screen and on the detail header â€” verify clipboard contains it and a confirmation toast fires. Tap the contact phone on the detail screen â€” verify the device dialer opens with the number prefilled. With an assigned-nurse-phone present, tap it â€” verify dialer opens. Drill into a detail screen with a filter active, press back â†’ verify filter still active. Leave to dashboard and return â†’ verify filter reset to "All".

### Implementation for User Story 5

- [X] T050 [P] [US5] Verify the list status filter built in US2 (T030 + T033) passes all filter-behavior acceptance scenarios from spec Â§10 US5 and clarification C4: filter resets pagination, applies on pull-to-refresh, survives detail-back-to-list, and resets on module re-entry from the dashboard. File any deviations as inline fixes in `nurse_request_list_controller.dart` or `nurse_status_filter_bar.dart`.
- [X] T051 [P] [US5] Verify the reference-number tap-to-copy on `nurse_request_success_screen.dart` (T029) and on the header of `nurse_request_detail_screen.dart` (T043) both call `copyReferenceToClipboard` (T015) and surface the localized "Copied" toast. If either is wired to `Clipboard.setData` directly, refactor to use the helper.
- [X] T052 [P] [US5] Verify all tap-to-call call-sites: contact phone on the detail screen (T043) and assigned nurse phone on the assigned-nurse card (T038). Both must call `launchDialer` (T015) and gracefully surface "no dialer available" when `canLaunchUrl` returns false. The form's contact-phone input is NOT tap-to-call â€” it's an editable field â€” so this verification applies only to the detail screen.

**Checkpoint**: All 5 user stories are independently functional and meet their acceptance scenarios. Module is feature-complete pending Polish.

---

## Phase 8: Polish & Cross-Cutting Concerns

**Purpose**: Final cleanup and verification across the whole module before merge.

- [X] T053 Run `flutter analyze` and compare the warning count against the baseline captured in T003. The delta MUST be zero â€” no new warnings introduced (Constitution + SC-012). Fix any introduced warnings.
- [ ] T054 [P] Walk through every manual test in `quickstart.md` Â§5 on Android. File any divergences as fixes in the affected file.
- [ ] T055 [P] Walk through the same manual tests on at least one of iOS or Web (Constitution I â€” Platform Parity). On Web, verify the `tel:` link opens the OS handler. File any divergences.
- [ ] T056 Network audit: capture an actual `POST /api/nurse-requests` request body using Charles, Proxyman, or `flutter_inappwebview` proxy. Confirm the body does NOT contain ANY of: `id`, `reference_number`, `status`, `assigned_nurse`, `total_amount`, `currency`, `payment_status`, `cancellation_reason`, `completed_at`, `status_history`, `nurse_id`, `coupon_code`, `patient_id`, `patient_for` (FR-022, SC-009, clarification C1). Save the captured request in a comment in `test/unit/nurse_request/nurse_request_apis_test.dart` for future regression.
- [X] T057 Final hardcoded-string sweep across `lib/screens/nurse_request/**/*.dart` and `lib/api/nurse_request_apis.dart` using `Grep` for any string literal containing English-letter content that isn't an identifier, asset path, or test fixture (SC-004). Result must be zero hits.
- [X] T058 Verify every localization key listed in `quickstart.md` Â§6 actually exists in BOTH `language_en.dart` and `language_ar.dart`. If `quickstart.md` drifted from the implementation, update `quickstart.md` to match â€” NOT the other way round.
- [X] T059 Update `CLAUDE.md` with one-paragraph notes for any new patterns established by this module that future contributors should know: per-field `Directionality` wrapper for bilingual inputs, the verify-list banner flow for unknown submit outcomes, the in-memory-only draft policy for forms touching PII, the Africa/Cairo wall-clock convention for scheduled dates. The auto-generated agent-context lines from `update-agent-context.ps1` are already in place from Phase 1 of `/speckit.plan`.

### Optional test suites (Constitution VI is RECOMMENDED)

- [X] T060 [P] Create `test/unit/nurse_request/nurse_request_apis_test.dart` covering: (a) request body builder omits empty optional fields, (b) trims whitespace, (c) NEVER includes `nurse_id`, `coupon_code`, `status`, `total_amount`, `payment_status`, `patient_id`, `patient_for`, (d) formats `preferred_date` as `yyyy-MM-dd`, (e) sends `governorate_id` and `city_id` only when set while `city` is always sent. Use mocked HTTP â€” never hit the live backend (Constitution VI).
- [X] T061 [P] Create `test/unit/nurse_request/nurse_status_test.dart` round-tripping `fromString` â†” `apiValue` for all six values; assert `isTerminal` is `true` for `completed` and `cancelled` only.
- [X] T062 [P] Create `test/unit/nurse_request/nurse_request_form_controller_test.dart` covering the bilingual cross-field rule (both empty â†’ fails; either non-empty â†’ passes), duration stepper boundary clamping (1 and 24), the phone regex, and the unknown-outcome verify-list flow (clarification C2 â€” the controller routes to the list with `showVerifyBanner: true` instead of auto-retrying).

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies â€” start immediately.
- **Foundational (Phase 2)**: Depends on Setup â€” BLOCKS all user-story phases.
- **US1 (Phase 3, P1, MVP)**: Depends on Foundational. Once done, the module ships an MVP.
- **US2 (Phase 4, P1)**: Depends on Foundational + US1 controller stub (T026/T027 emit `Get.arguments['showVerifyBanner']` consumed by T034).
- **US3 (Phase 5, P2)**: Depends on Foundational. Patches the placeholder route used in US1's success screen (T045), so should land after US1.
- **US4 (Phase 6, P2)**: Depends on US1 + US2 + US3 â€” it is a verification phase across all UI. The pluralization change in `language_ar.dart` (T047) is the only code change; the rest are inline tweaks discovered during verification.
- **US5 (Phase 7, P3)**: Depends on US1 + US2 + US3 â€” verifies wiring already in place.
- **Polish (Phase 8)**: Depends on every desired user story being complete. Optional test tasks (T060â€“T062) can run in parallel with the rest of Polish.

### Within Each User Story

- Components first (all `[P]` tasks within the phase).
- Controller second.
- Screen third (composes components + reads from controller).
- Cross-screen wiring last (e.g., success â†’ detail, list â†’ detail).

### Parallel Opportunities

- All Setup tasks marked `[P]`: T003 alone (T001 / T002 are sequential gates).
- All Foundational tasks marked `[P]`: T006, T007, T008, T009, T010, T011 (5 model files + the status enum can land in parallel); T014, T015, T016 (3 helper components).
- US1 components in parallel: T019, T020, T021, T022, T023, T024, T025 (7 form sub-components).
- US2 components in parallel: T030, T031, T032 (3 components).
- US3 components in parallel: T036, T037, T038, T039, T040, T041, T044 (7 detail components).
- US4 verification tasks in parallel: T046, T047.
- US5 verification tasks in parallel: T050, T051, T052.
- Polish manual-QA tasks in parallel: T054, T055.
- Optional test suites in parallel: T060, T061, T062.

---

## Parallel Example: User Story 3 component build-out

```bash
# After US3's controller (T042) has its signature decided, build all 7 detail components in parallel:
Task: "Create lib/screens/nurse_request/components/nurse_status_timeline.dart"
Task: "Create lib/screens/nurse_request/components/nurse_status_history_tile.dart"
Task: "Create lib/screens/nurse_request/components/assigned_nurse_card.dart"
Task: "Create lib/screens/nurse_request/components/pricing_card.dart"
Task: "Create lib/screens/nurse_request/components/address_summary_card.dart"
Task: "Create lib/screens/nurse_request/components/schedule_summary_card.dart"
Task: "Create lib/screens/nurse_request/components/nurse_cancellation_banner.dart"
```

```bash
# Then sequential â€” controller and the screen that composes everything:
Task: "Create lib/screens/nurse_request/detail/nurse_request_detail_controller.dart"
Task: "Create lib/screens/nurse_request/detail/nurse_request_detail_screen.dart composing all 7 components"
```

---

## Implementation Strategy

### MVP First (US1 only)

1. Phase 1: Setup (T001â€“T003).
2. Phase 2: Foundational (T004â€“T018).
3. Phase 3: US1 â€” Submit a request (T019â€“T029).
4. **STOP and VALIDATE**: Submit a request end-to-end against the test backend. Verify the success screen shows a `NR-YYYY-NNNN` reference number. All seven of US1's acceptance scenarios in `spec.md` Â§10 must pass.
5. Demo or merge MVP.

### Incremental Delivery

1. MVP (Setup + Foundational + US1) â†’ demo.
2. Add US2 (list + verify-list banner) â†’ demo.
3. Add US3 (detail + timeline + assigned nurse + pricing + cancellation banner) â†’ demo. The round-trip is now complete: submit â†’ list â†’ detail â†’ status updates visible after admin action.
4. Add US4 (RTL + dark mode QA) â†’ demo in Arabic with dark mode toggled.
5. Add US5 (filter + copy + call polish) â†’ final demo.
6. Phase 8: Polish â†’ final QA + merge.

### Parallel Team Strategy

After Phase 2 is complete and shared:

- Developer A: US1 (form + success).
- Developer B: US2 (list + filter bar + card + verify banner).
- Developer C: US3 (detail + 7 detail components + push deep-link wiring).

Then US4 and US5 are short verification phases for whoever finishes their primary story first.

---

## Notes

- `[P]` tasks operate on different files and have no incomplete dependency. Same-phase non-`[P]` tasks share a file or a sequential constraint (e.g., T026 builds the controller that T028's screen reads).
- `[Story]` tags trace each task to a `spec.md` user story so a contributor can pick up work scoped to a single story without thrashing the whole module.
- Verification tasks (US4, US5, Polish) operate on files already created in earlier phases â€” they may produce small inline fixes but should not produce large refactors. If a verification task starts ballooning, the upstream story phase missed something â€” backtrack and fix it there instead of patching late.
- Each story is independently testable from the patient app once its phase is complete. The clinic-admin actions (assign nurse, set price, cancel) are exercised via the existing backend admin tooling, NOT via this client (FR-042; clarification C1 enforces patient-side read-only-after-submit).
- Clarifications enforced by explicit tasks: C1 (T010 â€” no `patient_id`/`patient_for` in payload; T056 â€” network audit); C2 (T026/T027/T034 â€” verify-list flow); C3 (T028 â€” `Get.lazyPut(... fenix: false)` for in-memory drafts only; no GetStorage in module); C4 (T033 â€” list controller registration scope; T050 â€” verify); C5 (T016 â€” `cairoTodayMidnight()` helper; T021 â€” schedule section uses it; T041 â€” detail renders without device-TZ shift; T011 â€” model preserves wall-clock semantics).
- Commit strategy: commit after each completed task; squash-merge per phase if the team prefers tidy history.
- Avoid: cross-story dependencies that break independence. The deliberate stitches are: (a) US2's verify-list banner consumes `Get.arguments` set by US1's controller (T027 â†’ T034), and (b) US3 patches the success-screen placeholder route used by US1 (T045). Both are documented at the call-sites.

