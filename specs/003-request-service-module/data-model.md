# Data Model: Request Service Module

**Branch**: `003-request-service-module` | **Date**: 2026-03-29

## Entities

### RequestService

A patient's custom service request for services not in the catalog.

| Field       | Type    | Required | Notes                           |
|-------------|---------|----------|---------------------------------|
| id          | int     | Yes      | Unique identifier               |
| name        | String  | Yes      | Service name (required)         |
| description | String  | No       | Service description (max 500)   |
| type        | String  | No       | Type hint (laboratory/nurse/home/emergency) |
| status      | int     | Yes      | Active/inactive (1/0)           |
| isStatus    | String  | Yes      | pending, accept, reject         |
| createdBy   | int     | Yes      | Creator user ID                 |
| updatedBy   | int?    | No       | Updater user ID                 |
| deletedBy   | int?    | No       | Deleter user ID (soft delete)   |
| createdAt   | String  | Yes      | ISO datetime                    |
| updatedAt   | String  | Yes      | ISO datetime                    |
| deletedAt   | String? | No       | Soft delete timestamp           |

**Source**: `GET /v1/get-request-service`, `POST /v1/save-request-service`
**File**: `lib/screens/request_service/model/request_service_model.dart`

## Status Flow

```
pending → accept
pending → reject
```

- Only admin can change status (server-side)
- Patient can only create and view
- No edit or cancel from patient side
