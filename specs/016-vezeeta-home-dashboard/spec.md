# Feature Specification: Vezeeta-Style Home Dashboard

**Feature Branch**: `016-vezeeta-home-dashboard`
**Created**: 2026-04-16
**Status**: Draft
**Input**: User description: "Revamp Home Screen to Vezeeta-Style Dashboard with collapsing SliverAppBar, QuickActionsGrid (8 services), OffersCarousel with auto-scroll, PopularSpecialties chips, TopRatedDoctors cards, NearbyClinics section, and PharmacyPromoBanner. Parallel data loading with per-section shimmer."

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Quick Access to Healthcare Services (Priority: P1)

A patient opens the app and immediately sees a grid of healthcare services (Book Doctor, Labs, Radiology, Pharmacy, Home Nursing, ICU, Home Visit, Online Consult). They tap on the service they need and navigate directly to that service's screen.

**Why this priority**: Core navigation is the primary purpose of the home screen - users must be able to quickly find and access services. This is the most frequently used feature.

**Independent Test**: Can be fully tested by tapping each service tile and verifying navigation to the correct destination screen.

**Acceptance Scenarios**:

1. **Given** user is on home screen, **When** they view the QuickActionsGrid, **Then** they see 8 service tiles in a 2x4 grid layout
2. **Given** user taps "Book Doctor" tile, **When** navigation completes, **Then** they arrive at DoctorSearchScreen
3. **Given** user taps any service tile, **When** tile is pressed, **Then** they see visual feedback (scale/opacity animation) before navigation
4. **Given** user is using Arabic locale, **When** they view QuickActionsGrid, **Then** all labels display in Arabic and layout is RTL

---

### User Story 2 - Discover Special Offers (Priority: P1)

A patient views the home screen and sees a rotating carousel of current offers/promotions. The carousel auto-scrolls every 5 seconds. They can swipe manually or tap an offer to see details or be directed to the relevant service.

**Why this priority**: Offers drive engagement and conversions - they're a key business requirement and users expect to see promotions prominently.

**Independent Test**: Can be tested by verifying carousel loads offers from API, auto-scrolls at 5s intervals, and tap navigates correctly.

**Acceptance Scenarios**:

1. **Given** offers exist in the system, **When** home screen loads, **Then** OffersCarousel displays banner images with title and discount label
2. **Given** carousel has multiple offers, **When** 5 seconds pass, **Then** carousel animates to the next slide
3. **Given** user taps an offer, **When** offer has a linked service, **Then** user navigates to that service's filtered list or detail
4. **Given** no offers exist, **When** home screen loads, **Then** OffersCarousel section is hidden (not an empty state)
5. **Given** carousel is visible, **When** user views it, **Then** they see page indicator dots showing current position

---

### User Story 3 - Browse Popular Specialties (Priority: P2)

A patient wants to find a doctor by specialty. They see a horizontal list of specialty chips below the offers carousel and tap on a specialty to see doctors in that specialty.

**Why this priority**: Specialty-based search is a common user flow, but secondary to direct service access.

**Independent Test**: Can be tested by verifying chips load from categories API and tapping navigates to filtered doctor list.

**Acceptance Scenarios**:

1. **Given** categories exist in the system, **When** home screen loads, **Then** PopularSpecialties displays horizontal scrolling chip list
2. **Given** user taps a specialty chip, **When** navigation completes, **Then** they see doctor list filtered by that specialty
3. **Given** user scrolls horizontally, **When** more chips exist off-screen, **Then** they can reveal additional specialty chips

---

### User Story 4 - Discover Top-Rated Doctors (Priority: P2)

A patient wants to find highly-rated doctors. They see a horizontal list of top-rated doctor cards with photos, names, specialties, ratings, and offer badges (if applicable). They tap a doctor card to view their profile.

**Why this priority**: Doctor discovery is important but users often arrive via specialty or search rather than browsing.

**Independent Test**: Can be tested by verifying doctor cards load with is_popular=1 filter and tap navigates to doctor detail.

**Acceptance Scenarios**:

1. **Given** popular doctors exist, **When** home screen loads, **Then** TopRatedDoctors displays 160x220 horizontal cards
2. **Given** doctor has active offer, **When** card displays, **Then** offer badge overlay shows discount percentage
3. **Given** user taps a doctor card, **When** navigation completes, **Then** they arrive at doctor detail screen
4. **Given** user views a doctor card, **When** card renders, **Then** they see photo, name, specialty, and star rating

---

### User Story 5 - Find Nearby Clinics (Priority: P2)

A patient wants to find clinics near their location. The app uses their device location to show nearby clinics in a horizontal card list. They can tap a clinic to view details.

**Why this priority**: Location-based discovery is valuable but requires permission and not all users enable location services.

**Independent Test**: Can be tested by mocking location and verifying clinic cards display with distance, or graceful handling when location is unavailable.

**Acceptance Scenarios**:

1. **Given** user has granted location permission, **When** home screen loads, **Then** NearbyClinics section shows clinics sorted by distance
2. **Given** location permission is denied, **When** home screen loads, **Then** NearbyClinics section displays a prompt to enable location or is hidden
3. **Given** user taps a clinic card, **When** navigation completes, **Then** they arrive at clinic detail screen
4. **Given** clinics are loading, **When** API request is in progress, **Then** shimmer placeholder displays

---

### User Story 6 - Personalized Greeting & Location (Priority: P3)

A logged-in patient sees a collapsing app bar with their name, profile avatar, and selected location (governorate/city). They can tap the location chip to change their preferred location for filtering results.

**Why this priority**: Personalization enhances user experience but is not critical to core functionality.

**Independent Test**: Can be tested by verifying greeting shows user name, avatar loads, and location selector opens bottom sheet.

**Acceptance Scenarios**:

1. **Given** user is logged in, **When** home screen loads, **Then** greeting shows "مرحباً، {name}" with profile avatar
2. **Given** user is not logged in, **When** home screen loads, **Then** greeting shows "مرحباً، Guest" with placeholder avatar
3. **Given** user taps location chip, **When** bottom sheet opens, **Then** they can select governorate and city
4. **Given** user scrolls down, **When** scroll offset increases, **Then** SliverAppBar collapses smoothly

---

### User Story 7 - Quick Search Access (Priority: P3)

A patient wants to search across all services. They see a search bar in the app bar and tap it to open the unified search screen.

**Why this priority**: Search is an alternative navigation path, most users prefer direct service access.

**Independent Test**: Can be tested by tapping search bar and verifying navigation to SearchHubScreen.

**Acceptance Scenarios**:

1. **Given** user is on home screen, **When** they view the SliverAppBar, **Then** they see a search bar with placeholder text
2. **Given** user taps search bar, **When** navigation completes, **Then** they arrive at SearchHubScreen

---

### User Story 8 - Pharmacy Promotion (Priority: P3)

A patient sees a promotional banner for the pharmacy module at the bottom of the home screen. They tap it to open the pharmacy marketplace.

**Why this priority**: Pharmacy is a newer module that benefits from promotion, but is not a primary use case.

**Independent Test**: Can be tested by verifying banner displays and tap navigates to PharmacyHomeScreen.

**Acceptance Scenarios**:

1. **Given** user scrolls to bottom of home screen, **When** they view PharmacyPromoBanner, **Then** they see an attractive CTA banner for pharmacy
2. **Given** user taps PharmacyPromoBanner, **When** navigation completes, **Then** they arrive at PharmacyCategoriesScreen

---

### Edge Cases

