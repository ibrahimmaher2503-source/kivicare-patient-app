# Quickstart: Request Service Module

**Branch**: `003-request-service-module`

## Setup

```bash
git checkout 003-request-service-module
flutter pub get
flutter run
```

## Verify

### 1. View Service Requests
1. Open app → Home screen
2. Tap "Request Service" or "My Service Requests"
3. Verify: request list loads with name, type, status badge, date
4. Search by name → verify results
5. Filter by status (Pending/Accepted/Rejected)

### 2. Create a Request
1. Tap "+" button in the list screen
2. Fill in: service name (required), description, type
3. Submit → verify success message
4. Verify new request appears in list with "Pending" status

### 3. Dark Mode
1. Toggle dark mode
2. Navigate through both screens
3. Verify no visual defects

### 4. Localization
1. Switch to Arabic
2. Verify RTL layout and translated text
