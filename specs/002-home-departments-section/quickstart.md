# Quickstart: Home Page Departments Section

**Branch**: `002-home-departments-section`
**Date**: 2026-03-02

## What This Feature Does

Adds a "Departments" section to the home screen displaying five
hospital department cards: Doctors, Clinics, Radiology, Intensive
Care, and Nurse Requests. Doctors and Clinics are active and
navigate to existing screens. The other three display "Coming Soon".

## Files Modified

| File | Change |
|------|--------|
| `lib/screens/home/home_screen.dart` | Add `DepartmentsComponent` between slider and quick book |
| `lib/locale/languages.dart` | Add new locale key abstractions |
| `lib/locale/language_en.dart` | Add English translations |
| `lib/locale/language_ar.dart` | Add Arabic translations |
| `lib/locale/language_de.dart` | Add German translations |
| `lib/locale/language_fr.dart` | Add French translations |
| `lib/locale/language_hi.dart` | Add Hindi translations |

## Files Created

| File | Purpose |
|------|---------|
| `lib/screens/home/components/departments_component.dart` | Section widget with department cards |
| `lib/screens/home/components/department_card_widget.dart` | Individual department card widget |
| `assets/icons/ic_department_doctors.png` | Doctors department icon |
| `assets/icons/ic_department_clinics.png` | Clinics department icon |
| `assets/icons/ic_department_radiology.png` | Radiology department icon |
| `assets/icons/ic_department_intensive_care.png` | Intensive Care department icon |
| `assets/icons/ic_department_nurse_requests.png` | Nurse Requests department icon |

## How to Verify

1. Run `flutter pub get`
2. Run `flutter run` on Android emulator
3. On the home screen, scroll down past the banner carousel
4. Verify the "Departments" section appears with five cards
5. Tap "Doctors" — should navigate to doctor listing screen
6. Tap "Clinics" — should navigate to clinic listing screen
7. Tap "Radiology" — should show "Coming Soon" toast
8. Tap "Intensive Care" — should show "Coming Soon" toast
9. Tap "Nurse Requests" — should show "Coming Soon" toast
10. Toggle dark mode in settings — verify cards render correctly
11. Switch language to Arabic — verify RTL layout and translated text

## How to Activate a Coming-Soon Department

When a department's backend functionality is ready:

1. Open `lib/screens/home/components/departments_component.dart`
2. Find the department in the static list
3. Change `isActive: false` to `isActive: true`
4. Add an `onTap` callback with navigation:
   ```dart
   onTap: () => Get.to(() => NewDepartmentScreen()),
   ```
5. Run and verify
