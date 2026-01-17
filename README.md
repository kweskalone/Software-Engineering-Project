# Hospital Bed Management & Referral System (Backend)

Monolithic REST API for an undergraduate project targeting "No Bed Syndrome" mitigation in Ghana.

## Quick Start

1. Create a Supabase project.
2. If you are setting up the database from scratch, run: [supabase/DATABASE_SCHEMA.sql](supabase/DATABASE_SCHEMA.sql)
3. If you already created the tables earlier and only need the latest updates (e.g., new columns/RPC), run the migration(s) in: [supabase/migrations](supabase/migrations)
4. Copy `.env.example` to `.env` and fill in your Supabase keys.
5. Install dependencies:
   - `npm install`
6. Run:
   - `npm run dev`
7. Optional:
    - `npm test` (schema validation checks)

## Environment Variables

| Variable | Required | Description |
|----------|----------|-------------|

| `SUPABASE_URL` | ✅ | Your Supabase project URL |
| `SUPABASE_ANON_KEY` | ✅ | Supabase anon/public key |
| `SUPABASE_SERVICE_ROLE_KEY` | ⚠️ | Service role key (needed for user creation) |
| `PORT` | ❌ | Server port (default: 3000) |
| `CORS_ORIGIN` | ❌ | Allowed CORS origin (default: `*`) |
| `PASSWORD_RESET_REDIRECT_URL` | ❌ | Frontend URL for password reset (default: `http://localhost:3000/reset-password`) |

## API Endpoints

### Health

- `GET /health` - Liveness check
- `GET /health/ready` - Readiness check (verifies DB connectivity)

### Auth

- `POST /auth/login` - Login with email/password
- `POST /auth/refresh` - Refresh access token
- `POST /auth/logout` - Logout (invalidate session)
- `POST /auth/forgot-password` - Request password reset email
- `POST /auth/reset-password` - Set new password

### Resources (all paginated)

- `GET/POST /hospitals` - List/create hospitals
- `GET/POST /wards` - List/create wards
- `GET/POST /admissions` - List/create admissions
- `GET/POST /referrals` - List/create referrals
- `GET /patients` - Search patients
- `POST /discharges` - Discharge patient
- `POST /users` - Create staff account (admin only)

See [docs/API.md](docs/API.md) for full request/response examples.

## Docs

- Architecture: [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md)
- API examples: [docs/API.md](docs/API.md)
- Academic notes: [docs/ACADEMIC_NOTES.md](docs/ACADEMIC_NOTES.md)

## Project Structure

- `src/app.js` Express app wiring (CORS, Helmet, routes)
- `src/server.js` Server entry (env validation, graceful shutdown)
- `src/config/` Supabase client + environment validation
- `src/middleware/` Auth + RBAC + error handling
- `src/routes/` Route definitions
- `src/controllers/` HTTP controllers
- `src/services/` Business logic + Supabase operations
- `src/utils/` Utilities (pagination helper)
