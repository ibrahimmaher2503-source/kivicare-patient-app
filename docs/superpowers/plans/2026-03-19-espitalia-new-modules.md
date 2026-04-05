# Espitalia New Modules Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add three new patient-facing modules — Request Nurse, Radiology & Lab Tests, and Request Service — to the Espitalia Flutter app, integrating with 22 new API endpoints.

**Architecture:** Each module follows the existing feature-first pattern: models in `screens/<feature>/model/`, controller as a GetxController in its own file, screens as StatelessWidgets using `Obx()`, API methods added to `CoreServiceApis`. New endpoints added to `APIEndPoints`. Localization strings added to all 5 language files.

**Tech Stack:** Flutter + GetX, `http` package via `buildHttpResponse()`, `nb_utils`, `google_fonts`, existing `AppScaffoldNew` and component library.

---

## File Structure

### New Files to Create

```
lib/
├── screens/
│   ├── nurse/
│   │   ├── model/
│   │   │   ├── nurse_model.dart                    # Nurse, NurseListResponse
│   │   │   └── nurse_request_model.dart            # NurseRequest, NurseRequestListResponse, NurseRequestAddress
│   │   ├── components/
│   │   │   ├── nurse_card.dart                     # Nurse catalog card widget
│   │   │   └── nurse_request_card.dart             # Nurse request list item card
│   │   ├── nurse_list_screen.dart                  # Browse nurses catalog
│   │   ├── nurse_detail_screen.dart                # Nurse profile detail
│   │   ├── nurse_list_controller.dart              # Controller for nurse catalog
│   │   ├── nurse_request_list_screen.dart          # My nurse requests list
│   │   ├── nurse_request_list_controller.dart       # Controller for nurse requests
│   │   ├── nurse_request_detail_screen.dart        # Single nurse request detail
│   │   ├── create_nurse_request_screen.dart        # Create/edit nurse request form
│   │   └── create_nurse_request_controller.dart    # Controller for create/edit form
│   ├── lab_test/
│   │   ├── model/
│   │   │   ├── lab_test_category_model.dart        # LabTestCategory, LabTestCategoryListResponse
│   │   │   ├── lab_test_model.dart                 # LabTest, LabTestListResponse
│   │   │   └── test_order_model.dart               # TestOrder, TestOrderItem, TestOrderListResponse
│   │   ├── components/
│   │   │   ├── lab_test_category_card.dart         # Category grid card
│   │   │   ├── lab_test_card.dart                  # Lab test list item
│   │   │   └── test_order_card.dart                # Test order list item
│   │   ├── lab_test_categories_screen.dart         # Browse categories
│   │   ├── lab_test_categories_controller.dart     # Controller for categories
│   │   ├── lab_test_list_screen.dart               # Browse lab tests (filterable)
│   │   ├── lab_test_list_controller.dart           # Controller for lab tests
│   │   ├── lab_test_detail_screen.dart             # Single lab test detail
│   │   ├── test_order_list_screen.dart             # My test orders list
│   │   ├── test_order_list_controller.dart         # Controller for test orders
│   │   ├── test_order_detail_screen.dart           # Single test order detail
│   │   ├── create_test_order_screen.dart           # Create test order (select tests)
│   │   └── create_test_order_controller.dart       # Controller for creating orders
│   └── request_service/
│       ├── model/
│       │   └── request_service_model.dart          # RequestService, RequestServiceListResponse
│       ├── components/
│       │   └── request_service_card.dart           # Service request list item
│       ├── request_service_list_screen.dart        # My service requests list
│       ├── request_service_list_controller.dart    # Controller for service requests
│       ├── create_request_service_screen.dart      # Create service request form
│       └── create_request_service_controller.dart  # Controller for create form
```

### Existing Files to Modify

```
lib/utils/api_end_points.dart          # Add 22 new endpoint constants
lib/api/core_apis.dart                 # Add API methods for all 3 modules
lib/screens/dashboard/components/menu.dart  # Add new BottomItem enum values (if adding tabs)
lib/screens/dashboard/dashboard_controller.dart  # Add new screens to tab list
lib/screens/home/home_screen.dart      # Add navigation cards/buttons for new modules
lib/locale/language_en.dart            # Add ~80 new English strings
lib/locale/language_ar.dart            # Add ~80 new Arabic strings
lib/locale/language_de.dart            # Add ~80 new German strings
lib/locale/language_fr.dart            # Add ~80 new French strings
lib/locale/language_hi.dart            # Add ~80 new Hindi strings
lib/locale/languages.dart              # Add ~80 new abstract string getters
lib/utils/colors.dart                  # Add status colors for new workflows
lib/utils/constants.dart               # Add status constants for nurse/lab/service
```

---

## Task 1: API Endpoints & Constants

**Files:**
- Modify: `lib/utils/api_end_points.dart`
- Modify: `lib/utils/constants.dart`
- Modify: `lib/utils/colors.dart`

- [ ] **Step 1: Add endpoint constants to `api_end_points.dart`**

Add these after the existing `//Indicent` section at line 71:

```dart
  //Nurse
  static const String getNurses = 'v1/nurses';
  static const String getNurseDetail = 'v1/nurses'; // append /{id}
  static const String getNurseRequests = 'v1/nurse-requests';
  static const String createNurseRequest = 'v1/nurse-requests';
  static const String getNurseRequestDetail = 'v1/nurse-requests'; // append /{id}
  static const String updateNurseRequest = 'v1/nurse-requests'; // append /{id}
  static const String cancelNurseRequest = 'v1/nurse-requests'; // append /{id}/cancel

  //Lab Tests
  static const String getLabTestCategories = 'v1/lab-test-categories';
  static const String getLabTests = 'v1/lab-tests';
  static const String getLabTestDetail = 'v1/lab-tests'; // append /{id}
  static const String getTestOrders = 'v1/test-orders';
  static const String createTestOrder = 'v1/test-orders';
  static const String getTestOrderDetail = 'v1/test-orders'; // append /{id}
  static const String cancelTestOrder = 'v1/test-orders'; // append /{id}/cancel
  static const String downloadTestReport = 'v1/test-orders'; // append /{id}/report/download

  //Request Service
  static const String saveRequestService = 'v1/save-request-service';
  static const String getRequestService = 'v1/get-request-service';
```

- [ ] **Step 2: Add status constants to `constants.dart`**

Add after the existing `StatusConst` class:

```dart
class NurseRequestStatusConst {
  static const String pending = 'pending';
  static const String confirmed = 'confirmed';
  static const String inProgress = 'in_progress';
  static const String completed = 'completed';
  static const String cancelled = 'cancelled';
}

class TestOrderStatusConst {
  static const String pending = 'pending';
  static const String confirmed = 'confirmed';
  static const String sampleCollected = 'sample_collected';
  static const String processing = 'processing';
  static const String completed = 'completed';
  static const String delivered = 'delivered';
  static const String cancelled = 'cancelled';
}

class TestOrderPriorityConst {
  static const String routine = 'routine';
  static const String urgent = 'urgent';
  static const String stat = 'stat';
}

class TestResultStatusConst {
  static const String normal = 'normal';
  static const String abnormal = 'abnormal';
  static const String critical = 'critical';
}

class ServiceRequestStatusConst {
  static const String pending = 'pending';
  static const String accept = 'accept';
  static const String reject = 'reject';
}

class NurseAvailabilityConst {
  static const String available = 'available';
  static const String busy = 'busy';
  static const String offDuty = 'off_duty';
}
```

- [ ] **Step 3: Add status colors to `colors.dart`**

Add after existing status colors:

```dart
// Nurse Request Status Colors
const nurseStatusPendingColor = Color(0xFFFF9800);
const nurseStatusConfirmedColor = Color(0xFF037F7C);
const nurseStatusInProgressColor = Color(0xFF2196F3);
const nurseStatusCompletedColor = Color(0xFF13BAAA);
const nurseStatusCancelledColor = Color(0xFFE53935);

// Lab Test Order Status Colors
const labStatusPendingColor = Color(0xFFFF9800);
const labStatusConfirmedColor = Color(0xFF037F7C);
const labStatusSampleCollectedColor = Color(0xFF7C4DFF);
const labStatusProcessingColor = Color(0xFF2196F3);
const labStatusCompletedColor = Color(0xFF13BAAA);
const labStatusDeliveredColor = Color(0xFF4CAF50);
const labStatusCancelledColor = Color(0xFFE53935);

// Test Result Status Colors
const resultNormalColor = Color(0xFF4CAF50);
const resultAbnormalColor = Color(0xFFFF9800);
const resultCriticalColor = Color(0xFFE53935);

// Nurse Availability Colors
const nurseAvailableColor = Color(0xFF4CAF50);
const nurseBusyColor = Color(0xFFFF9800);
const nurseOffDutyColor = Color(0xFF9E9E9E);

// Service Request Status Colors
const serviceStatusPendingColor = Color(0xFFFF9800);
const serviceStatusAcceptColor = Color(0xFF4CAF50);
const serviceStatusRejectColor = Color(0xFFE53935);
```

