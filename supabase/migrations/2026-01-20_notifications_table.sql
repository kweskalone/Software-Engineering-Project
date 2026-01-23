-- Notifications table for hospital bed management system
-- Stores user notifications for events like referrals, admissions, discharges

create table if not exists notifications (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references users(id) on delete cascade,
  type text not null check (type in (
    'referral_received',
    'referral_accepted', 
    'referral_rejected',
    'referral_completed',
    'admission_created',
    'discharge_created',
    'bed_available',
    'system'
  )),
  title text not null,
  message text not null,
  -- Reference to related entity (referral_id, admission_id, etc.)
  reference_id uuid null,
  reference_type text null check (reference_type in ('referral', 'admission', 'discharge', 'bed', null)),
  is_read boolean not null default false,
  created_at timestamptz not null default now()
);

-- Indexes for common queries
create index if not exists notifications_user_id_idx on notifications(user_id);
create index if not exists notifications_user_unread_idx on notifications(user_id) where is_read = false;
create index if not exists notifications_created_at_idx on notifications(created_at desc);

-- RLS policies
alter table notifications enable row level security;

-- Users can only see their own notifications
create policy "Users can view own notifications" 
  on notifications for select 
  using (
    user_id in (
      select id from users where auth_user_id = auth.uid()
    )
  );

-- Users can update (mark as read) their own notifications
create policy "Users can update own notifications" 
  on notifications for update 
  using (
    user_id in (
      select id from users where auth_user_id = auth.uid()
    )
  );

-- Only service role can insert notifications
create policy "Service role can insert notifications"
  on notifications for insert
  with check (true);

-- Comment for documentation
comment on table notifications is 'User notifications for hospital events';
comment on column notifications.type is 'Type of notification event';
comment on column notifications.reference_id is 'UUID of related entity (referral, admission, etc.)';
comment on column notifications.reference_type is 'Type of referenced entity';
