# API Endpoint Sync Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Align all Flutter API endpoint strings in `lib/utils/api_end_points.dart` with the canonical backend routes from `postman_collection_full.json`, fix wrong `v1/` prefixes, and add all missing patient-relevant endpoints together with corresponding service methods in `lib/api/core_apis.dart`.

**Architecture:** All route strings live in a single source of truth — `APIEndPoints` class. Service calls in `core_apis.dart` reference only those constants. No hardcoded strings in screens or controllers. Changes are purely additive or string corrections; no business logic is altered.

**Tech Stack:** Flutter/Dart, GetX, `buildHttpResponse` from `lib/network/network_utils.dart`, `handleResponse` for JSON parsing.

---

## Analysis Summary

### v1-Prefix Mismatches (app says `v1/x`, Postman says `x`)

| Constant | Current (wrong) | Correct |
|---|---|---|
| getNurseRequests / createNurseRequest / getNurseRequestDetail / updateNurseRequest / cancelNurseRequest | `v1/nurse-requests` | `nurse-requests` |
| getCallDoctors / getCallDoctorServices / getCallSlots | `v1/call-doctors` | `call-doctors` |
| createCallBooking / getCallBookings | `v1/call-booking` | `call-booking` |
| getIndependentDoctors / getIndependentDoctorServices / getIndependentSlots | `v1/independent-doctors` | `independent-doctors` |
| createIndependentBooking / getIndependentBookings | `v1/independent-booking` | `independent-booking` |
| saveRequestService | `v1/save-request-service` | `save-request-service` |
| getRequestService | `v1/get-request-service` | `get-request-service` |

### Missing Patient-Relevant Endpoints

| Endpoint | Postman path | Notes |
|---|---|---|
| Cancel appointment | `POST cancel-appointment/{id}` | Dedicated cancel vs generic update-status |
| Download encounter invoice | `GET download-encounter-invoice` | |
| Download prescription | `GET download-prescription` | |
| Get prescription list | `GET get-prescription` | |
| Get medical report | `GET get-medical-report` | |
| Encounter dropdown list | `GET encounter-dropdown-list` | |
| Specialization list | `GET specialization-list` | |
| Branches list + detail | `GET v1/branches` / `GET v1/branches/{id}` | Hospital branches |
| FAQ | `GET v1/faq` | |
| Blog | `GET v1/blog` | |
| OTP resend | `POST otp-resend` | |
| OTP verify | `POST otp-verify` | |
| Check contact | `POST check-contact` | |
| Check email | `POST check-email` | |
| Constants | `GET constants` | Server-side constants |
| Pharmacy prescriptions | `GET/POST v1/pharmacy/prescriptions` + `GET v1/pharmacy/prescriptions/:id` | |
| Pharmacy order refund | `POST v1/pharmacy/orders/:id/refund` | |
| Pharmacy coupon validate | `POST v1/pharmacy/coupons/validate` | Different from offers coupon |
| Pharmacy refunds | `GET v1/pharmacy/refunds` + `GET v1/pharmacy/refunds/:id` | |
| Pharmacy notifications | `GET v1/pharmacy/notifications` | |
| Pharmacy notifications unread count | `GET v1/pharmacy/notifications/unread-count` | |
| Pharmacy mark notification read | `POST v1/pharmacy/notifications/:id/read` | |
| Pharmacy mark all read | `POST v1/pharmacy/notifications/read-all` | |

### Leave Unchanged (verified correct or intentionally diverge)
- `v1/nurses` — nurse listing uses this custom endpoint not in Postman (patient-specific list)
- `v1/hospitals`, `v1/icu-*`, `v1/facility-bookings`, `v1/lab-*`, `v1/offers/*`, `v1/pharmacy/*` (existing) — all match Postman with v1
- `home-healthcare/search` — correct (no v1 prefix, matches Postman)
- `doctor-visit/requests` — Postman shows doubled path (collection generation artifact); keep `v1/doctor-visit/requests`

---

## File Map

| File | Action | Responsibility |
|---|---|---|
| `lib/utils/api_end_points.dart` | Modify | Fix 17 wrong prefix constants; add ~24 new constants |
| `lib/api/core_apis.dart` | Modify | Add service methods for the new endpoints |

---

## Task 1: Fix v1-Prefix Mismatches in api_end_points.dart

**Files:**
- Modify: `lib/utils/api_end_points.dart`

- [ ] **Step 1: Fix nurse-requests prefix**

