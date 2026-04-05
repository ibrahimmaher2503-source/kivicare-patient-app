# API Contracts: Location & Search

**Feature**: `008-location-search` | **Date**: 2026-04-02
**Base URL**: `https://espitalia.net/api/`
**Auth**: None (public endpoints)
**Localization**: `Accept-Language` header (sent as `global-localization` by `buildHeaderTokens()`)

---

## Endpoint Map

| # | Method | Endpoint | Paginated | Existing API Method |
| - | ------ | -------- | --------- | ------------------- |
| 1 | GET | `governorates` | No | `getGovernorates()` — exists |
| 2 | GET | `cities?governorate_id={id}` | No | `getCities()` — exists |
| 3 | GET | `doctors/search?{filters}` | Yes (15/page) | `searchDoctors()` — extend |
| 4 | GET | `clinics/search?{filters}` | Yes (15/page) | `searchClinics()` — extend |
| 5 | GET | `nurses/search?{filters}` | Yes (15/page) | `searchNurses()` — exists |
| 6 | GET | `labs/search?{filters}` | Yes (15/page) | `searchLabs()` — exists |
| 7 | GET | `radiology/search?{filters}` | Yes (15/page) | NEW: `searchRadiology()` |
| 8 | GET | `home-healthcare/search?{filters}` | Yes (15/page) | NEW: `searchHomeHealthcare()` |

---

## 1. List Governorates

```
GET /api/governorates
```

**Response** (non-paginated):
```json
{
  "status": true,
  "message": "Governorates list",
  "data": [{ "id": 1, "name": "Cairo" }]
}
```

**Dart mapping**: `GovernorateListResponse.fromJson()` → `List<Governorate>`

---

## 2. List Cities

```
GET /api/cities?governorate_id={id}
```

**Required**: `governorate_id` (int) — returns 422 if omitted.

**Response** (non-paginated):
```json
{
  "status": true,
  "message": "Cities list",
  "data": [{ "id": 1, "name": "Nasr City" }]
}
```

**Dart mapping**: `CityListResponse.fromJson()` → `List<City>`

---

## 3. Search Doctors

```
GET /api/doctors/search?page={p}&per_page={n}&name={s}&governorate_id={g}&city_id={c}&specialty_id={sp}&gender={gen}&min_price={min}&max_price={max}
```

**Query params** (all optional):

| Param | Type | Validation | Match Type |
| ----- | ---- | ---------- | ---------- |
| `governorate_id` | int | exists:governorates,id | exact |
| `city_id` | int | exists:governorate_cities,id | exact |
| `specialty_id` | int | integer | exact |
| `name` | string | max:100 | partial (LIKE) |
| `gender` | string | in:male,female | exact |
| `min_price` | numeric | min:0 | range |
| `max_price` | numeric | min:0 | range |
| `page` | int | default: 1 | — |

**Response**: Paginated search envelope with `DoctorSearchListResponse`

**Dart method changes**: Add `specialtyId`, `gender`, `minPrice`, `maxPrice` params to `CoreServiceApis.searchDoctors()`

---

## 4. Search Clinics

```
GET /api/clinics/search?page={p}&per_page={n}&name={s}&governorate_id={g}&city_id={c}&specialty_id={sp}
```

**Query params** (all optional):

| Param | Type | Match Type |
| ----- | ---- | ---------- |
| `governorate_id` | int | exact |
| `city_id` | int | exact |
| `specialty_id` | int | exact |
| `name` | string | partial (LIKE) |
| `page` | int | — |

**Dart method changes**: Add `specialtyId` param to `CoreServiceApis.searchClinics()`

---

## 5. Search Nurses (no changes needed)

```
GET /api/nurses/search?page={p}&per_page={n}&search={s}&governorate_id={g}&city_id={c}&specialty={sp}&gender={gen}&availability={avail}
```

Already fully implemented in `CoreServiceApis.searchNurses()`.

---

## 6. Search Labs (no changes needed)

```
GET /api/labs/search?page={p}&per_page={n}&test_name={s}&governorate_id={g}&city_id={c}
```

Already fully implemented in `CoreServiceApis.searchLabs()`.

---

## 7. Search Radiology Centers (NEW)

```
GET /api/radiology/search?page={p}&per_page={n}&governorate_id={g}&city_id={c}&scan_type={type}
```

**Query params** (all optional):

| Param | Type | Match Type |
| ----- | ---- | ---------- |
| `governorate_id` | int | exact |
| `city_id` | int | exact |
| `scan_type` | string | **exact** (not LIKE) |
| `page` | int | — |

**Response**: Paginated search envelope → `RadiologyCenterListResponse`

**New Dart method**: `CoreServiceApis.searchRadiology()`

---

## 8. Search Home Healthcare (NEW)

```
GET /api/home-healthcare/search?page={p}&per_page={n}&governorate_id={g}&city_id={c}&service_type={type}
```

**Query params** (all optional):

| Param | Type | Match Type |
| ----- | ---- | ---------- |
| `governorate_id` | int | exact |
| `city_id` | int | exact |
| `service_type` | string | **exact** (not LIKE) |
| `page` | int | — |

**Response**: Paginated search envelope → `HomeHealthcareListResponse`

**New Dart method**: `CoreServiceApis.searchHomeHealthcare()`

---

## Shared Response Envelope

**Paginated (search endpoints 3-8)**:
```json
{
  "status": true,
  "message": "",
  "data": {
    "items": [],
    "pagination": {
      "current_page": 1,
      "last_page": 1,
      "per_page": 15,
      "total": 0
    }
  }
}
```

**Non-paginated (endpoints 1-2)**:
```json
{
  "status": true,
  "message": "...",
  "data": []
}
```

**422 Validation Error**:
```json
{
  "message": "The given data was invalid.",
  "errors": { "field_name": ["Error message"] }
}
```
