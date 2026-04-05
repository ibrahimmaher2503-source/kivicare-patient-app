# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**Espitalia Patient App** (v1.8.1+20) - A Flutter healthcare application for patients to book appointments, manage medical records, track incidents, and make payments. Built on the KiviCare v1.8.1 template, customized for the Espitalia healthcare system with a Laravel backend.

- **App Name**: Espitalia
- **Package ID**: `com.espitalia.patient`
- **Backend**: Laravel REST API at `https://espitalia.net/api/`
- **Firebase Project**: `espitalia-d934b` (Android configured, iOS placeholder only)
- **SDK**: Flutter 3.0.0+ / Dart 3.0.0+

## Development Commands

### Running the App
```bash
flutter run                    # Run on connected device/emulator
flutter run -d chrome         # Run on Chrome (web)
flutter run -d windows        # Run on Windows (desktop)
```

### Building
```bash
flutter build apk             # Build Android APK
flutter build appbundle       # Build Android App Bundle (for Play Store)
flutter build ios             # Build iOS (requires macOS)
flutter build web             # Build for web
```

### Testing & Code Quality
```bash
flutter test                  # Run all tests
flutter analyze              # Run static analysis
flutter pub get              # Install dependencies
flutter pub upgrade          # Update dependencies
flutter clean                # Clean build artifacts
```

### Firebase
```bash
flutterfire configure        # Reconfigure Firebase (if needed)
```

## Architecture

### State Management
- **GetX** (`get: ^4.7.2`) for state management, routing, and dependency injection
- Reactive state using `.obs` observables and `Obx()` widgets
- Global state stored in `lib/utils/common_base.dart` (e.g., `isLoggedIn`, `loginUserData`)
- `isDarkMode` reactive var lives in `lib/utils/app_common.dart` — NOT in `common_base.dart`

### UI Styling & Fonts
- **nb_utils** helpers: `primaryTextStyle()`, `boldTextStyle()`, `boxDecorationDefault()`, etc.
- **Fonts**: Google Fonts — **Plus Jakarta Sans** (body text) + **Outfit** (display/headings)
- `GoogleFonts.xxx()` returns a `TextStyle` directly — do NOT call `.textStyle` on it

### Project Structure

