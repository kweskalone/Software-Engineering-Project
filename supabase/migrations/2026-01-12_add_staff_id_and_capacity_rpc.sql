-- =========================================
-- MIGRATION: Add staff_id column + update_ward_capacity RPC
-- Date: 2026-01-12
-- Target: Supabase (PostgreSQL)
-- =========================================
-- Run this ONLY if you already created the base tables from DATABASE_SCHEMA.sql.
-- This migration adds new columns and functions introduced after initial setup.

-- ============================
-- 1) ALTER: Add staff_id to users table
-- ============================

-- Add column (safe if already exists)
alter table users
  add column if not exists staff_id text;

-- Backfill existing rows with placeholder staff IDs
-- IMPORTANT: Adjust this to match your real staff ID assignment logic.
update users
set staff_id = concat('STAFF-', substring(auth_user_id::text, 1, 8))
where staff_id is null;

-- Make column NOT NULL after backfill
alter table users
  alter column staff_id set not null;

-- Create index on staff_id
create index if not exists users_staff_id_idx on users(staff_id);

-- Add unique constraint per hospital (using DO block for idempotency)
do $$
begin
  if not exists (
    select 1 from pg_constraint where conname = 'users_staff_id_unique_per_hospital'
  ) then
    alter table users
      add constraint users_staff_id_unique_per_hospital unique (hospital_id, staff_id);
  end if;
end $$;

-- ============================
-- 2) CREATE/REPLACE: update_ward_capacity RPC
-- ============================
-- Allows admin to safely change ward capacity without violating occupied bed count.

create or replace function update_ward_capacity(
  p_actor_hospital_id uuid,
  p_ward_id uuid,
  p_new_total_beds integer,
  p_actor_auth_user_id uuid
) returns jsonb
language plpgsql
as $$
declare
  v_ward wards%rowtype;
  v_occupied integer;
  v_new_available integer;
begin
  if p_new_total_beds < 0 then
    raise exception 'INVALID_TOTAL_BEDS';
  end if;

  select * into v_ward
  from wards
  where id = p_ward_id
  for update;

  if not found then
    raise exception 'WARD_NOT_FOUND';
  end if;

  if v_ward.hospital_id <> p_actor_hospital_id then
    raise exception 'WARD_HOSPITAL_MISMATCH';
  end if;

  -- occupied = total - available
  v_occupied := v_ward.total_beds - v_ward.available_beds;

  if p_new_total_beds < v_occupied then
    raise exception 'CAPACITY_BELOW_OCCUPIED';
  end if;

  -- compute new available as: new_total - occupied
  v_new_available := p_new_total_beds - v_occupied;

  update wards
  set total_beds = p_new_total_beds,
      available_beds = v_new_available
  where id = v_ward.id;

  return jsonb_build_object(
    'ward', jsonb_build_object(
      'id', v_ward.id,
      'hospital_id', v_ward.hospital_id,
      'name', v_ward.name,
      'type', v_ward.type,
      'total_beds', p_new_total_beds,
      'available_beds', v_new_available
    )
  );
end;
$$;
