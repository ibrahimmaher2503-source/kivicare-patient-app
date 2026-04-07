# Tasks: ICU Admissions Module

**Input**: Design documents from `/specs/004-icu-admissions-module/`
**Prerequisites**: plan.md (required), spec.md (required), research.md, data-model.md, contracts/

**Tests**: Not requested. Tests are OPTIONAL per constitution.

**Context**: This is a **brand new module** — no existing code. All files must be
created from scratch following patterns established by lab_test, nurse, and
request_service modules. Reference those modules for implementation patterns.

**Organization**: Tasks grouped by user story for independent implementation.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (US1–US4)
- Exact file paths included in descriptions

---

## Phase 1: Setup (Project Structure & Infrastructure)

**Purpose**: Create directory structure, endpoint constants, color constants, locale keys, and status enums

- [x] T001 Create directory structure: lib/screens/icu/, lib/screens/icu/model/, lib/screens/icu/components/
- [x] T002 Add ~7 ICU endpoint constants to lib/utils/api_end_points.dart: getHospitals, getHospitalDetail, getIcuDepartments, getIcuAdmissionRequests, createIcuAdmissionRequest, getIcuAdmissionRequestDetail, cancelIcuAdmissionRequest — all with v1/ prefix paths per contracts/api-endpoints.md
- [x] T003 [P] Add ICU status colors to lib/utils/colors.dart: icuStatusPendingColor (amber), icuStatusAcceptedColor (green), icuStatusRejectedColor (red), icuStatusInfoRequestedColor (blue), icuStatusCancelledColor (grey) — plus urgency colors: urgencyCriticalColor (red), urgencyUrgentColor (orange), urgencyStandardColor (blue)
- [x] T004 [P] Add ICU constants to lib/utils/constants.dart: IcuAdmissionStatusConst (pending, accepted, rejected, info_requested, cancelled), IcuUrgencyConst (critical, urgent, standard), IcuCaseTypeConst (stroke, cardiac, post_operative, ventilator, neonatal, pediatric, burns, general), IcuEquipmentLevelConst (basic, advanced, full), IcuHospitalTypeConst (government, private, military, university), IcuPaymentMethodConst (insurance, cash), IcuSpecialtyConst (cardiac, neurology, pediatric, neonatal, burns, chest, surgical, general)

**Checkpoint**: Infrastructure ready for model and API development

---

## Phase 2: Foundational (Models, API Methods, Locale Keys)

**Purpose**: Create all data models, API service methods, and locale keys that ALL user stories depend on

### Models

- [x] T005 Create Hospital and IcuDepartment models in lib/screens/icu/model/hospital_model.dart — Hospital with 20 fields (fromJson/toJson), IcuDepartment with 12 fields (fromJson/toJson), HospitalListResponse with pagination meta, IcuDepartmentListResponse with pagination meta. Follow snake_case mapping pattern from lab_test_model.dart
- [x] T006 [P] Create IcuAdmissionRequest model in lib/screens/icu/model/icu_admission_model.dart — main model with 17 fields + 5 nested models: AdmissionPatient (id/name/email), PatientInfo (5 fields), CaseDetails (7 fields), ContactInfo (3 fields), MedicalReport (5 fields). Plus IcuAdmissionListResponse with pagination meta. Follow pattern from test_order_model.dart

### API Methods

- [x] T007 Add getHospitalList() method to lib/api/core_apis.dart — paginated GET with query params: per_page, page, city, specialty, ventilator, insurance, search. Returns RxList<Hospital>. Follow pattern from getNurseList()
- [x] T008 [P] Add getHospitalDetail() method to lib/api/core_apis.dart — GET v1/hospitals/{id}, returns single Hospital with departments
- [x] T009 [P] Add getIcuDepartmentList() method to lib/api/core_apis.dart — paginated GET with query params: per_page, page, hospital_id, specialty, available, ventilator. Returns RxList<IcuDepartment>
- [x] T010 [P] Add getIcuAdmissionList() method to lib/api/core_apis.dart — paginated GET with query params: per_page, page, status. Returns RxList<IcuAdmissionRequest>
- [x] T011 [P] Add createIcuAdmission() method to lib/api/core_apis.dart — multipart POST using buildMultiPartResponse() for file upload support. Accepts Map request + List<File> medicalReports. Returns IcuAdmissionRequest
- [x] T012 [P] Add getIcuAdmissionDetail() method to lib/api/core_apis.dart — GET v1/icu-admission-requests/{id}, returns single IcuAdmissionRequest
- [x] T013 [P] Add cancelIcuAdmission() method to lib/api/core_apis.dart — POST v1/icu-admission-requests/{id}/cancel with {cancellation_reason} body

