-- =========================================
-- MIGRATION: Bed Reservation Policy
-- Date: 2026-01-19
-- Purpose: Temporary bed hold during referral acceptance
-- =========================================
-- This migration adds bed reservation functionality to prevent double-booking
-- when a referral is accepted but not yet completed (patient not yet admitted).

-- ============================================
-- 1) BED RESERVATIONS TABLE
-- ============================================
-- Stores temporary bed holds with expiration

create table if not exists bed_reservations (
  id uuid primary key default gen_random_uuid(),
  
  -- The referral this reservation is for
  referral_id uuid not null references referrals(id) on delete cascade,
  
  -- Where the bed is reserved
  hospital_id uuid not null references hospitals(id) on delete cascade,
  ward_id uuid not null references wards(id) on delete cascade,
  
  -- Who made the reservation
  reserved_by_auth_user_id uuid not null,
  
  -- Reservation timing
  reserved_at timestamptz not null default now(),
  expires_at timestamptz not null,
  
  -- Status: active, completed (patient admitted), expired, cancelled
  status text not null default 'active' check (status in ('active', 'completed', 'expired', 'cancelled')),
  
  -- When status changed
  completed_at timestamptz null,
  cancelled_at timestamptz null,
  
  created_at timestamptz not null default now(),
  
  -- One active reservation per referral
  constraint bed_reservations_unique_active unique (referral_id, status)
);

-- Indexes for common queries
create index if not exists bed_reservations_referral_idx on bed_reservations(referral_id);
create index if not exists bed_reservations_ward_idx on bed_reservations(ward_id);
create index if not exists bed_reservations_hospital_idx on bed_reservations(hospital_id);
create index if not exists bed_reservations_status_idx on bed_reservations(status);
create index if not exists bed_reservations_expires_idx on bed_reservations(expires_at) where status = 'active';

-- ============================================
-- 2) ADD RESERVED_BEDS COLUMN TO WARDS
-- ============================================

do $$
begin
  if not exists (
    select 1 from information_schema.columns
    where table_name = 'wards' and column_name = 'reserved_beds'
  ) then
    alter table wards add column reserved_beds integer not null default 0;
    
    -- Add constraint to ensure reserved_beds is valid
    alter table wards add constraint wards_reserved_beds_valid 
      check (reserved_beds >= 0 and reserved_beds <= available_beds);
  end if;
end $$;

-- ============================================
-- 3) ADD RESERVATION COLUMNS TO REFERRALS
-- ============================================

do $$
begin
  -- Add reservation_id column if not exists
  if not exists (
    select 1 from information_schema.columns
    where table_name = 'referrals' and column_name = 'reservation_id'
  ) then
    alter table referrals add column reservation_id uuid null references bed_reservations(id);
  end if;
  
  -- Add accepted_at timestamp
  if not exists (
    select 1 from information_schema.columns
    where table_name = 'referrals' and column_name = 'accepted_at'
  ) then
    alter table referrals add column accepted_at timestamptz null;
  end if;
  
  -- Add accepted_by_auth_user_id
  if not exists (
    select 1 from information_schema.columns
    where table_name = 'referrals' and column_name = 'accepted_by_auth_user_id'
  ) then
    alter table referrals add column accepted_by_auth_user_id uuid null;
  end if;
  
  -- Add target_ward_id for the reserved ward
  if not exists (
    select 1 from information_schema.columns
    where table_name = 'referrals' and column_name = 'target_ward_id'
  ) then
    alter table referrals add column target_ward_id uuid null references wards(id);
  end if;
  
  -- Add reservation_expires_at
  if not exists (
    select 1 from information_schema.columns
    where table_name = 'referrals' and column_name = 'reservation_expires_at'
  ) then
    alter table referrals add column reservation_expires_at timestamptz null;
  end if;
end $$;

-- ============================================
-- 4) RESERVE BED FUNCTION
-- ============================================
-- Called when accepting a referral - reserves a bed temporarily

create or replace function reserve_bed_for_referral(
  p_referral_id uuid,
  p_ward_id uuid,
  p_hospital_id uuid,
  p_actor_auth_user_id uuid,
  p_reservation_hours integer default 2  -- Default 2 hour reservation
) returns jsonb
language plpgsql
as $$
declare
  v_ward wards%rowtype;
  v_referral referrals%rowtype;
  v_reservation_id uuid;
  v_expires_at timestamptz;
  v_effective_available integer;
