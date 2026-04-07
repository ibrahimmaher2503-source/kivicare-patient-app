# API Contract: Lab Tests

**Feature**: Labs & Radiology Booking System
**Version**: 1.0
**Date**: 2026-04-05

---

## Endpoints

### GET /v1/lab-test-categories

**Authentication**: None (public)

**Purpose**: Get all available lab test categories

**Request**:
```
GET /v1/lab-test-categories
```

**Response** (200):
```json
{
  "status": true,
  "data": [
    {
      "id": 1,
      "name": "Hematology",
      "slug": "hematology",
      "description": "Blood-related tests",
      "icon": "ph-blood",
      "display_order": 1,
      "test_count": 5,
      "status": 1
    }
  ]
}
```

**Error Responses**:
- 500: Server error

---

### GET /v1/lab-tests

**Authentication**: None (public)

**Purpose**: Get available lab tests with filtering and pagination

**Query Parameters**:

| Param | Type | Required | Description |
|-------|------|----------|-------------|
| `category_id` | int | No | Filter by category ID |
| `department` | string | No | Filter by "laboratory" or "radiology" |
| `search` | string | No | Search by name/code/description |
| `page` | int | No | Page number (default: 1) |
| `per_page` | int | No | Items per page (default: 15, max: 100) |

**Request**:
```
GET /v1/lab-tests?category_id=1&department=laboratory&search=blood&page=1&per_page=15
```

**Response** (200):
```json
{
  "status": true,
  "data": [
    {
      "id": 1,
      "name": "Complete Blood Count (CBC)",
      "code": "CBC001",
      "slug": "complete-blood-count",
      "category": {
        "id": 1,
        "name": "Hematology",
        "slug": "hematology",
        "description": "Blood-related tests",
        "icon": "ph-blood",
        "display_order": 1,
        "test_count": 5,
        "status": 1
      },
      "department": "laboratory",
      "sample_type": "blood",
      "description": "...",
      "preparation_instructions": "Fasting required",
      "default_price": 150.00,
      "turnaround_time": "24 hours",
      "status": 1
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

**Notes**:
- Only active tests (status=1) returned
- sample_type: blood | urine | stool | tissue | imaging | swab | other

---

### GET /v1/lab-tests/{id}

**Authentication**: None (public)

**Purpose**: Get single test details

**Request**:
```
GET /v1/lab-tests/1
```

**Response** (200):
```json
{
  "status": true,
  "data": {
    "id": 1,
    "name": "Complete Blood Count (CBC)",
    "code": "CBC001",
    "slug": "complete-blood-count",
    "category": { /* category object */ },
    "department": "laboratory",
    "sample_type": "blood",
    "description": "...",
    "preparation_instructions": "Fasting required",
    "default_price": 150.00,
    "turnaround_time": "24 hours",
    "reference_range": "...",
    "status": 1
  }
}
```

**Error Responses**:
- 404: Test not found

---

## Response Format

### Success Response

```json
{
  "status": true,
  "data": { /* or array */ },
  "message": "Success"
}
```

### Error Response

```json
{
  "status": false,
  "message": "Error description",
  "errors": {
    "field_name": ["Validation error"]
  }
}
```

**HTTP Status Codes**:
- 200: OK
- 400: Bad request (invalid parameters)
- 422: Unprocessable entity (validation failure)
- 404: Not found
- 500: Server error

---

## Sample Types

Valid values for `sample_type` field:
- `blood` - Blood sample
- `urine` - Urine sample
- `stool` - Stool sample
- `tissue` - Tissue sample
- `imaging` - Imaging (for radiology)
- `swab` - Swab sample
- `other` - Other type

---

## Departments

Valid values for `department` filter:
- `laboratory` - Lab test
- `radiology` - Radiology/imaging test

---

## Caching Strategy

- Categories: Cache for 24 hours (change infrequently)
- Tests: Cache for 12 hours (prices/availability may change)
- Single test: Cache for 6 hours

---

## Test Workflow

## Integration Tests

```gherkin
Scenario: Browse lab test categories
  Given I am on the lab test screen
  When I request categories
  Then I should see at least 5 categories
  And each category should have name, slug, icon
```

```gherkin
Scenario: Search for specific test
  Given I am on the test search screen
  When I search for "blood"
  Then I should see tests with "blood" in name or description
  And results should include CBC test
```

```gherkin
Scenario: Filter tests by department
  Given I am viewing lab tests
  When I filter by department "radiology"
  Then I should see only radiology-type tests
  And sample_type should include "imaging"
```
