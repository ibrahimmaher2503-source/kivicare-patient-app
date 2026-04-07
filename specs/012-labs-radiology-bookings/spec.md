# Feature Specification: Labs & Radiology Booking System

**Feature Branch**: `012-labs-radiology-bookings`
**Created**: 2026-04-05
**Status**: Draft
**Input**: Comprehensive API specification for lab test ordering and radiology booking with facility slot management

## User Scenarios & Testing *(mandatory)*

<!--
  IMPORTANT: User stories should be PRIORITIZED as user journeys ordered by importance.
  Each user story/journey must be INDEPENDENTLY TESTABLE - meaning if you implement just ONE of them,
  you should still have a viable MVP (Minimum Viable Product) that delivers value.
  
  Assign priorities (P1, P2, P3, etc.) to each story, where P1 is the most critical.
  Think of each story as a standalone slice of functionality that can be:
  - Developed independently
  - Tested independently
  - Deployed independently
  - Demonstrated to users independently
-->

### User Story 1 - Browse and Search Available Lab Tests (Priority: P1)

Patients and healthcare providers need to discover and research available laboratory tests to understand what services are available and their characteristics before ordering.

**Why this priority**: This is the foundation of the lab ordering system. Without being able to search and view tests, users cannot proceed with ordering. This must work independently as a browsing/discovery feature.

**Independent Test**: User can view a list of lab tests filtered by category, search by name/code, and see details (price, sample type, turnaround time) without authentication. This delivers immediate value for educational and discovery purposes.

**Acceptance Scenarios**:

1. **Given** user is on lab tests browsing page, **When** user views the page, **Then** system displays paginated list of all available lab tests with name, code, category, price, and turnaround time
2. **Given** user has accessed the tests list, **When** user filters by category "Hematology", **Then** system displays only tests from that category
3. **Given** tests are displayed, **When** user searches for "blood", **Then** system returns tests with "blood" in name, code, or description
4. **Given** user selects a test, **When** clicking view details, **Then** system shows full test information including sample type, preparation instructions, and reference ranges

---

### User Story 2 - Order Multiple Lab Tests (Priority: P1)

Authenticated patients need to create test orders specifying which tests they want and providing clinical context so they can get laboratory work done.

**Why this priority**: Core transaction functionality. This is the primary conversion point where browsers become customers. Essential for revenue generation.

**Independent Test**: Authenticated user can select multiple tests, add clinical notes, set priority, and create an order that generates an order number and calculates total price. Works as a complete checkout flow.

**Acceptance Scenarios**:

1. **Given** authenticated user is viewing test details, **When** user adds tests to order and proceeds to checkout, **Then** system displays order summary with selected tests, calculated total, and pricing breakdown
2. **Given** user is on order form, **When** user enters clinical notes and selects priority level, **Then** system validates inputs (max 2000 chars for notes, priority in: routine/urgent/stat)
3. **Given** user submits order with valid data, **When** order is created, **Then** system generates order number in format LAB-YYYY-NNNN, sends confirmation notification, and displays success message
4. **Given** user creates order, **When** order is confirmed, **Then** patient and assigned doctor (if any) receive notification with order number and next steps

---

### User Story 3 - Browse Radiology Services (Priority: P2)

Patients and providers need to discover available radiology services (CT scans, ultrasounds, X-rays, etc.) with pricing and characteristics to make informed decisions about imaging studies.

**Why this priority**: Similar value to lab tests but slightly less critical than core lab ordering. Completes the diagnostic offerings but can be secondary to lab focus.

**Independent Test**: User can view radiology services organized by type, search for specific scan types, and see pricing without authentication. System distinguishes radiology department from laboratory.

**Acceptance Scenarios**:

1. **Given** user browses radiology services, **When** page loads, **Then** system displays available scan types with descriptions, pricing, and facility information
2. **Given** radiology services are displayed, **When** user filters by department "radiology", **Then** only radiology services are shown (not laboratory tests)

