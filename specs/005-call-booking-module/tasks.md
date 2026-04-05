# Tasks: Call Booking Module

**Input**: Design documents from `/specs/005-call-booking-module/`
**Prerequisites**: plan.md (required), spec.md (required), research.md, data-model.md, contracts/

**Tests**: Not requested. Tests are OPTIONAL per constitution.

**Context**: This is a **brand new module** — no existing code. All files must be
created from scratch following patterns from lab_test, nurse, and icu modules.

**Organization**: Tasks grouped by user story for independent implementation.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (US1–US3)
- Exact file paths included in descriptions

---

## Phase 1: Setup (Project Structure & Infrastructure)

**Purpose**: Create directory structure, endpoint constants, color constants, and locale keys

- [x] T001 Create directory structure: lib/screens/call_booking/, lib/screens/call_booking/model/, lib/screens/call_booking/components/
- [x] T002 Add ~5 call booking endpoint constants to lib/utils/api_end_points.dart: getCallDoctors = 'v1/call-doctors', getCallDoctorServices = 'v1/call-doctors' (append /{id}/services), getCallSlots = 'v1/call-doctors' (append /{id}/slots), createCallBooking = 'v1/call-booking', getCallBookings = 'v1/call-booking' (for list if endpoint exists, or reuse appointments)
- [x] T003 [P] Add call booking colors to lib/utils/colors.dart: callTypeVideoColor (blue/indigo), callTypePhoneColor (green), callBookingConfirmedColor (green), callBookingCompletedColor (teal), callBookingCancelledColor (red)
- [x] T004 [P] Add call booking constants to lib/utils/constants.dart: CallTypeConst (video, phone), CallBookingStatusConst (confirmed, completed, cancelled), TransactionTypeConst (cash, stripe, razorpay, paypal, paystack, flutterwave, wallet)

**Checkpoint**: Infrastructure ready for model and API development

---

## Phase 2: Foundational (Models, API Methods, Locale Keys)

**Purpose**: Create all data models, API service methods, and locale keys

### Models

- [x] T005 Create CallDoctor and CallService models in lib/screens/call_booking/model/call_doctor_model.dart — CallDoctor with 18 fields (fromJson/toJson), CallService with 15 fields (fromJson/toJson), CallDoctorListResponse with pagination meta. Follow pattern from hospital_model.dart
- [x] T006 [P] Create TimeSlot model in lib/screens/call_booking/model/time_slot_model.dart — simple model with value (String, "09:00") and label (String, "9:00 AM"), fromJson/toJson, TimeSlotListResponse
- [x] T007 [P] Create CallBooking model in lib/screens/call_booking/model/call_booking_model.dart — 17 fields (id, userId, doctorId, appointmentDate, appointmentTime, callServiceId, bookingType, callType, meetingLink, servicePrice, serviceAmount, totalAmount, duration, status, startDateTime, createdAt, updatedAt), fromJson/toJson, CallBookingListResponse with pagination meta

### API Methods

- [x] T008 Add getCallDoctorList() method to lib/api/core_apis.dart — paginated GET with search param. Returns RxList<CallDoctor>. Follow pattern from getHospitalList()
- [x] T009 [P] Add getCallDoctorServices() method to lib/api/core_apis.dart — GET v1/call-doctors/{id}/services, returns List<CallService>
- [x] T010 [P] Add getCallSlots() method to lib/api/core_apis.dart — POST v1/call-doctors/{id}/slots with {appointment_date, call_service_id}, returns List<TimeSlot>
- [x] T011 [P] Add createCallBooking() method to lib/api/core_apis.dart — POST v1/call-booking with {doctor_id, call_service_id, appointment_date, appointment_time, transaction_type}, returns CallBooking (also extract meeting_link, call_type, service_name, duration, total_amount from response root)
- [x] T012 [P] Add getCallBookingList() method to lib/api/core_apis.dart — paginated GET (reuse existing appointment list with booking_type=call filter, or dedicated endpoint). Returns RxList<CallBooking>

### Locale Keys

