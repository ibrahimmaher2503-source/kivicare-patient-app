# Data Model: Location & Search

**Feature**: `008-location-search` | **Date**: 2026-04-02

## Entity Overview

```
Governorate (1) ──< City (many)
     │                    │
     │                    │
     ▼                    ▼
  [All search result entities reference Governorate? and City?]
     │
     ├── Doctor (search result)
     ├── Clinic (search result)
     ├── Nurse (search result)
     ├── LabTest (search result)
     ├── RadiologyCenter (search result)
     └── HomeHealthcareProvider (search result)    ← NEW MODEL

  Pagination (shared metadata for all paginated responses)
```

---

## Existing Models (no changes)

### Governorate
**File**: `lib/models/governorate_model.dart`
- `id`: int
- `name`: String (locale-aware)

### City
**File**: `lib/models/city_model.dart`
- `id`: int
- `name`: String (locale-aware)

### Doctor (search result)
**File**: `lib/screens/doctor/model/doctor_list_res.dart`
- Response class: `DoctorSearchListResponse`
- Entity fields: id, name, gender, experience, specialty (nullable), consultation_price (nullable), profile_image, governorate?, city?

### Clinic (search result)
**File**: `lib/screens/clinic/model/clinics_res_model.dart`
- Response class: `ClinicSearchListResponse`
- Entity fields: id, name, profile_image, governorate?, city?

### Nurse (search result)
**File**: `lib/screens/nurse/model/nurse_model.dart`
- Response class: `NurseListResponse`
- Entity fields: id, name, specialization, gender, availability_status, hourly_rate, profile_image, governorate?, city?

### LabTest (search result)
**File**: `lib/screens/lab_test/model/lab_test_model.dart` (via list response)
- Response class: `LabTestListResponse`
- Entity fields: id, name, governorate?, city?

### RadiologyCenter (search result)
**File**: `lib/screens/radiology/model/radiology_center_model.dart`
- Response class: `RadiologyCenterListResponse`
- Entity fields: id, name, description, address, contactNumber, email, profileImage, status, rating, scanTypes (List<String>), operatingHours, pricing, governorate?, city?

---

## New Model: HomeHealthcareProvider

**File**: `lib/models/home_healthcare_provider_model.dart`

### HomeHealthcareListResponse

| Field | Type | Source | Default |
| ----- | ---- | ------ | ------- |
| status | bool | `json['status']` | false |
| data | List\<HomeHealthcareProvider\> | `json['data']['items']` or `json['data']` | [] |
| currentPage | int | `json['data']['pagination']['current_page']` or `json['meta']['current_page']` | 1 |
| lastPage | int | `json['data']['pagination']['last_page']` or `json['meta']['last_page']` | 1 |
| perPage | int | `json['data']['pagination']['per_page']` or `json['meta']['per_page']` | 15 |
| total | int | `json['data']['pagination']['total']` or `json['meta']['total']` | 0 |

**Parsing**: Follows the flexible dual-format pattern from `RadiologyCenterListResponse` — supports both `data.items` + `data.pagination` and flat `data[]` + `meta{}` formats.

### HomeHealthcareProvider

| Field | Type | JSON Key | Default | Notes |
| ----- | ---- | -------- | ------- | ----- |
| id | int | `id` | -1 | |
| name | String | `name` | '' | |
| serviceType | String | `service_type` | '' | e.g., "physiotherapy", "elderly_care" |
| profileImage | String | `profile_image` | '' | May be null/empty — show placeholder |
| governorate | Governorate? | `governorate` | null | Nested object |
| city | City? | `city` | null | Nested object |
| createdAt | String | `created_at` | '' | |
| updatedAt | String | `updated_at` | '' | |

**Validation rules**:
- All fields use type-safe parsing: `json['field'] is Type ? json['field'] : default`
- Governorate/City use nested null-safe parsing: `json['governorate'] is Map ? Governorate.fromJson(...) : null`
- Follows exact pattern from `RadiologyCenter.fromJson()`

---

## Pagination (shared pattern)

All paginated search responses use this envelope:

```json
{
  "status": true,
  "message": "",
  "data": {
    "items": [...],
    "pagination": {
      "current_page": 1,
      "last_page": 5,
      "per_page": 15,
      "total": 72
    }
  }
}
```

**Pagination logic in controllers**:
- `isLastPage` = `currentPage >= lastPage`
- `page == 1` clears the accumulator list before adding new items
- `lastPageCallBack?.call(isLastPage)` reports to controller
