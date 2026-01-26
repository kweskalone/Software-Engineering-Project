-- =========================================
-- SEED DATA: Demo Auth Users for Supabase
-- Date: 2026-01-25
-- =========================================
-- This script creates auth users that correspond to the demo staff users.
-- Run this BEFORE the seed_demo_data.sql migration.
--
-- IMPORTANT: These users have a default password for demo purposes only.
-- Default password: Demo@26 (hashed below)
--
-- The password hash below is for: Demo@26
-- Generated using: SELECT crypt('Demo@26', gen_salt('bf'));

-- ============================================
-- CREATE AUTH USERS
-- ============================================

INSERT INTO auth.users (
  id,
  instance_id,
  email,
  encrypted_password,
  email_confirmed_at,
  created_at,
  updated_at,
  raw_app_meta_data,
  raw_user_meta_data,
  is_super_admin,
  role,
  aud,
  confirmation_token,
  recovery_token,
  email_change_token_new,
  email_change
) VALUES
  -- Korle Bu Teaching Hospital Staff
  (
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaa101',
    '00000000-0000-0000-0000-000000000000',
    'kwame.mensah@korlebu.gov.gh',
    crypt('Demo@26', gen_salt('bf')),
    now(),
    now(),
    now(),
    '{"provider": "email", "providers": ["email"]}',
    '{"first_name": "Kwame", "last_name": "Mensah", "role": "doctor"}',
    false,
    'authenticated',
    'authenticated',
    '',
    '',
    '',
    ''
  ),
  (
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaa102',
    '00000000-0000-0000-0000-000000000000',
    'abena.osei@korlebu.gov.gh',
    crypt('Demo@2026', gen_salt('bf')),
    now(),
    now(),
    now(),
    '{"provider": "email", "providers": ["email"]}',
    '{"first_name": "Abena", "last_name": "Osei", "role": "doctor"}',
    false,
    'authenticated',
    'authenticated',
    '',
    '',
    '',
    ''
  ),
  (
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaa103',
    '00000000-0000-0000-0000-000000000000',
    'akua.boateng@korlebu.gov.gh',
    crypt('Demo@2026', gen_salt('bf')),
    now(),
    now(),
    now(),
    '{"provider": "email", "providers": ["email"]}',
    '{"first_name": "Akua", "last_name": "Boateng", "role": "nurse"}',
    false,
    'authenticated',
    'authenticated',
    '',
    '',
    '',
    ''
  ),
  (
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaa104',
    '00000000-0000-0000-0000-000000000000',
    'yaw.asante@korlebu.gov.gh',
    crypt('Demo@2026', gen_salt('bf')),
    now(),
    now(),
    now(),
    '{"provider": "email", "providers": ["email"]}',
    '{"first_name": "Yaw", "last_name": "Asante", "role": "nurse"}',
    false,
    'authenticated',
    'authenticated',
    '',
    '',
    '',
    ''
  ),
  (
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaa105',
    '00000000-0000-0000-0000-000000000000',
    'ama.darko@korlebu.gov.gh',
    crypt('Demo@2026', gen_salt('bf')),
    now(),
    now(),
    now(),
    '{"provider": "email", "providers": ["email"]}',
    '{"first_name": "Ama", "last_name": "Darko", "role": "admin"}',
    false,
    'authenticated',
    'authenticated',
    '',
    '',
    '',
    ''
  ),

  -- Ridge Hospital Staff
  (
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaa106',
    '00000000-0000-0000-0000-000000000000',
    'kofi.adjei@ridge.gov.gh',
    crypt('Demo@2026', gen_salt('bf')),
    now(),
    now(),
    now(),
    '{"provider": "email", "providers": ["email"]}',
    '{"first_name": "Kofi", "last_name": "Adjei", "role": "doctor"}',
    false,
    'authenticated',
    'authenticated',
    '',
    '',
    '',
    ''
  ),
  (
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaa107',
    '00000000-0000-0000-0000-000000000000',
    'efua.mensah@ridge.gov.gh',
    crypt('Demo@2026', gen_salt('bf')),
    now(),
    now(),
    now(),
    '{"provider": "email", "providers": ["email"]}',
    '{"first_name": "Efua", "last_name": "Mensah", "role": "nurse"}',
    false,
    'authenticated',
    'authenticated',
    '',
    '',
    '',
    ''
  ),
  (
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaa108',
    '00000000-0000-0000-0000-000000000000',
    'kojo.antwi@ridge.gov.gh',
    crypt('Demo@2026', gen_salt('bf')),
    now(),
    now(),
    now(),
    '{"provider": "email", "providers": ["email"]}',
    '{"first_name": "Kojo", "last_name": "Antwi", "role": "admin"}',
    false,
    'authenticated',
    'authenticated',
    '',
    '',
    '',
    ''
  ),

  -- 37 Military Hospital Staff
  (
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaa109',
    '00000000-0000-0000-0000-000000000000',
    'emmanuel.owusu@37military.gov.gh',
    crypt('Demo@2026', gen_salt('bf')),
    now(),
    now(),
    now(),
    '{"provider": "email", "providers": ["email"]}',
    '{"first_name": "Emmanuel", "last_name": "Owusu", "role": "doctor"}',
    false,
    'authenticated',
    'authenticated',
    '',
    '',
    '',
    ''
  ),
  (
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaa110',
    '00000000-0000-0000-0000-000000000000',
    'grace.appiah@37military.gov.gh',
    crypt('Demo@2026', gen_salt('bf')),
    now(),
    now(),
    now(),
    '{"provider": "email", "providers": ["email"]}',
    '{"first_name": "Grace", "last_name": "Appiah", "role": "nurse"}',
    false,
    'authenticated',
    'authenticated',
    '',
    '',
    '',
    ''
  ),

  -- Komfo Anokye Teaching Hospital Staff
  (
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaa111',
    '00000000-0000-0000-0000-000000000000',
    'benjamin.agyei@kath.gov.gh',
    crypt('Demo@2026', gen_salt('bf')),
    now(),
    now(),
    now(),
    '{"provider": "email", "providers": ["email"]}',
    '{"first_name": "Benjamin", "last_name": "Agyei", "role": "doctor"}',
    false,
    'authenticated',
    'authenticated',
    '',
    '',
    '',
    ''
  ),
  (
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaa112',
    '00000000-0000-0000-0000-000000000000',
    'felicia.boakye@kath.gov.gh',
    crypt('Demo@2026', gen_salt('bf')),
    now(),
    now(),
    now(),
    '{"provider": "email", "providers": ["email"]}',
    '{"first_name": "Felicia", "last_name": "Boakye", "role": "doctor"}',
    false,
    'authenticated',
    'authenticated',
    '',
    '',
    '',
    ''
  ),
  (
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaa113',
    '00000000-0000-0000-0000-000000000000',
    'priscilla.amoah@kath.gov.gh',
    crypt('Demo@2026', gen_salt('bf')),
    now(),
    now(),
    now(),
    '{"provider": "email", "providers": ["email"]}',
    '{"first_name": "Priscilla", "last_name": "Amoah", "role": "nurse"}',
    false,
    'authenticated',
    'authenticated',
    '',
    '',
    '',
    ''
  ),
  (
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaa114',
    '00000000-0000-0000-0000-000000000000',
    'michael.ofori@kath.gov.gh',
    crypt('Demo@2026', gen_salt('bf')),
    now(),
    now(),
    now(),
    '{"provider": "email", "providers": ["email"]}',
    '{"first_name": "Michael", "last_name": "Ofori", "role": "admin"}',
    false,
    'authenticated',
    'authenticated',
    '',
    '',
    '',
    ''
  ),

  -- Tamale Teaching Hospital Staff
  (
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaa115',
    '00000000-0000-0000-0000-000000000000',
    'ibrahim.mohammed@tamale.gov.gh',
    crypt('Demo@2026', gen_salt('bf')),
    now(),
    now(),
    now(),
    '{"provider": "email", "providers": ["email"]}',
    '{"first_name": "Ibrahim", "last_name": "Mohammed", "role": "doctor"}',
    false,
    'authenticated',
    'authenticated',
    '',
    '',
    '',
    ''
  ),
  (
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaa116',
    '00000000-0000-0000-0000-000000000000',
    'fatima.iddrisu@tamale.gov.gh',
    crypt('Demo@2026', gen_salt('bf')),
    now(),
    now(),
    now(),
    '{"provider": "email", "providers": ["email"]}',
    '{"first_name": "Fatima", "last_name": "Iddrisu", "role": "nurse"}',
    false,
    'authenticated',
    'authenticated',
    '',
    '',
    '',
    ''
  ),
  (
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaa117',
    '00000000-0000-0000-0000-000000000000',
    'alhassan.salifu@tamale.gov.gh',
    crypt('Demo@2026', gen_salt('bf')),
    now(),
    now(),
    now(),
    '{"provider": "email", "providers": ["email"]}',
    '{"first_name": "Alhassan", "last_name": "Salifu", "role": "admin"}',
    false,
    'authenticated',
    'authenticated',
    '',
    '',
    '',
    ''
  ),

  -- Cape Coast Teaching Hospital Staff
  (
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaa118',
    '00000000-0000-0000-0000-000000000000',
    'samuel.acquah@ccth.gov.gh',
    crypt('Demo@2026', gen_salt('bf')),
    now(),
    now(),
    now(),
    '{"provider": "email", "providers": ["email"]}',
    '{"first_name": "Samuel", "last_name": "Acquah", "role": "doctor"}',
    false,
    'authenticated',
    'authenticated',
    '',
    '',
    '',
    ''
  ),
  (
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaa119',
    '00000000-0000-0000-0000-000000000000',
    'elizabeth.eshun@ccth.gov.gh',
    crypt('Demo@2026', gen_salt('bf')),
    now(),
    now(),
    now(),
    '{"provider": "email", "providers": ["email"]}',
    '{"first_name": "Elizabeth", "last_name": "Eshun", "role": "nurse"}',
    false,
    'authenticated',
    'authenticated',
    '',
    '',
    '',
    ''
  ),

  -- Tema General Hospital Staff
  (
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaa120',
    '00000000-0000-0000-0000-000000000000',
    'daniel.tetteh@tema.gov.gh',
    crypt('Demo@2026', gen_salt('bf')),
    now(),
    now(),
    now(),
    '{"provider": "email", "providers": ["email"]}',
    '{"first_name": "Daniel", "last_name": "Tetteh", "role": "doctor"}',
    false,
    'authenticated',
    'authenticated',
    '',
    '',
    '',
    ''
  ),
  (
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaa121',
    '00000000-0000-0000-0000-000000000000',
    'sophia.nartey@tema.gov.gh',
    crypt('Demo@2026', gen_salt('bf')),
    now(),
    now(),
    now(),
    '{"provider": "email", "providers": ["email"]}',
    '{"first_name": "Sophia", "last_name": "Nartey", "role": "nurse"}',
    false,
    'authenticated',
    'authenticated',
    '',
    '',
    '',
    ''
  ),

  -- Ho Teaching Hospital Staff
  (
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaa122',
    '00000000-0000-0000-0000-000000000000',
    'charles.agbeko@ho.gov.gh',
    crypt('Demo@2026', gen_salt('bf')),
    now(),
    now(),
    now(),
    '{"provider": "email", "providers": ["email"]}',
    '{"first_name": "Charles", "last_name": "Agbeko", "role": "doctor"}',
    false,
    'authenticated',
    'authenticated',
    '',
    '',
    '',
    ''
  ),
  (
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaa123',
    '00000000-0000-0000-0000-000000000000',
    'mary.dzivenu@ho.gov.gh',
    crypt('Demo@2026', gen_salt('bf')),
    now(),
    now(),
    now(),
    '{"provider": "email", "providers": ["email"]}',
    '{"first_name": "Mary", "last_name": "Dzivenu", "role": "nurse"}',
    false,
    'authenticated',
    'authenticated',
    '',
    '',
    '',
    ''
  ),

  -- Effia Nkwanta Regional Hospital Staff
  (
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaa124',
    '00000000-0000-0000-0000-000000000000',
    'patrick.egyir@effia.gov.gh',
    crypt('Demo@2026', gen_salt('bf')),
    now(),
    now(),
    now(),
    '{"provider": "email", "providers": ["email"]}',
    '{"first_name": "Patrick", "last_name": "Egyir", "role": "doctor"}',
    false,
    'authenticated',
    'authenticated',
    '',
    '',
    '',
    ''
  ),
  (
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaa125',
    '00000000-0000-0000-0000-000000000000',
    'janet.quayson@effia.gov.gh',
    crypt('Demo@2026', gen_salt('bf')),
    now(),
    now(),
    now(),
    '{"provider": "email", "providers": ["email"]}',
    '{"first_name": "Janet", "last_name": "Quayson", "role": "nurse"}',
    false,
    'authenticated',
    'authenticated',
    '',
    '',
    '',
    ''
  )