begin
  -- Lock and fetch the referral
  select * into v_referral
  from referrals
  where id = p_referral_id
  for update;
  
  if not found then
    raise exception 'REFERRAL_NOT_FOUND';
  end if;
  
  -- Check referral is pending
  if v_referral.status != 'pending' then
    raise exception 'REFERRAL_NOT_PENDING: Current status is %', v_referral.status;
  end if;
  
  -- Check hospital matches
  if v_referral.to_hospital_id != p_hospital_id then
    raise exception 'HOSPITAL_MISMATCH';
  end if;
  
  -- Lock and fetch the ward
  select * into v_ward
  from wards
  where id = p_ward_id
  for update;
  
  if not found then
    raise exception 'WARD_NOT_FOUND';
  end if;
  
  -- Check ward belongs to the receiving hospital
  if v_ward.hospital_id != p_hospital_id then
    raise exception 'WARD_HOSPITAL_MISMATCH';
  end if;
  
  -- Calculate effective available beds (available - already reserved)
  v_effective_available := v_ward.available_beds - coalesce(v_ward.reserved_beds, 0);
  
  if v_effective_available <= 0 then
    raise exception 'NO_BEDS_AVAILABLE: All beds are either occupied or reserved';
  end if;
  
  -- Calculate expiration
  v_expires_at := now() + (p_reservation_hours || ' hours')::interval;
  
  -- Create the reservation
  insert into bed_reservations (
    referral_id,
    hospital_id,
    ward_id,
    reserved_by_auth_user_id,
    expires_at,
    status
  ) values (
    p_referral_id,
    p_hospital_id,
    p_ward_id,
    p_actor_auth_user_id,
    v_expires_at,
    'active'
  ) returning id into v_reservation_id;
  
  -- Increment reserved_beds on the ward
  update wards
  set reserved_beds = coalesce(reserved_beds, 0) + 1
  where id = p_ward_id;
  
  -- Update the referral to accepted status with reservation info
  update referrals
  set 
    status = 'accepted',
    accepted_at = now(),
    accepted_by_auth_user_id = p_actor_auth_user_id,
    reservation_id = v_reservation_id,
    target_ward_id = p_ward_id,
    reservation_expires_at = v_expires_at
  where id = p_referral_id;
  
  return jsonb_build_object(
    'success', true,
    'reservation', jsonb_build_object(
      'id', v_reservation_id,
      'referral_id', p_referral_id,
      'ward_id', p_ward_id,
      'ward_name', v_ward.name,
      'reserved_at', now(),
      'expires_at', v_expires_at,
      'hours_until_expiry', p_reservation_hours
    ),
    'referral', jsonb_build_object(
      'id', p_referral_id,
      'status', 'accepted',
      'target_ward_id', p_ward_id
    ),
    'ward', jsonb_build_object(
      'id', v_ward.id,
      'name', v_ward.name,
      'available_beds', v_ward.available_beds,
      'reserved_beds', coalesce(v_ward.reserved_beds, 0) + 1,
      'effective_available', v_effective_available - 1
    )
  );
end;
$$;

-- ============================================
-- 5) COMPLETE RESERVATION FUNCTION
-- ============================================
-- Called when completing a referral - converts reservation to admission

create or replace function complete_bed_reservation(
  p_referral_id uuid,
  p_ward_id uuid,
  p_actor_hospital_id uuid,
  p_actor_auth_user_id uuid
) returns jsonb
language plpgsql
as $$
declare
  v_referral referrals%rowtype;
  v_reservation bed_reservations%rowtype;
  v_ward wards%rowtype;
begin
  -- Lock and fetch the referral
  select * into v_referral
  from referrals
  where id = p_referral_id
  for update;
  
  if not found then
    raise exception 'REFERRAL_NOT_FOUND';
  end if;
  
  -- Must be in accepted status
  if v_referral.status != 'accepted' then
    raise exception 'REFERRAL_NOT_ACCEPTED: Current status is %', v_referral.status;
  end if;
  
  -- Verify hospital
  if v_referral.to_hospital_id != p_actor_hospital_id then
    raise exception 'HOSPITAL_MISMATCH';
  end if;
  
  -- Fetch and lock the reservation if exists
  if v_referral.reservation_id is not null then
    select * into v_reservation
    from bed_reservations
    where id = v_referral.reservation_id
    for update;
    
    if found and v_reservation.status = 'active' then
      -- Mark reservation as completed
      update bed_reservations
      set 
        status = 'completed',
        completed_at = now()
      where id = v_reservation.id;
      
      -- Decrement reserved_beds on the ward (the bed is now actually occupied)
      update wards
      set reserved_beds = greatest(0, coalesce(reserved_beds, 0) - 1)
      where id = v_reservation.ward_id;
    end if;
  end if;
  
  return jsonb_build_object(
    'success', true,
    'reservation_completed', v_reservation.id is not null
  );
end;
$$;

-- ============================================
-- 6) CANCEL/EXPIRE RESERVATION FUNCTION
-- ============================================
-- Called when a reservation is cancelled or expires

create or replace function release_bed_reservation(
  p_reservation_id uuid,
  p_reason text default 'cancelled'  -- 'cancelled' or 'expired'
) returns jsonb
language plpgsql
as $$
declare
  v_reservation bed_reservations%rowtype;