- What happens when all API calls fail? → Show error state with retry button and cached data if available
- What happens when user has slow connection? → Show per-section shimmer placeholders while loading
- What happens when location services return stale data? → Display cached clinics with "updating..." indicator
- What happens when offers API returns empty? → Hide OffersCarousel section entirely (no empty state)
- What happens when user rapidly taps multiple service tiles? → Debounce navigation to prevent double-navigation

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST display QuickActionsGrid with 8 service tiles in 2x4 layout (Book Doctor, Labs, Radiology, Pharmacy, Home Nursing, ICU, Home Visit, Online Consult)
- **FR-002**: System MUST navigate to correct destination screen when user taps a service tile
- **FR-003**: System MUST fetch and display offers from OffersApis.getPublicOffers() in OffersCarousel
- **FR-004**: System MUST auto-scroll OffersCarousel every 5 seconds when multiple offers exist
- **FR-005**: System MUST display page indicator dots for OffersCarousel showing current position
- **FR-006**: System MUST hide OffersCarousel when no offers are available (not show empty state)
- **FR-007**: System MUST fetch categories from get-category-list API and display as PopularSpecialties chips
- **FR-008**: System MUST navigate to filtered doctor list when user taps a specialty chip
- **FR-009**: System MUST fetch popular doctors with is_popular=1 filter and display as TopRatedDoctors cards
- **FR-010**: System MUST display offer badge overlay on doctor cards when has_active_offer is true
- **FR-011**: System MUST use Geolocator to get user location and fetch nearby clinics
- **FR-012**: System MUST display NearbyClinics sorted by distance when location is available
- **FR-013**: System MUST handle location permission gracefully (hide section or show prompt)
- **FR-014**: System MUST display collapsing SliverAppBar with greeting, avatar, location, and search
- **FR-015**: System MUST show personalized greeting with user name when logged in
- **FR-016**: System MUST support pull-to-refresh to reload all sections
- **FR-017**: System MUST fire all data loading requests in parallel using Future.wait()
- **FR-018**: System MUST display per-section shimmer placeholders while each section loads
- **FR-019**: System MUST support both English and Arabic locales with RTL layout
- **FR-020**: System MUST display PharmacyPromoBanner at bottom with CTA to pharmacy module

### Key Entities

- **Offer**: Promotional offer with title, description, banner image, discount value, dates (already exists in offer_model.dart)
- **Category/Specialty**: Healthcare category for filtering (exists in dashboard model)
- **Doctor**: Healthcare provider with name, specialty, rating, offer status (exists in doctor models)
- **Clinic**: Healthcare facility with location, name, services (exists in clinic models)
- **UserLocation**: Governorate and city selection for location-based filtering

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Home screen fully loads (all sections visible or hidden if empty) in under 3 seconds on 4G connection
- **SC-002**: User can navigate to any service from home screen in under 2 taps
- **SC-003**: 95% of users can locate the service they need within 5 seconds of opening the app
- **SC-004**: Pull-to-refresh completes and updates all sections in under 4 seconds
- **SC-005**: Auto-scroll carousel maintains 5-second interval timing with less than 100ms variance
- **SC-006**: Screen supports 10,000+ concurrent users without degradation
- **SC-007**: RTL layout displays correctly for 100% of Arabic-locale users
- **SC-008**: Location-based nearby clinics update within 2 seconds of location change

## Assumptions

- Existing OffersApis.getPublicOffers() returns active offers suitable for carousel display
- Dashboard API continues to provide categories, doctors, and clinics data
- Geolocator package is already configured in the project for location services
- Design tokens (colors, gradients, radii) are already defined in colors.dart
- All destination screens (Labs, Radiology, Pharmacy, etc.) already exist in the codebase

## Out of Scope

- Creating new API endpoints - using existing endpoints only
- Modifying backend offer logic
- Implementing location permission request flows (use existing patterns)
- Creating new destination screens (e.g., NursingScreen, IcuScreen) if they don't exist
- Analytics/tracking implementation for home screen engagement

## Design Guidelines (Implementation Reference)

The following are implementation hints for the planning phase:

- **Card radius**: 16px
- **Input radius**: 12px
- **Section header padding**: 24px
- **Shadows**: Navy-tinted soft shadows (softShadowColor token)
- **Fonts**: GoogleFonts.plusJakartaSans (body), GoogleFonts.outfit (headings at 18pt semibold)
- **Offer badges**: gradientSecondaryStart → gradientSecondaryEnd gradient, white text
- **Quick action tiles**: 88x88 tap target with gradient icon circle
- **Doctor cards**: 160x220 size
- **Specialty chips**: 44px height

## Localization Keys Required

New locale keys to be added to language_en.dart and language_ar.dart:
- bookDoctor
- labs (may exist, verify)
- radiology (may exist, verify)
- pharmacy (may exist, verify)
- homeNursing
- icu
- homeVisit
- onlineConsult
- popularSpecialties
- topRatedDoctors
- nearbyClinics
- specialOffers
- greeting
- selectLocation
- searchHint
