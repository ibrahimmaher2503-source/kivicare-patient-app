# Data Model: Call Booking Module

**Branch**: `005-call-booking-module` | **Date**: 2026-03-29

## Entities

### CallDoctor

A doctor offering video/phone call consultations.

| Field             | Type              | Required | Notes                     |
|-------------------|-------------------|----------|---------------------------|
| id                | int               | Yes      | Unique identifier         |
| doctorId          | int               | Yes      | Doctor user ID            |
| firstName         | String            | Yes      | First name                |
| lastName          | String            | Yes      | Last name                 |
| fullName          | String            | Yes      | Display name              |
| email             | String            | No       | Email                     |
| mobile            | String            | No       | Phone                     |
| gender            | String            | No       | male/female               |
| expert            | String            | Yes      | Specialty                 |
| aboutSelf         | String            | No       | Bio                       |
| experience        | String            | No       | Experience description    |
| profileImage      | String            | No       | Photo URL                 |
| averageRating     | double            | No       | Rating (0-5)              |
| totalReviews      | int               | No       | Review count              |
| hasVideoCall      | bool              | Yes      | Offers video              |
| hasPhoneCall      | bool              | Yes      | Offers phone              |
| callStartingPrice | double            | No       | Lowest service price      |
| callServices      | List<CallService> | No       | Available services        |

**File**: `lib/screens/call_booking/model/call_doctor_model.dart`

### CallService

A specific call consultation offering from a doctor.

| Field            | Type   | Required | Notes                    |
|------------------|--------|----------|--------------------------|
| id               | int    | Yes      | Unique identifier        |
| doctorId         | int    | Yes      | Parent doctor            |
| name             | String | Yes      | Service name             |
| description      | String | No       | Description              |
| callType         | String | Yes      | video/phone              |
| durationMin      | int    | Yes      | Duration in minutes      |
| timeSlot         | int    | Yes      | Slot interval minutes    |
| charges          | double | Yes      | Original price           |
| discount         | int    | No       | Discount active (0/1)    |
| discountType     | String | No       | percentage/fixed         |
| discountValue    | double | No       | Discount amount/percent  |
| finalPrice       | double | Yes      | Price after discount     |
| isInclusiveTax   | int    | No       | Tax included flag        |
| inclusiveTaxPrice| double | No       | Tax amount               |
| status           | int    | Yes      | Active/inactive          |

### TimeSlot

An available appointment slot for a specific date.

| Field | Type   | Required | Notes                    |
|-------|--------|----------|--------------------------|
| value | String | Yes      | 24h format (e.g., "09:00") |
| label | String | Yes      | Display (e.g., "9:00 AM")  |

**File**: `lib/screens/call_booking/model/time_slot_model.dart`

### CallBooking

A confirmed call appointment.

| Field           | Type   | Required | Notes                    |
|-----------------|--------|----------|--------------------------|
| id              | int    | Yes      | Unique identifier        |
| userId          | int    | Yes      | Patient user ID          |
| doctorId        | int    | Yes      | Doctor ID                |
| appointmentDate | String | Yes      | Date (YYYY-MM-DD)       |
| appointmentTime | String | Yes      | Time (HH:MM)            |
| callServiceId   | int    | Yes      | Service booked           |
| bookingType     | String | Yes      | "call"                   |
| callType        | String | Yes      | video/phone              |
| meetingLink     | String | No       | Jitsi link (video only)  |
| servicePrice    | double | Yes      | Original price           |
| serviceAmount   | double | Yes      | After discount           |
| totalAmount     | double | Yes      | Final amount             |
| duration        | int    | Yes      | Duration minutes         |
| status          | String | Yes      | confirmed/completed/etc  |
| startDateTime   | String | No       | Full datetime            |
| createdAt       | String | Yes      | ISO datetime             |
| updatedAt       | String | No       | ISO datetime             |

**File**: `lib/screens/call_booking/model/call_booking_model.dart`

## Relationships

```
CallDoctor 1──* CallService
CallDoctor 1──* CallBooking
CallService 1──* CallBooking
CallBooking *──1 Patient (user)
```
