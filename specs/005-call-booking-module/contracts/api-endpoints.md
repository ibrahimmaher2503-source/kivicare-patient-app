# API Contracts: Call Booking Module

**Base URL**: `https://espitalia.net/api/v1`

## Public Endpoints (No Auth)

### GET /call-doctors

Returns paginated list of doctors with active call services.

**Query Parameters**:

| Param    | Type   | Required | Default | Notes            |
|----------|--------|----------|---------|------------------|
| per_page | int    | No       | 15      | Page size        |
| page     | int    | No       | 1       | Page number      |
| search   | string | No       | —       | Doctor name      |

**Response** `200`: Array of CallDoctorResource with nested call_services.

### GET /call-doctors/{id}/services

Returns a doctor's call services. No auth required.

**Response** `200`: Array of CallServiceResource.

## Authenticated Endpoints (Bearer Token)

### POST /call-doctors/{id}/slots

Returns available time slots for a specific date and service.

**Request**:
```json
{
  "appointment_date": "2026-03-28",
  "call_service_id": 1
}
```

**Response** `200`:
```json
{
  "status": true,
  "data": [
    { "value": "09:00", "label": "9:00 AM" },
    { "value": "09:30", "label": "9:30 AM" }
  ]
}
```

### POST /call-booking

Creates a call booking.

**Request**:
```json
{
  "doctor_id": 1,
  "call_service_id": 1,
  "appointment_date": "2026-03-28",
  "appointment_time": "09:00",
  "transaction_type": "cash"
}
```

**Validation**:

| Field            | Type   | Required | Rules                    |
|------------------|--------|----------|--------------------------|
| doctor_id        | int    | Yes      | Must exist, status=1     |
| call_service_id  | int    | Yes      | Must exist               |
| appointment_date | date   | Yes      | after_or_equal: today    |
| appointment_time | time   | Yes      | 24h format HH:MM        |
| transaction_type | string | No       | cash/stripe/razorpay/etc |

**Response** `200`:
```json
{
  "status": true,
  "message": "Appointment created successfully",
  "data": { "...": "CallBookingResource" },
  "meeting_link": "https://meet.jit.si/...",
  "call_type": "video",
  "service_name": "Video Consultation",
  "duration": 30,
  "total_amount": 135.00
}
```