### Locale Keys

- [x] T014 Add ~40 ICU locale key getters to lib/locale/languages.dart abstract class: icuAdmissions, hospitals, hospitalDetails, icuDepartments, browseHospitals, myIcuRequests, createAdmissionRequest, admissionRequestDetails, admissionSubmitted, admissionCancelled, patientInformation, caseDetails, emergencyContact, paymentInformation, medicalReports, patientName, patientAge, patientGender, nationalId, insuranceNumber, medicalCondition, diagnosis, caseType, urgency, needsVentilator, needsOxygen, currentLocation, needsAmbulance, contactName, contactPhone, relationship, paymentMethod, insuranceProvider, attachReports, requestNumber, totalBeds, availableBeds, dailyPrice, equipmentLevel, hospitalType, noHospitalsFound, noIcuRequestsYet, critical, urgent, standard, accepted, rejected, infoRequested, male, female
- [x] T015 [P] Add English translations for all T014 keys in lib/locale/language_en.dart
- [x] T016 [P] Add Arabic translations for all T014 keys in lib/locale/language_ar.dart
- [x] T017 [P] Add German translations for all T014 keys in lib/locale/language_de.dart
- [x] T018 [P] Add French translations for all T014 keys in lib/locale/language_fr.dart
- [x] T019 [P] Add Hindi translations for all T014 keys in lib/locale/language_hi.dart

**Checkpoint**: All models, API methods, and locale keys ready. User story implementation can begin.

---

## Phase 3: User Story 1 — Browse Hospitals & ICU Departments (Priority: P1) MVP

**Goal**: Build hospital list with filters, hospital detail with departments, and department list

**Independent Test**: Open ICU section from home, browse hospitals, filter by specialty/ventilator/insurance, view hospital detail with departments, browse departments directly

### Implementation for User Story 1

- [x] T020 [P] [US1] Create hospital_card.dart in lib/screens/icu/components/ — displays hospital name, logo (CachedImageWidget with fallback), type badge, city, rating (stars), departments count, accepted insurance tags. Uses Clinical Elegance tokens: 16px radius, softShadowColor, surfaceElevated/Dark. Tap navigates to detail.
- [x] T021 [P] [US1] Create department_card.dart in lib/screens/icu/components/ — displays department name, specialty badge, bed availability (available/total with color indicator), ventilator/oxygen icons, equipment level badge, daily price. Clinical Elegance tokens.
- [x] T022 [US1] Create hospital_list_controller.dart in lib/screens/icu/ — manages hospital list with RxList<Hospital>, search debounce (500ms), specialty filter, ventilator filter, insurance filter, city filter, pagination (page, isLastPage, isLoading). Calls CoreServiceApis.getHospitalList(). Follow pattern from nurse_list_controller.dart
- [x] T023 [US1] Create hospital_list_screen.dart in lib/screens/icu/ — AppScaffoldNew, search field, filter chips (specialty types), AnimatedScrollView with onNextPage/onSwipeRefresh, HospitalCard items, empty state. Follow pattern from nurse_list_screen.dart
- [x] T024 [US1] Create hospital_detail_screen.dart in lib/screens/icu/ — displays full hospital profile (name, logo, type, address, city, phone, email, website, rating, accepted insurance list) + scrollable list of IcuDepartment cards. "Request Admission" action button. Loads via CoreServiceApis.getHospitalDetail()
- [x] T025 [P] [US1] Create department_list_controller.dart in lib/screens/icu/ — manages department list with filters: hospital_id, specialty, available beds, ventilator. Pagination. Calls CoreServiceApis.getIcuDepartmentList()
- [x] T026 [US1] Create department_list_screen.dart in lib/screens/icu/ — AppScaffoldNew, filter chips, AnimatedScrollView, DepartmentCard items, empty state
- [x] T027 [US1] Add ICU entry points to lib/screens/home/components/quick_services_component.dart — "ICU Admissions" quick service card navigating to HospitalListScreen via Get.to() with doIfLoggedIn(), plus "My ICU Requests" request tile navigating to AdmissionListScreen

**Checkpoint**: Patient can browse hospitals, filter, view details with departments, and browse departments

---

## Phase 4: User Story 2 — Submit ICU Admission Request (Priority: P2)

**Goal**: Build multi-section admission form with conditional validation and file uploads

**Independent Test**: Select hospital, fill all form sections, upload report, submit, see confirmation

### Implementation for User Story 2

