-- =========================================
-- MIGRATION: Complete Schema Update
-- Date: 2026-01-16
-- Target: Supabase (PostgreSQL)
-- =========================================
-- This migration adds all missing tables, columns, indexes, functions, and RLS policies.
-- Safe to run multiple times (uses IF NOT EXISTS / OR REPLACE where possible).

-- ============================================
-- 1) MISSING COLUMNS: wards table
-- ============================================
-- The dashboard controller expects 'ward_type' and 'occupied_beds' columns

-- Add ward_type column (alias for 'type' for compatibility)
-- Note: If your code uses 'type', this creates a computed column for dashboard compatibility
do $$
begin
  if not exists (
    select 1 from information_schema.columns
    where table_name = 'wards' and column_name = 'ward_type'
  ) then
    alter table wards add column ward_type text;
    -- Backfill from existing 'type' column
    update wards set ward_type = type where ward_type is null;
  end if;
end $$;

-- Add occupied_beds column (computed as total_beds - available_beds)
-- This is useful for dashboard queries
do $$
begin
  if not exists (
    select 1 from information_schema.columns
    where table_name = 'wards' and column_name = 'occupied_beds'
  ) then
    alter table wards add column occupied_beds integer default 0;
    -- Backfill: occupied = total - available
    update wards set occupied_beds = total_beds - available_beds where occupied_beds = 0;
  end if;
end $$;

-- Create a trigger to keep occupied_beds in sync
create or replace function sync_occupied_beds()
returns trigger
language plpgsql
as $$
begin
  new.occupied_beds := new.total_beds - new.available_beds;
  return new;
end;
$$;

drop trigger if exists wards_sync_occupied on wards;
create trigger wards_sync_occupied
before insert or update on wards
for each row
execute function sync_occupied_beds();

-- ============================================
-- 2) MISSING TABLE: discharges (optional view)
-- ============================================
-- The dashboard queries a 'discharges' table, but discharges are stored in 'admissions'.
-- Create a view to satisfy dashboard queries without duplicating data.

drop view if exists discharges;
create or replace view discharges as
select
  id,
  patient_id,
  hospital_id,
  ward_id,
  discharged_at,
  discharged_by_auth_user_id
from admissions
where status = 'discharged' and discharged_at is not null;

-- ============================================
-- 3) ADD MISSING INDEXES
-- ============================================
create index if not exists admissions_status_idx on admissions(status);
create index if not exists admissions_admitted_at_idx on admissions(admitted_at);
create index if not exists admissions_discharged_at_idx on admissions(discharged_at);
create index if not exists referrals_status_idx on referrals(status);
create index if not exists referrals_created_at_idx on referrals(created_at);
create index if not exists patients_full_name_idx on patients(full_name);
create index if not exists wards_available_beds_idx on wards(available_beds);
create index if not exists wards_type_idx on wards(type);
create index if not exists audit_logs_created_at_idx on audit_logs(created_at);
create index if not exists audit_logs_action_idx on audit_logs(action);

-- ============================================
-- 4) ADD MISSING COLUMNS TO referrals
-- ============================================
-- Add accepted_at and completed_at timestamps for tracking referral lifecycle
do $$
begin
  if not exists (
    select 1 from information_schema.columns
    where table_name = 'referrals' and column_name = 'accepted_at'
  ) then
    alter table referrals add column accepted_at timestamptz null;
  end if;
  
  if not exists (
    select 1 from information_schema.columns
    where table_name = 'referrals' and column_name = 'completed_at'
  ) then
    alter table referrals add column completed_at timestamptz null;
  end if;
  
  if not exists (
    select 1 from information_schema.columns
    where table_name = 'referrals' and column_name = 'rejected_at'
  ) then
    alter table referrals add column rejected_at timestamptz null;
  end if;
  
  if not exists (
    select 1 from information_schema.columns
    where table_name = 'referrals' and column_name = 'cancelled_at'
  ) then
    alter table referrals add column cancelled_at timestamptz null;
  end if;

  if not exists (
    select 1 from information_schema.columns
    where table_name = 'referrals' and column_name = 'to_ward_id'
  ) then
    alter table referrals add column to_ward_id uuid null references wards(id);
  end if;

  if not exists (
    select 1 from information_schema.columns
    where table_name = 'referrals' and column_name = 'rejection_reason'
  ) then
    alter table referrals add column rejection_reason text null;
  end if;

  if not exists (
    select 1 from information_schema.columns
    where table_name = 'referrals' and column_name = 'updated_by_auth_user_id'
  ) then
    alter table referrals add column updated_by_auth_user_id uuid null;
  end if;
