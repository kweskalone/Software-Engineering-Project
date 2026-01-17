# Academic Framing (Project Documentation + Viva Defense)

## Technology Justification

- **Node.js + Express:**
  - Lightweight, easy to learn, large ecosystem.
  - Fast development and clear REST endpoint implementation.

- **Supabase (PostgreSQL + Auth):**
  - Provides managed Postgres (reliable, ACID transactions) and authentication.
  - Reduces time spent building user management, letting the project focus on hospital workflow.

- **JWT Authentication:**
  - Stateless auth fits REST APIs.
  - Tokens can be validated on each request and work across web/mobile clients.

## Architectural Decisions

- **Monolith instead of microservices:**
  - Lower operational complexity.
  - Easier debugging and deployment.
  - Suitable for an undergraduate timeline.

- **Ward-level bed counts instead of per-bed tracking:**
  - Simpler data model.
  - Works well in low-resource settings where exact bed-level state may be difficult to maintain.

- **Database-side transactions for admissions/discharges:**
  - Prevents race conditions (two staff admitting at once).
  - Enforces correctness ("no bed, no admission") even under concurrent requests.

## Key System Rules (Defense Summary)

- Admissions are blocked when there are no available beds.
- Successful admission reduces ward availability.
- Discharge increases ward availability.
- Referrals are only allowed when the current hospital has zero available beds.
- Only authorized roles can admit/discharge/refer.

## Security, Audit, and Quality (Defense Summary)

- **RLS policies** provide database-level protection even if an endpoint is misconfigured.
- **Audit logging** records all critical changes for accountability in healthcare settings.
- **Basic automated tests** validate request schemas and reduce regression risks.

## Intermittent Connectivity Consideration

- The system is designed to be simple and to fail clearly.
- Supabase is cloud-based; therefore, an offline-first system would require local synchronization, which is out of scope for this undergraduate project.
