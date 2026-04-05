# Feature Specification: Call Booking Module

**Feature Branch**: `005-call-booking-module`
**Created**: 2026-03-29
**Status**: Implementation Complete
**Input**: User description: "Call Booking module integration — video/phone consultations with doctors, time slot selection, and booking"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Browse Doctors with Call Services (Priority: P1)

A patient wants to have a video or phone consultation with a doctor.
They open the Call Booking section, see a list of doctors offering
call services with their name, specialty, rating, experience, and
starting price. They can search by doctor name. They tap a doctor
to view their full profile and available call services (video call,
phone call) with pricing, duration, and discount information.

**Why this priority**: Discovering available doctors is the entry
point. Patients cannot book a call without first finding a doctor
and their services.

**Independent Test**: Can be tested by opening the Call Booking
section, searching for a doctor, tapping to view their profile and
call services list with prices.

**Acceptance Scenarios**:

1. **Given** the patient opens Call Booking, **When** the doctor list
   loads, **Then** doctors are displayed with name, profile image,
   specialty, rating, review count, and starting call price.
2. **Given** the patient types a search term, **When** results load,
   **Then** only doctors matching the name are shown.
3. **Given** the patient taps a doctor, **When** the detail screen
   loads, **Then** the doctor's profile is shown with all call
   services listing: name, type (video/phone), duration, original
   price, discount, and final price.
4. **Given** no doctors match the search, **When** the screen loads,
   **Then** an appropriate empty state is displayed.

---

### User Story 2 - Select Time Slot & Book a Call (Priority: P2)

A patient selects a call service from a doctor, picks a date, views
available time slots for that date, selects a slot, and confirms the
booking. The system creates the appointment and returns a meeting
link (for video calls) or confirmation details. The patient can
choose a payment method (cash, or existing payment gateways).

**Why this priority**: Booking is the core transactional action.
The slot selection + booking flow is what converts browsing into an
actual consultation appointment.

**Independent Test**: Can be tested by selecting a service, picking
a date, selecting a time slot, confirming the booking, and verifying
the confirmation screen with meeting link and appointment details.

**Acceptance Scenarios**:

1. **Given** the patient selects a call service and picks a date,
   **When** the slots load, **Then** available time slots for that
   date are displayed (e.g., "9:00 AM", "9:30 AM").
2. **Given** the patient selects a time slot and confirms, **When**
   the booking API responds successfully, **Then** a confirmation
   screen shows the appointment date, time, call type, duration,
   total amount, and meeting link (for video calls).
3. **Given** the patient selects a date in the past, **When** they
   attempt to proceed, **Then** a validation error indicates the
   date must be today or later.
4. **Given** no time slots are available for the selected date,
   **When** slots load, **Then** an empty state message suggests
   trying another date.
5. **Given** the API returns an error during booking, **When** the
   patient confirms, **Then** a user-friendly error is displayed.
6. **Given** a video call is booked, **When** the confirmation
   screen loads, **Then** the meeting link is displayed with a
   "Join Call" button that opens the link.

---

### User Story 3 - View My Call Bookings (Priority: P3)

A patient views their call booking history and upcoming calls. They
can see appointment details including date, time, doctor, call type,
status, meeting link, and total amount.

**Why this priority**: After booking, patients need to access their
appointment details, especially the meeting link for video calls.

**Independent Test**: Can be tested by viewing the bookings list and
tapping a booking to see full details with meeting link.

**Acceptance Scenarios**:

1. **Given** the patient opens "My Call Bookings", **When** the list
   loads, **Then** bookings are displayed with doctor name, date,
   time, call type (video/phone), status, and amount.
2. **Given** the patient taps a booking, **When** the detail loads,
   **Then** full details are shown including meeting link (for video),
   duration, payment info, and service name.
3. **Given** a video booking has a meeting link, **When** the patient
   taps "Join Call", **Then** the meeting link opens in the browser
   or external app.
