# Home V2 — Vezeeta-Inspired Homepage

## Summary

A clean, flat, Vezeeta-inspired replacement for the current `HomeScreen`. Removes the navy gradient header and 14 staggered legacy sections in favor of a focused 6-section layout on a white background. A/B switchable via a config constant so both screens coexist during development.

## Goals

- Faster perceived load — fewer sections, no staggered animations
- Vezeeta-like clarity — search-first, services grid, curated content
- Reuse existing components and `HomeController` — no new API calls or data models
- Clean swap mechanism — flip one constant to switch between old and new

## Switch Mechanism

A compile-time constant in `lib/configs.dart`:

```dart
const bool useHomeV2 = true;
```

`DashboardController.screen` list reads this flag to instantiate either `HomeScreen()` or `HomeV2Screen()`. No runtime logic, no local storage, no remote config.

## Files to Create

| File | Purpose |
|------|---------|
| `lib/screens/home_v2/home_v2_screen.dart` | Main screen — composes all sections in a `CustomScrollView` |
| `lib/screens/home_v2/components/home_greeting_header.dart` | Flat greeting row: avatar, name, location chip, notification bell |
| `lib/screens/home_v2/components/home_search_bar.dart` | Fake search input that navigates to `SearchHubScreen` on tap |
| `lib/screens/home_v2/components/upcoming_appointment_card.dart` | Compact next-appointment reminder card |

## Files to Modify

| File | Change |
|------|--------|
| `lib/configs.dart` | Add `const bool useHomeV2 = true;` |
| `lib/screens/dashboard/dashboard_controller.dart` | Conditional: `useHomeV2 ? HomeV2Screen() : HomeScreen()` in `screen` list |

## Layout Structure

```
Scaffold (scaffoldBackgroundColor, no gradient)
└── RefreshIndicator
    └── CustomScrollView (AlwaysScrollableScrollPhysics)
        ├── SliverToBoxAdapter: HomeGreetingHeader
        ├── SliverToBoxAdapter: HomeSearchBar          (tap → SearchHubScreen)
        ├── SliverToBoxAdapter: UpcomingAppointmentCard (conditional: logged in + has appointments)
        ├── SliverToBoxAdapter: QuickActionsGrid        (existing widget, unchanged)
        ├── SliverToBoxAdapter: OffersCarousel           (existing widget, unchanged)
        ├── SliverToBoxAdapter: PopularSpecialties       (existing widget, unchanged)
        ├── SliverToBoxAdapter: TopRatedDoctors          (existing widget, unchanged)
        ├── SliverToBoxAdapter: NearbyClinics             (existing widget, unchanged)
        └── SliverToBoxAdapter: 90px bottom spacing
```

No `SliverAppBar`. No collapsing behavior. Simple flat scroll.

## Component Specs

### HomeGreetingHeader

**Location:** `lib/screens/home_v2/components/home_greeting_header.dart`

Flat white background. Padded 24px horizontal, respects `context.statusBarHeight` at top.

Layout:
```
Row
├── Profile avatar (46px circle, conditional on having profile image URL)
├── 12px gap
├── Column (expanded)
│   ├── Row: time icon + "Good Morning" (secondaryTextColor, 12px)
│   ├── 2px gap
│   ├── User name or "Guest" (primaryTextColor, 21px, bold)
│   └── Location chip (tappable → LocationSelectorSheet)
├── 16px gap
└── Notification bell with unread badge
```

Reuses the same logic from current `GreetingsComponent` but with light-theme colors instead of white-on-gradient. No animations on the avatar.

### HomeSearchBar

**Location:** `lib/screens/home_v2/components/home_search_bar.dart`

A `GestureDetector` wrapping a styled `Container`:
- Background: `surfaceElevated` (white)
- Border: 1px `gray200`
- Border radius: 14px
- Shadow: `softShadowColor` with 8px blur, 2px vertical offset
- Padding: 15px vertical, 16px horizontal
- Content: Row with teal search icon + placeholder text in `gray400`
- Horizontal margin: 24px

On tap: `Get.to(() => const SearchHubScreen())`

### UpcomingAppointmentCard

**Location:** `lib/screens/home_v2/components/upcoming_appointment_card.dart`

Only rendered when `isLoggedIn.value == true` and `dashboardData.upcomingAppointment.isNotEmpty`. Takes the first appointment from the list.

Compact horizontal card:
- Background: `surfaceElevated`
- Border: 1px `gray200`
- Border radius: 16px
- Shadow: `softShadowColor`, 8px blur
- Horizontal margin: 24px
- Padding: 14px

Content layout:
```
Row
├── Column (expanded)
│   ├── "Next Appointment" label (secondaryTextColor, 11px, uppercase, w500)
│   ├── 4px gap
│   ├── Doctor name (primaryTextColor, 14px, w700)
│   ├── 2px gap
│   └── Date + time (secondaryTextColor, 12px)
├── Forward arrow icon (gray400, 18px)
```

On tap: switches to the Appointments tab by setting `DashboardController.currentIndex` to 1.

### Section Spacing

No gradient dividers. Vertical spacing creates natural separation:

| After | Spacing |
|-------|---------|
| Status bar + greeting header | 16px |
| Search bar | 16px |
| Upcoming appointment card | 24px |
| Quick actions grid | 24px |
| Offers carousel | 24px |
| Popular specialties | 24px |
| Top rated doctors | 24px |
| Nearby clinics | 90px (bottom nav clearance) |

When upcoming appointment card is absent, its 16px spacing disappears — quick actions grid moves up naturally.

## Loading & Error States

**Loading:** Reuses `HomeController.isLoading`. While loading, show a centered `LoaderWidget` (existing). Individual sections already handle their own shimmer states.

**Error:** If `getDashboardDetailFuture` fails, show existing `NoDataWidget` with retry button, same as current HomeScreen.

**Pull-to-refresh:** `RefreshIndicator` wraps the `CustomScrollView`, calls `homeScreenController.getDashboardDetail(isFromSwipeRefresh: true)`.

## What's Excluded

These current HomeScreen sections are intentionally removed:
- `ChooseCategoryComponents` (replaced by `PopularSpecialties`)
- `SliderComponent` (replaced by `OffersCarousel`)
- `DoctorQuickBookComponent` (booking flow starts from doctor cards or quick actions)
- `QuickServicesComponent` (covered by `QuickActionsGrid`)
- `PopularDoctorComponent` (replaced by `TopRatedDoctors`)
- `PopularServiceComponent` (not needed — services reachable via quick actions)
- `PerfectClinicComponent` (replaced by `NearbyClinics`)
- `PharmacyPromoBanner` (reachable via quick actions grid)
- Staggered fade-in animations
- Gradient section dividers
- Navy gradient header background

## Dark Mode

All new components use the existing color token pattern:
- `isDarkMode.value ? surfaceElevatedDark : surfaceElevated`
- `isDarkMode.value ? textPrimaryDark : primaryTextColor`
- etc.

The flat layout works well in dark mode — `scaffoldBackgroundColor` handles the page background automatically via the theme.

## RTL Support

No special RTL handling needed. All layouts use `Row`/`Column` with `CrossAxisAlignment.start`, which Flutter mirrors automatically. The `EdgeInsetsDirectional` pattern from `GreetingsComponent` is carried over to the greeting header.
