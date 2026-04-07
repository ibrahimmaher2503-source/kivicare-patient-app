# QuickStart: Integration Patterns

**Feature**: Labs & Radiology Booking System
**Branch**: `012-labs-radiology-bookings`
**Date**: 2026-04-05

---

## Overview

This feature integrates with the existing Espitalia Patient App ecosystem. It uses established patterns for authentication, networking, state management, and localization. Minimal new infrastructure required.

---

## 1. API Service Layer Integration

### Pattern: buildHttpResponse Pattern

All API calls follow the existing Espitalia pattern in `lib/network/network_utils.dart`.

**File**: `lib/api/lab_test_apis.dart`

```dart
import 'package:kivicare_patient/network/network_utils.dart';
import 'package:kivicare_patient/utils/api_end_points.dart';

class LabTestAPIs {
  // Get lab test categories (public endpoint)
  static Future<ResponseModel> getLabTestCategories() async {
    return await buildHttpResponse(
      APIEndPoints.labTestCategories,  // ADD TO api_end_points.dart
      method: HttpMethodType.GET,
    ).then((response) {
      return ResponseModel.fromJson(handleResponse(response));
    }).catchError((e) {
      throw e;
    });
  }

  // Get lab tests (public, with filtering)
  static Future<ResponseModel> getLabTests({
    required String? categoryId,
    required String? department,
    required String? search,
    required int page,
  }) async {
    Map<String, dynamic> queryParams = {};
    if (categoryId != null) queryParams['category_id'] = categoryId;
    if (department != null) queryParams['department'] = department;
    if (search != null) queryParams['search'] = search;
    queryParams['page'] = page;
    queryParams['per_page'] = 15;

    return await buildHttpResponse(
      APIEndPoints.labTests,  // ADD TO api_end_points.dart
      method: HttpMethodType.GET,
      queryParameters: queryParams,
    ).then((response) {
      return ResponseModel.fromJson(handleResponse(response));
    }).catchError((e) {
      throw e;
    });
  }

  // Create test order (authenticated)
  static Future<ResponseModel> createTestOrder({
    required Map request,
  }) async {
    return await buildHttpResponse(
      APIEndPoints.testOrders,  // ADD TO api_end_points.dart
      method: HttpMethodType.POST,
      request: request,
    ).then((response) {
      return ResponseModel.fromJson(handleResponse(response));
    }).catchError((e) {
      throw e;
    });
  }
}
```

### API Endpoint Additions

Add these constants to `lib/utils/api_end_points.dart`:

```dart
class APIEndPoints {
  // Lab Test Catalog (public)
  static const String labTestCategories = '$baseUrl/lab-test-categories';
  static const String labTests = '$baseUrl/lab-tests';

  // Test Orders (authenticated)
  static const String testOrders = '$baseUrl/test-orders';
  static const String testOrderDetail(int id) => '$testOrders/$id';
  static const String testOrderCancel(int id) => '$testOrders/$id/cancel';
  static const String testOrderReportDownload(int id) => '$testOrders/$id/report/download';

  // Facility Bookings (authenticated)
  static const String facilityBookings = '$baseUrl/facility-bookings';
  static const String facilityBookingDetail(int id) => '$facilityBookings/$id';
  static const String facilityBookingCancel(int id) => '$facilityBookings/$id/cancel';
  static const String labSlots(int labId) => '$facilityBookings/labs/$labId/slots';
  static const String radiologyCenterSlots(int centerId) => '$facilityBookings/radiology-centers/$centerId/slots';
}
```

---

## 2. State Management: GetX Controllers

### Lab Test Listing Controller

**File**: `lib/screens/lab_test/lab_test_categories_controller.dart`

```dart
import 'package:get/get.dart';
import 'package:kivicare_patient/api/lab_test_apis.dart';

class LabTestCategoriesController extends GetxController {
  RxBool isLoading = false.obs;
  RxList<LabTestCategory> categories = <LabTestCategory>[].obs;
  RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadCategories();
  }

  Future<void> loadCategories() async {
    isLoading(true);
    errorMessage('');

    try {
      final response = await LabTestAPIs.getLabTestCategories();

      if (response.statusCode == 1) {
        categories.assignAll(
          List.from(response.data ?? [])
              .map((c) => LabTestCategory.fromJson(c))
              .toList(),
        );
      } else {
        errorMessage(response.message ?? 'Failed to load categories');
      }
    } catch (e) {
      errorMessage(e.toString());
    } finally {
      isLoading(false);
    }
  }
}
```

### Pattern: Observable State

```dart
// Mutable state
RxBool isLoading = false.obs;
RxString selectedCategoryId = ''.obs;
RxList<LabTest> tests = <LabTest>[].obs;

// Update state
isLoading(true);  // triggers UI rebuild

// Watch changes
ever(selectedCategoryId, (categoryId) {
  filterTestsByCategory(categoryId);
});
```

---

## 3. Model Classes

### Auto-Generated from JSON Responses

Use existing pattern in `lib/models/` or co-locate with screens.

