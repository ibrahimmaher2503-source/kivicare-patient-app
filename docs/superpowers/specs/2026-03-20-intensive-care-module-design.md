# Intensive Care Module — Design Specification

**Date:** 2026-03-20
**Status:** Approved
**App:** Espitalia Patient App (v1.8.1+20)
**Scope:** Full-stack (Flutter frontend + Laravel backend)

## Overview

A new "Intensive Care" module that transforms the app from a simple doctor booking platform into a critical care access and coordination platform. The module enables patients (or their companions) to search for available ICU beds, submit emergency admission requests, and track request outcomes.

### Three Subsystems

1. **ICU Bed Search** — Filter/search ICU units by specialty, ventilator, insurance, distance, price, availability, equipment level
2. **Emergency Admission Request** — Multi-step form with patient info, vitals, diagnosis, severity, file attachments, companion info, arrival method
3. **Live Bed Availability (Level 1)** — Hospital admin manually updates status per ICU unit (Available / Last Bed / Unavailable)

### Out of Scope (v1)

- Family condition tracking / timeline
- In-app coordination workflow (ambulance tracking, staff assignment)
- Insurance verification / pre-approval
- Payment processing (pricing is display-only)
- Level 2 automated bed counts (internal hospital dashboard)

### Key Decisions

- Case types and insurance providers are **dynamic** (fetched from backend, admin-editable)
- Coordination is **notification-only** — relevant parties notified, but coordination happens outside the app
- "Redirected" status is a **label with free-text note** (e.g., "We recommend Hospital X"), not an automated workflow
- Pricing is **display-only** — no payment flow in the ICU module
- Availability is **Level 1** — manual status update by hospital admin

---

## 1. Data Models & Database Schema

### 1.1 Laravel Database Tables

#### `icu_case_types` — Dynamic case type catalog

| Column | Type | Notes |
|--------|------|-------|
| id | bigint PK | Auto-increment |
| name | string | e.g., "Stroke", "Cardiac Emergency" |
| name_ar | string (nullable) | Arabic translation |
| description | text (nullable) | Optional description |
| icon | string (nullable) | Icon identifier for the app |
| is_active | boolean | Default true |
| sort_order | int | Display ordering |
| created_at | timestamp | |
| updated_at | timestamp | |

#### `insurance_providers` — Insurance provider catalog

| Column | Type | Notes |
|--------|------|-------|
| id | bigint PK | Auto-increment |
| name | string | Provider name |
| name_ar | string (nullable) | Arabic translation |
| logo | string (nullable) | Logo image path |
| is_active | boolean | Default true |
| created_at | timestamp | |
| updated_at | timestamp | |

#### `icu_units` — Individual ICU units within hospitals

| Column | Type | Notes |
|--------|------|-------|
| id | bigint PK | Auto-increment |
| hospital_id | bigint FK → clinics | Links to existing clinic/hospital |
| name | string | e.g., "Cardiac ICU", "Neonatal ICU" |
| specialty | string | Cardiac, Neurology, Pediatrics, Burns, Chest, General |
| total_beds | int | Total bed count |
| has_ventilator | boolean | Whether ventilators are available |
| has_isolation | boolean | Whether isolation rooms are available |
| daily_price_min | decimal(10,2) | Price range low |
| daily_price_max | decimal(10,2) | Price range high |
| availability_status | enum | `available`, `last_bed`, `unavailable` |
| availability_updated_at | timestamp | When admin last updated status |
| equipment_level | enum | `basic`, `advanced`, `comprehensive` |
| accepted_insurance_ids | json | Array of insurance provider IDs |
| case_type_ids | json | Array of supported case type IDs |
| is_active | boolean | Default true |
| created_at | timestamp | |
| updated_at | timestamp | |

#### `icu_admission_requests` — Core admission request