- [ ] **Step 4: Commit**

```bash
git add lib/utils/api_end_points.dart lib/utils/constants.dart lib/utils/colors.dart
git commit -m "feat: add API endpoints, status constants, and colors for nurse, lab test, and service modules"
```

---

## Task 2: Nurse Module — Models

**Files:**
- Create: `lib/screens/nurse/model/nurse_model.dart`
- Create: `lib/screens/nurse/model/nurse_request_model.dart`

- [ ] **Step 1: Create `nurse_model.dart`**

```dart
import 'package:get/get_rx/src/rx_types/rx_types.dart';

class NurseListResponse {
  bool status;
  List<Nurse> data;
  int currentPage;
  int lastPage;
  int perPage;
  int total;

  NurseListResponse({
    this.status = false,
    this.data = const [],
    this.currentPage = 1,
    this.lastPage = 1,
    this.perPage = 15,
    this.total = 0,
  });

  factory NurseListResponse.fromJson(Map<String, dynamic> json) {
    return NurseListResponse(
      status: json["status"] is bool ? json["status"] : false,
      data: json["data"] is List ? List<Nurse>.from(json["data"].map((x) => Nurse.fromJson(x))) : [],
      currentPage: json["meta"] is Map ? (json["meta"]["current_page"] ?? 1) : 1,
      lastPage: json["meta"] is Map ? (json["meta"]["last_page"] ?? 1) : 1,
      perPage: json["meta"] is Map ? (json["meta"]["per_page"] ?? 15) : 15,
      total: json["meta"] is Map ? (json["meta"]["total"] ?? 0) : 0,
    );
  }
}

class Nurse {
  int id;
  int nurseId;
  String name;
  String firstName;
  String lastName;
  String email;
  String mobile;
  String specialization;
  String experience;
  String about;
  double hourlyRate;
  String availabilityStatus;
  String serviceArea;
  String profileImage;
  bool status;
  String createdAt;
  String updatedAt;

  Nurse({
    this.id = -1,
    this.nurseId = -1,
    this.name = "",
    this.firstName = "",
    this.lastName = "",
    this.email = "",
    this.mobile = "",
    this.specialization = "",
    this.experience = "",
    this.about = "",
    this.hourlyRate = 0.0,
    this.availabilityStatus = "",
    this.serviceArea = "",
    this.profileImage = "",
    this.status = true,
    this.createdAt = "",
    this.updatedAt = "",
  });

  factory Nurse.fromJson(Map<String, dynamic> json) {
    return Nurse(
      id: json["id"] is int ? json["id"] : -1,
      nurseId: json["nurse_id"] is int ? json["nurse_id"] : -1,
      name: json["name"] is String ? json["name"] : "",
      firstName: json["first_name"] is String ? json["first_name"] : "",
      lastName: json["last_name"] is String ? json["last_name"] : "",
      email: json["email"] is String ? json["email"] : "",
      mobile: json["mobile"] is String ? json["mobile"] : "",
      specialization: json["specialization"] is String ? json["specialization"] : "",
      experience: json["experience"] is String ? json["experience"] : "",
      about: json["about"] is String ? json["about"] : "",
      hourlyRate: json["hourly_rate"] is num ? json["hourly_rate"].toDouble() : 0.0,
      availabilityStatus: json["availability_status"] is String ? json["availability_status"] : "",
      serviceArea: json["service_area"] is String ? json["service_area"] : "",
      profileImage: json["profile_image"] is String ? json["profile_image"] : "",
      status: json["status"] is bool ? json["status"] : true,
      createdAt: json["created_at"] is String ? json["created_at"] : "",
      updatedAt: json["updated_at"] is String ? json["updated_at"] : "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "nurse_id": nurseId,
      "name": name,
      "first_name": firstName,
      "last_name": lastName,
      "email": email,
      "mobile": mobile,
      "specialization": specialization,
      "experience": experience,
      "about": about,
      "hourly_rate": hourlyRate,
      "availability_status": availabilityStatus,
      "service_area": serviceArea,
      "profile_image": profileImage,
      "status": status,
      "created_at": createdAt,
      "updated_at": updatedAt,
    };
  }
}

class NurseListResult {
  final RxList<Nurse> nurses;

  NurseListResult({required this.nurses});
}
```

- [ ] **Step 2: Create `nurse_request_model.dart`**

```dart
import 'package:get/get_rx/src/rx_types/rx_types.dart';

class NurseRequestListResponse {
  bool status;
  List<NurseRequest> data;
  int currentPage;
  int lastPage;
  int perPage;
  int total;

  NurseRequestListResponse({
    this.status = false,
    this.data = const [],
    this.currentPage = 1,
    this.lastPage = 1,
    this.perPage = 15,
    this.total = 0,
  });

  factory NurseRequestListResponse.fromJson(Map<String, dynamic> json) {
    return NurseRequestListResponse(
      status: json["status"] is bool ? json["status"] : false,
      data: json["data"] is List ? List<NurseRequest>.from(json["data"].map((x) => NurseRequest.fromJson(x))) : [],
      currentPage: json["meta"] is Map ? (json["meta"]["current_page"] ?? 1) : 1,
      lastPage: json["meta"] is Map ? (json["meta"]["last_page"] ?? 1) : 1,
      perPage: json["meta"] is Map ? (json["meta"]["per_page"] ?? 15) : 15,
      total: json["meta"] is Map ? (json["meta"]["total"] ?? 0) : 0,
    );
  }
}

class NurseRequestPatient {
  int id;
  String name;
  String email;
  String mobile;

  NurseRequestPatient({this.id = -1, this.name = "", this.email = "", this.mobile = ""});

  factory NurseRequestPatient.fromJson(Map<String, dynamic> json) {
    return NurseRequestPatient(
      id: json["id"] is int ? json["id"] : -1,
      name: json["name"] is String ? json["name"] : "",
      email: json["email"] is String ? json["email"] : "",
      mobile: json["mobile"] is String ? json["mobile"] : "",
    );
  }

  Map<String, dynamic> toJson() => {"id": id, "name": name, "email": email, "mobile": mobile};
}

class NurseRequestNurse {
  int id;
  String name;
  String specialization;

  NurseRequestNurse({this.id = -1, this.name = "", this.specialization = ""});

  factory NurseRequestNurse.fromJson(Map<String, dynamic> json) {
    return NurseRequestNurse(
      id: json["id"] is int ? json["id"] : -1,
      name: json["name"] is String ? json["name"] : "",
      specialization: json["specialization"] is String ? json["specialization"] : "",
    );
  }

  Map<String, dynamic> toJson() => {"id": id, "name": name, "specialization": specialization};
}

class NurseRequestAddress {
  String addressLine1;
  String addressLine2;
  String city;
  String state;
  String country;
  String postalCode;
  double latitude;
  double longitude;
  String fullAddress;

  NurseRequestAddress({
    this.addressLine1 = "",
    this.addressLine2 = "",
    this.city = "",
    this.state = "",
    this.country = "",
    this.postalCode = "",
    this.latitude = 0.0,
    this.longitude = 0.0,
    this.fullAddress = "",
  });

  factory NurseRequestAddress.fromJson(Map<String, dynamic> json) {
    return NurseRequestAddress(
      addressLine1: json["address_line_1"] is String ? json["address_line_1"] : "",
      addressLine2: json["address_line_2"] is String ? json["address_line_2"] : "",
      city: json["city"] is String ? json["city"] : "",
      state: json["state"] is String ? json["state"] : "",
      country: json["country"] is String ? json["country"] : "",
      postalCode: json["postal_code"] is String ? json["postal_code"] : "",
      latitude: json["latitude"] is num ? json["latitude"].toDouble() : 0.0,
      longitude: json["longitude"] is num ? json["longitude"].toDouble() : 0.0,
      fullAddress: json["full_address"] is String ? json["full_address"] : "",
    );
  }

  Map<String, dynamic> toJson() => {
    "address_line_1": addressLine1,
    "address_line_2": addressLine2,
    "city": city,
    "state": state,
    "country": country,
    "postal_code": postalCode,
    "latitude": latitude,
    "longitude": longitude,
    "full_address": fullAddress,
  };
}

class NurseRequest {
  int id;
  NurseRequestPatient? patient;
  NurseRequestNurse? nurse;
  String serviceDescription;
  String requestDate;
  String preferredDate;
  String preferredTime;
  int durationHours;
  NurseRequestAddress? address;
  String contactNumber;
  String status;
  bool paymentStatus;
  double totalAmount;
  String patientNotes;
  String? adminNotes;
  String? cancelledBy;
  String? cancellationReason;
  String createdAt;
  String updatedAt;

  NurseRequest({
    this.id = -1,
    this.patient,
    this.nurse,
    this.serviceDescription = "",
    this.requestDate = "",
    this.preferredDate = "",
    this.preferredTime = "",
    this.durationHours = 0,
    this.address,
    this.contactNumber = "",
    this.status = "",
    this.paymentStatus = false,
    this.totalAmount = 0.0,
    this.patientNotes = "",
    this.adminNotes,
    this.cancelledBy,
    this.cancellationReason,
    this.createdAt = "",
    this.updatedAt = "",
  });

  factory NurseRequest.fromJson(Map<String, dynamic> json) {
    return NurseRequest(
      id: json["id"] is int ? json["id"] : -1,
      patient: json["patient"] is Map<String, dynamic> ? NurseRequestPatient.fromJson(json["patient"]) : null,
      nurse: json["nurse"] is Map<String, dynamic> ? NurseRequestNurse.fromJson(json["nurse"]) : null,
      serviceDescription: json["service_description"] is String ? json["service_description"] : "",
      requestDate: json["request_date"] is String ? json["request_date"] : "",
      preferredDate: json["preferred_date"] is String ? json["preferred_date"] : "",
      preferredTime: json["preferred_time"] is String ? json["preferred_time"] : "",
      durationHours: json["duration_hours"] is int ? json["duration_hours"] : 0,
      address: json["address"] is Map<String, dynamic> ? NurseRequestAddress.fromJson(json["address"]) : null,
      contactNumber: json["contact_number"] is String ? json["contact_number"] : "",
      status: json["status"] is String ? json["status"] : "",
      paymentStatus: json["payment_status"] is bool ? json["payment_status"] : false,
      totalAmount: json["total_amount"] is num ? json["total_amount"].toDouble() : 0.0,
      patientNotes: json["patient_notes"] is String ? json["patient_notes"] : "",
      adminNotes: json["admin_notes"] is String ? json["admin_notes"] : null,
      cancelledBy: json["cancelled_by"] is String ? json["cancelled_by"] : null,
      cancellationReason: json["cancellation_reason"] is String ? json["cancellation_reason"] : null,
      createdAt: json["created_at"] is String ? json["created_at"] : "",
      updatedAt: json["updated_at"] is String ? json["updated_at"] : "",
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "patient": patient?.toJson(),
    "nurse": nurse?.toJson(),
    "service_description": serviceDescription,
    "request_date": requestDate,
    "preferred_date": preferredDate,
    "preferred_time": preferredTime,
    "duration_hours": durationHours,
    "address": address?.toJson(),
    "contact_number": contactNumber,
    "status": status,
    "payment_status": paymentStatus,
    "total_amount": totalAmount,
    "patient_notes": patientNotes,
    "admin_notes": adminNotes,
    "cancelled_by": cancelledBy,
    "cancellation_reason": cancellationReason,
    "created_at": createdAt,
    "updated_at": updatedAt,
  };
}

class NurseRequestListResult {
  final RxList<NurseRequest> requests;

  NurseRequestListResult({required this.requests});
}
```