In `lib/utils/api_end_points.dart`, replace the Nurse section:

```dart
  //Nurse
  static const String getNurses = 'v1/nurses';
  static const String getNurseDetail = 'v1/nurses'; // append /{id}
  static const String getNurseRequests = 'nurse-requests';
  static const String createNurseRequest = 'nurse-requests';
  static const String getNurseRequestDetail = 'nurse-requests'; // append /{id}
  static const String updateNurseRequest = 'nurse-requests'; // append /{id}
  static const String cancelNurseRequest = 'nurse-requests'; // append /{id}/cancel
```

(Note: `getNurses` and `getNurseDetail` stay as `v1/nurses` — that custom listing endpoint is not in Postman and verified working.)

- [ ] **Step 2: Fix call-doctors and call-booking prefix**

Replace the Call Booking section:

```dart
  //Call Booking
  static const String getCallDoctors = 'call-doctors';
  static const String getCallDoctorServices = 'call-doctors'; // append /{id}/services
  static const String getCallSlots = 'call-doctors'; // append /{id}/slots
  static const String createCallBooking = 'call-booking';
  static const String getCallBookings = 'call-booking';
```

- [ ] **Step 3: Fix independent-doctors and independent-booking prefix**

Replace the Independent Doctor Booking section:

```dart
  //Independent Doctor Booking
  static const String getIndependentDoctors = 'independent-doctors';
  static const String getIndependentDoctorServices = 'independent-doctors'; // append /{id}/services
  static const String getIndependentSlots = 'independent-doctors'; // append /{id}/slots
  static const String createIndependentBooking = 'independent-booking';
  static const String getIndependentBookings = 'independent-booking';
```

- [ ] **Step 4: Fix request-service prefix**

Replace in the Request Service section:

```dart
  //Request Service
  static const String saveRequestService = 'save-request-service';
  static const String getRequestService = 'get-request-service';
```

- [ ] **Step 5: Commit the prefix fixes**

```bash
git add lib/utils/api_end_points.dart
git commit -m "fix: correct v1 prefix mismatches for nurse-requests, call-booking, independent-booking, request-service"
```

---

## Task 2: Add Missing Patient Endpoints to api_end_points.dart

**Files:**
- Modify: `lib/utils/api_end_points.dart`

- [ ] **Step 1: Add missing appointment endpoint**

In the `//booking api-list` section, after `rescheduleBooking`:

```dart
  static const String cancelAppointment = 'cancel-appointment'; // POST /{id}
```

- [ ] **Step 2: Add missing encounter endpoints**

In the `//booking encounter detail` section, after `encounterDashboardDetail`:

```dart
  static const String encounterDetails = 'encounter-details';
  static const String downloadEncounterInvoice = 'download-encounter-invoice';
  static const String downloadPrescription = 'download-prescription';
  static const String getPrescription = 'get-prescription';
  static const String getMedicalReport = 'get-medical-report';
  static const String encounterDropdownList = 'encounter-dropdown-list';
```

- [ ] **Step 3: Add auth utility endpoints**

In the `//Auth & User` section, after `forgotPassword`:

```dart
  static const String otpResend = 'otp-resend';
  static const String otpVerify = 'otp-verify';
  static const String checkContact = 'check-contact';
  static const String checkEmail = 'check-email';
  static const String constants = 'constants';
```

- [ ] **Step 4: Add specialization and branches**

After the `//Location` section:

```dart
  // Directory & Content
  static const String specializationList = 'specialization-list';
  static const String branches = 'v1/branches';
  static String branchDetail(int id) => '$branches/$id';
  static const String faq = 'v1/faq';
  static const String blog = 'v1/blog';
```

- [ ] **Step 5: Add pharmacy sub-endpoints**

After the existing pharmacy section, add:

```dart
  // Pharmacy — prescriptions
  static const String pharmacyPrescriptions = 'v1/pharmacy/prescriptions';
  static String pharmacyPrescriptionDetail(int id) => '$pharmacyPrescriptions/$id';

  // Pharmacy — refunds
  static const String pharmacyRefunds = 'v1/pharmacy/refunds';
  static String pharmacyRefundDetail(int id) => '$pharmacyRefunds/$id';
  static String pharmacyOrderRefund(int id) => '$pharmacyOrders/$id/refund';

  // Pharmacy — coupon (pharmacy-specific, different from v1/offers coupon)
  static const String pharmacyCouponValidate = 'v1/pharmacy/coupons/validate';

  // Pharmacy — notifications
  static const String pharmacyNotifications = 'v1/pharmacy/notifications';
  static const String pharmacyNotificationsUnreadCount = 'v1/pharmacy/notifications/unread-count';
  static String pharmacyNotificationMarkRead(int id) => 'v1/pharmacy/notifications/$id/read';
  static const String pharmacyNotificationsReadAll = 'v1/pharmacy/notifications/read-all';
```

