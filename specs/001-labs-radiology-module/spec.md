# Feature Specification: Labs & Radiology Module

**Feature Branch**: `001-labs-radiology-module`
**Created**: 2026-03-29
**Status**: Implementation Complete
**Input**: User description: "Labs & Radiology module integration with 8 API endpoints, models, UI screens with existing theme, and translations"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Browse Lab Test Catalog (Priority: P1)

A patient opens the app and wants to explore available lab tests and
radiology services. They navigate to the Labs & Radiology section, see
test categories (e.g., Hematology, Radiology), tap a category to filter
tests, and browse individual test details including price, sample type,
preparation instructions, and turnaround time. They can also search
tests by name or code, and filter by department (laboratory vs
radiology).

**Why this priority**: Browsing is the entry point for the entire
module. Without it, patients cannot discover tests or proceed to
ordering. This is the read-only foundation that all other stories
depend on.

**Independent Test**: Can be fully tested by opening the Labs &
Radiology section, browsing categories, filtering by department,
searching by name, and viewing test details. Delivers discovery
value even without ordering capability.

**Acceptance Scenarios**:

1. **Given** the patient opens the Labs & Radiology section, **When**
   the screen loads, **Then** a list of test categories is displayed
   with name, icon, description, and test count.
2. **Given** the patient taps a category, **When** the filtered test
   list loads, **Then** only tests belonging to that category are shown.
3. **Given** the patient types a search term, **When** results load,
   **Then** tests matching the name, code, or description are shown.
4. **Given** the patient selects the "Radiology" department filter,
   **When** results load, **Then** only radiology tests are displayed.
5. **Given** the patient taps a test, **When** the detail screen loads,
   **Then** the test name, code, category, department, sample type,
   description, preparation instructions, price, turnaround time, and
   status are displayed.
6. **Given** the test catalog is empty or the API returns an error,
   **When** the screen loads, **Then** an appropriate empty state or
   error message is displayed.

---

### User Story 2 - Place a Lab Test Order (Priority: P2)

A patient selects one or more lab tests and places an order. They can
add optional clinical notes, select a priority level (routine, urgent,
stat), and optionally associate a doctor. After submission the system
confirms the order with an auto-generated order number.

**Why this priority**: Ordering is the core transactional action of the
module. It converts browsing intent into a trackable request. Without
it the module is informational only.

**Independent Test**: Can be tested by selecting tests from the
catalog, filling in order details, submitting, and verifying the
confirmation screen shows the order number and summary.

**Acceptance Scenarios**:

1. **Given** the patient has selected at least one test, **When** they
   tap "Place Order", **Then** the order form is shown with the
   selected tests, total price, and fields for clinical notes and
   priority.
2. **Given** the patient fills in order details and submits, **When**
   the API responds successfully, **Then** a confirmation screen
   displays the order number (LAB-YYYY-NNNN format), items, and total
   amount.
3. **Given** the patient submits an order without selecting any tests,
   **When** they tap submit, **Then** a validation message instructs
   them to select at least one test.
4. **Given** the patient enters clinical notes exceeding 2000
   characters, **When** they attempt to submit, **Then** a validation
   error is shown.
5. **Given** the API returns an error during order creation, **When**
   the patient submits, **Then** a user-friendly error message is
   displayed and the form data is preserved.

---

### User Story 3 - View & Track Orders (Priority: P3)

A patient views their list of test orders and checks the status of
each. They can filter orders by status (pending, confirmed,
sample_collected, processing, completed, delivered, cancelled) and
tap an order to see full details including items, results (if
available), priority, payment status, and dates.

**Why this priority**: After placing an order, patients need
visibility into its progress. This completes the core order lifecycle
from the patient's perspective.

**Independent Test**: Can be tested by viewing the order list,
filtering by status, tapping an order, and verifying all detail
fields display correctly.

**Acceptance Scenarios**:

1. **Given** the patient opens "My Orders", **When** the list loads,
   **Then** orders are displayed with order number, date, status,
   item count, and total amount.
2. **Given** the patient selects a status filter, **When** results
   load, **Then** only orders with that status are shown.
3. **Given** the patient taps an order, **When** the detail screen
   loads, **Then** all order details are shown: items with individual
   status, clinical notes, priority, doctor, payment status, amounts,
   and dates.
4. **Given** the patient has no orders, **When** the list loads,
   **Then** an empty state with a call-to-action to browse tests is
   displayed.
5. **Given** an order has completed items with results, **When** the
   patient views the order detail, **Then** result values, units,
   reference ranges, and result notes are visible.

---

### User Story 4 - Cancel a Pending Order (Priority: P4)

A patient decides to cancel an order that has not yet progressed
beyond the "confirmed" stage. They provide a cancellation reason
and confirm the action.

**Why this priority**: Cancellation is important for patient autonomy
but is secondary to creating and tracking orders.

**Independent Test**: Can be tested by opening a pending or confirmed
order, tapping cancel, entering a reason, confirming, and verifying
the order status changes to cancelled.

**Acceptance Scenarios**:

1. **Given** the patient views an order with status "pending" or
   "confirmed", **When** they tap "Cancel Order", **Then** a dialog
   prompts for a cancellation reason.
2. **Given** the patient enters a reason and confirms, **When** the
   API responds successfully, **Then** the order status updates to
   "cancelled" and a success message is shown.
3. **Given** the patient tries to cancel an order with status
   "sample_collected" or beyond, **When** they view the order,
   **Then** the cancel option is not available.
