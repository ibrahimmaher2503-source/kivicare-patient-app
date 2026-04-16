# Intensive Care Module Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a full Intensive Care module to the Espitalia Patient App — ICU bed search, emergency admission requests, and Level 1 bed availability — with all supporting Laravel backend APIs.

**Architecture:** Sub-feature split within `lib/screens/intensive_care/` with `search/`, `admission/`, `model/`, and `components/` sub-directories. Laravel backend under `app/Http/Controllers/Api/V1/Icu/` with 5 migrations, 5 models, 5 controllers, and 11 API endpoints. Follows existing Nurse/Incident module patterns exactly.

**Tech Stack:** Flutter 3.0+, GetX, nb_utils, Google Fonts (Plus Jakarta Sans + Outfit), Laravel 10+, Sanctum auth, MySQL, Firebase Cloud Messaging.

**Spec:** `docs/superpowers/specs/2026-03-20-intensive-care-module-design.md`

---

## File Structure

### Flutter (Create)

```
lib/screens/intensive_care/
├── intensive_care_screen.dart              # Entry point with TabBar
├── intensive_care_controller.dart          # Tab state
├── search/
│   ├── icu_search_screen.dart              # Search + results
│   ├── icu_search_controller.dart          # Filters, pagination
│   ├── icu_unit_detail_screen.dart         # Unit detail
│   ├── icu_unit_detail_controller.dart     # Detail fetch
│   └── icu_filter_bottom_sheet.dart        # Advanced filters
├── admission/
│   ├── create_admission_screen.dart        # Admission form
│   ├── create_admission_controller.dart    # Form state, files
│   ├── admission_list_screen.dart          # User's requests
│   ├── admission_list_controller.dart      # List + status filter
│   ├── admission_detail_screen.dart        # Request detail
│   └── admission_detail_controller.dart    # Detail fetch
├── model/
│   ├── icu_case_type_model.dart
│   ├── icu_unit_model.dart
│   ├── insurance_provider_model.dart
│   ├── admission_request_model.dart
│   └── admission_file_model.dart
└── components/
    ├── icu_unit_card.dart
    ├── admission_request_card.dart
    ├── availability_badge.dart
    ├── severity_badge.dart
    ├── admission_status_badge.dart
    ├── vital_signs_input.dart
    ├── equipment_indicator.dart
    └── admission_file_picker.dart
```

### Flutter (Modify)

```
lib/utils/api_end_points.dart              # Add ICU endpoints
lib/api/core_apis.dart                     # Add ICU service methods
lib/locale/languages.dart                  # Add abstract getters
lib/locale/language_en.dart                # Add English strings
lib/locale/language_ar.dart                # Add Arabic strings
lib/locale/language_de.dart                # Add German strings
lib/locale/language_fr.dart                # Add French strings
lib/locale/language_hi.dart                # Add Hindi strings
lib/screens/home/components/quick_services_component.dart  # Add ICU card + tile
```

### Laravel (Create)

```
database/migrations/
├── xxxx_create_icu_case_types_table.php
├── xxxx_create_insurance_providers_table.php
├── xxxx_create_icu_units_table.php
├── xxxx_create_icu_admission_requests_table.php
└── xxxx_create_icu_admission_files_table.php

app/Models/
├── IcuCaseType.php
├── IcuUnit.php
├── InsuranceProvider.php
├── AdmissionRequest.php
└── AdmissionFile.php

app/Http/Controllers/Api/V1/Icu/
├── IcuCaseTypeController.php
├── InsuranceProviderController.php
├── IcuUnitController.php
├── AdmissionRequestController.php
└── AdminAdmissionController.php

app/Http/Requests/Icu/
├── SearchIcuUnitsRequest.php
├── StoreAdmissionRequest.php
├── UpdateAvailabilityRequest.php
└── RespondAdmissionRequest.php

app/Http/Resources/Icu/
├── IcuCaseTypeResource.php
├── IcuUnitResource.php
├── InsuranceProviderResource.php
├── AdmissionRequestResource.php
└── AdmissionFileResource.php

app/Services/IcuDistanceService.php
app/Notifications/AdmissionStatusNotification.php

routes/api.php                             # Add ICU route group
```

---

## Task 1: Flutter Data Models

**Files:**
- Create: `lib/screens/intensive_care/model/icu_case_type_model.dart`
- Create: `lib/screens/intensive_care/model/insurance_provider_model.dart`
- Create: `lib/screens/intensive_care/model/admission_file_model.dart`
- Create: `lib/screens/intensive_care/model/icu_unit_model.dart`
- Create: `lib/screens/intensive_care/model/admission_request_model.dart`

**Reference:** `lib/screens/nurse/model/nurse_model.dart` for pattern (type-safe `fromJson`, defaults, `toJson`, list response wrapper).

- [ ] **Step 1: Create model directory**

```bash
mkdir -p lib/screens/intensive_care/model
```

- [ ] **Step 2: Create `icu_case_type_model.dart`**

```dart
class IcuCaseType {
  int id;
  String name;
  String description;
  String icon;

  IcuCaseType({
    this.id = -1,
    this.name = "",
    this.description = "",
    this.icon = "",
  });

  factory IcuCaseType.fromJson(Map<String, dynamic> json) {
    return IcuCaseType(
      id: json["id"] is int ? json["id"] : -1,
      name: json["name"] is String ? json["name"] : "",
      description: json["description"] is String ? json["description"] : "",
      icon: json["icon"] is String ? json["icon"] : "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "description": description,
      "icon": icon,
    };
  }
}
```

- [ ] **Step 3: Create `insurance_provider_model.dart`**

```dart
class InsuranceProvider {
  int id;
  String name;
  String logo;

  InsuranceProvider({
    this.id = -1,
    this.name = "",
    this.logo = "",
  });

  factory InsuranceProvider.fromJson(Map<String, dynamic> json) {
    return InsuranceProvider(
      id: json["id"] is int ? json["id"] : -1,
      name: json["name"] is String ? json["name"] : "",
      logo: json["logo"] is String ? json["logo"] : "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "logo": logo,
    };
  }
}
```

- [ ] **Step 4: Create `admission_file_model.dart`**

```dart
class AdmissionFile {
  int id;
  String filePath;
  String fileType;
  String originalName;

  AdmissionFile({
    this.id = -1,
    this.filePath = "",
    this.fileType = "",
    this.originalName = "",
  });

  factory AdmissionFile.fromJson(Map<String, dynamic> json) {
    return AdmissionFile(
      id: json["id"] is int ? json["id"] : -1,
      filePath: json["file_path"] is String ? json["file_path"] : "",
      fileType: json["file_type"] is String ? json["file_type"] : "",
      originalName: json["original_name"] is String ? json["original_name"] : "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "file_path": filePath,
      "file_type": fileType,
      "original_name": originalName,
    };
  }
}
```

- [ ] **Step 5: Create `icu_unit_model.dart`**

This is the largest model — includes nested hospital, case types, insurances, and the list response wrapper.

