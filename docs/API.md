# REST API Design (Examples + Status Codes)

Base URL (dev): `http://localhost:3000`

Authentication: `Authorization: Bearer <access_token>`

Request tracing: Each response includes `X-Request-Id` and the JSON body includes `request_id` for easier debugging.

## Health Check Endpoints

### GET /health

**Purpose:** Simple liveness check.

```json
{ "status": "ok", "service": "hospital-bed-management-backend" }
```

### GET /health/ready

**Purpose:** Deep readiness check (verifies database connectivity).

#### 200 OK

```json
{
  "status": "healthy",
  "service": "hospital-bed-management-backend",
  "database": "connected",
  "timestamp": "2026-01-16T10:00:00.000Z"
}
```

#### 503 Service Unavailable

```json
{
  "status": "unhealthy",
  "service": "hospital-bed-management-backend",
  "database": "disconnected",
  "error": "Database query failed"
}
```

---

## POST /auth/login

**Purpose:** Exchange email/password for a Supabase JWT.

### Request

```json
{
  "email": "doctor@hospital.com",
  "password": "StrongPassword123"
}
```

### 200 OK(JWT)

```json
{
  "access_token": "<jwt>",
  "refresh_token": "<refresh>",
  "token_type": "bearer",
  "expires_in": 3600,
  "user": { "id": "...", "email": "doctor@hospital.com" }
}
```

### 401 Unauthorized

```json
{ "error": "Invalid credentials" }
```

### 400 Bad Request (validation)

```json
{
  "error": "Validation error",
  "request_id": "<uuid>",
  "details": {
    "fieldErrors": {
      "email": ["Invalid email"]
    }
  }
}
```

---

## POST /auth/refresh

**Purpose:** Exchange a refresh token for a new access token (no re-login required).

### Request

```json
{
  "refresh_token": "<refresh-token>"
}
```

### 200 OK

```json
{
  "access_token": "<new-jwt>",
  "refresh_token": "<new-refresh>",
  "token_type": "bearer",
  "expires_in": 3600,
  "user": { "id": "...", "email": "doctor@hospital.com" }
}
```

### 401 Unauthorized

```json
{ "error": "Invalid or expired refresh token" }
```

---

## POST /auth/logout

**Purpose:** Invalidate the current session (requires authentication).

### 200 OK

```json
{ "message": "Logged out successfully" }
```

---

## POST /auth/forgot-password

**Purpose:** Request a password reset email.

### Request

```json
{ "email": "doctor@hospital.com" }
```

### 200 OK

```json
{ "message": "If an account with that email exists, a password reset link has been sent" }
```

---

## POST /auth/reset-password

**Purpose:** Set a new password (called after clicking reset link).

### Request

```json
{ "new_password": "NewStrongPassword123" }
```

### 200 OK

```json
{ "message": "Password reset successfully" }
```

### 400 Bad Request

```json
{ "error": "Failed to reset password. Link may have expired." }
```

---

## GET /hospitals

**Purpose:** List hospitals (paginated).

### Query Parameters

| Param | Type | Default | Description |
|-------|------|---------|-------------|

| `page` | int | 1 | Page number |
| `limit` | int | 20 | Items per page (max 100) |

### 200 OK

```json
{
  "hospitals": [
    { "id": "...", "name": "Korle-Bu Teaching Hospital", "region": "Greater Accra", "district": "Accra" }
  ],
  "pagination": {
    "page": 1,
    "limit": 20,
    "total_count": 45,
    "total_pages": 3,
    "has_next": true,
    "has_prev": false
  }
}
```

**401 Unauthorized** if missing/invalid token.

### Admin management

#### POST /hospitals (admin)

Creates a new hospital record.

### Request(create hospital)

```json
{ "name": "Tamale Teaching Hospital", "region": "Northern", "district": "Tamale" }
```

### 201 Created(hopital created)

```json
{ "hospital": { "id": "<uuid>", "name": "Tamale Teaching Hospital", "region": "Northern", "district": "Tamale", "created_at": "..." } }
```

#### PATCH /hospitals/:id (admin)

