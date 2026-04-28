# Phase 1 Data Model — Nurse Request (Home Nursing) Module

This document specifies the entities the patient client deserializes from and serializes to the backend, plus all client-side validation rules and state-transition rules surfaced in the UI. Field types use Dart conventions.

## Conventions

- All `fromJson` factories MUST be null-safe with sensible defaults (`?? 0`, `?? ''`, `?? []`, `?? false`).
- Server-controlled fields (status, total amount, reference number, payment status, assigned nurse, status history, timestamps) are read-only on the client and MUST NOT be sent in the create payload.
- All `DateTime` fields use ISO-8601 strings on the wire and `DateTime` in Dart; null on the wire stays null in Dart.
- All money amounts are non-negative `double`; currency is an ISO-4217 string (`EGP` is the default per the existing app currency config).

---

## Entity: NurseRequest

A patient's submitted home-nursing request. The central entity of this module.

### Fields

| Field | Wire key | Dart type | Direction | Notes |
|-------|----------|-----------|-----------|-------|
| `id` | `id` | `int` | server → client | Numeric id used for detail fetch and deep-linking. |
| `referenceNumber` | `reference_number` | `String` | server → client | Format `NR-YYYY-NNNN`. Opaque on the client. |
| `serviceDescriptionEn` | `service_description_en` | `String?` | both | At least one of EN/AR MUST be non-empty (cross-field rule, see Validation). Max 2,000 chars. Trimmed before send. |
| `serviceDescriptionAr` | `service_description_ar` | `String?` | both | Same as above, mirrored language. |
| `preferredDate` | `preferred_date` | `DateTime` | both | Required. ISO date (no time) on wire; client renders in active locale. Must be `today` ≤ d ≤ `today + 90 days`. |
| `preferredTime` | `preferred_time` | `String?` | both | Optional `HH:mm` 24-h. |
| `durationHours` | `duration_hours` | `int` | both | Required. Range 1..24 inclusive. |
| `addressLine1` | `address_line_1` | `String` | both | Required. Max 255 chars. |
| `addressLine2` | `address_line_2` | `String?` | both | Optional. Max 255 chars. |
| `governorateId` | `governorate_id` | `int?` | both | Optional FK to `Governorate`. Omitted from payload when null. |
| `cityId` | `city_id` | `int?` | both | Optional FK to `City`. Cleared whenever `governorateId` changes. Omitted from payload when null. |
| `city` | `city` | `String` | both | Required. Holds the free-text city name when no `cityId` is selected, OR the display name copied from the dropdown selection when `cityId` is set. Both `city` (always) and `city_id` (when picked) MUST be sent. Max 100 chars. |
| `state` | `state` | `String?` | both | Optional. Max 100 chars. Hidden behind the "More address details" toggle on the form. |
| `country` | `country` | `String?` | both | Optional. Max 100 chars. |
| `postalCode` | `postal_code` | `String?` | both | Optional. Max 20 chars. |
| `contactPhone` | `contact_phone` | `String` | both | Required. Max 20 chars. Pattern `^\+?[0-9]{7,20}$`. Defaults to `+20` prefix in the form. |
| `patientNotes` | `patient_notes` | `String?` | both | Optional. Max 2,000 chars. |
| `status` | `status` | `String` | server → client | One of the 6 enum values (see Status Enum below). Client never sends this. |
| `assignedNurse` | `assigned_nurse` | `AssignedNurse?` | server → client | Present only when admin has assigned a nurse. |
| `totalAmount` | `total_amount` | `double?` | server → client | Present only when admin has calculated pricing. |
| `currency` | `currency` | `String?` | server → client | ISO-4217 (defaults to app currency on render if null). |
| `paymentStatus` | `payment_status` | `String?` | server → client | E.g. `unpaid`, `paid`, `refunded`. Patient-visible label localized on render. |
| `cancellationReason` | `cancellation_reason` | `String?` | server → client | Present only on cancelled requests. |
| `completedAt` | `completed_at` | `DateTime?` | server → client | Present only on completed requests. |
| `createdAt` | `created_at` | `DateTime` | server → client | Submission timestamp. |
| `updatedAt` | `updated_at` | `DateTime` | server → client | Last-mutation timestamp. |
| `statusHistory` | `status_history` | `List<StatusHistoryEntry>` | server → client | Empty list when absent. Patient-visible but actor identity is hidden. |

### Validation rules (client-side, applied before submit)

- `serviceDescriptionEn.isNotEmpty || serviceDescriptionAr.isNotEmpty` after trim. Otherwise: top-level inline error in the description section.
- `serviceDescriptionEn.length <= 2000` and `serviceDescriptionAr.length <= 2000`. Counters visible on each field.
- `preferredDate` ∈ `[today, today + 90 days]`. Picker disables out-of-range dates; submission still re-asserts.
- `preferredTime` matches `^[0-2][0-9]:[0-5][0-9]$` when present.
- `durationHours` ∈ `[1, 24]`. Stepper disables boundary controls.
- `addressLine1.isNotEmpty` and `addressLine1.length <= 255`.
- `city.isNotEmpty` and `city.length <= 100`.
- `contactPhone.matches(r'^\+?[0-9]{7,20}$')`.
- All optional string fields max-length-checked.

