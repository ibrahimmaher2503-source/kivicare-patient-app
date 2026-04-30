# Contracts — Labs & Radiology Booking Module

This directory pins the externally observable contracts the feature both consumes and exposes. Anything not listed here is internal and may change without coordination.

| File | Purpose |
|---|---|
| [`api-endpoints.md`](./api-endpoints.md) | Patient-scoped Laravel REST endpoints consumed by the module |
| [`api-forbidden-fields.md`](./api-forbidden-fields.md) | Server-controlled fields the app must never send |
| [`routing-contract.md`](./routing-contract.md) | Public navigation entry points exposed to other parts of the app |
| [`localization-keys.md`](./localization-keys.md) | Localization keys to be added to language files |

The app is a **client** of the Laravel API. There are no public APIs, CLI commands, or library exports introduced by this feature — only HTTP calls outward and routes inward from the dashboard.
