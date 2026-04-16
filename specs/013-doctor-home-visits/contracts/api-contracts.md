# API Contracts: Doctor Home Visit Requests

**Feature**: 013-doctor-home-visits
**Date**: 2026-04-06
**Base URL**: `https://espitalia.net/api/`

All endpoints require `auth:sanctum` authentication via Bearer token.

---

## Patient Endpoints

### 9.1 Submit Doctor Visit Request

```
POST /v1/doctor-visit/requests
Authorization: Bearer {token}
Content-Type: application/json
```

**Request Body**:

| Field | Type | Required | Validation |
|-------|------|----------|------------|
| visit_reason | string | Yes | max:1000 |
| preferred_date | date | Yes | Y-m-d, after_or_equal:today |
| contact_phone | string | Yes | max:20 |
| preferred_doctor_id | integer | No | exists:doctors,id |
| additional_notes | string | No | max:2000 |

**Example Request**:
```json
{
  "visit_reason": "Severe back pain for 3 days",
  "preferred_date": "2026-04-10",
  "contact_phone": "+966501234567",
  "preferred_doctor_id": 5,
  "additional_notes": "Please bring pain medication samples."
}
```

**Response (201 Created)**:
```json
{
  "status": true,
  "data": {
    "id": 42,
    "reference_number": "VR-2026-0042",
    "visit_type": "home_visit",
    "visit_reason": "Severe back pain for 3 days",
    "preferred_date": "2026-04-10",
    "contact_phone": "+966501234567",
    "additional_notes": "Please bring pain medication samples.",
    "status": "pending",
    "preferred_doctor": { "id": 5, "name": "Dr. Ahmed Al-Rashid" },
    "assigned_doctor": null,
    "created_at": "2026-04-05T10:30:00+00:00"
  },
  "message": "doctor_visit.request_submitted_success"
}
```

**Error Responses**:
- **422**: Validation errors (missing required fields, date in past, invalid doctor_id)

---

### 9.2 List My Visit Requests

```
GET /v1/doctor-visit/requests?page=1&per_page=15
Authorization: Bearer {token}
```

**Query Parameters**:

| Param | Type | Required | Default | Description |
|-------|------|----------|---------|-------------|
| page | int | No | 1 | Page number |
| per_page | int | No | 15 | Items per page |

**Response (200)**:
```json
{
  "status": true,
  "data": [
    {
      "id": 42,
      "reference_number": "VR-2026-0042",
      "visit_type": "home_visit",
      "visit_reason": "Severe back pain for 3 days",
      "preferred_date": "2026-04-10",
      "contact_phone": "+966501234567",
      "additional_notes": "Please bring pain medication samples.",
      "status": "pending",
      "preferred_doctor": { "id": 5, "name": "Dr. Ahmed Al-Rashid" },
      "assigned_doctor": null,
      "created_at": "2026-04-05T10:30:00+00:00"
    }
  ],
  "meta": {
    "current_page": 1,
    "last_page": 3,
    "per_page": 15,
    "total": 42
  }
}
```

Returns only the authenticated patient's requests, sorted by most recent first.

---

### 9.3 View Visit Request Detail

```
GET /v1/doctor-visit/requests/{reference}
Authorization: Bearer {token}
```

**URL Parameter**: `reference` — e.g., `VR-2026-0042`

**Response (200)**:
```json
{
  "status": true,
  "data": {
    "id": 42,
    "reference_number": "VR-2026-0042",
    "visit_type": "home_visit",
    "visit_reason": "Severe back pain for 3 days",
    "preferred_date": "2026-04-10",
    "contact_phone": "+966501234567",
    "additional_notes": "Please bring pain medication samples.",
    "status": "confirmed",
    "admin_notes": "Confirmed for morning slot.",
    "preferred_doctor": { "id": 5, "name": "Dr. Ahmed Al-Rashid" },
    "assigned_doctor": { "id": 7, "name": "Dr. Fatima Al-Sayed" },
    "cancellation_reason": null,
    "completed_at": null,
    "created_at": "2026-04-05T10:30:00+00:00"
  }
}
```

