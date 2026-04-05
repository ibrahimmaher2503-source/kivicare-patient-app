
# Feature Specification: Unified Doctor-First Booking Experience

**Feature Branch**: `010-unified-doctor-booking`
**Created**: 2026-04-02
**Status**: Draft
**Input**: Restructure the Espitalia patient app to prioritize direct doctor booking over clinic-based booking. Unify the fragmented doctor components (4 card variants, 3 list screens, 3 detail screens, 3 models) into a single cohesive doctor experience. Reorder the home screen to put doctors first, and make "Find a Doctor" the primary booking path.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Doctor-First Home Screen Layout (Priority: P1)

A patient opens the app and immediately sees doctors as the primary booking path. Popular doctors appear prominently near the top of the home screen (before clinics and services). The quick service cards prioritize doctor-direct options ("Book a Doctor", "Video Consult") over facility-based services. The patient can tap a popular doctor and reach a booking flow within 2 taps.

**Why this priority**: The home screen is the first thing every user sees. Reordering sections and cards requires minimal code changes but fundamentally shifts the app's perceived purpose from "find a clinic" to "find a doctor."

**Independent Test**: Can be fully tested by opening the app and verifying section order, card order, and that tapping a popular doctor leads to a bookable profile. Delivers immediate UX improvement with no backend changes.

**Acceptance Scenarios**:

1. **Given** the patient opens the home screen, **When** they scroll down, **Then** Popular Doctors section appears before Popular Clinics section and before Popular Services section.
2. **Given** the patient views the Quick Services horizontal cards, **When** they see the card list, **Then** "Book a Doctor" (renamed from "Independent Booking") appears as the 2nd card and "Video Consult" (renamed from "Call Booking") appears as the 3rd card.
3. **Given** the patient taps a Popular Doctor card, **When** the doctor detail opens, **Then** a visible "Book Appointment" action is available (not just About/Services/Reviews tabs).

---

### User Story 2 - Unified Doctor Card with Booking Options (Priority: P2)

A patient browsing any doctor list sees a single consistent doctor card design regardless of how they got there. Each card shows the doctor's name, photo, specialty, rating, and badges indicating which booking types are available for that doctor (clinic-based, video call, phone call, in-person). Each badge displays a starting price. The patient can tap a badge to jump directly to that booking flow, or tap the card to see the full profile.

**Why this priority**: The current app has 4 different card designs showing the same doctor differently depending on context. This confuses patients and forces them to know which booking type they want before they can browse. A unified card lets them discover options naturally.

**Independent Test**: Can be tested by navigating to any doctor list and verifying the card shows all available booking options for each doctor. Delivers a coherent browsing experience.

**Acceptance Scenarios**:

1. **Given** a doctor is available for both clinic and in-person booking, **When** the patient views that doctor's card, **Then** both booking type badges are visible on the same card with respective starting prices.
2. **Given** a doctor only offers video consultations, **When** the patient views that doctor's card, **Then** only the video call badge appears (no empty or disabled badges for unavailable types).
3. **Given** the patient taps a booking type badge on the card, **When** the badge is tapped, **Then** they navigate directly to the booking flow for that type (date/slot selection) without going through the detail screen first.
4. **Given** the patient taps the card body (not a badge), **When** the card is tapped, **Then** they navigate to the unified doctor detail screen.

---

### User Story 3 - Unified Doctor Detail with Booking Tabs (Priority: P3)

A patient viewing a doctor's profile sees a single comprehensive detail screen with all information and booking options in one place. The screen has a hero section (photo, name, specialty, rating, stats) followed by tabs: Book, About, Reviews, Qualifications. The "Book" tab is the default active tab and shows all available booking methods for this doctor (clinic-based, video/phone call, in-person) as expandable sections, each with its own service selection, date picker, and slot picker.

**Why this priority**: Currently 3 separate detail screens exist. Merging them into one eliminates the need for patients to know which booking type they want upfront, and lets them compare options (price, availability) side by side.

