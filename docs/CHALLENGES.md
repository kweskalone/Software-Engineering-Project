# Backend Challenges & Solutions (Living Document)

This is a **living log** of architecture/logic/implementation challenges (not syntax) encountered during the project, plus common issues students typically face.

Format: **Problem → Impact → Fix** (kept short).

---

## Challenges we actually faced in this project

### 1) CommonJS vs ES Modules mismatch

- **Problem:** The codebase started with `require/module.exports`, but we wanted `import/export`.
- **Impact:** Mixed module systems causes runtime import errors and inconsistent code style.
- **Fix:** Switched project to ESM by setting `"type": "module"` and updated all internal imports to include `.js` extensions.

### 2) Linting not enforced early

- **Problem:** No linting meant small structural issues slipped through.
- **Impact:** Inconsistent code quality and harder debugging as the code grows.
- **Fix:** Added ESLint (flat config) + `npm run lint`/`npm run lint:fix` scripts.

### 3) Race conditions in bed availability (admission logic)

- **Problem:** A naive API approach is: `SELECT available_beds` then `UPDATE available_beds = available_beds - 1`.
- **Impact:** Two admissions at the same time can overbook beds.
- **Fix:** Moved critical rules into PostgreSQL RPC (`create_admission`) using row locks (`FOR UPDATE`) so "no bed, no admission" is enforced atomically.

### 4) Capacity updates can violate occupancy

- **Problem:** If admins reduce `total_beds` without considering already admitted patients, the system becomes inconsistent.
- **Impact:** You can end up with `available_beds > total_beds` or negative availability.
- **Fix:** Added an RPC (`update_ward_capacity`) that computes occupied beds and blocks changes when `new_total_beds < occupied_beds`.

### 5) User provisioning needs higher privileges than normal queries

- **Problem:** Creating Supabase Auth users requires admin privileges.
- **Impact:** Trying to do it with the anon key fails; or devs accidentally expose admin keys.
- **Fix:** Admin-only endpoint `POST /users` uses `SUPABASE_SERVICE_ROLE_KEY`**server-side only** and creates both the Auth user and the app profile (`public.users`).

### 6) Schema drift after changes (don’t recreate everything)

- **Problem:** After adding new columns/functions, re-running full schema SQL can conflict with an existing DB.
- **Impact:** Broken deployments or accidental data loss.
- **Fix:** Created a separate migration SQL under `supabase/migrations/` that only alters existing tables and adds new RPC functions.

### 7) CORS errors when testing with frontend

- **Problem:** Browser showed "Access-Control-Allow-Origin" errors when React app tried to call the API.
- **Impact:** Frontend couldn't communicate with backend at all during development.
- **Fix:** Added `cors` middleware with proper configuration. Also learned that CORS is a browser security feature, not a backend bug—Postman worked fine because it ignores CORS.

### 8) Forgetting `await` on async functions

- **Problem:** Called Supabase queries without `await`, got `Promise { <pending> }` instead of actual data.
- **Impact:** Weird bugs where data was always `undefined` or conditions never worked.
- **Fix:** Learned to always `await` async calls. Also added ESLint rules to catch floating promises. Spent 2 hours debugging before realizing the missing `await`.

### 9) Confusion between Supabase anon key vs service role key

- **Problem:** User creation endpoint kept failing with "permission denied" errors.
- **Impact:** Couldn't create staff accounts; thought RLS was broken.
- **Fix:** Learned that `anon` key respects RLS policies (good for client-side), but `service_role` key bypasses RLS (needed for admin operations server-side). Used service role only in `POST /users`.

### 10) Middleware order matters in Express

- **Problem:** Put `express.json()` after route handlers; `req.body` was always `undefined`.
- **Impact:** All POST requests failed silently with empty bodies.
- **Fix:** Reordered middleware: security (helmet, cors) → body parsing → request ID → logging → routes → error handlers. Order is crucial!

### 11) RLS policies blocking legitimate queries

- **Problem:** After enabling RLS, even authenticated users got empty arrays from queries.
- **Impact:** Thought the code was broken; data existed but wasn't returned.
- **Fix:** RLS uses `auth.uid()` which requires the JWT to be passed correctly. When using service role key, RLS is bypassed entirely. Had to understand when to use which key.

