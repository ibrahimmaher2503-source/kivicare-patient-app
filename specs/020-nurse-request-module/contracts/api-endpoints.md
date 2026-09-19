# API Contract — Nurse Request (Home Nursing) Module

Base URL (from `lib/configs.dart`): `https://espitalia.net/api/`

All requests carry the standard auth headers built by `lib/network/network_utils.dart::buildHeaderTokens()`:

```
Authorization: Bearer <api_token>
global-localization: <en|ar>
Content-Type: application/json
Accept: application/json
```

The HTTP layer transparently re-issues the request once on a 401 response after `reGenerateToken()` succeeds (Constitution IV).

The patient client touches **3 nurse-request endpoints** plus 2 existing location reference endpoints. No `PUT` or `DELETE` is invoked from this client (request edit and delete are out of patient scope).

---

## C1 — Submit a new nurse request

**Method**: `POST`
**Path**: `nurse-requests`
**Auth**: Bearer token (required)
**Constant**: `APIEndPoints.createNurseRequest`

### Request body (JSON)

Only fields the patient supplied are present. Empty optional fields are omitted entirely (FR-021). The forbidden fields (FR-022) MUST NEVER appear in the body.

```json
{
  "service_description_en": "Daily blood pressure check and dressing change.",
  "service_description_ar": "قياس ضغط يومي وتغيير الضمادة.",
  "preferred_date": "2026-05-02",
  "preferred_time": "10:00",
  "duration_hours": 3,
  "address_line_1": "12 El-Tahrir St., Apt 4",
  "address_line_2": "Floor 3",
  "governorate_id": 11,
  "city_id": 47,
  "city": "Maadi",
  "state": "Cairo Governorate",
  "country": "Egypt",
  "postal_code": "11431",
  "contact_phone": "+201001234567",
  "patient_notes": "Please ring the doorbell twice."
}
```

`preferred_date` and `preferred_time` are interpreted as wall-clock values in `Africa/Cairo` (clarification C5). They carry no time-zone designator on the wire.

Minimal valid body (only required fields):

```json
{
  "service_description_en": "Daily wound dressing change.",
  "preferred_date": "2026-05-02",
  "duration_hours": 2,
  "address_line_1": "12 El-Tahrir St.",
  "city": "Maadi",
  "contact_phone": "+201001234567"
}
```

### Forbidden fields in any request body

`id`, `reference_number`, `status`, `assigned_nurse`, `total_amount`, `currency`, `payment_status`, `cancellation_reason`, `completed_at`, `created_at`, `updated_at`, `status_history`. The client builds the payload with an explicit allow-list — never by JSON-serializing the whole `NurseRequest` model.

### Successful response (HTTP 201)

```json
{
  "data": {
    "id": 42,
    "reference_number": "NR-2026-0042",
    "service_description_en": "Daily wound dressing change.",
    "service_description_ar": null,
    "preferred_date": "2026-05-02",
    "preferred_time": null,
    "duration_hours": 2,
    "address_line_1": "12 El-Tahrir St.",
    "address_line_2": null,
    "governorate_id": null,
    "city_id": null,
    "city": "Maadi",
    "state": null,
    "country": null,
    "postal_code": null,
    "contact_phone": "+201001234567",
    "patient_notes": null,
    "status": "pending",
    "assigned_nurse": null,
    "total_amount": null,
    "currency": null,
    "payment_status": null,
    "cancellation_reason": null,
    "completed_at": null,
    "created_at": "2026-04-28T13:42:11Z",
    "updated_at": "2026-04-28T13:42:11Z",
    "status_history": [
      {
        "previous_status": null,
        "new_status": "pending",
        "note": null,
        "changed_at": "2026-04-28T13:42:11Z"
      }
    ]
  }
}
```

### Error responses

| HTTP | Shape | Client behavior |
|------|-------|-----------------|
| `422` | `{"message": "...", "errors": {"<field>": ["..."]}}` | Field-level errors render inline next to each errored field (FR-023). Cross-field errors (e.g., both descriptions empty) render as a top-level message. |
| `401` | (handled by network layer) | Token refresh + retry, transparent to UI (FR-047). |
| `5xx` / network | `{"message": "..."}` or thrown | Toast the error message; restore the form intact (no data loss). |

---

## C2 — List the patient's nurse requests (paginated)

**Method**: `GET`
**Path**: `nurse-requests`
**Auth**: Bearer token (required)
**Constant**: `APIEndPoints.getNurseRequests`

### Query parameters

| Param | Type | Required | Notes |
|-------|------|----------|-------|
| `page` | `int` | yes | 1-indexed. |
| `per_page` | `int` | yes | Always `15` from this client (FR-027). |
| `status` | `string` | no | When set: one of `pending`, `assigned`, `confirmed`, `in_progress`, `completed`, `cancelled`. Omitted for "All". |

### Successful response (HTTP 200)

```json
{
  "data": [
    { "id": 42, "reference_number": "NR-2026-0042", "...": "..." },
    { "id": 41, "reference_number": "NR-2026-0041", "...": "..." }
  ],
  "meta": {
    "current_page": 1,
    "last_page": 4,
    "per_page": 15,
    "total": 53
  },
  "links": {
    "first": "...",
    "last": "...",
    "prev": null,
    "next": "..."
  }
}
```

