# Quickstart: ICU Admissions Module

**Branch**: `004-icu-admissions-module`

## Setup

```bash
git checkout 004-icu-admissions-module
flutter pub get
flutter run
```

## Verify

### 1. Browse Hospitals
1. Open app → Home screen
2. Tap "ICU Admissions" in Quick Services
3. Verify: hospital list loads with name, type, city, rating
4. Search for a hospital → verify results
5. Filter by specialty (e.g., cardiac) → verify filtering
6. Filter by ventilator availability → verify
7. Tap a hospital → verify detail with departments

### 2. Browse ICU Departments
1. From hospital detail, view departments list
2. Or navigate to department list directly
3. Verify: bed counts, equipment indicators, daily price
4. Filter by available beds → verify

### 3. Submit Admission Request
1. From hospital detail, tap "Request Admission"
2. Fill patient info: name, age, gender
3. Fill case details: condition, case type, urgency
4. Fill contact: name, phone
5. Select payment method (insurance → verify conditional fields)
6. Optionally attach medical reports
7. Submit → verify confirmation with request number

### 4. View My Requests
1. Home → "My ICU Requests"
2. Verify: request list with status badges
3. Filter by status → verify
4. Tap a request → verify full detail

### 5. Cancel a Request
1. Open a pending request
2. Tap "Cancel" → enter reason → confirm
3. Verify status changes to "cancelled"

### 6. Dark Mode + Localization
1. Toggle dark mode → navigate all ICU screens
2. Switch to Arabic → verify RTL layout
