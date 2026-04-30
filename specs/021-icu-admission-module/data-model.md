# Data Model: ICU Admission Module

**Phase**: 1 — Design
**Branch**: `021-icu-admission-module`
**Date**: 2026-04-29

This document captures the entities, fields, validation rules, and state transitions used by the patient app. Backend storage shapes are owned by the Laravel API; the structures here are the **client-side representations** the app needs to deserialize from / serialize to that API.

---

## 1. Entity Overview

| Entity | Direction | File (planned) |
|--------|-----------|----------------|
| `Hospital` | Inbound | `lib/screens/icu_admission/models/hospital_model.dart` |
| `IcuDepartment` | Inbound | `lib/screens/icu_admission/models/icu_department_model.dart` |
| `AdmissionRequest` | Inbound | `lib/screens/icu_admission/models/admission_request_model.dart` |
| `StatusHistoryEntry` | Inbound (nested) | `lib/screens/icu_admission/models/status_history_model.dart` |
| `AdmissionRequestFormPayload` | Outbound (POST body) | `lib/screens/icu_admission/models/admission_request_form_payload.dart` |
| `IcuPaginatedResponse<T>` | Inbound (envelope) | `lib/screens/icu_admission/models/icu_paginated_response.dart` |

Enums: `UrgencyLevel`, `AdmissionStatus` — defined alongside `AdmissionRequest`.

---

## 2. Hospital

Represents a partner hospital with ICU capability. Read-only from the app.

| Field | Type | Nullable | Notes |
|-------|------|----------|-------|
| `id` | `int` | no | Server primary key |
| `name` | `String` | no | Display name (localised by server based on `global-localization` header) |
| `description` | `String?` | yes | Marketing blurb |
| `phone` | `String?` | yes | Reception number |
| `emergencyPhone` | `String?` | yes | Used by FR-008 (separate "Call Emergency" CTA) |
| `email` | `String?` | yes | |
| `addressLine` | `String?` | yes | |
| `governorateId` | `int?` | yes | FK — feeds the location filter |
| `governorateName` | `String?` | yes | Denormalised for list display |
| `cityId` | `int?` | yes | |
| `cityName` | `String?` | yes | |
| `latitude` | `double?` | yes | If present + `longitude` present, "Open in Maps" CTA shown (FR-010) |
| `longitude` | `double?` | yes | |
| `imageUrl` | `String?` | yes | Card thumbnail |
| `amenities` | `List<String>` | no (default `[]`) | Tags shown on detail page |
| `icuDepartments` | `List<IcuDepartment>` | no (default `[]`) | Empty in list responses; populated in detail responses |
| `hasAvailableBeds` | `bool` | no (default `false`) | Computed by server: any of `icuDepartments[i].availableBeds > 0` |

**Validation (inbound)**: `id` and `name` must be present. Missing → entity dropped from list and warning logged via `log()` (no toast — keeps the list usable).

---

## 3. IcuDepartment

A category of intensive care unit offered by a hospital. Read-only.

| Field | Type | Nullable | Notes |
|-------|------|----------|-------|
| `id` | `int` | no | Department-type id (stable across hospitals) |
| `hospitalId` | `int?` | yes | Null when listed from the global department-types endpoint |
| `name` | `String` | no | e.g. "General ICU", "Cardiac ICU" |
| `description` | `String?` | yes | Shown on the department list (User Story 4) |
| `iconUrl` | `String?` | yes | Optional asset for the department card |
| `availableBeds` | `int?` | yes | Null when not reported by hospital; `0` means "no beds available" but still bookable (Edge Cases) |
| `totalBeds` | `int?` | yes | Display only; not validated |

---

## 4. AdmissionRequest

A patient-initiated request and the central tracked entity in this module.

