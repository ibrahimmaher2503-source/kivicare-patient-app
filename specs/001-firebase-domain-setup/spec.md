# Feature Specification: Firebase and Domain Integration Setup

**Feature Branch**: `001-firebase-domain-setup`
**Created**: 2026-02-27
**Status**: Draft
**Input**: User description: "i need to link my project with firebase and my domain read all config and main files and give me full steps to do"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Complete iOS Firebase Configuration (Priority: P1)

An iOS developer needs to configure Firebase for the iOS version of the KiviCare Patient app to enable push notifications, crash reporting, and social authentication for iPhone and iPad users.

**Why this priority**: iOS users cannot receive push notifications or use Google/Apple Sign-In without proper Firebase configuration. This is a critical user-facing feature gap affecting 30-40% of potential mobile users.

**Independent Test**: Can be fully tested by building the iOS app, running it on an iOS simulator or device, attempting Google Sign-In, and verifying that Firebase Crashlytics logs appear in the Firebase console. Delivers functional social authentication and crash tracking for iOS users.

**Acceptance Scenarios**:

1. **Given** an iOS device or simulator, **When** the app launches, **Then** Firebase initializes without throwing UnsupportedError
2. **Given** a user on the login screen, **When** they tap "Sign in with Google", **Then** the Google authentication flow completes successfully
3. **Given** the app is running on iOS, **When** a push notification is sent from Firebase Console, **Then** the notification appears on the device
4. **Given** the app crashes on iOS, **When** viewing Firebase Crashlytics console, **Then** the crash report appears within 5 minutes

---

### User Story 2 - Configure Web Platform Firebase Support (Priority: P2)

A web user needs to access the KiviCare Patient app through a browser to book appointments and manage medical records without installing a mobile app.

**Why this priority**: Currently the web platform throws UnsupportedError. Enabling web access expands the app's reach to users who prefer browser-based access or don't have compatible mobile devices. This is a moderate priority as mobile apps are the primary delivery method for healthcare apps.

**Independent Test**: Can be fully tested by running `flutter run -d chrome`, verifying Firebase initialization, attempting login, and checking that push notifications work via browser notification permissions. Delivers a fully functional web version of the patient portal.

**Acceptance Scenarios**:

1. **Given** a Chrome browser, **When** the user navigates to the web app URL, **Then** the app loads without Firebase configuration errors
2. **Given** a user on the web login page, **When** they enter credentials and submit, **Then** authentication completes and Firebase Analytics logs the event
3. **Given** a logged-in web user, **When** the system sends a notification, **Then** the browser prompts for notification permission
4. **Given** the web app is running, **When** an error occurs, **Then** Firebase Crashlytics captures the error (if supported on web)

---

### User Story 3 - Verify Domain and API Integration (Priority: P1)

The development team needs to ensure that all Firebase services are correctly linked to the espitalia.net domain and the Laravel backend API to maintain consistent branding and functionality.

**Why this priority**: Domain integration affects OAuth redirect URIs, dynamic links, app verification, and API communication. Incorrect configuration can break authentication flows and deep linking. This is critical for production readiness.

**Independent Test**: Can be fully tested by configuring OAuth providers (Google, Apple) with the correct domain, testing deep links, verifying API calls include correct headers, and checking Firebase Dynamic Links. Delivers properly configured OAuth and deep linking capabilities.

**Acceptance Scenarios**:

1. **Given** Firebase Console OAuth configuration, **When** authorized domains are reviewed, **Then** espitalia.net is listed as an authorized domain
2. **Given** a user completes Google Sign-In, **When** the OAuth flow redirects, **Then** it uses the correct espitalia.net callback URL
3. **Given** a Firebase Dynamic Link is created, **When** the link is opened, **Then** it correctly redirects to the app with espitalia.net domain
4. **Given** API calls are made from the app, **When** network traffic is inspected, **Then** all requests use the BASE_URL https://espitalia.net/api/