```dart
import 'icu_case_type_model.dart';
import 'insurance_provider_model.dart';

class IcuUnitListResponse {
  bool status;
  List<IcuUnit> data;
  int currentPage;
  int lastPage;
  int perPage;
  int total;

  IcuUnitListResponse({
    this.status = false,
    this.data = const [],
    this.currentPage = 1,
    this.lastPage = 1,
    this.perPage = 15,
    this.total = 0,
  });

  factory IcuUnitListResponse.fromJson(Map<String, dynamic> json) {
    return IcuUnitListResponse(
      status: json["status"] is bool ? json["status"] : false,
      data: json["data"] is List ? List<IcuUnit>.from(json["data"].map((x) => IcuUnit.fromJson(x))) : [],
      currentPage: json["meta"] is Map ? (json["meta"]["current_page"] ?? 1) : 1,
      lastPage: json["meta"] is Map ? (json["meta"]["last_page"] ?? 1) : 1,
      perPage: json["meta"] is Map ? (json["meta"]["per_page"] ?? 15) : 15,
      total: json["meta"] is Map ? (json["meta"]["total"] ?? 0) : 0,
    );
  }
}

class IcuUnitHospital {
  int id;
  String name;
  String address;
  String city;
  String latitude;
  String longitude;
  double distanceKm;
  String image;

  IcuUnitHospital({
    this.id = -1,
    this.name = "",
    this.address = "",
    this.city = "",
    this.latitude = "",
    this.longitude = "",
    this.distanceKm = 0.0,
    this.image = "",
  });

  factory IcuUnitHospital.fromJson(Map<String, dynamic> json) {
    return IcuUnitHospital(
      id: json["id"] is int ? json["id"] : -1,
      name: json["name"] is String ? json["name"] : "",
      address: json["address"] is String ? json["address"] : "",
      city: json["city"] is String ? json["city"] : "",
      latitude: json["latitude"] is String ? json["latitude"] : "",
      longitude: json["longitude"] is String ? json["longitude"] : "",
      distanceKm: json["distance_km"] is num ? json["distance_km"].toDouble() : 0.0,
      image: json["image"] is String ? json["image"] : "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "address": address,
      "city": city,
      "latitude": latitude,
      "longitude": longitude,
      "distance_km": distanceKm,
      "image": image,
    };
  }
}

class IcuUnit {
  int id;
  int hospitalId;
  String name;
  String specialty;
  int totalBeds;
  bool hasVentilator;
  bool hasIsolation;
  double dailyPriceMin;
  double dailyPriceMax;
  String availabilityStatus;
  String availabilityUpdatedAt;
  String equipmentLevel;
  IcuUnitHospital hospital;
  List<IcuCaseType> caseTypes;
  List<InsuranceProvider> acceptedInsurances;

  IcuUnit({
    this.id = -1,
    this.hospitalId = -1,
    this.name = "",
    this.specialty = "",
    this.totalBeds = 0,
    this.hasVentilator = false,
    this.hasIsolation = false,
    this.dailyPriceMin = 0.0,
    this.dailyPriceMax = 0.0,
    this.availabilityStatus = "",
    this.availabilityUpdatedAt = "",
    this.equipmentLevel = "",
    IcuUnitHospital? hospital,
    this.caseTypes = const [],
    this.acceptedInsurances = const [],
  }) : hospital = hospital ?? IcuUnitHospital();

  factory IcuUnit.fromJson(Map<String, dynamic> json) {
    return IcuUnit(
      id: json["id"] is int ? json["id"] : -1,
      hospitalId: json["hospital_id"] is int ? json["hospital_id"] : -1,
      name: json["name"] is String ? json["name"] : "",
      specialty: json["specialty"] is String ? json["specialty"] : "",
      totalBeds: json["total_beds"] is int ? json["total_beds"] : 0,
      hasVentilator: json["has_ventilator"] is bool ? json["has_ventilator"] : false,
      hasIsolation: json["has_isolation"] is bool ? json["has_isolation"] : false,
      dailyPriceMin: json["daily_price_min"] is num ? json["daily_price_min"].toDouble() : 0.0,
      dailyPriceMax: json["daily_price_max"] is num ? json["daily_price_max"].toDouble() : 0.0,
      availabilityStatus: json["availability_status"] is String ? json["availability_status"] : "",
      availabilityUpdatedAt: json["availability_updated_at"] is String ? json["availability_updated_at"] : "",
      equipmentLevel: json["equipment_level"] is String ? json["equipment_level"] : "",
      hospital: json["hospital"] is Map<String, dynamic> ? IcuUnitHospital.fromJson(json["hospital"]) : IcuUnitHospital(),
      caseTypes: json["case_types"] is List ? List<IcuCaseType>.from(json["case_types"].map((x) => IcuCaseType.fromJson(x))) : [],
      acceptedInsurances: json["accepted_insurances"] is List ? List<InsuranceProvider>.from(json["accepted_insurances"].map((x) => InsuranceProvider.fromJson(x))) : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "hospital_id": hospitalId,
      "name": name,
      "specialty": specialty,
      "total_beds": totalBeds,
      "has_ventilator": hasVentilator,
      "has_isolation": hasIsolation,
      "daily_price_min": dailyPriceMin,
      "daily_price_max": dailyPriceMax,
      "availability_status": availabilityStatus,
      "availability_updated_at": availabilityUpdatedAt,
      "equipment_level": equipmentLevel,
      "hospital": hospital.toJson(),
      "case_types": caseTypes.map((x) => x.toJson()).toList(),
      "accepted_insurances": acceptedInsurances.map((x) => x.toJson()).toList(),
    };
  }
}
```

- [ ] **Step 6: Create `admission_request_model.dart`**

```dart
import 'icu_case_type_model.dart';
import 'icu_unit_model.dart';
import 'insurance_provider_model.dart';
import 'admission_file_model.dart';

class AdmissionRequestListResponse {
  bool status;
  List<AdmissionRequest> data;
  int currentPage;
  int lastPage;
  int perPage;
  int total;

  AdmissionRequestListResponse({
    this.status = false,
    this.data = const [],
    this.currentPage = 1,
    this.lastPage = 1,
    this.perPage = 15,
    this.total = 0,
  });

  factory AdmissionRequestListResponse.fromJson(Map<String, dynamic> json) {
    return AdmissionRequestListResponse(
      status: json["status"] is bool ? json["status"] : false,
      data: json["data"] is List ? List<AdmissionRequest>.from(json["data"].map((x) => AdmissionRequest.fromJson(x))) : [],
      currentPage: json["meta"] is Map ? (json["meta"]["current_page"] ?? 1) : 1,
      lastPage: json["meta"] is Map ? (json["meta"]["last_page"] ?? 1) : 1,
      perPage: json["meta"] is Map ? (json["meta"]["per_page"] ?? 15) : 15,
      total: json["meta"] is Map ? (json["meta"]["total"] ?? 0) : 0,
    );
  }
}

class VitalSigns {
  int heartRate;
  String bp;
  int o2Sat;
  double temperature;

  VitalSigns({
    this.heartRate = 0,
    this.bp = "",
    this.o2Sat = 0,
    this.temperature = 0.0,
  });

  factory VitalSigns.fromJson(Map<String, dynamic> json) {
    return VitalSigns(
      heartRate: json["heart_rate"] is int ? json["heart_rate"] : 0,
      bp: json["bp"] is String ? json["bp"] : "",
      o2Sat: json["o2_sat"] is int ? json["o2_sat"] : 0,
      temperature: json["temperature"] is num ? json["temperature"].toDouble() : 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "heart_rate": heartRate,
      "bp": bp,
      "o2_sat": o2Sat,
      "temperature": temperature,
    };
  }

  bool get isEmpty => heartRate == 0 && bp.isEmpty && o2Sat == 0 && temperature == 0.0;
}

class AdmissionRequest {
  int id;
  String patientName;
  int patientAge;
  String patientGender;
  String initialDiagnosis;
  String severityLevel;
  VitalSigns vitalSigns;
  bool requiresOxygen;
  bool requiresVentilator;
  bool requiresIsolation;
  String companionName;
  String companionPhone;
  String companionRelation;
  String arrivalMethod;
  String insuranceNumber;
  String notes;
  String status;
  String adminResponseNote;
  String respondedAt;
  String createdAt;
  String updatedAt;
  IcuUnit icuUnit;
  IcuCaseType caseType;
  InsuranceProvider insuranceProvider;
  List<AdmissionFile> files;

  AdmissionRequest({
    this.id = -1,
    this.patientName = "",
    this.patientAge = 0,
    this.patientGender = "",
    this.initialDiagnosis = "",
    this.severityLevel = "",
    VitalSigns? vitalSigns,
    this.requiresOxygen = false,
    this.requiresVentilator = false,
    this.requiresIsolation = false,
    this.companionName = "",
    this.companionPhone = "",
    this.companionRelation = "",
    this.arrivalMethod = "",
    this.insuranceNumber = "",
    this.notes = "",
    this.status = "",
    this.adminResponseNote = "",
    this.respondedAt = "",
    this.createdAt = "",
    this.updatedAt = "",
    IcuUnit? icuUnit,
    IcuCaseType? caseType,
    InsuranceProvider? insuranceProvider,
    this.files = const [],
  })  : vitalSigns = vitalSigns ?? VitalSigns(),
        icuUnit = icuUnit ?? IcuUnit(),
        caseType = caseType ?? IcuCaseType(),
        insuranceProvider = insuranceProvider ?? InsuranceProvider();

  factory AdmissionRequest.fromJson(Map<String, dynamic> json) {
    return AdmissionRequest(
      id: json["id"] is int ? json["id"] : -1,
      patientName: json["patient_name"] is String ? json["patient_name"] : "",
      patientAge: json["patient_age"] is int ? json["patient_age"] : 0,
      patientGender: json["patient_gender"] is String ? json["patient_gender"] : "",
      initialDiagnosis: json["initial_diagnosis"] is String ? json["initial_diagnosis"] : "",
      severityLevel: json["severity_level"] is String ? json["severity_level"] : "",
      vitalSigns: json["vital_signs"] is Map<String, dynamic> ? VitalSigns.fromJson(json["vital_signs"]) : VitalSigns(),
      requiresOxygen: json["requires_oxygen"] is bool ? json["requires_oxygen"] : false,
      requiresVentilator: json["requires_ventilator"] is bool ? json["requires_ventilator"] : false,
      requiresIsolation: json["requires_isolation"] is bool ? json["requires_isolation"] : false,
      companionName: json["companion_name"] is String ? json["companion_name"] : "",
      companionPhone: json["companion_phone"] is String ? json["companion_phone"] : "",
      companionRelation: json["companion_relation"] is String ? json["companion_relation"] : "",
      arrivalMethod: json["arrival_method"] is String ? json["arrival_method"] : "",
      insuranceNumber: json["insurance_number"] is String ? json["insurance_number"] : "",
      notes: json["notes"] is String ? json["notes"] : "",
      status: json["status"] is String ? json["status"] : "",
      adminResponseNote: json["admin_response_note"] is String ? json["admin_response_note"] : "",
      respondedAt: json["responded_at"] is String ? json["responded_at"] : "",
      createdAt: json["created_at"] is String ? json["created_at"] : "",
      updatedAt: json["updated_at"] is String ? json["updated_at"] : "",
      icuUnit: json["icu_unit"] is Map<String, dynamic> ? IcuUnit.fromJson(json["icu_unit"]) : IcuUnit(),
      caseType: json["case_type"] is Map<String, dynamic> ? IcuCaseType.fromJson(json["case_type"]) : IcuCaseType(),
      insuranceProvider: json["insurance_provider"] is Map<String, dynamic> ? InsuranceProvider.fromJson(json["insurance_provider"]) : InsuranceProvider(),
      files: json["files"] is List ? List<AdmissionFile>.from(json["files"].map((x) => AdmissionFile.fromJson(x))) : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "patient_name": patientName,
      "patient_age": patientAge,
      "patient_gender": patientGender,
      "initial_diagnosis": initialDiagnosis,
      "severity_level": severityLevel,
      "vital_signs": vitalSigns.toJson(),
      "requires_oxygen": requiresOxygen,
      "requires_ventilator": requiresVentilator,
      "requires_isolation": requiresIsolation,
      "companion_name": companionName,
      "companion_phone": companionPhone,
      "companion_relation": companionRelation,
      "arrival_method": arrivalMethod,
      "insurance_number": insuranceNumber,
      "notes": notes,
      "status": status,
      "admin_response_note": adminResponseNote,
      "responded_at": respondedAt,
      "created_at": createdAt,
      "updated_at": updatedAt,
    };
  }
}
```

