# Feature Specification: Independent Doctor Booking Module

**Feature Branch**: `006-independent-booking-module`
**Created**: 2026-03-29
**Status**: Implementation Complete
**Input**: User description: "Independent Doctor Booking — book appointments directly with doctors outside clinic scheduling, with separate services, sessions, and pricing"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Browse Independent Doctors & Services (Priority: P1)

A patient wants to book a direct consultation with a doctor outside
the clinic system. They open the Independent Booking section, see a
list of doctors offering independent services with their name,
specialty, rating, experience, and stats (appointments, patients,
reviews). They can search by name. They tap a doctor to view their
full profile and available independent services with pricing,
duration, discount, and tax information.

**Why this priority**: Discovering doctors and their services is the
entry point. Patients cannot book without first finding a doctor
and selecting a service.

**Independent Test**: Can be tested by opening the section, searching
doctors, tapping to view profile and services with pricing breakdown.

**Acceptance Scenarios**:

1. **Given** the patient opens Independent Booking, **When** the
   doctor list loads, **Then** doctors are displayed with name,
   profile image, specialty, rating, experience, total appointments,
   and total patients.
2. **Given** the patient types a search term, **When** results load,
   **Then** only doctors matching the name are shown.
3. **Given** the patient taps a doctor, **When** the detail screen
   loads, **Then** the doctor's profile and independent services are
   shown with: name, description, duration, slot interval, original
   charges, discount info, tax info, and final price.
4. **Given** a service has a 10% discount and inclusive VAT, **When**
   the price displays, **Then** the original price, discount amount,
   and final price with tax are all visible.
5. **Given** no doctors are available, **When** the screen loads,
   **Then** an appropriate empty state is displayed.

---

### User Story 2 - Select Time Slot & Book Appointment (Priority: P2)

