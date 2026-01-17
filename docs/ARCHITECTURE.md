# Backend Architecture (Monolithic REST API)

## 1) High-level Architecture

This project uses a **monolithic REST API** built with **Node.js + Express**, connected to **Supabase (PostgreSQL + Auth)**.

**Why a monolith (undergraduate + low-resource constraints):**

- Fewer moving parts than microservices (easier to build, deploy, and debug).
- Easier for a viva/project defense: one API, one database, clear flows.
- Works well in low-resource settings where the priority is reliability and simplicity.

### Components

1. **Client (not included here)**
   - Mobile app or web app used by clinicians.

2. **Express REST API (this repo)**
   - Implements business rules and exposes endpoints.
   - Performs authentication (JWT validation via Supabase Auth).
   - Enforces role-based access control (Admin/Doctor/Nurse).
   - **Security middleware:** CORS, Helmet (security headers).
   - **Pagination:** All list endpoints support `?page=1&limit=20`.
   - **Graceful shutdown:** Handles SIGTERM/SIGINT for clean deployments.

3. **Supabase**
   - **Supabase Auth** issues JWT tokens after login.
   - **PostgreSQL** stores hospitals, wards, bed availability, patients, admissions, referrals.
   - **RPC (stored functions)** handle atomic bed updates (prevents race conditions).
   - **RLS Policies** (Row Level Security) enforce hospital/role data boundaries at the database layer.
   - **Audit Logs** capture critical changes (admissions, discharges, referrals, capacity changes).
   - **Rate Limiting** configured via Supabase Dashboard (100 req/min general, 5 login attempts/min).

## 2) Component Interaction (Express API ↔ Supabase)

### Login

1. User sends email/password to `POST /auth/login`.
2. Express calls `supabase.auth.signInWithPassword`.
3. Supabase returns a **JWT access token**.
4. Client stores token and sends it in `Authorization: Bearer <token>` for future requests.

### Protected API Request

1. Client calls a protected endpoint with Bearer token.
2. Express middleware calls `supabase.auth.getUser(token)`.
3. Express loads app profile from `public.users` to get **role** and **hospital_id**.
4. If role is allowed, request proceeds to controller/service.

## 3) Critical Consistency Design: “No Bed, No Admission”

Hospital bed availability can change quickly (multiple staff admitting at the same time). To avoid admitting more patients than available beds, **bed decrement is done inside PostgreSQL in a single transaction**.

This project uses Postgres RPC functions:

- `create_admission(...)`: locks the ward row, blocks admission if `available_beds = 0`, decrements availability, and creates an admission record (all in one transaction).
- `discharge_patient(...)`: locks the admission row, prevents double discharge, marks the admission as discharged, and increments availability (capped at `total_beds`).
- `update_ward_capacity(...)`: safely changes `total_beds` while preserving real occupancy; it prevents setting capacity below currently occupied beds.

This is safer than doing “SELECT then UPDATE” in the API.

## 4) Intermittent Internet Considerations

This system still depends on internet connectivity because Supabase is cloud-hosted. However, the backend is designed to:

- Fail fast with clear error messages (e.g., 503/500) when connectivity is lost.
- Avoid complex distributed coordination.
- Keep operations transactional server-side to avoid partial updates.

For a full Ghana deployment, hospitals could optionally run a local replica, but that is out of scope for this undergraduate system.

## 5) Defense-ready Summary

- **Problem:** No Bed Syndrome is worsened by lack of real-time visibility and slow referrals.
- **Solution:** Centralize ward-level bed availability and enforce rules that prevent admitting beyond capacity.
- **Key design choice:** Use a monolithic API and database-side transactions to ensure correctness.
- **Security:** Supabase Auth JWT + role-based access control + CORS + Helmet security headers + Express rate limiting.
- **Auditability:** Central audit log records who changed what and when.
- **Traceability:** Each API response includes `request_id` for easier debugging and support.
- **Scalability:** Pagination on all list endpoints to handle growing data.
- **Reliability:** Graceful shutdown ensures in-flight requests complete during deployments.
- **Complete Auth Flow:** Login, logout, refresh tokens, password reset.

## 6) New Features (January 2026)

### Security Enhancements

- **CORS:** Configured via `CORS_ORIGIN` env var (defaults to `*` for dev).
- **Helmet:** Adds security headers (X-Content-Type-Options, X-Frame-Options, etc.).
- **Rate Limiting:** Implemented in Express middleware:
  - General API: 100 requests/minute per IP
  - Auth endpoints (login/refresh): 10 requests/minute per IP
  - Password reset: 3 requests/15 minutes per IP
  - User creation: 5 requests/minute per IP

### API Completeness

- **GET /admissions:** List and filter admissions by status/ward.
- **GET /admissions/:id:** Get admission details with patient and ward info.
- **GET /referrals:** List referrals with direction filter (outgoing/incoming).
- **GET /referrals/:id:** Get referral details.
- **GET /patients:** Search patients by name or national ID.
- **GET /patients/:id:** Get patient with admission history.

### Auth Enhancements

- **POST /auth/refresh:** Exchange refresh token for new access token.
- **POST /auth/logout:** Invalidate current session.
- **POST /auth/forgot-password:** Request password reset email.
- **POST /auth/reset-password:** Set new password after reset.

### Operational Improvements

- **GET /health/ready:** Deep health check that verifies DB connectivity.
- **Environment validation:** Fails fast at startup if required env vars are missing.
- **Graceful shutdown:** Handles SIGTERM/SIGINT to complete in-flight requests.
- **Pagination:** All list endpoints support `?page=X&limit=Y` (max 100 per page).
