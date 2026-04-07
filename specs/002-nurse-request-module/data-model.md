# Data Model: Nurse Request Module

**Branch**: `002-nurse-request-module` | **Date**: 2026-03-29

## Entities

### Nurse

Represents a healthcare professional available for home care.

| Field              | Type   | Required | Notes                           |
|--------------------|--------|----------|---------------------------------|
| id                 | int    | Yes      | Nurse model ID                  |
| nurseId            | int    | Yes      | User ID of the nurse            |
| name               | String | Yes      | Full display name               |
| firstName          | String | Yes      | First name                      |
| lastName           | String | Yes      | Last name                       |
| email              | String | Yes      | Email address                   |
| mobile             | String | Yes      | Phone number                    |
| specialization     | String | Yes      | Area of expertise               |
| experience         | String | Yes      | Experience description          |
| about              | String | Yes      | Bio/about text                  |
| hourlyRate         | double | Yes      | Rate per hour                   |
| availabilityStatus | String | Yes      | available, busy, off_duty       |
| serviceArea        | String | Yes      | Geographic service area         |
| profileImage       | String | No       | Profile photo URL               |
| status             | int    | Yes      | Active/inactive                 |
| createdAt          | String | Yes      | ISO datetime                    |
| updatedAt          | String | Yes      | ISO datetime                    |

**Source**: `GET /v1/nurses`
**File**: `lib/screens/nurse/model/nurse_model.dart`

### NurseRequest

Represents a patient's request for nurse home care.

| Field               | Type                | Required | Notes                          |
|---------------------|---------------------|----------|--------------------------------|
| id                  | int                 | Yes      | Unique identifier              |
| patient             | NurseRequestPatient?| No       | Patient info (nested)          |
| nurse               | NurseRequestNurse?  | No       | Assigned nurse (nested)        |
| serviceDescription  | String              | Yes      | Service needed (max 1000)      |
| requestDate         | String              | Yes      | When request was made          |
| preferredDate       | String              | Yes      | Desired service date           |
| preferredTime       | String              | No       | Desired time (H:i format)      |
| durationHours       | double              | Yes      | Duration 1-24 hours            |
| address             | NurseRequestAddress?| No       | Service location (nested)      |
| contactNumber       | String              | Yes      | Contact phone (max 20)         |
| status              | String              | Yes      | See Status Flow                |
| paymentStatus       | bool                | Yes      | Paid or not                    |
| totalAmount         | double              | Yes      | Calculated total               |
| patientNotes        | String              | No       | Notes from patient             |
| adminNotes          | String              | No       | Notes from admin               |
| cancelledBy         | String              | No       | Who cancelled                  |
| cancellationReason  | String              | No       | Why cancelled (max 500)        |
| createdAt           | String              | Yes      | ISO datetime                   |
| updatedAt           | String              | Yes      | ISO datetime                   |

**Source**: `GET /v1/nurse-requests`
**File**: `lib/screens/nurse/model/nurse_request_model.dart`

### Supporting Nested Objects

**NurseRequestPatient**: `{ id, name, email, mobile }`
**NurseRequestNurse**: `{ id, name, specialization }`
**NurseRequestAddress**: `{ addressLine1, addressLine2, city, state, country, postalCode, latitude, longitude, fullAddress }`

## Status Flow

```
pending → confirmed → in_progress → completed
   ↓          ↓
cancelled  cancelled
```

- Edit allowed only from: `pending`
- Cancel allowed from: `pending`, `confirmed`

## Relationships

```
Nurse 1──* NurseRequest (via nurse_id)
Patient 1──* NurseRequest (via patient_id)
NurseRequest 1──1 NurseRequestAddress
```