```dart
class LabTestCategory {
  final int id;
  final String name;
  final String slug;
  final String description;
  final String icon;
  final int displayOrder;
  final int testCount;
  final int status;

  LabTestCategory({
    required this.id,
    required this.name,
    required this.slug,
    required this.description,
    required this.icon,
    required this.displayOrder,
    required this.testCount,
    required this.status,
  });

  factory LabTestCategory.fromJson(Map<String, dynamic> json) {
    return LabTestCategory(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      description: json['description'] ?? '',
      icon: json['icon'] ?? '',
      displayOrder: json['display_order'] ?? 0,
      testCount: json['test_count'] ?? 0,
      status: json['status'] ?? 1,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'slug': slug,
    'description': description,
    'icon': icon,
    'display_order': displayOrder,
    'test_count': testCount,
    'status': status,
  };
}
```

---

## 4. Authentication & RBAC

### Bearer Token Usage (Existing)

The existing `network_utils.dart` automatically handles Bearer token authentication:

```dart
// In buildHeaderTokens() - already implemented
headers['Authorization'] = 'Bearer ${loginUserData.value.apiToken}';
```

### Role-Based Access Control

Backend enforces RBAC via 403 responses. Client-side handling:

```dart
Future<void> loadMyOrders() async {
  try {
    final response = await LabTestAPIs.getTestOrders();

    if (response.statusCode == 403) {
      // User doesn't have permission to view orders
      toast('You do not have permission to view orders');
      Get.back();
      return;
    }

    // Process response
    orders.assignAll(parseOrders(response.data));
  } catch (e) {
    toast(e.toString());
  }
}
```

---

## 5. Localization Integration

### Add to Language Files

**File**: `lib/locale/languages.dart`

```dart
abstract class BaseLanguage {
  // Lab & Radiology strings
  String get labTests;
  String get labTestCategories;
  String get createOrder;
  String get myOrders;
  String get orderNumber;
  String get testName;
  String get sampleType;
  String get price;
  String get turnaroundTime;
  String get clinicalNotes;
  String get priority;
  String get orderStatus;
  String get facilityBooking;
  String get bookingNumber;
  String get selectFacility;
  String get selectDate;
  String get selectTime;
  String get patientName;
  String get patientPhone;
  String get bookingStatus;
  // ... (add ~25 total)
}
```

**File**: `lib/locale/language_en.dart`

```dart
class LanguageEn extends BaseLanguage {
  @override
  String get labTests => 'Lab Tests';

  @override
  String get labTestCategories => 'Test Categories';

  @override
  String get createOrder => 'Create Order';

  @override
  String get myOrders => 'My Orders';

  @override
  String get orderNumber => 'Order Number';

  @override
  String get sampleType => 'Sample Type';

  @override
  String get price => 'Price';

  @override
  String get turnaroundTime => 'Turnaround Time';

  @override
  String get clinicalNotes => 'Clinical Notes';

  @override
  String get priority => 'Priority';

  @override
  String get orderStatus => 'Order Status';

  @override
  String get facilityBooking => 'Facility Booking';

  @override
  String get bookingNumber => 'Booking Number';

  @override
  String get selectFacility => 'Select Facility';

  @override
  String get selectDate => 'Select Date';

  @override
  String get selectTime => 'Select Time';

  @override
  String get patientName => 'Patient Name';

  @override
  String get patientPhone => 'Patient Phone';

  @override
  String get bookingStatus => 'Booking Status';
}
```

**File**: `lib/locale/language_ar.dart`

```dart
class LanguageAr extends BaseLanguage {
  @override
  String get labTests => 'الاختبارات المخبرية';

  @override
  String get labTestCategories => 'فئات الاختبار';

  @override
  String get createOrder => 'إنشاء طلب';

  @override
  String get myOrders => 'طلباتي';

  // ... (translate remaining keys to Arabic)
}
```

### Usage in UI

```dart
// In any screen
Text(locale.value.labTests)  // Displays "Lab Tests" or "الاختبارات المخبرية"
```

---

## 6. Notifications Integration

### Firebase Cloud Messaging (Existing)

Existing setup in `lib/utils/push_notification_service.dart` handles notification delivery.

### Backend Integration

Backend (Laravel) sends FCM notifications after events:

**Event**: Test Order Created
```json
{
  "notification": {
    "title": "Order Created",
    "body": "Your test order LAB-2026-0001 was created successfully"
  },
  "data": {
    "order_id": "1",
    "order_number": "LAB-2026-0001",
    "action": "order_created"
  }
}
```

**Event**: Facility Booking Created
```json
{
  "notification": {
    "title": "Booking Confirmed",
    "body": "Your appointment is confirmed for 2026-04-10 at 09:00"
  },
  "data": {
    "booking_id": "1",
    "booking_number": "BK-2026-0001",
    "action": "booking_created"
  }
}
```

### Client-Side Handling (Background)

Existing handler in `main.dart`:

```dart
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Existing implementation handles notification display
  // Feature-specific handling via data['action'] field
}
```

---

## 7. Error Handling Pattern

### Standard Error Response

