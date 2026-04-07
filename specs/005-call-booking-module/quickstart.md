# Quickstart: Call Booking Module

**Branch**: `005-call-booking-module`

## Setup

```bash
git checkout 005-call-booking-module
flutter pub get
flutter run
```

## Verify

### 1. Browse Call Doctors
1. Open app → Home → "Call Booking"
2. Verify: doctor list loads with name, specialty, rating, starting price
3. Search for a doctor → verify results
4. Tap a doctor → verify profile + call services with pricing

### 2. Book a Call
1. From doctor detail, tap a call service
2. Pick a date → verify time slots load
3. Select a time slot
4. Confirm booking → verify confirmation with meeting link (video)

### 3. View My Bookings
1. Home → "My Call Bookings"
2. Verify: booking list with doctor, date, time, type, status
3. Tap a video booking → verify "Join Call" button with meeting link

### 4. Dark Mode + Localization
1. Toggle dark mode → navigate all call booking screens
2. Switch to Arabic → verify RTL layout