### Payload omission rules (FR-021, FR-022)

When building the POST body, the client MUST:

- Trim all string fields.
- Omit any optional field whose value is null, empty (after trim), or zero where zero is the "unset" sentinel for the field.
- NEVER include: `id`, `reference_number`, `status`, `assigned_nurse`, `total_amount`, `currency`, `payment_status`, `cancellation_reason`, `completed_at`, `created_at`, `updated_at`, `status_history`. These are server-controlled.

### Lifecycle / status enum

Status values (FR-040), ordered:

1. `pending` — initial state on submission.
2. `assigned` — admin has linked an `assigned_nurse`.
3. `confirmed` — admin has confirmed the assignment with the patient (administratively).
4. `in_progress` — the visit has started.
5. `completed` — terminal success. `completed_at` set.
6. `cancelled` — terminal failure. `cancellation_reason` set. May be reached from any earlier state.

Patient-side rules:

- The client renders the current status and the timeline; it never mutates status.
- `assignedNurse` is shown if and only if non-null (independent of status, since admin may assign before formal confirmation).
- Pricing card is shown if and only if `totalAmount != null` (independent of status; admin may price post-assignment).
- Cancellation banner is shown if and only if `status == "cancelled"`.

---

## Entity: AssignedNurse

The nurse the admin has assigned. Patient-visible subset only.

### Fields

| Field | Wire key | Dart type | Direction | Notes |
|-------|----------|-----------|-----------|-------|
| `id` | `id` | `int` | server → client | Server identity. Used only for navigation / phone-call attribution. |
| `displayName` | `display_name` | `String` | server → client | Localized to active app language by the backend if it can, else patient sees the name as stored. |
| `avatarUrl` | `avatar_url` | `String?` | server → client | Optional; client falls back to a generic nurse silhouette when null. |
| `phone` | `phone` | `String?` | server → client | Optional. Wired up to tap-to-call when present. |
| `rating` | `rating` | `double?` | server → client | 0.0–5.0; renders only when present. |
| `bio` | `bio` | `String?` | server → client | Short bio, multi-line allowed; renders only when present. |

---

## Entity: StatusHistoryEntry

A single transition in a request's lifecycle.

### Fields

| Field | Wire key | Dart type | Direction | Notes |
|-------|----------|-----------|-----------|-------|
| `previousStatus` | `previous_status` | `String?` | server → client | Null on the initial entry (creation). |
| `newStatus` | `new_status` | `String` | server → client | One of the 6 enum values. |
| `note` | `note` | `String?` | server → client | Optional admin note about the change. |
| `changedAt` | `changed_at` | `DateTime` | server → client | When the change happened. |

The actor identity (admin, system, etc.) is intentionally NOT exposed to the patient.

---

## Entity: NurseRequestListResponse (paginated wrapper)

Wraps a single page of `NurseRequest` items with the standard Laravel pagination meta the patient app already consumes elsewhere.

### Fields

| Field | Wire key | Dart type | Notes |
|-------|----------|-----------|-------|
| `data` | `data` | `List<NurseRequest>` | Page entries. |
| `currentPage` | `meta.current_page` | `int` | 1-indexed. |
| `lastPage` | `meta.last_page` | `int` | Used to compute `hasMore`. |
| `perPage` | `meta.per_page` | `int` | Always 15 in this module's calls. |
| `total` | `meta.total` | `int` | Total entries on the patient's account that match the active filter. |

`hasMore` is a computed Dart getter: `currentPage < lastPage`.

---

## Entity: Governorate (existing, reused)

Already used elsewhere in the app. Listed here for completeness because the form relies on it.

### Fields

| Field | Wire key | Dart type | Notes |
|-------|----------|-----------|-------|
| `id` | `id` | `int` | |
| `name` | `name` | `String` | Localized by backend per active language. |

---

## Entity: City (existing, reused)

Subdivision of a `Governorate`.

### Fields

| Field | Wire key | Dart type | Notes |
|-------|----------|-----------|-------|
| `id` | `id` | `int` | |
| `name` | `name` | `String` | Localized by backend. |
| `governorateId` | `governorate_id` | `int` | FK back to the parent governorate. |

---

## Cross-field invariants (must hold both client-side and on receipt)

- A request whose `status == "cancelled"` MUST have a non-null `cancellationReason`.
- A request whose `status == "completed"` MUST have a non-null `completedAt`.
- If `assignedNurse != null`, then `status` is one of `assigned`, `confirmed`, `in_progress`, `completed` (the admin cannot un-assign back to `pending`).
- If `governorateId == null`, then `cityId == null` (cityId only valid in the context of a chosen governorate). `city` (free text) is always present and required.
- The `preferred_date` and `preferred_time` strings are interpreted as wall-clock in `Africa/Cairo` (clarification C5). The client MUST NOT shift these values into the device's local zone when rendering or validating.

When the backend violates an invariant, the client logs via `dart:developer` `log()` and renders defensively (e.g., hides the cancellation banner if status is `cancelled` but reason is null) rather than crashing.