begin
  -- Lock and fetch the reservation
  select * into v_reservation
  from bed_reservations
  where id = p_reservation_id
  for update;
  
  if not found then
    raise exception 'RESERVATION_NOT_FOUND';
  end if;
  
  -- Only active reservations can be released
  if v_reservation.status != 'active' then
    return jsonb_build_object(
      'success', false,
      'message', 'Reservation is not active',
      'current_status', v_reservation.status
    );
  end if;
  
  -- Update reservation status
  update bed_reservations
  set 
    status = p_reason,
    cancelled_at = case when p_reason = 'cancelled' then now() else null end
  where id = p_reservation_id;
  
  -- Release the reserved bed
  update wards
  set reserved_beds = greatest(0, coalesce(reserved_beds, 0) - 1)
  where id = v_reservation.ward_id;
  
  -- If referral is still accepted, revert to pending (for cancelled) or handle expiry
  if p_reason = 'cancelled' then
    update referrals
    set 
      status = 'pending',
      reservation_id = null,
      target_ward_id = null,
      reservation_expires_at = null,
      accepted_at = null,
      accepted_by_auth_user_id = null
    where id = v_reservation.referral_id
    and status = 'accepted';
  elsif p_reason = 'expired' then
    -- Mark referral reservation as expired but keep accepted status
    -- The receiving hospital needs to re-reserve or the referral lapses
    update referrals
    set 
      reservation_expires_at = null
    where id = v_reservation.referral_id;
  end if;
  
  return jsonb_build_object(
    'success', true,
    'reservation_id', p_reservation_id,
    'new_status', p_reason,
    'ward_id', v_reservation.ward_id
  );
end;
$$;

-- ============================================
-- 7) AUTO-EXPIRE RESERVATIONS FUNCTION
-- ============================================
-- This function can be called by a cron job or scheduled task

create or replace function expire_stale_reservations()
returns jsonb
language plpgsql
as $$
declare
  v_expired_count integer := 0;
  v_reservation record;
begin
  -- Find all active reservations that have expired
  for v_reservation in
    select id, referral_id, ward_id
    from bed_reservations
    where status = 'active'
    and expires_at < now()
    for update skip locked
  loop
    -- Release each expired reservation
    perform release_bed_reservation(v_reservation.id, 'expired');
    v_expired_count := v_expired_count + 1;
  end loop;
  
  return jsonb_build_object(
    'success', true,
    'expired_count', v_expired_count,
    'checked_at', now()
  );
end;
$$;

-- ============================================
-- 8) VIEW FOR EFFECTIVE BED AVAILABILITY
-- ============================================
-- Shows true availability accounting for reservations

create or replace view ward_availability as
select 
  w.id,
  w.hospital_id,
  w.name,
  w.type,
  w.ward_type,
  w.total_beds,
  w.available_beds,
  coalesce(w.reserved_beds, 0) as reserved_beds,
  w.available_beds - coalesce(w.reserved_beds, 0) as effective_available,
  w.occupied_beds,
  h.name as hospital_name,
  h.region,
  h.district
from wards w
join hospitals h on h.id = w.hospital_id;

-- ============================================
-- 9) RLS POLICIES FOR BED_RESERVATIONS
-- ============================================

alter table bed_reservations enable row level security;

-- Staff can view reservations for their hospital
create policy if not exists bed_reservations_select
  on bed_reservations for select
  using (exists (
    select 1 from users u 
    where u.auth_user_id = auth.uid() 
    and u.hospital_id = bed_reservations.hospital_id
  ));

-- Only doctors and admins can create/modify reservations
create policy if not exists bed_reservations_write
  on bed_reservations for all
  using (exists (
    select 1 from users u 
    where u.auth_user_id = auth.uid() 
    and u.hospital_id = bed_reservations.hospital_id
    and u.role in ('admin', 'doctor')
  ))
  with check (exists (
    select 1 from users u 
    where u.auth_user_id = auth.uid() 
    and u.hospital_id = bed_reservations.hospital_id
    and u.role in ('admin', 'doctor')
  ));

-- ============================================
-- 10) AUDIT TRIGGER FOR RESERVATIONS
-- ============================================

create or replace function audit_bed_reservation_changes()
returns trigger
language plpgsql
as $$
begin
  if TG_OP = 'INSERT' then
    insert into audit_logs (action, table_name, record_id, new_data)
    values ('reservation.create', 'bed_reservations', NEW.id, to_jsonb(NEW));
  elsif TG_OP = 'UPDATE' then
    insert into audit_logs (action, table_name, record_id, old_data, new_data)
    values (
      'reservation.' || NEW.status, 
      'bed_reservations', 
      NEW.id, 
      to_jsonb(OLD), 
      to_jsonb(NEW)
    );
  end if;
  return coalesce(NEW, OLD);
end;
$$;

drop trigger if exists bed_reservations_audit on bed_reservations;
create trigger bed_reservations_audit
after insert or update on bed_reservations
for each row execute function audit_bed_reservation_changes();

-- ============================================
-- MIGRATION COMPLETE
-- ============================================
-- Summary:
-- 1. Created bed_reservations table to track temporary bed holds
-- 2. Added reserved_beds column to wards table
-- 3. Added reservation tracking columns to referrals
-- 4. Created reserve_bed_for_referral() function
-- 5. Created complete_bed_reservation() function
-- 6. Created release_bed_reservation() function
-- 7. Created expire_stale_reservations() function for cron jobs
-- 8. Created ward_availability view for effective availability
-- 9. Added RLS policies for security
-- 10. Added audit trigger for reservation changes
