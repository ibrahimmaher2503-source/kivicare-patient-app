# Feature Specification: Labs & Radiology Booking Module

**Feature Branch**: `022-labs-radiology-booking`
**Created**: 2026-04-29
**Status**: Draft
**Input**: User description: Vezeeta-style diagnostic booking module covering both labs and radiology centers — discovery, test catalog browsing, slot selection, booking confirmation, order tracking with status timeline, and report download.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Book a Diagnostic Test at a Facility (Priority: P1)

A patient needs a diagnostic test (lab work or imaging) prescribed by a doctor. They open the module, choose between Labs and Radiology Centers, find a nearby facility (optionally filtering by governorate/city or searching by name), view its details (rating, services, available tests, address), pick a test if applicable, choose an available date and time slot from a calendar, and confirm their booking. They receive a reference number and can view the order immediately.

**Why this priority**: This is the core value proposition — without it the module has no purpose. It is the minimum viable slice: a patient who only ever uses this flow already gets full value from the module.

**Independent Test**: Open module → switch between Labs/Radiology tabs → pick a facility → pick a test → pick a slot → confirm → see success screen with reference number → verify the order appears in order history.

**Acceptance Scenarios**:

1. **Given** the patient is on the module hub with the Labs tab active, **When** they tap a lab card, **Then** the facility detail screen opens showing rating, services, available tests, address, and a "Book Appointment" call to action.
2. **Given** the patient is on the slot selection screen, **When** they tap an available date and then an available time slot, **Then** the slot is visibly selected and the "Continue" button becomes enabled.
3. **Given** the patient is on the booking confirmation screen with a slot selected, **When** they tap "Confirm Booking", **Then** the system creates the booking, displays a success screen with a reference number that can be copied to the clipboard, and the new order is visible in order history.
4. **Given** the patient is booking at a lab, **When** they reach the confirmation step without selecting a test, **Then** the system prevents submission and indicates that a test is required.
5. **Given** the patient is booking at a radiology center where no specific test is required, **When** they confirm without a test, **Then** the booking succeeds.
6. **Given** the chosen slot becomes unavailable between selection and confirmation, **When** the patient taps Confirm, **Then** the system shows a clear message explaining the conflict and returns the patient to slot selection with refreshed availability.

---

### User Story 2 - Track Orders and Download Reports (Priority: P2)

After booking, the patient wants to follow the order through its stages (pending → confirmed → sample collected → in progress → completed) and download the diagnostic report PDF when it is ready. They open "My Test Orders", filter by status if needed, tap an order to see a status timeline, and download the report once completed.

**Why this priority**: Order tracking and report retrieval are essential follow-through for patients who have booked, but they only matter once Story 1 exists. Without them the booking value is incomplete; with them the patient round-trip is closed.

**Independent Test**: From order history, open any order → see status timeline reflecting current and historical statuses → for a completed order with a report, tap Download → confirm the report file is saved and opened in the device's default viewer.

**Acceptance Scenarios**:

1. **Given** the patient has multiple orders in different statuses, **When** they apply a status filter, **Then** only orders matching that status are shown.
2. **Given** the patient opens an order with status "Confirmed", **When** the detail screen loads, **Then** the status timeline highlights Pending and Confirmed as completed steps and shows the remaining steps as upcoming.
3. **Given** an order is for a radiology center, **When** the timeline renders, **Then** the "Sample Collected" step is hidden because it does not apply.
4. **Given** an order has reached "Completed" status with a report attached, **When** the patient taps "Download Report", **Then** the report is downloaded to the device and opened in the default viewer.
5. **Given** an order is "Completed" but no report is yet attached, **When** the patient views the order, **Then** the Download button is hidden or shows a clear message that the report is not yet ready.
6. **Given** an order is in "Pending" or "Confirmed" status, **When** the patient taps "Cancel Order" and confirms in the dialog (with optional reason), **Then** the order is cancelled and the status updates to Cancelled with the reason recorded.
7. **Given** an order is in a non-cancellable status, **When** the patient views the detail, **Then** no Cancel button is visible.

---

### User Story 3 - Discover Tests by Category or Search (Priority: P3)

A patient who knows the test name (e.g., "CBC") or the test category (e.g., Blood Tests, Imaging) wants to discover what tests exist and which facilities offer them, before deciding where to book. They browse categories, drill into a category to see its tests, view test details (description, preparation instructions, turnaround time, price), and proceed to choose a facility offering that test.

**Why this priority**: Improves discovery and removes friction for patients who arrive with a specific test in mind, but is not strictly required for the core booking flow (which can also start from a facility).

**Independent Test**: From the hub, tap "Browse Test Categories" → tap a category → see filtered tests list → tap a test → see its details and preparation instructions → proceed to "Book Test" and choose a facility.