Updates core hospital metadata.

### Request(update hospital metadata)

```json
{ "district": "Accra Metro" }
```

### 200 OK(hospital metadata updated)

```json
{ "hospital": { "id": "<uuid>", "name": "...", "region": "...", "district": "Accra Metro", "created_at": "..." } }
```

---

## GET /wards/:id/availability

**Purpose:** View ward bed capacity and availability.

### 200 OK(VIew bed capacity)

```json
{
  "ward": {
    "id": "...",
    "name": "ICU",
    "type": "icu",
    "total_beds": 10,
    "available_beds": 2,
    "hospital_id": "..."
  }
}
```

### 404 Not Found(Ward not found)

```json
{ "error": "Ward not found" }
```

#### POST /wards (admin)

Creates a ward and sets initial capacity.

### Request(create ward)

```json
{ "name": "Maternity", "type": "maternity", "total_beds": 20 }
```

### 201 Created(ward created)

```json
{ "ward": { "id": "<uuid>", "hospital_id": "<uuid>", "name": "Maternity", "type": "maternity", "total_beds": 20, "available_beds": 20, "created_at": "..." } }
```

#### PATCH /wards/:id/capacity (admin)

Updates `total_beds` safely and adjusts `available_beds` based on current occupancy.

### Request(update total bed)

```json
{ "total_beds": 25 }
```

### 200 OK(total beds updated)

```json
{ "ward": { "id": "<uuid>", "hospital_id": "<uuid>", "name": "...", "type": "...", "total_beds": 25, "available_beds": 10 } }
```

---

## GET /admissions

**Roles:** `admin`, `doctor`, `nurse`

**Purpose:** List admissions for your hospital (paginated).

### Query Parameters

| Param | Type | Default | Description |
|-------|------|---------|-------------|
| `page` | int | 1 | Page number |
| `limit` | int | 20 | Items per page (max 100) |
| `status` | string | - | Filter by status (`admitted` or `discharged`) |
| `ward_id` | uuid | - | Filter by ward |

### 200 OK

```json
{
  "admissions": [
    {
      "id": "<admission-uuid>",
      "status": "admitted",
      "admitted_at": "2026-01-12T10:00:00.000Z",
      "discharged_at": null,
      "patient_id": "<patient-uuid>",
      "ward_id": "<ward-uuid>",
      "hospital_id": "<hospital-uuid>",
      "patients": { "id": "...", "full_name": "Ama Mensah", "sex": "F", "date_of_birth": "1998-04-01", "phone": "...", "national_id": "..." },
      "wards": { "id": "...", "name": "ICU", "type": "icu" }
    }
  ],
  "pagination": { "page": 1, "limit": 20, "total_count": 50, "total_pages": 3, "has_next": true, "has_prev": false }
}
```

---

## GET /admissions/:id

**Roles:** `admin`, `doctor`, `nurse`

**Purpose:** Get a single admission with full details.

### 200 OK

```json
{
  "admission": {
    "id": "<admission-uuid>",
    "status": "admitted",
    "admitted_at": "2026-01-12T10:00:00.000Z",
    "discharged_at": null,
    "patient_id": "<patient-uuid>",
    "ward_id": "<ward-uuid>",
    "hospital_id": "<hospital-uuid>",
    "admitted_by_auth_user_id": "<user-uuid>",
    "patients": { "id": "...", "full_name": "Ama Mensah", "sex": "F", ... },
    "wards": { "id": "...", "name": "ICU", "type": "icu", "hospital_id": "..." }
  }
}
```

### 404 Not Found

```json
{ "error": "Admission not found" }
```

---

## POST /admissions

**Roles:** `admin`, `doctor`, `nurse`

**Purpose:** Admit a patient into a ward.

**Critical rule enforced:** If `available_beds == 0`, admission fails.

### Request (POST /admissions)

```json
{
  "ward_id": "<ward-uuid>",
  "patient": {
    "full_name": "Ama Mensah",
    "sex": "F",
    "date_of_birth": "1998-04-01",
    "phone": "+233XXXXXXXXX",
    "national_id": "GHA-123456"
  }
}
```