```dart
Future<void> createOrder() async {
  try {
    final response = await LabTestAPIs.createTestOrder(request: {...});

    if (response.statusCode == 1) {
      // Success
      toast('Order created successfully');
      Get.back();
    } else {
      // API error (422, 400, etc.)
      toast(response.message ?? 'Failed to create order');
    }
  } catch (e) {
    // Network or parsing error
    toast('Error: ${e.toString()}');
  }
}
```

### Error UI Component

Use existing patterns:

```dart
if (isLoading.value) {
  return LoaderWidget();
} else if (errorMessage.isNotEmpty) {
  return EmptyErrorStateWidget(
    title: 'Error',
    subTitle: errorMessage.value,
    onRetry: () => loadCategories(),
  );
} else if (categories.isEmpty) {
  return EmptyErrorStateWidget(
    title: 'No Tests',
    subTitle: 'No tests available at the moment',
  );
} else {
  // Display categories
}
```

---

## 8. Navigation Pattern

### GetX Navigation

```dart
// Navigate to test details
Get.to(() => LabTestDetailScreen(testId: 1));

// Navigate to create order
Get.to(() => CreateTestOrderScreen());

// Navigate with data
Get.to(
  () => FacilityBookingScreen(),
  arguments: {'testOrderId': 1, 'selectedTests': [...]}
);

// Pop with result
Get.back(result: createdOrder);
```

---

## 9. UI Component Library Usage

### Existing Components

Reuse existing Espitalia UI patterns:

```dart
// Button
AppButton(
  text: locale.value.createOrder,
  onPress: () => createOrder(),
)

// Text Field
AppTextField(
  label: locale.value.clinicalNotes,
  hint: 'Enter clinical notes...',
  maxLines: 3,
)

// Loading
LoaderWidget()

// Empty State
EmptyErrorStateWidget(
  title: 'No orders',
  subTitle: 'You haven\'t placed any orders yet',
)

// Card
Container(
  decoration: boxDecorationDefault(
    color: isDarkMode.value ? cardDarkColor : Colors.white,
  ),
  child: // content
)
```

---

## 10. Testing Pattern

### Unit Test: Order Pricing

```dart
void main() {
  group('TestOrder Pricing', () {
    test('calculates correct total from items', () {
      final items = [
        {'test_id': 1, 'price': 150.00},
        {'test_id': 2, 'price': 100.00},
      ];
      final total = calculateOrderTotal(items);
      expect(total, equals(250.00));
    });

    test('applies discount correctly', () {
      final total = 250.00;
      final discount = 50.00;
      final final_amount = total - discount;
      expect(final_amount, equals(200.00));
    });
  });
}
```

### Integration Test: Order Creation Flow

```dart
testWidgets('User can create test order', (WidgetTester tester) async {
  // Setup
  await tester.pumpWidget(MyApp());

  // Navigate to lab tests
  await tester.tap(find.byIcon(Icons.medical_services));
  await tester.pumpAndSettle();

  // Select tests
  await tester.tap(find.byText('Complete Blood Count'));
  await tester.pumpAndSettle();

  // Create order
  await tester.tap(find.byText('Create Order'));
  await tester.pumpAndSettle();

  // Verify
  expect(find.text('Order created successfully'), findsOneWidget);
});
```

---

## 11. Performance Optimization Tips

1. **Test Catalog Caching**: Cache lab test categories in GetStorage after first load
2. **Pagination**: Implement lazy loading for test list (load 15 at a time)
3. **Slot Availability**: Query slots only for selected facility+date (don't load all)
4. **Image Loading**: Use cached_image_widget for test/facility images
5. **ListTile Performance**: Use ListView with proper separation for large lists

---

## 12. Accessibility & Dark Mode

### Dark Mode Support

```dart
// Use isDarkMode.value in colors
backgroundColor: isDarkMode.value ? Colors.grey[900] : Colors.white,

// Use design tokens
Container(
  decoration: BoxDecoration(
    color: isDarkMode.value ? surfaceElevatedDark : surfaceElevated,
    border: Border.all(
      color: isDarkMode.value ? glassStrokeDark : glassStrokeLight,
    ),
  ),
)
```

### Accessibility

- Use semantic HTML/Flutter (buttons, labels for inputs)
- Add tooltip descriptions for icons
- Ensure text contrast meets WCAG AA standards
- Use `Semantics` widget for custom widgets

---

## Next Steps

1. **Implement API Services** (`lib/api/lab_test_apis.dart`, `lib/api/facility_booking_apis.dart`)
2. **Add API Endpoints** to `lib/utils/api_end_points.dart`
3. **Create Models** in `lib/models/`
4. **Build Controllers** with GetX patterns
5. **Design UI Screens** using existing components
6. **Add Localization** strings to language files
7. **Write Tests** for critical paths
8. **Integration Testing** on Android + iOS + Web

---

## Reference Links

- API Contract: [../data-model.md](data-model.md)
- Feature Spec: [../spec.md](spec.md)
- Implementation Plan: [../plan.md](../plan.md)
- Constitution: `.specify/memory/constitution.md`
- Existing Patterns: `CLAUDE.md`
