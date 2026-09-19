# API Endpoints Contract

**Base path**: `https://espitalia.net/api/`
**Auth**: Bearer token via `buildHeaderTokens()`
**Localization header**: `global-localization: <language_code>`
**Pagination**: 15 per page, newest first. Standard Laravel paginator wrapper.

All endpoint **constants** live in `lib/utils/api_end_points.dart`. All **methods** live in `lib/api/labs_radiology_apis.dart`.

---

## Endpoint constants (added to `api_end_points.dart`)

```dart
// ============================================
// LABS & RADIOLOGY MODULE
// ============================================
static const String labsSearch        = "labs/search";
static const String radiologySearch   = "radiology/search";
static const String labTestCategories = "v1/lab-test-categories";
static const String labTests          = "v1/lab-tests";
// labTests + '/' + id  → show
static const String facilityBookings  = "v1/facility-bookings";
// facilityBookings + '/labs/' + labId + '/slots'
// facilityBookings + '/radiology-centers/' + centerId + '/slots'
static const String testOrders        = "v1/test-orders";
// testOrders + '/' + id                  → show
// testOrders + '/' + id + '/cancel'      → cancel
// testOrders + '/' + id + '/report/download'  → download
```

**Excluded — must NOT be added:** `/v1/admin/facility-bookings/*` (admin scope).

---

## 1. `GET /labs/search`

Search labs with optional filters.

**Query parameters**:

| Param | Type | Required | Notes |
|---|---|---|---|
| `search` | string | no | Free-text |
| `governorate_id` | int | no | |
| `city_id` | int | no | |
| `lab_test_id` | int | no | Filter labs offering a specific test |
| `page` | int | no | Default 1 |
| `per_page` | int | no | Default 15 |

**Response** (200): `FacilityListResponse` with `data: List<FacilityModel>`. See `data-model.md`.

---

## 2. `GET /radiology/search`

Same shape as `/labs/search`. Replace `lab_test_id` with `service_id`.

---

## 3. `GET /v1/lab-test-categories`

List all diagnostic test categories. Cached client-side for 7 days (R-6).

**Response** (200):
```json
{
  "data": [
    {"id": 1, "name": "Blood Tests", "icon": "...", "description": "...", "tests_count": 32},
    ...
  ]
}
```

Returns to `Future<List<LabTestCategoryModel>>`.

---

## 4. `GET /v1/lab-tests`

List/search lab tests.

**Query parameters**:

| Param | Type | Required | Notes |
|---|---|---|---|
| `search` | string | no | |
| `category_id` | int | no | |
| `facility_id` | int | no | Tests offered by a specific facility |
| `page` | int | no | |
| `per_page` | int | no | Default 15 |

**Response** (200): `LabTestListResponse`.

---

## 5. `GET /v1/lab-tests/{id}`

Get test detail.

**Response** (200): single `LabTestModel`.

---

## 6. `GET /v1/facility-bookings/labs/{labId}/slots`

Available slots for a lab.

**Response** (200):
```json
{
  "data": {
    "facility_id": 12,
    "facility_type": "lab",
    "available_dates": ["2026-05-10", "2026-05-11"],
    "slots_by_date": {
      "2026-05-10": [
        {"id": 789, "start_time": "09:00", "end_time": "09:30", "available": true},
        {"id": 790, "start_time": "09:30", "end_time": "10:00", "available": false}
      ]
    }
  }
}
```

Maps to `SlotsResponse`.

---

## 7. `GET /v1/facility-bookings/radiology-centers/{centerId}/slots`

Same response shape as endpoint 6.

---

## 8. `POST /v1/test-orders` *(canonical creation endpoint — see R-1)*

Create a test order.

**Request body** (built by `BookingPayload.toJson()`):

```json
{
  "facility_type":   "lab",
  "facility_id":     12,
  "lab_test_id":     45,
  "slot_id":         789,
  "preferred_date":  "2026-05-10",
  "preferred_time":  "10:30",
  "notes":           "Doctor referral attached if any",
  "patient_notes":   "Fasting since last night"
}
```

