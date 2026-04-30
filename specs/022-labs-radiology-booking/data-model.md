# Phase 1 Data Model: Labs & Radiology Booking Module

**Feature**: 022-labs-radiology-booking
**Date**: 2026-04-29

All models live under `lib/screens/labs_radiology/models/`. Conventions:

- `factory Model.fromJson(Map<String, dynamic> json)` and `Map<String, dynamic> toJson()`
- Null-safe with sensible defaults (`?? 0`, `?? ''`, `?? []`, `?? false`)
- `==` and `hashCode` implemented on `FacilityModel`, `LabTestModel`, `SlotModel`, `LabTestCategoryModel` to support selection logic
- Enum values use `apiValue` (snake_case) when serialised; Dart names use camelCase

---

## Enums

### `FacilityType`

```dart
enum FacilityType {
  lab,
  radiology;

  static FacilityType fromString(String? s) =>
      s == 'radiology' ? FacilityType.radiology : FacilityType.lab;

  String get apiValue => this == FacilityType.lab ? 'lab' : 'radiology';

  String get endpointBase =>
      this == FacilityType.lab ? 'labs' : 'radiology-centers';

  String displayLabel(BaseLanguage l) =>
      this == FacilityType.lab ? l.labs : l.radiology;
}
```

### `TestOrderStatus`

```dart
enum TestOrderStatus {
  pending,
  confirmed,
  sampleCollected,
  inProgress,
  completed,
  cancelled,
  rejected;

  static TestOrderStatus fromString(String? s) {
    switch (s) {
      case 'confirmed':         return TestOrderStatus.confirmed;
      case 'sample_collected':  return TestOrderStatus.sampleCollected;
      case 'in_progress':       return TestOrderStatus.inProgress;
      case 'completed':         return TestOrderStatus.completed;
      case 'cancelled':         return TestOrderStatus.cancelled;
      case 'rejected':          return TestOrderStatus.rejected;
      case 'pending':
      default:                  return TestOrderStatus.pending;
    }
  }

  String get apiValue {
    switch (this) {
      case TestOrderStatus.sampleCollected: return 'sample_collected';
      case TestOrderStatus.inProgress:      return 'in_progress';
      default:                              return name;
    }
  }

  bool get isTerminal =>
      this == TestOrderStatus.completed ||
      this == TestOrderStatus.cancelled ||
      this == TestOrderStatus.rejected;

  bool get isCancellable =>
      this == TestOrderStatus.pending ||
      this == TestOrderStatus.confirmed;

  String displayLabel(BaseLanguage l) {
    switch (this) {
      case TestOrderStatus.pending:         return l.statusPending;
      case TestOrderStatus.confirmed:       return l.statusConfirmed;
      case TestOrderStatus.sampleCollected: return l.statusSampleCollected;
      case TestOrderStatus.inProgress:      return l.statusInProgress;
      case TestOrderStatus.completed:       return l.statusCompleted;
      case TestOrderStatus.cancelled:       return l.statusCancelled;
      case TestOrderStatus.rejected:        return l.statusRejected;
    }
  }
}
```

---

## Entity: `FacilityModel`

| Field | Type | Source | Notes |
|---|---|---|---|
| `id` | `int` | `id` | Required |
| `name` | `String` | `name` | Required |
| `logo` | `String?` | `logo` | Nullable URL |
| `coverImage` | `String?` | `cover_image` | Nullable URL |
| `type` | `FacilityType` | `facility_type` | Required |
| `description` | `String?` | `description` | |
| `rating` | `double?` | `rating` | 0–5 |
| `reviewsCount` | `int` | `reviews_count` | Default 0 |
| `address` | `String` | `address` | Default `''` |
| `city` | `String?` | `city.name` or flat `city` | |
| `governorate` | `String?` | `governorate.name` or flat `governorate` | |
| `phone` | `String?` | `phone` | Used for tap-to-call |
| `email` | `String?` | `email` | |
| `latitude` | `double?` | `latitude` | |
| `longitude` | `double?` | `longitude` | |
| `services` | `List<String>` | `services` | Default `[]` |
| `availableTestsCount` | `int?` | `available_tests_count` | |
| `distanceKm` | `double?` | `distance_km` | Server-computed |
| `priceFrom` | `double?` | `price_from` | "starting from" UX |

**Equality**: by `id` + `type`.

**Validation**: `id > 0`, `name.isNotEmpty`. Anything else degrades gracefully.

---