### 201 Created(admitted)

```json
{
  "admission": {
    "id": "<admission-uuid>",
    "patient_id": "<patient-uuid>",
    "ward_id": "<ward-uuid>",
    "hospital_id": "<hospital-uuid>",
    "status": "admitted",
    "admitted_at": "2026-01-12T10:00:00.000Z"
  },
  "ward": {
    "id": "<ward-uuid>",
    "available_beds": 1,
    "total_beds": 10
  }
}
```

### 409 Conflict (no beds)

```json
{ "error": "No beds available in this ward" }
```

### 403 Forbidden (ward not in your hospital)

```json
{ "error": "Ward does not belong to your hospital" }
```

---

## POST /discharges

**Roles:** `admin`, `doctor`, `nurse`

**Purpose:** Discharge a patient (frees a bed).

### Request (POST /discharges)

```json
{ "admission_id": "<admission-uuid>" }
```

### 200 OK(Discahrged)

```json
{
  "admission": {
    "id": "<admission-uuid>",
    "status": "discharged",
    "discharged_at": "2026-01-12T12:00:00.000Z"
  },
  "ward": { "id": "<ward-uuid>", "available_beds": 2, "total_beds": 10 }
}
```

---

## GET /referrals

**Roles:** `admin`, `doctor`, `nurse`

**Purpose:** List referrals for your hospital (paginated).

### Query Parameters

| Param | Type | Default | Description |
|-------|------|---------|-------------|
| `page` | int | 1 | Page number |
| `limit` | int | 20 | Items per page (max 100) |
| `status` | string | - | Filter by status (`pending`, `accepted`, `rejected`, `completed`, `cancelled`) |
| `direction` | string | `outgoing` | `outgoing` (from your hospital) or `incoming` (to your hospital) |

### 200 OK

```json
{
  "referrals": [
    {
      "id": "<referral-uuid>",
      "status": "pending",
      "reason": "No beds available. Needs ICU monitoring.",
      "created_at": "2026-01-12T10:15:00.000Z",
      "patient_id": "<patient-uuid>",
      "from_hospital_id": "<hospital-uuid>",
      "from_ward_id": "<ward-uuid>",
      "to_hospital_id": "<hospital-uuid>",
      "patients": { "id": "...", "full_name": "Kofi Asante", "sex": "M", "date_of_birth": "1985-06-15" },
      "from_hospital": { "id": "...", "name": "Korle-Bu", "region": "Greater Accra" },
      "from_ward": { "id": "...", "name": "ICU", "type": "icu" },
      "to_hospital": { "id": "...", "name": "37 Military Hospital", "region": "Greater Accra" }
    }
  ],
  "direction": "outgoing",
  "pagination": { "page": 1, "limit": 20, "total_count": 12, "total_pages": 1, "has_next": false, "has_prev": false }
}
```

---

## GET /referrals/:id

**Roles:** `admin`, `doctor`, `nurse`

**Purpose:** Get a single referral with full details.

### 200 OK

```json
{
  "referral": {
    "id": "<referral-uuid>",
    "status": "pending",
    "reason": "No beds available. Needs ICU monitoring.",
    "created_at": "2026-01-12T10:15:00.000Z",
    "patient_id": "<patient-uuid>",
    "from_hospital_id": "<hospital-uuid>",
    "from_ward_id": "<ward-uuid>",
    "to_hospital_id": "<hospital-uuid>",
    "created_by_auth_user_id": "<user-uuid>",
    "patients": { ... },
    "from_hospital": { ... },
    "from_ward": { ... },
    "to_hospital": { ... }
  }
}
```

### 404 Not Found

```json
{ "error": "Referral not found" }
```

---

## POST /referrals

**Roles:** `admin`, `doctor`

**Purpose:** Create a referral to another hospital.

**Critical rule enforced:** Referral can only be created when the current hospital has **0** available beds.

### Request (POST /referrals)

```json
{
  "patient_id": "<patient-uuid>",
  "from_ward_id": "<ward-uuid>",
  "to_hospital_id": "<hospital-uuid>",
  "reason": "No beds available. Needs ICU monitoring."
}
```

