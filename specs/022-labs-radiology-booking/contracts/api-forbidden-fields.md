# Forbidden Request Fields

The patient app is a **client of a multi-actor backend**. Several fields exist on the canonical `TestOrder` resource that are written by the server (or by admin actors) and **must never be sent from this app**, even if a future bug surfaces them in a `toJson()` accidentally.

This contract is enforced by:

1. `BookingPayload.toJson()` — by construction does not have getters for these fields.
2. `test/screens/labs_radiology/booking_payload_test.dart` — asserts the produced map's keys against an allow-list.

## Forbidden keys

| Key | Reason |
|---|---|
| `status` | Server-controlled state machine |
| `total_amount` | Server-priced |
| `payment_status` | Server/payment-gateway controlled |
| `report_url` | Set when admin uploads report |
| `report_uploaded_at` | Server timestamp |
| `confirmed_at` | Admin transition timestamp |
| `cancelled_at` | Server timestamp |
| `completed_at` | Server timestamp |
| `admin_notes` | Admin scope |
| `commission_*` | Internal accounting |
| `earnings_*` | Internal accounting |

## Allowed keys (whitelist for `BookingPayload.toJson()`)

```
facility_type
facility_id
lab_test_id      (optional; required when facility_type == lab)
slot_id
preferred_date
preferred_time
notes            (optional)
patient_notes    (optional)
```

The unit test compares `payload.toJson().keys.toSet()` against the union of the whitelist and asserts the difference is empty. Any new field added to `BookingPayload` requires updating both this contract and the test.

## Excluded API surface

The following endpoints are admin-scoped and **must not** be added to `api_end_points.dart`, called from any service, or referenced anywhere in `lib/screens/labs_radiology/`:

- `/v1/admin/facility-bookings`
- `/v1/admin/facility-bookings/{id}/confirm`
- `/v1/admin/facility-bookings/{id}/cancel`
- `/v1/admin/facility-bookings/{id}/status`

A grep guard `grep -r "v1/admin/facility-bookings" lib/` should return zero matches at any time.