4. **Given** the patient has no bookings, **When** the list loads,
   **Then** an empty state with CTA to browse doctors is shown.

---

### Edge Cases

- What happens when all time slots for a date are booked? Show
  "No available slots" with suggestion to try another date.
- How does the app handle time zones? Display times in the device's
  local time zone; the API handles conversion.
- What if a doctor's call service is deactivated between selection
  and booking? The server validates; the client shows the error.
- How does the app display the meeting link before the appointment
  time? Always show it — the doctor controls when to start.
- What if the patient has no internet during a video call? This is
  outside app scope — the video platform handles connectivity.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: Users MUST be able to view a paginated list of doctors
  with active call services showing name, profile image, specialty,
  rating, review count, and starting call price.
- **FR-002**: Users MUST be able to search doctors by name.
- **FR-003**: Users MUST be able to view a doctor's full profile
  with all call services including name, call type (video/phone),
  duration, original charges, discount info, and final price.
- **FR-004**: Authenticated users MUST be able to select a call
  service, pick a date, and view available time slots for that date.
- **FR-005**: The system MUST display time slots with human-readable
  labels (e.g., "9:00 AM") and value format (e.g., "09:00").
- **FR-006**: Authenticated users MUST be able to book a call by
  selecting a doctor, service, date, time slot, and payment method.
- **FR-007**: After successful booking, the system MUST display
  confirmation with appointment date, time, call type, duration,
  total amount, and meeting link (for video calls).
- **FR-008**: Users MUST be able to join video calls by tapping the
  meeting link, which opens in the browser or external app.
- **FR-009**: Authenticated users MUST be able to view their call
  bookings with doctor, date, time, type, status, and amount.
- **FR-010**: Booking creation MUST validate: date is today or later,
  time slot is available, service exists, doctor is active.
- **FR-011**: All user-facing text MUST be localized in all five
  supported languages (EN, AR, DE, FR, HI).
- **FR-012**: All screens MUST support both light and dark themes.
- **FR-013**: All screens MUST follow the Clinical Elegance design
  system.

### Key Entities

- **Call Doctor**: A doctor offering call consultation services.
  Attributes: name, email, mobile, gender, specialty, about,
  experience, profile image, average rating, total reviews,
  has video/phone call flags, starting price, call services list.
- **Call Service**: A specific call offering from a doctor.
  Attributes: name, description, call type (video/phone), duration
  minutes, time slot interval, charges, discount info (type, value),
  final price, tax info, status.
- **Time Slot**: An available appointment slot. Attributes: value
  (24h format), label (display format).
- **Call Booking**: A confirmed call appointment. Attributes:
  appointment date, time, doctor, call service, call type, booking
  type, meeting link, prices (service, amount, total), duration,
  status, timestamps.

### Assumptions

- The patient app only needs the `user` (patient) role perspective.
- Doctor list and services are public (no auth required).
- Time slot fetching and booking require authentication.
- The meeting link is generated server-side (Jitsi-based) and
  returned in the booking response.
- Payment method defaults to "cash" — existing payment gateway
  integration handles other methods if the user selects them.
- The booking list reuses the existing appointment list filtered
  by booking_type="call", or a dedicated endpoint exists.
- Call bookings show in "My Appointments" or a dedicated "My Calls"
  section — using a dedicated section for clarity.
- Discount calculation is server-side; the client displays the
  final_price from the API response.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Users can find a doctor and view their call services
  within 3 taps from the home screen.
- **SC-002**: Users can complete a call booking (select service,
  date, slot, confirm) in under 2 minutes.
- **SC-003**: Doctor and slot screens load within 2 seconds.
- **SC-004**: All three user stories are functional in both light
  and dark themes without visual defects.
- **SC-005**: All user-facing text appears correctly in all five
  supported languages, including RTL layout for Arabic.
- **SC-006**: 90% of users can complete their first call booking
  without assistance or errors.
- **SC-007**: Video call meeting links are accessible and open
  correctly in the device browser.