### 201 Created(referred)

```json
{
  "referral": {
    "id": "<referral-uuid>",
    "status": "pending",
    "created_at": "2026-01-12T10:15:00.000Z",
    "patient_id": "<patient-uuid>",
    "from_hospital_id": "<hospital-uuid>",
    "from_ward_id": "<ward-uuid>",
    "to_hospital_id": "<hospital-uuid>",
    "reason": "No beds available. Needs ICU monitoring."
  },
  "hospital_available_beds": 0
}
```

### 409 Conflict (beds still available)

```json
{ "error": "Referral allowed only when hospital has no available beds" }
```

---

## POST /users

**Roles:** `admin`

**Purpose:** Admin creates staff accounts (doctor/nurse/admin) and assigns them to a hospital.

**Important:** This endpoint requires `SUPABASE_SERVICE_ROLE_KEY` on the server.

### Request (POST /users)

```json
{
  "email": "nurse@hospital.com",
  "password": "StrongPassword123",
  "staff_id": "KBTH-NUR-00123",
  "role": "nurse",
  "hospital_id": "<hospital-uuid>"
}
```

### 201 Created

```json
{
  "auth_user": { "id": "<auth-user-uuid>", "email": "nurse@hospital.com" },
  "profile": {
    "id": "<profile-uuid>",
    "auth_user_id": "<auth-user-uuid>",
    "staff_id": "KBTH-NUR-00123",
    "role": "nurse",
    "hospital_id": "<hospital-uuid>",
    "created_at": "2026-01-12T10:30:00.000Z"
  }
}
```

### 400 Bad Request

```json
{ "error": "email, password, role, hospital_id, staff_id are required" }
```

### 403 Forbidden (non-admin)

```json
{ "error": "Forbidden" }
```

---

## GET /patients

**Roles:** `admin`, `doctor`, `nurse`

**Purpose:** Search and list patients (paginated).

### Query Parameters

| Param | Type | Default | Description |
|-------|------|---------|-------------|
| `page` | int | 1 | Page number |
| `limit` | int | 20 | Items per page (max 100) |
| `search` | string | - | Search by name or national_id (partial match) |
| `national_id` | string | - | Exact national_id lookup |

### 200 OK

```json
{
  "patients": [
    {
      "id": "<patient-uuid>",
      "full_name": "Ama Mensah",
      "sex": "F",
      "date_of_birth": "1998-04-01",
      "phone": "+233XXXXXXXXX",
      "national_id": "GHA-123456",
      "created_at": "2026-01-12T09:00:00.000Z"
    }
  ],
  "pagination": { "page": 1, "limit": 20, "total_count": 150, "total_pages": 8, "has_next": true, "has_prev": false }
}
```

---

## GET /patients/:id

**Roles:** `admin`, `doctor`, `nurse`

**Purpose:** Get a single patient with their admission history (scoped to your hospital).

### 200 OK

```json
{
  "patient": {
    "id": "<patient-uuid>",
    "full_name": "Ama Mensah",
    "sex": "F",
    "date_of_birth": "1998-04-01",
    "phone": "+233XXXXXXXXX",
    "national_id": "GHA-123456",
    "created_at": "2026-01-12T09:00:00.000Z"
  },
  "admissions": [
    {
      "id": "<admission-uuid>",
      "status": "discharged",
      "admitted_at": "2026-01-10T08:00:00.000Z",
      "discharged_at": "2026-01-12T14:00:00.000Z",
      "hospital_id": "<hospital-uuid>",
      "ward_id": "<ward-uuid>",
      "wards": { "id": "...", "name": "General Ward", "type": "general" },
      "hospitals": { "id": "...", "name": "Korle-Bu" }
    }
  ]
}
```

### 404 Not Found

```json
{ "error": "Patient not found" }
```

---

## GET /beds/search

**Roles:** `admin`, `doctor`, `nurse`

**Purpose:** Search for available beds across ALL hospitals (cross-hospital visibility for referrals).

### Query Parameters