- [x] T028 [US2] Create create_admission_controller.dart in lib/screens/icu/ — manages ~20 TextEditingControllers for form fields, RxString paymentMethod for conditional insurance fields, RxBool needsVentilator/needsOxygen/needsAmbulance toggles, RxList<File> medicalReports for file attachments, selectedHospital and selectedDepartment reactive state. submitRequest() builds multipart request body, calls CoreServiceApis.createIcuAdmission(). Validation: required fields (patient_name, patient_age, patient_gender, medical_condition, case_type, urgency, contact_name, contact_phone, payment_method, hospital_id), conditional insurance fields when payment_method='insurance'
- [x] T029 [US2] Create create_admission_screen.dart in lib/screens/icu/ — multi-section scrollable form with Clinical Elegance styling:
  Section 1 - Hospital: pre-selected hospital name, optional department dropdown
  Section 2 - Patient Info: name (required max:255), age (required 0-150), gender selector (male/female), national ID (optional max:50), insurance number (conditional max:100)
  Section 3 - Case Details: medical condition (required max:5000 multiline), diagnosis (optional max:500), case type dropdown (8 types), urgency selector (critical/urgent/standard), needs ventilator/oxygen/ambulance toggle switches, current location (optional max:500)
  Section 4 - Emergency Contact: name (required max:255), phone (required max:50), relationship (optional max:100)
  Section 5 - Payment: method selector (insurance/cash), insurance provider (conditional max:255)
  Section 6 - Medical Reports: file picker (pdf/jpg/png/doc/docx, max 10MB each), file list with remove, upload progress indicator
  Submit button with gradient styling. All labels via locale.value. All inputs with Clinical Elegance tokens (12px radius, inputFillColor/Dark)
- [x] T030 [US2] Implement file picker integration in create_admission_controller.dart — pickFiles() method using existing image_picker or file_picker patterns, filter by allowed mime types (pdf/jpg/jpeg/png/doc/docx), validate max 10MB per file, store in RxList<File>, removeFile() method
- [x] T031 [US2] Implement multipart request body builder in create_admission_controller.dart — _buildMultiPartRequest() that constructs MultipartRequest with all form fields as flat keys + medical_reports[] as file attachments. Handle boolean fields as '1'/'0' strings for multipart

**Checkpoint**: Patient can fill multi-section form, attach files, submit, see confirmation

---

## Phase 5: User Story 3 — View & Track Admission Requests (Priority: P3)

**Goal**: Build request list with status filter and detailed request view

**Independent Test**: Open My ICU Requests, filter by status, tap request, verify all sections

### Implementation for User Story 3

- [x] T032 [P] [US3] Create admission_request_card.dart in lib/screens/icu/components/ — displays request number (ICU-YYYY-NNNN), hospital name, status badge (colored per icuStatus*Color), urgency badge (colored per urgency*Color), case type, creation date. Tap navigates to detail. Clinical Elegance tokens.
- [x] T033 [US3] Create admission_list_controller.dart in lib/screens/icu/ — manages admission list with RxList<IcuAdmissionRequest>, status filter (5 statuses + all), pagination. Calls CoreServiceApis.getIcuAdmissionList()
- [x] T034 [US3] Create admission_list_screen.dart in lib/screens/icu/ — AppScaffoldNew, status filter chips, AnimatedScrollView, AdmissionRequestCard items, empty state with CTA to browse hospitals, "Add" button in app bar
- [x] T035 [US3] Create admission_detail_screen.dart in lib/screens/icu/ — displays all request sections:
  Header: request number, status badge, urgency badge
  Patient Info: name, age, gender, national ID, insurance number
  Case Details: medical condition, diagnosis, case type, equipment needs, location, ambulance
  Emergency Contact: name, phone, relationship
  Hospital & Department: hospital name, department name (if selected)
  Payment: method, insurance provider
  Admin Response: admin notes, rejection reason (if rejected), response date
  Medical Reports: list of attached files with download links (tap to open URL)
  Timestamps: created_at
  Action buttons: Cancel (if pending)
  All labels via locale.value, Clinical Elegance tokens, dark mode support

**Checkpoint**: Patient can view request list, filter by status, see full request details

---

## Phase 6: User Story 4 — Cancel an Admission Request (Priority: P4)

**Goal**: Add cancel functionality to the detail screen

**Independent Test**: Open pending request, tap cancel, enter reason, confirm, verify status change

### Implementation for User Story 4

