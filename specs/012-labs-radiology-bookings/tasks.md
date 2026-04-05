# Tasks: Labs & Radiology Booking System

**Input**: Design documents from `/specs/012-labs-radiology-bookings/`
**Prerequisites**: plan.md ✅, spec.md ✅, research.md ✅, data-model.md ✅, contracts/ ✅, quickstart.md ✅

**Status**: Phase-based implementation with 6 user stories prioritized as P1 (4 stories) and P2 (2 stories)

**Total Tasks**: ~85 tasks organized by user story for independent implementation and testing

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3, US4, US5, US6)
- All paths assume Flutter single-project structure in `lib/`

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Initialize project structure, API endpoints, and shared resources

**Checkpoint**: All paths, endpoints, and localization keys defined before foundational phase

- [x] T001 Create lib/api/lab_test_apis.dart with method signatures for getLabTestCategories(), getLabTests(), getTestOrder(), createTestOrder()
- [x] T002 Create lib/api/facility_booking_apis.dart with method signatures for getLabSlots(), getRadiologyCenterSlots(), createFacilityBooking(), getFacilityBookings()
- [x] T003 Update lib/utils/api_end_points.dart with all 13 new endpoints: labTestCategories, labTests, labTestDetail, testOrders, testOrderDetail, testOrderCancel, testOrderReportDownload, facilityBookings, facilityBookingDetail, facilityBookingCancel, labSlots, radiologyCenterSlots
- [x] T004 [P] Create lib/locale/ language keys in BaseLanguage: add ~30 keys for labs/radiology/booking terms (labTests, testName, sampleType, turnaroundTime, bookingNumber, selectDate, patientName, etc.)
- [x] T005 [P] Add English translations to lib/locale/language_en.dart for all new keys
- [x] T006 [P] Add Arabic translations to lib/locale/language_ar.dart for all new keys
- [x] T007 Create lib/models/ directory structure and placeholder files for all 8 models (LabTestCategory, LabTest, TestOrder, TestOrderItem, FacilityBooking, Lab, RadiologyCenter, BookingSlot)
- [x] T008 Update CLAUDE.md documentation with new feature summary, added endpoints, and key architectural decisions

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core shared models and services that ALL user stories depend on

**⚠️ CRITICAL**: No user story work can begin until this phase is complete

**Checkpoint**: All foundational models and API services working with mock/live API responses

- [x] T009 [P] Implement LabTestCategory model in lib/models/lab_test_category_model.dart with fromJson(), toJson() (7 fields)
- [x] T010 [P] Implement LabTest model in lib/models/lab_test_model.dart with fromJson(), toJson() (14 fields including category relationship)
- [x] T011 [P] Implement TestOrderItem model in lib/models/test_order_item_model.dart with fromJson(), toJson() (11 fields)
- [x] T012 [P] Implement FacilityBooking model in lib/models/facility_booking_model.dart with fromJson(), toJson() (13 fields, polymorphic facility reference)
- [x] T013 [P] Implement BookingSlot model in lib/models/booking_slot_model.dart with fromJson(), toJson() (5 fields: time, available)
- [x] T014 Implement getLabTestCategories() in lib/api/lab_test_apis.dart (public, no auth)
- [x] T015 Implement getLabTests() in lib/api/lab_test_apis.dart with filtering (public, category_id, department, search, pagination)
- [x] T016 Implement getLabTestDetail() in lib/api/lab_test_apis.dart (public endpoint for single test)
- [x] T017 Implement getLabSlots() in lib/api/facility_booking_apis.dart with date parameter (public endpoint)
- [x] T018 Implement getRadiologyCenterSlots() in lib/api/facility_booking_apis.dart with date parameter (public endpoint)
- [x] T019 Create lib/utils/lab_test_constants.dart with enums: SampleType (blood, urine, stool, tissue, imaging, swab, other), Department (laboratory, radiology), Priority (routine, urgent, stat), OrderStatus (pending, confirmed, sample_collected, processing, completed, delivered, cancelled), PaymentStatus (unpaid, partial, paid)
- [x] T020 Create shared validation utility in lib/utils/form_validators.dart with methods for: validateDate(futureOnly), validateTime(HHMMFormat), validatePatientName(), validatePhoneNumber(), validateClinicalNotes(), validateBookingDate()
- [x] T021 [P] Create FilterParams-style model for LabTestFilter in lib/screens/lab_test/model/lab_test_filter.dart with: categoryId, department, searchQuery, currentPage