```
lib/                                  # 261 Dart files, 59 directories
├── api/                              # API service layer (3 files)
│   ├── auth_apis.dart               # Authentication endpoints
│   ├── core_apis.dart               # Core app endpoints
│   └── home_apis.dart               # Home/dashboard endpoints
├── components/                       # Reusable UI components (21 files)
│   ├── app_scaffold.dart            # Base scaffold wrapper
│   ├── cached_image_widget.dart     # Cached network images
│   ├── loader_widget.dart           # Loading indicators
│   ├── new_update_dialog.dart       # App update prompts
│   ├── filter_count_badge.dart      # Filter count badge (unified across modules)
│   └── ...                          # ~16 more shared widgets
├── generated/                        # Auto-generated code
│   └── assets.dart                  # Asset path constants
├── google_calendar/                  # Google Calendar integration
│   ├── calendar_client.dart         # Calendar API client
│   └── calendar_event_service.dart  # Event CRUD operations
├── locale/                           # Internationalization (4 files)
│   ├── app_localizations.dart
│   ├── languages.dart               # Language configuration
│   ├── language_en.dart             # English
│   └── language_ar.dart             # Arabic
├── models/                           # Shared data models (3 files)
│   ├── base_response_model.dart
│   ├── notificationdata_model.dart
│   └── register_user_res_model.dart
├── network/                          # Network layer (3 files)
│   ├── network_utils.dart           # HTTP client, token management
│   ├── location_service.dart        # Geolocation services
│   └── map_screen.dart              # Google Maps display
├── payment_gateways/                 # Payment integrations (14 files)
│   ├── stripe_services.dart         # Stripe (INR)
│   ├── razor_pay_service.dart       # Razorpay (India)
│   ├── pay_pal_service.dart         # PayPal (USD)
│   ├── flutter_wave_service.dart    # FlutterWave (multi-currency)
│   ├── pay_stack_service.dart       # PayStack (NGN)
│   ├── cinet_pay_services.dart      # CinetPay (West Africa)
│   ├── midtrans_service.dart        # Midtrans (Indonesia)
│   ├── sadad_services.dart          # Sadad (Qatar)
│   ├── phone_pe/                    # PhonePe (India - UPI)
│   │   ├── phone_pe_service.dart
│   │   ├── upi_pay.dart
│   │   └── upi_app_model.dart
│   └── airtel_money/                # Airtel Money (Africa)
│       ├── airtel_money_service.dart
│       ├── airtel_payment_response.dart
│       └── aritel_auth_model.dart
├── screens/                          # Feature screens (56 files, 15 areas)
│   ├── splash_screen.dart           # App splash/launch
│   ├── splash_controller.dart
│   ├── auth/                        # Authentication flows
│   │   ├── sign_in_sign_up/        # Login & registration
│   │   ├── password/               # Password reset
│   │   ├── profile/                # User profile management
│   │   ├── services/               # Auth services
│   │   ├── model/                  # Auth models
│   │   └── other/                  # Other auth screens
│   ├── dashboard/                   # Main dashboard + components
│   ├── home/                        # Home screen + components + models
│   ├── booking/                     # Appointment booking
│   │   ├── components/
│   │   ├── model/
│   │   └── filter/                 # Typed filtering system (FilterParams, location)
│   │       ├── components/         # FilterLocationComponent (governorate/city picker)
│   │       ├── model/              # FilterParams (typed filter data structure)
│   │       ├── filter_controller.dart
│   │       └── filter_screen.dart
│   ├── slots/                       # Appointment slot selection
│   ├── doctor/                      # Doctor listings & profiles
│   ├── clinic/                      # Clinic information
│   ├── category/                    # Category browsing
│   ├── service/                     # Service browsing
│   ├── Encounter/                   # Medical encounter records
│   ├── payment/                     # Payment processing
│   │   ├── payment_screen.dart
│   │   ├── payment_controller.dart
│   │   ├── booking_success_screen.dart
│   │   └── booking_confirmation_dialog.dart
│   ├── incident_management/         # Incident tracking & reporting
│   ├── other_patient/               # Multi-patient/family member support
│   └── walkthrough/                 # Onboarding screens
├── utils/                            # Utilities (11 files)
│   ├── constants.dart               # App constants, date formats, keys
│   ├── colors.dart                  # Color definitions
│   ├── api_end_points.dart          # API endpoints (72 endpoints)
│   ├── local_storage.dart           # GetStorage wrapper
│   ├── common_base.dart             # Global state variables (isLoggedIn, loginUserData)
│   ├── app_common.dart              # Common utility functions + isDarkMode reactive var
│   ├── push_notification_service.dart # Firebase messaging
│   ├── price_widget.dart            # Price formatting widget
│   ├── empty_error_state_widget.dart # Empty/error state display
│   ├── getImage.dart                # Image picker utilities
│   └── view_all_label_component.dart # "View All" section headers
├── app_theme.dart                    # Light & dark theme definitions
├── configs.dart                      # App configuration (URLs, keys)
├── firebase_options.dart             # Firebase setup (Android only)
└── main.dart                         # App entry point
```

### Other Project Directories

```
specs/                                # SpecKit specification documents
├── speckit.constitution.md          # Project constitution
├── speckit.specify.md               # Feature specifications
├── speckit.plan.md                  # Implementation plans
├── speckit.tasks.md                 # Task tracking
├── speckit.taskstoissues.md         # GitHub issue mapping
├── speckit.clarify.md               # Clarification notes
├── speckit.checklist.md             # Implementation checklists
├── speckit.analyze.md               # Cross-artifact analysis
└── speckit.implement.md             # Implementation guide

assets/
├── app_logo.png                     # Main app logo
├── flags/                           # Country flags (locale selection)
├── icons/
│   ├── navigation/                  # Navigation bar icons
│   ├── social_media/               # Social login icons
│   └── upi_payment/                # UPI payment app icons
├── images/
│   └── walkthrough_images/          # Onboarding walkthrough images
└── lottie/                          # Lottie animations
```