end $$;

-- ============================================
-- 5) ADD MISSING COLUMNS TO users
-- ============================================
-- Add name and email for better user management
do $$
begin
  if not exists (
    select 1 from information_schema.columns
    where table_name = 'users' and column_name = 'full_name'
  ) then
    alter table users add column full_name text null;
  end if;
  
  if not exists (
    select 1 from information_schema.columns
    where table_name = 'users' and column_name = 'email'
  ) then
    alter table users add column email text null;
  end if;

  if not exists (
    select 1 from information_schema.columns
    where table_name = 'users' and column_name = 'is_active'
  ) then
    alter table users add column is_active boolean default true;
  end if;
end $$;

-- ============================================
-- 6) ROW LEVEL SECURITY (RLS)
-- ============================================
-- Enable RLS on all tables (safe to run multiple times)
alter table hospitals enable row level security;
alter table wards enable row level security;
alter table patients enable row level security;
alter table admissions enable row level security;
alter table referrals enable row level security;
alter table users enable row level security;
alter table audit_logs enable row level security;

-- Drop existing policies to recreate them cleanly
drop policy if exists hospitals_select on hospitals;
drop policy if exists hospitals_write_admin on hospitals;
drop policy if exists wards_select on wards;
drop policy if exists wards_write_admin on wards;
drop policy if exists patients_select on patients;
drop policy if exists patients_insert on patients;
drop policy if exists admissions_select on admissions;
drop policy if exists admissions_insert on admissions;
drop policy if exists referrals_select on referrals;
drop policy if exists referrals_insert on referrals;
drop policy if exists referrals_update on referrals;
drop policy if exists users_select on users;
drop policy if exists users_write_admin on users;
drop policy if exists audit_logs_select on audit_logs;
drop policy if exists audit_logs_insert on audit_logs;

-- ==================
-- HOSPITALS POLICIES
-- ==================
-- Any authenticated user can view all hospitals (needed for referral search)
create policy hospitals_select
  on hospitals for select
  using (auth.uid() is not null);

-- Only admins can insert/update/delete hospitals
create policy hospitals_write_admin
  on hospitals for all
  using (
    exists (
      select 1 from users u 
      where u.auth_user_id = auth.uid() 
      and u.role = 'admin'
    )
  )
  with check (
    exists (
      select 1 from users u 
      where u.auth_user_id = auth.uid() 
      and u.role = 'admin'
    )
  );

-- ==================
-- WARDS POLICIES
-- ==================
-- Any authenticated user can view wards (needed for bed search across hospitals)
create policy wards_select
  on wards for select
  using (auth.uid() is not null);

-- Only admins can write to wards in their own hospital
create policy wards_write_admin
  on wards for all
  using (
    exists (
      select 1 from users u 
      where u.auth_user_id = auth.uid() 
      and u.role = 'admin' 
      and u.hospital_id = wards.hospital_id
    )
  )
  with check (
    exists (
      select 1 from users u 
      where u.auth_user_id = auth.uid() 
      and u.role = 'admin' 
      and u.hospital_id = wards.hospital_id
    )
  );

-- ==================
-- PATIENTS POLICIES
-- ==================
-- Staff can view patients that have admissions in their hospital
create policy patients_select
  on patients for select
  using (
    exists (
      select 1 from users u 
      where u.auth_user_id = auth.uid()
    )
    and (
      -- Patient has admission in user's hospital
      exists (
        select 1 from admissions a
        join users u on u.hospital_id = a.hospital_id
        where a.patient_id = patients.id
        and u.auth_user_id = auth.uid()
      )
      or
      -- Patient has referral involving user's hospital
      exists (
        select 1 from referrals r
        join users u on (u.hospital_id = r.from_hospital_id or u.hospital_id = r.to_hospital_id)
        where r.patient_id = patients.id
        and u.auth_user_id = auth.uid()
      )
    )
  );

