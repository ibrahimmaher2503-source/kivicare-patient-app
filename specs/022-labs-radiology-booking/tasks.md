 ---
description: "Task list for Labs & Radiology Booking Module"
---

# Tasks: Labs & Radiology Booking Module

**Input**: Design documents from `/specs/022-labs-radiology-booking/`
**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/, quickstart.md
**Tests**: Included for high-risk logic only (booking payload, status enum, slots response, order helpers) per Constitution VI (Testing Discipline — recommended for booking flows).
**Organization**: Grouped by user story (US1 = MVP). All paths absolute under repo root `C:\Users\berog\StudioProjects\kivicare-laravel-patient-flutter-app-v1.8.1\`.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Different files, no dependencies on incomplete tasks — parallelizable
- **[Story]**: US1 / US2 / US3 maps to user stories in spec.md
- All paths are repo-root-relative

---

## Phase 1: Setup (Shared Infrastructure)

- [ ] T001 Add `open_filex: ^4.5.0` to `pubspec.yaml` dependencies (per research.md R-2) and run `flutter pub get`
- [ ] T002 Create the empty folder skeleton under `lib/screens/labs_radiology/` matching plan.md project structure (hub/, categories/, tests/, facility_detail/, slot_selection/, booking_confirmation/, orders/, shared/, models/ plus their `components/` subfolders)
- [ ] T003 Add the labs/radiology endpoint constants block to `lib/utils/api_end_points.dart` exactly as in `specs/022-labs-radiology-booking/contracts/api-endpoints.md` (labsSearch, radiologySearch, labTestCategories, labTests, facilityBookings, testOrders) — do NOT add any `/v1/admin/facility-bookings/*` constant
- [ ] T004 [P] Open a backend question to confirm R-1: does `POST /v1/test-orders` accept the body in `contracts/api-endpoints.md §8` and return the full Test Order shape? Document the answer in `research.md` (gates T052)
- [ ] T005 [P] Open a backend question to confirm R-4: does the API return HTTP 409 or 422 (with `slot_id` field error) when a slot is taken between fetch and submit? Document the answer in `research.md` (gates T055)

---

## Phase 2: Foundational (Blocking Prerequisites)

**⚠️ CRITICAL**: No user-story work begins until this phase is complete.

### Models

- [ ] T006 [P] Create `FacilityType` enum in `lib/screens/labs_radiology/models/facility_type.dart` per data-model.md (`fromString`, `apiValue`, `endpointBase`, `displayLabel`)
- [ ] T007 [P] Create `TestOrderStatus` enum in `lib/screens/labs_radiology/models/test_order_status.dart` per data-model.md (`fromString`, `apiValue`, `isTerminal`, `isCancellable`, `displayLabel`)
- [ ] T008 [P] Create `LabTestCategoryModel` in `lib/screens/labs_radiology/models/lab_test_category_model.dart` with `fromJson`, `toJson`, `==`, `hashCode`
- [ ] T009 [P] Create `LabTestModel` in `lib/screens/labs_radiology/models/lab_test_model.dart` with `fromJson`, `toJson`, `==`, `hashCode` (depends on T006, T008)
- [ ] T010 [P] Create `FacilityModel` in `lib/screens/labs_radiology/models/facility_model.dart` with `fromJson`, `toJson`, `==` by id+type, `hashCode` (depends on T006)
- [ ] T011 [P] Create `SlotModel` in `lib/screens/labs_radiology/models/slot_model.dart` with `formattedRange(localeCode)` helper, `==`, `hashCode`
- [ ] T012 [P] Create `SlotsResponse` in `lib/screens/labs_radiology/models/slots_response.dart` with `slotsFor(DateTime)` helper (depends on T006, T011)
- [ ] T013 [P] Create `TestOrderStatusHistoryModel` in `lib/screens/labs_radiology/models/test_order_status_history_model.dart` (depends on T007)
- [ ] T014 [P] Create `TestOrderModel` in `lib/screens/labs_radiology/models/test_order_model.dart` with `canCancel` and `hasReport` getters and `PaymentStatus` enum (depends on T006, T007, T009, T010, T013)
- [ ] T015 [P] Create `BookingPayload` in `lib/screens/labs_radiology/models/booking_payload.dart` with `toJson()` that strips nulls and `validate()` per data-model.md (depends on T006)
- [ ] T016 [P] Create `FacilityListResponse` in `lib/screens/labs_radiology/models/facility_list_response.dart` (depends on T010)
- [ ] T017 [P] Create `LabTestListResponse` in `lib/screens/labs_radiology/models/lab_test_list_response.dart` (depends on T009)
- [ ] T018 [P] Create `TestOrderListResponse` in `lib/screens/labs_radiology/models/test_order_list_response.dart` (depends on T014)

### API service

- [ ] T019 Create `lib/api/labs_radiology_apis.dart` with all 12 method signatures from `contracts/api-endpoints.md` (searchLabs, searchRadiology, getTestCategories, getLabTests, getLabTestById, getLabSlots, getRadiologySlots, createTestOrder, getTestOrders, getTestOrderById, cancelTestOrder, downloadReport) — each routed through `buildHttpResponse()` → `handleResponse()` → model deserialization (depends on T006–T018)

### Cross-cutting

- [ ] T020 [P] Create `ReportDownloadService` skeleton in `lib/screens/labs_radiology/shared/service/report_download_service.dart` with `download(int orderId, String referenceNumber)` method signature; body throws `UnimplementedError` for now (full impl in T068/T069)
- [ ] T021 [P] Add ALL locale keys from `contracts/localization-keys.md` to `lib/locale/language_en.dart` (English text)
- [ ] T022 [P] Add ALL locale keys from `contracts/localization-keys.md` to `lib/locale/language_ar.dart` (Arabic text; mark unknown translations with `// TODO: translate`)
- [ ] T023 [P] Create `FacilityTypeBadge` widget in `lib/screens/labs_radiology/shared/components/facility_type_badge.dart`
- [ ] T024 [P] Create `FacilityRatingBadge` widget in `lib/screens/labs_radiology/shared/components/facility_rating_badge.dart`
- [ ] T025 [P] Create `DistanceBadge` widget in `lib/screens/labs_radiology/shared/components/distance_badge.dart`

**Checkpoint**: Foundation ready — user-story work can now begin.

---

## Phase 3: User Story 1 — Book a Diagnostic Test at a Facility (Priority: P1) 🎯 MVP

**Goal**: Patient discovers a facility, picks a test (required for labs), picks a slot, and confirms a booking, receiving a reference number.

**Independent Test**: From dashboard tap "Labs & Radiology" → switch tabs → tap a lab → "Book this test" → pick a date and slot → tap Continue → tap Confirm Booking → success screen with reference number.

### Tests for User Story 1

- [ ] T026 [P] [US1] Write `test/screens/labs_radiology/booking_payload_test.dart` — asserts `BookingPayload.toJson()` keys are subset of allow-list from `contracts/api-forbidden-fields.md`, asserts `validate()` returns `'lab_test_required'` for lab without test, asserts nullable fields are stripped when null/empty, asserts dates serialise as `yyyy-MM-dd`
- [ ] T027 [P] [US1] Write `test/screens/labs_radiology/slots_response_test.dart` — asserts `SlotsResponse.slotsFor(date)` returns matching list and empty list for missing date keys

### Hub screen

- [ ] T028 [P] [US1] Create `FacilityTypeTabs` (segmented control with gradient indicator) in `lib/screens/labs_radiology/hub/components/facility_type_tabs.dart`
- [ ] T029 [P] [US1] Create `FacilitySearchBar` (rounded 12px, debounced via controller) in `lib/screens/labs_radiology/hub/components/facility_search_bar.dart`
- [ ] T030 [P] [US1] Create `LocationFilterChip` reusing existing `FilterLocationComponent` per research.md R-7 in `lib/screens/labs_radiology/hub/components/location_filter_chip.dart`
- [ ] T031 [P] [US1] Create `ServiceBadge` chip in `lib/screens/labs_radiology/hub/components/service_badge.dart`
- [ ] T032 [P] [US1] Create `LabCard` (cover, name, rating, address, distance, services, "starting from", "View Tests" CTA) in `lib/screens/labs_radiology/hub/components/lab_card.dart`
- [ ] T033 [P] [US1] Create `RadiologyCenterCard` mirror of LabCard in `lib/screens/labs_radiology/hub/components/radiology_center_card.dart`
- [ ] T034 [P] [US1] Create `EmptyFacilitiesWidget` (illustration + clear-filters CTA) in `lib/screens/labs_radiology/hub/components/empty_facilities_widget.dart` reusing `EmptyErrorStateWidget` where possible
- [ ] T035 [US1] Create `LabsRadiologyHubController` in `lib/screens/labs_radiology/hub/labs_radiology_hub_controller.dart` with reactive `selectedTab`, `labs`, `radiologyCenters`, pagination state, location filter state, last-tab persistence (R-9), 400ms server-side search debounce, and methods `fetchFacilities`, `loadMore`, `refresh`, `onTabChanged`, `onSearchChanged`, `onLocationFilterChanged`
- [ ] T036 [US1] Create `LabsRadiologyHubScreen` in `lib/screens/labs_radiology/hub/labs_radiology_hub_screen.dart` with optional constructor param `int? prefilterTestId`, AppBar title `locale.value.labsAndRadiology`, sticky tabs/search/location-chip, quick-action row (3 cards — taps left as no-op toasts now; wired later by US2/US3 tasks T071/T083), facility list with pagination + pull-to-refresh + empty state

### Facility detail

- [ ] T037 [P] [US1] Create `FacilityHeroHeader` (cover image, logo, name, type badge, rating + reviews) in `lib/screens/labs_radiology/facility_detail/components/facility_hero_header.dart`
- [ ] T038 [P] [US1] Create `FacilityServicesSection` (chip list) in `lib/screens/labs_radiology/facility_detail/components/facility_services_section.dart`
- [ ] T039 [P] [US1] Create `FacilityTestsSection` (top-5 tests + "View All" link + "Book this test" inline CTA) in `lib/screens/labs_radiology/facility_detail/components/facility_tests_section.dart`
- [ ] T040 [P] [US1] Create `FacilityAddressCard` (full address + tap-to-call + open-in-maps via `url_launcher`) in `lib/screens/labs_radiology/facility_detail/components/facility_address_card.dart`
- [ ] T041 [P] [US1] Create `BookAppointmentStickyBar` (gradient CTA) in `lib/screens/labs_radiology/facility_detail/components/book_appointment_sticky_bar.dart`
- [ ] T042 [US1] Create `FacilityDetailController` in `lib/screens/labs_radiology/facility_detail/facility_detail_controller.dart` with `loadTests()` (calls `getLabTests(facilityId: facility.id)`) and `onBookAppointmentTapped({LabTestModel? preselectedTest})` navigating to slot selection
- [ ] T043 [US1] Create `FacilityDetailScreen` in `lib/screens/labs_radiology/facility_detail/facility_detail_screen.dart` (scrollable: hero → action row → about → services → tests → address → contact → sticky CTA)

### Slot selection

- [ ] T044 [P] [US1] Create `SlotChip` with available/selected/unavailable states (per spec UX styling) in `lib/screens/labs_radiology/slot_selection/components/slot_chip.dart`
- [ ] T045 [P] [US1] Create `SlotCalendarStrip` (horizontal date list, 14 days, RTL-aware via inherited `Directionality`, today indicator) in `lib/screens/labs_radiology/slot_selection/components/slot_calendar_strip.dart`
- [ ] T046 [P] [US1] Create `SlotGrid` (3-column grid) in `lib/screens/labs_radiology/slot_selection/components/slot_grid.dart`
- [ ] T047 [US1] Create `SlotSelectionController` in `lib/screens/labs_radiology/slot_selection/slot_selection_controller.dart` with `slotsResponse`, `selectedDate`, `selectedSlot`, `loadSlots()` (uses `getLabSlots` or `getRadiologySlots` per FacilityType), pre-select first available date, `visibleSlots` getter, `onContinueTapped()` navigation guard
- [ ] T048 [US1] Create `SlotSelectionScreen` in `lib/screens/labs_radiology/slot_selection/slot_selection_screen.dart` with summary card, calendar strip, slot grid, sticky Continue (disabled until slot selected), shimmer loading and empty state

### Booking confirmation

- [ ] T049 [P] [US1] Create `BookingSummaryCard` (facility + test + slot + address) in `lib/screens/labs_radiology/booking_confirmation/components/booking_summary_card.dart`
- [ ] T050 [P] [US1] Create `PriceSummarySection` in `lib/screens/labs_radiology/booking_confirmation/components/price_summary_section.dart`
- [ ] T051 [P] [US1] Create `ConfirmationNotesField` (max 1000 chars + counter) in `lib/screens/labs_radiology/booking_confirmation/components/confirmation_notes_field.dart`
- [ ] T052 [US1] Create `BookingConfirmationController` in `lib/screens/labs_radiology/booking_confirmation/booking_confirmation_controller.dart` with `confirmBooking()` that builds `BookingPayload`, calls `BookingPayload.validate()` (toast on failure), calls `LabsRadiologyApis.createTestOrder`, on success `Get.off(() => BookingSuccessScreen(order: result))` and triggers `TestOrdersListController.refresh()` if registered (R-10) — depends on T004 confirmation
- [ ] T053 [US1] Create `BookingConfirmationScreen` in `lib/screens/labs_radiology/booking_confirmation/booking_confirmation_screen.dart` (AppBar + summary + notes + price + sticky Confirm)
- [ ] T054 [US1] Create `BookingSuccessScreen` in `lib/screens/labs_radiology/booking_confirmation/booking_success_screen.dart` with animated checkmark, copyable reference number, "View Order" → `Get.off(() => TestOrderDetailScreen(orderId: order.id))` (note: TestOrderDetailScreen ships in US2 — for MVP demo, this button can be hidden if `Get.isRegistered<TestOrderDetailController>() == false`; default to "Back to Hub")
- [ ] T055 [US1] In `BookingConfirmationController`, add slot-conflict handler per R-4 confirmation: catch 409 (or 422 keyed on `slot_id`), show `slotConflictTitle`/`slotConflictBody` dialog, `Get.back()` to slot selection and trigger `loadSlots()` — depends on T005

### Dashboard entry

- [ ] T056 [US1] Add a "Labs & Radiology" tile to the dashboard grid in `lib/screens/dashboard/` with primary gradient and test-tube + scanner icon, navigating via `Get.to(() => const LabsRadiologyHubScreen())` — minimal-touch change consistent with existing dashboard tiles

**Checkpoint**: User Story 1 (MVP) complete. The patient can discover, pick, and confirm a booking end-to-end. The success screen confirms with a reference number.

---

## Phase 4: User Story 2 — Track Orders and Download Reports (Priority: P2)

**Goal**: Patient sees all orders with status filter, opens an order to view its timeline, cancels while permitted, and downloads the report PDF when complete.

**Independent Test**: From hub quick-action "My Test Orders" → see list → filter by Pending → tap an order → see timeline + Cancel button → cancel with reason → status updates. Open a Completed order with report → tap Download → PDF saves and opens (or browser-downloads on Web).

### Tests for User Story 2

- [ ] T057 [P] [US2] Write `test/screens/labs_radiology/test_order_status_test.dart` — asserts `isCancellable` is true only for `pending` and `confirmed`; `isTerminal` is true for `completed`, `cancelled`, `rejected`; `apiValue` round-trip via `fromString` for all 7 values including `sample_collected` and `in_progress`
- [ ] T058 [P] [US2] Write `test/screens/labs_radiology/test_order_model_test.dart` — asserts `canCancel == status.isCancellable`, `hasReport` true only when `reportUrl` is non-empty

### Orders list

- [ ] T059 [P] [US2] Create `TestOrderStatusChip` (color/icon table per spec §11) in `lib/screens/labs_radiology/orders/components/test_order_status_chip.dart`
- [ ] T060 [P] [US2] Create `TestOrderCard` (reference, status chip, facility, test, slot, total) in `lib/screens/labs_radiology/orders/components/test_order_card.dart`
- [ ] T061 [US2] Create `TestOrdersListController` in `lib/screens/labs_radiology/orders/test_orders_list_controller.dart` with `orders`, pagination state, `statusFilter`, `fetchOrders`, `loadMore`, `refresh`, `applyFilter` — uses `LabsRadiologyApis.getTestOrders`
- [ ] T062 [US2] Create `TestOrdersListScreen` in `lib/screens/labs_radiology/orders/test_orders_list_screen.dart` with status chip row + paginated list + pull-to-refresh + empty state; constructor accepts optional `initialStatusFilter`

### Order detail

- [ ] T063 [P] [US2] Create `TestOrderStatusTimeline` (vertical stepper; hides `sampleCollected` step when `facilityType == radiology` per FR-018) in `lib/screens/labs_radiology/orders/components/test_order_status_timeline.dart`
- [ ] T064 [P] [US2] Create `DownloadReportButton` (gradient prominent button with inline spinner) in `lib/screens/labs_radiology/orders/components/download_report_button.dart`
- [ ] T065 [P] [US2] Create `CancelOrderDialog` (title, body, optional reason field max 500 chars, destructive Cancel CTA) in `lib/screens/labs_radiology/orders/components/cancel_order_dialog.dart`
- [ ] T066 [US2] Create `TestOrderDetailController` in `lib/screens/labs_radiology/orders/test_order_detail_controller.dart` with `order`, `isLoading/isCancelling/isDownloadingReport`, `fetchOrder`, `refresh`, `cancelOrder(reason)` (calls `cancelTestOrder` then refreshes), `downloadReport()` (delegates to `ReportDownloadService` and shows toast on failure)
- [ ] T067 [US2] Create `TestOrderDetailScreen` in `lib/screens/labs_radiology/orders/test_order_detail_screen.dart` (header + timeline + test info + facility info + slot info + notes + pricing + cancellation banner + action buttons + pull-to-refresh)

### Report download implementation

- [ ] T068 [US2] Implement native branch in `lib/screens/labs_radiology/shared/service/report_download_service.dart`: check Android storage permission via `permission_handler`, call `LabsRadiologyApis.downloadReport`, save bytes to `getApplicationDocumentsDirectory()` as `report_{referenceNumber}.pdf`, open via `OpenFilex.open(file.path)`; handle 404 / null url → toast `reportNotReady`
- [ ] T069 [US2] Implement Web branch in same file gated by `kIsWeb` (R-3): fetch bytes, build a Blob, anchor.click() to trigger browser Save As; return a stub File so callers don't crash and skip `open_filex`
- [ ] T070 [US2] Wire optimistic refresh after cancel: in `TestOrderDetailController.cancelOrder`, after success update local `order.value` and call `Get.find<TestOrdersListController>().refresh()` only if `Get.isRegistered<TestOrdersListController>()` (R-10)
- [ ] T071 [US2] In `LabsRadiologyHubScreen` (T036), wire the "My Test Orders" quick-action to `Get.to(() => const TestOrdersListScreen())`
- [ ] T072 [P] [US2] (Optional) Update `lib/utils/push_notification_service.dart` to deep-link to `TestOrderDetailScreen(orderId: payload['order_id'])` when notification `type == 'test_order_status_changed'` per spec §14

**Checkpoint**: User Stories 1 AND 2 both work independently. Patients can book and follow up on orders end-to-end.

---

## Phase 5: User Story 3 — Discover Tests by Category or Search (Priority: P3)

**Goal**: Patient browses test categories, drills into a category, views test details, and can start a booking from the test detail.

**Independent Test**: From hub → "Browse Test Categories" → grid → tap a category → tests list (filtered) → tap a test → bottom sheet with prep instructions → tap "Book Test" → opens facilities offering it.

### Categories

- [ ] T073 [P] [US3] Create `CategorySearchBar` (200ms client-side debounce filter) in `lib/screens/labs_radiology/categories/components/category_search_bar.dart`
- [ ] T074 [P] [US3] Create `CategoryGridTile` (icon, name, "X tests") in `lib/screens/labs_radiology/categories/components/category_grid_tile.dart`
- [ ] T075 [US3] Create `TestCategoriesController` in `lib/screens/labs_radiology/categories/test_categories_controller.dart` with `categories`, `filteredCategories`, `searchQuery`, `fetchCategories()`, `onSearchChanged(query)`; implements 7-day GetStorage TTL envelope cache per R-6 with key `labs_radiology.test_categories`
- [ ] T076 [US3] Create `TestCategoriesScreen` in `lib/screens/labs_radiology/categories/test_categories_screen.dart` with search bar + 2-column shimmer grid + retry on error + empty state

### Tests catalog

- [ ] T077 [P] [US3] Create `PricePill` (gradient background) in `lib/screens/labs_radiology/tests/components/price_pill.dart`
- [ ] T078 [P] [US3] Create `PrepInstructionsChip` in `lib/screens/labs_radiology/tests/components/prep_instructions_chip.dart`
- [ ] T079 [P] [US3] Create `LabTestTile` (name, category chip, 1-line description, price pill, optional Imaging badge, turnaround chip) in `lib/screens/labs_radiology/tests/components/lab_test_tile.dart`
- [ ] T080 [US3] Create `LabTestsListController` in `lib/screens/labs_radiology/tests/lab_tests_list_controller.dart` with `categoryId`, `facilityId`, `tests`, pagination state, 400ms server-side search debounce — uses `LabsRadiologyApis.getLabTests`
- [ ] T081 [US3] Create `LabTestsListScreen` in `lib/screens/labs_radiology/tests/lab_tests_list_screen.dart` with sticky search + paginated list + pull-to-refresh + empty state; constructor accepts `int? categoryId, int? facilityId`
- [ ] T082 [US3] Create `LabTestDetailSheet` in `lib/screens/labs_radiology/tests/lab_test_detail_sheet.dart` (bottom sheet: full description + prep + turnaround + price + "Book Test" CTA)

### Wire-in

- [ ] T083 [US3] In `LabsRadiologyHubScreen` (T036), wire the "Browse Test Categories" quick-action to `Get.to(() => const TestCategoriesScreen())` and the "All Tests" quick-action to `Get.to(() => const LabTestsListScreen())`
- [ ] T084 [US3] In `LabTestDetailSheet` Book Test handler: if facility context is unset, `Get.to(() => LabsRadiologyHubScreen(prefilterTestId: t.id))`; if facility context is set, `Get.to(() => SlotSelectionScreen(facility: f, labTest: t))`. In `LabsRadiologyHubController`, when `prefilterTestId` is non-null, pass it as `labTestId` to `searchLabs` per `contracts/api-endpoints.md §1`

**Checkpoint**: All three user stories ship independently. Patient can enter the flow from a facility OR from a test.

---

## Phase 6: Polish & Cross-Cutting Concerns

- [ ] T085 [P] Run `flutter analyze` from repo root; fix any new warnings introduced by the module so the count is unchanged from pre-feature baseline (Constitution §Development Workflow, SC-007). Pre-existing warnings (Radio deprecation in `payment_screen.dart`, AppBarTheme color) MUST NOT be touched
- [ ] T086 [P] Manual QA: switch app to Arabic and verify all 8 screens, including calendar strip and slot grid, mirror correctly RTL (FR-024, SC-005)
- [ ] T087 [P] Manual QA: toggle dark mode and verify status chips, slot states (available/selected/unavailable), gradient buttons, and cards keep adequate contrast on every screen (FR-025, SC-005)
- [ ] T088 [P] Manual QA on Chrome (`flutter run -d chrome`): verify report download triggers a browser Save As (R-3 graceful degradation, Constitution I)
- [ ] T089 [P] Run the Android walkthrough in `quickstart.md` end-to-end including slot-conflict simulation, network-failure on confirm, and permission-denied on download
- [ ] T090 [P] Run the secondary-platform walkthrough (iOS simulator OR Chrome) for at least the dashboard → hub → slot → confirmation path (Constitution I)
- [ ] T091 Run `grep -r "v1/admin/facility-bookings" lib/` from repo root; verify zero matches (Forbidden API contract from `contracts/api-forbidden-fields.md`)

---

## Dependencies & Execution Order

### Phase Dependencies

- **Phase 1 (Setup)**: No dependencies. T001 (open_filex) gates T020/T068/T069 (download service). T003 (endpoint constants) gates T019.
- **Phase 2 (Foundational)**: Depends on Phase 1. **Blocks all user-story phases.** T019 (API service) depends on all model tasks T006–T018.
- **Phase 3 (US1)**: Depends on Phase 2. T052 gated on T004 (R-1 confirmation). T055 gated on T005 (R-4 confirmation).
- **Phase 4 (US2)**: Depends on Phase 2. Independent of US1 (the orders screen can be built and demoed standalone with seeded backend data). Wire-in T071 needs T036 (hub), but the screens themselves do not.
- **Phase 5 (US3)**: Depends on Phase 2. Wire-ins T083/T084 need T036 and T048 respectively. Otherwise independent.
- **Phase 6 (Polish)**: Depends on whichever stories are in scope for the current delivery.

### Within each user story

- Tests (when present) are written first. They MAY fail until implementation lands; they are not strictly TDD-gated for this module since tests target pure logic that lands in Phase 2.
- Components → Controller → Screen → Wire-in.

### Parallel opportunities

- Phase 1: T004 and T005 (backend questions) can run in parallel with each other and with T001/T002/T003.
- Phase 2: T006–T018 (models) all parallel — different files, only depending on enums T006/T007 which run first. T020–T025 (service skeleton, locale files, badges) all parallel after T006/T007.
- Phase 3 (US1): All `[P]`-tagged component tasks in each section parallel within section. Hub components (T028–T034), facility-detail components (T037–T041), slot components (T044–T046), and confirmation components (T049–T051) are four cleanly independent component clusters — different folders.
- Phase 4 (US2): T057/T058 (tests), T059/T060 (list components), T063/T064/T065 (detail components), T072 (push deep link) parallel.
- Phase 5 (US3): T073/T074 (categories components) parallel; T077/T078/T079 (tests components) parallel.
- Phase 6: T085–T090 all parallel.

### Cross-story decoupling

- US1 hub leaves quick-action taps as no-op toasts initially. US2 wires "My Test Orders" (T071); US3 wires "Browse Test Categories" and "All Tests" (T083). This keeps each story independently testable.
- The Booking Success screen's "View Order" button (T054) is conditional on `Get.isRegistered<TestOrderDetailController>()` so US1 ships without US2.

---

## Parallel Example: User Story 1 (Hub component cluster)

```bash
# After Foundational phase, dispatch hub components together:
Task: "Create FacilityTypeTabs in lib/screens/labs_radiology/hub/components/facility_type_tabs.dart"     # T028
Task: "Create FacilitySearchBar in lib/screens/labs_radiology/hub/components/facility_search_bar.dart"   # T029
Task: "Create LocationFilterChip in lib/screens/labs_radiology/hub/components/location_filter_chip.dart" # T030
Task: "Create ServiceBadge in lib/screens/labs_radiology/hub/components/service_badge.dart"              # T031
Task: "Create LabCard in lib/screens/labs_radiology/hub/components/lab_card.dart"                        # T032
Task: "Create RadiologyCenterCard in lib/screens/labs_radiology/hub/components/radiology_center_card.dart" # T033
Task: "Create EmptyFacilitiesWidget in lib/screens/labs_radiology/hub/components/empty_facilities_widget.dart" # T034
# Then T035 (controller), then T036 (screen) — sequential, same screen surface.
```

---

## Implementation Strategy

### MVP First (US1 only)

1. Phase 1 (Setup) — gates everything; T004/T005 backend questions can start in parallel with implementation work and resolve before T052/T055.
2. Phase 2 (Foundational) — full models + API surface + locale + badges. **Critical** — blocks all stories.
3. Phase 3 (US1) — 31 tasks. Ends with a complete facility-first booking flow plus dashboard tile.
4. **Stop and validate**: walk Sections 1–2 of `quickstart.md`. This is a demo-able MVP.

### Incremental Delivery

- After MVP, ship US2 (orders + download). Ends Section 3 of quickstart.
- Then US3 (discovery). Ends Section 1 (steps 8–11) and the test-first booking path.
- Polish (Phase 6) happens at any point but is required before final release.

### Parallel Team Strategy

- Once Phase 2 completes, US1, US2, and US3 can be split across three developers with minimal collision (different folders, different controllers, only the hub `quick-action wire-in` tasks T071/T083 touch the hub screen file).

---

## Notes

- All user-facing strings go through `locale.value.<key>` (Constitution V).
- No `setState`; all reactive state via `.obs` + `Obx()` (Constitution III).
- All HTTP through `buildHttpResponse()` / `handleResponse()` (Constitution IV).
- No hardcoded URLs — all endpoints from `lib/utils/api_end_points.dart` (Constitution IV).
- No new state-management library, no new payment abstraction, no wrapper classes around `http` (Constitution VII).
- Forbidden request fields and admin endpoints: enforce via T091 grep guard plus T026 unit test.
- Backend questions T004 and T005 are non-blocking until T052/T055 — start them on day 1.

---

## Task Count Summary

| Phase | Count | Notes |
|---|---|---|
| Phase 1 — Setup | 5 | Includes 2 backend questions |
| Phase 2 — Foundational | 20 | 13 models + 1 API service + 1 download skeleton + 2 locale + 3 badges |
| Phase 3 — US1 (MVP) | 31 | 2 tests + hub (9) + facility detail (7) + slot (5) + confirmation (6) + dashboard (1) + slot-conflict (1) |
| Phase 4 — US2 | 16 | 2 tests + list (4) + detail (5) + download impl (2) + cancel + wire-in + push (1 optional) |
| Phase 5 — US3 | 12 | Categories (4) + tests catalog (6) + 2 wire-ins |
| Phase 6 — Polish | 7 | analyze + RTL + dark + Web + 2 walkthroughs + grep guard |
| **Total** | **91** | |

### Parallel-eligible tasks: 60 (all `[P]`-tagged)

### Independent test criteria

- **US1**: `Dashboard → Hub → Lab → Test → Slot → Confirm → Reference number copied`
- **US2**: `Hub → My Orders → filter Pending → Cancel with reason → status updates; open Completed → Download → PDF opens`
- **US3**: `Hub → Browse Categories → Category → Test sheet with prep instructions → Book Test → Facility list filtered by test`

### Suggested MVP scope

**User Story 1 only** (Phases 1 + 2 + 3). Validates the full booking value proposition end-to-end with the dashboard entry point. Total: 56 tasks.

### Format validation

All 91 tasks follow `- [ ] T### [P?] [Story?] Description with file path`. Setup, Foundational, and Polish tasks correctly omit story labels; user-story phases all carry `[US1]`/`[US2]`/`[US3]` labels. All implementation tasks include exact file paths.
