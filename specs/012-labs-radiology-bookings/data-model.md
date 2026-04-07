# Data Model: Labs & Radiology Booking System

**Feature**: Labs & Radiology Booking System
**Branch**: `012-labs-radiology-bookings`
**Date**: 2026-04-05

---

## Entity Relationship Diagram

```
┌─────────────────────┐
│  LabTestCategory    │
│  (id, name, slug)   │
└──────────┬──────────┘
           │ has many
           ▼
┌──────────────────────┐          ┌──────────────────────┐
│     LabTest          │  has     │   TestOrderItem      │
│ (id, name, code,     │◄────────┤  (id, test_id,       │
│  category_id,        │ many     │   order_id, price)   │
│  department,         │          └──────────┬───────────┘
│  sample_type, price) │                     │
└──────────────────────┘                     │
                                             │
┌──────────────────────┐          ┌──────────▼──────────┐
│    TestOrder         │          │   TestOrder [2]     │
│  (id, order_number,  │◄─────┤  │   has TestOrderItem │
│   patient_id,        │ items│   │   references [1]    │
│   doctor_id,         │      │   └─────────────────────┘
│   total_amount,      │      │
│   status,            │      └──┤ has many items
│   payment_status)    │
└──────────────────────┘

┌──────────────────┐
│   FacilityBooking│        ┌──────────────────┐    ┌──────────────────┐
│ (id, booking#,   │        │      Lab         │    │  RadiologyCenter │
│  facility_id,    │◄───┬───┤  (id, name,      │    │  (id, name,      │
│  type [lab|      │    │   │   is_active)     │    │   is_active)     │
│  radiology],     │    └──┤  (polymorphic)   │    │   (polymorphic)  │
│  booking_date,   │        └──────────────────┘    └──────────────────┘
│  booking_time,   │
│  status)         │
└──────────────────┘
```

---

## Detailed Entity Specifications

### 1. LabTestCategory

**Purpose**: Organize lab tests into categories for browsing and filtering.

| Field | Type | Required | Constraints | Notes |
|-------|------|----------|-------------|-------|
| id | int | Yes | Primary key, auto-increment | Unique identifier |
| name | string | Yes | max 255 | e.g., "Hematology", "Chemistry" |
| slug | string | Yes | max 255, unique | URL-friendly identifier |
| description | string | No | max 1000 | Purpose/scope of category |
| icon | string | No | max 255 | Icon class name (e.g., "ph-blood") |
| display_order | int | Yes | >= 1 | Sort order for UI display |
| test_count | int | Computed | >= 0 | Count of tests in category |
| status | int | Yes | 0 or 1 | 1 = active, 0 = inactive/archived |
| created_at | timestamp | Yes | Auto | Record creation time |
| updated_at | timestamp | Yes | Auto | Last modification time |

**Relationships**:
- has_many: LabTest

**Validation Rules**:
- name must be unique (no two categories with same name)
- slug must be unique and URL-safe (lowercase, hyphens)
- display_order must be >= 1

---

### 2. LabTest

**Purpose**: Individual lab test that can be ordered.

| Field | Type | Required | Constraints | Notes |
|-------|------|----------|-------------|-------|
| id | int | Yes | Primary key | Unique test identifier |
| name | string | Yes | max 255 | e.g., "Complete Blood Count (CBC)" |
| code | string | Yes | max 50, unique | Test code for ordering system |
| slug | string | Yes | max 255 | URL-friendly identifier |
| category_id | int | Yes | FK → LabTestCategory | Which category this test belongs to |
| department | enum | Yes | 'laboratory' \| 'radiology' | Test type |
| sample_type | enum | Yes | 'blood' \| 'urine' \| 'stool' \| 'tissue' \| 'imaging' \| 'swab' \| 'other' | Specimen type required |
| description | string | No | max 2000 | Detailed test description |
| preparation_instructions | string | No | max 2000 | Patient prep instructions (e.g., "Fasting required") |
| default_price | decimal | Yes | > 0, precision 2 | Base price in currency units |
| turnaround_time | string | Yes | max 100 | e.g., "24 hours", "2-3 business days" |
| reference_range | string | No | max 500 | Normal result range |
| status | int | Yes | 0 or 1 | 1 = active, 0 = archived |
| created_at | timestamp | Yes | Auto | Record creation time |
| updated_at | timestamp | Yes | Auto | Last modification time |

**Relationships**:
- belongs_to: LabTestCategory
- has_many: TestOrderItem

**Validation Rules**:
- code must be unique
- default_price must be > 0
- department must be one of: laboratory, radiology
- sample_type must be one of specified enums

**Usage Notes**:
- Price can be overridden at order time (stored in TestOrderItem)
- Only active tests (status=1) returned in public catalog API

---

### 3. TestOrder

**Purpose**: Patient's request to perform one or more lab tests.

