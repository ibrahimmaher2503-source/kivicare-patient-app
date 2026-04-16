# Quickstart: Nurse Request Module

**Branch**: `002-nurse-request-module`

## Prerequisites

- Flutter 3.0+ / Dart 3.0+ installed
- Connected device or emulator
- Backend at `https://espitalia.net/api/` accessible
- Logged in as a patient user

## Setup

```bash
git checkout 002-nurse-request-module
flutter pub get
flutter run
```

## Verify

### 1. Browse Nurses

1. Open app → Home screen
2. Tap "Request Nurse" in Quick Services
3. Verify: nurse list loads with name, specialization, hourly rate
4. Search for a nurse by name → verify results
5. Filter by availability → verify filtering works
6. Tap a nurse → verify detail screen shows full profile

### 2. Create a Request

1. From nurse detail, tap "Request Nurse" (or from request list)
2. Fill in: service description, preferred date/time, duration, address, contact
3. Optionally select a nurse → verify total calculation
4. Submit → verify confirmation with request details

### 3. View Requests

1. Home → "My Nurse Requests"
2. Verify request list loads with status badges
3. Filter by status (e.g., "pending")
4. Tap a request → verify detail screen

### 4. Edit a Pending Request

1. Open a pending request
2. Tap "Edit"
3. Modify fields → save
4. Verify updates reflected

### 5. Cancel a Request

1. Open a pending/confirmed request
2. Tap "Cancel Request"
3. Enter cancellation reason → confirm
4. Verify status changes to "cancelled"

### 6. Dark Mode

1. Toggle dark mode in app settings
2. Navigate through all nurse screens
3. Verify no visual defects

### 7. Localization

1. Switch language to Arabic
2. Navigate through nurse screens
3. Verify RTL layout and translated text