- [ ] **Step 7: Verify models compile**

Run: `flutter analyze lib/screens/intensive_care/model/`
Expected: No errors

- [ ] **Step 8: Commit**

```bash
git add lib/screens/intensive_care/model/
git commit -m "feat(icu): add data models for ICU module"
```

---

## Task 2: API Endpoints & Service Methods

**Files:**
- Modify: `lib/utils/api_end_points.dart`
- Modify: `lib/api/core_apis.dart`

**Reference:** `api_end_points.dart:73-95` for endpoint pattern, `core_apis.dart:470-536` for service method patterns.

- [ ] **Step 1: Add ICU endpoints to `api_end_points.dart`**

Add after the existing Lab Tests section (around line 95):

```dart
  //ICU / Intensive Care
  static const String icuCaseTypes = 'v1/icu/case-types';
  static const String icuInsuranceProviders = 'v1/icu/insurance-providers';
  static const String icuUnits = 'v1/icu/units';
  static const String icuAdmissionRequests = 'v1/icu/admission-requests';
```

- [ ] **Step 2: Add imports to `core_apis.dart`**

Add at top of `core_apis.dart`:

```dart
import '../screens/intensive_care/model/icu_case_type_model.dart';
import '../screens/intensive_care/model/icu_unit_model.dart';
import '../screens/intensive_care/model/insurance_provider_model.dart';
import '../screens/intensive_care/model/admission_request_model.dart';
```

- [ ] **Step 3: Add `getIcuCaseTypes()` method**

Follow the existing list method pattern. Add to `CoreServiceApis` class:

```dart
  // ── ICU Module ──

  static Future<List<IcuCaseType>> getIcuCaseTypes() async {
    final json = await handleResponse(
      await buildHttpResponse(APIEndPoints.icuCaseTypes, method: HttpMethodType.GET),
    );
    return json["data"] is List
        ? List<IcuCaseType>.from(json["data"].map((x) => IcuCaseType.fromJson(x)))
        : [];
  }
```

- [ ] **Step 4: Add `getInsuranceProviders()` method**

```dart
  static Future<List<InsuranceProvider>> getInsuranceProviders() async {
    final json = await handleResponse(
      await buildHttpResponse(APIEndPoints.icuInsuranceProviders, method: HttpMethodType.GET),
    );
    return json["data"] is List
        ? List<InsuranceProvider>.from(json["data"].map((x) => InsuranceProvider.fromJson(x)))
        : [];
  }
```

- [ ] **Step 5: Add `getIcuUnits()` paginated search method**

Follow `getNurseList` pattern at `core_apis.dart:470-492`:

```dart
  static Future<RxList<IcuUnit>> getIcuUnits({
    int page = 1,
    int perPage = 15,
    required List<IcuUnit> unitList,
    Function(bool)? lastPageCallBack,
    String search = "",
    String specialty = "",
    String availabilityStatus = "",
    int? caseTypeId,
    int? insuranceProviderId,
    bool? hasVentilator,
    double? priceMin,
    double? priceMax,
    String city = "",
    double? latitude,
    double? longitude,
    String sortBy = "",
  }) async {
    String params = '?per_page=$perPage&page=$page';
    if (search.isNotEmpty) params += '&search=$search';
    if (specialty.isNotEmpty) params += '&specialty=$specialty';
    if (availabilityStatus.isNotEmpty) params += '&availability_status=$availabilityStatus';
    if (caseTypeId != null) params += '&case_type_id=$caseTypeId';
    if (insuranceProviderId != null) params += '&insurance_provider_id=$insuranceProviderId';
    if (hasVentilator != null) params += '&has_ventilator=${hasVentilator ? 1 : 0}';
    if (priceMin != null) params += '&price_min=$priceMin';
    if (priceMax != null) params += '&price_max=$priceMax';
    if (city.isNotEmpty) params += '&city=$city';
    if (latitude != null && longitude != null) {
      params += '&latitude=$latitude&longitude=$longitude';
    }
    if (sortBy.isNotEmpty) params += '&sort_by=$sortBy';

    final res = IcuUnitListResponse.fromJson(await handleResponse(
      await buildHttpResponse("${APIEndPoints.icuUnits}$params", method: HttpMethodType.GET),
    ));
    if (page == 1) unitList.clear();
    unitList.addAll(res.data);
    lastPageCallBack?.call(res.data.length != perPage);
    return unitList.obs;
  }
```

- [ ] **Step 6: Add `getIcuUnitDetail()` method**

```dart
  static Future<IcuUnit> getIcuUnitDetail({required int unitId}) async {
    final json = await handleResponse(
      await buildHttpResponse('${APIEndPoints.icuUnits}/$unitId', method: HttpMethodType.GET),
    );
    return IcuUnit.fromJson(json["data"] is Map<String, dynamic> ? json["data"] : json);
  }
```

- [ ] **Step 7: Add `createAdmissionRequest()` multipart method**

Follow the `addIncident` pattern at `core_apis.dart:371-410`:

```dart
  static Future<dynamic> createAdmissionRequest({
    required Map<String, String> fields,
    List<File> files = const [],
    List<String> fileTypes = const [],
    Function(dynamic)? onSuccess,
  }) async {
    MultipartRequest multiPartRequest = await getMultiPartRequest(APIEndPoints.icuAdmissionRequests);

    multiPartRequest.fields.addAll(fields);

    for (int i = 0; i < files.length; i++) {
      if (files[i].existsSync()) {
        multiPartRequest.files.add(await MultipartFile.fromPath('files[$i]', files[i].path));
        multiPartRequest.fields['file_types[$i]'] = fileTypes[i];
      }
    }

    multiPartRequest.headers.addAll(buildHeaderTokens());

    await sendMultiPartRequest(
      multiPartRequest,
      onSuccess: (data) async {
        onSuccess?.call(data);
      },
      onError: (error) {
        throw error;
      },
    ).catchError((error) {
      throw error;
    });
  }
```

- [ ] **Step 8: Add `getAdmissionRequests()` paginated list method**

```dart
  static Future<RxList<AdmissionRequest>> getAdmissionRequests({
    int page = 1,
    int perPage = 15,
    required List<AdmissionRequest> requestList,
    Function(bool)? lastPageCallBack,
    String status = "",
  }) async {
    String statusParam = status.isNotEmpty ? '&status=$status' : '';

    final res = AdmissionRequestListResponse.fromJson(await handleResponse(
      await buildHttpResponse(
        "${APIEndPoints.icuAdmissionRequests}?per_page=$perPage&page=$page$statusParam",
        method: HttpMethodType.GET,
      ),
    ));
    if (page == 1) requestList.clear();
    requestList.addAll(res.data);
    lastPageCallBack?.call(res.data.length != perPage);
    return requestList.obs;
  }
```

- [ ] **Step 9: Add `getAdmissionRequestDetail()` method**

```dart
  static Future<AdmissionRequest> getAdmissionRequestDetail({required int requestId}) async {
    final json = await handleResponse(
      await buildHttpResponse('${APIEndPoints.icuAdmissionRequests}/$requestId', method: HttpMethodType.GET),
    );
    return AdmissionRequest.fromJson(json["data"] is Map<String, dynamic> ? json["data"] : json);
  }
```