---

### User Story 4 - Book Lab/Radiology Appointment at Specific Facility (Priority: P1)

Patients need to book appointments at specific lab or radiology centers for their ordered tests or scans, selecting date and time that fits their schedule.

**Why this priority**: Essential for operational flow. Tests can't be completed without facility bookings. Required for end-to-end service delivery.

**Independent Test**: Authenticated user can view available appointment slots at a facility, select a date/time, and create a booking with patient details. Booking creates record and sends confirmation.

**Acceptance Scenarios**:

1. **Given** user has ordered tests or selected a radiology service, **When** user accesses facility booking, **Then** system displays calendar with available dates for the selected facility
2. **Given** user selects a date, **When** user views available slots, **Then** system shows time slots marked as available or booked (e.g., "08:00 - available", "09:00 - booked")
3. **Given** user selects an available slot, **When** user provides patient details (name, phone) and submits, **Then** system validates inputs and creates booking with status "pending"
4. **Given** booking is created successfully, **When** order is confirmed, **Then** system generates booking number (BK-YYYY-NNNN) and sends confirmation to user

---

### User Story 5 - View and Manage Test Orders and Bookings (Priority: P2)

Patients and providers need to track their test orders and facility bookings, viewing status, results when available, and having ability to cancel if needed.

**Why this priority**: Important for user confidence and operational management but secondary to initial creation. Can be implemented after core ordering/booking flows.

**Independent Test**: Authenticated user can list their orders/bookings filtered by status, view full details of each, and cancel pending orders. Status transitions follow defined workflow.

**Acceptance Scenarios**:

1. **Given** authenticated user navigates to "My Orders", **When** page loads, **Then** system displays user's test orders ordered by date, with status badges showing current state (pending/confirmed/processing/completed)
2. **Given** orders are displayed, **When** user filters by status "completed", **Then** only completed orders with available results are shown
3. **Given** user views a completed order, **When** user clicks "Download Report", **Then** system provides PDF file of test results
4. **Given** user views a pending/confirmed order, **When** user clicks "Cancel Order", **Then** system opens cancellation dialog, accepts cancellation reason, and updates order status to cancelled

---

### User Story 6 - Access Control by Role (Priority: P1)

Different user types (patients, doctors, lab technicians, admin) have different visibility and permissions for test orders and bookings based on their role.

**Why this priority**: Critical for data security, privacy, and proper operational workflows. Must be built into core ordering and listing logic.

**Independent Test**: When different user roles access order/booking lists, system correctly filters and displays only data they have permission to see, preventing unauthorized access.

**Acceptance Scenarios**:

1. **Given** authenticated patient views their orders, **When** they access order list, **Then** system shows only orders where they are the patient
2. **Given** authenticated doctor views orders, **When** they access order list, **Then** system shows only orders they assigned or are assigned to
3. **Given** lab technician views orders, **When** they access order list, **Then** system shows only orders assigned to them (if assignment implemented)
4. **Given** admin views orders, **When** they access order list, **Then** system shows all orders regardless of assignment

---

### Edge Cases

- What happens when user tries to book a slot that was just reserved by another user (simultaneous booking)?
- How does system handle test orders with multiple items when only some items' slots are available?
- Can user cancel an order that's already been marked as "sample_collected" or "processing"?
- What happens if a facility is marked as inactive after a booking is made but before the appointment date?
- How are pricing discounts applied if patient is eligible for bulk discounts?
- What timezone is used for slot availability display (facility's local time vs user's local time)?

## Requirements *(mandatory)*

<!--
  ACTION REQUIRED: The content in this section represents placeholders.
  Fill them out with the right functional requirements.
-->

### Functional Requirements

