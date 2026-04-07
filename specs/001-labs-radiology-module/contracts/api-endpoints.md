# API Contracts: Labs & Radiology Module

**Base URL**: `https://espitalia.net/api/v1`

## Public Endpoints (No Auth)

### GET /lab-test-categories

Returns all active test categories.

**Response** `200`:
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

### GET /lab-tests

Returns paginated lab test catalog with optional filters.

**Query Parameters**:

| Param         | Type   | Required | Default | Notes                      |
|---------------|--------|----------|---------|----------------------------|
| category_id   | int    | No       | —       | Filter by category         |
| department    | string | No       | —       | "laboratory" or "radiology"|
| search        | string | No       | —       | Search name/code/desc      |
| per_page      | int    | No       | 15      | Page size                  |
| page          | int    | No       | 1       | Page number                |

**Response** `200`:
```json
{
  "status": true,
  "data": [
    {
      "id": 1,
      "name": "Blood Test",
      "code": "BT001",
      "slug": "blood-test",
      "category": { "...": "LabTestCategoryResource" },
      "department": "laboratory",
      "sample_type": "blood",
      "description": "...",
      "preparation_instructions": "...",
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

**Sample types**: blood, urine, stool, tissue, imaging, swab, other

### GET /lab-tests/{id}

Returns single lab test detail. Same shape as individual item in list.

## Authenticated Endpoints (Bearer Token)

### GET /test-orders

Returns paginated orders for the authenticated patient.

**Query Parameters**:

| Param    | Type   | Required | Default | Notes                                           |
|----------|--------|----------|---------|-------------------------------------------------|
| status   | string | No       | —       | pending, confirmed, sample_collected, processing, completed, delivered, cancelled |
| per_page | int    | No       | 15      | Page size                                       |
| page     | int    | No       | 1       | Page number                                     |

**Response** `200`:
```json
{
  "status": true,
  "data": [
    {
      "id": 1,
      "order_number": "LAB-2026-0001",
      "patient": { "id": 5, "name": "John Doe", "email": "john@example.com" },
      "doctor": { "id": 2, "name": "Dr. Jane Smith" },
      "lab_technician": { "id": 3, "name": "Tech John" },
      "items": [
        {
          "id": 1,
          "lab_test": { "...": "LabTestResource" },
          "price": 150.00,
          "status": "pending",
          "result_value": null,
          "result_unit": null,
          "reference_range": null,
          "result_status": null,
          "result_notes": null,
          "result_date": null
        }
      ],
      "clinical_notes": "Fasting required",
      "priority": "routine",
      "order_date": "2026-03-25",
      "status": "pending",
      "payment_status": "unpaid",
      "total_amount": 150.00,
      "discount_amount": 0.00,
      "final_amount": 150.00,
      "reports": [],
      "created_at": "2026-03-25T10:30:00Z"
    }
  ],
  "meta": { "current_page": 1, "per_page": 15, "total": 50, "last_page": 4 }
}
```

### POST /test-orders

Creates a new test order.

**Request**:
```json
{
  "items": [
    { "lab_test_id": 1 },
    { "lab_test_id": 3 }
  ],
  "clinical_notes": "Fasting required",
  "priority": "routine",
  "doctor_id": 2,
  "patient_id": 5
}
```

**Validation**:

| Field                 | Type   | Required | Rules                         |
|-----------------------|--------|----------|-------------------------------|
| items                 | array  | Yes      | min: 1                        |
| items.*.lab_test_id   | int    | Yes      | Must exist in lab_tests table |
| clinical_notes        | string | No       | max: 2000                     |
| priority              | string | No       | routine, urgent, stat (default: routine) |
| doctor_id             | int    | No       | Must exist as doctor user     |
| patient_id            | int    | No       | Auto-set to self for user role|

**Response** `201`:
```json
{
  "status": true,
  "message": "radiology_lab.order_save_success",
  "data": { "...": "TestOrderResource" }
}
```

### GET /test-orders/{id}

Returns single order detail. Same role-based access as list.

### POST /test-orders/{id}/cancel

Cancels an order (only pending or confirmed).

**Request**:
```json
{
  "cancellation_reason": "Patient requested cancellation"
}
```

**Validation**: `cancellation_reason` required, max: 500

**Response** `200`:
```json
{
  "status": true,
  "message": "radiology_lab.order_cancel_success"
}
```

### GET /test-orders/{id}/report/download

Downloads PDF report for a completed order.

**Response**: `200` — Binary PDF (`application/pdf`)
**Headers**: `Content-Disposition: attachment; filename="report.pdf"`