| Field | Type | Required | Constraints | Notes |
|-------|------|----------|-------------|-------|
| id | int | Yes | Primary key | Unique order identifier |
| order_number | string | Yes | unique, format LAB-YYYY-NNNN | Human-readable order number |
| patient_id | int | Yes | FK → User (role=patient) | Patient requesting tests |
| doctor_id | int | No | FK → User (role=doctor) | Doctor who ordered tests (optional) |
| items | array[TestOrderItem] | Yes | min length 1 | Tests to perform |
| clinical_notes | string | No | max 2000 | Fasting, prep instructions, medical context |
| priority | enum | No | 'routine' \| 'urgent' \| 'stat' | Default: 'routine' |
| order_date | date | Yes | Auto | When order was created |
| status | enum | Yes | See workflow below | Current state in workflow |
| payment_status | enum | Yes | 'unpaid' \| 'partial' \| 'paid' | Payment completion |
| total_amount | decimal | Yes | >= 0, precision 2 | Sum of all items' prices |
| discount_amount | decimal | No | >= 0, precision 2 | Applied discount (if any) |
| final_amount | decimal | Yes | >= 0, precision 2 | total_amount - discount_amount |
| reports | array[Report] | No | (external) | PDF reports when results available |
| created_at | timestamp | Yes | Auto | Record creation time |
| updated_at | timestamp | Yes | Auto | Last modification time |

**Relationships**:
- belongs_to: User (patient)
- belongs_to: User (doctor, optional)
- has_many: TestOrderItem
- has_many: Report (computed)

**Status Workflow**:
```
pending ──(confirm)──→ confirmed ──(collect)──→ sample_collected
         ↘(cancel)↙                 ↘(cancel)↙
           ↓ cancelled              ↓ cancelled

sample_collected ──(start processing)──→ processing ──(complete)──→ completed ──(deliver)──→ delivered
                   ↘(cancel if not started)↙
                         ↓ cancelled
```

**Validation Rules**:
- items array must have minimum 1 test
- clinical_notes max 2000 characters
- priority must be one of: routine, urgent, stat
- final_amount = total_amount - discount_amount (must equal exactly)
- Cannot transition to invalid states (only allowed transitions above)

**Calculation Rules**:
- total_amount = sum(TestOrderItem.price for each item)
- discount_amount = applied discount (0 if none)
- final_amount = total_amount - discount_amount

---

### 4. TestOrderItem

**Purpose**: Line item in a test order (one test per item).

| Field | Type | Required | Constraints | Notes |
|-------|------|----------|-------------|-------|
| id | int | Yes | Primary key | Unique item identifier |
| order_id | int | Yes | FK → TestOrder | Which order this item belongs to |
| test_id | int | Yes | FK → LabTest | Which test to perform |
| price | decimal | Yes | > 0, precision 2 | Price for this item (may differ from test default_price) |
| status | enum | Yes | 'pending' \| 'sample_collected' \| 'processing' \| 'completed' | Item status |
| result_value | string | No | max 255 | Numerical or text result value |
| result_unit | string | No | max 100 | e.g., "mg/dL", "cells/μL" |
| reference_range | string | No | max 500 | Normal range for result interpretation |
| result_status | enum | No | 'normal' \| 'abnormal' \| 'pending' | Interpretation of result |
| result_notes | string | No | max 1000 | Clinical notes on result |
| result_date | datetime | No | Auto | When result was entered |
| created_at | timestamp | Yes | Auto | Record creation time |
| updated_at | timestamp | Yes | Auto | Last modification time |

**Relationships**:
- belongs_to: TestOrder
- belongs_to: LabTest

**Validation Rules**:
- price must be > 0
- status must be one of specified enums
- result_date should not be in future

**Usage Notes**:
- Results entered by lab technician (not patient)
- If no specific price override, use LabTest.default_price
- Status transitions flow with parent TestOrder

---

### 5. FacilityBooking

**Purpose**: Appointment slot reservation at a lab or radiology center.

| Field | Type | Required | Constraints | Notes |
|-------|------|----------|-------------|-------|
| id | int | Yes | Primary key | Unique booking identifier |
| booking_number | string | Yes | unique, format BK-YYYY-NNNN | Human-readable booking number |
| type | enum | Yes | 'lab' \| 'radiology' | Facility type |
| lab_id | int | Conditional | FK → Lab (if type='lab') | Which lab (if lab booking) |
| radiology_center_id | int | Conditional | FK → RadiologyCenter (if type='radiology') | Which radiology center (if radiology) |
| scan_type | string | No | max 255 | Scan/test type (radiology only) |
| patient_name | string | Yes | max 255 | Full name of patient |
| patient_phone | string | Yes | max 50 | Contact phone number |
| booking_date | date | Yes | >= today | Appointment date |
| booking_time | time | Yes | HH:MM format | Appointment time |
| notes | string | No | max 1000 | Special instructions or comments |
| status | enum | Yes | 'pending' \| 'confirmed' \| 'cancelled' \| 'completed' \| 'no_show' | Booking state |
| created_at | timestamp | Yes | Auto | Record creation time |
| updated_at | timestamp | Yes | Auto | Last modification time |