- [ ] **Step 10: Add `cancelAdmissionRequest()` method**

```dart
  static Future<BaseResponseModel> cancelAdmissionRequest({required int requestId}) async {
    return BaseResponseModel.fromJson(
      await handleResponse(
        await buildHttpResponse('${APIEndPoints.icuAdmissionRequests}/$requestId/cancel', method: HttpMethodType.POST, request: {}),
      ),
    );
  }
```

- [ ] **Step 11: Verify compilation**

Run: `flutter analyze lib/utils/api_end_points.dart lib/api/core_apis.dart`
Expected: No new errors

- [ ] **Step 12: Commit**

```bash
git add lib/utils/api_end_points.dart lib/api/core_apis.dart
git commit -m "feat(icu): add API endpoints and service methods for ICU module"
```

---

## Task 3: Localization Keys

**Files:**
- Modify: `lib/locale/languages.dart`
- Modify: `lib/locale/language_en.dart`
- Modify: `lib/locale/language_ar.dart`
- Modify: `lib/locale/language_de.dart`
- Modify: `lib/locale/language_fr.dart`
- Modify: `lib/locale/language_hi.dart`

**Reference:** See existing nurse/lab test locale keys in each file for pattern. Abstract getters in `languages.dart`, concrete `@override String get` in each language file.

- [ ] **Step 1: Add abstract getters to `languages.dart`**

Add before the closing `}` of `BaseLanguage`:

```dart
  // ── ICU Module ──
  String get intensiveCare;
  String get icuSearch;
  String get myIcuRequests;
  String get searchForIcuBed;
  String get findAvailableIcuBeds;
  String get noIcuUnitsFound;
  String get noAdmissionRequests;
  String get caseType;
  String get selectCaseType;
  String get specialty;
  String get allSpecialties;
  String get cardiac;
  String get neurology;
  String get pediatrics;
  String get burns;
  String get chest;
  String get generalEmergency;
  String get filterResults;
  String get sortBy;
  String get sortByDistance;
  String get sortByPrice;
  String get ventilatorAvailable;
  String get isolationAvailable;
  String get equipmentLevel;
  String get equipmentBasic;
  String get equipmentAdvanced;
  String get equipmentComprehensive;
  String get priceRange;
  String get dailyPrice;
  String get icuAvailability;
  String get icuAvailable;
  String get lastBed;
  String get icuUnavailable;
  String get lastUpdated;
  String get bedsAvailable;
  String get totalBeds;
  String get requestAdmission;
  String get submitAdmissionRequest;
  String get patientInfo;
  String get patientName;
  String get patientAge;
  String get patientGender;
  String get caseDetails;
  String get initialDiagnosis;
  String get severityLevel;
  String get severityCritical;
  String get severitySerious;
  String get severityModerate;
  String get medicalRequirements;
  String get requiresOxygen;
  String get requiresVentilator;
  String get requiresIsolation;
  String get vitalSigns;
  String get heartRate;
  String get bloodPressure;
  String get oxygenSaturation;
  String get temperatureLabel;
  String get attachFiles;
  String get fileType;
  String get fileTypeImaging;
  String get fileTypeLabResult;
  String get fileTypeMedicalReport;
  String get fileTypePrescription;
  String get fileTypeOther;
  String get arrivalMethod;
  String get arrivalAmbulance;
  String get arrivalPrivateCar;
  String get insuranceProvider;
  String get selectInsurance;
  String get cashPayment;
  String get insuranceNumber;
  String get companionInfo;
  String get companionName;
  String get companionPhone;
  String get companionRelation;
  String get additionalNotes;
  String get admissionStatus;
  String get statusPending;
  String get statusAccepted;
  String get statusRejected;
  String get statusInfoRequested;
  String get statusRedirected;
  String get statusCancelled;
  String get hospitalResponse;
  String get admissionSubmittedSuccessfully;
  String get cancelRequest;
  String get confirmCancelRequest;
  String get requestCancelled;
  String get hospitalInfo;
  String get icuUnitDetails;
  String get acceptedInsurance;
  String get estimatedDailyPrice;
  String get requestAdmissionToThisUnit;
  String get pleaseEnterPatientName;
  String get pleaseEnterPatientAge;
  String get pleaseSelectCaseType;
  String get pleaseEnterDiagnosis;
  String get pleaseSelectSeverity;
  String get pleaseSelectArrivalMethod;
  String get pleaseEnterInsuranceNumber;
```

- [ ] **Step 2: Add English implementations to `language_en.dart`**

Add before the closing `}` of `LanguageEn`:

```dart
  // ── ICU Module ──
  @override String get intensiveCare => 'Intensive Care';
  @override String get icuSearch => 'ICU Search';
  @override String get myIcuRequests => 'My ICU Requests';
  @override String get searchForIcuBed => 'Search for ICU Bed';
  @override String get findAvailableIcuBeds => 'Find available ICU beds near you';
  @override String get noIcuUnitsFound => 'No ICU units found';
  @override String get noAdmissionRequests => 'No admission requests yet';
  @override String get caseType => 'Case Type';
  @override String get selectCaseType => 'Select Case Type';
  @override String get specialty => 'Specialty';
  @override String get allSpecialties => 'All Specialties';
  @override String get cardiac => 'Cardiac';
  @override String get neurology => 'Neurology';
  @override String get pediatrics => 'Pediatrics';
  @override String get burns => 'Burns';
  @override String get chest => 'Chest';
  @override String get generalEmergency => 'General Emergency';
  @override String get filterResults => 'Filter Results';
  @override String get sortBy => 'Sort By';
  @override String get sortByDistance => 'Distance';
  @override String get sortByPrice => 'Price';
  @override String get ventilatorAvailable => 'Ventilator Available';
  @override String get isolationAvailable => 'Isolation Available';
  @override String get equipmentLevel => 'Equipment Level';
  @override String get equipmentBasic => 'Basic';
  @override String get equipmentAdvanced => 'Advanced';
  @override String get equipmentComprehensive => 'Comprehensive';
  @override String get priceRange => 'Price Range';
  @override String get dailyPrice => 'Daily Price';
  @override String get icuAvailability => 'Availability';
  @override String get icuAvailable => 'Available';
  @override String get lastBed => 'Last Bed';
  @override String get icuUnavailable => 'Unavailable';
  @override String get lastUpdated => 'Last Updated';
  @override String get bedsAvailable => 'Beds Available';
  @override String get totalBeds => 'Total Beds';
  @override String get requestAdmission => 'Request Admission';
  @override String get submitAdmissionRequest => 'Submit Admission Request';
  @override String get patientInfo => 'Patient Information';
  @override String get patientName => 'Patient Name';
  @override String get patientAge => 'Patient Age';
  @override String get patientGender => 'Patient Gender';
  @override String get caseDetails => 'Case Details';
  @override String get initialDiagnosis => 'Initial Diagnosis';
  @override String get severityLevel => 'Severity Level';
  @override String get severityCritical => 'Critical';
  @override String get severitySerious => 'Serious';
  @override String get severityModerate => 'Moderate';
  @override String get medicalRequirements => 'Medical Requirements';
  @override String get requiresOxygen => 'Requires Oxygen';
  @override String get requiresVentilator => 'Requires Ventilator';
  @override String get requiresIsolation => 'Requires Isolation';
  @override String get vitalSigns => 'Vital Signs';
  @override String get heartRate => 'Heart Rate';
  @override String get bloodPressure => 'Blood Pressure';
  @override String get oxygenSaturation => 'O2 Saturation';
  @override String get temperatureLabel => 'Temperature';
  @override String get attachFiles => 'Attach Files';
  @override String get fileType => 'File Type';
  @override String get fileTypeImaging => 'Imaging';
  @override String get fileTypeLabResult => 'Lab Result';
  @override String get fileTypeMedicalReport => 'Medical Report';
  @override String get fileTypePrescription => 'Prescription';
  @override String get fileTypeOther => 'Other';
  @override String get arrivalMethod => 'Arrival Method';
  @override String get arrivalAmbulance => 'Ambulance';
  @override String get arrivalPrivateCar => 'Private Car';
  @override String get insuranceProvider => 'Insurance Provider';
  @override String get selectInsurance => 'Select Insurance';
  @override String get cashPayment => 'Cash Payment';
  @override String get insuranceNumber => 'Insurance Number';
  @override String get companionInfo => 'Companion Information';
  @override String get companionName => 'Companion Name';
  @override String get companionPhone => 'Companion Phone';
  @override String get companionRelation => 'Relation';
  @override String get additionalNotes => 'Additional Notes';
  @override String get admissionStatus => 'Admission Status';
  @override String get statusPending => 'Pending';
  @override String get statusAccepted => 'Accepted';
  @override String get statusRejected => 'Rejected';
  @override String get statusInfoRequested => 'Info Requested';
  @override String get statusRedirected => 'Redirected';
  @override String get statusCancelled => 'Cancelled';
  @override String get hospitalResponse => 'Hospital Response';
  @override String get admissionSubmittedSuccessfully => 'Admission request submitted successfully';
  @override String get cancelRequest => 'Cancel Request';
  @override String get confirmCancelRequest => 'Are you sure you want to cancel this admission request?';
  @override String get requestCancelled => 'Request cancelled successfully';
  @override String get hospitalInfo => 'Hospital Information';
  @override String get icuUnitDetails => 'ICU Unit Details';
  @override String get acceptedInsurance => 'Accepted Insurance';
  @override String get estimatedDailyPrice => 'Estimated Daily Price';
  @override String get requestAdmissionToThisUnit => 'Request Admission to this Unit';
  @override String get pleaseEnterPatientName => 'Please enter patient name';
  @override String get pleaseEnterPatientAge => 'Please enter patient age';
  @override String get pleaseSelectCaseType => 'Please select a case type';
  @override String get pleaseEnterDiagnosis => 'Please enter initial diagnosis';
  @override String get pleaseSelectSeverity => 'Please select severity level';
  @override String get pleaseSelectArrivalMethod => 'Please select arrival method';
  @override String get pleaseEnterInsuranceNumber => 'Please enter insurance number';
```