- [ ] **Step 6: Commit the new endpoint constants**

```bash
git add lib/utils/api_end_points.dart
git commit -m "feat: add missing patient-relevant endpoint constants (cancel-appointment, encounter downloads, OTP, branches, pharmacy sub-endpoints)"
```

---

## Task 3: Add Service Methods in core_apis.dart

**Files:**
- Modify: `lib/api/core_apis.dart`

- [ ] **Step 1: Add cancelAppointment method**

Add after the `rescheduleBooking` method in `CoreServiceApis`:

```dart
  static Future<BaseResponseModel> cancelAppointment({required int appointmentId}) async {
    return BaseResponseModel.fromJson(
      await handleResponse(
        await buildHttpResponse(
          '${APIEndPoints.cancelAppointment}/$appointmentId',
          method: HttpMethodType.POST,
          request: {},
        ),
      ),
    );
  }
```

- [ ] **Step 2: Add encounter download methods**

Add after `cancelAppointment`:

```dart
  static Future<String> downloadEncounterInvoice({required int appointmentId}) async {
    final json = await handleResponse(
      await buildHttpResponse(
        '${APIEndPoints.downloadEncounterInvoice}?appointment_id=$appointmentId',
        method: HttpMethodType.GET,
      ),
    );
    return json['url'] as String? ?? '';
  }

  static Future<String> downloadPrescription({required int appointmentId}) async {
    final json = await handleResponse(
      await buildHttpResponse(
        '${APIEndPoints.downloadPrescription}?appointment_id=$appointmentId',
        method: HttpMethodType.GET,
      ),
    );
    return json['url'] as String? ?? '';
  }

  static Future<List<dynamic>> getPrescription({required int appointmentId}) async {
    final json = await handleResponse(
      await buildHttpResponse(
        '${APIEndPoints.getPrescription}?appointment_id=$appointmentId',
        method: HttpMethodType.GET,
      ),
    );
    return json['data'] as List? ?? [];
  }

  static Future<List<dynamic>> getMedicalReport({required int appointmentId}) async {
    final json = await handleResponse(
      await buildHttpResponse(
        '${APIEndPoints.getMedicalReport}?appointment_id=$appointmentId',
        method: HttpMethodType.GET,
      ),
    );
    return json['data'] as List? ?? [];
  }

  static Future<List<dynamic>> getEncounterDropdownList() async {
    final json = await handleResponse(
      await buildHttpResponse(APIEndPoints.encounterDropdownList, method: HttpMethodType.GET),
    );
    return json['data'] as List? ?? [];
  }
```

- [ ] **Step 3: Add OTP and auth-check methods**

Add after the existing `forgotPassword` region in `core_apis.dart`:

```dart
  static Future<BaseResponseModel> resendOtp({required Map<String, dynamic> request}) async {
    return BaseResponseModel.fromJson(
      await handleResponse(await buildHttpResponse(APIEndPoints.otpResend, method: HttpMethodType.POST, request: request)),
    );
  }

  static Future<BaseResponseModel> verifyOtp({required Map<String, dynamic> request}) async {
    return BaseResponseModel.fromJson(
      await handleResponse(await buildHttpResponse(APIEndPoints.otpVerify, method: HttpMethodType.POST, request: request)),
    );
  }

  static Future<BaseResponseModel> checkContact({required Map<String, dynamic> request}) async {
    return BaseResponseModel.fromJson(
      await handleResponse(await buildHttpResponse(APIEndPoints.checkContact, method: HttpMethodType.POST, request: request)),
    );
  }

  static Future<BaseResponseModel> checkEmail({required Map<String, dynamic> request}) async {
    return BaseResponseModel.fromJson(
      await handleResponse(await buildHttpResponse(APIEndPoints.checkEmail, method: HttpMethodType.POST, request: request)),
    );
  }
```

- [ ] **Step 4: Add branches and directory methods**

