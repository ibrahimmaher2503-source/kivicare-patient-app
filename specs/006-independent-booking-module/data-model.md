# Data Model: Independent Doctor Booking Module

**Branch**: `006-independent-booking-module` | **Date**: 2026-03-29

## Entities

### IndependentDoctor

A doctor offering direct in-person consultations.

| Field              | Type                      | Required | Notes                     |
|--------------------|---------------------------|----------|---------------------------|
| id                 | int                       | Yes      | Doctor model ID           |
| doctorId           | int                       | Yes      | Doctor user ID            |
| firstName          | String                    | Yes      | First name                |
| lastName           | String                    | Yes      | Last name                 |
| fullName           | String                    | Yes      | Display name              |
| email              | String                    | No       | Email                     |
| mobile             | String                    | No       | Phone                     |
| gender             | String                    | No       | male/female               |
| expert             | String                    | Yes      | Specialty                 |
| dateOfBirth        | String                    | No       | DOB                       |
| status             | int                       | Yes      | Active/inactive           |
| address            | String                    | No       | Address                   |
| latitude           | String                    | No       | GPS lat                   |
| longitude          | String                    | No       | GPS lng                   |
| description        | String                    | No       | Bio                       |
| experience         | String                    | No       | Experience                |
| profileImage       | String                    | No       | Photo URL                 |
| averageRating      | double                    | No       | Rating (0-5)              |
| totalAppointment   | int                       | No       | Appointment count         |
| totalPatient       | int                       | No       | Patient count             |
| totalReviews       | int                       | No       | Review count              |
| services           | List<IndependentService>  | No       | Available services        |

**File**: `lib/screens/independent_booking/model/independent_doctor_model.dart`

### IndependentService

A specific consultation offering with tax support.

| Field            | Type   | Required | Notes                         |
|------------------|--------|----------|-------------------------------|
| id               | int    | Yes      | Unique identifier             |
| doctorId         | int    | Yes      | Parent doctor                 |
| name             | String | Yes      | Service name                  |
| description      | String | No       | Description                   |
| durationMin      | int    | Yes      | Duration (default 30 min)     |
| timeSlot         | int    | Yes      | Slot interval (default 10 min)|
| charges          | double | Yes      | Base price                    |
| discount         | int    | No       | 0/1 enabled                   |
| discountType     | String | No       | percentage/fixed              |
| discountValue    | double | No       | Discount amount/percent       |
| isInclusiveTax   | int    | No       | 0/1 enabled                   |
| inclusiveTax     | String | No       | JSON string of tax objects    |
| inclusiveTaxPrice| double | No       | Calculated tax amount         |
| status           | int    | Yes      | Active/inactive               |
| createdAt        | String | No       | ISO datetime                  |
| updatedAt        | String | No       | ISO datetime                  |

### TimeSlot (REUSED from Call Booking)

`lib/screens/call_booking/model/time_slot_model.dart`

| Field | Type   | Notes                    |
|-------|--------|--------------------------|
| value | String | 24h format ("09:00")     |
| label | String | Display ("9:00 AM")      |

### IndependentBooking

A confirmed in-person appointment.

| Field                  | Type   | Required | Notes                    |
|------------------------|--------|----------|--------------------------|
| id                     | int    | Yes      | Unique identifier        |
| userId                 | int    | Yes      | Patient user ID          |
| doctorId               | int    | Yes      | Doctor ID                |
| independentServiceId   | int    | Yes      | Service booked           |
| appointmentDate        | String | Yes      | Date (YYYY-MM-DD)       |
| appointmentTime        | String | Yes      | Time (HH:MM)            |
| bookingType            | String | Yes      | "independent"            |
| status                 | String | Yes      | confirmed/completed/etc  |
| servicePrice           | double | Yes      | Original price           |
| serviceAmount          | double | Yes      | After discount           |
| totalAmount            | double | Yes      | Final with tax           |
| duration               | int    | Yes      | Duration minutes         |
| startDateTime          | String | No       | Full datetime            |
| createdAt              | String | Yes      | ISO datetime             |
| updatedAt              | String | No       | ISO datetime             |

**File**: `lib/screens/independent_booking/model/independent_booking_model.dart`

## Relationships

```
IndependentDoctor 1──* IndependentService
IndependentDoctor 1──* IndependentBooking
IndependentService 1──* IndependentBooking
```
