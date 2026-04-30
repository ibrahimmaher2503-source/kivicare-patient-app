# Research: ICU Admission Module

**Phase**: 0 — Research  
**Branch**: `021-icu-admission-module`  
**Date**: 2026-04-28

---

## 1. Dependency Audit

**Decision**: No new packages are required.

**Rationale**: Every capability the module needs is already in the pubspec:

| Capability | Package | Version |
|------------|---------|---------|
| Tap-to-call (`tel:` URI) | `url_launcher` | `^6.3.1` |
| Success screen animation | `lottie` | `^3.3.1` |
| Date formatting | `intl` | `^0.20.2` |
| Reference number persistence | `get_storage` | `^2.1.1` |
| UI helpers, toast, styles | `nb_utils` | `^7.1.4` |
| State + navigation + DI | `get` | `^4.7.2` |

**Alternatives considered**: `shimmer` package (rejected — the project already has a hand-rolled shimmer widget in `lib/screens/location_filter/components/location_shimmer.dart` that uses `shimmerBase/shimmerHighlight` color tokens; copy that pattern rather than adding a dependency).

---

## 2. Shimmer Loading Pattern

**Decision**: Replicate `LocationShimmer` pattern — `AnimatedBuilder` + `LinearGradient` over `shimmerBase`/`shimmerHighlight` color tokens.

**Rationale**: The pattern already exists and is consistent with the design token system. Introducing a package would create dual approaches.

**How to apply**: Create `IcuShimmer` (or reuse `LocationShimmer` directly for list skeletons) using the same `AnimationController` + `Tween<double>(-2, 2)` approach. Card height varies by screen (hospital card ≈ 110px, request card ≈ 90px, department card ≈ 80px).

---

## 3. Push Notification Deep Link

**Decision**: Add `else if` for `icu_admission_status_changed` in `PushNotificationService.handleNotificationClick()`.

**Rationale**: `nurse_request_status_changed` is the exact precedent at lines 101–107 of `push_notification_service.dart`. Same payload shape: `additionalData['type']` + `additionalData['request_id']`.

**Implementation pattern**:
```
} else if (notificationType == 'icu_admission_status_changed') {
  final rawId = additionalData['request_id'];
  final requestId = rawId is int ? rawId : int.tryParse(rawId?.toString() ?? '') ?? 0;
  if (requestId > 0) {
    Get.to(() => AdmissionRequestDetailScreen(requestId: requestId));
  }
}
```

**Alternatives considered**: Named routes (rejected — the codebase uses widget-based navigation with `Get.to()` uniformly).

---

## 4. Governorate / City Picker Reuse

**Decision**: Reuse `lib/screens/location_filter/governorate_selection_screen.dart` and `city_selection_screen.dart` for the hospital filter sheet.

**Rationale**: These screens already exist, are styled with design tokens, and handle the governorate→city cascade. No need to rebuild this functionality.

**How to apply**: In `HospitalFilterScreen`, open the governorate picker via `Get.to(() => GovernorateSelectionScreen(...))` with a callback to set `HospitalFilterController.selectedGovernorateId`, mirroring how the booking filter uses it.

---

## 5. Reference Number Persistence

**Decision**: `setValueToLocal('lastIcuRequestReference', referenceNumber)` immediately after successful submit. Read back via `getValueFromLocal<String?>('lastIcuRequestReference')`.

**Rationale**: `GetStorage` is already the app-wide persistence layer. The reference number is not sensitive data (no PII, not a credential). Constitution II (Patient Data Security) does not apply to a non-PII reference code.

**Key**: `'lastIcuRequestReference'` — add as a constant in `lib/utils/constants.dart` alongside existing `SharedPreferenceConst` / `SettingsLocalConst` groups.

---

## 6. `tel:` URI Platform Guard

**Decision**: Wrap every `url_launcher` tel: call with `canLaunchUrl` check. On desktop web where `tel:` is unsupported, fall back to copying the number to clipboard + `toast()`.

**Rationale**: Constitution I (Platform Parity) requires the feature to degrade gracefully on platforms where the feature cannot function, rather than crashing. `canLaunchUrl(Uri.parse('tel:+X'))` returns `false` on desktop browsers.

**Pattern**:
```
final uri = Uri.parse('tel:$phoneNumber');
if (await canLaunchUrl(uri)) {
  await launchUrl(uri);
} else {
  await Clipboard.setData(ClipboardData(text: phoneNumber));
  toast('Number copied to clipboard');
}
```

---

## 7. Emergency Hotline Configuration

**Decision**: Add `EMERGENCY_HOTLINE` constant to `lib/configs.dart`, following the existing `HELP_LINE_NUMBER` pattern.

**Rationale**: The spec requires the hotline to be configurable (not hardcoded in widgets). `configs.dart` already holds `HELP_LINE_NUMBER` for this exact purpose.

**Addition**:
```dart
/// ICU emergency hotline — shown prominently throughout the ICU module
const EMERGENCY_HOTLINE = '+20XXXXXXXXXX';
```

---

## 8. Locale Key Strategy

**Decision**: Add ~80 new string keys to `lib/locale/languages.dart` (abstract getters), `lib/locale/language_en.dart` (English values), and `lib/locale/language_ar.dart` (Arabic values). Use `// TODO: translate` on Arabic strings where translation is unavailable.

**Rationale**: Constitution V (Localization-First) requires all user-visible strings to flow through the `BaseLanguage` system.

**Note**: Several generic keys (`all`, `search`, `refresh`, `retry`, `somethingWentWrong`) may already exist in `BaseLanguage`. Audit before adding duplicates — reuse existing keys where semantically correct.

---

## 9. API Method Style

**Decision**: Follow the `CoreServiceApis` static-method pattern: `buildHttpResponse()` → `handleResponse()` → `Model.fromJson()`. Query parameters concatenated as strings. POST bodies via `request:` Map parameter.

**Rationale**: 100% of existing API files use this exact pattern. Consistency reduces onboarding friction.

**Specific for ICU**: The new endpoints use RESTful path segments (`/icu-admission-requests/{id}`, `/icu-admission-requests/{id}/cancel`) rather than query parameters. Construct the path by string concatenation: `'${APIEndPoints.icuAdmissionRequests}/$id'`.

---

## 10. Lottie Success Animation

**Decision**: Use an existing Lottie asset from `assets/lottie/` for the admission success screen. If no checkmark asset exists, use the same animation used in other success flows (e.g., booking confirmation).

**Rationale**: `lottie: ^3.3.1` is already in pubspec. The asset path must be referenced via `lib/generated/assets.dart` constants (Constitution, Development Workflow).

**Alternatives considered**: Custom painted checkmark (rejected — adds complexity; Lottie is already available).

---

## Summary: All NEEDS CLARIFICATION Resolved

| Topic | Resolution |
|-------|-----------|
| Shimmer approach | Hand-rolled — replicate `LocationShimmer` |
| New packages needed | None |
| Notification routing | `else if` in `handleNotificationClick()` |
| Governorate picker | Reuse existing `location_filter/` screens |
| Reference persistence key | `'lastIcuRequestReference'` in GetStorage |
| `tel:` on web | `canLaunchUrl` guard + clipboard fallback |
| Emergency hotline config | `EMERGENCY_HOTLINE` const in `configs.dart` |
| Lottie animation | Use existing `assets/lottie/` asset |
| Locale duplicates | Audit before adding — reuse where possible |
| API method style | Static, `buildHttpResponse` pattern |