- [ ] **Step 3: Commit**

```bash
git add lib/screens/nurse/
git commit -m "feat: add nurse and nurse request data models"
```

---

## Task 3: Lab Test Module — Models

**Files:**
- Create: `lib/screens/lab_test/model/lab_test_category_model.dart`
- Create: `lib/screens/lab_test/model/lab_test_model.dart`
- Create: `lib/screens/lab_test/model/test_order_model.dart`

- [ ] **Step 1: Create `lab_test_category_model.dart`**

```dart
class LabTestCategoryListResponse {
  bool status;
  List<LabTestCategory> data;

  LabTestCategoryListResponse({this.status = false, this.data = const []});

  factory LabTestCategoryListResponse.fromJson(Map<String, dynamic> json) {
    return LabTestCategoryListResponse(
      status: json["status"] is bool ? json["status"] : false,
      data: json["data"] is List ? List<LabTestCategory>.from(json["data"].map((x) => LabTestCategory.fromJson(x))) : [],
    );
  }
}

class LabTestCategory {
  int id;
  String name;
  String slug;
  String description;
  String icon;
  int displayOrder;
  int testCount;
  bool status;

  LabTestCategory({
    this.id = -1,
    this.name = "",
    this.slug = "",
    this.description = "",
    this.icon = "",
    this.displayOrder = 0,
    this.testCount = 0,
    this.status = true,
  });

  factory LabTestCategory.fromJson(Map<String, dynamic> json) {
    return LabTestCategory(
      id: json["id"] is int ? json["id"] : -1,
      name: json["name"] is String ? json["name"] : "",
      slug: json["slug"] is String ? json["slug"] : "",
      description: json["description"] is String ? json["description"] : "",
      icon: json["icon"] is String ? json["icon"] : "",
      displayOrder: json["display_order"] is int ? json["display_order"] : 0,
      testCount: json["test_count"] is int ? json["test_count"] : 0,
      status: json["status"] is bool ? json["status"] : true,
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id, "name": name, "slug": slug, "description": description,
    "icon": icon, "display_order": displayOrder, "test_count": testCount, "status": status,
  };
}
```

- [ ] **Step 2: Create `lab_test_model.dart`**

```dart
import 'lab_test_category_model.dart';

class LabTestListResponse {
  bool status;
  List<LabTest> data;
  int currentPage;
  int lastPage;
  int perPage;
  int total;

  LabTestListResponse({
    this.status = false, this.data = const [],
    this.currentPage = 1, this.lastPage = 1, this.perPage = 15, this.total = 0,
  });

  factory LabTestListResponse.fromJson(Map<String, dynamic> json) {
    return LabTestListResponse(
      status: json["status"] is bool ? json["status"] : false,
      data: json["data"] is List ? List<LabTest>.from(json["data"].map((x) => LabTest.fromJson(x))) : [],
      currentPage: json["meta"] is Map ? (json["meta"]["current_page"] ?? 1) : 1,
      lastPage: json["meta"] is Map ? (json["meta"]["last_page"] ?? 1) : 1,
      perPage: json["meta"] is Map ? (json["meta"]["per_page"] ?? 15) : 15,
      total: json["meta"] is Map ? (json["meta"]["total"] ?? 0) : 0,
    );
  }
}

class LabTest {
  int id;
  String name;
  String code;
  String slug;
  LabTestCategory? category;
  String department;
  String sampleType;
  String description;
  String preparationInstructions;
  double defaultPrice;
  String turnaroundTime;
  bool status;

  LabTest({
    this.id = -1, this.name = "", this.code = "", this.slug = "",
    this.category, this.department = "", this.sampleType = "",
    this.description = "", this.preparationInstructions = "",
    this.defaultPrice = 0.0, this.turnaroundTime = "", this.status = true,
  });

  factory LabTest.fromJson(Map<String, dynamic> json) {
    return LabTest(
      id: json["id"] is int ? json["id"] : -1,
      name: json["name"] is String ? json["name"] : "",
      code: json["code"] is String ? json["code"] : "",
      slug: json["slug"] is String ? json["slug"] : "",
      category: json["category"] is Map<String, dynamic> ? LabTestCategory.fromJson(json["category"]) : null,
      department: json["department"] is String ? json["department"] : "",
      sampleType: json["sample_type"] is String ? json["sample_type"] : "",
      description: json["description"] is String ? json["description"] : "",
      preparationInstructions: json["preparation_instructions"] is String ? json["preparation_instructions"] : "",
      defaultPrice: json["default_price"] is num ? json["default_price"].toDouble() : 0.0,
      turnaroundTime: json["turnaround_time"] is String ? json["turnaround_time"] : "",
      status: json["status"] is bool ? json["status"] : true,
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id, "name": name, "code": code, "slug": slug,
    "category": category?.toJson(), "department": department,
    "sample_type": sampleType, "description": description,
    "preparation_instructions": preparationInstructions,
    "default_price": defaultPrice, "turnaround_time": turnaroundTime, "status": status,
  };
}
```

- [ ] **Step 3: Create `test_order_model.dart`**