**Validation** (mirrors server, runs in `BookingPayload.validate()`):

| Field | Rule |
|---|---|
| `facility_type` | required, `lab` or `radiology` |
| `facility_id` | required, integer |
| `lab_test_id` | required for `facility_type == lab`, optional for radiology |
| `slot_id` | required, integer |
| `preferred_date` | required, `yyyy-MM-dd`, today or future |
| `preferred_time` | required, `HH:mm` |
| `patient_notes` | optional, max 1000 chars |

**Response** (201): full `TestOrderModel` (see `data-model.md`).

**Conflict response** (409 or 422 with `slot_id` field error — see R-4): handled in UI per FR-014. App refetches slots and pops back to slot selection.

**Forbidden fields** (must never appear in the request body): see [api-forbidden-fields.md](./api-forbidden-fields.md).

---

## 9. `GET /v1/test-orders`

List the patient's test orders.

**Query parameters**:

| Param | Type | Notes |
|---|---|---|
| `status` | string | optional filter; uses `TestOrderStatus.apiValue` |
| `page` | int | |
| `per_page` | int | Default 15 |

**Response** (200): `TestOrderListResponse`.

---

## 10. `GET /v1/test-orders/{id}`

Get test order detail.

**Response** (200): single `TestOrderModel`.

---

## 11. `POST /v1/test-orders/{id}/cancel`

Cancel a test order.

**Request body** (optional reason):

```json
{ "cancellation_reason": "Schedule changed" }
```

The reason field is optional. If omitted, send an empty body `{}`.

**Response** (200): updated `TestOrderModel` with `status: cancelled` and `cancellation_reason` set.

**App-side guard**: only invoke when `order.status.isCancellable` is true. The Cancel button is hidden otherwise (FR-020).

---

## 12. `GET /v1/test-orders/{id}/report/download`

Download report PDF.

**Two acceptable response shapes** (handled in `ReportDownloadService`):

1. **Direct binary** — `Content-Type: application/pdf`, body is bytes. Save to `getApplicationDocumentsDirectory()` and open via `open_filex`.
2. **Signed URL JSON** — `Content-Type: application/json`, body `{ "url": "<signed_url>" }`. Re-fetch the URL (no Bearer header — the URL is signed) and save as above.

**Failure modes** (FR-023):

| Status | UI |
|---|---|
| 404 / `report_url == null` | Toast: `reportNotReady` |
| Network error mid-download | Toast with retry action |
| Permission denied (Android) | Explanatory dialog + open settings |

**Web platform**: bypass file system; trigger browser download via blob (R-3).

---

## Method signatures (in `lib/api/labs_radiology_apis.dart`)

```dart
class LabsRadiologyApis {
  static Future<FacilityListResponse> searchLabs({
    int page = 1, String? search, int? governorateId, int? cityId, int? labTestId,
  });

  static Future<FacilityListResponse> searchRadiology({
    int page = 1, String? search, int? governorateId, int? cityId, int? serviceId,
  });

  static Future<List<LabTestCategoryModel>> getTestCategories();

  static Future<LabTestListResponse> getLabTests({
    int page = 1, String? search, int? categoryId, int? facilityId,
  });

  static Future<LabTestModel> getLabTestById(int id);

  static Future<SlotsResponse> getLabSlots(int labId);
  static Future<SlotsResponse> getRadiologySlots(int centerId);

  static Future<TestOrderModel> createTestOrder(BookingPayload payload);

  static Future<TestOrderListResponse> getTestOrders({
    int page = 1, TestOrderStatus? statusFilter,
  });

  static Future<TestOrderModel> getTestOrderById(int id);
  static Future<TestOrderModel> cancelTestOrder(int id, {String? reason});

  /// Returns saved file on native, or triggers browser download on Web.
  /// On Web, returned File is a stub (path is empty) and UI must not call open_filex.
  static Future<File> downloadReport(int orderId, String referenceNumber);
}
```

All methods route through `buildHttpResponse()` → `handleResponse()` for token refresh and error mapping.