| Column | Type | Notes |
|--------|------|-------|
| id | bigint PK | Auto-increment |
| user_id | bigint FK → users | Requesting user |
| icu_unit_id | bigint FK → icu_units | Target ICU unit |
| case_type_id | bigint FK → icu_case_types | Selected case type |
| patient_name | string | |
| patient_age | int | |
| patient_gender | enum | `male`, `female`, `other` |
| initial_diagnosis | text | Free-text diagnosis |
| severity_level | enum | `critical`, `serious`, `moderate` |
| vital_signs | json (nullable) | `{heart_rate, bp, o2_sat, temperature}` |
| requires_oxygen | boolean | Default false |
| requires_ventilator | boolean | Default false |
| requires_isolation | boolean | Default false |
| companion_name | string (nullable) | |
| companion_phone | string (nullable) | |
| companion_relation | string (nullable) | |
| arrival_method | enum | `ambulance`, `private_car` |
| insurance_provider_id | bigint FK (nullable) | Null = cash payment |
| insurance_number | string (nullable) | |
| notes | text (nullable) | Additional notes |
| status | enum | `pending`, `accepted`, `rejected`, `info_requested`, `redirected`, `cancelled` |
| admin_response_note | text (nullable) | Hospital's response / redirect recommendation |
| responded_at | timestamp (nullable) | When hospital responded |
| created_at | timestamp | |
| updated_at | timestamp | |

#### `icu_admission_files` — Attached files for admission requests

| Column | Type | Notes |
|--------|------|-------|
| id | bigint PK | Auto-increment |
| admission_request_id | bigint FK → icu_admission_requests | Parent request |
| file_path | string | Storage path |
| file_type | enum | `imaging`, `lab_result`, `medical_report`, `prescription`, `other` |
| original_name | string | Original uploaded filename |
| created_at | timestamp | |
| updated_at | timestamp | |

### 1.2 Flutter Models

All models follow existing codebase patterns: safe `is Type` checks before casting, default values in constructors, `fromJson()` and `toJson()` methods.

- **`IcuCaseType`** — id, name, description, icon
- **`IcuUnit`** — id, hospitalId, name, specialty, totalBeds, hasVentilator, hasIsolation, dailyPriceMin, dailyPriceMax, availabilityStatus, availabilityUpdatedAt, equipmentLevel, acceptedInsurances (List\<InsuranceProvider\>), caseTypes (List\<IcuCaseType\>), hospital (nested clinic model with distance)
- **`InsuranceProvider`** — id, name, logo
- **`AdmissionRequest`** — all admission fields + nested icuUnit, caseType, insuranceProvider, files list
- **`AdmissionFile`** — id, filePath, fileType, originalName

List response wrappers (`IcuUnitListResponse`, `AdmissionRequestListResponse`) handle Laravel pagination with `meta` object (`current_page`, `last_page`, `per_page`, `total`).

---

## 2. API Endpoints & Contracts

### 2.1 Route Summary

All routes under `api/v1/icu/`, authenticated via Sanctum.

**Catalog / Lookup:**

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `icu/case-types` | List active case types |
| GET | `icu/insurance-providers` | List active insurance providers |

**ICU Bed Search:**

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `icu/units` | Search/filter ICU units |
| GET | `icu/units/{id}` | ICU unit detail with hospital info |

**Admission Requests (Patient):**

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `icu/admission-requests` | Submit new admission request (multipart) |
| GET | `icu/admission-requests` | List user's admission requests (paginated) |
| GET | `icu/admission-requests/{id}` | Admission request detail |
| POST | `icu/admission-requests/{id}/cancel` | Cancel a pending request |

**Hospital Admin:**

| Method | Endpoint | Description |
|--------|----------|-------------|
| PUT | `icu/units/{id}/availability` | Update bed availability status |
| GET | `icu/admin/admission-requests` | List requests for admin's hospital |
| PUT | `icu/admin/admission-requests/{id}/respond` | Accept/reject/request-info/redirect |

### 2.2 Request/Response Contracts

#### GET `icu/units` — Bed Search

**Query parameters:**
```
?case_type_id=3
&specialty=cardiac
&has_ventilator=1
&availability_status=available
&insurance_provider_id=5
&price_min=500
&price_max=3000
&city=cairo
&latitude=30.0
&longitude=31.2
&sort_by=distance|price
&page=1
&per_page=15
```