```dart
import 'package:get/get_rx/src/rx_types/rx_types.dart';

class TestOrderListResponse {
  bool status;
  List<TestOrder> data;
  int currentPage;
  int lastPage;
  int perPage;
  int total;

  TestOrderListResponse({
    this.status = false, this.data = const [],
    this.currentPage = 1, this.lastPage = 1, this.perPage = 15, this.total = 0,
  });

  factory TestOrderListResponse.fromJson(Map<String, dynamic> json) {
    return TestOrderListResponse(
      status: json["status"] is bool ? json["status"] : false,
      data: json["data"] is List ? List<TestOrder>.from(json["data"].map((x) => TestOrder.fromJson(x))) : [],
      currentPage: json["meta"] is Map ? (json["meta"]["current_page"] ?? 1) : 1,
      lastPage: json["meta"] is Map ? (json["meta"]["last_page"] ?? 1) : 1,
      perPage: json["meta"] is Map ? (json["meta"]["per_page"] ?? 15) : 15,
      total: json["meta"] is Map ? (json["meta"]["total"] ?? 0) : 0,
    );
  }
}

class TestOrderPatient {
  int id;
  String name;
  String email;

  TestOrderPatient({this.id = -1, this.name = "", this.email = ""});

  factory TestOrderPatient.fromJson(Map<String, dynamic> json) {
    return TestOrderPatient(
      id: json["id"] is int ? json["id"] : -1,
      name: json["name"] is String ? json["name"] : "",
      email: json["email"] is String ? json["email"] : "",
    );
  }

  Map<String, dynamic> toJson() => {"id": id, "name": name, "email": email};
}

class TestOrderDoctor {
  int id;
  String name;

  TestOrderDoctor({this.id = -1, this.name = ""});

  factory TestOrderDoctor.fromJson(Map<String, dynamic> json) {
    return TestOrderDoctor(
      id: json["id"] is int ? json["id"] : -1,
      name: json["name"] is String ? json["name"] : "",
    );
  }

  Map<String, dynamic> toJson() => {"id": id, "name": name};
}

class TestOrderItemLabTest {
  int id;
  String name;
  String code;

  TestOrderItemLabTest({this.id = -1, this.name = "", this.code = ""});

  factory TestOrderItemLabTest.fromJson(Map<String, dynamic> json) {
    return TestOrderItemLabTest(
      id: json["id"] is int ? json["id"] : -1,
      name: json["name"] is String ? json["name"] : "",
      code: json["code"] is String ? json["code"] : "",
    );
  }

  Map<String, dynamic> toJson() => {"id": id, "name": name, "code": code};
}

class TestOrderItem {
  int id;
  TestOrderItemLabTest? labTest;
  double price;
  String status;
  String? resultValue;
  String? resultUnit;
  String? referenceRange;
  String? resultStatus;
  String? resultNotes;
  String? resultDate;

  TestOrderItem({
    this.id = -1, this.labTest, this.price = 0.0, this.status = "",
    this.resultValue, this.resultUnit, this.referenceRange,
    this.resultStatus, this.resultNotes, this.resultDate,
  });

  factory TestOrderItem.fromJson(Map<String, dynamic> json) {
    return TestOrderItem(
      id: json["id"] is int ? json["id"] : -1,
      labTest: json["lab_test"] is Map<String, dynamic> ? TestOrderItemLabTest.fromJson(json["lab_test"]) : null,
      price: json["price"] is num ? json["price"].toDouble() : 0.0,
      status: json["status"] is String ? json["status"] : "",
      resultValue: json["result_value"] is String ? json["result_value"] : null,
      resultUnit: json["result_unit"] is String ? json["result_unit"] : null,
      referenceRange: json["reference_range"] is String ? json["reference_range"] : null,
      resultStatus: json["result_status"] is String ? json["result_status"] : null,
      resultNotes: json["result_notes"] is String ? json["result_notes"] : null,
      resultDate: json["result_date"] is String ? json["result_date"] : null,
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id, "lab_test": labTest?.toJson(), "price": price, "status": status,
    "result_value": resultValue, "result_unit": resultUnit,
    "reference_range": referenceRange, "result_status": resultStatus,
    "result_notes": resultNotes, "result_date": resultDate,
  };
}

class TestOrder {
  int id;
  String orderNumber;
  TestOrderPatient? patient;
  TestOrderDoctor? doctor;
  dynamic labTechnician;
  List<TestOrderItem> items;
  String clinicalNotes;
  String priority;
  String orderDate;
  String status;
  String paymentStatus;
  double totalAmount;
  double discountAmount;
  double finalAmount;
  List<dynamic> reports;
  String createdAt;

  TestOrder({
    this.id = -1, this.orderNumber = "", this.patient, this.doctor,
    this.labTechnician, this.items = const [], this.clinicalNotes = "",
    this.priority = "", this.orderDate = "", this.status = "",
    this.paymentStatus = "", this.totalAmount = 0.0, this.discountAmount = 0.0,
    this.finalAmount = 0.0, this.reports = const [], this.createdAt = "",
  });

  factory TestOrder.fromJson(Map<String, dynamic> json) {
    return TestOrder(
      id: json["id"] is int ? json["id"] : -1,
      orderNumber: json["order_number"] is String ? json["order_number"] : "",
      patient: json["patient"] is Map<String, dynamic> ? TestOrderPatient.fromJson(json["patient"]) : null,
      doctor: json["doctor"] is Map<String, dynamic> ? TestOrderDoctor.fromJson(json["doctor"]) : null,
      labTechnician: json["lab_technician"],
      items: json["items"] is List ? List<TestOrderItem>.from(json["items"].map((x) => TestOrderItem.fromJson(x))) : [],
      clinicalNotes: json["clinical_notes"] is String ? json["clinical_notes"] : "",
      priority: json["priority"] is String ? json["priority"] : "",
      orderDate: json["order_date"] is String ? json["order_date"] : "",
      status: json["status"] is String ? json["status"] : "",
      paymentStatus: json["payment_status"] is String ? json["payment_status"] : "",
      totalAmount: json["total_amount"] is num ? json["total_amount"].toDouble() : 0.0,
      discountAmount: json["discount_amount"] is num ? json["discount_amount"].toDouble() : 0.0,
      finalAmount: json["final_amount"] is num ? json["final_amount"].toDouble() : 0.0,
      reports: json["reports"] is List ? json["reports"] : [],
      createdAt: json["created_at"] is String ? json["created_at"] : "",
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id, "order_number": orderNumber, "patient": patient?.toJson(),
    "doctor": doctor?.toJson(), "lab_technician": labTechnician,
    "items": items.map((x) => x.toJson()).toList(),
    "clinical_notes": clinicalNotes, "priority": priority,
    "order_date": orderDate, "status": status, "payment_status": paymentStatus,
    "total_amount": totalAmount, "discount_amount": discountAmount,
    "final_amount": finalAmount, "reports": reports, "created_at": createdAt,
  };
}

class TestOrderListResult {
  final RxList<TestOrder> orders;

  TestOrderListResult({required this.orders});
}
```

- [ ] **Step 4: Commit**

```bash
git add lib/screens/lab_test/
git commit -m "feat: add lab test category, lab test, and test order data models"
```

---

## Task 4: Request Service Module — Model

**Files:**
- Create: `lib/screens/request_service/model/request_service_model.dart`

- [ ] **Step 1: Create `request_service_model.dart`**

```dart
import 'package:get/get_rx/src/rx_types/rx_types.dart';

class RequestServiceListResponse {
  bool status;
  List<RequestService> data;
  int currentPage;
  int lastPage;
  int perPage;
  int total;

  RequestServiceListResponse({
    this.status = false, this.data = const [],
    this.currentPage = 1, this.lastPage = 1, this.perPage = 10, this.total = 0,
  });

  factory RequestServiceListResponse.fromJson(Map<String, dynamic> json) {
    return RequestServiceListResponse(
      status: json["status"] is bool ? json["status"] : false,
      data: json["data"] is List ? List<RequestService>.from(json["data"].map((x) => RequestService.fromJson(x))) : [],
      currentPage: json["meta"] is Map ? (json["meta"]["current_page"] ?? 1) : 1,
      lastPage: json["meta"] is Map ? (json["meta"]["last_page"] ?? 1) : 1,
      perPage: json["meta"] is Map ? (json["meta"]["per_page"] ?? 10) : 10,
      total: json["meta"] is Map ? (json["meta"]["total"] ?? 0) : 0,
    );
  }
}

class RequestService {
  int id;
  String name;
  String description;
  String type;
  int status;
  String isStatus;
  int createdBy;
  int? updatedBy;
  int? deletedBy;
  String createdAt;
  String updatedAt;
  String? deletedAt;

  RequestService({
    this.id = -1, this.name = "", this.description = "", this.type = "",
    this.status = 1, this.isStatus = "", this.createdBy = -1,
    this.updatedBy, this.deletedBy, this.createdAt = "", this.updatedAt = "", this.deletedAt,
  });

  factory RequestService.fromJson(Map<String, dynamic> json) {
    return RequestService(
      id: json["id"] is int ? json["id"] : -1,
      name: json["name"] is String ? json["name"] : "",
      description: json["description"] is String ? json["description"] : "",
      type: json["type"] is String ? json["type"] : "",
      status: json["status"] is int ? json["status"] : 1,
      isStatus: json["is_status"] is String ? json["is_status"] : "",
      createdBy: json["created_by"] is int ? json["created_by"] : -1,
      updatedBy: json["updated_by"] is int ? json["updated_by"] : null,
      deletedBy: json["deleted_by"] is int ? json["deleted_by"] : null,
      createdAt: json["created_at"] is String ? json["created_at"] : "",
      updatedAt: json["updated_at"] is String ? json["updated_at"] : "",
      deletedAt: json["deleted_at"] is String ? json["deleted_at"] : null,
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id, "name": name, "description": description, "type": type,
    "status": status, "is_status": isStatus, "created_by": createdBy,
    "updated_by": updatedBy, "deleted_by": deletedBy,
    "created_at": createdAt, "updated_at": updatedAt, "deleted_at": deletedAt,
  };
}

class RequestServiceListResult {
  final RxList<RequestService> services;

  RequestServiceListResult({required this.services});
}
```