**Relationships**:
- belongs_to: Lab (if type='lab')
- belongs_to: RadiologyCenter (if type='radiology')
- Polymorphic reference to facility

**Validation Rules**:
- type must be 'lab' or 'radiology'
- lab_id required if type='lab', else null
- radiology_center_id required if type='radiology', else null
- booking_date must be >= today
- booking_time format HH:MM (24-hour)
- Cannot book if facility is_holiday=true or has no session for that date
- Cannot double-book same time slot

**Double-Booking Prevention**:
- Before confirming booking: check for existing bookings at same facility/date/time
- Use optimistic locking (version field) or database transaction

---

### 6. Lab

**Purpose**: Laboratory facility where tests can be performed.

| Field | Type | Required | Constraints | Notes |
|-------|------|----------|-------------|-------|
| id | int | Yes | Primary key | Unique lab identifier |
| name | string | Yes | max 255 | Lab name |
| address | string | No | max 500 | Physical address |
| phone | string | No | max 50 | Contact phone |
| working_hours | json | No | See format below | Operating schedule |
| is_active | boolean | Yes | Default: true | Can accept bookings? |
| is_holiday | boolean | Yes | Default: false | Closed today? |
| created_at | timestamp | Yes | Auto | Record creation time |
| updated_at | timestamp | Yes | Auto | Last modification time |

**working_hours format**:
```json
{
  "monday": { "start": "08:00", "end": "17:00" },
  "tuesday": { "start": "08:00", "end": "17:00" },
  ...
  "sunday": null  // closed
}
```

**Relationships**:
- has_many: FacilityBooking

**Validation Rules**:
- name must be unique
- If is_holiday=true, no slots available for that day

---

### 7. RadiologyCenter

**Purpose**: Radiology facility where imaging tests can be performed.

| Field | Type | Required | Constraints | Notes |
|-------|------|----------|-------------|-------|
| id | int | Yes | Primary key | Unique center identifier |
| name | string | Yes | max 255 | Center name |
| address | string | No | max 500 | Physical address |
| phone | string | No | max 50 | Contact phone |
| working_hours | json | No | Same format as Lab | Operating schedule |
| is_active | boolean | Yes | Default: true | Can accept bookings? |
| is_holiday | boolean | Yes | Default: false | Closed today? |
| created_at | timestamp | Yes | Auto | Record creation time |
| updated_at | timestamp | Yes | Auto | Last modification time |

**Relationships**:
- has_many: FacilityBooking

**Validation Rules**:
- name must be unique
- If is_holiday=true, no slots available for that day

---

## State & Workflow Diagrams

### TestOrder Status Workflow

```
[pending] ──confirm──> [confirmed]
   ▲                       │
   │                       ▼
   └──cancel──────────────[cancelled]
                           ▲
                           │
                    sample_collected ──collect sample──> [processing]
                           ▲                                │
                           │                                ▼
                           └──(if can't collect)───────[cancelled]
                                                          │
                                                          ▼
                                                      [completed]
                                                          │
                                                          ▼
                                                      [delivered]
```

### FacilityBooking Status Workflow

```
[pending] ──confirm──> [confirmed]
    │                     │
    └──cancel────────────[cancelled]
                          │
                          ▼
                      [completed] (appointment attended)
                          │
                          └──no_show (if didn't attend)
```

---

## API Request/Response Data Shapes

### CreateTestOrder Request
```json
{
  "items": [
    { "lab_test_id": 1 },
    { "lab_test_id": 3 }
  ],
  "clinical_notes": "Fasting required",
  "priority": "routine",
  "doctor_id": 2,
  "patient_id": 5
}
```

### TestOrderResponse
```json
{
  "id": 1,
  "order_number": "LAB-2026-0001",
  "patient": { "id": 5, "name": "John Doe", "email": "john@example.com" },
  "doctor": { "id": 2, "name": "Dr. Jane Smith" },
  "items": [...TestOrderItem array],
  "clinical_notes": "Fasting required",
  "priority": "routine",
  "order_date": "2026-03-25",
  "status": "pending",
  "payment_status": "unpaid",
  "total_amount": 450.00,
  "discount_amount": 0.00,
  "final_amount": 450.00,
  "reports": [],
  "created_at": "2026-03-25T10:30:00Z"
}
```

---

## Implementation Notes

1. **Cascade Behavior**: If a LabTest becomes inactive, existing orders referencing it remain valid (historical data)
2. **Soft Deletes**: Use status flags (status=0) instead of hard deletes for audit trails
3. **Pricing Precision**: Always use 2 decimal places for currency amounts
4. **Timezone Handling**: Store booking_date/booking_time in facility's local timezone; convert to UTC for API
5. **Audit Trails**: created_at and updated_at on all entities for compliance