## Entity: `FacilityListResponse`

| Field | Type | Source |
|---|---|---|
| `data` | `List<FacilityModel>` | `data` |
| `currentPage` | `int` | `current_page` |
| `lastPage` | `int` | `last_page` |
| `total` | `int` | `total` |
| `hasMore` | `bool` | computed: `currentPage < lastPage` |

---

## Entity: `LabTestCategoryModel`

| Field | Type | Source |
|---|---|---|
| `id` | `int` | `id` |
| `name` | `String` | `name` |
| `icon` | `String?` | `icon` |
| `description` | `String?` | `description` |
| `testsCount` | `int` | `tests_count` |

**Equality**: by `id`.

---

## Entity: `LabTestModel`

| Field | Type | Source | Notes |
|---|---|---|---|
| `id` | `int` | `id` | |
| `name` | `String` | `name` | |
| `slug` | `String?` | `slug` | |
| `category` | `LabTestCategoryModel?` | `category` | Embedded or by ref |
| `description` | `String?` | `description` | |
| `price` | `double?` | `price` | |
| `currency` | `String` | `currency` | Default `'EGP'` |
| `preparationInstructions` | `String?` | `preparation_instructions` | |
| `turnaroundHours` | `int?` | `turnaround_hours` | |
| `isImaging` | `bool` | `is_imaging` | Default `false` |
| `facilityType` | `FacilityType` | `facility_type` | Default `lab` |

**Equality**: by `id`.

---

## Entity: `LabTestListResponse`

Same shape as `FacilityListResponse` but with `data: List<LabTestModel>`.

---

## Entity: `SlotModel`

| Field | Type | Source | Notes |
|---|---|---|---|
| `id` | `int` | `id` | |
| `startTime` | `String` | `start_time` | `HH:mm` |
| `endTime` | `String` | `end_time` | `HH:mm` |
| `available` | `bool` | `available` | Default `false` |

**Equality**: by `id`.

**Helper**:
```dart
String formattedRange(String localeCode) {
  // Build a DateFormat('h:mm a', localeCode) display from startTime/endTime.
  // Returns "9:00 – 9:30 AM" (en) or "9:00 – 9:30 ص" (ar).
}
```

---

## Entity: `SlotsResponse`

| Field | Type | Source |
|---|---|---|
| `facilityId` | `int` | `data.facility_id` |
| `facilityType` | `FacilityType` | `data.facility_type` |
| `availableDates` | `List<DateTime>` | `data.available_dates` (parsed) |
| `slotsByDate` | `Map<String, List<SlotModel>>` | `data.slots_by_date` (keys are `yyyy-MM-dd`) |

**Helper**:
```dart
List<SlotModel> slotsFor(DateTime date) {
  final key = DateFormat('yyyy-MM-dd').format(date);
  return slotsByDate[key] ?? const [];
}
```

---

## Entity: `TestOrderModel`

| Field | Type | Source | Notes |
|---|---|---|---|
| `id` | `int` | `id` | |
| `referenceNumber` | `String` | `reference_number` | Format `TO-YYYY-NNNN` |
| `status` | `TestOrderStatus` | `status` | |
| `facilityType` | `FacilityType` | `facility_type` | |
| `facility` | `FacilityModel` | `facility` | Slim shape |
| `labTest` | `LabTestModel?` | `lab_test` | Nullable for radiology-only bookings |
| `slot` | `_SlotInfo` | `slot` | Inline `{date, startTime, endTime}` |
| `patientNotes` | `String?` | `patient_notes` | |
| `totalAmount` | `double?` | `total_amount` | Server-controlled |
| `currency` | `String` | `currency` | Default `'EGP'` |
| `paymentStatus` | `PaymentStatus` | `payment_status` | `unpaid` \| `paid` \| `refunded` |
| `reportUrl` | `String?` | `report_url` | |
| `reportUploadedAt` | `DateTime?` | `report_uploaded_at` | |
| `cancellationReason` | `String?` | `cancellation_reason` | |
| `statusHistories` | `List<TestOrderStatusHistoryModel>` | `status_histories` | Default `[]` |
| `completedAt` | `DateTime?` | `completed_at` | |
| `createdAt` | `DateTime` | `created_at` | |
| `updatedAt` | `DateTime` | `updated_at` | |

**Helper getters**:
```dart
bool get canCancel => status.isCancellable;
bool get hasReport => reportUrl != null && reportUrl!.isNotEmpty;
```