**Error Responses**:
- **403**: Request belongs to a different patient
- **404**: Reference not found

---

## Admin Endpoints

### 9.4 List All Visit Requests

```
GET /v1/admin/doctor-visit/requests
Authorization: Bearer {token}
```

Accessible to: admin, receptionist, or doctor roles.

**Query Parameters**:

| Param | Type | Required | Default | Description |
|-------|------|----------|---------|-------------|
| status | string | No | — | Filter: pending, confirmed, cancelled, completed |
| date_from | date | No | — | Filter preferred_date >= value |
| date_to | date | No | — | Filter preferred_date <= value |
| assigned_doctor_id | integer | No | — | Filter by assigned doctor |
| page | int | No | 1 | Page number |
| per_page | int | No | 15 | Items per page |

**Response (200)**: Same structure as patient list but includes `patient` field on each item:
```json
{
  "status": true,
  "data": [
    {
      "id": 42,
      "reference_number": "VR-2026-0042",
      "visit_reason": "Severe back pain for 3 days",
      "preferred_date": "2026-04-10",
      "status": "pending",
      "patient": { "id": 10, "name": "Mohammed Ali", "email": "m.ali@email.com" },
      "preferred_doctor": { "id": 5, "name": "Dr. Ahmed Al-Rashid" },
      "assigned_doctor": null,
      "created_at": "2026-04-05T10:30:00+00:00"
    }
  ],
  "meta": { "current_page": 1, "last_page": 1, "per_page": 15, "total": 1 }
}
```

---

### 9.5 Update Visit Request Status

```
PUT /v1/admin/doctor-visit/requests/{reference}/status
Authorization: Bearer {token}
```

Accessible to: admin, receptionist (any request), or doctor (only assigned requests).

**Request Body**:

| Field | Type | Required | Notes |
|-------|------|----------|-------|
| status | string | Yes | in: confirmed, cancelled, completed |
| cancellation_reason | string | No | Stored when status = cancelled |
| note | string | No | Appended to status history |

**Example Request**:
```json
{
  "status": "confirmed",
  "cancellation_reason": null,
  "note": "Confirmed for morning slot."
}
```

**Response (200)**: Updated visit request resource (same shape as detail endpoint).

**Error Responses**:
- **403**: Doctor not assigned to this request
- **422**: Invalid status transition (e.g., completed -> pending)

---

### 9.6 Assign Doctor

```
PUT /v1/admin/doctor-visit/requests/{reference}/assign-doctor
Authorization: Bearer {token}
```

Accessible to: admin or receptionist only.

**Request Body**:

| Field | Type | Required | Validation |
|-------|------|----------|------------|
| doctor_id | integer | Yes | exists:doctors,id |

**Example Request**:
```json
{
  "doctor_id": 7
}
```

**Response (200)**: Updated visit request resource with assigned_doctor populated.

**Error Responses**:
- **403**: Insufficient role (doctor cannot assign)
- **422**: Invalid doctor_id

---

## API Endpoint Registration

Add to `lib/utils/api_end_points.dart`:

```dart
// Doctor Home Visit
static const String doctorVisitRequests = 'v1/doctor-visit/requests';
static String doctorVisitRequestDetail(String reference) => '$doctorVisitRequests/$reference';
static const String adminDoctorVisitRequests = 'v1/admin/doctor-visit/requests';
static String adminDoctorVisitRequestStatus(String reference) => '$adminDoctorVisitRequests/$reference/status';
static String adminDoctorVisitRequestAssignDoctor(String reference) => '$adminDoctorVisitRequests/$reference/assign-doctor';
```

Note: The detail endpoint uses a string `reference` parameter (e.g., "VR-2026-0042"), not a numeric `id`. This differs from other features that use `int id`.