- [ ] **Step 3: Add Arabic implementations to `language_ar.dart`**

Same keys with Arabic translations. Follow existing Arabic patterns in the file. Use appropriate RTL medical terminology.

- [ ] **Step 4: Add German implementations to `language_de.dart`**

Same keys with German translations.

- [ ] **Step 5: Add French implementations to `language_fr.dart`**

Same keys with French translations.

- [ ] **Step 6: Add Hindi implementations to `language_hi.dart`**

Same keys with Hindi translations.

- [ ] **Step 7: Verify compilation**

Run: `flutter analyze lib/locale/`
Expected: No errors (all abstract getters have implementations in all language files)

- [ ] **Step 8: Commit**

```bash
git add lib/locale/
git commit -m "feat(icu): add localization keys for ICU module (5 languages)"
```

---

## Task 4: Reusable Components

**Files:**
- Create: `lib/screens/intensive_care/components/availability_badge.dart`
- Create: `lib/screens/intensive_care/components/severity_badge.dart`
- Create: `lib/screens/intensive_care/components/admission_status_badge.dart`
- Create: `lib/screens/intensive_care/components/equipment_indicator.dart`
- Create: `lib/screens/intensive_care/components/vital_signs_input.dart`
- Create: `lib/screens/intensive_care/components/admission_file_picker.dart`

**Reference:** `lib/screens/nurse/components/nurse_card.dart:226-275` for badge pattern. Use the project's Clinical Elegance design tokens from `lib/utils/colors.dart`.

- [ ] **Step 1: Create components directory**

```bash
mkdir -p lib/screens/intensive_care/components
```

- [ ] **Step 2: Create `availability_badge.dart`**

A colored chip showing Available (green) / Last Bed (amber) / Unavailable (red). Follow the `_buildAvailabilityBadge()` pattern from `nurse_card.dart:226-275` — gradient background, pulsing dot, bold label text.

Props: `String status` — maps to `available`, `last_bed`, `unavailable`.
Returns: Container with dot + text, color derived from status.

- [ ] **Step 3: Create `severity_badge.dart`**

Same badge pattern. Maps `critical` (red), `serious` (orange), `moderate` (blue).

Props: `String severity`

- [ ] **Step 4: Create `admission_status_badge.dart`**

Maps `pending` (amber), `accepted` (green), `rejected` (red), `info_requested` (blue), `redirected` (purple), `cancelled` (gray).

Props: `String status`

- [ ] **Step 5: Create `equipment_indicator.dart`**

A Row of icon chips showing ventilator and isolation capability.

Props: `bool hasVentilator`, `bool hasIsolation`, `String equipmentLevel`
Returns: Row with icon + label for each capability.

- [ ] **Step 6: Create `vital_signs_input.dart`**

Grouped input fields for heart rate, blood pressure, O2 saturation, and temperature. Uses `AppTextField` with appropriate keyboard types (number for HR/O2/temp, text for BP).

Props: `TextEditingController` for each field, optional `FocusNode` for each.
Returns: Column of 2x2 grid input fields with labels.

- [ ] **Step 7: Create `admission_file_picker.dart`**

Custom file picker that supports per-file type tagging. Shows a list of picked files, each with a dropdown for file type (Imaging/Lab Result/Medical Report/Prescription/Other) and a remove button.

**Important:** This file must `import 'dart:io';` for `File` type. Dart imports are NOT transitive.

Props: `RxList<File> files`, `RxList<String> fileTypes`, `VoidCallback onAddFile`
Returns: Column with "Add File" button + list of file items with type dropdown.

- [ ] **Step 8: Verify compilation**

Run: `flutter analyze lib/screens/intensive_care/components/`
Expected: No errors

- [ ] **Step 9: Commit**

```bash
git add lib/screens/intensive_care/components/
git commit -m "feat(icu): add reusable badge and input components"
```

---

## Task 5: ICU Unit Card & Admission Request Card

**Files:**
- Create: `lib/screens/intensive_care/components/icu_unit_card.dart`
- Create: `lib/screens/intensive_care/components/admission_request_card.dart`

**Reference:** `lib/screens/nurse/components/nurse_card.dart:57-275` for card layout pattern.

- [ ] **Step 1: Create `icu_unit_card.dart`**

Search result card showing:
- Hospital name + image (use `CachedImageWidget`)
- ICU unit name + specialty
- Availability badge (from Task 4)
- Equipment indicators (ventilator/isolation)
- Price range
- Distance (if available)
- `onTap` callback for navigation to detail

Follow the Stack-based overlapping layout from `nurse_card.dart`. Use the `_availabilityColor` getter pattern for left border accent color based on availability status.

Props: `IcuUnit unitData`, `VoidCallback onTap`

- [ ] **Step 2: Create `admission_request_card.dart`**

Request list card showing:
- Patient name + age + gender
- Case type name
- Severity badge
- Admission status badge
- Hospital/unit name
- Created date
- `onTap` callback

Props: `AdmissionRequest requestData`, `VoidCallback onTap`

- [ ] **Step 3: Verify compilation**

Run: `flutter analyze lib/screens/intensive_care/components/`
Expected: No errors

- [ ] **Step 4: Commit**

```bash
git add lib/screens/intensive_care/components/icu_unit_card.dart lib/screens/intensive_care/components/admission_request_card.dart
git commit -m "feat(icu): add ICU unit card and admission request card components"
```

---

## Task 6: ICU Search — Controller & Screen

**Files:**
- Create: `lib/screens/intensive_care/search/icu_search_controller.dart`
- Create: `lib/screens/intensive_care/search/icu_search_screen.dart`
- Create: `lib/screens/intensive_care/search/icu_filter_bottom_sheet.dart`

**Reference:** `lib/screens/nurse/nurse_list_controller.dart:1-77` for controller, `lib/screens/nurse/nurse_list_screen.dart:16-235` for screen, `lib/screens/booking/filter/components/clinic_filter/filter_clinic_component.dart` for filter bottom sheet.

- [ ] **Step 1: Create search directory**

```bash
mkdir -p lib/screens/intensive_care/search
```

- [ ] **Step 2: Create `icu_search_controller.dart`**

Follow `NurseListController` pattern:
- `Rx<Future<RxList<IcuUnit>>> unitFuture`
- `RxList<IcuUnit> units`
- `RxBool isLoading`, `RxBool isLastPage`, `RxInt page`
- `TextEditingController searchCont`
- Filter state: `RxString selectedSpecialty`, `RxString selectedAvailability`, `Rx<IcuCaseType?> selectedCaseType`, `RxBool filterVentilator`, `RxString sortBy`
- `RxList<IcuCaseType> caseTypes`, `RxList<InsuranceProvider> insuranceProviders` — fetched on init
- `getIcuUnits()` method calling `CoreServiceApis.getIcuUnits()`
- `loadCatalogData()` method to fetch case types and insurance providers
- Filter change methods that reset page and re-fetch

- [ ] **Step 3: Create `icu_search_screen.dart`**

Follow `nurse_list_screen.dart` pattern:
- `AppScaffoldNew` wrapper
- Search bar at top with `TextEditingController`
- Horizontal filter chips for specialties (All, Cardiac, Neurology, etc.)
- "More Filters" button that opens `IcuFilterBottomSheet`
- Sort dropdown (Distance / Price)
- `SnapHelperWidget` + `AnimatedScrollView` for results
- `IcuUnitCard` for each result with `onTap` navigating to `IcuUnitDetailScreen`
- `onNextPage` and `onSwipeRefresh` callbacks
- Empty state when no results

- [ ] **Step 4: Create `icu_filter_bottom_sheet.dart`**

