# Tasks: Independent Doctor Booking Module

**Input**: Design documents from `/specs/006-independent-booking-module/`
**Prerequisites**: plan.md (required), spec.md (required), research.md, data-model.md, contracts/

**Tests**: Not requested. Tests are OPTIONAL per constitution.

**Context**: Brand new module — no existing code. Mirrors Call Booking structure
but for in-person appointments. **Reuses** TimeSlot model and TimeSlotChip widget
from `lib/screens/call_booking/`.

**Organization**: Tasks grouped by user story for independent implementation.

## Format: `[ID] [P?] [Story] Description`

---

## Phase 1: Setup (Project Structure & Infrastructure)

**Purpose**: Create directory structure, endpoint constants, and locale keys

- [x] T001 Create directory structure: lib/screens/independent_booking/, lib/screens/independent_booking/model/, lib/screens/independent_booking/components/
- [x] T002 Add 4 endpoint constants to lib/utils/api_end_points.dart: getIndependentDoctors = 'v1/independent-doctors', getIndependentDoctorServices = 'v1/independent-doctors' (append /{id}/services), getIndependentSlots = 'v1/independent-doctors' (append /{id}/slots), createIndependentBooking = 'v1/independent-booking'

**Checkpoint**: Infrastructure ready

---

## Phase 2: Foundational (Models, API Methods, Locale Keys)

**Purpose**: Create models, API methods, and locale keys

### Models

- [x] T003 Create IndependentDoctor and IndependentService models in lib/screens/independent_booking/model/independent_doctor_model.dart — IndependentDoctor with 21 fields including totalAppointment/totalPatient/totalReviews, IndependentService with 16 fields including inclusiveTax (String JSON), inclusiveTaxPrice (double), timestamps. IndependentDoctorListResponse with pagination meta. Follow call_doctor_model.dart pattern.
- [x] T004 [P] Create IndependentBooking model in lib/screens/independent_booking/model/independent_booking_model.dart — 15 fields: id, userId, doctorId, independentServiceId, appointmentDate, appointmentTime, bookingType ("independent"), status, servicePrice, serviceAmount, totalAmount, duration, startDateTime, createdAt, updatedAt. IndependentBookingListResponse with pagination. Follow call_booking_model.dart pattern.

**Note**: TimeSlot model REUSED from lib/screens/call_booking/model/time_slot_model.dart — no new file needed.

### API Methods

- [x] T005 Add getIndependentDoctorList() method to lib/api/core_apis.dart — paginated GET with search. Returns RxList<IndependentDoctor>
- [x] T006 [P] Add getIndependentDoctorServices() method to lib/api/core_apis.dart — GET v1/independent-doctors/{id}/services, returns List<IndependentService>
- [x] T007 [P] Add getIndependentSlots() method to lib/api/core_apis.dart — POST v1/independent-doctors/{id}/slots with {appointment_date, independent_service_id}, returns List<TimeSlot> (reuse TimeSlot from call_booking)
- [x] T008 [P] Add createIndependentBooking() method to lib/api/core_apis.dart — POST v1/independent-booking with {doctor_id, independent_service_id, appointment_date, appointment_time, transaction_type}, returns IndependentBooking
- [x] T009 [P] Add getIndependentBookingList() method to lib/api/core_apis.dart — paginated GET for patient's independent bookings. Returns RxList<IndependentBooking>

### Locale Keys

- [x] T010 Add ~30 independent booking locale key getters to lib/locale/languages.dart abstract class: independentBooking, independentDoctors, browseIndependentDoctors, myIndependentBookings, bookAppointment, independentServices, selectDateLabel, selectTimeSlotLabel, availableSlotsLabel, noSlotsAvailableLabel, bookingConfirmedLabel, appointmentDetails, inPersonConsultation, totalAppointments, totalPatients, taxIncluded, inclusiveTaxLabel, pricingBreakdown, noIndependentDoctorsFound, noIndependentBookingsYet, selectServiceLabel2, confirmBookingLabel, bookingDetailsLabel2
- [x] T011 [P] Add English translations in lib/locale/language_en.dart
- [x] T012 [P] Add Arabic translations in lib/locale/language_ar.dart
- [x] T013 [P] Add German translations in lib/locale/language_de.dart
- [x] T014 [P] Add French translations in lib/locale/language_fr.dart
- [x] T015 [P] Add Hindi translations in lib/locale/language_hi.dart

**Checkpoint**: Models, API, and locales ready

---

## Phase 3: User Story 1 — Browse Independent Doctors & Services (Priority: P1) MVP

**Goal**: Doctor list with search, doctor detail with services + pricing/tax display

**Independent Test**: Open section, search doctors, view profile + services with tax breakdown

- [x] T016 [P] [US1] Create independent_doctor_card.dart in lib/screens/independent_booking/components/ — name, profile image (CachedImageWidget), specialty, rating stars + reviews, experience, total appointments/patients stats. 16px radius, softShadowColor, surfaceElevated/Dark.
- [x] T017 [P] [US1] Create independent_service_card.dart in lib/screens/independent_booking/components/ — service name, duration + slot interval ("30 min / 10 min slots"), charges with discount display (strikethrough + badge if discount>0), inclusive tax info (parsed from JSON, show tax title + amount), final price. Tap callback.
- [x] T018 [US1] Create independent_doctor_list_controller.dart in lib/screens/independent_booking/ — RxList<IndependentDoctor>, search debounce 500ms, pagination. Calls CoreServiceApis.getIndependentDoctorList()
- [x] T019 [US1] Create independent_doctor_list_screen.dart in lib/screens/independent_booking/ — AppScaffoldNew, search, AnimatedScrollView, IndependentDoctorCard items, empty state
- [x] T020 [US1] Create independent_doctor_detail_screen.dart in lib/screens/independent_booking/ — profile header (image, name, specialty, rating, experience, stats grid: appointments/patients/reviews), about/description section, services list (IndependentServiceCard items). Each service taps to BookIndependentScreen. Load services via API if not in doctor data.
- [x] T021 [US1] Add entry points to lib/screens/home/components/quick_services_component.dart — "Independent Booking" quick service card + "My Independent Bookings" request tile, both with doIfLoggedIn() and Get.to()