Each `data[i]` has the same shape as the `data` object in C1's response. The list cell does NOT need every field — it consumes only those shown on a card per FR-030 — but the deserialized model retains everything for cheap detail-view hydration if the patient taps a card before the detail fetch completes.

### Sorting

The backend orders by `created_at DESC`. The client does not re-sort (FR-027). The client trusts server order.

### Error responses

| HTTP | Client behavior |
|------|-----------------|
| `401` | Transparent refresh + retry. |
| `5xx` / network | If no cached entries: render recoverable error state with retry button (FR-033). If cached entries exist: keep them visible, surface a non-blocking toast. |

---

## C3 — Fetch a single nurse-request's full detail

**Method**: `GET`
**Path**: `nurse-requests/{id}`
**Auth**: Bearer token (required)
**Constant**: `APIEndPoints.getNurseRequestDetail` (append `/{id}` per the project pattern)

### Path parameters

| Param | Type | Notes |
|-------|------|-------|
| `id` | `int` | The numeric `id` from C1's response or any C2 entry. |

### Successful response (HTTP 200)

Same shape as the `data` object in C1's response — including `assigned_nurse`, `total_amount`, `currency`, `payment_status`, `cancellation_reason`, `completed_at`, and the full `status_history` array (oldest → newest).

When admin has acted, `assigned_nurse` is populated:

```json
{
  "data": {
    "id": 42,
    "reference_number": "NR-2026-0042",
    "...": "...",
    "status": "in_progress",
    "assigned_nurse": {
      "id": 7,
      "display_name": "Sara M.",
      "avatar_url": "https://espitalia.net/storage/nurses/7.jpg",
      "phone": "+201112345678",
      "rating": 4.8,
      "bio": "5+ years home-care experience."
    },
    "total_amount": 850.00,
    "currency": "EGP",
    "payment_status": "unpaid",
    "...": "...",
    "status_history": [
      { "previous_status": null,        "new_status": "pending",     "note": null,                   "changed_at": "2026-04-28T13:42:11Z" },
      { "previous_status": "pending",   "new_status": "assigned",    "note": "Assigned to Sara M.",  "changed_at": "2026-04-28T15:10:00Z" },
      { "previous_status": "assigned",  "new_status": "confirmed",   "note": null,                   "changed_at": "2026-04-29T09:00:00Z" },
      { "previous_status": "confirmed", "new_status": "in_progress", "note": null,                   "changed_at": "2026-05-02T10:05:00Z" }
    ]
  }
}
```

### Error responses

| HTTP | Client behavior |
|------|-----------------|
| `401` | Transparent refresh + retry. |
| `404` | Show a "not found" empty state with a back-to-list action (rare; only if the request was deleted server-side). |
| `5xx` / network | If no cached entry from the list: error state with retry. Otherwise: keep last-known-good rendered, toast the error (FR-038 partial-state preservation). |

---

## C4 — List governorates (existing, reused)

**Method**: `GET`
**Path**: `governorates`
**Constant**: `APIEndPoints.governorates`

Returns `{ "data": [{ "id": 1, "name": "Cairo" }, ...] }`. Used to populate the governorate dropdown on the form. Failure is non-blocking — the form falls back to free-text city per FR-014.

---

## C5 — List cities for a governorate (existing, reused)

**Method**: `GET`
**Path**: `cities?governorate_id={id}`
**Constant**: `APIEndPoints.cities`

Returns `{ "data": [{ "id": 47, "name": "Maadi", "governorate_id": 11 }, ...] }`. Used when the patient picks a governorate, to populate the city dropdown. Failure is non-blocking — the city field falls back to free-text input per FR-014.

---

## Endpoint constants to add to `lib/utils/api_end_points.dart`

```dart
// Nurse Request (Home Nursing) — patient-facing endpoints
static const String getNurseRequests = 'nurse-requests';
static const String createNurseRequest = 'nurse-requests';
static const String getNurseRequestDetail = 'nurse-requests'; // append /{id}

// Location reference (existing, ensure present)
static const String governorates = 'governorates';
static const String cities = 'cities'; // ?governorate_id=
```

If `getNurseRequests` and friends are already present from a parent-branch commit, they MUST be reused as-is (single source of truth — Constitution IV). The plan task list will check for their presence before adding.

---

## API service method signatures (`lib/api/nurse_request_apis.dart`)

```dart
class NurseRequestApis {
  /// POST /api/nurse-requests
  /// Builds payload by allow-list — never serializes server-controlled fields.
  static Future<NurseRequestModel> create({required NurseRequestFormPayload payload});

  /// GET /api/nurse-requests?page=N&per_page=15&status=...
  static Future<NurseRequestListResponse> list({
    required int page,
    int perPage = 15,
    String? status,
  });

  /// GET /api/nurse-requests/{id}
  static Future<NurseRequestModel> detail({required int id});
}
```

Each method follows the canonical `buildHttpResponse(...) → handleResponse(...) → Model.fromJson(...)` pattern, surfacing any error by re-throwing for the controller's `catchError` chain.