---

### User Story 4 - Set Up Firebase Cloud Messaging Topics (Priority: P2)

Medical staff at clinics need to send targeted push notifications to specific patient groups (e.g., appointment reminders, health tips) through Firebase Cloud Messaging.

**Why this priority**: While basic FCM is already configured, topic-based messaging enables more sophisticated notification strategies like sending reminders only to patients with appointments. This improves user engagement without being critical for MVP.

**Independent Test**: Can be fully tested by subscribing test devices to topics, sending topic-specific messages from Firebase Console, and verifying only subscribed devices receive notifications. Delivers targeted notification capabilities.

**Acceptance Scenarios**:

1. **Given** a logged-in patient, **When** they enable appointment reminders, **Then** their device subscribes to the "appointment_reminders" FCM topic
2. **Given** devices subscribed to different topics, **When** an admin sends a topic-specific notification, **Then** only subscribed devices receive it
3. **Given** a user logs out, **When** the logout process completes, **Then** the device unsubscribes from all user-specific topics
4. **Given** a new clinic is added to the system, **When** Firebase is configured, **Then** a new topic is created for that clinic's patients

---

### User Story 5 - Configure Production Environment Variables (Priority: P3)

The DevOps team needs to separate development and production Firebase configurations to prevent test data from affecting production analytics and ensure secure API key management.

**Why this priority**: This is an operational improvement that prevents mixing test and production data. While important for professional operations, the app can function with a single environment. This becomes critical when scaling to multiple environments.

**Independent Test**: Can be fully tested by creating separate Firebase projects for dev/staging/prod, configuring environment-specific configs.dart files, and verifying that build variants use correct credentials. Delivers proper environment separation.

**Acceptance Scenarios**:

1. **Given** the codebase, **When** reviewing configuration files, **Then** development and production Firebase projects use separate credentials
2. **Given** a development build, **When** Firebase Analytics is checked, **Then** events appear in the development Firebase project only
3. **Given** a production build, **When** checking configs.dart, **Then** DOMAIN_URL points to the production domain https://espitalia.net
4. **Given** sensitive API keys, **When** reviewing source control, **Then** production keys are not committed to the repository

---

### Edge Cases

- What happens when Firebase initialization fails due to network issues during app startup?
- How does the system handle OAuth redirects when the domain configuration is incorrect?
- What happens when push notifications are sent to users who have uninstalled the app?
- How does the app behave when Firebase services are temporarily unavailable?
- What happens when a user denies browser notification permissions on the web platform?
- How does the system handle FCM token refresh and invalid tokens?
- What happens when iOS users have not configured APNS certificates in Firebase?

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST initialize Firebase for Android platform using existing configuration (App ID: 1:470329686255:android:22275b1bda3542326f031a)
- **FR-002**: System MUST initialize Firebase for iOS platform with valid credentials (currently using placeholder values)
- **FR-003**: System MUST initialize Firebase for web platform (currently throws UnsupportedError)
- **FR-004**: System MUST register espitalia.net as an authorized domain in Firebase Console for OAuth redirects
- **FR-005**: System MUST configure Firebase Cloud Messaging for push notifications across all supported platforms
- **FR-006**: System MUST enable Firebase Crashlytics for error tracking in release builds (already configured for Android)
- **FR-007**: System MUST configure Google Sign-In OAuth client IDs for web and iOS platforms in Firebase Console
- **FR-008**: System MUST configure Apple Sign-In service ID in Firebase Console for iOS authentication
- **FR-009**: System MUST verify that API calls use BASE_URL https://espitalia.net/api/ with proper headers
- **FR-010**: System MUST configure APNS authentication for iOS push notifications (p8 key or certificate)
- **FR-011**: System MUST support FCM background message handling via firebaseMessagingBackgroundHandler
- **FR-012**: System MUST store Firebase configuration files securely (GoogleService-Info.plist for iOS, google-services.json for Android)
- **FR-013**: System MUST handle platform-specific Firebase initialization failures gracefully
- **FR-014**: System MUST configure SHA-1 and SHA-256 fingerprints in Firebase Console for Android app signing
- **FR-015**: System MUST enable required Firebase APIs in Google Cloud Console (Auth, FCM, Crashlytics, Analytics)

