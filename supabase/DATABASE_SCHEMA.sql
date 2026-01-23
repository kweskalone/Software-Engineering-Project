-- Hospital Bed Management & Referral System
-- Target: Supabase (PostgreSQL)

-- Enable UUID generation
create extension if not exists "pgcrypto";

-- ============
-- Core Tables
-- ============

create table if not exists hospitals (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  region text null,
  district text null,
  created_at timestamptz not null default now()
);

create table if not exists wards (
  id uuid primary key default gen_random_uuid(),
  hospital_id uuid not null references hospitals(id) on delete cascade,
  name text not null,
  type text not null,
  total_beds integer not null check (total_beds >= 0),
  available_beds integer not null check (available_beds >= 0),
  created_at timestamptz not null default now(),
  constraint wards_available_le_total check (available_beds <= total_beds),
  constraint wards_unique_name_per_hospital unique (hospital_id, name)
);

create index if not exists wards_hospital_id_idx on wards(hospital_id);

create table if not exists patients (
  id uuid primary key default gen_random_uuid(),
  full_name text not null,
  sex text not null check (sex in ('M','F','Other')),
  date_of_birth date null,
  phone text null,
  national_id text null,
  created_at timestamptz not null default now(),
  constraint patients_national_id_unique unique (national_id)
);

create table if not exists admissions (
  id uuid primary key default gen_random_uuid(),
  patient_id uuid not null references patients(id) on delete restrict,
  hospital_id uuid not null references hospitals(id) on delete restrict,
  ward_id uuid not null references wards(id) on delete restrict,
  status text not null check (status in ('admitted','discharged')),
  admitted_at timestamptz not null default now(),
  discharged_at timestamptz null,
  admitted_by_auth_user_id uuid null,
  discharged_by_auth_user_id uuid null,
  created_at timestamptz not null default now()
);

create index if not exists admissions_patient_idx on admissions(patient_id);
create index if not exists admissions_hospital_idx on admissions(hospital_id);
create index if not exists admissions_ward_idx on admissions(ward_id);

create table if not exists referrals (
  id uuid primary key default gen_random_uuid(),
  patient_id uuid not null references patients(id) on delete restrict,
  from_hospital_id uuid not null references hospitals(id) on delete restrict,
  from_ward_id uuid not null references wards(id) on delete restrict,
  to_hospital_id uuid not null references hospitals(id) on delete restrict,
  reason text null,
  status text not null check (status in ('pending','accepted','rejected','completed','cancelled')),
  created_by_auth_user_id uuid null,
  created_at timestamptz not null default now()
);

create index if not exists referrals_patient_idx on referrals(patient_id);
create index if not exists referrals_from_hospital_idx on referrals(from_hospital_id);
create index if not exists referrals_to_hospital_idx on referrals(to_hospital_id);

-- App-level staff profile table.
-- Links Supabase Auth user (auth.users.id) to a hospital and role.
create table if not exists users (
  id uuid primary key default gen_random_uuid(),
  auth_user_id uuid not null unique,
  -- Human-friendly staff identifier (often printed on staff ID cards).
  -- Unique per hospital.
  staff_id text not null,
  role text not null check (role in ('admin','doctor','nurse')),
  hospital_id uuid not null references hospitals(id) on delete restrict,
  first_name text,
  last_name text,
  created_at timestamptz not null default now()
);

create index if not exists users_hospital_idx on users(hospital_id);
create index if not exists users_staff_id_idx on users(staff_id);

alter table users
  add constraint users_staff_id_unique_per_hospital unique (hospital_id, staff_id);

-- ============
-- Audit Logs
-- ============

create table if not exists audit_logs (
  id uuid primary key default gen_random_uuid(),
  action text not null,
  table_name text not null,
  record_id uuid null,
  actor_auth_user_id uuid null,
  old_data jsonb null,
  new_data jsonb null,
  created_at timestamptz not null default now()
);

create index if not exists audit_logs_table_idx on audit_logs(table_name);
create index if not exists audit_logs_actor_idx on audit_logs(actor_auth_user_id);

