# Data Model: ICU Admissions Module

**Branch**: `004-icu-admissions-module` | **Date**: 2026-03-29

## Entities

### Hospital

A healthcare facility with ICU departments.

| Field              | Type           | Required | Notes                           |
|--------------------|----------------|----------|---------------------------------|
| id                 | int            | Yes      | Unique identifier               |
| name               | String         | Yes      | Hospital name                   |
| slug               | String         | Yes      | URL-safe identifier             |
| description        | String         | No       | About the hospital              |
| hospitalType       | String         | Yes      | government/private/military/university |
| address            | String         | Yes      | Street address                  |
| city               | String         | Yes      | City                            |
| state              | String         | No       | State/province                  |
| country            | String         | No       | Country                         |
| latitude           | double         | No       | GPS latitude                    |
| longitude          | double         | No       | GPS longitude                   |
| phone              | String         | No       | Contact phone                   |
| email              | String         | No       | Contact email                   |
| website            | String         | No       | Website URL                     |
| licenseNumber      | String         | No       | License ID                      |
| acceptedInsurance  | List<String>   | No       | Insurance providers accepted    |
| rating             | double         | No       | Rating (0-5)                    |
| logo               | String         | No       | Logo image URL                  |
| status             | bool           | Yes      | Active/inactive                 |
| departments        | List<IcuDept>  | No       | Nested departments              |
| departmentsCount   | int            | No       | Total department count          |

**Source**: `GET /v1/hospitals`
**File**: `lib/screens/icu/model/hospital_model.dart`

### IcuDepartment

An ICU department within a hospital.

| Field           | Type   | Required | Notes                         |
|-----------------|--------|----------|-------------------------------|
| id              | int    | Yes      | Unique identifier             |
| name            | String | Yes      | Department name               |
| hospitalId      | int    | Yes      | Parent hospital               |
| specialtyType   | String | Yes      | cardiac/neurology/pediatric/neonatal/burns/chest/surgical/general |
| totalBeds       | int    | Yes      | Total bed capacity            |
| availableBeds   | int    | Yes      | Currently available beds      |
| hasVentilator   | bool   | Yes      | Ventilator equipped           |
| hasOxygen       | bool   | Yes      | Oxygen supply equipped        |
| equipmentLevel  | String | Yes      | basic/advanced/full           |
| dailyPrice      | String | Yes      | Price per day (string from API)|
| description     | String | No       | Department description        |
| status          | bool   | Yes      | Active/inactive               |

**Source**: `GET /v1/icu-departments`, nested in Hospital
**File**: `lib/screens/icu/model/hospital_model.dart`

### IcuAdmissionRequest

A patient's request for ICU bed admission.

| Field              | Type                  | Required | Notes                    |
|--------------------|-----------------------|----------|--------------------------|
| id                 | int                   | Yes      | Unique identifier        |
| requestNumber      | String                | Yes      | ICU-YYYY-NNNN format    |
| patient            | AdmissionPatient?     | No       | Auth user (nested)       |
| patientInfo        | PatientInfo?          | No       | Patient details (nested) |
| caseDetails        | CaseDetails?          | No       | Medical case (nested)    |
| contact            | ContactInfo?          | No       | Emergency contact (nested)|
| hospital           | Hospital?             | No       | Selected hospital        |
| icuDepartment      | IcuDepartment?        | No       | Selected department      |
| status             | String                | Yes      | See Status Flow          |
| urgency            | String                | Yes      | critical/urgent/standard |
| paymentMethod      | String                | Yes      | insurance/cash           |
| insuranceProvider   | String               | No       | If payment=insurance     |
| adminNotes         | String                | No       | Admin response notes     |
| rejectionReason    | String                | No       | If rejected              |
| responseDate       | String                | No       | Admin response date      |
| medicalReports     | List<MedicalReport>   | No       | Uploaded files           |
| createdAt          | String                | Yes      | ISO datetime             |

**Source**: `GET /v1/icu-admission-requests`
**File**: `lib/screens/icu/model/icu_admission_model.dart`

### Nested Models

**AdmissionPatient**: `{ id, name, email }`

**PatientInfo**: `{ patientName, patientAge, patientGender, nationalId, insuranceNumber }`

**CaseDetails**: `{ medicalCondition, diagnosis, caseType, needsVentilator, needsOxygen, currentLocation, needsAmbulance }`

**ContactInfo**: `{ contactName, contactPhone, relationshipToPatient }`

**MedicalReport**: `{ id, name, url, size, mimeType }`

## Status Flow

```
pending → accepted
pending → rejected
pending → info_requested
pending → cancelled (by patient)
```

- Cancel allowed only from: `pending`
- Patient can only create and view — status changes are admin-side

## Enums/Constants

**Hospital Types**: government, private, military, university
**Specialty Types**: cardiac, neurology, pediatric, neonatal, burns, chest, surgical, general
**Equipment Levels**: basic, advanced, full
**Case Types**: stroke, cardiac, post_operative, ventilator, neonatal, pediatric, burns, general
**Urgency Levels**: critical, urgent, standard
**Payment Methods**: insurance, cash
**Admission Statuses**: pending, accepted, rejected, info_requested, cancelled
**Patient Genders**: male, female

## Relationships

```
Hospital 1──* IcuDepartment
IcuAdmissionRequest *──1 Hospital
IcuAdmissionRequest *──0..1 IcuDepartment
IcuAdmissionRequest *──1 Patient (user)
IcuAdmissionRequest 1──* MedicalReport
```
