# Data Model: Labs & Radiology Centers Browse

**Feature Branch**: `009-labs-radiology-browse`
**Date**: 2026-04-02

## Entities

### Lab (NEW)

A physical laboratory facility where patients can get tests done.

| Field | Type | Description | Source |
|-------|------|-------------|--------|
| id | int | Unique identifier | API |
| name | String | Lab facility name (e.g., "Al Borg Lab") | API |
| governorate | Governorate? | Geographic region | API (nested object: `{id, name}`) |
| city | City? | City within governorate | API (nested object: `{id, name}`) |

**Response wrapper**: `LabListResponse`
| Field | Type | Description |
|-------|------|-------------|
| status | bool | API success flag |
| data | List\<Lab\> | Lab items (from `data.items`) |
| currentPage | int | Current page number |
| lastPage | int | Total pages available |
| perPage | int | Items per page (15) |
| total | int | Total item count |

**Pagination nested at**: `data.pagination`

### RadiologyCenter (EXISTING — reuse)

Located at: `lib/screens/radiology/model/radiology_center_model.dart`

A physical radiology/imaging center. Already has all needed fields:

| Field | Type | Used on Card | Description |
|-------|------|-------------|-------------|
| id | int | No | Unique identifier |
| name | String | Yes | Center name |
| scanTypes | List\<String\> | Yes | Available scan types (mri, ct, xray, etc.) |
| governorate | Governorate? | Yes | Geographic region |
| city | City? | Yes | City within governorate |
| description | String | No | (available for future detail screen) |
| address | String | No | (available for future detail screen) |
| contactNumber | String | No | (available for future detail screen) |
| rating | double | No | (available for future detail screen) |

**Response wrapper**: `RadiologyCenterListResponse` (already exists)

### Governorate (EXISTING)

Located at: `lib/models/governorate_model.dart`

| Field | Type |
|-------|------|
| id | int |
| name | String |

### City (EXISTING)

Located at: `lib/models/city_model.dart`

| Field | Type |
|-------|------|
| id | int |
| name | String |
| governorateId | int |

## Relationships

```
Governorate 1──* City
Governorate 1──* Lab
City        1──* Lab
Governorate 1──* RadiologyCenter
City        1──* RadiologyCenter
```

## State (No State Transitions)

Both Lab and RadiologyCenter are read-only entities in this feature. There are no status fields or state transitions — they are simple display models.
