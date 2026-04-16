# API Contract: Facility Bookings

**Feature**: Labs & Radiology Booking System
**Version**: 1.0
**Date**: 2026-04-05

---

## Endpoints

### GET /v1/facility-bookings/labs/{labId}/slots

**Authentication**: None (public)

**Purpose**: Get available appointment slots at a lab

**Query Parameters**:

| Param | Type | Required | Description |
|-------|------|----------|-------------|
| `date` | string | Yes | Date in Y-m-d format, must be >= today |

**Request**:
```
GET /v1/facility-bookings/labs/1/slots?date=2026-04-05
```

**Response** (200):
```json
{
  "status": true,
  "data": {
    "facility": {
      "id": 1,
      "name": "Al Borg Lab",
      "type": "lab"
    },
    "date": "2026-04-05",
    "day": "sunday",
    "slots": [
      { "time": "08:00", "available": true },
      { "time": "08:30", "available": true },
      { "time": "09:00", "available": false },
      { "time": "09:30", "available": true }
    ]
  }
}
```

**Notes**:
- Returns empty slots array if no sessions for date or facility is_holiday=true
- `available: false` means slot already booked
- Slots in 30-minute intervals

**Error Responses**:
- 422: Invalid date format or date in past

---

### GET /v1/facility-bookings/radiology-centers/{centerId}/slots

**Authentication**: None (public)

**Purpose**: Get available appointment slots at a radiology center

**Query Parameters**: Same as lab slots

**Request**:
```
GET /v1/facility-bookings/radiology-centers/1/slots?date=2026-04-05
```

**Response** (200):
```json
{
  "status": true,
  "data": {
    "facility": {
      "id": 1,
      "name": "Elite Radiology Center",
      "type": "radiology"
    },
    "date": "2026-04-05",
    "day": "sunday",
    "slots": [
      { "time": "08:00", "available": true },
      { "time": "08:30", "available": true },
      { "time": "09:00", "available": false }
    ]
  }
}
```

---

### POST /v1/facility-bookings

**Authentication**: Required (Bearer token)

**Purpose**: Create a new facility booking

**Request**:
```json
{
  "type": "lab",
  "lab_id": 1,
  "booking_date": "2026-04-05",
  "booking_time": "09:00",
  "patient_name": "Ahmed Ali",
  "patient_phone": "+201234567890",
  "notes": "Fasting required"
}
```

**Request Fields**:

| Field | Type | Required | Validation |
|-------|------|----------|-----------|
| `type` | string | Yes | in: lab, radiology |
| `lab_id` | int | Conditional | if type=lab, exists in labs |
| `radiology_center_id` | int | Conditional | if type=radiology, exists in radiology_centers |
| `scan_type` | string | Conditional | if type=radiology, max 255 |
| `booking_date` | string | Yes | date Y-m-d, >= today |
| `booking_time` | string | Yes | time H:i format |
| `patient_name` | string | Yes | max 255 |
| `patient_phone` | string | Yes | max 50 |
| `notes` | string | No | max 1000 |

**Response** (201):
```json
{
  "status": true,
  "message": "Booking created successfully",
  "data": {
    "id": 1,
    "booking_number": "BK-2026-0001",
    "type": "lab",
    "facility": {
      "id": 1,
      "name": "Al Borg Lab"
    },
    "scan_type": null,
    "patient_name": "Ahmed Ali",
    "patient_phone": "+201234567890",
    "booking_date": "2026-04-05",
    "booking_time": "09:00",
    "status": "pending",
    "notes": "Fasting required",
    "created_at": "2026-04-02T10:00:00.000000Z"
  }
}
```

**Error Responses**:
- 422: Validation error or slot unavailable
- 401: Not authenticated
- 403: Insufficient permissions

---

### GET /v1/facility-bookings

**Authentication**: Required (Bearer token)

**Purpose**: List authenticated user's facility bookings

**Query Parameters**:

| Param | Type | Required | Description |
|-------|------|----------|-------------|
| `type` | string | No | Filter: lab, radiology |
| `status` | string | No | Filter: pending, confirmed, cancelled, completed, no_show |
| `page` | int | No | Page number (default: 1) |
| `per_page` | int | No | Items per page (default: 15) |

**Request**:
```
GET /v1/facility-bookings?type=lab&status=pending&page=1
```

**Response** (200):
```json
{
  "status": true,
  "data": [
    {
      "id": 1,
      "booking_number": "BK-2026-0001",
      "type": "lab",
      "facility": { "id": 1, "name": "Al Borg Lab" },
      "patient_name": "Ahmed Ali",
      "patient_phone": "+201234567890",
      "booking_date": "2026-04-05",
      "booking_time": "09:00",
      "status": "pending",
      "notes": "Fasting required",
      "created_at": "2026-04-02T10:00:00Z"
    }
  ],
  "meta": {
    "current_page": 1,
    "per_page": 15,
    "total": 25,
    "last_page": 2
  }
}
```