- [ ] **Step 2: Commit**

```bash
git add lib/screens/request_service/
git commit -m "feat: add request service data model"
```

---

## Task 5: API Service Methods

**Files:**
- Modify: `lib/api/core_apis.dart`

- [ ] **Step 1: Add imports at the top of `core_apis.dart`**

Add after existing imports:

```dart
import '../screens/nurse/model/nurse_model.dart';
import '../screens/nurse/model/nurse_request_model.dart';
import '../screens/lab_test/model/lab_test_category_model.dart';
import '../screens/lab_test/model/lab_test_model.dart';
import '../screens/lab_test/model/test_order_model.dart';
import '../screens/request_service/model/request_service_model.dart';
```

- [ ] **Step 2: Add Nurse API methods inside `CoreServiceApis` class**

```dart
  // ===== NURSE MODULE =====

  static Future<RxList<Nurse>> getNurseList({
    int page = 1,
    int perPage = 15,
    required List<Nurse> nurseList,
    Function(bool)? lastPageCallBack,
    String search = "",
    String availabilityStatus = "",
    String serviceArea = "",
    String specialization = "",
  }) async {
    String searchParam = search.isNotEmpty ? '&search=$search' : '';
    String statusParam = availabilityStatus.isNotEmpty ? '&availability_status=$availabilityStatus' : '';
    String areaParam = serviceArea.isNotEmpty ? '&service_area=$serviceArea' : '';
    String specParam = specialization.isNotEmpty ? '&specialization=$specialization' : '';

    final res = NurseListResponse.fromJson(await handleResponse(
      await buildHttpResponse("${APIEndPoints.getNurses}?per_page=$perPage&page=$page$searchParam$statusParam$areaParam$specParam", method: HttpMethodType.GET),
    ));
    if (page == 1) nurseList.clear();
    nurseList.addAll(res.data);
    lastPageCallBack?.call(res.data.length != perPage);
    return nurseList.obs;
  }

  static Future<Nurse> getNurseDetail({required int nurseId}) async {
    final json = await handleResponse(await buildHttpResponse('${APIEndPoints.getNurseDetail}/$nurseId', method: HttpMethodType.GET));
    return Nurse.fromJson(json["data"] is Map<String, dynamic> ? json["data"] : json);
  }

  static Future<RxList<NurseRequest>> getNurseRequestList({
    int page = 1,
    int perPage = 15,
    required List<NurseRequest> requestList,
    Function(bool)? lastPageCallBack,
    String status = "",
    String search = "",
  }) async {
    String statusParam = status.isNotEmpty ? '&status=$status' : '';
    String searchParam = search.isNotEmpty ? '&search=$search' : '';

    final res = NurseRequestListResponse.fromJson(await handleResponse(
      await buildHttpResponse("${APIEndPoints.getNurseRequests}?per_page=$perPage&page=$page$statusParam$searchParam", method: HttpMethodType.GET),
    ));
    if (page == 1) requestList.clear();
    requestList.addAll(res.data);
    lastPageCallBack?.call(res.data.length != perPage);
    return requestList.obs;
  }

  static Future<NurseRequest> createNurseRequest({required Map<String, dynamic> request}) async {
    final json = await handleResponse(await buildHttpResponse(APIEndPoints.createNurseRequest, method: HttpMethodType.POST, request: request));
    return NurseRequest.fromJson(json["data"] is Map<String, dynamic> ? json["data"] : json);
  }

  static Future<NurseRequest> getNurseRequestDetail({required int requestId}) async {
    final json = await handleResponse(await buildHttpResponse('${APIEndPoints.getNurseRequestDetail}/$requestId', method: HttpMethodType.GET));
    return NurseRequest.fromJson(json["data"] is Map<String, dynamic> ? json["data"] : json);
  }

  static Future<NurseRequest> updateNurseRequest({required int requestId, required Map<String, dynamic> request}) async {
    final json = await handleResponse(await buildHttpResponse('${APIEndPoints.updateNurseRequest}/$requestId', method: HttpMethodType.PUT, request: request));
    return NurseRequest.fromJson(json["data"] is Map<String, dynamic> ? json["data"] : json);
  }

  static Future<BaseResponseModel> cancelNurseRequest({required int requestId, required Map<String, dynamic> request}) async {
    return BaseResponseModel.fromJson(await handleResponse(await buildHttpResponse('${APIEndPoints.cancelNurseRequest}/$requestId/cancel', method: HttpMethodType.POST, request: request)));
  }
```

- [ ] **Step 3: Add Lab Test API methods**

```dart
  // ===== LAB TEST MODULE =====

  static Future<List<LabTestCategory>> getLabTestCategories() async {
    final res = LabTestCategoryListResponse.fromJson(await handleResponse(
      await buildHttpResponse(APIEndPoints.getLabTestCategories, method: HttpMethodType.GET),
    ));
    return res.data;
  }

  static Future<RxList<LabTest>> getLabTestList({
    int page = 1,
    int perPage = 15,
    required List<LabTest> labTestList,
    Function(bool)? lastPageCallBack,
    int? categoryId,
    String department = "",
    String search = "",
  }) async {
    String catParam = (categoryId != null && categoryId != -1) ? '&category_id=$categoryId' : '';
    String deptParam = department.isNotEmpty ? '&department=$department' : '';
    String searchParam = search.isNotEmpty ? '&search=$search' : '';

    final res = LabTestListResponse.fromJson(await handleResponse(
      await buildHttpResponse("${APIEndPoints.getLabTests}?per_page=$perPage&page=$page$catParam$deptParam$searchParam", method: HttpMethodType.GET),
    ));
    if (page == 1) labTestList.clear();
    labTestList.addAll(res.data);
    lastPageCallBack?.call(res.data.length != perPage);
    return labTestList.obs;
  }

  static Future<LabTest> getLabTestDetail({required int testId}) async {
    final json = await handleResponse(await buildHttpResponse('${APIEndPoints.getLabTestDetail}/$testId', method: HttpMethodType.GET));
    return LabTest.fromJson(json["data"] is Map<String, dynamic> ? json["data"] : json);
  }

  static Future<RxList<TestOrder>> getTestOrderList({
    int page = 1,
    int perPage = 15,
    required List<TestOrder> orderList,
    Function(bool)? lastPageCallBack,
    String status = "",
  }) async {
    String statusParam = status.isNotEmpty ? '&status=$status' : '';

    final res = TestOrderListResponse.fromJson(await handleResponse(
      await buildHttpResponse("${APIEndPoints.getTestOrders}?per_page=$perPage&page=$page$statusParam", method: HttpMethodType.GET),
    ));
    if (page == 1) orderList.clear();
    orderList.addAll(res.data);
    lastPageCallBack?.call(res.data.length != perPage);
    return orderList.obs;
  }

  static Future<TestOrder> createTestOrder({required Map<String, dynamic> request}) async {
    final json = await handleResponse(await buildHttpResponse(APIEndPoints.createTestOrder, method: HttpMethodType.POST, request: request));
    return TestOrder.fromJson(json["data"] is Map<String, dynamic> ? json["data"] : json);
  }

  static Future<TestOrder> getTestOrderDetail({required int orderId}) async {
    final json = await handleResponse(await buildHttpResponse('${APIEndPoints.getTestOrderDetail}/$orderId', method: HttpMethodType.GET));
    return TestOrder.fromJson(json["data"] is Map<String, dynamic> ? json["data"] : json);
  }

  static Future<BaseResponseModel> cancelTestOrder({required int orderId, required Map<String, dynamic> request}) async {
    return BaseResponseModel.fromJson(await handleResponse(await buildHttpResponse('${APIEndPoints.cancelTestOrder}/$orderId/cancel', method: HttpMethodType.POST, request: request)));
  }

  static Future<Response> downloadTestReport({required int orderId}) async {
    return await buildHttpResponse('${APIEndPoints.downloadTestReport}/$orderId/report/download', method: HttpMethodType.GET);
  }
```

- [ ] **Step 4: Add Request Service API methods**

