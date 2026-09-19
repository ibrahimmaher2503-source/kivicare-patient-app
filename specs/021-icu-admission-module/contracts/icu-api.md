# Contract: ICU Admission API

**Phase**: 1 — Design
**Branch**: `021-icu-admission-module`
**Date**: 2026-04-29

This contract enumerates the REST endpoints the ICU Admission module consumes from the Laravel backend at `https://espitalia.net/api/`. All endpoints inherit the existing app conventions:

- Authenticated via `Authorization: Bearer <apiToken>` (auto-attached by `buildHeaderTokens()`).
- Localised via `global-localization: <ar|en>`.
- Paginated lists use the standard `{data, current_page, last_page, total}` envelope (15 items per page).
- HTTPS only.

Endpoints are added to `lib/utils/api_end_points.dart` as constants on the existing `APIEndPoints` class.

---

## 1. Endpoint Index

| # | Method | Path | Constant name | Used by |
|---|--------|------|---------------|---------|
| 1 | GET | `/icu-hospitals` | `icuHospitals` | Hospital list (FR-001..006) |
| 2 | GET | `/icu-hospitals/{id}` | `icuHospitalDetail` (path-built) | Hospital detail (FR-007..010) |
| 3 | GET | `/icu-departments` | `icuDepartments` | Department types list (User Story 4) |
| 4 | GET | `/icu-hospitals/{id}/departments` | `icuHospitalDepartments` (path-built) | Department picker in form (FR-016) |
| 5 | POST | `/icu-admission-requests` | `icuAdmissionRequests` | Submit request (FR-020) |
| 6 | GET | `/icu-admission-requests` | `icuAdmissionRequests` | Request list (FR-024, 025) |
| 7 | GET | `/icu-admission-requests/{id}` | path-built | Request detail (FR-026..029) |
| 8 | POST | `/icu-admission-requests/{id}/cancel` | path-built | Cancel request (FR-030, 031) |
| 9 | GET | `/governorates` | `governorates` (existing) | Filter — reuse |
| 10 | GET | `/cities?governorate_id={id}` | `cities` (existing) | Filter — reuse |

---

## 2. GET `/icu-hospitals`

**Purpose**: Paginated hospital list with optional filters and search.

**Query parameters**

| Param | Type | Required | Notes |
|-------|------|----------|-------|
| `page` | int | no (default 1) | |
| `per_page` | int | no (default 15) | |
| `search` | string | no | Matches `name` ILIKE |
| `governorate_id` | int | no | |
| `city_id` | int | no | |
| `icu_department_id` | int | no | Hospitals offering this dept type |
| `has_available_beds` | bool | no | `true` filters to hospitals with `>0` beds in any dept |

**200 response**

```json
{
  "status": true,
  "message": "Hospitals fetched",
  "data": [ Hospital, ... ],
  "current_page": 1,
  "last_page": 4,
  "total": 47
}
```

**`Hospital` shape** (list mode — no `icu_departments`):

```json
{
  "id": 12,
  "name": "Cairo International Hospital",
  "description": null,
  "phone": "+20221234567",
  "emergency_phone": "+20227654321",
  "email": "info@example.com",
  "address_line": "12 Nile Corniche",
  "governorate_id": 1, "governorate_name": "Cairo",
  "city_id": 5, "city_name": "Maadi",
  "latitude": 29.961, "longitude": 31.244,
  "image_url": "https://...",
  "amenities": ["Parking", "Cafeteria"],
  "has_available_beds": true
}
```

---

## 3. GET `/icu-hospitals/{id}`

**Purpose**: Single hospital with embedded department list (with bed counts).

**200 response**

```json
{
  "status": true,
  "data": {
    /* Hospital fields as above, plus: */
    "icu_departments": [
      {
        "id": 1,
        "hospital_id": 12,
        "name": "Cardiac ICU",
        "description": "Specialised cardiac intensive care",
        "icon_url": "https://...",
        "available_beds": 2,
        "total_beds": 8
      }
    ]
  }
}
```

**404 response**: `{ "status": false, "message": "Hospital not found" }`. App shows empty-state with retry.

---

## 4. GET `/icu-departments`

**Purpose**: Global ICU department-type catalogue (User Story 4).

**200 response**

```json
{
  "status": true,
  "data": [
    { "id": 1, "name": "General ICU", "description": "...", "icon_url": "..." },
    { "id": 2, "name": "Cardiac ICU", "description": "...", "icon_url": "..." }
  ]
}
```

`hospital_id`, `available_beds`, `total_beds` are absent in this view.

---

## 5. GET `/icu-hospitals/{id}/departments`

**Purpose**: Department picker scoped to a specific hospital (FR-016 cascade).

**200 response**: same `data` array shape as §3's `icu_departments` field.

---

## 6. POST `/icu-admission-requests`

**Purpose**: Submit a new ICU admission request (FR-011..020).