### 12) Refresh tokens vs access tokens confusion

- **Problem:** Kept using refresh token as Bearer token; got "invalid token" errors.
- **Impact:** Users couldn't stay logged in; kept getting logged out.
- **Fix:** Access token = short-lived, used in `Authorization` header. Refresh token = long-lived, only sent to `/auth/refresh` to get new access token. They serve different purposes.

### 13) Foreign key constraints blocking test data cleanup

- **Problem:** Couldn't delete test hospitals because wards/admissions referenced them.
- **Impact:** Test database got cluttered; had to manually delete in correct order.
- **Fix:** Added `ON DELETE CASCADE` for wards (deleting hospital deletes its wards). Used `ON DELETE RESTRICT` for admissions (can't delete ward with active patients—this is intentional safety).

### 14) Pagination off-by-one errors

- **Problem:** First implementation showed duplicate items when navigating pages.
- **Impact:** Users saw same records on page 1 and page 2.
- **Fix:** Supabase `.range(start, end)` is inclusive on both ends. For page 1 with limit 20: `.range(0, 19)` not `.range(0, 20)`. Formula: `.range(offset, offset + limit - 1)`.

### 15) Rate limiting blocking during development

- **Problem:** Set strict rate limits, then got locked out while testing login repeatedly.
- **Impact:** Had to wait 15 minutes during debugging sessions.
- **Fix:** Made rate limits configurable via environment variables (stricter in production). Also learned to use different IP/sessions for testing.

### 16) Graceful shutdown not working on Windows

- **Problem:** `SIGTERM` signal doesn't work the same on Windows as Linux.
- **Impact:** `Ctrl+C` in terminal didn't trigger cleanup handlers.
- **Fix:** Added `SIGINT` handler alongside `SIGTERM`. Windows sends `SIGINT` on Ctrl+C. Both signals now trigger graceful shutdown.

### 17) Understanding when to use 4xx vs 5xx status codes

- **Problem:** Initially returned `500` for everything including validation errors.
- **Impact:** Frontend couldn't distinguish between "you made a mistake" and "server crashed".
- **Fix:** Created a mapping: 400 = bad input, 401 = not logged in, 403 = not allowed, 404 = not found, 409 = conflict (like no beds), 500 = actual server error. This helped frontend show appropriate messages.

### 18) Null vs undefined confusion in JavaScript

- **Problem:** Checked `if (!patient.national_id)` but this also matched empty string `""`.
- **Impact:** Patients with empty national_id passed validation but failed DB unique constraint.
- **Fix:** Learned to be explicit: `if (national_id === null || national_id === undefined)`. Also used Zod schemas to coerce empty strings to `null` before database insert.

### 19) Module exports not matching imports

- **Problem:** Created new controller with `export const AppError` but existing file only exported `{ notFoundHandler, errorHandler }`.
- **Impact:** Server crashed on startup with "does not provide an export named 'AppError'" error.
- **Fix:** Always check what a module exports before importing. Added `AppError` class to errorHandlers.js and updated the export statement. Could have also created a separate `errors.js` utility file.

### 20) Supabase client factory vs singleton confusion

- **Problem:** Existing code used `getSupabaseClients()` function, but new controllers tried to import `supabase` directly.
- **Impact:** Import errors crashed the server; inconsistent patterns across codebase.
- **Fix:** Added both patterns to `supabaseClient.js`: the factory function for flexibility AND a lazy-loaded singleton `supabase` for convenience. Used Proxy to defer initialization until first use.

### 21) Cross-hospital queries blocked by RLS

- **Problem:** Bed search across ALL hospitals returned empty because RLS restricted to user's own hospital.
- **Impact:** Couldn't find available beds at other hospitals—defeating the whole referral purpose!
- **Fix:** Had to add specific RLS policy for read-only cross-hospital visibility on `wards` table. Policy allows authenticated users to SELECT wards from any hospital, but INSERT/UPDATE/DELETE still restricted to own hospital.

### 22) State machine transitions not validated

- **Problem:** Initially allowed any status change on referrals (pending → completed, rejected → accepted).
- **Impact:** Broken workflow—could complete a rejected referral or accept an already cancelled one.
- **Fix:** Added explicit status checks before each transition: accept only from `pending`, complete only from `accepted`, cancel only `pending` referrals. Documented valid transitions in code comments.

### 23) Parallel database queries returning different formats

- **Problem:** Used `Promise.all()` for dashboard stats but forgot some queries use `{ count: 'exact', head: true }`.
- **Impact:** Tried to access `.data` on count queries which have `.count` instead. Got `undefined` everywhere.
- **Fix:** Count queries return `{ count, error }` not `{ data, error }`. Regular queries return `{ data, error }`. Had to destructure correctly for each type.

### 24) Date filtering with timezone issues

- **Problem:** Dashboard "today's admissions" query used `new Date().toISOString()` which is UTC.
- **Impact:** At 8 PM Ghana time (UTC+0), "today" was correct. But if server was in different timezone, counts were wrong.
- **Fix:** For simplicity, used UTC consistently: `new Date().toISOString().split('T')[0]` for the date portion. Documented that all timestamps are UTC. In production, would need proper timezone handling.

### 25) Forgetting to check authorization on nested resources

- **Problem:** Referral accept/reject checked if user belongs to `to_hospital_id`, but initially forgot to check.
- **Impact:** Any authenticated user could accept referrals for any hospital—major security bug.
- **Fix:** Added explicit `if (referral.to_hospital_id !== req.user.hospital_id)` check before allowing accept/reject. Similarly, cancel checks `from_hospital_id`. Always verify resource ownership!

### 26) Audit logging revealing sensitive data

- **Problem:** Logged entire request body including passwords in audit metadata.
- **Impact:** Passwords stored in plain text in audit_logs table—security nightmare.
- **Fix:** Created whitelist of safe fields to log. Never log `password`, `token`, or other secrets. Used `{ patient_name, ward_id }` instead of spreading entire objects.

### 27) Transaction rollback complexity with Supabase

- **Problem:** `completeReferral` does two operations: update referral status AND create admission. If admission fails, referral status shouldn't change.
- **Impact:** Could end up with `status: completed` referral but no admission record (inconsistent state).
- **Fix:** In Supabase without true transactions, ordered operations carefully: create admission first, then update referral. If admission fails, referral stays in `accepted` state. Better solution would be RPC function with ROLLBACK.

### 28) Filter parameters not sanitized

- **Problem:** Bed search accepted `ward_type` directly from query params without validation.
- **Impact:** Could pass SQL injection or invalid enum values causing cryptic DB errors.
- **Fix:** Validated `ward_type` against allowed values array before using in query. Also used Supabase's parameterized queries which escape values automatically.

### 29) Pagination metadata calculated incorrectly

- **Problem:** `total_pages` calculation used `Math.floor()` instead of `Math.ceil()`.
- **Impact:** With 25 items and limit 20, got 1 page instead of 2. Last 5 items unreachable!
- **Fix:** Correct formula: `Math.ceil(total_count / limit)`. Also added sanity checks: `has_next = page < total_pages`, `has_prev = page > 1`.

### 30) Dashboard stats hitting too many queries

- **Problem:** Initial dashboard made 10+ sequential queries, taking 2-3 seconds to load.
- **Impact:** Slow dashboard, poor user experience, high database load.
- **Fix:** Used `Promise.all()` to run independent queries in parallel. Reduced from ~2.5s to ~400ms. Also considered caching stats with short TTL (future improvement).

## Common backend challenges students face (and how to handle them)

### A) Overloading controllers with business logic

- **Problem:** Controllers directly do validation + DB logic + rule enforcement.
- **Impact:** Harder testing and changes break multiple endpoints.
- **Fix:** Keep controllers thin; put logic in `services/` and keep DB helpers separate.

### B) Not enforcing authorization consistently

- **Problem:** Some routes forget `requireAuth` or forget role checks.
- **Impact:** Security holes (e.g., nurses creating referrals when only doctors should).
- **Fix:** Use standard middleware everywhere; define allowed roles per route (RBAC).

### C) Confusing “authentication” vs “authorization”

- **Problem:** Treating “logged in” as “allowed to do anything”.
- **Impact:** Incorrect access control and weak defense explanation.
- **Fix:** Authentication = identity (JWT). Authorization = permissions (role + hospital scope).

### D) Weak scoping in multi-hospital systems

- **Problem:** Queries don’t filter by `hospital_id`.
- **Impact:** Users can see/update other hospitals’ data.
- **Fix:** Always scope reads/writes by `hospital_id` (or do it with RLS policies in Supabase).

### E) Designing tables too granular too early (per-bed tracking)

- **Problem:** Modeling each bed as a row from day 1.
- **Impact:** More complexity than needed, harder UI/workflows.
- **Fix:** Start with ward-level counts (`total_beds`, `available_beds`). Add per-bed later only if required.

### F) Not using state machines for workflows

- **Problem:** Treating status as just a string that can be set to anything.
- **Impact:** Invalid state transitions (e.g., `pending` → `completed` skipping `accepted`).
- **Fix:** Define valid transitions explicitly. Referral flow: `pending → accepted → completed` OR `pending → rejected` OR `pending → cancelled`. Validate current state before allowing transition.

### G) Dashboard queries not optimized

- **Problem:** Making 10+ sequential queries to build dashboard data.
- **Impact:** Dashboard takes 3+ seconds to load, bad user experience.
- **Fix:** Use `Promise.all()` for parallel queries. Consider database views or materialized views for complex aggregations. Cache expensive computations with short TTL.

### H) Audit logs missing context

- **Problem:** Only logging "action happened" without who/what/when details.
- **Impact:** Can't trace issues, compliance problems, useless for debugging.
- **Fix:** Always log: `action`, `entity_type`, `entity_id`, `user_id`, `hospital_id`, `timestamp`, and relevant `metadata`. But never log sensitive data like passwords!

### I) Hardcoding allowed values instead of using constants

- **Problem:** Writing `role === 'admin'` in 15 different places.
- **Impact:** Typos cause bugs ("Admin" vs "admin"). Adding new role requires finding all checks.
- **Fix:** Define constants: `const ROLES = ['admin', 'doctor', 'nurse']`. Validate against array: `ROLES.includes(role)`. Same for statuses, ward types, etc.

### J) Not handling the "no beds" case gracefully in referral completion

- **Problem:** Completing referral creates admission, but what if beds ran out since acceptance?
- **Impact:** Either admission fails with cryptic error, or system allows overbooking.
- **Fix:** Check bed availability immediately before creating admission. Return clear 409 error: "No beds available in selected ward". User can then search for alternative wards.

### F) Missing “state machine” for admissions/referrals

- **Problem:** Status fields exist but transitions aren’t defined.
- **Impact:** Weird states (e.g., discharged twice, referral completed without acceptance).
- **Fix:** Define allowed statuses + transitions and enforce them in DB/RPC or service layer.

### G) Error handling without clear status codes

- **Problem:** Everything returns `500`.
- **Impact:** Clients can’t respond correctly; debugging is harder.
- **Fix:** Map rules to status codes (e.g., 409 for capacity conflicts, 403 forbidden, 404 not found).

### H) Not understanding the request-response cycle

- **Problem:** Calling `res.json()` multiple times or forgetting to `return` after sending response.
- **Impact:** "Cannot set headers after they are sent" errors crash the server.
- **Fix:** Always `return res.status().json()` to prevent code from continuing after response is sent.

### I) Hardcoding values instead of using environment variables

- **Problem:** Putting Supabase URL directly in code, then pushing to GitHub.
- **Impact:** Exposed credentials; had to rotate keys and scrub git history.
- **Fix:** Use `.env` file (never committed) + `.env.example` (committed as template). Access via `process.env.VARIABLE_NAME`.

### J) Not validating request body before using it

- **Problem:** Trusted that `req.body.patient.full_name` exists without checking.
- **Impact:** "Cannot read property of undefined" crashes when fields are missing.
- **Fix:** Use Zod schemas to validate input structure before processing. Invalid requests get 400 with helpful error messages.

### K) Testing only happy paths

- **Problem:** Only tested "create admission" with valid data, never with missing fields or no beds.
- **Impact:** Edge cases crashed in demo; embarrassing during presentation.
- **Fix:** Write tests for error cases too: missing fields, invalid IDs, capacity exceeded, unauthorized access.