- [x] T013 Add ~35 call booking locale key getters to lib/locale/languages.dart abstract class: callBooking, callDoctors, browseCallDoctors, myCallBookings, bookCall, videoConsultation, phoneConsultation, callServices, selectDate, selectTimeSlot, availableSlots, noSlotsAvailable, tryAnotherDate, bookingConfirmed, meetingLink, joinCall, callType, videoCall, phoneCall, durationLabel, startingFrom, originalPrice, discountLabel, finalPriceLabel, paymentMethodLabel, appointmentDate, appointmentTime, serviceName, totalAmountLabel, noCallDoctorsFound, noCallBookingsYet, selectService, confirmBooking, bookingDetails, transactionType
- [x] T014 [P] Add English translations for all T013 keys in lib/locale/language_en.dart
- [x] T015 [P] Add Arabic translations for all T013 keys in lib/locale/language_ar.dart
- [x] T016 [P] Add German translations for all T013 keys in lib/locale/language_de.dart
- [x] T017 [P] Add French translations for all T013 keys in lib/locale/language_fr.dart
- [x] T018 [P] Add Hindi translations for all T013 keys in lib/locale/language_hi.dart

**Checkpoint**: All models, API methods, and locale keys ready

---

## Phase 3: User Story 1 — Browse Doctors with Call Services (Priority: P1) MVP

**Goal**: Build doctor list with search and doctor detail with call services + pricing

**Independent Test**: Open Call Booking, search doctors, tap doctor, view services with prices

### Implementation for User Story 1

- [x] T019 [P] [US1] Create call_doctor_card.dart in lib/screens/call_booking/components/ — displays doctor name, profile image (CachedImageWidget with fallback), specialty, rating (stars + count), experience, call type badges (video/phone icons), starting price. Clinical Elegance tokens: 16px radius, softShadowColor, surfaceElevated/Dark.
- [x] T020 [P] [US1] Create call_service_card.dart in lib/screens/call_booking/components/ — displays service name, call type badge (video=blue, phone=green), duration (e.g., "30 min"), original charges with strikethrough if discounted, discount badge (e.g., "10% off"), final price (bold). Tap callback to select service.
- [x] T021 [US1] Create call_doctor_list_controller.dart in lib/screens/call_booking/ — RxList<CallDoctor>, search debounce 500ms, pagination (page, isLastPage, isLoading). Calls CoreServiceApis.getCallDoctorList()
- [x] T022 [US1] Create call_doctor_list_screen.dart in lib/screens/call_booking/ — AppScaffoldNew, search field, AnimatedScrollView with onNextPage/onSwipeRefresh, CallDoctorCard items, empty state
- [x] T023 [US1] Create call_doctor_detail_screen.dart in lib/screens/call_booking/ — header with profile image, name, specialty, rating, experience, about. Call services section: list of CallServiceCard widgets. Each service tappable to navigate to booking flow. Loads services via CoreServiceApis.getCallDoctorServices() if not already in doctor data.
- [x] T024 [US1] Add call booking entry points to lib/screens/home/components/quick_services_component.dart — "Call Booking" quick service card with phone/video icon and gradient, navigating to CallDoctorListScreen via Get.to() with doIfLoggedIn(). Plus "My Call Bookings" request tile navigating to CallBookingListScreen.

**Checkpoint**: Patient can browse doctors, search, view profile + services with pricing

---

## Phase 4: User Story 2 — Select Time Slot & Book a Call (Priority: P2)

**Goal**: Build date picker, time slot grid, and booking confirmation flow

**Independent Test**: Select service, pick date, see slots, select slot, confirm booking, see meeting link

### Implementation for User Story 2

- [x] T025 [P] [US2] Create time_slot_chip.dart in lib/screens/call_booking/components/ — selectable chip showing slot label (e.g., "9:00 AM"). Selected state: gradient background. Unselected: surfaceElevated with border. Tap callback. 12px radius.
- [x] T026 [US2] Create book_call_controller.dart in lib/screens/call_booking/ — manages: selectedDoctor (Rx<CallDoctor?>), selectedService (Rx<CallService?>), selectedDate (Rx<DateTime?>), selectedSlot (Rx<TimeSlot?>), availableSlots (RxList<TimeSlot>), isLoadingSlots (RxBool), selectedPaymentMethod (RxString = 'cash'). Methods: fetchSlots(date) calls CoreServiceApis.getCallSlots(), confirmBooking() calls CoreServiceApis.createCallBooking() with {doctor_id, call_service_id, appointment_date, appointment_time, transaction_type}. On success: navigate to confirmation.
- [x] T027 [US2] Create book_call_screen.dart in lib/screens/call_booking/ — multi-step scrollable form:
  Section 1 - Selected Service: read-only card showing service name, type, duration, price
  Section 2 - Select Date: date picker (today or later), on date change fetch slots
  Section 3 - Available Slots: grid of TimeSlotChip widgets, empty state if none
  Section 4 - Payment Method: dropdown (cash default, other gateway options)
  Section 5 - Summary: doctor, service, date, time, amount
  Confirm button: gradient, disabled until date + slot selected
  After booking success: show confirmation dialog/screen with meeting link (video) or confirmation message (phone), "Join Call" button for video using url_launcher