```dart
  static Future<List<dynamic>> getBranches() async {
    final json = await handleResponse(
      await buildHttpResponse(APIEndPoints.branches, method: HttpMethodType.GET),
    );
    return json['data'] as List? ?? [];
  }

  static Future<Map<String, dynamic>> getBranchDetail({required int id}) async {
    final json = await handleResponse(
      await buildHttpResponse(APIEndPoints.branchDetail(id), method: HttpMethodType.GET),
    );
    return json['data'] as Map<String, dynamic>? ?? {};
  }

  static Future<List<dynamic>> getFaq() async {
    final json = await handleResponse(
      await buildHttpResponse(APIEndPoints.faq, method: HttpMethodType.GET),
    );
    return json['data'] as List? ?? [];
  }

  static Future<List<dynamic>> getBlog({int page = 1, int perPage = 10}) async {
    final json = await handleResponse(
      await buildHttpResponse('${APIEndPoints.blog}?per_page=$perPage&page=$page', method: HttpMethodType.GET),
    );
    return json['data'] as List? ?? [];
  }

  static Future<List<dynamic>> getSpecializationList() async {
    final json = await handleResponse(
      await buildHttpResponse(APIEndPoints.specializationList, method: HttpMethodType.GET),
    );
    return json['data'] as List? ?? [];
  }
```

- [ ] **Step 5: Add pharmacy prescription methods**

```dart
  static Future<List<dynamic>> getPharmacyPrescriptions({int page = 1, int perPage = 10}) async {
    final json = await handleResponse(
      await buildHttpResponse('${APIEndPoints.pharmacyPrescriptions}?per_page=$perPage&page=$page', method: HttpMethodType.GET),
    );
    return json['data'] as List? ?? [];
  }

  static Future<Map<String, dynamic>> getPharmacyPrescriptionDetail({required int id}) async {
    final json = await handleResponse(
      await buildHttpResponse(APIEndPoints.pharmacyPrescriptionDetail(id), method: HttpMethodType.GET),
    );
    return json['data'] as Map<String, dynamic>? ?? {};
  }

  static Future<BaseResponseModel> createPharmacyPrescription({required Map<String, dynamic> request}) async {
    return BaseResponseModel.fromJson(
      await handleResponse(await buildHttpResponse(APIEndPoints.pharmacyPrescriptions, method: HttpMethodType.POST, request: request)),
    );
  }
```

- [ ] **Step 6: Add pharmacy refund and notification methods**

```dart
  static Future<List<dynamic>> getPharmacyRefunds({int page = 1, int perPage = 10}) async {
    final json = await handleResponse(
      await buildHttpResponse('${APIEndPoints.pharmacyRefunds}?per_page=$perPage&page=$page', method: HttpMethodType.GET),
    );
    return json['data'] as List? ?? [];
  }

  static Future<Map<String, dynamic>> getPharmacyRefundDetail({required int id}) async {
    final json = await handleResponse(
      await buildHttpResponse(APIEndPoints.pharmacyRefundDetail(id), method: HttpMethodType.GET),
    );
    return json['data'] as Map<String, dynamic>? ?? {};
  }

  static Future<BaseResponseModel> requestPharmacyOrderRefund({required int orderId, required Map<String, dynamic> request}) async {
    return BaseResponseModel.fromJson(
      await handleResponse(await buildHttpResponse(APIEndPoints.pharmacyOrderRefund(orderId), method: HttpMethodType.POST, request: request)),
    );
  }

  static Future<BaseResponseModel> validatePharmacyCoupon({required Map<String, dynamic> request}) async {
    return BaseResponseModel.fromJson(
      await handleResponse(await buildHttpResponse(APIEndPoints.pharmacyCouponValidate, method: HttpMethodType.POST, request: request)),
    );
  }

  static Future<List<dynamic>> getPharmacyNotifications({int page = 1, int perPage = 20}) async {
    final json = await handleResponse(
      await buildHttpResponse('${APIEndPoints.pharmacyNotifications}?per_page=$perPage&page=$page', method: HttpMethodType.GET),
    );
    return json['data'] as List? ?? [];
  }

  static Future<int> getPharmacyNotificationsUnreadCount() async {
    final json = await handleResponse(
      await buildHttpResponse(APIEndPoints.pharmacyNotificationsUnreadCount, method: HttpMethodType.GET),
    );
    return (json['count'] as num?)?.toInt() ?? 0;
  }

  static Future<BaseResponseModel> markPharmacyNotificationRead({required int id}) async {
    return BaseResponseModel.fromJson(
      await handleResponse(await buildHttpResponse(APIEndPoints.pharmacyNotificationMarkRead(id), method: HttpMethodType.POST, request: {})),
    );
  }

  static Future<BaseResponseModel> markAllPharmacyNotificationsRead() async {
    return BaseResponseModel.fromJson(
      await handleResponse(await buildHttpResponse(APIEndPoints.pharmacyNotificationsReadAll, method: HttpMethodType.POST, request: {})),
    );
  }
```