```dart
  // ===== REQUEST SERVICE MODULE =====

  static Future<RequestService> saveRequestService({required Map<String, dynamic> request}) async {
    final json = await handleResponse(await buildHttpResponse(APIEndPoints.saveRequestService, method: HttpMethodType.POST, request: request));
    return RequestService.fromJson(json["data"] is Map<String, dynamic> ? json["data"] : json);
  }

  static Future<RxList<RequestService>> getRequestServiceList({
    int page = 1,
    int perPage = 10,
    required List<RequestService> serviceList,
    Function(bool)? lastPageCallBack,
    String isStatus = "",
    String search = "",
  }) async {
    String statusParam = isStatus.isNotEmpty ? '&is_status=$isStatus' : '';
    String searchParam = search.isNotEmpty ? '&search=$search' : '';

    final res = RequestServiceListResponse.fromJson(await handleResponse(
      await buildHttpResponse("${APIEndPoints.getRequestService}?per_page=$perPage&page=$page$statusParam$searchParam", method: HttpMethodType.GET),
    ));
    if (page == 1) serviceList.clear();
    serviceList.addAll(res.data);
    lastPageCallBack?.call(res.data.length != perPage);
    return serviceList.obs;
  }
```

- [ ] **Step 5: Commit**

```bash
git add lib/api/core_apis.dart
git commit -m "feat: add API service methods for nurse, lab test, and request service modules"
```

---

## Task 6: Localization Strings

**Files:**
- Modify: `lib/locale/languages.dart`
- Modify: `lib/locale/language_en.dart`
- Modify: `lib/locale/language_ar.dart`
- Modify: `lib/locale/language_de.dart`
- Modify: `lib/locale/language_fr.dart`
- Modify: `lib/locale/language_hi.dart`

- [ ] **Step 1: Add abstract getters to `languages.dart`**

Add these at the end of the `BaseLanguage` class (before the closing `}`):

```dart
  // Nurse Module
  String get requestNurse;
  String get nurses;
  String get nurseDetails;
  String get browseNurses;
  String get myNurseRequests;
  String get createNurseRequest;
  String get editNurseRequest;
  String get serviceDescription;
  String get preferredDate;
  String get preferredTime;
  String get durationHours;
  String get contactNumber;
  String get patientNotes;
  String get selectNurse;
  String get hourlyRate;
  String get experience;
  String get specialization;
  String get serviceArea;
  String get availabilityStatus;
  String get nurseAvailable;
  String get nurseBusy;
  String get nurseOffDuty;
  String get nurseRequestSubmitted;
  String get nurseRequestUpdated;
  String get nurseRequestCancelled;
  String get cancellationReason;
  String get totalAmount;
  String get addressLine1;
  String get addressLine2;
  String get city;
  String get postalCode;
  String get nurseRequestPending;
  String get nurseRequestConfirmed;
  String get nurseRequestInProgress;
  String get nurseRequestCompleted;

  // Lab Test Module
  String get labTests;
  String get labTestCategories;
  String get labTestDetails;
  String get browseLabTests;
  String get myTestOrders;
  String get createTestOrder;
  String get testOrderDetails;
  String get orderNumber;
  String get clinicalNotes;
  String get priority;
  String get priorityRoutine;
  String get priorityUrgent;
  String get priorityStat;
  String get selectTests;
  String get addTest;
  String get removeTest;
  String get sampleType;
  String get preparationInstructions;
  String get turnaroundTime;
  String get defaultPrice;
  String get department;
  String get laboratory;
  String get radiology;
  String get testOrderCreated;
  String get testOrderCancelled;
  String get downloadReport;
  String get reportDownloaded;
  String get paymentStatus;
  String get orderDate;
  String get resultValue;
  String get resultStatus;
  String get resultNormal;
  String get resultAbnormal;
  String get resultCritical;
  String get sampleCollected;
  String get processing;
  String get delivered;
  String get referenceRange;
  String get testCount;

  // Request Service Module
  String get requestService;
  String get myServiceRequests;
  String get createServiceRequest;
  String get serviceName;
  String get serviceType;
  String get serviceRequestSubmitted;
  String get serviceStatusPending;
  String get serviceStatusAccepted;
  String get serviceStatusRejected;
```

- [ ] **Step 2: Add English translations to `language_en.dart`**

Add implementations for all the getters above with English values. Example pattern:

```dart
  // Nurse Module
  @override String get requestNurse => 'Request Nurse';
  @override String get nurses => 'Nurses';
  @override String get nurseDetails => 'Nurse Details';
  @override String get browseNurses => 'Browse Nurses';
  @override String get myNurseRequests => 'My Nurse Requests';
  @override String get createNurseRequest => 'Create Nurse Request';
  @override String get editNurseRequest => 'Edit Nurse Request';
  @override String get serviceDescription => 'Service Description';
  @override String get preferredDate => 'Preferred Date';
  @override String get preferredTime => 'Preferred Time';
  @override String get durationHours => 'Duration (Hours)';
  @override String get contactNumber => 'Contact Number';
  @override String get patientNotes => 'Patient Notes';
  @override String get selectNurse => 'Select Nurse';
  @override String get hourlyRate => 'Hourly Rate';
  @override String get experience => 'Experience';
  @override String get specialization => 'Specialization';
  @override String get serviceArea => 'Service Area';
  @override String get availabilityStatus => 'Availability';
  @override String get nurseAvailable => 'Available';
  @override String get nurseBusy => 'Busy';
  @override String get nurseOffDuty => 'Off Duty';
  @override String get nurseRequestSubmitted => 'Nurse request submitted successfully';
  @override String get nurseRequestUpdated => 'Nurse request updated successfully';
  @override String get nurseRequestCancelled => 'Nurse request cancelled successfully';
  @override String get cancellationReason => 'Cancellation Reason';
  @override String get totalAmount => 'Total Amount';
  @override String get addressLine1 => 'Address Line 1';
  @override String get addressLine2 => 'Address Line 2';
  @override String get city => 'City';
  @override String get postalCode => 'Postal Code';
  @override String get nurseRequestPending => 'Pending';
  @override String get nurseRequestConfirmed => 'Confirmed';
  @override String get nurseRequestInProgress => 'In Progress';
  @override String get nurseRequestCompleted => 'Completed';

  // Lab Test Module
  @override String get labTests => 'Lab Tests';
  @override String get labTestCategories => 'Test Categories';
  @override String get labTestDetails => 'Test Details';
  @override String get browseLabTests => 'Browse Lab Tests';
  @override String get myTestOrders => 'My Test Orders';
  @override String get createTestOrder => 'Create Test Order';
  @override String get testOrderDetails => 'Order Details';
  @override String get orderNumber => 'Order Number';
  @override String get clinicalNotes => 'Clinical Notes';
  @override String get priority => 'Priority';
  @override String get priorityRoutine => 'Routine';
  @override String get priorityUrgent => 'Urgent';
  @override String get priorityStat => 'STAT';
  @override String get selectTests => 'Select Tests';
  @override String get addTest => 'Add Test';
  @override String get removeTest => 'Remove Test';
  @override String get sampleType => 'Sample Type';
  @override String get preparationInstructions => 'Preparation Instructions';
  @override String get turnaroundTime => 'Turnaround Time';
  @override String get defaultPrice => 'Price';
  @override String get department => 'Department';
  @override String get laboratory => 'Laboratory';
  @override String get radiology => 'Radiology';
  @override String get testOrderCreated => 'Test order created successfully';
  @override String get testOrderCancelled => 'Test order cancelled successfully';
  @override String get downloadReport => 'Download Report';
  @override String get reportDownloaded => 'Report downloaded successfully';
  @override String get paymentStatus => 'Payment Status';
  @override String get orderDate => 'Order Date';
  @override String get resultValue => 'Result';
  @override String get resultStatus => 'Result Status';
  @override String get resultNormal => 'Normal';
  @override String get resultAbnormal => 'Abnormal';
  @override String get resultCritical => 'Critical';
  @override String get sampleCollected => 'Sample Collected';
  @override String get processing => 'Processing';
  @override String get delivered => 'Delivered';
  @override String get referenceRange => 'Reference Range';
  @override String get testCount => 'Tests';

  // Request Service Module
  @override String get requestService => 'Request Service';
  @override String get myServiceRequests => 'My Service Requests';
  @override String get createServiceRequest => 'Create Service Request';
  @override String get serviceName => 'Service Name';
  @override String get serviceType => 'Service Type';
  @override String get serviceRequestSubmitted => 'Service request submitted successfully';
  @override String get serviceStatusPending => 'Pending';
  @override String get serviceStatusAccepted => 'Accepted';
  @override String get serviceStatusRejected => 'Rejected';
```

- [ ] **Step 3: Add Arabic translations to `language_ar.dart`**

Same getters with Arabic values:

```dart
  @override String get requestNurse => 'طلب ممرضة';
  @override String get nurses => 'الممرضات';
  @override String get nurseDetails => 'تفاصيل الممرضة';
  @override String get browseNurses => 'تصفح الممرضات';
  @override String get myNurseRequests => 'طلبات الممرضات الخاصة بي';
  @override String get createNurseRequest => 'إنشاء طلب ممرضة';
  @override String get editNurseRequest => 'تعديل طلب الممرضة';
  @override String get serviceDescription => 'وصف الخدمة';
  @override String get preferredDate => 'التاريخ المفضل';
  @override String get preferredTime => 'الوقت المفضل';
  @override String get durationHours => 'المدة (ساعات)';
  @override String get contactNumber => 'رقم التواصل';
  @override String get patientNotes => 'ملاحظات المريض';
  @override String get selectNurse => 'اختيار ممرضة';
  @override String get hourlyRate => 'السعر بالساعة';
  @override String get experience => 'الخبرة';
  @override String get specialization => 'التخصص';
  @override String get serviceArea => 'منطقة الخدمة';
  @override String get availabilityStatus => 'الحالة';
  @override String get nurseAvailable => 'متاحة';
  @override String get nurseBusy => 'مشغولة';
  @override String get nurseOffDuty => 'خارج الخدمة';
  @override String get nurseRequestSubmitted => 'تم تقديم طلب الممرضة بنجاح';
  @override String get nurseRequestUpdated => 'تم تحديث طلب الممرضة بنجاح';
  @override String get nurseRequestCancelled => 'تم إلغاء طلب الممرضة بنجاح';
  @override String get cancellationReason => 'سبب الإلغاء';
  @override String get totalAmount => 'المبلغ الإجمالي';
  @override String get addressLine1 => 'العنوان السطر 1';
  @override String get addressLine2 => 'العنوان السطر 2';
  @override String get city => 'المدينة';
  @override String get postalCode => 'الرمز البريدي';
  @override String get nurseRequestPending => 'قيد الانتظار';
  @override String get nurseRequestConfirmed => 'مؤكد';
  @override String get nurseRequestInProgress => 'قيد التنفيذ';
  @override String get nurseRequestCompleted => 'مكتمل';
  @override String get labTests => 'الفحوصات المخبرية';
  @override String get labTestCategories => 'فئات الفحوصات';
  @override String get labTestDetails => 'تفاصيل الفحص';
  @override String get browseLabTests => 'تصفح الفحوصات';
  @override String get myTestOrders => 'طلبات الفحوصات الخاصة بي';
  @override String get createTestOrder => 'إنشاء طلب فحص';
  @override String get testOrderDetails => 'تفاصيل الطلب';
  @override String get orderNumber => 'رقم الطلب';
  @override String get clinicalNotes => 'ملاحظات سريرية';
  @override String get priority => 'الأولوية';
  @override String get priorityRoutine => 'روتيني';
  @override String get priorityUrgent => 'عاجل';
  @override String get priorityStat => 'طارئ';
  @override String get selectTests => 'اختيار الفحوصات';
  @override String get addTest => 'إضافة فحص';
  @override String get removeTest => 'إزالة فحص';
  @override String get sampleType => 'نوع العينة';
  @override String get preparationInstructions => 'تعليمات التحضير';
  @override String get turnaroundTime => 'وقت الإنجاز';
  @override String get defaultPrice => 'السعر';
  @override String get department => 'القسم';
  @override String get laboratory => 'مختبر';
  @override String get radiology => 'أشعة';
  @override String get testOrderCreated => 'تم إنشاء طلب الفحص بنجاح';
  @override String get testOrderCancelled => 'تم إلغاء طلب الفحص بنجاح';
  @override String get downloadReport => 'تحميل التقرير';
  @override String get reportDownloaded => 'تم تحميل التقرير بنجاح';
  @override String get paymentStatus => 'حالة الدفع';
  @override String get orderDate => 'تاريخ الطلب';
  @override String get resultValue => 'النتيجة';
  @override String get resultStatus => 'حالة النتيجة';
  @override String get resultNormal => 'طبيعي';
  @override String get resultAbnormal => 'غير طبيعي';
  @override String get resultCritical => 'حرج';
  @override String get sampleCollected => 'تم جمع العينة';
  @override String get processing => 'قيد المعالجة';
  @override String get delivered => 'تم التسليم';
  @override String get referenceRange => 'النطاق المرجعي';
  @override String get testCount => 'الفحوصات';
  @override String get requestService => 'طلب خدمة';
  @override String get myServiceRequests => 'طلبات الخدمة الخاصة بي';
  @override String get createServiceRequest => 'إنشاء طلب خدمة';
  @override String get serviceName => 'اسم الخدمة';
  @override String get serviceType => 'نوع الخدمة';
  @override String get serviceRequestSubmitted => 'تم تقديم طلب الخدمة بنجاح';
  @override String get serviceStatusPending => 'قيد الانتظار';
  @override String get serviceStatusAccepted => 'مقبول';
  @override String get serviceStatusRejected => 'مرفوض';
```

- [ ] **Step 4: Add placeholder translations for German, French, Hindi**

For `language_de.dart`, `language_fr.dart`, `language_hi.dart` — add the same getters with English values as placeholders (mark with `// TODO: translate` comment). These can be translated later.

- [ ] **Step 5: Commit**

```bash
git add lib/locale/
git commit -m "feat: add localization strings for nurse, lab test, and service request modules (EN + AR complete, DE/FR/HI placeholder)"
```

---

## Task 7: Nurse Module — Controllers & Screens

**Files:**
- Create: `lib/screens/nurse/nurse_list_controller.dart`
- Create: `lib/screens/nurse/nurse_list_screen.dart`
- Create: `lib/screens/nurse/nurse_detail_screen.dart`
- Create: `lib/screens/nurse/components/nurse_card.dart`
- Create: `lib/screens/nurse/nurse_request_list_controller.dart`
- Create: `lib/screens/nurse/nurse_request_list_screen.dart`
- Create: `lib/screens/nurse/nurse_request_detail_screen.dart`
- Create: `lib/screens/nurse/components/nurse_request_card.dart`
- Create: `lib/screens/nurse/create_nurse_request_controller.dart`
- Create: `lib/screens/nurse/create_nurse_request_screen.dart`

- [ ] **Step 1: Create nurse list controller**

Follow the `IncidentManagement` controller pattern from `incident_management_controller.dart`:
- `RxList<Nurse> nurses`, `RxBool isLoading`, `RxBool isLastPage`, `RxInt page`
- `Rx<Future<RxList<Nurse>>> nurseFuture`
- `getNurses()` method calling `CoreServiceApis.getNurseList()`
- Search text controller and filter state

- [ ] **Step 2: Create nurse card component**

Follow the `IncidentManagementCard` pattern:
- Display nurse name, specialization, experience, hourly rate, availability status badge
- Use `CachedImageWidget` for profile image
- `GestureDetector` navigating to `NurseDetailScreen`
- Use theme colors (`isDarkMode.value`, `appColorPrimary`, `GoogleFonts.plusJakartaSans`)

- [ ] **Step 3: Create nurse list screen**

Follow the `IncidentManagementListScreen` pattern exactly:
- `StatelessWidget` with `Get.put(NurseListController())`
- `AppScaffoldNew` wrapper
- `Obx()` + `SnapHelperWidget` for async data
- `AnimatedScrollView` with `onNextPage` for pagination and `onSwipeRefresh`
- Filter chips for availability status (All, Available, Busy, Off Duty)
- Search bar at top
- Empty state with Lottie animation

- [ ] **Step 4: Create nurse detail screen**

- `AppScaffoldNew` with nurse name as title
- Profile image hero section
- Info cards: specialization, experience, hourly rate, service area, about
- "Request This Nurse" button at bottom navigating to `CreateNurseRequestScreen` with pre-selected nurse

- [ ] **Step 5: Create nurse request list controller**

Same pattern as nurse list controller but for `NurseRequest`:
- Filter tabs: All, Pending, Confirmed, In Progress, Completed, Cancelled
- `getNurseRequests()` method calling `CoreServiceApis.getNurseRequestList()`

- [ ] **Step 6: Create nurse request card component**

- Display: nurse name, service description, preferred date/time, status badge, total amount
- Status badge colored per `NurseRequestStatusConst` + corresponding color
- Tap navigates to `NurseRequestDetailScreen`

- [ ] **Step 7: Create nurse request list screen**

Follow the `IncidentManagementListScreen` pattern:
- Status filter chips with gradient selection
- `AnimatedScrollView` with pagination
- FAB or app bar action to create new request
- Empty state when no requests

- [ ] **Step 8: Create nurse request detail screen**

- Full detail view with all fields from `NurseRequest`
- Status timeline/badge at top
- Nurse info section (if assigned)
- Address section with map link
- Action buttons: Edit (if pending), Cancel (if cancellable)
- Cancel shows confirmation dialog with reason text field

- [ ] **Step 9: Create nurse request form controller**

- TextEditingControllers for all form fields
- `RxBool isLoading`, `Rx<Nurse?> selectedNurse`
- `submitRequest()` and `updateRequest()` methods
- Form validation
- Date/time picker state
- Address fields with location picker integration

- [ ] **Step 10: Create nurse request form screen**