**Response:**
```json
{
  "status": true,
  "data": [
    {
      "id": 1,
      "name": "Cardiac ICU",
      "specialty": "cardiac",
      "total_beds": 12,
      "has_ventilator": true,
      "has_isolation": true,
      "daily_price_min": 1500.00,
      "daily_price_max": 3000.00,
      "availability_status": "available",
      "availability_updated_at": "2026-03-20T10:30:00Z",
      "equipment_level": "advanced",
      "hospital": {
        "id": 5,
        "name": "Cairo Medical Center",
        "address": "123 Main St, Cairo",
        "city": "Cairo",
        "latitude": 30.05,
        "longitude": 31.23,
        "distance_km": 3.2,
        "image": "https://..."
      },
      "case_types": [
        {"id": 1, "name": "Heart Attack"},
        {"id": 2, "name": "Stroke"}
      ],
      "accepted_insurances": [
        {"id": 5, "name": "MetLife"}
      ]
    }
  ],
  "meta": {
    "current_page": 1,
    "last_page": 3,
    "per_page": 15,
    "total": 42
  }
}
```

#### GET `icu/units/{id}` — Unit Detail

**Response:** Same as single item in search results, with full hospital details.

#### POST `icu/admission-requests` — Submit Admission

**Request (multipart/form-data):**
```
patient_name: "Ahmed Hassan"
patient_age: 55
patient_gender: "male"
icu_unit_id: 1
case_type_id: 3
initial_diagnosis: "Suspected acute MI"
severity_level: "critical"
vital_signs: {"heart_rate": 120, "bp": "80/50", "o2_sat": 88, "temperature": 38.2}
requires_oxygen: 1
requires_ventilator: 0
requires_isolation: 0
companion_name: "Sara Hassan"
companion_phone: "+201012345678"
companion_relation: "Daughter"
arrival_method: "ambulance"
insurance_provider_id: 5
insurance_number: "INS-123456"
notes: "Patient is diabetic"
files[0]: (binary)
file_types[0]: "imaging"
files[1]: (binary)
file_types[1]: "lab_result"
```

**Response:**
```json
{
  "status": true,
  "message": "Admission request submitted successfully",
  "data": {
    "id": 42,
    "patient_name": "Ahmed Hassan",
    "status": "pending",
    "icu_unit": { /* nested */ },
    "case_type": { /* nested */ },
    "files": [ /* nested */ ],
    "created_at": "2026-03-20T14:30:00Z"
  }
}
```

#### GET `icu/admission-requests` — List User's Requests

**Query parameters:**
```
?status=pending|accepted|rejected|info_requested|redirected|cancelled
&page=1
&per_page=15
```

**Response:** Paginated list of admission requests with nested icu_unit and case_type.

#### POST `icu/admission-requests/{id}/cancel` — Cancel Request

**Precondition:** Request must be in `pending` status.

**Response:**
```json
{
  "status": true,
  "message": "Admission request cancelled successfully"
}
```

#### PUT `icu/units/{id}/availability` — Update Availability (Admin)

**Request:**
```json
{
  "availability_status": "last_bed"
}
```

**Response:**
```json
{
  "status": true,
  "message": "Availability updated successfully",
  "data": { /* updated IcuUnit */ }
}
```

#### PUT `icu/admin/admission-requests/{id}/respond` — Respond to Request (Admin)

**Request:**
```json
{
  "status": "accepted",
  "admin_response_note": "Patient accepted. Bed 4A assigned. Please arrive within 2 hours."
}
```

Or for redirect:
```json
{
  "status": "redirected",
  "admin_response_note": "We recommend Nile Hospital — they have a specialized burns unit. Contact: 02-12345678"
}
```

**Response:**
```json
{
  "status": true,
  "message": "Response submitted successfully",
  "data": { /* updated AdmissionRequest */ }
}
```

### 2.3 Flutter API Integration

**New constants in `APIEndPoints`:**
```dart
static const String icuCaseTypes = 'v1/icu/case-types';
static const String icuInsuranceProviders = 'v1/icu/insurance-providers';
static const String icuUnits = 'v1/icu/units';
static const String icuAdmissionRequests = 'v1/icu/admission-requests';
```