**Checkpoint**: Patient can browse doctors, search, view services with pricing

---

## Phase 4: User Story 2 — Select Time Slot & Book Appointment (Priority: P2)

**Goal**: Date picker, slot grid (reuse TimeSlotChip), booking with tax breakdown

**Independent Test**: Select service, pick date, see 10-min slots, book, see confirmation with tax

- [x] T022 [US2] Create book_independent_controller.dart in lib/screens/independent_booking/ — selectedDoctor, selectedService, selectedDate, selectedSlot (reuse TimeSlot from call_booking), availableSlots (RxList<TimeSlot>), isLoadingSlots, isBooking, paymentMethod. fetchSlots() calls CoreServiceApis.getIndependentSlots(). confirmBooking() calls CoreServiceApis.createIndependentBooking(). No meeting link handling (in-person).
- [x] T023 [US2] Create book_independent_screen.dart in lib/screens/independent_booking/ — reuse TimeSlotChip from lib/screens/call_booking/components/time_slot_chip.dart (import it). Sections: selected service info (with tax breakdown), date picker, slot grid (Wrap of TimeSlotChip), payment method, summary (charges - discount + tax = total), confirm button. After success: confirmation dialog with date, time, duration, pricing breakdown (no meeting link).
- [x] T024 [US2] Implement tax breakdown display in service card and booking confirmation — parse inclusiveTax JSON string (e.g., [{"title":"VAT","type":"percent","value":15}]) and display each tax item with title and amount. Show: charges → discount → subtotal → tax items → total.

**Checkpoint**: Patient can book with 10-min slot intervals, see tax breakdown

---

## Phase 5: User Story 3 — View My Independent Bookings (Priority: P3)

**Goal**: Booking list and detail screen

**Independent Test**: View list, tap booking, see detail with pricing/tax

- [x] T025 [P] [US3] Create independent_booking_card.dart in lib/screens/independent_booking/components/ — doctor name, date/time, "In-Person" badge, status badge, total amount. 16px radius, clinical elegance tokens. Tap to detail.
- [x] T026 [US3] Create independent_booking_list_controller.dart in lib/screens/independent_booking/ — RxList<IndependentBooking>, pagination. Calls CoreServiceApis.getIndependentBookingList()
- [x] T027 [US3] Create independent_booking_list_screen.dart in lib/screens/independent_booking/ — AppScaffoldNew, AnimatedScrollView, IndependentBookingCard items, empty state with CTA
- [x] T028 [US3] Create independent_booking_detail_screen.dart in lib/screens/independent_booking/ — appointment info (date, time, duration), doctor info, service name, pricing breakdown (service price → discount → tax → total), status, timestamps. No meeting link section (in-person). Dark mode, localized labels.

**Checkpoint**: Patient can view bookings with pricing detail

---

## Phase 6: Polish & Cross-Cutting Concerns

- [x] T029 [P] Verify Clinical Elegance tokens across all independent_booking screens
- [x] T030 [P] Verify dark mode support in all files
- [x] T031 [P] Verify Arabic RTL layout
- [x] T032 [P] Verify doctor with no profile image shows placeholder
- [x] T033 [P] Verify discount + tax display: original → discount → tax → total in service cards and booking detail
- [x] T034 Run flutter analyze — zero new warnings
- [x] T035 Run quickstart.md verification on device

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: Start immediately
- **Foundational (Phase 2)**: Depends on Phase 1
- **US1 (Phase 3)**: Depends on Phase 2 — MVP
- **US2 (Phase 4)**: Depends on US1 (needs doctor + service selection)
- **US3 (Phase 5)**: Depends on US2 (needs booking data)
- **Polish (Phase 6)**: Depends on all stories

### Parallel Opportunities

- T003-T004: Both model files in parallel
- T006-T009: API methods in parallel
- T011-T015: All 5 language files in parallel
- T016-T017: Both card components in parallel
- T025-T028: US3 tasks mostly parallel
- T029-T033: All polish tasks in parallel

### Reuse from Call Booking

- `lib/screens/call_booking/model/time_slot_model.dart` — import TimeSlot
- `lib/screens/call_booking/components/time_slot_chip.dart` — import TimeSlotChip

---

## Implementation Strategy

### Incremental Delivery

1. Setup + Foundational → infrastructure
2. US1 (browse doctors) → demo
3. US2 (slot + booking with tax) → core flow
4. US3 (booking list) → complete
5. Polish → final pass

---

## Notes

- Mirrors Call Booking but NO meeting links, NO call types
- 10-min default slot interval (vs 15 for calls)
- Inclusive tax display: parse JSON, show breakdown
- Reuse TimeSlot + TimeSlotChip via import (don't duplicate)
- booking_type = "independent" (not "call")
- Doctor ID = model ID (not user_id)