#### Lab Test Catalog
- **FR-001**: System MUST provide public (unauthenticated) endpoint to list all available lab test categories with metadata (id, name, slug, description, icon, display_order, test_count)
- **FR-002**: System MUST support pagination for lab test listing with configurable page size (default 15, max 100)
- **FR-003**: System MUST allow filtering lab tests by category_id to show only tests in a specific category
- **FR-004**: System MUST allow filtering by department ("laboratory" or "radiology") to distinguish test types
- **FR-005**: System MUST support full-text search across test name, code, and description fields
- **FR-006**: System MUST return test details including sample_type (blood, urine, stool, tissue, imaging, swab, other), preparation_instructions, default_price, and turnaround_time
- **FR-007**: System MUST provide single test detail endpoint accessible to unauthenticated users

#### Test Order Management
- **FR-008**: Authenticated users MUST be able to create test orders by selecting multiple tests and providing clinical_notes and priority level
- **FR-009**: System MUST validate test order requests: items array must have minimum 1 test, clinical_notes max 2000 characters, priority in (routine, urgent, stat), referenced tests must exist
- **FR-010**: System MUST auto-generate order numbers in format LAB-YYYY-NNNN where YYYY is current year and NNNN is sequential number
- **FR-011**: System MUST calculate total order amount by summing individual test prices, apply discounts if configured, and store final_amount
- **FR-012**: System MUST support order status tracking through workflow: pending → confirmed → sample_collected → processing → completed → delivered, with ability to cancel from pending/confirmed states
- **FR-013**: Authenticated users MUST be able to list their test orders with filtering by status
- **FR-014**: Authenticated users MUST be able to view full details of their orders including items, prices, patient info, doctor assignment, and current status
- **FR-015**: Authenticated users MUST be able to cancel pending or confirmed orders with optional cancellation reason
- **FR-016**: System MUST support downloading test reports as PDF for completed orders (auto-generate if not pre-stored)

#### Facility Booking System
- **FR-017**: System MUST provide endpoints to check available appointment slots at labs and radiology centers for specified date
- **FR-018**: System MUST return slot availability for a facility showing time blocks, available/booked status, and facility metadata
- **FR-019**: Authenticated users MUST be able to create facility bookings specifying: type (lab/radiology), facility_id, date, time, patient_name, patient_phone, and optional notes
- **FR-020**: System MUST validate facility booking requests: type must be in (lab, radiology), date must be future date, time format must be HH:MM, patient fields required, notes max 1000 chars
- **FR-021**: System MUST auto-generate booking numbers in format BK-YYYY-NNNN
- **FR-022**: System MUST prevent double-booking same slot (handle concurrent booking race conditions)
- **FR-023**: System MUST mark facility as inactive if it has no sessions for a date or if facility is_holiday flag is set
- **FR-024**: Authenticated users MUST be able to list their own bookings with filtering by type (lab/radiology) and status
- **FR-025**: Authenticated users MUST be able to view full details of their bookings including facility info, appointment time, and patient details
- **FR-026**: Authenticated users MUST be able to cancel pending bookings with optional cancellation reason

#### Role-Based Access Control
- **FR-027**: System MUST restrict order listing based on user role: patients see only own orders, doctors see assigned orders, lab_technicians see assigned orders, admins see all
- **FR-028**: System MUST restrict booking listing based on user role: patients see only own bookings, others see only their assigned bookings, admins see all
- **FR-029**: System MUST enforce role-based access control on detail views (403 if user lacks permission to view specific order/booking)
- **FR-030**: System MUST support optional doctor_id assignment when creating orders so doctors can place orders on behalf of patients

#### Data Persistence & Notifications
- **FR-031**: System MUST persist all test orders with complete audit trail (created_at, updated_at timestamps)
- **FR-032**: System MUST persist all facility bookings with complete audit trail
- **FR-033**: System MUST send notifications to patient and assigned doctor when test order is created
- **FR-034**: System MUST send confirmation notification when facility booking is created
- **FR-035**: System MUST support payment_status tracking on test orders (unpaid, partial, paid) for integration with payment system

### Key Entities *(include if feature involves data)*

