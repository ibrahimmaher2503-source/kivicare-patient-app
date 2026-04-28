# Home V2 Enhancements — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add greeting header, quick actions grid, and upcoming appointment card to the existing HomeV2Screen, transforming it into the full Vezeeta-inspired homepage from the design spec.

**Architecture:** The existing `HomeV2Screen` at `lib/screens/vezeeta/home_v2/` already has sticky search bar, specialties grid, nearby doctors, and offers strip. This plan adds three new sliver sections (greeting header, quick actions, upcoming appointment) and wires the controller to load upcoming appointment data. No new API endpoints — reuses existing `appointment-list` via `CoreServiceApis`.

**Tech Stack:** Flutter/Dart, GetX state management, Google Fonts, nb_utils, existing color tokens from `lib/utils/colors.dart`.

---

## File Structure

| Action | File | Responsibility |
|--------|------|----------------|
| Create | `lib/screens/vezeeta/home_v2/components/home_greeting_header.dart` | Flat greeting row: avatar, name, location chip, notification bell |
| Create | `lib/screens/vezeeta/home_v2/components/upcoming_appointment_card.dart` | Compact next-appointment reminder card |
| Modify | `lib/screens/vezeeta/home_v2/home_v2_controller.dart` | Add upcoming appointment loading + state |
| Modify | `lib/screens/vezeeta/home_v2/home_v2_screen.dart` | Insert new slivers: greeting, quick actions, upcoming appointment |
| Modify | `lib/locale/languages.dart` | Add `nextAppointment` locale key |
| Modify | `lib/locale/language_en.dart` | Add English translation |
| Modify | `lib/locale/language_ar.dart` | Add Arabic translation |

---

### Task 1: Add locale key for "Next Appointment"

**Files:**
- Modify: `lib/locale/languages.dart`
- Modify: `lib/locale/language_en.dart`
- Modify: `lib/locale/language_ar.dart`

- [ ] **Step 1: Add abstract getter to `languages.dart`**

Add after the `noSpecialtiesAvailable` getter (around line 1482):

```dart
String get nextAppointment;
```

- [ ] **Step 2: Add English translation to `language_en.dart`**

Find where the other vezeeta-related strings are defined (near `noSpecialtiesAvailable`) and add:

```dart
@override
String get nextAppointment => 'Next Appointment';
```

- [ ] **Step 3: Add Arabic translation to `language_ar.dart`**

In the same location as English:

```dart
@override
String get nextAppointment => 'الموعد القادم';
```

- [ ] **Step 4: Verify no analysis errors**

Run: `flutter analyze lib/locale/`
Expected: No new errors (existing warnings may remain).

- [ ] **Step 5: Commit**

```bash
git add lib/locale/languages.dart lib/locale/language_en.dart lib/locale/language_ar.dart
git commit -m "feat(home_v2): add nextAppointment locale key"
```

---

### Task 2: Create HomeGreetingHeader component

**Files:**
- Create: `lib/screens/vezeeta/home_v2/components/home_greeting_header.dart`

- [ ] **Step 1: Create the greeting header widget**

```dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../../components/cached_image_widget.dart';
import '../../../../generated/assets.dart';
import '../../../../main.dart';
import '../../../../utils/app_common.dart';
import '../../../../utils/colors.dart';
import '../../../../utils/common_base.dart';
import '../../../auth/other/notification_screen.dart';
import '../home_v2_controller.dart';
import 'city_prompt_banner.dart';

class HomeGreetingHeader extends StatelessWidget {
  const HomeGreetingHeader({super.key});

  String get _timeGreeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  IconData get _timeIcon {
    final hour = DateTime.now().hour;
    if (hour < 12) return Icons.wb_sunny_rounded;
    if (hour < 17) return Icons.wb_cloudy_rounded;
    return Icons.nightlight_round;
  }

  @override
  Widget build(BuildContext context) {
    final dark = isDarkMode.value;
    return Padding(
      padding: EdgeInsets.fromLTRB(24, context.statusBarHeight + 12, 24, 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Profile avatar
          Obx(
            () => loginUserData.value.profileImage.contains('http')
                ? Padding(
                    padding: const EdgeInsetsDirectional.only(end: 12),
                    child: CachedImageWidget(
                      url: loginUserData.value.profileImage,
                      fit: BoxFit.cover,
                      width: 46,
                      height: 46,
                      circle: true,
                    ),
                  )
                : const SizedBox.shrink(),
          ),
          // Greeting + name + location
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _timeIcon,
                      color: dark ? textTertiaryDark : secondaryTextColor,
                      size: 12,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _timeGreeting,
                      style: GoogleFonts.plusJakartaSans(
                        color: dark ? textSecondaryDark : secondaryTextColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Obx(
                  () => Text(
                    isLoggedIn.value
                        ? loginUserData.value.userName.validate()
                        : locale.value.guest.validate(),
                    style: GoogleFonts.outfit(
                      color: dark ? textPrimaryDark : primaryTextColor,
                      fontSize: 21,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.4,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                _buildLocationChip(context),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Notification bell
          _buildNotificationBell(dark),
        ],
      ),
    );
  }

  /// Location chip that opens the CityPromptBanner's picker when tapped.
  /// Uses HomeV2Controller (not the legacy HomeController which is not
  /// registered on the vezeeta path).
  Widget _buildLocationChip(BuildContext context) {
    if (!Get.isRegistered<HomeV2Controller>()) return const SizedBox.shrink();
    final controller = Get.find<HomeV2Controller>();
    return Obx(() {
      final dark = isDarkMode.value;
      String locationText;
      if (controller.chosenCityId != null) {
        locationText = locale.value.location;
      } else if (loginUserData.value.address.isNotEmpty) {
        locationText = loginUserData.value.address;
      } else {
        locationText = locale.value.chooseYourCity;
      }
      if (locationText.length > 30) {
        locationText = '${locationText.substring(0, 27)}...';
      }
      return GestureDetector(
        onTap: () {
          // Reuse the city picker from CityPromptBanner by opening it directly.
          // The CityPromptBanner._openPicker is private, so we show the same
          // bottom sheet inline here.
          _openCityPicker(context, controller);
        },
        child: Container(
          margin: const EdgeInsets.only(top: 3),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: dark ? surfaceElevatedDark : gray100,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: dark ? glassStrokeDark : gray200,
              width: 0.5,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.location_on_outlined,
                color: dark ? textTertiaryDark : secondaryTextColor,
                size: 12,
              ),
              const SizedBox(width: 4),
              Text(
                locationText,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.plusJakartaSans(
                  color: dark ? textSecondaryDark : secondaryTextColor,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                color: dark ? textTertiaryDark : gray400,
                size: 14,
              ),
            ],
          ),
        ),
      );
    });
  }

  void _openCityPicker(BuildContext context, HomeV2Controller controller) {
    int? pendingGov = controller.chosenGovernorateId;
    int? pendingCity = controller.chosenCityId;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDarkMode.value ? surfaceElevatedDark : surfaceElevated,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16, right: 16, top: 16,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                locale.value.chooseYourCity,
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: isDarkMode.value ? Colors.white : primaryTextColor,
                ),
              ),
              const SizedBox(height: 12),
              // GovernoratesCityPicker import is transitive through
              // city_prompt_banner.dart — add explicit import if needed:
              // import '../../../../components/governorates_city_picker.dart';
              _CityPickerInline(
                initialGov: pendingGov,
                initialCity: pendingCity,
                onGovChanged: (id) { pendingGov = id; pendingCity = null; },
                onCityChanged: (id) => pendingCity = id,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: appColorPrimary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  if (pendingGov != null && pendingCity != null) {
                    controller.setUserCity(
                      governorateId: pendingGov!,
                      cityId: pendingCity!,
                    );
                    Navigator.of(ctx).pop();
                  }
                },
                child: Text(
                  locale.value.confirm,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15, fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNotificationBell(bool dark) {
    return GestureDetector(
      onTap: () => doIfLoggedIn(() => Get.to(() => NotificationScreen())),
      behavior: HitTestBehavior.translucent,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: const EdgeInsets.all(11),
            decoration: BoxDecoration(
              color: dark ? surfaceElevatedDark : gray100,
              shape: BoxShape.circle,
              border: Border.all(
                color: dark ? glassStrokeDark : gray200,
                width: 1,
              ),
            ),
            child: CachedImageWidget(
              url: Assets.navigationIcNotifyOutlined,
              color: dark ? textPrimaryDark : primaryTextColor,
              height: 22,
            ),
          ),
          Positioned(
            top: -3,
            right: -3,
            child: Obx(
              () => unreadNotificationCount.value > 0
                  ? Container(
                      padding: const EdgeInsets.all(4),
                      constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
                      decoration: BoxDecoration(
                        color: cancelStatusColor,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: dark ? surfaceElevatedDark : Colors.white,
                          width: 1.5,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          unreadNotificationCount.value > 99
                              ? '99+'
                              : unreadNotificationCount.value.toString(),
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ),
        ],
      ),
    );
  }
}

/// Inline wrapper for GovernoratesCityPicker used in the bottom sheet.
/// Keeps the import isolated to this file.
class _CityPickerInline extends StatelessWidget {
  final int? initialGov;
  final int? initialCity;
  final ValueChanged<int?> onGovChanged;
  final ValueChanged<int?> onCityChanged;

  const _CityPickerInline({
    required this.initialGov,
    required this.initialCity,
    required this.onGovChanged,
    required this.onCityChanged,
  });

  @override
  Widget build(BuildContext context) {
    // Import GovernoratesCityPicker at the file level:
    // import '../../../../components/governorates_city_picker.dart';
    return const Placeholder(fallbackHeight: 120);
    // Replace with:
    // GovernoratesCityPicker(
    //   selectedGovernorateId: initialGov,
    //   selectedCityId: initialCity,
    //   onGovernorateChanged: onGovChanged,
    //   onCityChanged: onCityChanged,
    // );
  }
}
```