**Notes**:
- Results filtered by authenticated user's role
- Patient sees only own bookings
- Doctor/admin see assigned/all bookings respectively

---

### GET /v1/facility-bookings/{id}

**Authentication**: Required (Bearer token)

**Purpose**: Get single booking details

**Request**:
```
GET /v1/facility-bookings/1
```

**Response** (200):
```json
{
  "status": true,
  "data": {
    "id": 1,
    "booking_number": "BK-2026-0001",
    "type": "lab",
    "facility": {
      "id": 1,
      "name": "Al Borg Lab",
      "address": "Cairo, Egypt",
      "phone": "+20-xxx-xxx-xxxx"
    },
    "patient_name": "Ahmed Ali",
    "patient_phone": "+201234567890",
    "booking_date": "2026-04-05",
    "booking_time": "09:00",
    "status": "pending",
    "notes": "Fasting required",
    "created_at": "2026-04-02T10:00:00Z",
    "updated_at": "2026-04-02T10:00:00Z"
  }
}
```

**Error Responses**:
- 404: Booking not found
- 403: Not authorized to view this booking

---

### POST /v1/facility-bookings/{id}/cancel

**Authentication**: Required (Bearer token)

**Purpose**: Cancel a pending or confirmed booking

**Request**:
```json
{
  "cancellation_reason": "Patient needs to reschedule"
}
```

**Request Fields**:

| Field | Type | Required | Validation |
|-------|------|----------|-----------|
| `cancellation_reason` | string | Yes | max 500 |

**Response** (200):
```json
{
  "status": true,
  "message": "Booking cancelled successfully"
}
```

**Error Responses**:
- 422: Cannot cancel (already completed/no_show)
- 404: Booking not found
- 403: Not authorized

---

## Booking Status Workflow

```
pending ──(confirm)──→ confirmed
  ↓                       ↓
cancel ──────────────→ cancelled

confirmed ──(on appointment day)──→ completed
    ↓                                  ↓
  cancel ──────────────→ cancelled    (no changes after this)

confirmed ──(if no-show)──→ no_show
```

---

## Response Format

### Success Response

```json
{
  "status": true,
  "data": { /* or array */ },
  "message": "Success message (optional)"
}
```

### Error Response

```json
{
  "status": false,
  "message": "Error description",
  "errors": {
    "field_name": ["Validation error"]
  }
}
```

**HTTP Status Codes**:
- 200: OK
- 201: Created
- 400: Bad request
- 401: Unauthorized
- 403: Forbidden
- 404: Not found
- 422: Unprocessable entity (validation)
- 500: Server error

---

## Booking Validation Rules

1. **Date Validation**:
   - Must be >= today
   - Cannot be in past
   - Cannot book on facility holiday (is_holiday=true)

2. **Time Validation**:
   - Must be HH:MM format (24-hour)
   - Must be on 30-minute boundary (08:00, 08:30, etc.)
   - Must match available slot

3. **Double-Booking Prevention**:
   - Cannot book same facility/date/time twice
   - Use optimistic locking or database transaction

4. **Facility Availability**:
   - Facility must be active (is_active=true)
   - Must have session for that day

---

## Cancellation Rules

- Can cancel only from `pending` or `confirmed` status
- Cannot cancel from `completed` or `no_show`
- Cancellation reason is optional but recommended

---

## Testing Scenarios

### Happy Path

```gherkin
Scenario: User books facility appointment
  Given user has test order
  When user selects facility and available slot
  And provides patient details
  And submits booking
  Then booking number should be generated
  And status should be "pending"
  And confirmation notification sent
```

### Error Cases

```gherkin
Scenario: User tries to book unavailable slot
  Given slot is marked as unavailable
  When user tries to book that slot
  Then system should return 422 error
  And message "Slot is not available"
```

```gherkin
Scenario: User cancels confirmed booking
  Given booking is in "confirmed" status
  When user requests cancellation
  And provides reason
  Then booking status changes to "cancelled"
  And user receives confirmation
```

---

## Performance Expectations

- Slot availability: <500ms response time
- Create booking: <1s response time
- List bookings: <2s response time (including pagination)
- Double-booking prevention: 100% success rate

---

## Integration Notes

- Bookings work independently of test orders
- Patient can book facility without order (advance booking)
- Order and booking are linked via patient context, not direct FK
- Pricing handled separately (not in this contract)