### Network Layer

- **Base URL**: Configured in `lib/configs.dart` (`DOMAIN_URL` / `BASE_URL`)
- **HTTP Client**: `lib/network/network_utils.dart`
  - `buildHttpResponse()` - Main HTTP method (GET/POST/PUT/DELETE)
  - `buildMultiPartResponse()` - For file uploads
  - Automatic token refresh on 401 responses via `reGenerateToken()`
  - Bearer token authentication from `loginUserData.value.apiToken`
- **Headers**: Auto-injected via `buildHeaderTokens()` including:
  - `Authorization: Bearer <token>`
  - `global-localization: <language_code>`
  - Content-Type and CORS headers

### Authentication Flow

1. Login/Register through `lib/api/auth_apis.dart`
2. User data stored in GetStorage via `lib/utils/local_storage.dart`
3. Global `loginUserData` reactive variable updated
4. `isLoggedIn.value` flag controls app flow
5. Social login supported: Google Sign-In, Apple Sign-In
6. Password stored locally (encrypted) for token regeneration

### Configuration Management

- **Environment Config**: `lib/configs.dart`
  - Update `DOMAIN_URL` for different environments
  - Configure payment gateway keys (Stripe, PayPal, etc.)
  - Set app name, URLs, contact info
- **Local Storage**: `GetStorage` for persistent data
  - User credentials, theme mode, language preference
  - Access via `getValueFromLocal()` and `setValueToLocal()` in `lib/utils/local_storage.dart`

### API Endpoints (72 total in `lib/utils/api_end_points.dart`)

**Categories:**
- **Auth**: register, login, logout, verify, socialLogin, changePassword, forgotPassword
- **User**: userDetail, updateProfile, deleteUserAccount, notification management, wallet
- **Dashboard**: dashboard-detail, getDashboard
- **Browsing**: categories, services, clinics, doctors (with details/lists)
- **Appointments**: getAppointments, saveBooking, rescheduleBooking, updateStatus
- **Encounters**: getEncounterList, encounterDashboardDetail
- **Payments**: savePayment
- **Reviews**: saveRating, getRating, deleteRating
- **Incidents**: incidenceList, incidenceSave, updateIncidentStatus
- **Other Patients**: addPatient, otherMemberPatientList, deleteOtherMember

## Key Features

- **Appointments**: Book, view, reschedule appointments with doctors
- **Lab Tests & Radiology**: Browse test catalog, create orders, book facility appointments
- **Encounters**: View medical encounter records
- **Incident Management**: Track and report healthcare incidents
- **Multi-Patient Support**: Manage family members / other patients
- **Multi-language**: Support for English and Arabic (RTL)
- **Push Notifications**: Firebase Cloud Messaging integration
- **Google Calendar**: Sync appointments to Google Calendar
- **Google Maps**: Location services for clinics
- **File Uploads**: Medical documents, profile images
- **Dark Mode**: Theme switching support
- **10 Payment Gateways**: Stripe, Razorpay, PayPal, PhonePe, PayStack, FlutterWave, CinetPay, Airtel Money, Midtrans, Sadad

## Important Notes

### API Token Management
- The app automatically regenerates tokens when they expire (401 responses)
- Token refresh happens transparently via `reGenerateToken()` in `network_utils.dart`
- User password is stored locally (in SharedPreferences) to enable token regeneration for non-social logins

### Firebase Status
- **Android**: Fully configured (project: `espitalia-d934b`)
- **iOS**: Placeholder values only - not yet configured
- **Web**: Not configured
- **Crashlytics**: Enabled in release mode only
- **Cloud Messaging**: Background handler in `main.dart`
- **Auth**: Used for social sign-in (Google, Apple)