Bottom sheet with:
- Case type dropdown (from `caseTypes` list)
- Ventilator required toggle
- Availability status chips (Available/Last Bed/Unavailable)
- Insurance provider dropdown
- Price range (min/max text fields)
- City text field
- Apply / Reset buttons
- Calls controller filter methods on apply

- [ ] **Step 5: Verify compilation**

Run: `flutter analyze lib/screens/intensive_care/search/`
Expected: No errors

- [ ] **Step 6: Commit**

```bash
git add lib/screens/intensive_care/search/
git commit -m "feat(icu): add ICU bed search screen with filters"
```

---

## Task 7: ICU Unit Detail — Controller & Screen

**Files:**
- Create: `lib/screens/intensive_care/search/icu_unit_detail_controller.dart`
- Create: `lib/screens/intensive_care/search/icu_unit_detail_screen.dart`

**Reference:** Nurse detail pattern. Screen shows full unit info with "Request Admission" CTA.

- [ ] **Step 1: Create `icu_unit_detail_controller.dart`**

- `Rx<Future<IcuUnit>> unitFuture`
- `Rx<IcuUnit> unit`
- `RxBool isLoading`
- `int unitId` passed via constructor
- `getUnitDetail()` calling `CoreServiceApis.getIcuUnitDetail()`

- [ ] **Step 2: Create `icu_unit_detail_screen.dart`**

Scrollable screen with:
- Hospital image header (CachedImageWidget, full width)
- Hospital name + address + distance
- Availability badge (prominent)
- Unit name + specialty
- Equipment indicator row
- Total beds count
- Daily price range display
- Accepted insurances list (chips)
- Supported case types list (chips)
- "Last updated" timestamp for availability
- **"Request Admission" gradient button** at bottom → navigates to `CreateAdmissionScreen(icuUnit: unit)`
- If availability is `unavailable`, show warning text above button but still allow submission

- [ ] **Step 3: Verify compilation**

Run: `flutter analyze lib/screens/intensive_care/search/`
Expected: No errors

- [ ] **Step 4: Commit**

```bash
git add lib/screens/intensive_care/search/icu_unit_detail_controller.dart lib/screens/intensive_care/search/icu_unit_detail_screen.dart
git commit -m "feat(icu): add ICU unit detail screen"
```

---

## Task 8: Create Admission — Controller & Screen

**Files:**
- Create: `lib/screens/intensive_care/admission/create_admission_controller.dart`
- Create: `lib/screens/intensive_care/admission/create_admission_screen.dart`

**Reference:** `lib/screens/incident_management/add_incident_management_screen.dart` for form + file upload pattern, `lib/screens/incident_management/incident_management_controller.dart` for controller pattern.

- [ ] **Step 1: Create admission directory**

```bash
mkdir -p lib/screens/intensive_care/admission
```

- [ ] **Step 2: Create `create_admission_controller.dart`**

- `IcuUnit icuUnit` — passed via constructor (pre-selected unit)
- TextEditingControllers: `patientNameCont`, `patientAgeCont`, `diagnosisCont`, `insuranceNumberCont`, `companionNameCont`, `companionPhoneCont`, `companionRelationCont`, `notesCont`
- TextEditingControllers for vitals: `heartRateCont`, `bpCont`, `o2SatCont`, `temperatureCont`
- Rx state: `RxString selectedGender`, `Rx<IcuCaseType?> selectedCaseType`, `RxString selectedSeverity`, `RxBool requiresOxygen/Ventilator/Isolation`, `RxString selectedArrivalMethod`, `RxBool useInsurance`, `Rx<InsuranceProvider?> selectedInsurance`
- `RxList<File> attachedFiles`, `RxList<String> attachedFileTypes` — **must `import 'dart:io';`**
- `RxBool isLoading`, `RxBool showVitalSigns`
- `RxList<IcuCaseType> caseTypes`, `RxList<InsuranceProvider> insuranceProviders`
- `loadCatalogData()` — fetch case types and insurance providers on init
- `pickFile()` — file picker, adds to `attachedFiles`, prompts for type
- `removeFile(int index)` — removes from both lists
- `submitRequest()` — validates, builds multipart fields map, calls `CoreServiceApis.createAdmissionRequest()`
- `dispose()` — cleanup all controllers

- [ ] **Step 3: Create `create_admission_screen.dart`**

Single scrollable form matching spec Section 3.4:

**Section 1 — Patient Info:**
- Patient name (`AppTextField`, required)
- Patient age (`AppTextField`, number keyboard, required)
- Gender radio group (Male/Female/Other) using existing `GenderTypeConst`

**Section 2 — Case Details:**
- Case type dropdown (from API list, required)
- Initial diagnosis (`AppTextField` multiline, required)
- Severity radio group (Critical/Serious/Moderate)

**Section 3 — Medical Requirements:**
- Three switch toggles (oxygen/ventilator/isolation)
- Expandable vital signs section using `VitalSignsInput` widget

**Section 4 — File Attachments:**
- `AdmissionFilePicker` widget

**Section 5 — Logistics:**
- Arrival method radio (Ambulance/Private Car)
- Insurance/Cash toggle
- Conditional insurance provider dropdown + number field

**Section 6 — Companion Info:**
- Optional fields (name, phone with country code, relation)

**Section 7 — Notes:**
- Optional text area

**Submit button** — gradient button at bottom, shows loader during submission.
On success: toast + navigate to `AdmissionDetailScreen`.

Wrap entire form in `Form(key: formKey)` with `GlobalKey<FormState>`.
Wrap screen in `Stack` with `LoaderWidget` overlay.

- [ ] **Step 4: Verify compilation**

Run: `flutter analyze lib/screens/intensive_care/admission/`
Expected: No errors

- [ ] **Step 5: Commit**

```bash
git add lib/screens/intensive_care/admission/create_admission_controller.dart lib/screens/intensive_care/admission/create_admission_screen.dart
git commit -m "feat(icu): add admission request creation form"
```

---

## Task 9: Admission List — Controller & Screen

**Files:**
- Create: `lib/screens/intensive_care/admission/admission_list_controller.dart`
- Create: `lib/screens/intensive_care/admission/admission_list_screen.dart`

**Reference:** `lib/screens/incident_management/incident_management_list_screen.dart:88-196` for chip-based filter tabs.

- [ ] **Step 1: Create `admission_list_controller.dart`**

Follow `NurseListController` pattern:
- `Rx<Future<RxList<AdmissionRequest>>> requestFuture`
- `RxList<AdmissionRequest> requests`
- `RxBool isLoading`, `RxBool isLastPage`, `RxInt page`
- `RxString selectedStatus` — filter by status (empty = all)
- Status filter list: `[{key: '', label: 'All'}, {key: 'pending', label: ...}, ...]`
- `getRequests()` calling `CoreServiceApis.getAdmissionRequests()`
- `onFilterChanged(String status)` — resets page, re-fetches

- [ ] **Step 2: Create `admission_list_screen.dart`**

- `AppScaffoldNew` wrapper
- Status filter chips at top (All / Pending / Accepted / Rejected / Info Requested / Redirected / Cancelled) — follow incident management chip pattern
- `SnapHelperWidget` + `AnimatedScrollView` for list
- `AdmissionRequestCard` for each item, `onTap` → `AdmissionDetailScreen`
- Pagination via `onNextPage` / `onSwipeRefresh`
- Empty state with `noAdmissionRequests` locale key

- [ ] **Step 3: Verify compilation**

Run: `flutter analyze lib/screens/intensive_care/admission/`
Expected: No errors

- [ ] **Step 4: Commit**

```bash
git add lib/screens/intensive_care/admission/admission_list_controller.dart lib/screens/intensive_care/admission/admission_list_screen.dart
git commit -m "feat(icu): add admission request list screen with status filters"
```

---

## Task 10: Admission Detail — Controller & Screen

**Files:**
- Create: `lib/screens/intensive_care/admission/admission_detail_controller.dart`
- Create: `lib/screens/intensive_care/admission/admission_detail_screen.dart`

- [ ] **Step 1: Create `admission_detail_controller.dart`**

- `Rx<Future<AdmissionRequest>> requestFuture`
- `Rx<AdmissionRequest> request`
- `RxBool isLoading`
- `int requestId` passed via constructor
- `getRequestDetail()` calling `CoreServiceApis.getAdmissionRequestDetail()`
- `cancelRequest()` — shows confirmation dialog, calls `CoreServiceApis.cancelAdmissionRequest()`, refreshes detail

- [ ] **Step 2: Create `admission_detail_screen.dart`**

Scrollable detail screen:
- **Status section:** Large admission status badge + responded timestamp (if any)
- **Hospital response section:** (visible only if `adminResponseNote` is not empty) Card with hospital response text, styled prominently
- **Patient info section:** Name, age, gender, severity badge
- **Case details section:** Case type, diagnosis text
- **Medical requirements:** Oxygen/ventilator/isolation indicators
- **Vital signs:** Display card (if provided)
- **Files section:** List of attached files with type labels and tap-to-open
- **Logistics:** Arrival method, insurance info
- **Companion info:** (if provided)
- **Notes:** (if provided)
- **Cancel button:** Visible only if status is `pending`. Red outlined button. Shows confirmation dialog before calling cancel.
- **ICU unit info:** Card showing unit name, hospital name, with tap to view unit detail