**Acceptance Scenarios**:

1. **Given** the patient is on the hub, **When** they tap "Browse Test Categories", **Then** a grid of categories is shown with name and test count for each.
2. **Given** the patient is on the tests list with no category filter, **When** they type a search term, **Then** the list updates with matching tests after a brief debounce.
3. **Given** the patient taps a test, **When** the detail sheet opens, **Then** it shows description, preparation instructions, turnaround time, price, and a "Book Test" action.
4. **Given** the patient taps "Book Test" from a test detail without a facility chosen, **When** the navigation completes, **Then** the patient sees a list of facilities that offer that test and can continue from there.

---

### Edge Cases

- **Slot becomes unavailable mid-flow**: System surfaces a clear conflict message and refreshes slot availability, returning the patient to slot selection rather than failing silently.
- **No facilities match filters**: Empty state explains the situation and offers a "clear filters" action.
- **No slots on selected date**: Empty state suggests trying another date.
- **Facility with zero tests**: Detail screen still loads gracefully with an empty-tests section instead of erroring.
- **Network failure during list/detail fetch**: A recoverable error state is shown with a retry option; previously loaded data is preserved on a failed refresh.
- **Network failure during booking submit**: The patient is informed and can retry; no duplicate orders are created.
- **Network failure during report download**: A retry option is offered; partial files are not left on the device.
- **Storage permission denied (Android)**: The patient sees a clear explanation and a shortcut to system settings.
- **Long facility names or test names**: Layouts truncate gracefully with ellipsis without breaking visual structure.
- **Right-to-left (Arabic) layout**: All screens, including the calendar strip and slot grid, mirror correctly and remain usable.
- **Dark mode**: All states (available, selected, unavailable slots; status chips) maintain sufficient contrast.
- **Authentication token expiry**: Re-authentication happens transparently without forcing the patient to restart the flow.
- **Cancellation race**: Patient attempts to cancel an order that the facility has just moved past the cancellable stage — system shows the actual current status and hides the Cancel option.

## Requirements *(mandatory)*

### Functional Requirements

#### Discovery

- **FR-001**: Patients MUST be able to switch between Labs and Radiology Centers in a single hub and see facility lists appropriate to the active selection.
- **FR-002**: Patients MUST be able to search facilities by name within the active facility type.
- **FR-003**: Patients MUST be able to filter the facility list by location (governorate and city) using the existing location filter.
- **FR-004**: Patients MUST be able to browse a catalog of diagnostic test categories, each showing its test count.
- **FR-005**: Patients MUST be able to view a list of individual tests, optionally filtered by category or by facility, and search tests by name.
- **FR-006**: Patients MUST be able to view test details including description, preparation instructions, turnaround time, and price.
- **FR-007**: Patients MUST be able to view a facility detail page containing rating, services offered, available tests, address, and contact options (phone tap-to-call, open in maps).

#### Booking

- **FR-008**: Patients MUST be able to select a date from the next 14 days for any chosen facility and see available time slots for that date.
- **FR-009**: Available, selected, and unavailable slots MUST be visually distinct, and unavailable slots MUST NOT be selectable.
- **FR-010**: For labs, patients MUST select a test before they can confirm a booking. For radiology centers, the test selection MAY be optional.
- **FR-011**: Patients MUST be able to add optional notes (up to 1,000 characters) before confirming.
- **FR-012**: The system MUST display a clear price summary before the patient confirms.
- **FR-013**: On successful booking, the system MUST display a success screen containing a unique reference number and allow the patient to copy it to the clipboard and navigate to the new order's detail.
- **FR-014**: The system MUST gracefully handle the case where a previously available slot is taken before submission, by informing the patient and refreshing availability.

#### Order Tracking

- **FR-015**: Patients MUST be able to view a list of all their test orders, ordered with the newest first, with pagination.
- **FR-016**: Patients MUST be able to filter the orders list by status (All, Pending, Confirmed, Sample Collected, In Progress, Completed, Cancelled, Rejected).
- **FR-017**: The order detail view MUST show the order's current status, full status timeline reflecting historical transitions, facility info, test info (if applicable), slot info, patient notes, pricing, payment status, and any cancellation reason.
- **FR-018**: For radiology orders, the status timeline MUST omit the Sample Collected step.
- **FR-019**: Patients MUST be able to cancel an order while it is in a cancellable status (Pending or Confirmed) via a confirmation dialog that accepts an optional cancellation reason.
- **FR-020**: The Cancel action MUST NOT be available on orders in non-cancellable statuses (Sample Collected, In Progress, Completed, Cancelled, Rejected).

#### Report Download

