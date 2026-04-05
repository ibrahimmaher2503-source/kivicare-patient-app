# API Contracts: Labs & Radiology Centers Browse

**Feature Branch**: `009-labs-radiology-browse`
**Date**: 2026-04-02

## 1. Search Labs

**Endpoint**: `GET /api/labs/search`
**Authentication**: None (public)
**Existing constant**: `APIEndPoints.labsSearch = 'labs/search'`

### Query Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| page | int | No | Page number (default: 1) |
| per_page | int | No | Items per page (default: 15) |
| test_name | string | No | Partial match on lab name (URL-encoded) |
| governorate_id | int | No | Filter by governorate |
| city_id | int | No | Filter by city |

### Response (200 OK)

```json
{
  "status": true,
  "data": {
    "items": [
      {
        "id": 1,
        "name": "Al Borg Lab",
        "governorate": {
          "id": 1,
          "name": "Cairo"
        },
        "city": {
          "id": 1,
          "name": "Nasr City"
        }
      }
    ],
    "pagination": {
      "current_page": 1,
      "last_page": 2,
      "per_page": 15,
      "total": 18
    }
  }
}
```

### Error Response (500)

```json
{
  "status": false,
  "message": "Something went wrong"
}
```

---

## 2. Search Radiology Centers

**Endpoint**: `GET /api/radiology/search`
**Authentication**: None (public)
**Existing constant**: `APIEndPoints.radiologySearch = 'radiology/search'`

### Query Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| page | int | No | Page number (default: 1) |
| per_page | int | No | Items per page (default: 15) |
| scan_type | string | No | Exact match: `mri`, `ct`, `xray`, `ultrasound` |
| governorate_id | int | No | Filter by governorate |
| city_id | int | No | Filter by city |

### Response (200 OK)

```json
{
  "status": true,
  "data": {
    "items": [
      {
        "id": 1,
        "name": "Diagnostic Radiology Center",
        "scan_type": "MRI",
        "governorate": {
          "id": 2,
          "name": "Alexandria"
        },
        "city": {
          "id": 8,
          "name": "Smouha"
        }
      }
    ],
    "pagination": {
      "current_page": 1,
      "last_page": 1,
      "per_page": 15,
      "total": 5
    }
  }
}
```

### Error Response (500)

```json
{
  "status": false,
  "message": "Something went wrong"
}
```

---

## Notes

- Both endpoints return data nested under `data.items` with pagination at `data.pagination`
- The existing `searchLabs()` API method in `core_apis.dart` uses a similar pattern but for `LabTest` items — the new Labs endpoint returns simpler `Lab` objects
- The `scan_type` parameter in the radiology endpoint uses exact match (case-insensitive on backend)
- Empty results return `data.items: []` with `pagination.total: 0`