### Android Build Config
- **Compile SDK**: 35 / **Target SDK**: 35
- **NDK**: 27.0.12077973
- **Multidex**: Enabled
- **JDK Target**: 1.8 (with desugaring)
- **Native SDKs**: PhonePe SDK 2.3.0

### GetX Best Practices
- Use `.obs` for reactive variables
- Wrap UI with `Obx()` for reactive updates
- Controllers are typically embedded in screen files (not separate controller files)
- Navigation uses `Get.to()`, `Get.back()`, `Get.offAll()`
- Snackbars/Toasts use `Get.snackbar()` or nb_utils `toast()`

### Localization
- All user-facing strings should be accessed via `locale.value.<key>`
- Global `locale` variable defined in `main.dart`
- Add new translations to all language files in `lib/locale/`

### Known Pre-existing Warnings (do not fix unless asked)
- `Radio` `groupValue`/`onChanged` deprecation in `payment_screen.dart`
- `AppBarTheme` `color` deprecation in theme files
These existed before recent work and should not be treated as regressions.

### Custom Packages
Several payment gateways use custom forks from `iqonic-design` GitHub:
- `flutterwave_standard`
- `flutter_paypal_checkout`
- `cinetpay`
- `flutter_paystack`
- `midpay`

These are specified as git dependencies in `pubspec.yaml`.

## UI Modernization (Clinical Elegance)

Design system upgrade in progress. Phase 1 is complete.

### Design Tokens
- Card radius: **16px**
- Input radius: **12px**
- Bottom sheets / scaffold body padding: **24px**
- Shadows: navy-tinted soft shadows

### Phase 1 — COMPLETE (Foundation Layer)
Modified files: `colors.dart`, `app_theme.dart`, `main.dart`, `common_base.dart`, `app_scaffold.dart`, `loader_widget.dart`, `app_dialogue_component.dart`, `bottom_selection_widget.dart`

### Color Tokens Added to `colors.dart`
- **Gradients**: `gradientStart`, `gradientEnd`, `gradientSecondaryStart`, `gradientSecondaryEnd`
- **Glass**: `glassTintLight`, `glassTintDark`, `glassStrokeLight`, `glassStrokeDark`
- **Shadows**: `softShadowColor`, `softShadowColorMedium`, `softShadowColorDark`
- **Surfaces**: `surfaceElevated`, `surfaceElevatedDark`, `surfaceSubtle`
- **Shimmer**: `shimmerBase`, `shimmerHighlight`, `shimmerBaseDark`, `shimmerHighlightDark`
- **Input**: `inputFillColor`, `inputFillColorDark`, `inputFocusGlow`

### Phases 2–6 — PENDING (Screens and remaining components)

## Enhanced Filter System (Complete)

Comprehensive redesign of filtering across doctor, clinic, service, and category modules. Implements typed FilterParams, consolidated filter logic, and location-based filtering.

### FilterParams Model
Type-safe replacement for positional `Get.arguments` lists. Located in `lib/screens/booking/filter/model/filter_params.dart`.

```dart
class FilterParams {
  final int clinicId;
  final String serviceType;
  final String priceMin;
  final String priceMax;
  final String moduleType;      // "doctor", "clinic", "service", "category"
  final int categoryId;
  final int? governorateId;     // Location filters
  final int? cityId;
  final int? specialtyId;        // Advanced filters
  final String gender;
  final String ratingMin;
  final String ratingMax;
}
```

**Usage Pattern:**
```dart
// In list screen, construct FilterParams with current filter state
final params = FilterParams(
  moduleType: "doctor",
  clinicId: doctorListCont.clinicId.value,
  serviceType: doctorListCont.serviceType.value,
  governorateId: doctorListCont.selectedGovernorateId.value,
  cityId: doctorListCont.selectedCityId.value,
  // ... other fields
);

// Pass via arguments to FilterScreen
Get.to(() => FilterScreen(...), arguments: params);
```