-- Staff (doctors, nurses, admins) can insert patients
create policy patients_insert
  on patients for insert
  with check (
    exists (
      select 1 from users u 
      where u.auth_user_id = auth.uid()
      and u.role in ('admin', 'doctor', 'nurse')
    )
  );

-- ==================
-- ADMISSIONS POLICIES
-- ==================
-- Staff can view admissions for their hospital
create policy admissions_select
  on admissions for select
  using (
    exists (
      select 1 from users u 
      where u.auth_user_id = auth.uid() 
      and u.hospital_id = admissions.hospital_id
    )
  );

-- Staff can create admissions for their hospital
create policy admissions_insert
  on admissions for insert
  with check (
    exists (
      select 1 from users u 
      where u.auth_user_id = auth.uid() 
      and u.hospital_id = admissions.hospital_id
      and u.role in ('admin', 'doctor', 'nurse')
    )
  );

-- ==================
-- REFERRALS POLICIES
-- ==================
-- Staff can view referrals where their hospital is sender OR receiver
create policy referrals_select
  on referrals for select
  using (
    exists (
      select 1 from users u 
      where u.auth_user_id = auth.uid() 
      and (
        u.hospital_id = referrals.from_hospital_id 
        or u.hospital_id = referrals.to_hospital_id
      )
    )
  );

-- Staff can create referrals from their hospital
create policy referrals_insert
  on referrals for insert
  with check (
    exists (
      select 1 from users u 
      where u.auth_user_id = auth.uid() 
      and u.hospital_id = referrals.from_hospital_id
      and u.role in ('admin', 'doctor', 'nurse')
    )
  );

-- Staff can update referrals where they are sender or receiver
create policy referrals_update
  on referrals for update
  using (
    exists (
      select 1 from users u 
      where u.auth_user_id = auth.uid() 
      and (
        u.hospital_id = referrals.from_hospital_id 
        or u.hospital_id = referrals.to_hospital_id
      )
      and u.role in ('admin', 'doctor', 'nurse')
    )
  )
  with check (
    exists (
      select 1 from users u 
      where u.auth_user_id = auth.uid() 
      and (
        u.hospital_id = referrals.from_hospital_id 
        or u.hospital_id = referrals.to_hospital_id
      )
      and u.role in ('admin', 'doctor', 'nurse')
    )
  );

-- ==================
-- USERS POLICIES
-- ==================
-- Staff can view users in their hospital
create policy users_select
  on users for select
  using (
    -- Can see users in same hospital
    exists (
      select 1 from users u 
      where u.auth_user_id = auth.uid() 
      and u.hospital_id = users.hospital_id
    )
    or
    -- Can see own profile
    users.auth_user_id = auth.uid()
  );

-- Only admins can write to users table in their hospital
create policy users_write_admin
  on users for all
  using (
    exists (
      select 1 from users u 
      where u.auth_user_id = auth.uid() 
      and u.role = 'admin' 
      and u.hospital_id = users.hospital_id
    )
  )
  with check (
    exists (
      select 1 from users u 
      where u.auth_user_id = auth.uid() 
      and u.role = 'admin' 
      and u.hospital_id = users.hospital_id
    )
  );

-- ==================
-- AUDIT LOGS POLICIES
-- ==================
-- Only admins can view audit logs
create policy audit_logs_select
  on audit_logs for select
  using (
    exists (
      select 1 from users u 
      where u.auth_user_id = auth.uid() 
      and u.role = 'admin'
    )
  );

-- Any authenticated user can insert audit logs (for tracking actions)
create policy audit_logs_insert
  on audit_logs for insert
  with check (auth.uid() is not null);

-- ============================================
-- 7) HELPER FUNCTIONS
-- ============================================

-- Function to get hospital bed summary
create or replace function get_hospital_bed_summary(p_hospital_id uuid)
returns jsonb
language plpgsql
security definer
as $$
declare
  v_result jsonb;
begin
  select jsonb_build_object(
    'hospital_id', p_hospital_id,
    'total_beds', coalesce(sum(total_beds), 0),
    'available_beds', coalesce(sum(available_beds), 0),
    'occupied_beds', coalesce(sum(occupied_beds), 0),
    'occupancy_rate', case 
      when coalesce(sum(total_beds), 0) > 0 
      then round((coalesce(sum(occupied_beds), 0)::numeric / sum(total_beds)::numeric) * 100, 1)
      else 0 
    end,
    'ward_count', count(*)
  ) into v_result
  from wards
  where hospital_id = p_hospital_id;
  
  return v_result;