**New methods in `CoreServiceApis`** (8 total):
- `getIcuCaseTypes()` — GET, returns `List<IcuCaseType>`
- `getInsuranceProviders()` — GET, returns `List<InsuranceProvider>`
- `getIcuUnits({filters, page, perPage})` — GET with query params, paginated
- `getIcuUnitDetail({required int id})` — GET single unit
- `createAdmissionRequest({required Map request, List<File> files})` — POST multipart
- `getAdmissionRequests({String status, int page})` — GET paginated list
- `getAdmissionRequestDetail({required int id})` — GET single request
- `cancelAdmissionRequest({required int id})` — POST cancel

All methods follow existing codebase patterns: `buildHttpResponse()` / `buildMultiPartResponse()`, `handleResponse()`, safe type checking.

---

## 3. Flutter Screen Architecture & Navigation

### 3.1 File Structure

```
lib/screens/intensive_care/
├── intensive_care_screen.dart              # Entry point — tabs: Search | My Requests
├── intensive_care_controller.dart          # Tab state management
├── search/
│   ├── icu_search_screen.dart              # Search form + results list
│   ├── icu_search_controller.dart          # Filters, pagination, API calls
│   ├── icu_unit_detail_screen.dart         # Full unit detail + "Request Admission" CTA
│   ├── icu_unit_detail_controller.dart     # Detail fetch
│   └── icu_filter_bottom_sheet.dart        # Advanced filter bottom sheet
├── admission/
│   ├── create_admission_screen.dart        # Single scrollable admission form
│   ├── create_admission_controller.dart    # Form state, validation, file uploads
│   ├── admission_list_screen.dart          # User's past/active requests (paginated)
│   ├── admission_list_controller.dart      # List fetch, status filtering
│   ├── admission_detail_screen.dart        # Request detail + hospital response
│   └── admission_detail_controller.dart    # Detail fetch
├── model/
│   ├── icu_case_type_model.dart
│   ├── icu_unit_model.dart                 # IcuUnit + IcuUnitListResponse
│   ├── insurance_provider_model.dart
│   ├── admission_request_model.dart        # AdmissionRequest + list response
│   └── admission_file_model.dart
└── components/
    ├── icu_unit_card.dart                  # Search result card widget
    ├── admission_request_card.dart         # Request list item card
    ├── availability_badge.dart             # Available / Last Bed / Unavailable chip
    ├── severity_badge.dart                 # Critical / Serious / Moderate chip
    ├── admission_status_badge.dart         # Pending / Accepted / Rejected / etc.
    ├── vital_signs_input.dart              # Grouped vitals input fields
    ├── equipment_indicator.dart            # Ventilator / Isolation icons row
    └── admission_file_picker.dart          # File picker with per-file type tagging
```

### 3.2 Navigation Flow

```
Home Screen
  └── "Intensive Care" service card (red/orange gradient)
        └── IntensiveCareScreen (TabBar: Search | My Requests)
              │
              ├── Tab 1: ICU Search
              │     └── IcuSearchScreen
              │           ├── Filter bar (case type, specialty quick chips)
              │           ├── "More Filters" → IcuFilterBottomSheet
              │           ├── Sort dropdown (distance / price)
              │           └── Results list (IcuUnitCard, paginated)
              │                 └── Tap card → IcuUnitDetailScreen
              │                       ├── Hospital info, equipment, pricing
              │                       ├── Availability badge
              │                       ├── Accepted insurances
              │                       └── "Request Admission" button
              │                             └── CreateAdmissionScreen
              │                                   └── Submit → AdmissionDetailScreen
              │
              └── Tab 2: My Requests
                    └── AdmissionListScreen
                          ├── Status filter tabs (All / Pending / Accepted / Rejected / etc.)
                          └── AdmissionRequestCard list (paginated)
                                └── Tap card → AdmissionDetailScreen
                                      ├── Full request info
                                      ├── Status badge
                                      ├── Hospital response note
                                      └── Cancel button (if pending)
```

### 3.3 Home Screen Integration