**Independent Test**: Can be tested by navigating to any doctor's profile and verifying all booking options, about info, reviews, and qualifications are accessible from one screen. Delivers a complete doctor profile experience.

**Acceptance Scenarios**:

1. **Given** the patient opens a doctor's detail screen, **When** the screen loads, **Then** the "Book" tab is selected by default showing available booking methods.
2. **Given** a doctor offers clinic-based, video, and in-person services, **When** the patient views the Book tab, **Then** three booking method sections are displayed with distinct labels and icons (e.g., "At Clinic", "Video Call", "In-Person Visit").
3. **Given** the patient selects "Video Call" booking method, **When** they pick a service and date, **Then** available time slots for that specific booking type load correctly.
4. **Given** the patient switches from the Book tab to About, **When** they view the About section, **Then** doctor bio, contact info, specialization, and social links are displayed.
5. **Given** the patient wants to see reviews, **When** they tap the Reviews tab, **Then** paginated reviews with ratings, comments, and reviewer info load correctly.

---

### User Story 4 - Doctor-First Quick Book Widget (Priority: P4)

The current home screen QuickBookComponent (Service -> Clinic -> Date -> Time) is replaced with a doctor-first quick booking widget. The patient types a doctor name or specialty, selects from results, picks a booking type, then proceeds to date/slot selection -- all without leaving the home screen card.

**Why this priority**: The QuickBook widget is the most prominent booking CTA on the home screen. Changing it from clinic-first to doctor-first signals the app's new direction. However, this requires more significant UI changes than the previous stories.

**Independent Test**: Can be tested by using the quick book widget on the home screen to search for a doctor by name, select them, choose a booking type, and complete a booking. Delivers a streamlined doctor-first booking path.

**Acceptance Scenarios**:

1. **Given** the patient views the home screen QuickBook section, **When** they see the first input field, **Then** it reads "Search doctor or specialty" (not "Select Service").
2. **Given** the patient types a doctor name or specialty, **When** results appear, **Then** matching doctors are shown with their photo, name, specialty, and available booking types.
3. **Given** the patient selects a doctor from search results, **When** they choose a booking type, **Then** the date picker becomes available and shows dates with slot availability.
4. **Given** the patient completes all fields (doctor, booking type, date, time), **When** they tap "Book Now", **Then** the booking is created and a confirmation is shown.

---

### User Story 5 - Consistent Patient-Friendly Labels (Priority: P5)

All user-facing labels are updated to remove technical jargon. "Independent Booking" becomes "Book a Doctor" or "In-Person Visit". "Call Booking" becomes "Video Consult". Quick service cards, My Requests tiles, and all screen titles use the new patient-friendly terminology consistently across all supported languages.

**Why this priority**: Naming changes are low-effort but high-impact for user comprehension. Patients should not need to understand the system's internal categorization.

**Independent Test**: Can be tested by navigating through all screens and verifying no instance of "Independent Booking" or "Call Booking" appears in user-facing text. Delivers clarity for all users.

**Acceptance Scenarios**:

1. **Given** the patient views the Quick Services section, **When** they see the doctor booking cards, **Then** they read "Book a Doctor" and "Video Consult" (not "Independent Booking" and "Call Booking").
2. **Given** the patient views the My Requests section, **When** they see request tiles, **Then** they read "My Doctor Appointments" and "My Video Consults" (not "My Independent Bookings" and "My Call Bookings").
3. **Given** the patient is on any screen title or app bar, **When** they read the title, **Then** it uses the updated patient-friendly label.

---

### Edge Cases