### FilterCountBadge Component
Unified badge widget showing active filter count across all modules.
- **Location**: `lib/components/filter_count_badge.dart`
- **Features**: Small gradient circle (gradientSecondaryStart/End), positioned overlay, auto-hide when count = 0
- **Used in**: Doctor list, clinic list, service list, category list screens

```dart
Stack(
  children: [
    FilterButton(...),
    FilterCountBadge(count: filterController.activeFilterCount),
  ],
)
```

### FilterLocationComponent
Wraps GovernoratesCityPicker with design token styling.
- **Location**: `lib/screens/booking/filter/components/filter_location_component.dart`
- **Features**: surfaceElevated background, glass border, 16px radius, soft navy shadow
- **State**: Reads from `FilterController.selectedGovernorateId` and `selectedCityId`
- **Behavior**: Automatically resets city when governorate changes

### FilterController Features
- **activeFilterCount getter**: Single computed property replacing 9 scattered counter variables
- **Location support**: `selectedGovernorateId`, `selectedCityId` reactive variables
- **Advanced filters**: `selectedSpecialtyId`, `selectedGender`
- **Callbacks**: `onGovernorateChanged(id)`, `onCityChanged(id)` for cascading logic
- **Backwards compatible**: Still accepts legacy List-based Get.arguments if needed

### Applied Modules
All four list screens use the new filter system:
1. **Doctor List**: `lib/screens/home/components/doctor_list_screen.dart`
2. **Clinic List**: `lib/screens/home/components/clinic_list_screen.dart`
3. **Service List**: `lib/screens/home/components/popular_service_list.dart`
4. **Category List**: `lib/screens/service/services_list_screen.dart`

Each module constructs FilterParams with its specific filters and passes to FilterScreen.

## Common Patterns

### API Call Pattern
```dart
// In API service file
static Future<ResponseModel> apiMethod({required Map request}) async {
  return await buildHttpResponse(
    APIEndPoints.endpoint,
    method: HttpMethodType.POST,
    request: request,
  ).then((response) {
    return ResponseModel.fromJson(handleResponse(response));
  }).catchError((e) {
    throw e;
  });
}
```

### Screen with Loading State
```dart
RxBool isLoading = false.obs;

// Show loader
isLoading(true);
appStore.setLoading(true);

// API call
await apiMethod().then((value) {
  // Handle success
}).catchError((e) {
  toast(e.toString());
}).whenComplete(() {
  isLoading(false);
  appStore.setLoading(false);
});
```

### Navigation
```dart
Get.to(() => NextScreen());                    // Push
Get.back();                                    // Pop
Get.offAll(() => DashboardScreen());          // Replace all
```

### Filter Navigation Pattern
```dart
// Build FilterParams with current state
final params = FilterParams(
  moduleType: "doctor",
  clinicId: doctorListCont.clinicId.value,
  serviceType: doctorListCont.serviceType.value,
  priceMin: doctorListCont.minimumPrice.toString(),
  priceMax: doctorListCont.maximumPrice.toString(),
  governorateId: doctorListCont.selectedGovernorateId.value,
  cityId: doctorListCont.selectedCityId.value,
  ratingMin: doctorListCont.minimumRating.toString(),
  ratingMax: doctorListCont.maximumRating.toString(),
  // ... other fields
);

// Navigate with typed arguments
Get.to(() => FilterScreen(displayName: 'Doctor'), arguments: params);

// In FilterScreen.onInit(), read FilterParams:
if (Get.arguments is FilterParams) {
  var params = Get.arguments as FilterParams;
  // Use params.clinicId, params.governorateId, etc.
}
```

### Accessing Active Filter Count
```dart
// Anywhere in the app with access to FilterController
int activeCount = filterController.activeFilterCount;

// Reactive updates in widgets
Obx(() => Text('${filterController.activeFilterCount} filters active'))
```