- [ ] **Step 3: Verify compilation**

Run: `flutter analyze lib/screens/intensive_care/admission/`
Expected: No errors

- [ ] **Step 4: Commit**

```bash
git add lib/screens/intensive_care/admission/admission_detail_controller.dart lib/screens/intensive_care/admission/admission_detail_screen.dart
git commit -m "feat(icu): add admission request detail screen"
```

---

## Task 11: Entry Point Screen (Tabs)

**Files:**
- Create: `lib/screens/intensive_care/intensive_care_controller.dart`
- Create: `lib/screens/intensive_care/intensive_care_screen.dart`

**Reference:** Use `DefaultTabController` + `TabBar` + `TabBarView` pattern.

- [ ] **Step 1: Create `intensive_care_controller.dart`**

Minimal controller:
- `RxInt currentTab = 0.obs`

- [ ] **Step 2: Create `intensive_care_screen.dart`**

- `AppScaffoldNew` with title `locale.value.intensiveCare`
- `DefaultTabController(length: 2)`
- `TabBar` with two tabs: ICU Search / My Requests
- `TabBarView` with:
  - Tab 0: `IcuSearchScreen()`
  - Tab 1: `AdmissionListScreen()`
- Style TabBar with project's gradient for selected indicator, `GoogleFonts.plusJakartaSans` for labels

- [ ] **Step 3: Verify compilation**

Run: `flutter analyze lib/screens/intensive_care/`
Expected: No errors

- [ ] **Step 4: Commit**

```bash
git add lib/screens/intensive_care/intensive_care_controller.dart lib/screens/intensive_care/intensive_care_screen.dart
git commit -m "feat(icu): add intensive care entry screen with tabs"
```

---

## Task 12: Home Screen Integration

**Files:**
- Modify: `lib/screens/home/components/quick_services_component.dart`

**Reference:** Lines 75-152 for service card pattern, lines 332-434 for request tile pattern. Follow the exact `_buildServiceCard` and `_buildRequestTile` method signatures.

- [ ] **Step 1: Add import**

Add at top of `quick_services_component.dart`:

```dart
import '../../intensive_care/intensive_care_screen.dart';
import '../../intensive_care/admission/admission_list_screen.dart';
```

- [ ] **Step 2: Add ICU service card**

In the `Row` children inside the `SingleChildScrollView` (around line 92), add after the last existing `_buildServiceCard`:

```dart
12.width,
_buildServiceCard(
  context,
  icon: Icons.local_hospital_rounded,
  label: locale.value.intensiveCare,
  gradient: const LinearGradient(
    colors: [Color(0xFFE53935), Color(0xFFFF7043), Color(0xFFFF8A65)],
    stops: [0.0, 0.5, 1.0],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  ),
  delayIndex: 3,  // adjust based on existing card count
  onTap: () {
    doIfLoggedIn(() {
      Get.to(() => IntensiveCareScreen());
    });
  },
),
```

- [ ] **Step 3: Add ICU request tile**

In the "My Requests" section (after existing `_buildRequestTile` entries), add:

```dart
8.height,
_buildRequestTile(
  context,
  icon: Icons.local_hospital_outlined,
  label: locale.value.myIcuRequests,
  accentColor: const Color(0xFFE53935),
  delayIndex: 3,  // adjust based on existing tile count
  onTap: () {
    doIfLoggedIn(() {
      Get.to(() => AdmissionListScreen());
    });
  },
),
```

- [ ] **Step 4: Verify compilation**

Run: `flutter analyze lib/screens/home/components/quick_services_component.dart`
Expected: No errors

- [ ] **Step 5: Commit**

```bash
git add lib/screens/home/components/quick_services_component.dart
git commit -m "feat(icu): integrate intensive care module into home screen"
```

---

## Task 13: Full Flutter Integration Test

- [ ] **Step 1: Run full analysis**

Run: `flutter analyze`
Expected: No new errors or warnings related to ICU module

- [ ] **Step 2: Run the app**

Run: `flutter run`
Verify:
- Home screen shows "Intensive Care" card and "My ICU Requests" tile
- Tapping "Intensive Care" opens the tabbed screen
- Search tab renders (will show empty state until backend is ready)
- My Requests tab renders empty state
- Navigation flow works: Search → Unit Detail → Create Admission form
- Form validates required fields
- All locale strings display correctly

- [ ] **Step 3: Commit any fixes**

```bash
git add -A
git commit -m "fix(icu): resolve integration issues from full app test"
```

---

## Task 14: Laravel — Database Migrations

**Files:**
- Create: `database/migrations/xxxx_create_icu_case_types_table.php`
- Create: `database/migrations/xxxx_create_insurance_providers_table.php`
- Create: `database/migrations/xxxx_create_icu_units_table.php`
- Create: `database/migrations/xxxx_create_icu_admission_requests_table.php`
- Create: `database/migrations/xxxx_create_icu_admission_files_table.php`

**Reference:** Spec Section 1.1 for exact column definitions.

- [ ] **Step 1: Generate migrations**

```bash
php artisan make:migration create_icu_case_types_table
php artisan make:migration create_insurance_providers_table
php artisan make:migration create_icu_units_table
php artisan make:migration create_icu_admission_requests_table
php artisan make:migration create_icu_admission_files_table
```

- [ ] **Step 2: Implement `icu_case_types` migration**

```php
Schema::create('icu_case_types', function (Blueprint $table) {
    $table->id();
    $table->string('name');
    $table->string('name_ar')->nullable();
    $table->text('description')->nullable();
    $table->string('icon')->nullable();
    $table->boolean('is_active')->default(true);
    $table->integer('sort_order')->default(0);
    $table->timestamps();
});
```

- [ ] **Step 3: Implement `insurance_providers` migration**

```php
Schema::create('insurance_providers', function (Blueprint $table) {
    $table->id();
    $table->string('name');
    $table->string('name_ar')->nullable();
    $table->string('logo')->nullable();
    $table->boolean('is_active')->default(true);
    $table->timestamps();
});
```

- [ ] **Step 4: Implement `icu_units` migration**

```php
Schema::create('icu_units', function (Blueprint $table) {
    $table->id();
    $table->foreignId('hospital_id')->constrained('clinics')->onDelete('cascade');
    $table->string('name');
    $table->string('specialty');
    $table->integer('total_beds');
    $table->boolean('has_ventilator')->default(false);
    $table->boolean('has_isolation')->default(false);
    $table->decimal('daily_price_min', 10, 2)->default(0);
    $table->decimal('daily_price_max', 10, 2)->default(0);
    $table->enum('availability_status', ['available', 'last_bed', 'unavailable'])->default('available');
    $table->timestamp('availability_updated_at')->nullable();
    $table->enum('equipment_level', ['basic', 'advanced', 'comprehensive'])->default('basic');
    $table->json('accepted_insurance_ids')->nullable();
    $table->json('case_type_ids')->nullable();
    $table->boolean('is_active')->default(true);
    $table->timestamps();
});
```

- [ ] **Step 5: Implement `icu_admission_requests` migration**

```php
Schema::create('icu_admission_requests', function (Blueprint $table) {
    $table->id();
    $table->foreignId('user_id')->constrained()->onDelete('cascade');
    $table->foreignId('icu_unit_id')->constrained('icu_units')->onDelete('cascade');
    $table->foreignId('case_type_id')->constrained('icu_case_types')->onDelete('cascade');
    $table->string('patient_name');
    $table->integer('patient_age');
    $table->enum('patient_gender', ['male', 'female', 'other']);
    $table->text('initial_diagnosis');
    $table->enum('severity_level', ['critical', 'serious', 'moderate']);
    $table->json('vital_signs')->nullable();
    $table->boolean('requires_oxygen')->default(false);
    $table->boolean('requires_ventilator')->default(false);
    $table->boolean('requires_isolation')->default(false);
    $table->string('companion_name')->nullable();
    $table->string('companion_phone')->nullable();
    $table->string('companion_relation')->nullable();
    $table->enum('arrival_method', ['ambulance', 'private_car']);
    $table->foreignId('insurance_provider_id')->nullable()->constrained('insurance_providers')->nullOnDelete();
    $table->string('insurance_number')->nullable();
    $table->text('notes')->nullable();
    $table->enum('status', ['pending', 'accepted', 'rejected', 'info_requested', 'redirected', 'cancelled'])->default('pending');
    $table->text('admin_response_note')->nullable();
    $table->timestamp('responded_at')->nullable();
    $table->timestamps();
});
```

- [ ] **Step 6: Implement `icu_admission_files` migration**

