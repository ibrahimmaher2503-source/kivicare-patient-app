# API Contracts: Unified Doctor-First Booking Experience

**Feature**: 010-unified-doctor-booking
**Date**: 2026-04-05

All API calls go through `lib/network/network_utils.dart` using `buildHttpResponse()`. No backend changes are required for this feature.

---

## Existing Endpoints Consumed (Unchanged)

### 1. Doctor Search (Clinic-Based)

**Endpoint**: `GET /doctors/search`
**Defined in**: `APIEndPoints.searchDoctors` → `CoreServiceApis.searchDoctors()`
**Used for**: Primary doctor browsing, QuickBook P4 doctor search

Request params:
```
page: int
per_page: int
name: String?        # doctor name or specialty search
governorate_id: int?
city_id: int?
specialty_id: int?
gender: String?
min_price: double?
max_price: double?
```

Response (paginated `Doctor` list):
```json
{
  "status": true,
  "data": [
    {
      "id": 1,
      "doctor_id": 42,
      "full_name": "Dr. Ahmed Hassan",
      "expert": "Cardiology",
      "profile_image": "https://...",
      "average_rating": 4.7,
      "total_reviews": 23,
      "experience": "10",
      "governorate": { "id": 1, "name": "Cairo" },
      "governorate_city": { "id": 5, "name": "Nasr City" }
    }
  ],
  "meta": { "current_page": 1, "last_page": 3, "per_page": 15, "total": 42 }
}
```

**UnifiedDoctor construction**: `UnifiedDoctor.fromDoctor(Doctor d)` — capability defaults to `[BookingCapability(type: BookingType.clinic)]`

---

### 2. Call Doctors List

**Endpoint**: `GET /v1/call-doctors`
**Defined in**: `APIEndPoints.callDoctors` → `CoreServiceApis.getCallDoctors()`
**Used for**: `CallDoctorListScreen`, capability detection

Request params:
```
page: int
per_page: int
```

Response:
```json
{
  "status": true,
  "data": [
    {
      "id": 3,
      "doctor_id": 42,
      "full_name": "Dr. Ahmed Hassan",
      "has_video_call": true,
      "has_phone_call": false,
      "call_starting_price": 150.0,
      "call_services": [ ... ]
    }
  ],
  "meta": { ... }
}
```

**UnifiedDoctor construction**: `UnifiedDoctor.fromCallDoctor(CallDoctor d)` — capabilities derived from `hasVideoCall` and `hasPhoneCall` flags

---

### 3. Independent Doctors List

**Endpoint**: `GET /v1/independent-doctors`
**Defined in**: `APIEndPoints.independentDoctors` → `CoreServiceApis.getIndependentDoctors()`
**Used for**: `IndependentDoctorListScreen`, capability detection

Response:
```json
{
  "status": true,
  "data": [
    {
      "id": 7,
      "doctor_id": 42,
      "full_name": "Dr. Ahmed Hassan",
      "address": "15 Tahrir St, Cairo",
      "average_rating": 4.5,
      "services": [ ... ]
    }
  ],
  "meta": { ... }
}
```

**UnifiedDoctor construction**: `UnifiedDoctor.fromIndependentDoctor(IndependentDoctor d)` — capability is `BookingCapability(type: BookingType.inPerson)`

---

### 4. Doctor Detail (Clinic)

**Endpoint**: `GET /v1/doctor-detail/{doctorId}`
**Used for**: Qualifications, reviews, clinic services on unified detail Book tab

Provides: `qualifications`, `reviews`, `services` (clinic services), `clinics`, `socialLinks`

---

### 5. Call Doctor Services

**Endpoint**: `GET /v1/call-doctors/{id}/services`
**Used for**: Book tab → Video Call / Phone Call section services

Response:
```json
[
  {
    "id": 1,
    "doctor_id": 3,
    "name": "General Consultation",
    "call_type": "video",
    "duration_min": 30,
    "charges": 150.0,
    "final_price": 120.0
  }
]
```

---

### 6. Independent Doctor Services

**Endpoint**: `GET /v1/independent-doctors/{id}/services`
**Used for**: Book tab → In-Person section services
**New method**: `CoreServiceApis.getIndependentDoctorServices(int id)` — follows same pattern as `getCallDoctorServices()`

---

### 7. Time Slots

| Booking Type | Method | Endpoint | Key Params |
|---|---|---|---|
| Clinic | GET | `/get-time-slots` | `doctor_id, clinic_id, service_id, appointment_date` |
| Video/Phone Call | POST | `/v1/call-doctors/{id}/slots` | `date, call_service_id` |
| In-Person | POST | `/v1/independent-doctors/{id}/slots` | `date, independent_service_id` |

---

### 8. Booking Creation

| Booking Type | Method | Endpoint | Content-Type |
|---|---|---|---|
| Clinic | POST | `/save-booking` | multipart/form-data |
| Call | POST | `/v1/call-booking` | application/json |
| Independent | POST | `/v1/independent-booking` | application/json |

**These endpoints are not modified.** The unified detail screen navigates to the existing booking screens which call these endpoints.

---

## Error Handling

All capability-loading calls in `UnifiedDoctorDetailController` use `.catchError(() => [])` — a 404 or any error for call/independent services simply means that capability is not shown. This supports FR-014 (partial availability graceful handling).

Booking endpoint errors surface via the existing `toast()` pattern in each respective booking screen.