**Checkpoint**: Foundation ready - all user story phases can now proceed in parallel

---

## Phase 3: User Story 1 - Browse and Search Lab Tests (Priority: P1) 🎯

**Goal**: Users can discover and search available lab tests publicly without authentication

**Independent Test**: User can browse test categories, filter by category/department, search by name, and view test details without signing in

**Tasks for User Story 1**:

- [x] T022 Implement TestOrder model stub in lib/models/test_order_model.dart (core fields: id, orderNumber, patientId, status, totalAmount, items[], clinicalNotes)
- [x] T023 Implement Lab model in lib/models/lab_model.dart (fields: id, name, address, phone, isActive, isHoliday)
- [x] T024 Implement RadiologyCenter model in lib/models/radiology_center_model.dart (same structure as Lab)
- [x] T025 Create LabTestCategoriesController in lib/screens/lab_test/lab_test_categories_controller.dart with GetX reactive state: isLoading, categories list, errorMessage
- [x] T026 Create LabTestListController in lib/screens/lab_test/lab_test_list_controller.dart extending LabTestCategoriesController: add filtering (categoryId, department, searchQuery), pagination (currentPage, perPage), loadTests() method
- [x] T027 Implement loadCategories() and loadTests() in controllers (call respective APIs)
- [x] T028 Create LabTestCategoriesScreen in lib/screens/lab_test/lab_test_categories_screen.dart displaying paginated category grid
- [x] T029 Create LabTestListScreen in lib/screens/lab_test/lab_test_list_screen.dart with category/department filter tabs and search bar
- [x] T030 [P] Create LabTestCategoryCard component in lib/screens/lab_test/components/lab_test_category_card.dart (displays: icon, name, test_count, leading to test list)
- [x] T031 [P] Create LabTestCard component in lib/screens/lab_test/components/lab_test_card.dart (displays: name, code, price, sample_type, turnaround_time with onTap to details)
- [x] T032 Create LabTestDetailScreen in lib/screens/lab_test/lab_test_detail_screen.dart showing full test info (description, preparation_instructions, reference_range, category details)
- [x] T033 Create LabTestDetailController in lib/screens/lab_test/lab_test_detail_controller.dart with: selectedTest observable, addToCart() method, navigateToOrder()
- [x] T034 [US1] Integration test in test/integration/lab_test_browsing_test.dart: verify can load categories, filter tests, search tests, view test details (no auth required)
- [x] T035 [US1] Add loading state UI with LoaderWidget, error state with EmptyErrorStateWidget

**Checkpoint**: User Story 1 complete - users can browse and search tests independently

---

## Phase 4: User Story 2 - Order Multiple Lab Tests (Priority: P1)

**Goal**: Authenticated patients can create test orders with multiple tests, clinical notes, and priority selection

**Independent Test**: Authenticated user can select tests, add notes, create order, receive order number, and see confirmation

**Tasks for User Story 2**:

- [x] T036 [P] Implement full TestOrder model in lib/models/test_order_model.dart (add: orderId, orderedTests[], items relationship, createdAt, updatedAt)
- [x] T037 Implement createTestOrder() in lib/api/lab_test_apis.dart (POST /v1/test-orders with items[], clinicalNotes, priority, doctorId)
- [x] T038 Implement getTestOrders() in lib/api/lab_test_apis.dart (GET /v1/test-orders with status/pagination filtering)
- [x] T039 Implement getTestOrderDetail() in lib/api/lab_test_apis.dart (GET /v1/test-orders/{id})
- [x] T040 Implement cancelTestOrder() in lib/api/lab_test_apis.dart (POST /v1/test-orders/{id}/cancel with cancellation reason)
- [x] T041 Create CreateTestOrderController in lib/screens/lab_test/create_test_order_controller.dart with GetX state: selectedTests list, clinicalNotes, priority, isLoading, total/discount/finalAmount calculations
- [x] T042 Add calculateOrderTotal() method to controller (sum test prices, apply discounts)
- [x] T043 Add validateOrderForm() to controller (minimum 1 test, notes max 2000 chars, valid priority)
- [x] T044 Implement createOrder() method in controller (call API, handle 422 validation errors, show toast, navigate)
- [x] T045 Create CreateTestOrderScreen in lib/screens/lab_test/create_test_order_screen.dart with: order summary, selected tests list, clinical notes input, priority selector, total price display
- [x] T046 Create OrderSummarySection component in lib/screens/lab_test/components/order_summary_section.dart (shows selected tests with prices, total, discount, final amount)
- [x] T047 Create TestPrioritySelector component in lib/screens/lab_test/components/test_priority_selector.dart (radio/toggle for routine/urgent/stat)
- [x] T048 Create TestOrderCard component in lib/screens/lab_test/components/test_order_card.dart (displays: order#, tests count, status badge, total amount, date)
- [x] T049 Create TestOrderStatusBadge component in lib/screens/lab_test/components/test_order_status_badge.dart (colors per status: pending=orange, confirmed=blue, processing=purple, completed=green, cancelled=gray)
- [x] T050 Create TestOrderDetailScreen in lib/screens/lab_test/test_order_detail_screen.dart showing: order number, status, items with prices, clinical notes, patient info, doctor info
- [x] T051 Create TestOrderDetailController in lib/screens/lab_test/test_order_detail_controller.dart with: loadOrderDetail(), cancelOrder() with reason dialog
- [ ] T052 [US2] Integration test in test/integration/test_order_creation_test.dart: create order with 2+ tests, verify order number generated, verify total calculated, verify success notification
- [ ] T053 [US2] Unit test in test/unit/test_order_pricing_test.dart: test order total calculation logic, discount application, final_amount accuracy
- [x] T054 [US2] Add proper error handling for 422 validation errors (show field-specific error messages)
- [x] T055 [US2] Add success dialog/snackbar with order number and next steps

**Checkpoint**: User Stories 1 & 2 complete - users can browse, search, and create orders

---

## Phase 5: User Story 4 - Book Lab/Radiology Appointment (Priority: P1)

**Goal**: Authenticated patients can book appointments at labs/radiology centers with available slot selection

**Independent Test**: Authenticated user can select facility, view calendar, choose available slot, enter details, create booking with confirmation

**Tasks for User Story 4**:

- [x] T056 Implement getLabSlots() and getRadiologyCenterSlots() full implementation in facility_booking_apis.dart returning BookingSlot models with availability status
- [x] T057 Implement createFacilityBooking() in lib/api/facility_booking_apis.dart (POST /v1/facility-bookings with: type, facility_id, date, time, patientName, patientPhone, notes)
- [x] T058 Implement getFacilityBookings() in lib/api/facility_booking_apis.dart (GET /v1/facility-bookings with type/status/pagination filters)
- [x] T059 Implement getFacilityBookingDetail() in lib/api/facility_booking_apis.dart (GET /v1/facility-bookings/{id})
- [x] T060 Implement cancelFacilityBooking() in lib/api/facility_booking_apis.dart (POST /v1/facility-bookings/{id}/cancel)
- [x] T061 Create FacilityBookingController in lib/screens/facility_booking/facility_booking_controller.dart with GetX state: selectedFacility, selectedDate, selectedSlots, facilityType (lab|radiology), isLoading
- [x] T062 Create FacilitySlotCalendarController in lib/screens/facility_booking/facility_slots_controller.dart with: loadSlots(date), getAvailableSlots(), getBookedSlots()
- [x] T063 Create BookingDetailsController in lib/screens/facility_booking/booking_detail_controller.dart with: patientName, patientPhone, notes validation
- [x] T064 Implement validateBookingForm() method (validate patient name/phone, check slot selection)
- [x] T065 Implement createBooking() method calling API with proper error handling (422 for unavailable slot, 403 for permission)
- [x] T066 Create FacilitySelectionScreen in lib/screens/facility_booking/facility_selection_screen.dart showing: list of available labs/radiology centers, search/filter by location, "View Slots" button
- [x] T067 Create FacilitySlotCalendarScreen in lib/screens/facility_booking/facility_slot_calendar_screen.dart with: calendar widget showing available dates, time slot grid for selected date
- [x] T068 Create BookingDetailsScreen in lib/screens/facility_booking/booking_details_screen.dart with: patient name/phone inputs, notes field, selected facility/slot display, "Confirm Booking" button
- [x] T069 Create BookingConfirmationScreen in lib/screens/facility_booking/booking_confirmation_screen.dart showing: booking number (BK-YYYY-NNNN), facility details, appointment date/time, status
- [x] T070 [P] Create FacilityCard component in lib/screens/facility_booking/components/facility_card.dart (displays: facility name, address, phone, "View Slots" button)
- [x] T071 [P] Create SlotCalendar component in lib/screens/facility_booking/components/facility_slot_calendar.dart (calendar showing available dates with slot counts)
- [x] T072 [P] Create SlotTimeGrid component in lib/screens/facility_booking/components/slot_time_grid.dart (grid of time slots with available/booked status, selectable)
- [x] T073 [P] Create FacilityBookingCard component in lib/screens/facility_booking/components/facility_booking_card.dart (displays: booking#, facility, date/time, status badge, "Cancel" button)
- [x] T074 [P] Create BookingStatusBadge component in lib/screens/facility_booking/components/booking_status_badge.dart (colors per status: pending=orange, confirmed=blue, completed=green, cancelled=gray, no_show=red)
- [ ] T075 [US4] Integration test in test/integration/facility_booking_flow_test.dart: load slots, select date/time, enter patient details, create booking, verify booking number generated
- [ ] T076 [US4] Unit test in test/unit/booking_slot_validation_test.dart: test slot availability logic, date validation (must be future), time validation (HH:MM format)
- [x] T077 [US4] Add error handling for slot unavailable (422) with UI message to retry other slots
- [x] T078 [US4] Add success dialog with booking confirmation details and facility contact info

**Checkpoint**: User Stories 1, 2, & 4 complete - users can browse, order, and book appointments

---

## Phase 6: User Story 6 - Access Control by Role (Priority: P1)

**Goal**: Ensure proper RBAC so different user roles see only permitted data (patients see own, doctors see assigned, admins see all)

**Independent Test**: Different user roles accessing lists/details correctly filtered, unauthorized access returns 403

**Tasks for User Story 6**:

- [ ] T079 Add roleFilter logic to TestOrderListController to filter getTestOrders() results by user role: patient (own), doctor (assigned), admin (all)
- [ ] T080 Add roleFilter logic to FacilityBookingController list methods for same RBAC pattern
- [ ] T081 Implement 403 error handling in both controllers (unauthorized users shown error screen with message)
- [ ] T082 Add permission check before showing "Cancel Order" button (only if user is patient/owner or admin)
- [ ] T083 Add permission check before showing "Cancel Booking" button (only if user is patient/owner or admin)
- [ ] T084 Add role-based filtering to detail screens (TestOrderDetailScreen, BookingDetailScreen) - prevent viewing others' data
- [ ] T085 Add audit logging for access attempts (use existing Crashlytics pattern) for high-risk RBAC operations
- [ ] T086 [US6] Integration test in test/integration/rbac_test.dart: test patient, doctor, admin roles see correct filtered results, cannot access others' records
- [ ] T087 [US6] Test 403 error handling when unauthorized user tries to view detail

**Checkpoint**: All P1 user stories complete with RBAC enforced - MVP ready

---

## Phase 7: User Story 3 - Browse Radiology Services (Priority: P2)

**Goal**: Users can discover available radiology services (imaging tests) separately from lab tests with proper categorization

**Independent Test**: User can view radiology services filtered by department, search radiology-specific scans, view radiology service details

**Tasks for User Story 3**:

- [x] T088 Update LabTest model to properly handle department filtering (ensure "radiology" filter works on list API)
- [x] T089 Create RadiologyTestsController in lib/screens/lab_test/radiology_tests_controller.dart extending LabTestListController with pre-filtered department="radiology"
- [x] T090 Create RadiologyTestsScreen in lib/screens/lab_test/radiology_tests_screen.dart similar to LabTestListScreen but department-specific
- [x] T091 Create RadiologyServiceCard component in lib/screens/lab_test/components/radiology_service_card.dart (displays radiology-specific fields: scan type, equipment, imaging format)
- [x] T092 Create RadiologyDetailScreen in lib/screens/lab_test/radiology_detail_screen.dart with radiology-specific preparation instructions, safety info, contrast requirements
- [ ] T093 [US3] Integration test in test/integration/radiology_browsing_test.dart: verify radiology services shown, lab tests filtered out, search finds radiology tests
- [x] T094 [US3] Add radiology-specific localization strings (scanType, contrastRequired, imagingFormat, radiationDose)

**Checkpoint**: P2 stories starting - radiology catalog browsing available

---

## Phase 8: User Story 5 - View and Manage Orders/Bookings (Priority: P2)

**Goal**: Users can track test orders and facility bookings, view status/results, and manage cancellations

**Independent Test**: User can list filtered orders/bookings, view full details, download reports (if completed), cancel pending items with reason

**Tasks for User Story 5**:

- [x] T095 Create TestOrderListScreen in lib/screens/lab_test/test_order_list_screen.dart with: order list filtered by status, tabs (All/Pending/Completed), order cards
- [x] T096 Create TestOrderListController in lib/screens/lab_test/test_order_list_controller.dart with: loadOrders(), filterByStatus(), RBAC filtering
- [x] T097 Implement getTestOrderReport() in lab_test_apis.dart (GET /v1/test-orders/{id}/report/download returns PDF binary)
- [x] T098 Add downloadReport() method to TestOrderDetailController (call API, save/open PDF file)
- [x] T099 Create CancellationReasonDialog component in lib/screens/lab_test/components/cancellation_reason_dialog.dart (text input for reason, max 500 chars)
- [x] T100 Add cancelOrderWithReason() method to TestOrderDetailController (show dialog, submit reason with API call)
- [x] T101 Create MyBookingsScreen in lib/screens/facility_booking/my_bookings_screen.dart with: booking list filtered by type/status, booking cards
- [x] T102 Create MyBookingsController in lib/screens/facility_booking/my_bookings_controller.dart with: loadBookings(), filterByType(), filterByStatus(), RBAC filtering
- [x] T103 Add cancelBookingWithReason() to MyBookingsController with dialog
- [x] T104 Create BookingDetailScreen in lib/screens/facility_booking/booking_detail_screen.dart (full details: facility info, appointment time, patient details, status, reschedule option)
- [ ] T105 [US5] Integration test in test/integration/order_management_test.dart: load orders, filter by status, view details, cancel order
- [ ] T106 [US5] Integration test in test/integration/booking_management_test.dart: load bookings, filter by type, view details, cancel booking
- [ ] T107 [US5] Test PDF report download functionality (mock file system)
- [ ] T108 [US5] Add proper error states for failed downloads/operations

**Checkpoint**: P2 stories complete - full order/booking lifecycle supported

---

## Phase 9: Polish & Cross-Cutting Concerns

**Purpose**: Improvements affecting multiple stories, testing, performance, and documentation

**Checkpoint**: Feature complete and ready for release

- [ ] T109 [P] Run all existing test suites to ensure no regressions with new code
- [ ] T110 [P] Add unit tests for all utility functions (validators, constants, filters)
- [ ] T111 [P] Performance testing: verify test search <1s, slot availability <500ms, order creation <5min
- [ ] T112 [P] Accessibility audit: verify semantic labels, ARIA, focus states, contrast ratios on all new screens
- [ ] T113 [P] Dark mode testing: verify all new screens respect isDarkMode.value with proper design tokens
- [x] T114 Verify localization completeness: all UI strings use locale.value.*, RTL layout works for Arabic
- [x] T115 Code cleanup: remove debug logging, unused imports, format code with existing style
- [x] T116 Update lib/utils/api_end_points.dart to remove placeholder endpoints
- [ ] T117 Add feature-specific error logging for Crashlytics (sanitized for patient privacy)
- [ ] T118 Verify double-booking prevention: test concurrent booking scenarios, verify 100% success rate
- [ ] T119 Test status workflow transitions: verify no invalid state transitions, all status changes logged
- [ ] T120 Verify pricing accuracy: run pricing tests with edge cases (discounts, bulk orders, refunds)
- [ ] T121 Cross-platform testing: run on Android emulator, iOS simulator, Chrome web
- [ ] T122 Update CLAUDE.md with completed feature status and any maintenance notes
- [ ] T123 Create feature summary for release notes
- [ ] T124 Run final integration test suite covering all 6 user stories end-to-end
- [ ] T125 Performance optimization: implement test catalog caching, lazy loading for large lists
- [ ] T126 Document API integration assumptions and configuration in quickstart.md review

---

## Dependencies & Execution Order

### Phase Dependencies

- **Phase 1 Setup**: No dependencies - can start immediately
- **Phase 2 Foundational**: Depends on Phase 1 completion - **BLOCKS ALL USER STORIES**
- **Phase 3-6 (P1 Stories)**: All depend on Phase 2 - can proceed in parallel after Phase 2
- **Phase 7-8 (P2 Stories)**: All depend on Phase 2, can start after Phase 2 completes
- **Phase 9 Polish**: Depends on desired user stories being complete

### User Story Dependencies

```
Phase 1 (Setup)
    ↓
Phase 2 (Foundational)
    ├─→ Phase 3 (US1: Browse Tests) [P1] ─┐
    ├─→ Phase 4 (US2: Order Tests) [P1]   │
    ├─→ Phase 5 (US4: Book Facility) [P1] │ Can run in parallel
    ├─→ Phase 6 (US6: RBAC) [P1] ─────────┤ after Phase 2
    ├─→ Phase 7 (US3: Radiology) [P2]     │
    └─→ Phase 8 (US5: Manage Orders) [P2]─┘
           ↓
Phase 9 (Polish & Release)
```

### Within Each Phase

- **Models before Services**: Create all data models before implementing API services
- **Services before Screens**: Implement API methods before building UI
- **Tests before Implementation**: Write contract/integration tests first, ensure they FAIL before implementing
- **Core before Integrations**: Implement core functionality before cross-story integrations

### Parallel Opportunities

**Phase 1**: All tasks [P] can run in parallel (API definitions, localization)

**Phase 2**: Model creation tasks [P] can run in parallel

**Phase 3-8**: Once Phase 2 is complete, all user stories can run in parallel (if team capacity allows):
- Developer A: Phase 3 (Browse Tests)
- Developer B: Phase 4 (Order Tests)
- Developer C: Phase 5 (Book Facility)
- Etc.

**Within each Phase**: All [P] marked tasks can run in parallel (different files)

---

## Parallel Example: Phase 3 (US1)

```bash
# Run these in parallel:
Task T022-T024: Create models (different files)
Task T030-T031: Create components (different files)

# Then run sequentially:
Task T025-T027: Create controller and load logic
Task T028-T032: Create screens (depends on controller, components)
```

---

## Implementation Strategy

### MVP Path (P1 User Stories Only)

1. ✅ Complete Phase 1: Setup (API endpoints, models, localization)
2. ✅ Complete Phase 2: Foundational (shared models, API services)
3. ✅ Complete Phase 3: US1 (Browse Tests) → **TEST INDEPENDENTLY**
4. ✅ Complete Phase 4: US2 (Order Tests) → **TEST INDEPENDENTLY**
5. ✅ Complete Phase 5: US4 (Book Facility) → **TEST INDEPENDENTLY**
6. ✅ Complete Phase 6: US6 (RBAC) → **TEST INDEPENDENTLY**
7. ✅ Complete Phase 9 Polish (minimum viable polish for release)
8. **🚀 STOP AND RELEASE** - MVP ready with 4 core P1 stories

### Extended Delivery (Add P2 Stories)

9. Complete Phase 7: US3 (Radiology) → TEST
10. Complete Phase 8: US5 (Manage Orders/Bookings) → TEST
11. Complete Phase 9 Polish (full polish)
12. **🚀 RELEASE 2** - Full featured release

### Parallel Team Strategy (4 developers)

After Phase 1 & 2 complete:
- **Developer 1**: Phase 3 (US1) + Phase 7 (US3)
- **Developer 2**: Phase 4 (US2) + Phase 8 (US5)
- **Developer 3**: Phase 5 (US4)
- **Developer 4**: Phase 6 (US6) + Phase 9 (Polish)

Each developer works independently, integration happens after Phase 2 foundation.

---

## Testing Notes

- **Unit Tests**: Pricing calculations, validators, state transitions
- **Widget Tests**: Individual components and screens in isolation
- **Integration Tests**: Full user journeys (browse → order → book)
- **RBAC Tests**: Different roles accessing lists/details correctly filtered
- **API Contract Tests**: All 13 endpoints return expected JSON shapes
- **Cross-platform Tests**: Run on Android, iOS, Chrome
- **Concurrent Tests**: Double-booking prevention, simultaneous API calls

---

## Definition of Done (per User Story)

Each user story is complete when:

1. ✅ All tasks in the story phase marked [X]
2. ✅ All integration tests passing
3. ✅ RBAC verified (correct users see correct data)
4. ✅ Error handling verified (422/403/404 responses handled)
5. ✅ Localization verified (strings come from locale.value.*)
6. ✅ Dark mode verified (respects isDarkMode.value)
7. ✅ Tested on 2+ platforms (Android + iOS OR iOS + Web minimum)
8. ✅ No console errors or warnings
9. ✅ Code reviewed and approved
10. ✅ Story can be demo'd independently to stakeholders

---

## Notes

- **[P] marker**: Tasks marked [P] are parallelizable (different files, no wait-on dependencies)
- **[Story] label**: Maps each task to user story for traceability
- **Nested dependencies**: Tasks within a phase may have dependencies (noted in descriptions)
- **Stop at checkpoints**: After completing each phase, verify it works before proceeding
- **Incremental delivery**: Deploy after each user story completes, don't wait for entire feature
- **Avoid**: Mixing stories in same phase, tasks affecting same file in parallel, untested code merges