end;
$$;

-- Function to get system-wide bed availability (for No Bed Syndrome dashboard)
create or replace function get_system_bed_availability(
  p_region text default null,
  p_district text default null,
  p_ward_type text default null,
  p_min_beds integer default 1
)
returns table (
  hospital_id uuid,
  hospital_name text,
  region text,
  district text,
  ward_id uuid,
  ward_name text,
  ward_type text,
  total_beds integer,
  available_beds integer
)
language plpgsql
security definer
as $$
begin
  return query
  select 
    h.id as hospital_id,
    h.name as hospital_name,
    h.region,
    h.district,
    w.id as ward_id,
    w.name as ward_name,
    w.type as ward_type,
    w.total_beds,
    w.available_beds
  from wards w
  join hospitals h on h.id = w.hospital_id
  where w.available_beds >= p_min_beds
    and (p_region is null or h.region ilike p_region)
    and (p_district is null or h.district ilike p_district)
    and (p_ward_type is null or w.type ilike p_ward_type)
  order by w.available_beds desc, h.name;
end;
$$;

-- Function to complete a referral (accept, transfer patient, create admission)
create or replace function complete_referral(
  p_referral_id uuid,
  p_actor_auth_user_id uuid,
  p_to_ward_id uuid
)
returns jsonb
language plpgsql
as $$
declare
  v_referral referrals%rowtype;
  v_ward wards%rowtype;
  v_actor_hospital_id uuid;
  v_admission_id uuid;
  v_new_available integer;
begin
  -- Get actor's hospital
  select hospital_id into v_actor_hospital_id
  from users
  where auth_user_id = p_actor_auth_user_id;

  if v_actor_hospital_id is null then
    raise exception 'ACTOR_NOT_FOUND';
  end if;

  -- Get and lock referral
  select * into v_referral
  from referrals
  where id = p_referral_id
  for update;

  if not found then
    raise exception 'REFERRAL_NOT_FOUND';
  end if;

  -- Must be the receiving hospital
  if v_referral.to_hospital_id <> v_actor_hospital_id then
    raise exception 'NOT_RECEIVING_HOSPITAL';
  end if;

  -- Must be in accepted status
  if v_referral.status <> 'accepted' then
    raise exception 'REFERRAL_NOT_ACCEPTED';
  end if;

  -- Get and lock ward
  select * into v_ward
  from wards
  where id = p_to_ward_id
  for update;

  if not found then
    raise exception 'WARD_NOT_FOUND';
  end if;

  if v_ward.hospital_id <> v_actor_hospital_id then
    raise exception 'WARD_HOSPITAL_MISMATCH';
  end if;

  if v_ward.available_beds <= 0 then
    raise exception 'NO_BEDS_AVAILABLE';
  end if;

  -- Update ward availability
  update wards
  set available_beds = available_beds - 1
  where id = p_to_ward_id
  returning available_beds into v_new_available;

  -- Create admission at receiving hospital
  insert into admissions (
    patient_id, 
    hospital_id, 
    ward_id, 
    status, 
    admitted_by_auth_user_id
  )
  values (
    v_referral.patient_id,
    v_actor_hospital_id,
    p_to_ward_id,
    'admitted',
    p_actor_auth_user_id
  )
  returning id into v_admission_id;

  -- Mark referral as completed
  update referrals
  set 
    status = 'completed',
    completed_at = now(),
    to_ward_id = p_to_ward_id,
    updated_by_auth_user_id = p_actor_auth_user_id
  where id = p_referral_id;

  return jsonb_build_object(
    'referral', jsonb_build_object(
      'id', v_referral.id,
      'status', 'completed',
      'completed_at', now()
    ),
    'admission', jsonb_build_object(
      'id', v_admission_id,
      'patient_id', v_referral.patient_id,
      'ward_id', p_to_ward_id,
      'hospital_id', v_actor_hospital_id
    ),
    'ward', jsonb_build_object(
      'id', v_ward.id,
      'available_beds', v_new_available
    )
  );