- Form with all required fields per API validation rules
- Date picker for preferred_date (after_or_equal: today)
- Time picker for preferred_time (24h format)
- Number input for duration_hours (1-24)
- Nurse selector (optional, navigates to nurse list to pick)
- Address fields with option to use current location
- Submit button calling controller method

- [ ] **Step 11: Commit**

```bash
git add lib/screens/nurse/
git commit -m "feat: add nurse catalog and nurse request screens with controllers"
```

---

## Task 8: Lab Test Module — Controllers & Screens

**Files:**
- Create all files listed under `lib/screens/lab_test/` in the File Structure section

- [ ] **Step 1: Create lab test categories controller and screen**

- Controller: Fetch categories via `CoreServiceApis.getLabTestCategories()` (non-paginated)
- Screen: Grid of category cards, each showing name, description, icon, test count
- Tap navigates to `LabTestListScreen` filtered by category

- [ ] **Step 2: Create lab test category card component**

- Icon display, category name, test count badge
- Gradient card background matching theme

- [ ] **Step 3: Create lab test list controller**

- Pagination, search, category filter, department filter (laboratory/radiology)
- `RxList<LabTest> labTests`, `getLabTests()` method

- [ ] **Step 4: Create lab test card component**

- Display: test name, code, department badge, sample type, price, turnaround time
- Tap navigates to detail screen

- [ ] **Step 5: Create lab test list screen**

- `AppScaffoldNew` with search bar
- Department filter chips (All, Laboratory, Radiology)
- Paginated list with `AnimatedScrollView`

- [ ] **Step 6: Create lab test detail screen**

- Full info: name, code, category, department, sample type, description, preparation instructions, price, turnaround time
- "Add to Order" button (navigates to create test order or adds to cart)

- [ ] **Step 7: Create test order list controller**

- Status filter tabs: All, Pending, Confirmed, Sample Collected, Processing, Completed, Delivered, Cancelled
- `RxList<TestOrder> orders`, pagination, `getTestOrders()` method

- [ ] **Step 8: Create test order card component**

- Display: order number, order date, status badge, item count, final amount, priority badge
- Status color from `labStatus*Color` constants

- [ ] **Step 9: Create test order list screen**

- Status filter chips, paginated list, FAB to create order
- Empty state

- [ ] **Step 10: Create test order detail screen**

- Order header: order number, date, status, priority
- Items list with result display (value, status badge colored normal/abnormal/critical, reference range)
- Financial summary: total, discount, final amount, payment status
- Action buttons: Cancel (if pending/confirmed), Download Report (if completed/delivered)
- PDF download using `CoreServiceApis.downloadTestReport()` and save to device

- [ ] **Step 11: Create test order form controller**

- `RxList<LabTest> selectedTests` (cart of tests to order)
- `addTest()`, `removeTest()` methods
- Clinical notes text controller
- Priority selection (routine/urgent/stat)
- `submitOrder()` method building `items` array

- [ ] **Step 12: Create test order form screen**

- Test selector: button to browse/search lab tests and add to order
- Selected tests list with remove option and price display
- Clinical notes text field
- Priority dropdown
- Order summary with total calculation
- Submit button

- [ ] **Step 13: Commit**

```bash
git add lib/screens/lab_test/
git commit -m "feat: add lab test catalog, categories, and test order screens with controllers"
```

---

## Task 9: Request Service Module — Controllers & Screens

**Files:**
- Create all files under `lib/screens/request_service/` in the File Structure section

- [ ] **Step 1: Create request service list controller**

- `RxList<RequestService> services`, pagination, status filter, search
- Filter tabs: All, Pending, Accepted, Rejected
- `getServiceRequests()` method

- [ ] **Step 2: Create request service card component**

- Display: service name, type, status badge, created date
- Status colored per `serviceStatus*Color`

- [ ] **Step 3: Create request service list screen**

- Status filter chips, paginated list, FAB to create
- Empty state

- [ ] **Step 4: Create request service form controller**

- TextEditingControllers for name, description, type
- `submitRequest()` method
- Form validation (name is required)

- [ ] **Step 5: Create request service form screen**

- Simple form: name (required), description (optional), type (optional)
- Submit button

- [ ] **Step 6: Commit**

```bash
git add lib/screens/request_service/
git commit -m "feat: add request service screens with create form and list"
```

---

## Task 10: Navigation Integration

**Files:**
- Modify: `lib/screens/home/home_screen.dart`
- Modify: `lib/screens/dashboard/components/menu.dart` (if adding bottom nav items)
- Modify: `lib/screens/dashboard/dashboard_controller.dart` (if adding bottom nav items)

- [ ] **Step 1: Add service cards to home screen**

Add navigation cards/tiles to the home screen for the 3 new modules:
- "Request Nurse" card → navigates to `NurseListScreen`
- "Lab Tests" card → navigates to `LabTestCategoriesScreen`
- "Request Service" card → navigates to `RequestServiceListScreen`

Each card should use `GestureDetector` with `Get.to()` and be wrapped in `doIfLoggedIn()` since all endpoints are authenticated.

Use the existing home screen card pattern (gradient cards with icons).

- [ ] **Step 2: Add "My Requests" quick links**

Add quick-access links on the home screen or profile screen for:
- "My Nurse Requests" → `NurseRequestListScreen`
- "My Test Orders" → `TestOrderListScreen`
- "My Service Requests" → `RequestServiceListScreen`

- [ ] **Step 3: Commit**

```bash
git add lib/screens/home/ lib/screens/dashboard/
git commit -m "feat: integrate nurse, lab test, and service request modules into home navigation"
```

---

## Task 11: PDF Report Download Handler

**Files:**
- Modify: `lib/screens/lab_test/test_order_detail_screen.dart` (already created in Task 8)

- [ ] **Step 1: Implement PDF download and viewing**

In the test order detail screen, implement the download report button:

```dart
Future<void> downloadReport(int orderId, String orderNumber) async {
  isLoading(true);
  try {
    final response = await CoreServiceApis.downloadTestReport(orderId: orderId);
    if (response.statusCode == 200) {
      final bytes = response.bodyBytes;
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/LAB-REPORT-$orderNumber.pdf');
      await file.writeAsBytes(bytes);
      toast(locale.value.reportDownloaded);
      // Open PDF using existing pattern or url_launcher
      OpenFile.open(file.path);
    }
  } catch (e) {
    toast(e.toString());
  } finally {
    isLoading(false);
  }
}
```

Add `path_provider` and `open_file` to pubspec.yaml if not already present (check existing dependencies first — `path` is already a dependency).

- [ ] **Step 2: Commit**

```bash
git add lib/screens/lab_test/test_order_detail_screen.dart pubspec.yaml
git commit -m "feat: implement PDF report download for test orders"
```

---

## Task 12: Final Integration & Smoke Test

- [ ] **Step 1: Run `flutter analyze`**

```bash
cd C:\Users\berog\StudioProjects\kivicare-laravel-patient-flutter-app-v1.8.1
flutter analyze
```

Fix any analysis errors or warnings.

- [ ] **Step 2: Run the app**

```bash
flutter run
```

Verify:
- Home screen shows navigation cards for all 3 modules
- Nurse list loads and paginates
- Nurse detail screen displays correctly
- Nurse request form validates and submits
- Lab test categories load
- Lab test list filters by category and department
- Test order form allows selecting tests and submitting
- Test order list shows with status filters
- Service request form submits
- Service request list loads with status filters
- All screens handle loading, empty, and error states
- Dark mode renders correctly on all new screens

- [ ] **Step 3: Fix any issues found during testing**

- [ ] **Step 4: Final commit**

```bash
git add .
git commit -m "fix: resolve integration issues and polish new module screens"
```

---

## Implementation Notes

### Key Patterns to Follow
1. **API calls**: Use `buildHttpResponse()` from `network_utils.dart` — never use `http` package directly
2. **Model parsing**: Always use `json["field"] is Type ? json["field"] : defaultValue` pattern for null safety
3. **Screen structure**: `StatelessWidget` + `Get.put(Controller())` + `Obx()` wrapping `AppScaffoldNew`
4. **Loading state**: `RxBool isLoading` + `LoaderWidget()` + `.whenComplete(() => isLoading(false))`
5. **Pagination**: `onNextPage` in `AnimatedScrollView`, `lastPageCallBack` in API methods
6. **Localization**: All user-facing strings via `locale.value.<key>`, never hardcoded
7. **Navigation**: `Get.to(() => Screen())`, wrap authenticated routes with `doIfLoggedIn()`
8. **Styling**: `GoogleFonts.plusJakartaSans()` for body, `GoogleFonts.outfit()` for headings, `isDarkMode.value` checks

### Dependencies Check
- No new packages needed except possibly `open_file` for PDF viewing (check if `url_launcher` suffices)
- `path_provider` may be needed for file storage — check if already in pubspec.yaml