- **FR-021**: Patients MUST be able to download a report file for an order only when the order is Completed and a report is available.
- **FR-022**: After download, the system MUST open the report in the device's default viewer.
- **FR-023**: The system MUST clearly handle and explain failure cases including network failure, storage permission denial, and report-not-yet-ready.

#### Cross-Cutting

- **FR-024**: All patient-facing text MUST be available in both English (LTR) and Arabic (RTL), with layouts that mirror correctly in RTL — including the calendar strip and slot grid.
- **FR-025**: All screens MUST render correctly in both light and dark mode with sufficient contrast on interactive states.
- **FR-026**: Pull-to-refresh MUST be available on all list and detail screens.
- **FR-027**: Recoverable error states MUST offer a retry action and preserve previously loaded data on refresh failure.
- **FR-028**: Authentication renewal MUST be transparent to the patient; expiring sessions MUST NOT cause unrecoverable interruption mid-flow.
- **FR-029**: Patients MUST NOT have access to administrative controls (confirm bookings on behalf of facilities, change order status, edit orders post-creation, etc.); only patient-initiated cancellation is permitted.
- **FR-030**: A new entry point MUST be added to the app's main dashboard so patients can reach the module in one tap.

### Key Entities

- **Facility**: A physical service provider that delivers diagnostic services. Has a type (Lab or Radiology Center), name, optional logo and cover image, location (governorate, city, address, optional coordinates), contact info (phone, optional email), rating with review count, list of services (e.g., home sample collection, walk-in), available test count, and optionally a "starting from" minimum price.
- **Test Category**: A grouping of diagnostic tests (e.g., Blood Tests, Imaging, Hormones). Has a name, optional icon and description, and a count of tests within it.
- **Lab Test**: An individual diagnostic test or imaging procedure. Belongs to a category, has a name, optional description, price and currency, optional preparation instructions, optional turnaround time, an indicator for whether it is an imaging procedure, and the type of facility (lab or radiology) that offers it.
- **Slot**: A bookable time window at a facility on a specific date. Has a start time, end time, and an availability flag.
- **Test Order**: A patient's booking. References one Facility and (for labs) one Lab Test, has a chosen Slot, an optional patient note, a reference number, a current status, a status history, a total amount and currency, a payment status, an optional cancellation reason, and (when completed) an optional report reference and timestamp.
- **Status History Entry**: A record of a transition between statuses on a Test Order, with timestamp and optional note.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: A patient with a clear intent (test name or facility known) can complete a booking — from opening the module to confirmation — in under 90 seconds end-to-end.
- **SC-002**: At least 90% of patients who reach slot selection successfully complete a booking, indicating the slot picker and confirmation steps are not a drop-off point.
- **SC-003**: 100% of order-detail views display the current status and a coherent timeline reflecting all historical transitions for that order.
- **SC-004**: 100% of completed orders that have a report attached present a working Download action that produces an openable file on the device on the first attempt under normal network conditions.
- **SC-005**: All eight screens render correctly in both English (LTR) and Arabic (RTL), and in both light and dark mode, with no layout breakage on common phone sizes (verified via manual QA across both locales and themes).
- **SC-006**: When a slot conflict occurs at the moment of confirmation, the patient is returned to slot selection with refreshed availability in under 3 seconds and no duplicate order is created.
- **SC-007**: The module introduces zero new static-analysis warnings to the codebase.
- **SC-008**: At least 80% of patients who view a facility detail proceed to slot selection, indicating the facility detail content is sufficient to build trust without leaving the screen.

## Assumptions

- Slot availability is fetched on demand at the time the patient opens slot selection; real-time updates via push are not required.
- Each booking covers exactly one test (no multi-test cart in this version).
- Reports are made available by the facility/admin after the order reaches Completed; the patient app only consumes them, never uploads.
- In-app payment is out of scope for this version; the module surfaces price and total only.
- Editing a booking after submission is out of scope; the only patient-side change is cancellation while still allowed.
- Test categories change rarely and may be cached on the device for up to one week to keep the experience instant on revisits.
- The existing location filter (governorate/city) is reused and is not part of this feature's scope to redesign.
- The dashboard already contains other module entry tiles; adding one more for Labs & Radiology fits the existing pattern.
- The module is patient-facing only; administrative endpoints exist in the backend but are explicitly out of scope for this app.

## Out of Scope

- Multi-test cart (booking multiple tests in one order).
- A patient-facing health record / lab-result history beyond downloading the most recent report per order.
- In-app payment processing.
- Real-time slot availability via push or WebSocket.
- Editing a confirmed order (only cancel is supported).
- Patient-to-facility messaging or chat.
- Administrator screens (confirming bookings, changing order status, etc.).
