# API Contracts: Independent Doctor Booking Module

**Base URL**: `https://espitalia.net/api/v1`

## Public Endpoints

### GET /independent-doctors
Paginated list of doctors with independent services.
Query: per_page, page, search.

### GET /independent-doctors/{id}/services
Doctor's independent services. ID = Doctor model ID.

## Authenticated Endpoints

### POST /independent-doctors/{id}/slots
Available time slots for a date + service.
Body: { appointment_date, independent_service_id }
Response: Array of { value, label }

### POST /independent-booking
Create booking.
Body: { doctor_id, independent_service_id, appointment_date, appointment_time, transaction_type }
Response: IndependentBookingResource with pricing
