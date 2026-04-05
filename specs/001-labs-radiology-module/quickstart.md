# Quickstart: Labs & Radiology Module

**Branch**: `001-labs-radiology-module`

## Prerequisites

- Flutter 3.0+ / Dart 3.0+ installed
- Connected device or emulator
- Backend at `https://espitalia.net/api/` accessible

## Setup

```bash
git checkout 001-labs-radiology-module
flutter pub get
flutter run
```

## Verify

### 1. Browse Test Catalog (No auth required)

1. Open app → Home screen
2. Tap "Lab Tests" in Quick Services
3. Verify: categories load with name, icon, test count
4. Tap a category → verify filtered test list
5. Use search → verify results match query
6. Toggle department filter (Laboratory / Radiology)
7. Tap a test → verify detail screen shows all fields

### 2. Place an Order (Auth required)

1. Log in as a patient
2. Navigate to Lab Tests → browse tests
3. Select one or more tests
4. Tap "Place Order"
5. Add clinical notes (optional), select priority
6. Submit → verify confirmation with order number

### 3. View Orders

1. Home → "My Test Orders"
2. Verify order list loads with status badges
3. Filter by status (e.g., "pending")
4. Tap an order → verify detail screen

### 4. Cancel an Order

1. Open a pending/confirmed order
2. Tap "Cancel Order"
3. Enter cancellation reason → confirm
4. Verify status changes to "cancelled"

### 5. Download Report

1. Open a completed/delivered order
2. Tap "Download Report"
3. Verify PDF downloads and opens

### 6. Dark Mode

1. Toggle dark mode in app settings
2. Navigate through all lab test screens
3. Verify no visual defects

### 7. Localization

1. Switch language to Arabic
2. Navigate through lab test screens
3. Verify RTL layout and translated text
