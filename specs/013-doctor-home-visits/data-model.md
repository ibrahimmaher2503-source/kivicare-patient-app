# Data Model: Doctor Home Visit Requests

**Feature**: 013-doctor-home-visits
**Date**: 2026-04-06

## Entity Diagram

```
DoctorVisitRequest
├── id (int)
├── reference_number (string) — format: VR-YYYY-NNNN
├── visit_type (string) — always "home_visit"
├── visit_reason (string) — max 1000 chars
├── preferred_date (string) — format: YYYY-MM-DD
├── contact_phone (string) — max 20 chars
├── additional_notes (string?) — max 2000 chars, nullable
├── status (string) — enum: pending, confirmed, cancelled, completed
├── admin_notes (string?) — nullable, visible in detail
├── cancellation_reason (string?) — nullable, set when cancelled
├── completed_at (string?) — nullable ISO datetime, set when completed
├── created_at (string) — ISO datetime
├── preferred_doctor (DoctorSummary?) — nullable embedded object
├── assigned_doctor (DoctorSummary?) — nullable embedded object
└── patient (PatientSummary?) — nullable, present in admin list responses

DoctorSummary
├── id (int)
└── name (string)

PatientSummary
├── id (int)
├── name (string)
└── email (string?)

DoctorVisitRequestListResponse
├── status (bool)
├── data (List<DoctorVisitRequest>)
├── message (string?)
└── meta
    ├── current_page (int)
    ├── last_page (int)
    ├── per_page (int)
    └── total (int)
```

## Entities

### DoctorVisitRequest

The core entity representing a patient's request for a doctor home visit.

| Field | Dart Type | JSON Key | Default | Validation |
|-------|-----------|----------|---------|------------|
| id | int | id | 0 | Server-generated |
| referenceNumber | String | reference_number | '' | Format: VR-YYYY-NNNN |
| visitType | String | visit_type | 'home_visit' | Always "home_visit" |
| visitReason | String | visit_reason | '' | Required, max 1000 |
| preferredDate | String | preferred_date | '' | Required, YYYY-MM-DD, >= today |
| contactPhone | String | contact_phone | '' | Required, max 20 |
| additionalNotes | String | additional_notes | '' | Optional, max 2000 |
| status | String | status | 'pending' | pending/confirmed/cancelled/completed |
| adminNotes | String | admin_notes | '' | Set by admin |
| cancellationReason | String | cancellation_reason | '' | Set when status = cancelled |
| completedAt | String | completed_at | '' | ISO datetime, set when completed |
| createdAt | String | created_at | '' | ISO datetime |
| preferredDoctor | DoctorSummary? | preferred_doctor | null | Optional, nested object |
| assignedDoctor | DoctorSummary? | assigned_doctor | null | Nullable, nested object |
| patient | PatientSummary? | patient | null | Present in admin responses |

### DoctorSummary

Lightweight doctor reference embedded in visit request responses.

| Field | Dart Type | JSON Key | Default |
|-------|-----------|----------|---------|
| id | int | id | 0 |
| name | String | name | '' |

### PatientSummary

Lightweight patient reference in admin list responses.

| Field | Dart Type | JSON Key | Default |
|-------|-----------|----------|---------|
| id | int | id | 0 |
| name | String | name | '' |
| email | String | email | '' |

### DoctorVisitRequestListResponse

Paginated list response wrapper.

| Field | Dart Type | JSON Key | Default |
|-------|-----------|----------|---------|
| status | bool | status | false |
| data | List\<DoctorVisitRequest\> | data | [] |
| message | String | message | '' |
| currentPage | int | meta.current_page | 1 |
| lastPage | int | meta.last_page | 1 |
| perPage | int | meta.per_page | 15 |
| total | int | meta.total | 0 |

## State Transitions

```
         ┌──────────────┐
         │   pending     │ (initial state on creation)
         └──────┬───────┘
                │
        ┌───────┴───────┐
        ▼               ▼
┌──────────────┐ ┌──────────────┐
│  confirmed   │ │  cancelled   │ (terminal)
└──────┬───────┘ └──────────────┘
       │
 ┌─────┴─────┐
 ▼           ▼
┌──────────────┐ ┌──────────────┐
│  completed   │ │  cancelled   │ (terminal)
│  (terminal)  │ └──────────────┘
└──────────────┘
```

**Valid transitions**:
- pending -> confirmed
- pending -> cancelled
- confirmed -> completed
- confirmed -> cancelled

**Invalid transitions** (rejected with 422):
- completed -> any
- cancelled -> any
- confirmed -> pending
- Any backwards transition

## Request Body Models

### SubmitVisitRequest (POST /v1/doctor-visit/requests)

```dart
Map<String, dynamic> toJson() => {
  'visit_reason': visitReason,        // required, max 1000
  'preferred_date': preferredDate,    // required, YYYY-MM-DD, >= today
  'contact_phone': contactPhone,      // required, max 20
  if (preferredDoctorId != null) 'preferred_doctor_id': preferredDoctorId,  // optional
  if (additionalNotes.isNotEmpty) 'additional_notes': additionalNotes,      // optional, max 2000
};
```

### UpdateStatusRequest (PUT /v1/admin/doctor-visit/requests/{ref}/status)

```dart
Map<String, dynamic> toJson() => {
  'status': status,                   // required: confirmed, cancelled, completed
  if (cancellationReason != null) 'cancellation_reason': cancellationReason,
  if (note != null) 'note': note,
};
```

### AssignDoctorRequest (PUT /v1/admin/doctor-visit/requests/{ref}/assign-doctor)

```dart
Map<String, dynamic> toJson() => {
  'doctor_id': doctorId,              // required, exists:doctors,id
};
```