In `quick_services_component.dart`:
- **Service card:** Red/orange gradient, medical cross or bed icon, label "Intensive Care" → `Get.to(() => IntensiveCareScreen())`
- **My Requests tile:** "My ICU Requests" icon + label → `Get.to(() => AdmissionListScreen())`

Both wrapped in `doIfLoggedIn()`.

### 3.4 Create Admission Form Layout

Single scrollable screen with grouped sections (consistent with Nurse Request and Incident Management patterns):

**Section 1 — Patient Info**
- Patient name (text field, required)
- Patient age (number field, required)
- Patient gender (radio group: Male / Female / Other, required — uses existing `GenderTypeConst`)

**Section 2 — Case Details**
- Case type (dropdown from API, required)
- Initial diagnosis (text area, required)
- Severity level (radio group: Critical / Serious / Moderate, required)

**Section 3 — Medical Requirements**
- Requires oxygen (switch toggle)
- Requires ventilator (switch toggle)
- Requires isolation (switch toggle)
- Vital signs (optional expandable section):
  - Heart rate (number)
  - Blood pressure (text, e.g., "120/80")
  - O2 saturation (number, %)
  - Temperature (number, C)

**Section 4 — File Attachments**
- Add files button (custom file picker widget — existing `add_files_widget.dart` doesn't support per-file type tagging, so a new `admission_file_picker.dart` component is needed)
- Each file tagged with type dropdown: Imaging / Lab Result / Medical Report / Prescription / Other
- File list with remove option
- Max 10 files, max 10MB per file

**Section 5 — Logistics**
- Arrival method (radio group: Ambulance / Private Car, required)
- Payment type toggle: Insurance / Cash
  - If Insurance: Insurance provider (dropdown from API) + Insurance number (text field)

**Section 6 — Companion Info (optional)**
- Companion name (text field)
- Companion phone (text field with country code picker)
- Companion relation (text field)

**Section 7 — Additional Notes**
- Free text area (optional)

**Submit button** at bottom with loading state.

---

## 4. Laravel Backend Architecture

### 4.1 Directory Structure

```
app/
├── Http/Controllers/Api/V1/Icu/
│   ├── IcuCaseTypeController.php          # index: list active case types
│   ├── InsuranceProviderController.php    # index: list active insurance providers
│   ├── IcuUnitController.php              # index (search), show (detail), updateAvailability
│   ├── AdmissionRequestController.php     # store, index, show, cancel (patient-side)
│   └── AdminAdmissionController.php       # index, respond (hospital admin-side)
├── Models/
│   ├── IcuCaseType.php
│   ├── IcuUnit.php
│   ├── InsuranceProvider.php
│   ├── AdmissionRequest.php
│   └── AdmissionFile.php
├── Http/Requests/Icu/
│   ├── SearchIcuUnitsRequest.php           # Validates search filter params
│   ├── StoreAdmissionRequest.php           # Validates admission form fields + files
│   ├── UpdateAvailabilityRequest.php       # Validates availability_status enum
│   └── RespondAdmissionRequest.php         # Validates status + admin_response_note
├── Http/Resources/Icu/
│   ├── IcuCaseTypeResource.php
│   ├── IcuUnitResource.php                 # Includes nested hospital, distance_km
│   ├── InsuranceProviderResource.php
│   ├── AdmissionRequestResource.php        # Includes nested unit, case_type, files
│   └── AdmissionFileResource.php
├── Notifications/
│   └── AdmissionStatusNotification.php     # FCM push when status changes
└── Services/
    └── IcuDistanceService.php              # Haversine distance calculation in SQL
```

### 4.2 Routes

```php
Route::prefix('v1/icu')->middleware('auth:sanctum')->group(function () {
    // Catalog
    Route::get('case-types', [IcuCaseTypeController::class, 'index']);
    Route::get('insurance-providers', [InsuranceProviderController::class, 'index']);

    // Bed Search
    Route::get('units', [IcuUnitController::class, 'index']);
    Route::get('units/{id}', [IcuUnitController::class, 'show']);

    // Patient Admission Requests
    Route::post('admission-requests', [AdmissionRequestController::class, 'store']);
    Route::get('admission-requests', [AdmissionRequestController::class, 'index']);
    Route::get('admission-requests/{id}', [AdmissionRequestController::class, 'show']);
    Route::post('admission-requests/{id}/cancel', [AdmissionRequestController::class, 'cancel']);

    // Hospital Admin
    Route::middleware('role:admin,hospital_admin')->group(function () {
        Route::put('units/{id}/availability', [IcuUnitController::class, 'updateAvailability']);
        Route::get('admin/admission-requests', [AdminAdmissionController::class, 'index']);
        Route::put('admin/admission-requests/{id}/respond', [AdminAdmissionController::class, 'respond']);
    });
});
```

### 4.3 Model Relationships

```php
// IcuUnit
public function hospital() { return $this->belongsTo(Clinic::class, 'hospital_id'); }
public function admissionRequests() { return $this->hasMany(AdmissionRequest::class); }

// AdmissionRequest
public function user() { return $this->belongsTo(User::class); }
public function icuUnit() { return $this->belongsTo(IcuUnit::class); }
public function caseType() { return $this->belongsTo(IcuCaseType::class, 'case_type_id'); }
public function insuranceProvider() { return $this->belongsTo(InsuranceProvider::class); }
public function files() { return $this->hasMany(AdmissionFile::class, 'admission_request_id'); }
```

### 4.4 Distance Calculation

`IcuDistanceService` uses Haversine formula via a JOIN to the clinics table when `latitude`/`longitude` query params are provided. The `icu_units` table has no lat/lng columns — those live on the `clinics` table (joined via `hospital_id`). The existing Clinic model stores lat/lng as strings, so the query casts them:

```php
->join('clinics', 'icu_units.hospital_id', '=', 'clinics.id')
->selectRaw("icu_units.*, clinics.name as hospital_name,
  (6371 * acos(cos(radians(?)) * cos(radians(CAST(clinics.latitude AS DECIMAL(10,7))))
  * cos(radians(CAST(clinics.longitude AS DECIMAL(10,7))) - radians(?)) + sin(radians(?))
  * sin(radians(CAST(clinics.latitude AS DECIMAL(10,7)))))) AS distance_km", [$lat, $lng, $lat])
->orderBy('distance_km')
```

### 4.5 Notifications

When hospital admin responds to an admission request, `AdmissionStatusNotification` sends an FCM push to the requesting user via the existing `PushNotificationService` pattern. Payload includes admission request ID, new status, and hospital name.

### 4.6 File Storage

Admission files stored via Laravel storage:
- Path: `storage/app/public/icu-admissions/{request_id}/{filename}`
- Accessible via `storage:link` symlink
- Follows existing file upload handling patterns

---

## 5. Localization

Approximately **85 new locale keys** to add across all 5 language files (`language_en.dart`, `language_ar.dart`, `language_de.dart`, `language_fr.dart`, `language_hi.dart`) plus the abstract base (`languages.dart`).

### Key Groups

**Main Navigation:**
`intensiveCare`, `icuSearch`, `myIcuRequests`, `searchForIcuBed`, `findAvailableIcuBeds`, `noIcuUnitsFound`, `noAdmissionRequests`

**Case Types & Filters:**
`caseType`, `selectCaseType`, `specialty`, `allSpecialties`, `cardiac`, `neurology`, `pediatrics`, `burns`, `chest`, `generalEmergency`, `filterResults`, `sortBy`, `sortByDistance`, `sortByPrice`, `ventilatorAvailable`, `isolationAvailable`, `equipmentLevel`, `basic`, `advanced`, `comprehensive`, `priceRange`, `dailyPrice`

**Availability:**
`availability`, `available`, `lastBed`, `unavailable`, `lastUpdated`, `bedsAvailable`, `totalBeds`

**Admission Form:**
`requestAdmission`, `submitAdmissionRequest`, `patientInfo`, `patientName`, `patientAge`, `patientGender`, `male`, `female`, `other`, `caseDetails`, `initialDiagnosis`, `severityLevel`, `critical`, `serious`, `moderate`, `medicalRequirements`, `requiresOxygen`, `requiresVentilator`, `requiresIsolation`, `vitalSigns`, `heartRate`, `bloodPressure`, `oxygenSaturation`, `temperature`, `attachFiles`, `fileType`, `imaging`, `labResult`, `medicalReport`, `prescription`, `arrivalMethod`, `ambulance`, `privateCar`, `insuranceProvider`, `selectInsurance`, `cashPayment`, `insuranceNumber`, `companionInfo`, `companionName`, `companionPhone`, `companionRelation`, `additionalNotes`

**Admission Status:**
`admissionStatus`, `pending`, `accepted`, `rejected`, `infoRequested`, `redirected`, `cancelled`, `hospitalResponse`, `admissionSubmittedSuccessfully`, `cancelRequest`, `confirmCancelRequest`, `requestCancelled`

**Validation:**
`pleaseEnterPatientName`, `pleaseEnterPatientAge`, `pleaseSelectCaseType`, `pleaseEnterDiagnosis`, `pleaseSelectSeverity`, `pleaseSelectArrivalMethod`, `pleaseEnterInsuranceNumber`

**Unit Detail:**
`hospitalInfo`, `icuUnitDetails`, `acceptedInsurance`, `estimatedDailyPrice`, `requestAdmissionToThisUnit`

---

## 6. Validation & Edge Cases

### Backend Validation Rules (`StoreAdmissionRequest`)
- `patient_name`: required, string, max 255
- `patient_age`: required, integer, min 0, max 150
- `patient_gender`: required, in: `male`, `female`, `other`
- `icu_unit_id`: required, exists in `icu_units`
- `case_type_id`: required, exists in `icu_case_types`
- `initial_diagnosis`: required, string, max 2000
- `severity_level`: required, in: `critical`, `serious`, `moderate`
- `vital_signs.heart_rate`: nullable, integer, min 20, max 300
- `vital_signs.o2_sat`: nullable, integer, min 0, max 100
- `vital_signs.temperature`: nullable, numeric, min 30, max 45
- `vital_signs.bp`: nullable, string (e.g., "120/80")
- `requires_oxygen`, `requires_ventilator`, `requires_isolation`: boolean
- `arrival_method`: required, in: `ambulance`, `private_car`
- `insurance_provider_id`: nullable, exists in `insurance_providers`
- `insurance_number`: required_with `insurance_provider_id`, string
- `files.*`: nullable, file, max 10240 (10MB), mimes: jpg,jpeg,png,pdf,doc,docx
- `file_types.*`: required_with `files.*`, in: `imaging`, `lab_result`, `medical_report`, `prescription`, `other`
- Max 10 files per request

### Edge Cases
- **Submitting to an unavailable unit:** The backend allows submission regardless of availability status. The unit's availability is informational; the hospital may still accept if a bed opens up. The UI shows a warning but does not block submission.
- **Cancel precondition:** Only requests with status `pending` can be cancelled. The backend returns 422 if the request is in any other status.
- **Vital signs JSON keys vs locale keys:** The JSON payload uses short keys (`bp`, `o2_sat`) while locale keys use full names (`bloodPressure`, `oxygenSaturation`). These are intentionally different — JSON keys are for data, locale keys are for UI labels.
- **Distance sorting without coordinates:** If the user does not provide lat/lng, `distance_km` is omitted from the response and `sort_by=distance` falls back to default ordering.

---

## 7. Summary

| Dimension | Count |
|-----------|-------|
| Database tables | 5 |
| API endpoints | 11 (8 patient, 3 admin) |
| Flutter screens | 6 (+ 1 entry point, 1 filter bottom sheet) |
| Flutter controllers | 6 |
| Flutter models | 5 (+ 2 list response wrappers) |
| Reusable components | 8 |
| Locale keys | ~85 per language file |
| Laravel controllers | 5 |
| Laravel models | 5 |
| Laravel form requests | 4 |
| Laravel resources | 5 |
| Laravel migrations | 5 |
| Laravel services | 1 (distance) |
| Laravel notifications | 1 (FCM push) |