-- =====================
-- Referral State Machine
-- =====================

-- Allowed transitions:
-- pending -> accepted | rejected | cancelled
-- accepted -> completed | cancelled
-- rejected -> cancelled
create or replace function enforce_referral_transition()
returns trigger
language plpgsql
as $$
begin
  if old.status = new.status then
    return new;
  end if;

  if old.status = 'pending' and new.status in ('accepted','rejected','cancelled') then
    return new;
  end if;

  if old.status = 'accepted' and new.status in ('completed','cancelled') then
    return new;
  end if;

  if old.status = 'rejected' and new.status in ('cancelled') then
    return new;
  end if;

  raise exception 'INVALID_REFERRAL_TRANSITION';
end;
$$;

drop trigger if exists referrals_state_machine on referrals;
create trigger referrals_state_machine
before update on referrals
for each row
execute function enforce_referral_transition();

-- ==========================
-- Atomic Bed Update Functions
-- ==========================

-- create_admission: enforces "no bed, no admission" and decrements availability.
create or replace function create_admission(
  p_actor_hospital_id uuid,
  p_ward_id uuid,
  p_patient_full_name text,
  p_patient_sex text,
  p_patient_date_of_birth date,
  p_patient_phone text,
  p_patient_national_id text,
  p_actor_auth_user_id uuid
) returns jsonb
language plpgsql
as $$
declare
  v_ward wards%rowtype;
  v_patient_id uuid;
  v_admission_id uuid;
  v_new_available integer;
begin
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

  if v_ward.available_beds <= 0 then
    raise exception 'NO_BEDS_AVAILABLE';
  end if;

  insert into patients (full_name, sex, date_of_birth, phone, national_id)
  values (p_patient_full_name, p_patient_sex, p_patient_date_of_birth, p_patient_phone, p_patient_national_id)
  on conflict (national_id)
  do update set
    full_name = excluded.full_name,
    sex = excluded.sex,
    date_of_birth = excluded.date_of_birth,
    phone = excluded.phone
  returning id into v_patient_id;

  update wards
  set available_beds = available_beds - 1
  where id = p_ward_id
  returning available_beds into v_new_available;

  insert into admissions (patient_id, hospital_id, ward_id, status, admitted_by_auth_user_id)
  values (v_patient_id, v_ward.hospital_id, v_ward.id, 'admitted', p_actor_auth_user_id)
  returning id into v_admission_id;

  return jsonb_build_object(
    'admission', jsonb_build_object(
      'id', v_admission_id,
      'patient_id', v_patient_id,
      'ward_id', v_ward.id,
      'hospital_id', v_ward.hospital_id,
      'status', 'admitted',
      'admitted_at', now()
    ),
    'ward', jsonb_build_object(
      'id', v_ward.id,
      'available_beds', v_new_available,
      'total_beds', v_ward.total_beds
    )
  );
end;
$$;

-- discharge_patient: marks discharge and increments availability.
create or replace function discharge_patient(
  p_actor_hospital_id uuid,
  p_admission_id uuid,
  p_actor_auth_user_id uuid
) returns jsonb
language plpgsql
as $$
declare
  v_adm admissions%rowtype;
  v_ward wards%rowtype;
  v_new_available integer;
begin
  select * into v_adm
  from admissions
  where id = p_admission_id
  for update;

  if not found then
    raise exception 'ADMISSION_NOT_FOUND';
  end if;

  if v_adm.hospital_id <> p_actor_hospital_id then
    raise exception 'ADMISSION_HOSPITAL_MISMATCH';
  end if;

  if v_adm.status = 'discharged' then
    raise exception 'ALREADY_DISCHARGED';
  end if;

  update admissions
  set status = 'discharged',
      discharged_at = now(),
      discharged_by_auth_user_id = p_actor_auth_user_id
  where id = p_admission_id;

  select * into v_ward
  from wards
  where id = v_adm.ward_id
  for update;

  update wards
  set available_beds = least(total_beds, available_beds + 1)
  where id = v_adm.ward_id
  returning available_beds into v_new_available;

  return jsonb_build_object(
    'admission', jsonb_build_object(
      'id', v_adm.id,
      'status', 'discharged',
      'discharged_at', now()
    ),
    'ward', jsonb_build_object(
      'id', v_ward.id,
      'available_beds', v_new_available,
      'total_beds', v_ward.total_beds
    )
  );
