# Espitalia Patient App

Flutter patient application for the Espitalia healthcare platform.

## Supported production platform

Android is the only fully configured production target in this repository.
iOS requires an Espitalia `GoogleService-Info.plist`, Firebase OAuth setup, and
an injected `GOOGLE_MAPS_API_KEY` before it can be released. Web and desktop
targets are not currently supported and must not be advertised as production
targets.

## Local setup

1. Install a compatible Flutter 3 / Dart 3 toolchain.
2. Run `flutter pub get`.
3. Copy `android/key.properties.example` to `android/key.properties` and inject
   local or CI signing values.
4. Provide a restricted Android Maps key with the `GOOGLE_MAPS_API_KEY` Gradle
   property or environment variable.
5. Run `flutter run` on an Android device or emulator.

Do not commit signing credentials, Firebase service files, Maps keys, payment
secrets, local SDK paths, or generated release metadata.
