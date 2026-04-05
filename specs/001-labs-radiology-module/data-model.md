# Data Model: Labs & Radiology Module

**Branch**: `001-labs-radiology-module` | **Date**: 2026-03-29

## Entities

### LabTestCategory

Represents a grouping of lab tests (e.g., Hematology, Radiology).

| Field         | Type   | Required | Notes                        |
|---------------|--------|----------|------------------------------|
| id            | int    | Yes      | Unique identifier            |
| name          | String | Yes      | Display name                 |
| slug          | String | Yes      | URL-safe identifier          |
| description   | String | Yes      | Category description         |
| icon          | String | Yes      | Icon identifier (e.g. ph-blood) |
| displayOrder  | int    | Yes      | Sort order                   |
| testCount     | int    | Yes      | Number of tests in category  |
| status        | bool   | Yes      | Active/inactive              |

**Source**: `GET /v1/lab-test-categories`
**File**: `lib/screens/lab_test/model/lab_test_category_model.dart`

### LabTest

Represents a specific laboratory or radiology test/service.

| Field                    | Type             | Required | Notes                                    |
|--------------------------|------------------|----------|------------------------------------------|
| id                       | int              | Yes      | Unique identifier                        |
| name                     | String           | Yes      | Test name                                |
| code                     | String           | Yes      | Test code (e.g. BT001)                   |
| slug                     | String           | Yes      | URL-safe identifier                      |
| category                 | LabTestCategory? | No       | Parent category (nested object)          |
| department               | String           | Yes      | "laboratory" or "radiology"              |
| sampleType               | String           | Yes      | blood, urine, stool, tissue, imaging, swab, other |
| description              | String           | Yes      | Full description                         |
| preparationInstructions  | String           | Yes      | Patient prep instructions                |
| defaultPrice             | double           | Yes      | Price in default currency                |
| turnaroundTime           | String           | Yes      | Expected time (e.g. "24 hours")          |
| status                   | bool             | Yes      | Active/inactive                          |

**Source**: `GET /v1/lab-tests`, `GET /v1/lab-tests/{id}`
**File**: `lib/screens/lab_test/model/lab_test_model.dart`

### TestOrder

Represents a patient's order for one or more lab/radiology tests.

| Field            | Type               | Required | Notes                                    |
|------------------|--------------------|----------|------------------------------------------|
| id               | int                | Yes      | Unique identifier                        |
| orderNumber      | String             | Yes      | Format: LAB-YYYY-NNNN                    |
| patient          | TestOrderPatient?  | No       | Patient info (nested)                    |
| doctor           | TestOrderDoctor?   | No       | Referring doctor (nested)                |
| labTechnician    | TestOrderTech?     | No       | Assigned technician (nested)             |
| items            | List<TestOrderItem>| Yes      | Ordered tests                            |
| clinicalNotes    | String             | No       | Max 2000 chars                           |
| priority         | String             | Yes      | routine, urgent, stat                    |
| orderDate        | String             | Yes      | ISO date (YYYY-MM-DD)                    |
| status           | String             | Yes      | See Status Flow below                    |
| paymentStatus    | String             | Yes      | unpaid, paid, cancelled                  |
| totalAmount      | double             | Yes      | Sum of item prices                       |
| discountAmount   | double             | Yes      | Applied discount                         |
| finalAmount      | double             | Yes      | totalAmount - discountAmount             |
| reports          | List<dynamic>      | No       | Report file references                   |
| createdAt        | String             | Yes      | ISO datetime                             |

**Source**: `GET /v1/test-orders`, `POST /v1/test-orders`
**File**: `lib/screens/lab_test/model/test_order_model.dart`

### TestOrderItem

Represents a single test within an order, including results.

| Field          | Type               | Required | Notes                          |
|----------------|--------------------|----------|--------------------------------|
| id             | int                | Yes      | Unique identifier              |
| labTest        | TestOrderItemLabTest? | No    | Test reference (nested)        |
| price          | double             | Yes      | Price at time of order         |
| status         | String             | Yes      | Individual item status         |
| resultValue    | String?            | No       | Test result value              |
| resultUnit     | String?            | No       | Unit (e.g. mg/dL)             |
| referenceRange | String?            | No       | Normal range (e.g. 70-100)     |
| resultStatus   | String?            | No       | normal, abnormal, critical     |
| resultNotes    | String?            | No       | Additional notes               |
| resultDate     | String?            | No       | When result was recorded       |

### Supporting Nested Objects

**TestOrderPatient**: `{ id, name, email }`
**TestOrderDoctor**: `{ id, name }`
**TestOrderTech**: `{ id, name }`
**TestOrderItemLabTest**: Subset of LabTest fields for display

## Status Flow

```
pending → confirmed → sample_collected → processing → completed → delivered
   ↓          ↓
cancelled  cancelled
```

- Cancel allowed only from: `pending`, `confirmed`
- Report download allowed from: `completed`, `delivered`

## Relationships

```
LabTestCategory 1──* LabTest
TestOrder 1──* TestOrderItem
TestOrderItem *──1 LabTest
TestOrder *──1 Patient (user)
TestOrder *──0..1 Doctor
TestOrder *──0..1 LabTechnician
```