| Field | Type | Nullable | Notes |
|-------|------|----------|-------|
| `id` | `int` | no | Server primary key |
| `referenceNumber` | `String` | no | Format `ICU-YYYY-NNNN` (FR-020) |
| `status` | `AdmissionStatus` | no | See §6 state machine |
| `urgency` | `UrgencyLevel` | no | See §5 |
| `hospital` | `Hospital` | no | Lightweight — name, id, phones, emergencyPhone |
| `department` | `IcuDepartment` | no | Lightweight — id, name |
| `patientName` | `String` | no | |
| `patientAge` | `int` | no | 0–150 |
| `patientGender` | `String` | no | One of `male`, `female`, `other` |
| `nationalId` | `String?` | yes | Optional identifier |
| `diagnosis` | `String` | no | Required, ≤2000 chars |
| `currentCondition` | `String?` | yes | ≤2000 chars |
| `attendingDoctor` | `String?` | yes | Free text |
| `medicalHistory` | `String?` | yes | ≤2000 chars |
| `currentMedications` | `String?` | yes | ≤2000 chars |
| `allergies` | `String?` | yes | ≤2000 chars |
| `additionalNotes` | `String?` | yes | ≤2000 chars |
| `preferredAdmissionAt` | `DateTime?` | yes | If provided, must be within `[today, today+30d]` (FR-019) |
| `accompanyingName` | `String` | no | Required (FR-011) |
| `accompanyingRelation` | `String?` | yes | Optional |
| `accompanyingPhone` | `String` | no | Validated `^\+?\d{7,20}$` (FR-018) |
| `assignedRoom` | `String?` | yes | Only meaningful when status ∈ {Admitted, Discharged} (FR-027) |
| `assignedBed` | `String?` | yes | Same as above |
| `admittedAt` | `DateTime?` | yes | Same as above |
| `dischargedAt` | `DateTime?` | yes | Only meaningful when status = Discharged (FR-028) |
| `dischargeSummary` | `String?` | yes | |
| `cancelledAt` | `DateTime?` | yes | Only when status = Cancelled |
| `cancelReason` | `String?` | yes | Free text supplied at cancel time, ≤500 chars (FR-031) |
| `rejectedAt` | `DateTime?` | yes | Only when status = Rejected |
| `rejectionReason` | `String?` | yes | |
| `statusHistory` | `List<StatusHistoryEntry>` | no (default `[]`) | Newest-last; powers the timeline (FR-026) |
| `createdAt` | `DateTime` | no | |
| `updatedAt` | `DateTime?` | yes | |

**Note on outbound shape**: when the patient submits a request, only the patient/medical/scheduling/accompaniment fields go up — never `status`, `assignedRoom`, `assignedBed`, `admittedAt`, `dischargedAt`, `referenceNumber`, payment fields, or commission fields (FR-023). See `AdmissionRequestFormPayload` below.

---

## 5. UrgencyLevel (enum)

```dart
enum UrgencyLevel { routine, urgent, critical }
```

| Value | Wire format | UI treatment |
|-------|-------------|--------------|
| `routine` | `"routine"` | Neutral chip |
| `urgent` | `"urgent"` | Warning chip |
| `critical` | `"critical"` | Danger chip + triggers non-blocking emergency-call alert (FR-015) |

`UrgencyLevel.fromWire(String)` defaults unknown values to `routine` and logs.

---

## 6. AdmissionStatus (enum) and State Machine

```dart
enum AdmissionStatus {
  pending,
  underReview,
  approved,
  admitted,
  discharged,
  rejected,
  cancelled,
}
```

| Value | Wire format |
|-------|-------------|
| `pending` | `"pending"` |
| `underReview` | `"under_review"` |
| `approved` | `"approved"` |
| `admitted` | `"admitted"` |
| `discharged` | `"discharged"` |
| `rejected` | `"rejected"` |
| `cancelled` | `"cancelled"` |

### Allowed transitions

```
pending ─► under_review ─► approved ─► admitted ─► discharged
   │            │              │
   │            │              └─► rejected
   │            └─► rejected
   └─► rejected
   └─► cancelled (patient-triggered)
under_review ─► cancelled (patient-triggered)
```

**Patient app authority**: only `pending → cancelled` and `under_review → cancelled`. All other transitions are server-initiated. The app's "Cancel Request" CTA is shown iff `status ∈ {pending, underReview}` (FR-030).