| Param | Type | Default | Description |
|-------|------|---------|-------------|
| `page` | int | 1 | Page number |
| `limit` | int | 20 | Items per page (max 100) |
| `region` | string | - | Filter by region (e.g., "Greater Accra") |
| `district` | string | - | Filter by district |
| `ward_type` | string | - | Filter by ward type (e.g., "icu", "maternity", "general") |
| `min_beds` | int | 1 | Minimum available beds required |

### 200 OK

```json
{
  "success": true,
  "data": [
    {
      "ward_id": "<ward-uuid>",
      "ward_name": "ICU",
      "ward_type": "icu",
      "total_beds": 10,
      "occupied_beds": 6,
      "available_beds": 4,
      "hospital_id": "<hospital-uuid>",
      "hospital_name": "37 Military Hospital",
      "region": "Greater Accra",
      "district": "Accra"
    }
  ],
  "filters_applied": {
    "region": "Greater Accra",
    "district": null,
    "ward_type": "icu",
    "min_beds": 1
  },
  "pagination": { "page": 1, "limit": 20, "total_count": 5, "total_pages": 1, "has_next": false, "has_prev": false }
}
```

---

## PATCH /referrals/:id/accept

**Roles:** `admin`, `doctor`

**Purpose:** Accept an incoming referral (receiving hospital only).

### 200 OK

```json
{
  "success": true,
  "message": "Referral accepted",
  "referral": {
    "id": "<referral-uuid>",
    "status": "accepted",
    "accepted_at": "2026-01-16T10:00:00.000Z",
    "accepted_by_auth_user_id": "<user-uuid>"
  }
}
```

### 403 Forbidden

```json
{ "error": "Only the receiving hospital can accept this referral" }
```

### 409 Conflict

```json
{ "error": "Referral is not in pending status" }
```

---

## PATCH /referrals/:id/reject

**Roles:** `admin`, `doctor`

**Purpose:** Reject an incoming referral with a reason (receiving hospital only).

### Request

```json
{ "reason": "No ICU beds available at this time" }
```

### 200 OK

```json
{
  "success": true,
  "message": "Referral rejected",
  "referral": {
    "id": "<referral-uuid>",
    "status": "rejected",
    "rejection_reason": "No ICU beds available at this time",
    "rejected_at": "2026-01-16T10:00:00.000Z",
    "rejected_by_auth_user_id": "<user-uuid>"
  }
}
```

---

## POST /referrals/:id/complete

**Roles:** `admin`, `doctor`, `nurse`

**Purpose:** Complete a referral by admitting the patient at the receiving hospital.

### Request

```json
{
  "ward_id": "<ward-uuid>",
  "bed_number": "ICU-5",
  "notes": "Patient transferred from Korle-Bu"
}
```

### 201 Created

```json
{
  "success": true,
  "message": "Referral completed and patient admitted",
  "referral": {
    "id": "<referral-uuid>",
    "status": "completed",
    "completed_at": "2026-01-16T11:00:00.000Z"
  },
  "admission": {
    "id": "<admission-uuid>",
    "patient_id": "<patient-uuid>",
    "ward_id": "<ward-uuid>",
    "hospital_id": "<hospital-uuid>",
    "status": "admitted",
    "admitted_at": "2026-01-16T11:00:00.000Z"
  }
}
```

### 409 Conflict

```json
{ "error": "No beds available in selected ward" }
```

---

## PATCH /referrals/:id/cancel

**Roles:** `admin`, `doctor`

**Purpose:** Cancel an outgoing referral (sending hospital only, while still pending).

### Request

```json
{ "reason": "Patient condition stabilized" }
```

### 200 OK

```json
{
  "success": true,
  "message": "Referral cancelled",
  "referral": {
    "id": "<referral-uuid>",
    "status": "cancelled",
    "cancellation_reason": "Patient condition stabilized",
    "cancelled_at": "2026-01-16T10:30:00.000Z"
  }
}
```

---

## GET /dashboard/stats

**Roles:** `admin`, `doctor`, `nurse`

**Purpose:** Get dashboard statistics for the current user's hospital.