### Key Entities *(include if feature involves data)*

- **Firebase Project**: Represents the Firebase configuration for the KiviCare Patient app (Project ID: espitalia-d934b for Android, separate project ID needed for iOS/Web)
- **Domain Configuration**: The espitalia.net domain with its associated URLs (BASE_URL, APP_LOGO_URL, TERMS_CONDITION_URL, PRIVACY_POLICY_URL)
- **Platform Configuration**: Platform-specific settings (Android uses existing config, iOS needs GoogleService-Info.plist, Web needs Firebase config object)
- **OAuth Client**: Google and Apple OAuth credentials for each platform (Android, iOS, Web) registered in Firebase Console
- **FCM Token**: Unique device identifier for push notifications, refreshed periodically and stored per user device
- **APNS Certificate/Key**: Apple Push Notification service authentication for iOS notifications

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Users can successfully complete Google Sign-In on Android, iOS, and web platforms without authentication errors
- **SC-002**: Push notifications are delivered to devices within 30 seconds of being sent from the Laravel backend
- **SC-003**: Firebase Crashlytics captures and reports 100% of crashes within 5 minutes on all configured platforms
- **SC-004**: OAuth redirect flows complete successfully with zero "redirect_uri_mismatch" errors after domain configuration
- **SC-005**: The app successfully initializes Firebase on all supported platforms without throwing UnsupportedError exceptions
- **SC-006**: All API calls from the app include the correct Authorization header and use the espitalia.net domain
- **SC-007**: Development and production environments use separate Firebase projects with no data mixing between environments
- **SC-008**: Firebase Analytics tracks user events with accurate platform attribution (Android, iOS, Web)
- **SC-009**: 100% of required Firebase APIs are enabled in Google Cloud Console and accessible via API keys
- **SC-010**: App signing certificates (SHA fingerprints) are correctly configured, allowing zero authentication failures due to signature mismatch

## Assumptions

- The existing Android Firebase configuration (Project ID: espitalia-d934b) is correct and will remain unchanged
- The development team has admin access to the Firebase Console and Google Cloud Console for the project
- The espitalia.net domain is already registered and DNS is configured
- The Laravel backend at https://espitalia.net/api/ is operational and expects Firebase tokens for authentication
- The team has access to Apple Developer account for generating APNS certificates/keys for iOS push notifications
- iOS and web platforms will use the same Firebase project as Android (espitalia-d934b) rather than separate projects
- The app will support only Android, iOS, and web platforms (desktop platforms like Windows, macOS, Linux will remain unsupported)
- Firebase services will use the free Spark plan or paid Blaze plan (Spark plan limits may affect some features)
- OAuth credentials for Google Sign-In are already created in Google Cloud Console and need to be linked to Firebase
- The team has the necessary app signing certificates and keystores for production Android builds

## Out of Scope

- Migration of existing user data to Firebase Authentication (users remain authenticated via Laravel backend)
- Implementation of new Firebase services beyond those already in use (e.g., Firebase Remote Config, Firebase Storage)
- Configuration of Firebase Hosting for web deployment (web build will be hosted separately)
- Desktop platform support (Windows, macOS, Linux) - these will continue to throw UnsupportedError
- Changes to the Laravel backend API structure or authentication flow
- Migration from current API-based authentication to Firebase Authentication as the primary auth method
- Implementation of Firebase Analytics custom events beyond default automatic tracking
- Configuration of Firebase Performance Monitoring
- Setup of Firebase App Distribution for beta testing
- Changes to payment gateway integrations (Stripe, PayPal, Razorpay, etc.)