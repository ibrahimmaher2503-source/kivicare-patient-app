# API Contracts: ICU Admissions Module

**Base URL**: `https://espitalia.net/api/v1`
**Auth**: All endpoints require Bearer token (auth:sanctum)

## Hospital Endpoints

### GET /hospitals

Returns paginated list of hospitals with ICU departments.

**Query Parameters**:

| Param      | Type    | Required | Default | Notes                              |
|------------|---------|----------|---------|------------------------------------|
| per_page   | int     | No       | 15      | Page size                          |
| page       | int     | No       | 1       | Page number                        |
| city       | string  | No       | —       | Filter by city                     |
| specialty  | string  | No       | —       | cardiac/neurology/pediatric/etc.   |
| ventilator | boolean | No       | —       | Departments with ventilators       |
| insurance  | string  | No       | —       | Accepted insurance provider        |
| search     | string  | No       | —       | Search name/city/address/desc      |

**Response** `200`: Array of HospitalResource with nested departments, pagination meta.

### GET /hospitals/{id}

Returns single hospital with full departments array.

## Department Endpoints

### GET /icu-departments

Returns paginated list of ICU departments.

**Query Parameters**:

| Param       | Type    | Required | Default | Notes                    |
|-------------|---------|----------|---------|--------------------------|
| per_page    | int     | No       | 15      | Page size                |
| page        | int     | No       | 1       | Page number              |
| hospital_id | int     | No       | —       | Filter by hospital       |
| specialty   | string  | No       | —       | Filter by specialty      |
| available   | boolean | No       | —       | Only with available beds |
| ventilator  | boolean | No       | —       | Only with ventilators    |

## Admission Request Endpoints

### GET /icu-admission-requests

Returns paginated admission requests for authenticated patient.

**Query Parameters**:

| Param    | Type   | Required | Default | Notes                                                    |
|----------|--------|----------|---------|----------------------------------------------------------|
| per_page | int    | No       | 15      | Page size                                                |
| page     | int    | No       | 1       | Page number                                              |
| status   | string | No       | —       | pending/accepted/rejected/info_requested/cancelled       |

### POST /icu-admission-requests

Creates admission request. **Content-Type: multipart/form-data**.

**Fields**: hospital_id (required), icu_department_id, patient_name (required max:255), patient_age (required 0-150), patient_gender (required male/female), national_id (max:50), insurance_number (conditional max:100), medical_condition (required max:5000), diagnosis (max:500), case_type (required), urgency (required critical/urgent/standard), needs_ventilator, needs_oxygen, current_location (max:500), needs_ambulance, contact_name (required max:255), contact_phone (required max:50), relationship_to_patient (max:100), payment_method (required insurance/cash), insurance_provider (conditional max:255), medical_reports[] (files, pdf/jpg/png/doc/docx, max 10MB each)

**Response** `201`: `{ status: true, message: "...", data: IcuAdmissionRequestResource }`

### GET /icu-admission-requests/{id}

Returns single admission request detail.

### POST /icu-admission-requests/{id}/cancel

Cancels a pending admission request.

**Request**: `{ "cancellation_reason": "..." }` (required, max: 500)

**Response** `200`: `{ status: true, message: "..." }`