A patient selects an independent service, picks a date, views
available time slots (generated from the doctor's independent
sessions at the service's time_slot interval), selects a slot, and
confirms the booking. Slots are filtered by breaks, holidays, and
existing bookings across all types. The patient can choose a payment
method.

**Why this priority**: Booking is the core transactional action. The
slot selection flow with finer-grained intervals (10 min default)
is what differentiates this from call bookings.

**Independent Test**: Can be tested by selecting a service, picking
a date, selecting a time slot, confirming, and verifying the
confirmation with appointment details.

**Acceptance Scenarios**:

1. **Given** the patient selects a service and picks a date, **When**
   slots load, **Then** available slots at the service's time_slot
   interval (e.g., every 10 minutes) are displayed.
2. **Given** the patient selects a slot and confirms, **When** the
   booking succeeds, **Then** a confirmation shows the appointment
   date, time, duration, and total amount (with tax if applicable).
3. **Given** the patient selects a date that is a doctor holiday,
   **When** slots load, **Then** no slots are shown with a message.
4. **Given** the patient selects a past date, **When** they attempt
   to proceed, **Then** a validation error is shown.
5. **Given** another patient books the same slot between selection
   and confirmation, **When** the patient confirms, **Then** a
   "No slots available" error is shown.
6. **Given** the patient selects insurance payment, **When** they
   confirm, **Then** the booking proceeds with transaction_type set.

---

### User Story 3 - View My Independent Bookings (Priority: P3)

A patient views their independent booking history. They can see
appointment details including date, time, doctor, service, duration,
pricing breakdown, and status.

**Why this priority**: After booking, patients need to access their
appointment details for reference.

**Independent Test**: Can be tested by viewing the bookings list and
tapping a booking to see full details.

**Acceptance Scenarios**:

1. **Given** the patient opens "My Independent Bookings", **When**
   the list loads, **Then** bookings are displayed with doctor name,
   date, time, status, and total amount.
2. **Given** the patient taps a booking, **When** the detail loads,
   **Then** full details are shown: doctor, service name, date, time,
   duration, pricing (service price, discount, tax, total), status.
3. **Given** the patient has no bookings, **When** the list loads,
   **Then** an empty state with CTA to browse doctors is shown.

---

### Edge Cases

- What if all slots are booked for a date? Show empty state with
  suggestion to try another date.
- What if the doctor becomes inactive between browsing and booking?
  Server validates; client shows error.
- How does inclusive vs exclusive tax display? Show tax breakdown
  in the pricing section of service cards and booking detail.
- What if time_slot is 10 minutes and session is 1 hour? Show 6
  slots (09:00, 09:10, 09:20, 09:30, 09:40, 09:50).

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: Users MUST be able to view a paginated list of doctors
  with independent services showing name, profile image, specialty,
  rating, experience, total appointments, patients, and reviews.
- **FR-002**: Users MUST be able to search doctors by name.
- **FR-003**: Users MUST be able to view a doctor's independent
  services with name, description, duration, time slot interval,
  charges, discount info (type, value, final price), and tax info.
- **FR-004**: Authenticated users MUST be able to select a service,
  pick a date, and view available time slots for that date.
- **FR-005**: Time slots MUST display at the service's configured
  interval (default 10 minutes) with human-readable labels.
- **FR-006**: Authenticated users MUST be able to book an appointment
  by selecting doctor, service, date, time slot, and payment method.
- **FR-007**: After successful booking, the system MUST display
  confirmation with date, time, duration, and total amount with
  pricing breakdown.
- **FR-008**: Authenticated users MUST be able to view their
  independent bookings with doctor, date, time, status, and amount.
- **FR-009**: Booking MUST validate: date is today or later, slot
  is available (double-booking prevention across all types), service
  exists, doctor is active.
- **FR-010**: Pricing MUST display: original charges, discount (if
  any), inclusive tax (if any), and final total amount.
- **FR-011**: All user-facing text MUST be localized in all five
  supported languages (EN, AR, DE, FR, HI).
- **FR-012**: All screens MUST support both light and dark themes.
- **FR-013**: All screens MUST follow the Clinical Elegance design
  system.

### Key Entities

- **Independent Doctor**: A doctor offering direct consultations.
  Attributes: name, email, mobile, gender, specialty, date of birth,
  address, lat/lng, description, experience, profile image, rating,
  total appointments/patients/reviews, services list.
- **Independent Service**: A specific consultation offering.
  Attributes: name, description, duration minutes, time slot interval,
  charges, discount (enabled, type, value), inclusive tax (enabled,
  JSON tax details, calculated amount), status, timestamps.
- **Time Slot**: An available appointment slot. Attributes: value
  (24h format), label (display format).
- **Independent Booking**: A confirmed appointment. Attributes:
  appointment date/time, doctor, service, booking type ("independent"),
  prices (service, amount after discount, total with tax), duration,
  status, timestamps.

### Assumptions

- The patient app only needs the `user` (patient) role.
- Doctor list and services are public (no auth).
- Slot fetching and booking require authentication.
- This is for in-person appointments — no meeting links, no call
  type. booking_type = "independent".
- The doctor's `id` in the API is the Doctor model ID, not user_id.
- Can reuse the TimeSlot model from the Call Booking module.
- Can reuse the time_slot_chip.dart component from Call Booking.
- Payment method defaults to "cash" with gateway options available.
- Pricing calculation is server-side. Client displays amounts from
  the API response.
- Tax information (inclusive_tax) is a JSON string that can be
  parsed for display but calculation is server-side.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Users can find a doctor and view services within 3
  taps from the home screen.
- **SC-002**: Users can complete a booking in under 2 minutes.
- **SC-003**: Doctor and slot screens load within 2 seconds.
- **SC-004**: All three user stories work in light and dark themes.
- **SC-005**: All text appears correctly in all five languages
  including RTL for Arabic.
- **SC-006**: 90% of users complete their first booking without
  assistance.
