-- Migration: Audit logs + RLS templates + referral state-machine trigger
-- Date: 2026-01-16
-- Apply to an existing database (post initial schema)

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

-- =====================
-- RLS (Row Level Security) Templates
-- =====================
alter table hospitals enable row level security;
alter table wards enable row level security;
alter table patients enable row level security;
alter table admissions enable row level security;
alter table referrals enable row level security;
alter table users enable row level security;

create policy hospitals_select
  on hospitals for select
  using (auth.uid() is not null);

create policy hospitals_write_admin
  on hospitals for all
  using (exists (select 1 from users u where u.auth_user_id = auth.uid() and u.role = 'admin'))
  with check (exists (select 1 from users u where u.auth_user_id = auth.uid() and u.role = 'admin'));

create policy  wards_select
  on wards for select
  using (exists (
    select 1 from users u where u.auth_user_id = auth.uid() and u.hospital_id = wards.hospital_id
  ));

create policy wards_write_admin
  on wards for all
  using (exists (
    select 1 from users u where u.auth_user_id = auth.uid() and u.role = 'admin' and u.hospital_id = wards.hospital_id
  ))
  with check (exists (
    select 1 from users u where u.auth_user_id = auth.uid() and u.role = 'admin' and u.hospital_id = wards.hospital_id
  ));

create policy admissions_select
  on admissions for select
  using (exists (
    select 1 from users u where u.auth_user_id = auth.uid() and u.hospital_id = admissions.hospital_id
  ));

create policy  referrals_select
  on referrals for select
  using (exists (
    select 1 from users u where u.auth_user_id = auth.uid() and u.hospital_id = referrals.from_hospital_id
  ));

create policy  users_select
  on users for select
  using (exists (
    select 1 from users u where u.auth_user_id = auth.uid() and u.hospital_id = users.hospital_id
  ));

create policy users_write_admin
  on users for all
  using (exists (
    select 1 from users u where u.auth_user_id = auth.uid() and u.role = 'admin' and u.hospital_id = users.hospital_id
  ))
  with check (exists (
    select 1 from users u where u.auth_user_id = auth.uid() and u.role = 'admin' and u.hospital_id = users.hospital_id
  ));