**Important:** The `_CityPickerInline` class is a placeholder stub. In the actual implementation, replace the `Placeholder` widget with `GovernoratesCityPicker` and add the import `import '../../../../components/governorates_city_picker.dart';` at the file level. The stub is shown here so the file compiles without the import — the implementing agent should wire it properly.

- [ ] **Step 2: Verify no analysis errors**

Run: `flutter analyze lib/screens/vezeeta/home_v2/components/home_greeting_header.dart`
Expected: No errors.

- [ ] **Step 3: Commit**

```bash
git add lib/screens/vezeeta/home_v2/components/home_greeting_header.dart
git commit -m "feat(home_v2): add flat greeting header component"
```

---

### Task 3: Create UpcomingAppointmentCard component

**Files:**
- Create: `lib/screens/vezeeta/home_v2/components/upcoming_appointment_card.dart`

- [ ] **Step 1: Create the upcoming appointment card widget**

```dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../main.dart';
import '../../../../utils/app_common.dart';
import '../../../../utils/colors.dart';
import '../../../booking/model/appointments_res_model.dart';
import '../../../dashboard/dashboard_controller.dart';

class UpcomingAppointmentCard extends StatelessWidget {
  final AppointmentData appointment;
  const UpcomingAppointmentCard({super.key, required this.appointment});

  @override
  Widget build(BuildContext context) {
    final dark = isDarkMode.value;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: _navigateToAppointments,
          child: Ink(
            decoration: BoxDecoration(
              color: dark ? surfaceElevatedDark : surfaceElevated,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: dark ? glassStrokeDark : gray200,
              ),
              boxShadow: [
                BoxShadow(
                  color: dark ? softShadowColorDark : softShadowColor,
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          locale.value.nextAppointment.toUpperCase(),
                          style: GoogleFonts.plusJakartaSans(
                            color: dark ? textTertiaryDark : secondaryTextColor,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          appointment.doctorName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.plusJakartaSans(
                            color: dark ? textPrimaryDark : primaryTextColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${appointment.appointmentDate} • ${appointment.appointmentTime}',
                          style: GoogleFonts.plusJakartaSans(
                            color: dark ? textSecondaryDark : secondaryTextColor,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: dark ? textTertiaryDark : gray400,
                    size: 18,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToAppointments() {
    if (Get.isRegistered<DashboardController>()) {
      Get.find<DashboardController>().currentIndex.value = 1;
    }
  }
}
```