### 200 OK

```json
{
  "success": true,
  "data": {
    "summary": {
      "total_beds": 150,
      "occupied_beds": 120,
      "available_beds": 30,
      "occupancy_rate": 80.0
    },
    "today": {
      "admissions": 12,
      "discharges": 8,
      "net_change": 4
    },
    "referrals": {
      "pending_incoming": 3,
      "pending_outgoing": 2
    },
    "wards": [
      {
        "id": "<ward-uuid>",
        "name": "ICU",
        "ward_type": "icu",
        "total_beds": 10,
        "occupied_beds": 8,
        "available_beds": 2,
        "occupancy_rate": 80
      }
    ],
    "generated_at": "2026-01-16T10:00:00.000Z"
  }
}
```

---

## GET /dashboard/system-stats

**Roles:** `admin`

**Purpose:** Get system-wide statistics across all hospitals (admin only).

### 200 OK

```json
{
  "success": true,
  "data": {
    "hospitals": 45,
    "beds": {
      "total": 5000,
      "occupied": 4200,
      "available": 800,
      "occupancy_rate": 84.0
    },
    "today_admissions": 320,
    "pending_referrals": 25,
    "generated_at": "2026-01-16T10:00:00.000Z"
  }
}
```

---

## GET /audit-logs

**Roles:** `admin`

**Purpose:** List audit log entries for your hospital (paginated, filtered).

### Query Parameters

| Param | Type | Default | Description |
|-------|------|---------|-------------|
| `page` | int | 1 | Page number |
| `limit` | int | 20 | Items per page (max 100) |
| `action` | string | - | Filter by action (e.g., "admission.create", "referral.accept") |
| `entity_type` | string | - | Filter by entity type (admission, referral, discharge, patient) |
| `user_id` | uuid | - | Filter by user who performed action |
| `start_date` | date | - | Start of date range (YYYY-MM-DD) |
| `end_date` | date | - | End of date range (YYYY-MM-DD) |

### 200 OK

```json
{
  "success": true,
  "data": [
    {
      "id": "<audit-uuid>",
      "action": "admission.create",
      "entity_type": "admission",
      "entity_id": "<admission-uuid>",
      "user_id": "<user-uuid>",
      "hospital_id": "<hospital-uuid>",
      "metadata": { "patient_name": "Ama Mensah", "ward_name": "ICU" },
      "created_at": "2026-01-16T09:30:00.000Z"
    }
  ],
  "pagination": { "page": 1, "limit": 20, "total_count": 500, "total_pages": 25, "has_next": true, "has_prev": false }
}
```

---

## GET /audit-logs/summary

**Roles:** `admin`

**Purpose:** Get audit log statistics for reporting.

### Query Parameters

| Param | Type | Default | Description |
|-------|------|---------|-------------|
| `start_date` | date | 7 days ago | Start of date range |
| `end_date` | date | today | End of date range |

### 200 OK

```json
{
  "success": true,
  "data": {
    "period": {
      "start": "2026-01-09",
      "end": "2026-01-16"
    },
    "total_events": 150,
    "by_action": {
      "admission.create": 45,
      "discharge.create": 38,
      "referral.create": 12,
      "referral.accept": 8,
      "referral.complete": 6
    },
    "by_entity": {
      "admission": 45,
      "discharge": 38,
      "referral": 26
    }
  }
}
```

---

## GET /audit-logs/:id

**Roles:** `admin`

**Purpose:** Get a single audit log entry.

### 200 OK

```json
{
  "success": true,
  "data": {
    "id": "<audit-uuid>",
    "action": "referral.complete",
    "entity_type": "referral",
    "entity_id": "<referral-uuid>",
    "user_id": "<user-uuid>",
    "hospital_id": "<hospital-uuid>",
    "metadata": {
      "patient_id": "<patient-uuid>",
      "from_hospital": "Korle-Bu",
      "admission_id": "<admission-uuid>"
    },
    "created_at": "2026-01-16T11:00:00.000Z"
  }
}
```

### 404 Not Found

```json
{ "error": "Audit log entry not found" }
```