- [x] T028 [US2] Implement booking confirmation display — after createCallBooking succeeds, show: appointment date/time, call type, duration, total amount, meeting link (if video — tappable via launchUrl), service name. Option to navigate to booking detail or back to doctor list.

**Checkpoint**: Patient can select date, pick slot, confirm booking, see meeting link

---

## Phase 5: User Story 3 — View My Call Bookings (Priority: P3)

**Goal**: Build booking list and detail screen with meeting link access

**Independent Test**: View booking list, tap booking, see details, tap "Join Call" for video

### Implementation for User Story 3

- [x] T029 [P] [US3] Create call_booking_card.dart in lib/screens/call_booking/components/ — displays doctor name, appointment date/time, call type badge (video=blue, phone=green), status badge, total amount. "Join Call" button for video bookings with meeting link. Clinical Elegance tokens.
- [x] T030 [US3] Create call_booking_list_controller.dart in lib/screens/call_booking/ — RxList<CallBooking>, pagination. Calls CoreServiceApis.getCallBookingList()
- [x] T031 [US3] Create call_booking_list_screen.dart in lib/screens/call_booking/ — AppScaffoldNew, AnimatedScrollView, CallBookingCard items, empty state with CTA to browse doctors
- [x] T032 [US3] Create call_booking_detail_screen.dart in lib/screens/call_booking/ — displays all booking fields: doctor name, appointment date/time, call type, service name, duration, meeting link (if video — "Join Call" button using launchUrl), prices (service, discount, total), status, booking type, timestamps. Dark mode support, localized labels.

**Checkpoint**: Patient can view bookings and join video calls via meeting link

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Design compliance, dark mode, RTL, and static analysis

- [x] T033 [P] Verify all call_booking screens use Clinical Elegance design tokens: 16px card radius, 12px input radius, 24px body padding, softShadowColor — check all screen and component files
- [x] T034 [P] Verify all call_booking screens support dark mode: isDarkMode.value with surfaceElevated/surfaceElevatedDark, inputFillColor/inputFillColorDark — check all files
- [x] T035 [P] Verify Arabic RTL layout works for all call_booking screens
- [x] T036 [P] Verify doctor with no profile image displays default placeholder in call_doctor_card.dart and call_doctor_detail_screen.dart
- [x] T037 [P] Verify discount display: if service has discount, show original price with strikethrough + discount badge + final price. If no discount, show price normally.
- [x] T038 Run flutter analyze and confirm zero new warnings in call_booking module files
- [x] T039 Run quickstart.md verification on device/emulator

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies — start immediately
- **Foundational (Phase 2)**: Depends on Phase 1 (needs endpoints, colors, constants)
- **User Stories (Phase 3–5)**: ALL depend on Phase 2 completion
  - US1 (Phase 3): No story dependencies — MVP
  - US2 (Phase 4): Depends on US1 (needs doctor + service selection)
  - US3 (Phase 5): Depends on US2 (needs booking data to display)
- **Polish (Phase 6)**: Depends on all user stories

### Parallel Opportunities

- T003-T004: Colors + constants in parallel
- T005-T007: All 3 model files in parallel
- T009-T012: API methods in parallel (different methods, same file — sequential preferred)
- T014-T018: All 5 language files in parallel
- T019-T020: Both card components in parallel
- T025+T029: Slot chip + booking card in parallel
- T033-T037: All polish tasks in parallel

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Phase 1: Setup
2. Phase 2: Foundational (models, API, locales)
3. Phase 3: US1 (doctor browsing)
4. **STOP and VALIDATE**

### Incremental Delivery

1. Setup + Foundational → infrastructure
2. US1 (browse doctors) → demo
3. US2 (slot selection + booking) → demo (core flow)
4. US3 (booking list) → demo
5. Polish → final pass

---

## Notes

- [P] tasks = different files, no dependencies
- [Story] label maps task to specific user story
- BUILD-FROM-SCRATCH — follow ICU module patterns
- Meeting links open via url_launcher (already in pubspec)
- Discount display: strikethrough original + badge + final price
- Payment method: pass transaction_type to API, don't implement full payment flow
- Time slots: POST to get slots (not GET) — unique pattern for this module