- [ ] **Step 7: Commit service methods**

```bash
git add lib/api/core_apis.dart
git commit -m "feat: add service methods for cancel-appointment, encounter downloads, OTP, branches, pharmacy sub-endpoints"
```

---

## Task 4: Smoke-Test Each Changed Endpoint Group

**No new files — verification only.**

Run the app against the local backend (`adb reverse tcp:8000 tcp:8000` must be active).

- [ ] **Step 1: Verify prefix fixes compile**

```bash
flutter analyze lib/utils/api_end_points.dart lib/api/core_apis.dart
```

Expected: `No issues found!` (or only pre-existing warnings listed in CLAUDE.md)

- [ ] **Step 2: Verify nurse-requests fix**

Navigate to the Nurse section in the running app. Open logcat:

```bash
adb logcat -d | grep "nurse-requests"
```

Expected: URLs show `http://localhost:8000/api/nurse-requests` (no `v1/`).

- [ ] **Step 3: Verify call-booking fix**

Navigate to Call Doctor Booking in the app. Check logcat:

```bash
adb logcat -d | grep "call-booking\|call-doctors"
```

Expected: `http://localhost:8000/api/call-booking` and `http://localhost:8000/api/call-doctors` (no `v1/`).

- [ ] **Step 4: Verify independent-booking fix**

Navigate to Independent Doctor Booking. Check logcat:

```bash
adb logcat -d | grep "independent-booking\|independent-doctors"
```

Expected: `http://localhost:8000/api/independent-booking` and `http://localhost:8000/api/independent-doctors`.

- [ ] **Step 5: Verify request-service fix**

Navigate to Request Service screen. Check logcat:

```bash
adb logcat -d | grep "request-service"
```

Expected: `http://localhost:8000/api/save-request-service` and `http://localhost:8000/api/get-request-service`.

- [ ] **Step 6: Verify new endpoints reachable (curl spot-check)**

```bash
curl -s -o /dev/null -w "%{http_code}" http://localhost:8000/api/cancel-appointment/1 -X POST -H "Authorization: Bearer test"
```

Expected: `401` or `404` (not `Connection refused` — proves the route exists).

```bash
curl -s -o /dev/null -w "%{http_code}" http://localhost:8000/api/specialization-list -H "Accept: application/json"
```

Expected: `200` or `401`.

```bash
curl -s -o /dev/null -w "%{http_code}" http://localhost:8000/api/v1/branches -H "Accept: application/json"
```

Expected: `200` or `401`.

- [ ] **Step 7: Final commit**

```bash
git add -A
git commit -m "chore: verify endpoint sync complete — all Postman routes aligned"
```

---

## Self-Review

**Spec coverage check:**

| Category | Covered? |
|---|---|
| 17 v1-prefix mismatches | ✓ Task 1 |
| cancelAppointment | ✓ Task 2+3 |
| Encounter downloads (invoice, prescription, medical report) | ✓ Task 2+3 |
| OTP (resend, verify) + pre-auth checks | ✓ Task 2+3 |
| Specialization list | ✓ Task 2+3 |
| Branches (list + detail) | ✓ Task 2+3 |
| FAQ + Blog | ✓ Task 2+3 |
| Pharmacy prescriptions (list, detail, create) | ✓ Task 2+3 |
| Pharmacy refunds (list, detail, request refund) | ✓ Task 2+3 |
| Pharmacy coupon validate (pharmacy-specific) | ✓ Task 2+3 |
| Pharmacy notifications (list, unread count, mark read) | ✓ Task 2+3 |
| Smoke tests | ✓ Task 4 |

**Placeholder scan:** No TBDs, no "similar to Task N" shortcuts, all code blocks complete.

**Type consistency:** All methods use `BaseResponseModel`, `List<dynamic>`, or `Map<String, dynamic>` — matching the existing pattern in `core_apis.dart`. `APIEndPoints.*` references match exactly what's defined in Task 2.