`PaymentStatus` enum: `unpaid`, `paid`, `refunded` with `fromString()` and `displayLabel()` (locale keys: `unpaid`, `paid`, `refunded`).

---

## Entity: `TestOrderListResponse`

Same shape as `FacilityListResponse` but with `data: List<TestOrderModel>`.

---

## Entity: `TestOrderStatusHistoryModel`

| Field | Type | Source |
|---|---|---|
| `oldStatus` | `TestOrderStatus?` | `old_status` |
| `newStatus` | `TestOrderStatus` | `new_status` |
| `note` | `String?` | `note` |
| `changedAt` | `DateTime` | `changed_at` |

---

## Entity: `BookingPayload`

Builder for `POST /v1/test-orders` body. **Strips nulls** and **never includes server-controlled fields**.

```dart
class BookingPayload {
  final FacilityType facilityType;
  final int facilityId;
  final int? labTestId;          // required for facility_type == lab
  final int slotId;
  final DateTime preferredDate;  // formatted yyyy-MM-dd
  final String preferredTime;    // HH:mm
  final String? notes;
  final String? patientNotes;

  Map<String, dynamic> toJson() {
    final m = <String, dynamic>{
      'facility_type':  facilityType.apiValue,
      'facility_id':    facilityId,
      'slot_id':        slotId,
      'preferred_date': DateFormat('yyyy-MM-dd').format(preferredDate),
      'preferred_time': preferredTime,
    };
    if (labTestId != null) m['lab_test_id'] = labTestId;
    if (notes?.trim().isNotEmpty == true) m['notes'] = notes!.trim();
    if (patientNotes?.trim().isNotEmpty == true) {
      m['patient_notes'] = patientNotes!.trim();
    }
    return m;
  }

  /// Validation per FR-010 + cross-field rule from spec §16.
  String? validate() {
    if (facilityType == FacilityType.lab && labTestId == null) {
      return 'lab_test_required';
    }
    if (preferredDate.isBefore(DateTime.now().subtract(const Duration(days: 1)))) {
      return 'preferred_date_past';
    }
    if (!RegExp(r'^\d{2}:\d{2}$').hasMatch(preferredTime)) {
      return 'preferred_time_invalid';
    }
    if ((patientNotes?.length ?? 0) > 1000) {
      return 'patient_notes_too_long';
    }
    return null;
  }
}
```

**Forbidden fields** (never serialised — covered by unit test in `test/screens/labs_radiology/booking_payload_test.dart`):
`status`, `total_amount`, `payment_status`, `report_url`, `report_uploaded_at`, `confirmed_at`, `cancelled_at`, `completed_at`, `admin_notes`, anything matching `commission_*` / `earnings_*`.

---

## State Transitions: TestOrderStatus

```
                        ┌─────────┐
                        │ pending │ ──┐── (patient cancel)
                        └────┬────┘   │
                             │        │
                             ▼        ▼
                       ┌──────────┐  ┌───────────┐
                       │confirmed │──┤ cancelled │  (terminal)
                       └────┬─────┘  └───────────┘
                            │              ▲
                            ▼              │
                ┌────────────────────┐     │
                │  sample_collected  │ ────┘ (lab only — radiology may skip)
                └─────────┬──────────┘
                          │
                          ▼
                 ┌────────────────┐
                 │  in_progress   │
                 └────────┬───────┘
                          │
                          ▼
                 ┌────────────────┐
                 │   completed    │  (terminal)
                 └────────────────┘

  rejected (terminal) — admin-driven, reachable from any pre-completed state
```

**App responsibilities** (verified in `test/screens/labs_radiology/test_order_status_test.dart`):
- `isCancellable`: only `pending` or `confirmed`.
- `isTerminal`: `completed`, `cancelled`, `rejected`.
- For radiology orders (`facilityType == radiology`), the timeline UI omits the `sampleCollected` step; the underlying status enum is unchanged.
- App **never** triggers any non-cancel transition — those are server-side.

---

## Persistence Models (GetStorage)

### `labs_radiology.test_categories` (envelope, R-6)

```json
{
  "cachedAt": "2026-04-29T12:34:56.000Z",
  "data": [ { /* LabTestCategoryModel JSON */ }, ... ]
}
```

Stale check: `now - cachedAt > 7 days`.

### `labs_radiology.last_facility_type` (R-9)

Plain string: `"lab"` or `"radiology"`. Read on hub init; default to `"lab"` if absent.