end;
$$;

-- Function to accept a referral
create or replace function accept_referral(
  p_referral_id uuid,
  p_actor_auth_user_id uuid
)
returns jsonb
language plpgsql
as $$
declare
  v_referral referrals%rowtype;
  v_actor_hospital_id uuid;
begin
  -- Get actor's hospital
  select hospital_id into v_actor_hospital_id
  from users
  where auth_user_id = p_actor_auth_user_id;

  if v_actor_hospital_id is null then
    raise exception 'ACTOR_NOT_FOUND';
  end if;

  -- Get and lock referral
  select * into v_referral
  from referrals
  where id = p_referral_id
  for update;

  if not found then
    raise exception 'REFERRAL_NOT_FOUND';
  end if;

  -- Must be the receiving hospital
  if v_referral.to_hospital_id <> v_actor_hospital_id then
    raise exception 'NOT_RECEIVING_HOSPITAL';
  end if;

  -- Update referral status (trigger will validate transition)
  update referrals
  set 
    status = 'accepted',
    accepted_at = now(),
    updated_by_auth_user_id = p_actor_auth_user_id
  where id = p_referral_id;

  return jsonb_build_object(
    'referral', jsonb_build_object(
      'id', v_referral.id,
      'status', 'accepted',
      'accepted_at', now()
    )
  );
end;
$$;

-- Function to reject a referral
create or replace function reject_referral(
  p_referral_id uuid,
  p_actor_auth_user_id uuid,
  p_rejection_reason text default null
)
returns jsonb
language plpgsql
as $$
declare
  v_referral referrals%rowtype;
  v_actor_hospital_id uuid;
begin
  -- Get actor's hospital
  select hospital_id into v_actor_hospital_id
  from users
  where auth_user_id = p_actor_auth_user_id;

  if v_actor_hospital_id is null then
    raise exception 'ACTOR_NOT_FOUND';
  end if;

  -- Get and lock referral
  select * into v_referral
  from referrals
  where id = p_referral_id
  for update;

  if not found then
    raise exception 'REFERRAL_NOT_FOUND';
  end if;

  -- Must be the receiving hospital
  if v_referral.to_hospital_id <> v_actor_hospital_id then
    raise exception 'NOT_RECEIVING_HOSPITAL';
  end if;

  -- Update referral status (trigger will validate transition)
  update referrals
  set 
    status = 'rejected',
    rejected_at = now(),
    rejection_reason = p_rejection_reason,
    updated_by_auth_user_id = p_actor_auth_user_id
  where id = p_referral_id;

  return jsonb_build_object(
    'referral', jsonb_build_object(
      'id', v_referral.id,
      'status', 'rejected',
      'rejected_at', now(),
      'rejection_reason', p_rejection_reason
    )
  );
end;
$$;

-- ============================================
-- 8) GRANTS FOR SERVICE ROLE
-- ============================================
-- Grant execute permissions on functions (for Supabase service role)
grant execute on function get_hospital_bed_summary(uuid) to service_role;
grant execute on function get_system_bed_availability(text, text, text, integer) to service_role;
grant execute on function complete_referral(uuid, uuid, uuid) to service_role;
grant execute on function accept_referral(uuid, uuid) to service_role;
grant execute on function reject_referral(uuid, uuid, text) to service_role;
grant execute on function create_admission(uuid, uuid, text, text, date, text, text, uuid) to service_role;
grant execute on function discharge_patient(uuid, uuid, uuid) to service_role;
grant execute on function update_ward_capacity(uuid, uuid, integer, uuid) to service_role;

-- Grant usage on schema
grant usage on schema public to anon, authenticated, service_role;

-- Grant table permissions
grant select on hospitals to anon, authenticated;
grant select on wards to anon, authenticated;
grant all on hospitals to service_role;
grant all on wards to service_role;
grant all on patients to service_role;
grant all on admissions to service_role;
grant all on referrals to service_role;
grant all on users to service_role;
grant all on audit_logs to service_role;

-- Grant view permissions
grant select on discharges to authenticated, service_role;

-- ============================================
-- DONE
-- ============================================
-- Run this SQL in your Supabase SQL Editor to apply all changes.
-- This migration is idempotent and safe to run multiple times.