**Request body** — exactly the fields in `AdmissionRequestFormPayload` (see `data-model.md` §8). The patient app MUST NOT send `status`, `reference_number`, `assigned_*`, `admitted_at`, `discharged_at`, payment, or commission fields (FR-023).

**200 / 201 response**

```json
{
  "status": true,
  "message": "Admission request submitted",
  "data": {
    "id": 9876,
    "reference_number": "ICU-2026-0001",
    "status": "pending",
    /* full AdmissionRequest as in §7 */
  }
}
```

**422 response** (server validation failure)

```json
{
  "status": false,
  "message": "Validation failed",
  "errors": {
    "diagnosis": ["The diagnosis field is required."],
    "accompanying_phone": ["Invalid phone format."]
  }
}
```

The app surfaces `message` via `toast()` and, if `errors.<field>` matches a form field, shows the first message inline under that field.

---

## 7. GET `/icu-admission-requests`

**Purpose**: Authenticated user's own request list (FR-024).

**Query parameters**

| Param | Type | Required | Notes |
|-------|------|----------|-------|
| `page` | int | no | |
| `status` | string | no | One of the 7 wire status values; omit for "All" |

**200 response**

```json
{
  "status": true,
  "data": [ AdmissionRequest (lightweight), ... ],
  "current_page": 1, "last_page": 2, "total": 18
}
```

Lightweight `AdmissionRequest` for list mode includes: `id`, `reference_number`, `status`, `urgency`, `patient_name`, `preferred_admission_at`, `created_at`, and a nested `hospital: { id, name }`. Full medical fields are omitted.

---

## 8. GET `/icu-admission-requests/{id}`

**Purpose**: Full request detail with `status_history`, assignment, and discharge info.

**200 response**

```json
{
  "status": true,
  "data": {
    "id": 9876,
    "reference_number": "ICU-2026-0001",
    "status": "admitted",
    "urgency": "urgent",
    "hospital": { /* lightweight hospital */ },
    "department": { "id": 1, "name": "Cardiac ICU" },
    "patient_name": "...", "patient_age": 64, "patient_gender": "male",
    "national_id": null,
    "diagnosis": "...", "current_condition": "...",
    "attending_doctor": "Dr. Salem", "medical_history": "...",
    "current_medications": "...", "allergies": "...",
    "additional_notes": null,
    "preferred_admission_at": "2026-05-02T10:00:00+02:00",
    "accompanying_name": "...", "accompanying_relation": "Spouse",
    "accompanying_phone": "+201112223344",
    "assigned_room": "ICU-3B",
    "assigned_bed": "12",
    "admitted_at": "2026-05-02T11:30:00+02:00",
    "discharged_at": null, "discharge_summary": null,
    "cancelled_at": null, "cancel_reason": null,
    "rejected_at": null, "rejection_reason": null,
    "status_history": [
      { "status": "pending", "changed_at": "2026-05-01T14:00:00+02:00", "note": null },
      { "status": "under_review", "changed_at": "2026-05-01T14:20:00+02:00", "note": null },
      { "status": "approved", "changed_at": "2026-05-01T15:10:00+02:00", "note": "Bed reserved" },
      { "status": "admitted", "changed_at": "2026-05-02T11:30:00+02:00", "note": null }
    ],
    "created_at": "2026-05-01T14:00:00+02:00",
    "updated_at": "2026-05-02T11:30:00+02:00"
  }
}
```

**404**: app shows empty-state with retry.

---

## 9. POST `/icu-admission-requests/{id}/cancel`

**Purpose**: Patient-triggered cancel transition (FR-030, 031).

**Request body**

```json
{ "reason": "string ≤ 500 chars (optional)" }
```

**200 response**

```json
{
  "status": true,
  "message": "Request cancelled",
  "data": { /* updated AdmissionRequest with status: cancelled, cancelled_at, cancel_reason */ }
}
```

**409 response** (request no longer cancellable — e.g. server already approved/rejected/admitted it)

```json
{ "status": false, "message": "Request cannot be cancelled in its current state" }
```

App shows the message via `toast()` and refreshes the detail page so the user sees the new state.

---

## 10. Governorates / Cities (reuse)

The `GET /governorates` and `GET /cities` endpoints already exist in `lib/utils/api_end_points.dart` and are consumed by `lib/screens/location_filter/`. No changes needed; the ICU filter screen reuses the existing `GovernorateSelectionScreen` and `CitySelectionScreen` (research.md §4).

---

## 11. Error Conventions

All endpoints return a `status: bool` flag plus optional `message`. The app's existing `handleResponse()` helper unwraps the JSON envelope; non-2xx responses throw and are caught by each controller's `.catchError((e) { toast(e.toString()); ... })`.

`401 Unauthorized` is intercepted by the existing `reGenerateToken()` retry path in `network_utils.dart` (Constitution IV — that path MUST NOT be modified for this feature).