- What happens when a doctor has no booking types available (e.g., all services disabled)? The card should still appear but with a "Currently Unavailable" indicator and no booking badges.
- What happens when the patient taps a booking badge but the doctor has no available slots for that type? The booking flow opens and shows "No slots available -- try another date" with the date picker pre-focused.
- What happens when the backend returns doctor data in the old format (separate endpoints)? The unified card gracefully handles partial data -- missing booking types are simply not shown as badges.
- How does the unified detail screen handle a doctor who exists in the clinic system but not in the independent booking system? Only the "At Clinic" booking method section appears; other sections are hidden.
- What happens when search returns doctors from multiple booking systems with duplicate entries? Results are deduplicated by doctor ID, merging booking capabilities into one entry.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: Home screen MUST display sections in this order: Categories, Slider, QuickBook, QuickServices, Upcoming Appointments, Popular Doctors, Popular Services, Popular Clinics.
- **FR-002**: Quick Services cards MUST be ordered with "Search Providers" first, "Book a Doctor" second, "Video Consult" third, followed by remaining services.
- **FR-003**: The unified doctor card MUST display: profile photo, doctor name, specialty, star rating with review count, and one badge per available booking type showing starting price.
- **FR-004**: Booking type badges on the unified doctor card MUST be tappable and navigate directly to the booking flow for that type.
- **FR-005**: The unified doctor detail screen MUST have tabs: Book (default), About, Reviews, Qualifications.
- **FR-006**: The Book tab MUST display separate expandable sections for each available booking method (At Clinic, Video Call, Phone Call, In-Person Visit).
- **FR-007**: Each booking method section MUST allow service selection, date selection, and time slot selection independently.
- **FR-008**: The QuickBook home widget MUST allow searching by doctor name or specialty as the primary input.
- **FR-009**: All user-facing labels MUST use patient-friendly terminology: "Book a Doctor" (not "Independent Booking"), "Video Consult" (not "Call Booking").
- **FR-010**: The unified doctor card MUST be used consistently across all doctor listing contexts (home popular, search results, category browsing, clinic doctors).
- **FR-011**: Popular Doctor cards on the home screen MUST include a visible "Book" action that opens a booking type selector.
- **FR-012**: The My Requests section MUST use updated labels: "My Doctor Appointments", "My Video Consults".
- **FR-013**: Doctor search results MUST be deduplicated by doctor identity, merging booking capabilities from all systems into a single result.
- **FR-014**: The system MUST gracefully handle doctors with partial booking availability (only some types enabled) by showing only available options.

### Key Entities

- **UnifiedDoctor**: A single representation of a doctor combining data from clinic-based, call-based, and independent booking systems. Key attributes: identity (name, photo, specialty), professional info (rating, experience, qualifications), contact info, location, and a list of available booking capabilities with associated services and pricing.
- **BookingCapability**: Represents one booking method available for a doctor. Key attributes: type (clinic, video-call, phone-call, in-person), associated services, starting price, availability status.
- **BookingMethod**: The specific booking flow a patient selects. Key attributes: type, selected service, selected date, selected time slot, payment method.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Patients can find and begin booking a doctor within 2 taps from the home screen (currently requires 3-4 taps depending on path).
- **SC-002**: 100% of doctor listings across the app use the unified card design (currently 4 different designs exist).
- **SC-003**: Patients can view all booking options for a single doctor on one screen (currently requires navigating to 3 separate flows to discover all options).
- **SC-004**: Zero instances of "Independent Booking" or "Call Booking" appear in user-facing text after implementation.
- **SC-005**: The home screen shows doctor-focused content (Popular Doctors) within the first 2 scroll sections after the slider.
- **SC-006**: Patients can complete a booking from the home screen QuickBook widget in under 4 interactions (search doctor, select doctor, select date, select slot).
- **SC-007**: All existing booking flows (clinic-based, call, independent) continue to function correctly through the unified interface with no loss of functionality.

## Assumptions

- The backend API can provide (or be extended to provide) a unified doctor endpoint that includes booking capabilities across all systems, or the frontend can aggregate data from existing separate endpoints.
- The existing separate booking APIs (clinic slots, call slots, independent slots) will remain functional and be called from the unified detail screen based on which booking method the patient selects.
- Doctor identity is consistent across booking systems (same doctor ID or a reliable mapping exists between clinic doctor records, call doctor records, and independent doctor records).
- The current 3 separate doctor models share enough common fields (name, photo, specialty, rating) to be unified without data loss.
- Locale/translation files can be updated with new label keys without breaking existing translations -- old keys can be deprecated gradually.