- [ ] **Step 2: Verify no analysis errors**

Run: `flutter analyze lib/screens/vezeeta/home_v2/components/upcoming_appointment_card.dart`
Expected: No errors.

- [ ] **Step 3: Commit**

```bash
git add lib/screens/vezeeta/home_v2/components/upcoming_appointment_card.dart
git commit -m "feat(home_v2): add upcoming appointment card component"
```

---

### Task 4: Add upcoming appointment state to HomeV2Controller

**Files:**
- Modify: `lib/screens/vezeeta/home_v2/home_v2_controller.dart`

- [ ] **Step 1: Add imports and state variables**

Add imports at the top of the file, after the existing imports (skip any already present):

```dart
import '../../booking/model/appointments_res_model.dart';
import '../../../utils/common_base.dart';
```

Note: `CoreServiceApis` is already imported. `common_base.dart` provides `isLoggedIn`.

Add after the `offersError` declaration (around line 27):

```dart
final Rxn<AppointmentData> nextAppointment = Rxn<AppointmentData>();
final RxBool appointmentLoading = true.obs;
```

- [ ] **Step 2: Add `_loadNextAppointment` method**

Add after the `_loadOffers` method:

```dart
Future<void> _loadNextAppointment() async {
  if (!isLoggedIn.value) {
    appointmentLoading.value = false;
    nextAppointment.value = null;
    return;
  }
  appointmentLoading.value = true;
  try {
    final list = <AppointmentData>[];
    await CoreServiceApis.getAppointmentList(
      appointments: list,
      page: 1,
      perPage: 1,
      filterByStatus: 'upcoming',
    );
    nextAppointment.value = list.isNotEmpty ? list.first : null;
  } catch (_) {
    nextAppointment.value = null;
  } finally {
    appointmentLoading.value = false;
  }
}
```

- [ ] **Step 3: Add to `_loadAllInParallel` and `reloadAll`**

In `_loadAllInParallel`, add `_loadNextAppointment()` to the `Future.wait` list:

```dart
Future<void> _loadAllInParallel() async {
  _firstSectionEmitted = false;
  await Future.wait<void>([
    _loadSpecialties(),
    _loadNearbyDoctors(),
    _loadOffers(),
    _loadNextAppointment(),
  ]);
}
```

- [ ] **Step 4: Verify no analysis errors**

Run: `flutter analyze lib/screens/vezeeta/home_v2/home_v2_controller.dart`
Expected: No errors. Check that the `CoreServiceApis.getAppointmentList` method signature matches. If the method has a different name or parameters, adjust accordingly — look at `lib/api/core_apis.dart` around line 394 for the exact signature.

- [ ] **Step 5: Commit**

```bash
git add lib/screens/vezeeta/home_v2/home_v2_controller.dart
git commit -m "feat(home_v2): load upcoming appointment in controller"
```

---

### Task 5: Wire new sections into HomeV2Screen

**Files:**
- Modify: `lib/screens/vezeeta/home_v2/home_v2_screen.dart`

- [ ] **Step 1: Add imports for new components**

Add these imports at the top of the file:

```dart
import '../../home/components/quick_actions_grid.dart';
import '../../../utils/common_base.dart';
import 'components/home_greeting_header.dart';
import 'components/upcoming_appointment_card.dart';
```

- [ ] **Step 2: Insert new slivers into the CustomScrollView**

Replace the `slivers` list in the `CustomScrollView` (currently lines ~51-73) with:

```dart
slivers: [
  // Greeting header (flat, no gradient)
  const SliverToBoxAdapter(child: HomeGreetingHeader()),

  // Sticky search bar
  SliverPersistentHeader(
    pinned: true,
    delegate: StickySearchBarDelegate(
      onSelected: (s) => _handleSearchSelection(s),
    ),
  ),

  // Upcoming appointment (conditional)
  SliverToBoxAdapter(
    child: Obx(() {
      if (controller.appointmentLoading.value) return const SizedBox.shrink();
      final appt = controller.nextAppointment.value;
      if (appt == null) return const SizedBox.shrink();
      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: UpcomingAppointmentCard(appointment: appt),
      );
    }),
  ),

  // Quick actions grid (8 service tiles)
  const SliverToBoxAdapter(
    child: Padding(
      padding: EdgeInsets.only(bottom: 24),
      child: QuickActionsGrid(),
    ),
  ),

  // Specialties grid
  SliverToBoxAdapter(child: _SpecialtiesSliver(controller: controller)),

  // City prompt (when no city selected)
  SliverToBoxAdapter(
    child: Obx(() => controller.needsCityPrompt.value
        ? CityPromptBanner(controller: controller)
        : const SizedBox.shrink()),
  ),

  // Nearby doctors
  SliverToBoxAdapter(
    child: NearbyDoctorsSection(controller: controller),
  ),

  // Offers strip
  SliverToBoxAdapter(child: OffersStrip(controller: controller)),

  // Bottom spacing for nav bar clearance
  const SliverToBoxAdapter(child: SizedBox(height: 90)),
],
```

- [ ] **Step 3: Verify no analysis errors**

Run: `flutter analyze lib/screens/vezeeta/home_v2/home_v2_screen.dart`
Expected: No errors.

- [ ] **Step 4: Commit**

```bash
git add lib/screens/vezeeta/home_v2/home_v2_screen.dart
git commit -m "feat(home_v2): wire greeting, quick actions, upcoming appointment into screen"
```

---

### Task 6: Verify the appointment API call compiles

**Files:** None to modify — verification only.

- [ ] **Step 1: Check `CoreServiceApis.getAppointmentList` signature**

Confirm the method at `lib/api/core_apis.dart:370` matches the call in Task 4 Step 2. The actual signature is:

```dart
static Future<RxList<AppointmentData>> getAppointmentList({
  String filterByStatus = '',
  String filterByService = '',
  int page = 1,
  String search = '',
  int perPage = Constants.perPageItem,
  required List<AppointmentData> appointments,
  Function(bool)? lastPageCallBack,
})
```

The Task 4 call uses `appointments:`, `filterByStatus:`, `page:`, `perPage:` — all matching.

- [ ] **Step 2: Run full analysis**

Run: `flutter analyze lib/screens/vezeeta/home_v2/`
Expected: No errors across all files in the home_v2 directory.

- [ ] **Step 3: Run the app**

Run: `flutter run` on the connected device/emulator. Verify:
1. App launches and shows the HomeV2 screen (since `useVezeetaHome = true`)
2. Greeting header appears at top with user name and location chip
3. Sticky search bar pins below greeting on scroll
4. Quick actions grid (8 tiles) shows below search bar
5. Upcoming appointment card appears when logged in with appointments (or is absent when not)
6. Specialties grid, nearby doctors, offers strip all render below

- [ ] **Step 4: Commit any fixes**

If Step 1 required signature adjustments:

```bash
git add lib/screens/vezeeta/home_v2/home_v2_controller.dart
git commit -m "fix(home_v2): align appointment API call with actual method signature"
```
