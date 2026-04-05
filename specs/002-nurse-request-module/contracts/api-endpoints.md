# API Contracts: Nurse Request Module

**Base URL**: `https://espitalia.net/api/v1`
**Auth**: All endpoints require Bearer token (auth:sanctum)

## Nurse Endpoints

### GET /nurses

Returns paginated list of nurses with optional filters.

**Query Parameters**:

| Param               | Type   | Required | Default | Notes                       |
|---------------------|--------|----------|---------|-----------------------------|
| per_page            | int    | No       | 15      | Page size                   |
| page                | int    | No       | 1       | Page number                 |
| availability_status | string | No       | —       | available, unavailable      |
| service_area        | string | No       | —       | LIKE search                 |
| specialization      | string | No       | —       | LIKE search                 |
| search              | string | No       | —       | Search name/spec/area       |

**Response** `200`:
```json
{
  "status": true,
  "data": [
    {
      "id": 1,
      "nurse_id": 10,
      "name": "Jane Nurse",
      "first_name": "Jane",
      "last_name": "Nurse",
      "email": "jane@example.com",
      "mobile": "+201234567890",
      "specialization": "ICU Care",
      "experience": "5 years",
      "about": "Experienced ICU nurse",
      "hourly_rate": 50.00,
      "availability_status": "available",
      "service_area": "Cairo",
      "profile_image": "https://...",
      "status": 1,
      "created_at": "...",
      "updated_at": "..."
    }
  ],
  "meta": { "current_page": 1, "per_page": 15, "total": 50, "last_page": 4 }
}
```

### GET /nurses/{nurse_id}

Returns single nurse profile. `nurse_id` is the User ID.

## Nurse Request Endpoints

### GET /nurse-requests

Returns paginated requests for authenticated patient.

**Query Parameters**:

| Param    | Type   | Required | Default | Notes                                              |
|----------|--------|----------|---------|----------------------------------------------------|
| per_page | int    | No       | 15      | Page size                                          |
| page     | int    | No       | 1       | Page number                                        |
| status   | string | No       | —       | pending, confirmed, in_progress, completed, cancelled |
| search   | string | No       | —       | Search description/city/patient name               |

### POST /nurse-requests

Creates a new nurse request.

**Request**:
```json
{
  "service_description": "Post-surgery home care",
  "preferred_date": "2026-03-28",
  "preferred_time": "09:00",
  "duration_hours": 4,
  "address_line_1": "123 Main St",
  "address_line_2": "Apt 5",
  "city": "Cairo",
  "state": "Cairo",
  "country": "Egypt",
  "postal_code": "12345",
  "contact_number": "+201234567890",
  "patient_notes": "Patient has mobility issues",
  "nurse_id": 10
}
```

**Validation**:

| Field               | Type    | Required | Rules                            |
|---------------------|---------|----------|----------------------------------|
| service_description | string  | Yes      | max: 1000                        |
| preferred_date      | date    | Yes      | after_or_equal: today            |
| preferred_time      | time    | No       | Format H:i                       |
| duration_hours      | numeric | Yes      | min: 1, max: 24                  |
| address_line_1      | string  | Yes      | max: 255                         |
| address_line_2      | string  | No       | max: 255                         |
| city                | string  | Yes      | max: 100                         |
| state               | string  | No       |                                  |
| country             | string  | No       |                                  |
| postal_code         | string  | No       |                                  |
| contact_number      | string  | Yes      | max: 20                          |
| patient_notes       | string  | No       |                                  |
| nurse_id            | int     | No       | Must exist                       |

**Response** `201`:
```json
{
  "status": true,
  "message": "request_nurse.request_save_success",
  "data": { "...": "NurseRequestResource" }
}
```

### GET /nurse-requests/{id}

Returns single request detail. Role-based access.

### PUT /nurse-requests/{id}

Updates a request. Only own requests in "pending" status.
Same fields as create.

**Response** `200`:
```json
{
  "status": true,
  "message": "request_nurse.request_update_success",
  "data": { "...": "NurseRequestResource" }
}
```

### POST /nurse-requests/{id}/cancel

Cancels a request (pending or confirmed only).

**Request**:
```json
{ "cancellation_reason": "No longer needed" }
```

**Validation**: `cancellation_reason` required, max: 500

**Response** `200`:
```json
{
  "status": true,
  "message": "request_nurse.request_cancel_success"
}
```