ON CONFLICT (id) DO UPDATE SET
  email = EXCLUDED.email,
  raw_user_meta_data = EXCLUDED.raw_user_meta_data,
  updated_at = now();

-- Also add entries to auth.identities (required for email auth)
INSERT INTO auth.identities (
  id,
  user_id,
  identity_data,
  provider,
  provider_id,
  created_at,
  updated_at,
  last_sign_in_at
)
SELECT 
  id,
  id,
  jsonb_build_object('sub', id::text, 'email', email),
  'email',
  id::text,
  now(),
  now(),
  now()
FROM auth.users
WHERE id IN (
  'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaa101',
  'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaa102',
  'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaa103',
  'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaa104',
  'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaa105',
  'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaa106',
  'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaa107',
  'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaa108',
  'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaa109',
  'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaa110',
  'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaa111',
  'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaa112',
  'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaa113',
  'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaa114',
  'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaa115',
  'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaa116',
  'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaa117',
  'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaa118',
  'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaa119',
  'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaa120',
  'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaa121',
  'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaa122',
  'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaa123',
  'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaa124',
  'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaa125'
)
ON CONFLICT (provider, provider_id) DO NOTHING;

-- ============================================
-- DEMO LOGIN CREDENTIALS
-- ============================================
-- All users have the same password for demo purposes:
-- Password: Demo@2026
--
-- Sample logins to test:
-- | Email                           | Role   | Hospital              |
-- |---------------------------------|--------|-----------------------|
-- | kwame.mensah@korlebu.gov.gh     | doctor | Korle Bu Teaching     |
-- | ama.darko@korlebu.gov.gh        | admin  | Korle Bu Teaching     |
-- | benjamin.agyei@kath.gov.gh      | doctor | KATH                  |
-- | ibrahim.mohammed@tamale.gov.gh  | doctor | Tamale Teaching       |
-- | kofi.adjei@ridge.gov.gh         | doctor | Ridge Hospital        |