- **LabTestCategory**: Represents category/classification of tests (Hematology, Chemistry, etc.). Key attributes: id, name, slug, description, icon, display_order, test_count, status
- **LabTest**: Represents individual test offering (Blood Test, Urinalysis, etc.). Key attributes: id, name, code, slug, category_id, department (laboratory/radiology), sample_type, description, preparation_instructions, default_price, turnaround_time, status
- **TestOrder**: Represents patient's request to perform multiple lab tests. Key attributes: id, order_number, patient_id, doctor_id, items (array of test selections), clinical_notes, priority, order_date, status (pending/confirmed/processing/completed/delivered/cancelled), payment_status, total_amount, discount_amount, final_amount
- **TestOrderItem**: Line item in a test order. Key attributes: id, test_id, order_id, price, status, result_value, result_unit, reference_range, result_status, result_date
- **FacilityBooking**: Represents appointment slot reservation at a facility. Key attributes: id, booking_number, type (lab/radiology), facility_id (lab_id or radiology_center_id), patient_name, patient_phone, booking_date, booking_time, notes, status (pending/confirmed/cancelled/completed/no_show), created_at
- **Lab**: Represents laboratory facility. Key attributes: id, name, address, phone, working_hours, is_active, is_holiday
- **RadiologyCenter**: Represents radiology facility. Key attributes: id, name, address, phone, working_hours, is_active, is_holiday

## Success Criteria *(mandatory)*

<!--
  ACTION REQUIRED: Define measurable success criteria.
  These must be technology-agnostic and measurable.
-->

### Measurable Outcomes

- **SC-001**: Users can search lab tests and see results in under 1 second (browsing without auth must be fast)
- **SC-002**: Patients can complete a test order from test selection to checkout in under 5 minutes
- **SC-003**: Facility slot availability API returns results in under 500ms even when facility has 100+ daily bookings
- **SC-004**: Patients can successfully book a facility appointment within 3 minutes of selecting their slot
- **SC-005**: Double-booking race condition is prevented 100% of the time (no simultaneous bookings on same slot)
- **SC-006**: System correctly applies role-based filtering so unauthorized users cannot see other users' orders/bookings
- **SC-007**: 95% of test orders complete (reach "completed" or "delivered" status) within promised turnaround time
- **SC-008**: Order totals are calculated correctly with zero pricing discrepancies (final_amount matches sum of line items)
- **SC-009**: All status transitions follow defined workflow (pending → confirmed → processing → completed) with no invalid state transitions
- **SC-010**: System supports minimum 1000 concurrent users browsing tests and 100 simultaneous bookings without degradation

## Assumptions

- **Authentication**: System uses existing Espitalia authentication (Bearer tokens with Sanctum). Public endpoints (test browsing) work without authentication.
- **Facility Sessions**: Lab and radiology centers have pre-defined working hours/sessions stored separately. Slot availability is calculated based on these sessions and existing bookings.
- **Pricing Model**: Test prices are stored individually and can have optional bulk discount rules. Orders auto-calculate totals from line items.
- **Notifications**: System uses existing Espitalia notification service (Firebase Cloud Messaging) to notify patients and doctors of order/booking changes.
- **Turnaround Times**: Test turnaround times are defined per-test and represent estimated business days from sample collection to results availability.
- **Payment Integration**: Payment status on orders will be updated by existing payment system. This feature focuses on order creation and does not directly handle payments.
- **Slot Granularity**: Facility slots are in 30-minute intervals (e.g., 08:00, 08:30, 09:00). This can be configured per-facility if needed.
- **Timezone Handling**: All dates/times use facility's local timezone for display. API uses ISO 8601 UTC internally.
- **Reporting**: Test results are entered separately by lab staff. This feature provides download capability for generated reports but doesn't handle result entry.
- **RTL Support**: Feature follows existing Espitalia i18n patterns for English/Arabic with proper RTL layout support for Arabic text.
