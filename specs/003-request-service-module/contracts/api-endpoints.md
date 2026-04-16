# API Contracts: Request Service Module

**Base URL**: `https://espitalia.net/api/v1`
**Auth**: All endpoints require Bearer token (auth:sanctum)

### GET /get-request-service

Returns paginated list of patient's service requests.

**Query Parameters**:

| Param     | Type   | Required | Default | Notes                    |
|-----------|--------|----------|---------|--------------------------|
| per_page  | int    | No       | 15      | Page size                |
| page      | int    | No       | 1       | Page number              |
| is_status | string | No       | —       | pending, accept, reject  |
| search    | string | No       | —       | Search name/description  |

**Response** `200`:
```json
{
  "status": true,
  "data": [
    {
      "id": 1,
      "name": "Custom Blood Panel",
      "description": "Request for specialized blood panel test",
      "type": "laboratory",
      "status": 1,
      "is_status": "pending",
      "created_by": 5,
      "updated_by": null,
      "deleted_by": null,
      "created_at": "2026-03-25T10:30:00Z",
      "updated_at": "2026-03-25T10:30:00Z",
      "deleted_at": null
    }
  ],
  "meta": {
    "current_page": 1,
    "per_page": 15,
    "total": 50,
    "last_page": 4
  }
}
```

### POST /save-request-service

Creates a new service request.

**Request**:
```json
{
  "name": "Custom Blood Panel",
  "description": "Need specialized blood panel test",
  "type": "laboratory"
}
```

**Validation**:

| Field       | Type   | Required | Rules    |
|-------------|--------|----------|----------|
| name        | string | Yes      | Required |
| description | string | No       | max: 500 |
| type        | string | No       | Optional |

**Response** `201`:
```json
{
  "status": true,
  "message": "Service request submitted successfully",
  "data": { "...": "RequestServiceResource" }
}
```