end;
$$;

-- update_ward_capacity: admin changes total_beds without violating occupied beds.
-- occupied_beds = total_beds - available_beds
-- new_total_beds must be >= occupied_beds
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

  v_occupied := v_ward.total_beds - v_ward.available_beds;
  if p_new_total_beds < v_occupied then
    raise exception 'CAPACITY_BELOW_OCCUPIED';
  end if;

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

-- =====================
-- ER Diagram (Textual)
-- =====================
-- hospitals 1---* wards
-- hospitals 1---* users
-- wards 1---* admissions
-- patients 1---* admissions
-- patients 1---* referrals
-- hospitals 1---* referrals (from_hospital_id)
-- hospitals 1---* referrals (to_hospital_id)
-- wards 1---* referrals (from_ward_id)

-- =====================
-- Notes (Security/RLS)
-- =====================
-- In a production Supabase setup:
-- 1) Enable RLS on tables.
-- 2) Create policies to restrict reads/writes by role + hospital.
-- For an undergraduate build, many teams use a server-side service role key
-- and enforce RBAC in the Express API (still validating JWT).

-- =====================
-- Row Level Security (RLS) Templates
-- =====================
-- These policies demonstrate a safe, hospital-scoped model.
-- NOTE: service role bypasses RLS, so enforce RBAC in the API as well.

alter table hospitals enable row level security;
alter table wards enable row level security;
alter table patients enable row level security;
alter table admissions enable row level security;
alter table referrals enable row level security;
alter table users enable row level security;

-- Hospitals: any authenticated can view; only admins can insert/update
create policy if not exists hospitals_select
  on hospitals for select
  using (auth.uid() is not null);

create policy if not exists hospitals_write_admin
  on hospitals for all
  using (exists (select 1 from users u where u.auth_user_id = auth.uid() and u.role = 'admin'))
  with check (exists (select 1 from users u where u.auth_user_id = auth.uid() and u.role = 'admin'));

-- Wards: staff can view wards in their hospital; admin can write
create policy if not exists wards_select
  on wards for select
  using (exists (
    select 1 from users u where u.auth_user_id = auth.uid() and u.hospital_id = wards.hospital_id
  ));

create policy if not exists wards_write_admin
  on wards for all
  using (exists (
    select 1 from users u where u.auth_user_id = auth.uid() and u.role = 'admin' and u.hospital_id = wards.hospital_id
  ))
  with check (exists (
    select 1 from users u where u.auth_user_id = auth.uid() and u.role = 'admin' and u.hospital_id = wards.hospital_id
  ));

-- Admissions: staff can view admissions for their hospital
create policy if not exists admissions_select
  on admissions for select
  using (exists (
    select 1 from users u where u.auth_user_id = auth.uid() and u.hospital_id = admissions.hospital_id
  ));

-- Referrals: staff can view referrals where they are the sender hospital
create policy if not exists referrals_select
  on referrals for select
  using (exists (
    select 1 from users u where u.auth_user_id = auth.uid() and u.hospital_id = referrals.from_hospital_id
  ));

-- Users: staff can view users in their hospital (admin can write)
create policy if not exists users_select
  on users for select
  using (exists (
    select 1 from users u where u.auth_user_id = auth.uid() and u.hospital_id = users.hospital_id
  ));

create policy if not exists users_write_admin
  on users for all
  using (exists (
    select 1 from users u where u.auth_user_id = auth.uid() and u.role = 'admin' and u.hospital_id = users.hospital_id
  ))
  with check (exists (
    select 1 from users u where u.auth_user_id = auth.uid() and u.role = 'admin' and u.hospital_id = users.hospital_id
  ));