### Predicates (used by UI controllers)

| Predicate | True when |
|-----------|-----------|
| `canCancel` | `status ∈ {pending, underReview}` |
| `showAdmissionCard` | `status ∈ {admitted, discharged}` (FR-027) |
| `showDischargeInfo` | `status == discharged` (FR-028) |
| `showCancelOrRejectionBanner` | `status ∈ {cancelled, rejected}` (FR-029) |

---

## 7. StatusHistoryEntry

| Field | Type | Nullable | Notes |
|-------|------|----------|-------|
| `status` | `AdmissionStatus` | no | The status entered |
| `changedAt` | `DateTime` | no | Server timestamp |
| `note` | `String?` | yes | Optional free text from the hospital staff |

Sorted oldest-first by the server. The UI renders them top-down in the timeline.

---

## 8. AdmissionRequestFormPayload (outbound DTO)

The `Map<String, dynamic>` body submitted by `IcuApis.submitAdmissionRequest`. Built from form state by an explicit `toJson()` so accidental fields cannot be smuggled in.

```dart
{
  'hospital_id': int,
  'icu_department_id': int,
  'patient_name': String,
  'patient_age': int,
  'patient_gender': String,            // 'male' | 'female' | 'other'
  'national_id': String?,              // omitted if empty
  'diagnosis': String,
  'current_condition': String?,
  'attending_doctor': String?,
  'medical_history': String?,
  'current_medications': String?,
  'allergies': String?,
  'urgency': String,                   // wire form of UrgencyLevel
  'preferred_admission_at': String?,   // ISO-8601 in device time zone, omitted if null
  'additional_notes': String?,
  'accompanying_name': String,
  'accompanying_relation': String?,
  'accompanying_phone': String,
}
```

Forbidden keys (FR-023): `status`, `reference_number`, `assigned_room`, `assigned_bed`, `admitted_at`, `discharged_at`, `payment_*`, `commission_*`.

---

## 9. IcuPaginatedResponse<T>

Standard envelope used by all list endpoints (per Assumption: 15 items per page).

```dart
class IcuPaginatedResponse<T> {
  final List<T> data;
  final int currentPage;
  final int lastPage;
  final int total;
  bool get hasMore => currentPage < lastPage;
}
```

Reuses the existing pagination convention from other modules — no new envelope shape.

---

## 10. Validation Rules (consolidated)

These are enforced **client-side** before submit, in addition to whatever the server enforces.

| Rule | Source | Field(s) |
|------|--------|----------|
| Required, non-empty after trim | FR-011 | `patientName`, `patientAge`, `patientGender`, `diagnosis`, `urgency`, `accompanyingName`, `accompanyingPhone`, `hospital`, `department` |
| `patientAge ∈ [0, 150]` | implicit | `patientAge` |
| `patientGender ∈ {male, female, other}` | implicit | `patientGender` |
| Length ≤ 2000 with live counter | FR-013 | `diagnosis`, `currentCondition`, `medicalHistory`, `currentMedications`, `allergies`, `additionalNotes` |
| Phone matches `^\+?\d{7,20}$` (after stripping spaces/dashes) | FR-018 | `accompanyingPhone` |
| Date in `[today, today+30d]` | FR-019 | `preferredAdmissionAt` |
| Cancel reason ≤ 500 | FR-031 | `cancelReason` |
| Hospital change clears department | FR-016 | derived |

All validators surface inline error text under the relevant field; submission is blocked while any error is non-null (SC-007).

---

## 11. Persistence

| Key | Storage | Lifetime | Sensitivity |
|-----|---------|----------|-------------|
| `lastIcuRequestReference` | `GetStorage` (default container) | Until overwritten or app data cleared | Non-PII (just a reference code like `ICU-2026-0001`) |

No other ICU data is persisted on device — every screen reads from the API on open / pull-to-refresh.

---

## 12. Error Surface

Inbound deserialization failures fall back to safe defaults (empty lists, default enum values) and log via `log()`. User-visible errors are routed through `toast()` (per Constitution IV) when an HTTP request itself fails.