4. **Given** the patient enters a cancellation reason exceeding 500
   characters, **When** they attempt to confirm, **Then** a validation
   error is shown.
5. **Given** the patient dismisses the cancellation dialog without
   confirming, **When** the dialog closes, **Then** the order remains
   unchanged.

---

### User Story 5 - Download Test Report (Priority: P5)

A patient with a completed order downloads the PDF report for their
test results. The system either returns a stored report or
auto-generates one.

**Why this priority**: Report download is the final step in the
patient journey. It depends on orders reaching the completed/delivered
state and is less frequently used than browsing or ordering.

**Independent Test**: Can be tested by opening a completed order with
reports available, tapping download, and verifying the PDF opens or
saves successfully.

**Acceptance Scenarios**:

1. **Given** the patient views a completed order with a report
   available, **When** they tap "Download Report", **Then** a PDF
   file is downloaded and opened or saved to the device.
2. **Given** the report download fails (network error), **When** the
   patient taps download, **Then** an error message is displayed with
   a retry option.
3. **Given** the patient views an order that is not yet completed,
   **When** they view the order detail, **Then** the download option
   is not available.

---

### Edge Cases

- What happens when the patient's auth token expires mid-order
  creation? The existing token regeneration flow handles this
  transparently.
- How does the system handle a test that is removed from the catalog
  after being added to a draft order? The order submission validates
  test IDs server-side; the client displays the server error.
- What happens when pagination reaches the last page? The list shows
  no more items and the scroll-to-load-more indicator disappears.
- How does the app handle zero-price tests? Display "Free" instead
  of a zero amount.
- What if the PDF report download is large (>10MB)? Show a progress
  indicator during download.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST display lab test categories with name,
  icon, description, and test count.
- **FR-002**: System MUST display lab tests with name, code,
  category, department, sample type, description, preparation
  instructions, price, turnaround time, and status.
- **FR-003**: Users MUST be able to filter tests by category.
- **FR-004**: Users MUST be able to filter tests by department
  (laboratory or radiology).
- **FR-005**: Users MUST be able to search tests by name, code,
  or description.
- **FR-006**: System MUST support paginated test listing with
  configurable page size.
- **FR-007**: Users MUST be able to view detailed information
  for a single lab test.
- **FR-008**: Authenticated users MUST be able to create a test
  order with one or more test items.
- **FR-009**: Order creation MUST validate that at least one test
  item is selected.
- **FR-010**: Order creation MUST support optional clinical notes
  (max 2000 characters) and priority selection (routine, urgent,
  stat).
- **FR-011**: System MUST auto-generate order numbers in
  LAB-YYYY-NNNN format (server-side).
- **FR-012**: System MUST calculate total, discount, and final
  amounts from selected test prices (server-side).
- **FR-013**: Authenticated users MUST be able to view their own
  test orders in a paginated list.
- **FR-014**: Users MUST be able to filter orders by status.
- **FR-015**: Users MUST be able to view full order details
  including per-item results when available.
- **FR-016**: Users MUST be able to cancel orders that are in
  "pending" or "confirmed" status only, with a mandatory
  cancellation reason (max 500 characters).
- **FR-017**: Users MUST be able to download a PDF report for
  completed test orders.
- **FR-018**: All user-facing text MUST be localized in all five
  supported languages (EN, AR, DE, FR, HI).
- **FR-019**: All screens MUST support both light and dark themes
  using the existing design token system.
- **FR-020**: All screens MUST follow the Clinical Elegance design
  system (16px card radius, 12px input radius, 24px padding,
  navy-tinted shadows).

### Key Entities

- **Lab Test Category**: A grouping for lab tests. Attributes:
  name, slug, description, icon, display order, test count, status.
- **Lab Test**: A specific test or imaging service offered.
  Attributes: name, code, slug, category, department (laboratory
  or radiology), sample type, description, preparation instructions,
  price, turnaround time, status.
- **Test Order**: A patient's request for one or more lab tests.
  Attributes: order number, patient, doctor, lab technician, items,
  clinical notes, priority, order date, status, payment status,
  amounts (total, discount, final), reports, timestamps.
- **Test Order Item**: A single test within an order. Attributes:
  lab test reference, price, status, result value, result unit,
  reference range, result status, result notes, result date.

### Assumptions

- The patient app only needs the `user` (patient) role perspective.
  Doctor, lab technician, and admin views are not in scope.
- `patient_id` is automatically set to the authenticated user on
  order creation. The optional `doctor_id` field allows associating
  a referring doctor.
- Order pricing is calculated server-side from test prices. The
  client displays amounts but does not compute them.
- Report PDF generation is handled server-side. The client only
  triggers the download.
- The existing `buildHttpResponse()` network layer and token
  management handles authentication and error responses.
- Status badge colors follow standard patterns: pending=amber,
  confirmed=blue, processing=indigo, completed=green,
  delivered=teal, cancelled=red.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Users can browse the full test catalog (categories,
  tests, details) within 3 taps from the home screen.
- **SC-002**: Users can complete a test order (select tests, fill
  form, submit) in under 2 minutes.
- **SC-003**: Order list and detail screens load and display data
  within 2 seconds on a standard mobile connection.
- **SC-004**: All five user stories are functional in both light
  and dark themes without visual defects.
- **SC-005**: All user-facing text appears correctly in all five
  supported languages, including RTL layout for Arabic.
- **SC-006**: 95% of users can complete their first test order
  without assistance or errors.
- **SC-007**: Report PDF download completes and opens successfully
  on both Android and iOS devices.
