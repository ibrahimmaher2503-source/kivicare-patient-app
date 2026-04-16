# Research & Technical Decisions

**Feature**: Labs & Radiology Booking System
**Branch**: `012-labs-radiology-bookings`
**Date**: 2026-04-05

## Overview

All technical unknowns for this feature are resolved by the existing Espitalia Patient App constitution and codebase. No external research required. This document confirms decisions already documented in the constitution and implementation plan.

---

## Resolved Technical Decisions

### 1. State Management: GetX 4.7.2

**Decision**: Use GetX for all state management, following existing patterns.

**Rationale**:
- Espitalia Patient App uses GetX exclusively across 261 Dart files
- Reactive variables (`.obs`) + `Obx()` widgets provide clean separation of state and UI
- `Get.put()` / `Get.lazyPut()` for dependency injection
- `Get.to()` / `Get.back()` for navigation without competing patterns

**Consistency**: Constitution §III enforces GetX-only architecture. Confirmed no conflicts.

---

### 2. Networking: HTTP + buildHttpResponse Pattern

**Decision**: Use existing `lib/network/network_utils.dart` with `buildHttpResponse()` for all API calls.

**Rationale**:
- Centralizes HTTP method handling (GET/POST/PUT/DELETE)
- Automatic token refresh on 401 via `reGenerateToken()`
- Consistent error handling with `handleResponse()`
- Bearer token auth via `buildHeaderTokens()`

**Integration**:
- Create `lib/api/lab_test_apis.dart` and `lib/api/facility_booking_apis.dart`
- Follow pattern: `buildHttpResponse(endpoint, method, request).then(...).catchError(...)`
- Automatic HTTPS enforcement (no HTTP in production)

**Confirmed**: All lab/radiology API endpoints in plan match Laravel contract specifications.

---

### 3. Localization: BaseLanguage Pattern

**Decision**: Use existing `lib/locale/languages.dart` (BaseLanguage) with `language_en.dart` and `language_ar.dart`.

**Rationale**:
- Single source of truth for UI strings via `locale.value.<key>`
- Supports both English and Arabic with RTL layout
- Date/number formatting via `intl` package (existing)

**Implementation**:
- Add ~25 new keys to `BaseLanguage` abstract class
- Implement in both `language_en.dart` and `language_ar.dart`
- Use `// TODO: translate` placeholder if Arabic translation unknown

**Confirmed**: No new localization packages needed. Existing system sufficient.

---

### 4. Database & Persistence: Laravel REST API

**Decision**: No local database. All persistence via existing Laravel REST API at `https://espitalia.net/api/`.

**Rationale**:
- Espitalia architecture delegates all data persistence to Laravel backend
- Local caching via GetStorage for UI state only (filters, preferences)
- Sensitive data (auth tokens) via platform keychain (existing `network_utils.dart`)
- Simplicity: Adding local SQL database increases complexity without benefit

**Storage Strategy**:
- **GetStorage**: Order history filters, test category cache, booking preferences
- **Platform Keychain**: Auth tokens (handled by existing network layer)
- **Backend**: Lab tests, test orders, facility bookings, pricing

**Confirmed**: Constitution §VII (Simplicity) supported. No RBAC complexity in app; backend enforces via 403 responses.

---

### 5. Authentication & Authorization

**Decision**: Use existing Espitalia auth with role-based access control enforced on backend.

**Rationale**:
- Patient login via `/v1/auth` endpoints (existing)
- Bearer token in `Authorization: Bearer <token>` header (automatic)
- Token refresh for both password and social logins (existing `reGenerateToken()`)
- Role-based filtering done by Laravel backend (patient/doctor/technician/admin)

**RBAC Pattern**:
- Patient sees own orders/bookings (backend filters via auth context)
- Doctor sees assigned orders (backend filters)
- Technician sees assigned orders (backend filters)
- Admin sees all (no filters)
- Client respects 403 Forbidden and displays appropriate UI

**Confirmed**: No new auth mechanisms needed. Existing OAuth2 + Sanctum sufficient.

---

### 6. Notifications: Firebase Cloud Messaging

**Decision**: Use existing Firebase Cloud Messaging setup for order and booking confirmations.

**Rationale**:
- Android & iOS platform support (platform parity)
- Existing integration in `lib/utils/push_notification_service.dart`
- Background message handler in `main.dart`
- Firebase project `espitalia-d934b` already configured for Android

**Usage**:
- Send notification when test order created
- Send notification when facility booking created
- Backend (Laravel) triggers FCM messages

**Confirmed**: Existing infrastructure sufficient. No new setup required.

---

### 7. Payment Status Integration

**Decision**: Track `payment_status` field on test orders; integrate with existing payment gateway system.

**Rationale**:
- Espitalia supports 10 payment gateways (`lib/payment_gateways/`)
- Feature focus: order creation and facility booking
- Payment processing handled separately after order creation
- `payment_status` field (unpaid/partial/paid) allows future payments integration

**Flow**:
1. Create test order with `payment_status: unpaid`
2. Payment system updates status when payment processed
3. Feature doesn't implement payment directly (out of scope)

**Confirmed**: Minimal integration point. Existing patterns sufficient.

---

## No Unknowns Remaining

✅ All technical questions resolved by existing architecture
✅ No external research dependencies
✅ Design can proceed to Phase 1 (data-model.md, contracts/, quickstart.md)
✅ Implementation can proceed to Phase 2 (tasks.md generation)

---

## Dependencies & Constraints Confirmed

### New Dependencies

**None required**. All needed packages already in `pubspec.yaml`:
- `get: ^4.7.2` (GetX)
- `http` package (networking)
- `firebase_core`, `firebase_messaging` (notifications)
- `intl` (date/number formatting)
- `google_fonts` (typography)
- `nb_utils` (UI helpers)

### Platform Constraints Confirmed

| Platform | Status | Notes |
|----------|--------|-------|
| Android | ✅ Supported | API 21+, Target SDK 35 |
| iOS | ✅ Supported | Flutter defaults, FCM requires APNs config |
| Web | ✅ Supported | Chrome-based, date picker native-aware |

### Performance Targets Confirmed

| Metric | Target | Approach |
|--------|--------|----------|
| Test search | <1s | Client-side pagination + caching of catalog |
| Order creation | <5min | Form optimization, pre-populated defaults |
| Slot availability | <500ms | Server-side data (rely on backend scaling) |
| Booking completion | <3min | Calendar + time slot selection UX |

---

## Constitution Alignment Confirmed

All 7 principles in `Espitalia Patient App Constitution` (v1.0.1) are satisfied:

1. **Platform Parity** ✅ - Test on Android + iOS/Web minimum
2. **Patient Data Security** ✅ - HTTPS + Bearer tokens only
3. **GetX Architecture** ✅ - No competing patterns
4. **Backend Contract Fidelity** ✅ - Follow existing patterns
5. **Localization-First** ✅ - English + Arabic required
6. **Testing Discipline** ✅ - Tests for ordering + booking (high-risk)
7. **Simplicity & Maintainability** ✅ - No over-engineering

---

## Next Steps

Proceed to **Phase 1: Design**:
- Generate `data-model.md` with entity definitions
- Create `contracts/` directory with API specifications
- Generate `quickstart.md` with integration patterns
- Then proceed to **Phase 2** (`/speckit.tasks`) for task breakdown