- [x] T036 [US4] Add cancel button to admission_detail_screen.dart — show ONLY when status is "pending", hidden for all other statuses. Button triggers _showCancelDialog()
- [x] T037 [US4] Implement _showCancelDialog() in admission_detail_screen.dart — AlertDialog with Form + GlobalKey<FormState>, TextFormField for cancellation_reason (required, maxLength: 500, validator checks non-empty), Cancel/Confirm buttons. On confirm: calls CoreServiceApis.cancelIcuAdmission() with {cancellation_reason: user-typed-text}. On success: shows toast(locale.value.admissionCancelled), refreshes detail or navigates back. Follow the FIXED pattern from lab_test and nurse modules (NOT the hardcoded reason antipattern)
- [x] T038 [US4] Verify cancel API method sends correct field name `cancellation_reason` in request body — ensure consistency with labs/nurse cancel pattern

**Checkpoint**: Patient can cancel pending requests with user-typed reason

---

## Phase 7: Polish & Cross-Cutting Concerns

**Purpose**: Design compliance, dark mode, RTL, generated assets, and static analysis

- [x] T039 [P] Verify all ICU screens use Clinical Elegance design tokens: 16px card radius, 12px input radius, 24px body padding, navy-tinted shadows (softShadowColor) — check all screen and component files
- [x] T040 [P] Verify all ICU screens support dark mode: isDarkMode.value with surfaceElevated/surfaceElevatedDark, inputFillColor/inputFillColorDark, softShadowColor/softShadowColorDark — check all files
- [x] T041 [P] Verify Arabic RTL layout works for all ICU screens — spot-check hospital list, admission form, and detail screens
- [x] T042 [P] Verify hospital with no logo displays default placeholder in hospital_card.dart and hospital_detail_screen.dart
- [x] T043 [P] Verify department with 0 available beds shows "No beds available" styled in red/warning color in department_card.dart
- [x] T044 Run flutter analyze and confirm zero new warnings in ICU module files and modified shared files
- [x] T045 Run quickstart.md verification: walk through all 6 verification steps on an Android device/emulator

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies — start immediately
- **Foundational (Phase 2)**: Depends on Phase 1 (needs endpoint constants, colors, enums)
  - Models (T005-T006) can parallel with API methods (T007-T013) only if models are committed first
  - Locale keys (T014-T019) can parallel with models and API methods
- **User Stories (Phase 3–6)**: ALL depend on Phase 2 completion
  - US1 (Phase 3): No story dependencies — MVP
  - US2 (Phase 4): Depends on US1 (needs hospital selection UI)
  - US3 (Phase 5): No dependency on US2 (can parallel — different screens)
  - US4 (Phase 6): Depends on US3 (adds to detail screen created in US3)
- **Polish (Phase 7)**: Depends on all user stories

### Within Each User Story

- Components before screens (cards used in list screens)
- Controllers before screens (screens reference controllers)
- Screens are the final step

### Parallel Opportunities

- T003-T004: Color + constant tasks in parallel
- T005-T006: Both model files in parallel
- T007-T013: All 7 API methods in parallel (different methods in same file — sequential preferred)
- T015-T019: All 5 language translation tasks in parallel
- T020-T021: Both card components in parallel
- T025-T026: Department controller+screen can parallel with hospital screens
- T032-T034: US3 card + controller can parallel
- T039-T043: All polish tasks in parallel

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup (directory, endpoints, colors, constants)
2. Complete Phase 2: Foundational (models, API methods, locale keys)
3. Complete Phase 3: User Story 1 (hospital + department browsing)
4. **STOP and VALIDATE**: Test hospital browsing end-to-end
5. Proceed to remaining stories

### Incremental Delivery

1. Setup + Foundational → infrastructure ready
2. US1 (hospitals + departments) → deploy/demo
3. US2 (admission form) → deploy/demo (most complex phase)
4. US3 (request tracking) → deploy/demo
5. US4 (cancel) → deploy/demo
6. Polish → final quality pass

### Estimated Scope

**New files to create**: ~15 Dart files
**Shared files to modify**: ~6 (core_apis.dart, api_end_points.dart, colors.dart, constants.dart, languages.dart + 5 language files, quick_services_component.dart)
**Total estimated**: ~21 files touched

---

## Notes

- [P] tasks = different files, no dependencies
- [Story] label maps task to specific user story
- This is BUILD-FROM-SCRATCH — not verify-and-fix like previous modules
- Follow patterns from lab_test and nurse modules for consistency
- Cancel dialog MUST use proper form validation (lesson from labs/nurse)
- File uploads MUST use buildMultiPartResponse() from network_utils.dart
- Commit after each phase for safe checkpoints