```php
Schema::create('icu_admission_files', function (Blueprint $table) {
    $table->id();
    $table->foreignId('admission_request_id')->constrained('icu_admission_requests')->onDelete('cascade');
    $table->string('file_path');
    $table->enum('file_type', ['imaging', 'lab_result', 'medical_report', 'prescription', 'other']);
    $table->string('original_name');
    $table->timestamps();
});
```

- [ ] **Step 7: Run migrations**

```bash
php artisan migrate
```
Expected: 5 tables created successfully

- [ ] **Step 8: Commit**

```bash
git add database/migrations/
git commit -m "feat(icu): add database migrations for ICU module (5 tables)"
```

---

## Task 15: Laravel — Eloquent Models

**Files:**
- Create: `app/Models/IcuCaseType.php`
- Create: `app/Models/InsuranceProvider.php`
- Create: `app/Models/IcuUnit.php`
- Create: `app/Models/AdmissionRequest.php`
- Create: `app/Models/AdmissionFile.php`

**Reference:** Spec Section 4.3 for relationships.

- [ ] **Step 1: Create all 5 models**

Each model needs:
- `$fillable` array matching migration columns
- `$casts` for JSON fields (`vital_signs`, `accepted_insurance_ids`, `case_type_ids`)
- Relationships as defined in spec Section 4.3
- `IcuUnit`: `belongsTo(Clinic)` via `hospital_id`, `hasMany(AdmissionRequest)`
- `AdmissionRequest`: `belongsTo(User)`, `belongsTo(IcuUnit)`, `belongsTo(IcuCaseType)`, `belongsTo(InsuranceProvider)`, `hasMany(AdmissionFile)`

- [ ] **Step 2: Commit**

```bash
git add app/Models/IcuCaseType.php app/Models/InsuranceProvider.php app/Models/IcuUnit.php app/Models/AdmissionRequest.php app/Models/AdmissionFile.php
git commit -m "feat(icu): add Eloquent models with relationships"
```

---

## Task 16: Laravel — Form Requests

**Files:**
- Create: `app/Http/Requests/Icu/SearchIcuUnitsRequest.php`
- Create: `app/Http/Requests/Icu/StoreAdmissionRequest.php`
- Create: `app/Http/Requests/Icu/UpdateAvailabilityRequest.php`
- Create: `app/Http/Requests/Icu/RespondAdmissionRequest.php`

**Reference:** Spec Section 6 (Validation & Edge Cases) for exact rules.

- [ ] **Step 1: Create all 4 form requests**

`StoreAdmissionRequest` is the largest — use exact validation rules from spec Section 6.

- [ ] **Step 2: Commit**

```bash
git add app/Http/Requests/Icu/
git commit -m "feat(icu): add form request validation classes"
```

---

## Task 17: Laravel — API Resources

**Files:**
- Create: `app/Http/Resources/Icu/IcuCaseTypeResource.php`
- Create: `app/Http/Resources/Icu/InsuranceProviderResource.php`
- Create: `app/Http/Resources/Icu/IcuUnitResource.php`
- Create: `app/Http/Resources/Icu/AdmissionRequestResource.php`
- Create: `app/Http/Resources/Icu/AdmissionFileResource.php`

**Reference:** Spec Section 2.2 response contracts for exact field shapes.

- [ ] **Step 1: Create all 5 resources**

`IcuUnitResource` is the most complex — includes nested `hospital`, `case_types`, `accepted_insurances`, and computed `distance_km`.

- [ ] **Step 2: Commit**

```bash
git add app/Http/Resources/Icu/
git commit -m "feat(icu): add API resource transformers"
```

---

## Task 18: Laravel — Distance Service

**Files:**
- Create: `app/Services/IcuDistanceService.php`

**Reference:** Spec Section 4.4 for Haversine SQL with JOIN through clinics table.

- [ ] **Step 1: Create `IcuDistanceService.php`**

Static method `applyDistanceSort($query, $latitude, $longitude)` that:
- JOINs `icu_units` with `clinics` table on `hospital_id`
- Applies Haversine formula with CAST for string lat/lng columns
- Adds `distance_km` as computed column
- Orders by distance

- [ ] **Step 2: Commit**

```bash
git add app/Services/IcuDistanceService.php
git commit -m "feat(icu): add Haversine distance calculation service"
```

---

## Task 19: Laravel — Controllers

**Files:**
- Create: `app/Http/Controllers/Api/V1/Icu/IcuCaseTypeController.php`
- Create: `app/Http/Controllers/Api/V1/Icu/InsuranceProviderController.php`
- Create: `app/Http/Controllers/Api/V1/Icu/IcuUnitController.php`
- Create: `app/Http/Controllers/Api/V1/Icu/AdmissionRequestController.php`
- Create: `app/Http/Controllers/Api/V1/Icu/AdminAdmissionController.php`

**Reference:** Spec Sections 2.1 and 4.2 for routes and controller methods.

- [ ] **Step 1: Create `IcuCaseTypeController`**

`index()` — return active case types ordered by `sort_order`.

- [ ] **Step 2: Create `InsuranceProviderController`**

`index()` — return active insurance providers.

- [ ] **Step 3: Create `IcuUnitController`**

- `index(SearchIcuUnitsRequest)` — search with filters, pagination, optional distance sort
- `show($id)` — unit detail with hospital eager-loaded
- `updateAvailability($id, UpdateAvailabilityRequest)` — admin updates status + timestamp

- [ ] **Step 4: Create `AdmissionRequestController`**

- `store(StoreAdmissionRequest)` — create request, handle file uploads, return detail
- `index()` — list authenticated user's requests with optional status filter, paginated
- `show($id)` — detail with eager-loaded relations
- `cancel($id)` — set status to `cancelled` if currently `pending`, else return 422

- [ ] **Step 5: Create `AdminAdmissionController`**

- `index()` — list requests for admin's hospital(s), paginated
- `respond($id, RespondAdmissionRequest)` — update status + `admin_response_note` + `responded_at`, trigger FCM notification

- [ ] **Step 6: Commit**

```bash
git add app/Http/Controllers/Api/V1/Icu/
git commit -m "feat(icu): add API controllers for ICU module"
```

---

## Task 20: Laravel — Routes & Notification

**Files:**
- Modify: `routes/api.php`
- Create: `app/Notifications/AdmissionStatusNotification.php`

- [ ] **Step 1: Add ICU routes to `routes/api.php`**

Add the route group from spec Section 4.2 — all 11 endpoints under `v1/icu` prefix with `auth:sanctum` middleware.

- [ ] **Step 2: Create `AdmissionStatusNotification`**

FCM push notification sent when admin responds to a request. Payload: `{admission_request_id, status, hospital_name}`. Follow existing notification patterns in the Laravel codebase.

- [ ] **Step 3: Run route list to verify**

```bash
php artisan route:list --path=v1/icu
```
Expected: 11 routes listed

- [ ] **Step 4: Commit**

```bash
git add routes/api.php app/Notifications/AdmissionStatusNotification.php
git commit -m "feat(icu): add API routes and admission status notification"
```

---

## Task 21: Laravel — Seed Data & Smoke Test

- [ ] **Step 1: Create seeder for test data**

Create `database/seeders/IcuSeeder.php` with:
- 5-7 case types (Stroke, Heart Attack, Post-Op, Ventilation, Neonatal, Burns, General Emergency)
- 3-4 insurance providers
- 2-3 ICU units linked to existing clinics

- [ ] **Step 2: Run seeder**

```bash
php artisan db:seed --class=IcuSeeder
```

- [ ] **Step 3: Smoke test API endpoints**

```bash
# Test catalog endpoints
curl -H "Authorization: Bearer {token}" https://espitalia.net/api/v1/icu/case-types
curl -H "Authorization: Bearer {token}" https://espitalia.net/api/v1/icu/insurance-providers

# Test search
curl -H "Authorization: Bearer {token}" "https://espitalia.net/api/v1/icu/units?page=1&per_page=15"

# Test unit detail
curl -H "Authorization: Bearer {token}" https://espitalia.net/api/v1/icu/units/1
```

Expected: JSON responses matching spec Section 2.2 contracts

- [ ] **Step 4: Commit**

```bash
git add database/seeders/IcuSeeder.php
git commit -m "feat(icu): add seed data and verify API endpoints"
```

---

## Task 22: End-to-End Integration Test

- [ ] **Step 1: Test full flow in the Flutter app**

With seeded backend data:
1. Open app → Home screen → tap "Intensive Care"
2. Search tab shows ICU units from backend
3. Apply filters (specialty, ventilator) — results update
4. Tap a unit → detail screen loads
5. Tap "Request Admission" → form opens with pre-selected unit
6. Fill form with test data, attach a file, submit
7. Toast shows success, navigates to detail
8. Go to "My Requests" tab → new request appears
9. View request detail → shows all submitted data
10. Cancel the pending request → status updates

- [ ] **Step 2: Fix any integration issues**

- [ ] **Step 3: Final commit**

```bash
git add -A
git commit -m "feat(icu): complete intensive care module — search, admission, availability"
```
