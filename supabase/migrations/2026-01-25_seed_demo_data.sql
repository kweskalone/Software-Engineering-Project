-- =========================================
-- SEED DATA: Demo Data for Demonstration
-- Date: 2026-01-25
-- =========================================
-- This script populates the database with realistic demo data
-- for patients, users, admissions, referrals, and bed reservations.
-- Run AFTER the hospitals and wards seed migration.

-- ============================================
-- 1) DEMO USERS (Staff Members)
-- ============================================
-- Note: auth_user_id should reference Supabase Auth users.
-- These are placeholder UUIDs for demo purposes.
-- In production, users are created through the auth signup flow.

insert into users (id, auth_user_id, staff_id, role, hospital_id, first_name, last_name) values
  -- Korle Bu Teaching Hospital Staff
  ('22222222-2222-2222-2222-222222222201', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaa101', 'KB-DOC-001', 'doctor', '11111111-1111-1111-1111-111111111101', 'Kwame', 'Mensah'),
  ('22222222-2222-2222-2222-222222222202', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaa102', 'KB-DOC-002', 'doctor', '11111111-1111-1111-1111-111111111101', 'Abena', 'Osei'),
  ('22222222-2222-2222-2222-222222222203', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaa103', 'KB-NUR-001', 'nurse', '11111111-1111-1111-1111-111111111101', 'Akua', 'Boateng'),
  ('22222222-2222-2222-2222-222222222204', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaa104', 'KB-NUR-002', 'nurse', '11111111-1111-1111-1111-111111111101', 'Yaw', 'Asante'),
  ('22222222-2222-2222-2222-222222222205', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaa105', 'KB-ADM-001', 'admin', '11111111-1111-1111-1111-111111111101', 'Ama', 'Darko'),

  -- Ridge Hospital Staff
  ('22222222-2222-2222-2222-222222222206', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaa106', 'RH-DOC-001', 'doctor', '11111111-1111-1111-1111-111111111102', 'Kofi', 'Adjei'),
  ('22222222-2222-2222-2222-222222222207', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaa107', 'RH-NUR-001', 'nurse', '11111111-1111-1111-1111-111111111102', 'Efua', 'Mensah'),
  ('22222222-2222-2222-2222-222222222208', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaa108', 'RH-ADM-001', 'admin', '11111111-1111-1111-1111-111111111102', 'Kojo', 'Antwi'),

  -- 37 Military Hospital Staff
  ('22222222-2222-2222-2222-222222222209', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaa109', 'MH-DOC-001', 'doctor', '11111111-1111-1111-1111-111111111103', 'Emmanuel', 'Owusu'),
  ('22222222-2222-2222-2222-222222222210', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaa110', 'MH-NUR-001', 'nurse', '11111111-1111-1111-1111-111111111103', 'Grace', 'Appiah'),

  -- Komfo Anokye Teaching Hospital Staff
  ('22222222-2222-2222-2222-222222222211', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaa111', 'KATH-DOC-001', 'doctor', '11111111-1111-1111-1111-111111111201', 'Benjamin', 'Agyei'),
  ('22222222-2222-2222-2222-222222222212', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaa112', 'KATH-DOC-002', 'doctor', '11111111-1111-1111-1111-111111111201', 'Felicia', 'Boakye'),
  ('22222222-2222-2222-2222-222222222213', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaa113', 'KATH-NUR-001', 'nurse', '11111111-1111-1111-1111-111111111201', 'Priscilla', 'Amoah'),
  ('22222222-2222-2222-2222-222222222214', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaa114', 'KATH-ADM-001', 'admin', '11111111-1111-1111-1111-111111111201', 'Michael', 'Ofori'),

  -- Tamale Teaching Hospital Staff
  ('22222222-2222-2222-2222-222222222215', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaa115', 'TTH-DOC-001', 'doctor', '11111111-1111-1111-1111-111111111701', 'Ibrahim', 'Mohammed'),
  ('22222222-2222-2222-2222-222222222216', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaa116', 'TTH-NUR-001', 'nurse', '11111111-1111-1111-1111-111111111701', 'Fatima', 'Iddrisu'),
  ('22222222-2222-2222-2222-222222222217', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaa117', 'TTH-ADM-001', 'admin', '11111111-1111-1111-1111-111111111701', 'Alhassan', 'Salifu'),

  -- Cape Coast Teaching Hospital Staff
  ('22222222-2222-2222-2222-222222222218', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaa118', 'CCTH-DOC-001', 'doctor', '11111111-1111-1111-1111-111111111401', 'Samuel', 'Acquah'),
  ('22222222-2222-2222-2222-222222222219', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaa119', 'CCTH-NUR-001', 'nurse', '11111111-1111-1111-1111-111111111401', 'Elizabeth', 'Eshun'),

  -- Tema General Hospital Staff
  ('22222222-2222-2222-2222-222222222220', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaa120', 'TGH-DOC-001', 'doctor', '11111111-1111-1111-1111-111111111106', 'Daniel', 'Tetteh'),
  ('22222222-2222-2222-2222-222222222221', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaa121', 'TGH-NUR-001', 'nurse', '11111111-1111-1111-1111-111111111106', 'Sophia', 'Nartey'),

  -- Ho Teaching Hospital Staff
  ('22222222-2222-2222-2222-222222222222', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaa122', 'HTH-DOC-001', 'doctor', '11111111-1111-1111-1111-111111111601', 'Charles', 'Agbeko'),
  ('22222222-2222-2222-2222-222222222223', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaa123', 'HTH-NUR-001', 'nurse', '11111111-1111-1111-1111-111111111601', 'Mary', 'Dzivenu'),

  -- Effia Nkwanta Regional Hospital Staff
  ('22222222-2222-2222-2222-222222222224', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaa124', 'ENRH-DOC-001', 'doctor', '11111111-1111-1111-1111-111111111301', 'Patrick', 'Egyir'),
  ('22222222-2222-2222-2222-222222222225', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaa125', 'ENRH-NUR-001', 'nurse', '11111111-1111-1111-1111-111111111301', 'Janet', 'Quayson')

on conflict (id) do update set
  staff_id = excluded.staff_id,
  role = excluded.role,
  first_name = excluded.first_name,
  last_name = excluded.last_name;

-- ============================================
-- 2) DEMO PATIENTS
-- ============================================

insert into patients (id, full_name, sex, date_of_birth, phone, national_id) values
  -- Male Patients
  ('33333333-3333-3333-3333-333333333301', 'Kweku Asante', 'M', '1985-03-15', '0244123456', 'GHA-1985-0315-M001'),
  ('33333333-3333-3333-3333-333333333302', 'Yaw Boateng', 'M', '1972-07-22', '0208765432', 'GHA-1972-0722-M002'),
  ('33333333-3333-3333-3333-333333333303', 'Kofi Mensah', 'M', '1990-11-08', '0551234567', 'GHA-1990-1108-M003'),
  ('33333333-3333-3333-3333-333333333304', 'Emmanuel Osei', 'M', '1965-01-30', '0277654321', 'GHA-1965-0130-M004'),
  ('33333333-3333-3333-3333-333333333305', 'Isaac Darko', 'M', '1998-05-17', '0501112233', 'GHA-1998-0517-M005'),
  ('33333333-3333-3333-3333-333333333306', 'Michael Adjei', 'M', '1978-09-04', '0244556677', 'GHA-1978-0904-M006'),
  ('33333333-3333-3333-3333-333333333307', 'Daniel Appiah', 'M', '1955-12-25', '0208899001', 'GHA-1955-1225-M007'),
  ('33333333-3333-3333-3333-333333333308', 'Samuel Owusu', 'M', '2001-02-14', '0551122334', 'GHA-2001-0214-M008'),
  ('33333333-3333-3333-3333-333333333309', 'Ibrahim Mohammed', 'M', '1988-06-20', '0277788990', 'GHA-1988-0620-M009'),
  ('33333333-3333-3333-3333-333333333310', 'Alhassan Salifu', 'M', '1975-04-12', '0503344556', 'GHA-1975-0412-M010'),

  -- Female Patients
  ('33333333-3333-3333-3333-333333333311', 'Akua Boateng', 'F', '1992-08-19', '0244998877', 'GHA-1992-0819-F001'),
  ('33333333-3333-3333-3333-333333333312', 'Abena Mensah', 'F', '1980-03-27', '0208776655', 'GHA-1980-0327-F002'),
  ('33333333-3333-3333-3333-333333333313', 'Ama Darko', 'F', '1995-10-05', '0556655443', 'GHA-1995-1005-F003'),
  ('33333333-3333-3333-3333-333333333314', 'Efua Antwi', 'F', '1968-07-14', '0274433221', 'GHA-1968-0714-F004'),
  ('33333333-3333-3333-3333-333333333315', 'Grace Appiah', 'F', '2000-01-01', '0502211009', 'GHA-2000-0101-F005'),
  ('33333333-3333-3333-3333-333333333316', 'Fatima Iddrisu', 'F', '1983-11-30', '0248899776', 'GHA-1983-1130-F006'),
  ('33333333-3333-3333-3333-333333333317', 'Elizabeth Eshun', 'F', '1970-05-08', '0207766554', 'GHA-1970-0508-F007'),
  ('33333333-3333-3333-3333-333333333318', 'Priscilla Amoah', 'F', '1997-12-15', '0554433221', 'GHA-1997-1215-F008'),
  ('33333333-3333-3333-3333-333333333319', 'Sophia Nartey', 'F', '1960-09-22', '0272211889', 'GHA-1960-0922-F009'),
  ('33333333-3333-3333-3333-333333333320', 'Mary Dzivenu', 'F', '2003-06-18', '0508877665', 'GHA-2003-0618-F010'),

  -- Additional Patients (Mixed)
  ('33333333-3333-3333-3333-333333333321', 'Kwame Asiedu', 'M', '1982-04-23', '0244332211', 'GHA-1982-0423-M011'),
  ('33333333-3333-3333-3333-333333333322', 'Adwoa Frimpong', 'F', '1993-02-28', '0209988776', 'GHA-1993-0228-F011'),
  ('33333333-3333-3333-3333-333333333323', 'Yaw Opoku', 'M', '1958-08-11', '0557766554', 'GHA-1958-0811-M012'),
  ('33333333-3333-3333-3333-333333333324', 'Akosua Asamoah', 'F', '1986-10-07', '0275544332', 'GHA-1986-1007-F012'),
  ('33333333-3333-3333-3333-333333333325', 'Kojo Agyemang', 'M', '1999-07-03', '0503322110', 'GHA-1999-0703-M013'),
  ('33333333-3333-3333-3333-333333333326', 'Afua Nyarko', 'F', '1974-01-16', '0246655443', 'GHA-1974-0116-F013'),
  ('33333333-3333-3333-3333-333333333327', 'Nana Yaw Acheampong', 'M', '1991-12-09', '0201144332', 'GHA-1991-1209-M014'),
  ('33333333-3333-3333-3333-333333333328', 'Afia Konadu', 'F', '1967-03-25', '0559933221', 'GHA-1967-0325-F014'),
  ('33333333-3333-3333-3333-333333333329', 'Kwesi Appiah', 'M', '2005-09-12', '0278822110', 'GHA-2005-0912-M015'),
  ('33333333-3333-3333-3333-333333333330', 'Yaa Asantewaa', 'F', '1989-06-01', '0507711998', 'GHA-1989-0601-F015')

on conflict (id) do update set
  full_name = excluded.full_name,
  sex = excluded.sex,
  date_of_birth = excluded.date_of_birth,
  phone = excluded.phone,
  national_id = excluded.national_id;

-- ============================================
-- 3) DEMO ADMISSIONS
-- ============================================
-- Assume we need to get ward IDs. Since wards don't have predefined UUIDs,
-- we'll use a subquery approach. First, let's reference known wards.

-- For demo purposes, we'll insert admissions with ward lookups

-- Currently Admitted Patients
insert into admissions (id, patient_id, hospital_id, ward_id, status, admitted_at, admitted_by_auth_user_id) values
  (
    '44444444-4444-4444-4444-444444444401',
    '33333333-3333-3333-3333-333333333301', -- Kweku Asante
    '11111111-1111-1111-1111-111111111101', -- Korle Bu
    (select id from wards where hospital_id = '11111111-1111-1111-1111-111111111101' and name = 'General Ward A' limit 1),
    'admitted',
    now() - interval '3 days',
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaa101' -- Dr. Kwame Mensah
  ),
  (
    '44444444-4444-4444-4444-444444444402',
    '33333333-3333-3333-3333-333333333302', -- Yaw Boateng
    '11111111-1111-1111-1111-111111111101', -- Korle Bu
    (select id from wards where hospital_id = '11111111-1111-1111-1111-111111111101' and name = 'ICU Main' limit 1),
    'admitted',
    now() - interval '5 days',
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaa102' -- Dr. Abena Osei
  ),
  (
    '44444444-4444-4444-4444-444444444403',
    '33333333-3333-3333-3333-333333333311', -- Akua Boateng
    '11111111-1111-1111-1111-111111111101', -- Korle Bu
    (select id from wards where hospital_id = '11111111-1111-1111-1111-111111111101' and name = 'Maternity Ward' limit 1),
    'admitted',
    now() - interval '2 days',
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaa101'
  ),
  (
    '44444444-4444-4444-4444-444444444404',
    '33333333-3333-3333-3333-333333333303', -- Kofi Mensah
    '11111111-1111-1111-1111-111111111201', -- KATH
    (select id from wards where hospital_id = '11111111-1111-1111-1111-111111111201' and name = 'Surgical Ward A' limit 1),
    'admitted',
    now() - interval '7 days',
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaa111' -- Dr. Benjamin Agyei
  ),
  (
    '44444444-4444-4444-4444-444444444405',
    '33333333-3333-3333-3333-333333333312', -- Abena Mensah
    '11111111-1111-1111-1111-111111111201', -- KATH
    (select id from wards where hospital_id = '11111111-1111-1111-1111-111111111201' and name = 'General Ward A' limit 1),
    'admitted',
    now() - interval '1 day',
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaa112'
  ),
  (
    '44444444-4444-4444-4444-444444444406',
    '33333333-3333-3333-3333-333333333304', -- Emmanuel Osei
    '11111111-1111-1111-1111-111111111701', -- Tamale Teaching
    (select id from wards where hospital_id = '11111111-1111-1111-1111-111111111701' and name = 'Orthopedic Ward' limit 1),
    'admitted',
    now() - interval '10 days',
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaa115'
  ),
  (
    '44444444-4444-4444-4444-444444444407',
    '33333333-3333-3333-3333-333333333316', -- Fatima Iddrisu
    '11111111-1111-1111-1111-111111111701', -- Tamale Teaching
    (select id from wards where hospital_id = '11111111-1111-1111-1111-111111111701' and name = 'Maternity Ward' limit 1),
    'admitted',
    now() - interval '4 days',
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaa116'
  ),
  (
    '44444444-4444-4444-4444-444444444408',
    '33333333-3333-3333-3333-333333333305', -- Isaac Darko
    '11111111-1111-1111-1111-111111111102', -- Ridge Hospital
    (select id from wards where hospital_id = '11111111-1111-1111-1111-111111111102' and name = 'Emergency Ward' limit 1),
    'admitted',
    now() - interval '6 hours',
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaa106'
  )
on conflict (id) do update set
  status = excluded.status,
  admitted_at = excluded.admitted_at;

-- Discharged Patients (Past Admissions)
insert into admissions (id, patient_id, hospital_id, ward_id, status, admitted_at, discharged_at, admitted_by_auth_user_id, discharged_by_auth_user_id) values
  (
    '44444444-4444-4444-4444-444444444411',
    '33333333-3333-3333-3333-333333333306', -- Michael Adjei
    '11111111-1111-1111-1111-111111111101', -- Korle Bu
    (select id from wards where hospital_id = '11111111-1111-1111-1111-111111111101' and name = 'Surgical Ward A' limit 1),
    'discharged',
    now() - interval '14 days',
    now() - interval '7 days',
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaa101',
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaa102'
  ),
  (
    '44444444-4444-4444-4444-444444444412',
    '33333333-3333-3333-3333-333333333307', -- Daniel Appiah
    '11111111-1111-1111-1111-111111111101', -- Korle Bu
    (select id from wards where hospital_id = '11111111-1111-1111-1111-111111111101' and name = 'Cardiac Ward' limit 1),
    'discharged',
    now() - interval '21 days',
    now() - interval '10 days',
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaa101',
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaa101'
  ),
  (
    '44444444-4444-4444-4444-444444444413',
    '33333333-3333-3333-3333-333333333313', -- Ama Darko
    '11111111-1111-1111-1111-111111111201', -- KATH
    (select id from wards where hospital_id = '11111111-1111-1111-1111-111111111201' and name = 'Maternity Ward' limit 1),
    'discharged',
    now() - interval '10 days',
    now() - interval '7 days',
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaa111',
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaa112'
  ),
  (
    '44444444-4444-4444-4444-444444444414',
    '33333333-3333-3333-3333-333333333308', -- Samuel Owusu
    '11111111-1111-1111-1111-111111111401', -- Cape Coast Teaching
    (select id from wards where hospital_id = '11111111-1111-1111-1111-111111111401' and name = 'General Ward A' limit 1),
    'discharged',
    now() - interval '5 days',
    now() - interval '2 days',
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaa118',
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaa118'
  ),
  (
    '44444444-4444-4444-4444-444444444415',
    '33333333-3333-3333-3333-333333333317', -- Elizabeth Eshun
    '11111111-1111-1111-1111-111111111106', -- Tema General
    (select id from wards where hospital_id = '11111111-1111-1111-1111-111111111106' and name = 'General Ward A' limit 1),
    'discharged',
    now() - interval '8 days',
    now() - interval '3 days',
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaa120',
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaa120'
  )
on conflict (id) do update set
  status = excluded.status,
  discharged_at = excluded.discharged_at;

-- ============================================
-- 4) DEMO REFERRALS
-- ============================================

-- Pending Referrals
insert into referrals (id, patient_id, from_hospital_id, from_ward_id, to_hospital_id, reason, status, created_by_auth_user_id) values
  (
    '55555555-5555-5555-5555-555555555501',
    '33333333-3333-3333-3333-333333333309', -- Ibrahim Mohammed
    '11111111-1111-1111-1111-111111111701', -- From: Tamale Teaching
    (select id from wards where hospital_id = '11111111-1111-1111-1111-111111111701' and name = 'ICU' limit 1),
    '11111111-1111-1111-1111-111111111101', -- To: Korle Bu
    'Patient requires specialized cardiac surgery not available at Tamale Teaching Hospital. Condition is stable but urgent transfer recommended.',
    'pending',
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaa115' -- Dr. Ibrahim Mohammed
  ),
  (
    '55555555-5555-5555-5555-555555555502',
    '33333333-3333-3333-3333-333333333310', -- Alhassan Salifu
    '11111111-1111-1111-1111-111111111801', -- From: Upper East Regional
    (select id from wards where hospital_id = '11111111-1111-1111-1111-111111111801' and name = 'General Ward A' limit 1),
    '11111111-1111-1111-1111-111111111201', -- To: KATH
    'Complex orthopedic trauma requiring specialized surgical intervention. Multiple fractures sustained from road traffic accident.',
    'pending',
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaa115'
  ),
  (
    '55555555-5555-5555-5555-555555555503',
    '33333333-3333-3333-3333-333333333314', -- Efua Antwi
    '11111111-1111-1111-1111-111111111106', -- From: Tema General
    (select id from wards where hospital_id = '11111111-1111-1111-1111-111111111106' and name = 'Maternity Ward' limit 1),
    '11111111-1111-1111-1111-111111111101', -- To: Korle Bu
    'High-risk pregnancy with complications. Requires specialized neonatal intensive care unit.',
    'pending',
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaa120'
  )
on conflict (id) do nothing;

-- Accepted Referrals (Waiting for patient transfer)
insert into referrals (id, patient_id, from_hospital_id, from_ward_id, to_hospital_id, reason, status, created_by_auth_user_id, accepted_at, accepted_by_auth_user_id) values
  (
    '55555555-5555-5555-5555-555555555504',
    '33333333-3333-3333-3333-333333333318', -- Priscilla Amoah
    '11111111-1111-1111-1111-111111111301', -- From: Effia Nkwanta
    (select id from wards where hospital_id = '11111111-1111-1111-1111-111111111301' and name = 'Emergency Ward' limit 1),
    '11111111-1111-1111-1111-111111111101', -- To: Korle Bu
    'Severe burns requiring specialized burns unit treatment. Patient stabilized for transfer.',
    'accepted',
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaa124',
    now() - interval '2 hours',
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaa101'
  ),
  (
    '55555555-5555-5555-5555-555555555505',
    '33333333-3333-3333-3333-333333333321', -- Kwame Asiedu
    '11111111-1111-1111-1111-111111111601', -- From: Ho Teaching
    (select id from wards where hospital_id = '11111111-1111-1111-1111-111111111601' and name = 'General Ward A' limit 1),
    '11111111-1111-1111-1111-111111111201', -- To: KATH
    'Patient requires kidney transplant evaluation. Referred for specialist nephrology assessment.',
    'accepted',
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaa122',
    now() - interval '4 hours',
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaa111'
  )
on conflict (id) do nothing;

-- Completed Referrals
insert into referrals (id, patient_id, from_hospital_id, from_ward_id, to_hospital_id, reason, status, created_by_auth_user_id, accepted_at, accepted_by_auth_user_id) values
  (
    '55555555-5555-5555-5555-555555555506',
    '33333333-3333-3333-3333-333333333306', -- Michael Adjei (already discharged)
    '11111111-1111-1111-1111-111111111102', -- From: Ridge Hospital
    (select id from wards where hospital_id = '11111111-1111-1111-1111-111111111102' and name = 'General Ward A' limit 1),
    '11111111-1111-1111-1111-111111111101', -- To: Korle Bu
    'Required complex abdominal surgery. Referred to Korle Bu surgical unit.',
    'completed',
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaa106',
    now() - interval '15 days',
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaa101'
  ),
  (
    '55555555-5555-5555-5555-555555555507',
    '33333333-3333-3333-3333-333333333313', -- Ama Darko (already discharged)
    '11111111-1111-1111-1111-111111111401', -- From: Cape Coast Teaching
    (select id from wards where hospital_id = '11111111-1111-1111-1111-111111111401' and name = 'Maternity Ward' limit 1),
    '11111111-1111-1111-1111-111111111201', -- To: KATH
    'Complicated delivery requiring cesarean section with specialized team.',
    'completed',
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaa118',
    now() - interval '12 days',
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaa112'
  )
on conflict (id) do nothing;

-- Rejected Referrals
insert into referrals (id, patient_id, from_hospital_id, from_ward_id, to_hospital_id, reason, status, created_by_auth_user_id) values
  (
    '55555555-5555-5555-5555-555555555508',
    '33333333-3333-3333-3333-333333333322', -- Adwoa Frimpong
    '11111111-1111-1111-1111-111111111103', -- From: 37 Military
    (select id from wards where hospital_id = '11111111-1111-1111-1111-111111111103' and name = 'General Ward A' limit 1),
    '11111111-1111-1111-1111-111111111101', -- To: Korle Bu
    'Patient requires specialized neurosurgery.',
    'rejected',
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaa109'
  )
on conflict (id) do nothing;

-- Cancelled Referrals
insert into referrals (id, patient_id, from_hospital_id, from_ward_id, to_hospital_id, reason, status, created_by_auth_user_id) values
  (
    '55555555-5555-5555-5555-555555555509',
    '33333333-3333-3333-3333-333333333323', -- Yaw Opoku
    '11111111-1111-1111-1111-111111111106', -- From: Tema General
    (select id from wards where hospital_id = '11111111-1111-1111-1111-111111111106' and name = 'General Ward A' limit 1),
    '11111111-1111-1111-1111-111111111201', -- To: KATH
    'Patient condition improved significantly, referral no longer necessary.',
    'cancelled',
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaa120'
  )
on conflict (id) do nothing;

-- ============================================
-- 5) DEMO BED RESERVATIONS
-- ============================================

-- Active Emergency Reservations
insert into bed_reservations (id, referral_id, hospital_id, ward_id, reserved_by_auth_user_id, reserved_at, expires_at, status, reservation_type, reserved_by_name, priority, notes) values
  (
    '66666666-6666-6666-6666-666666666601',
    null, -- Emergency - no referral
    '11111111-1111-1111-1111-111111111101', -- Korle Bu
    (select id from wards where hospital_id = '11111111-1111-1111-1111-111111111101' and name = 'Emergency Ward' limit 1),
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaa101',
    now() - interval '30 minutes',
    now() + interval '90 minutes',
    'active',
    'emergency',
    'Dr. Kwame Mensah',
    'critical',
    'Emergency trauma case incoming from accident scene. ETA 20 minutes.'
  ),
  (
    '66666666-6666-6666-6666-666666666602',
    null, -- Emergency - no referral
    '11111111-1111-1111-1111-111111111201', -- KATH
    (select id from wards where hospital_id = '11111111-1111-1111-1111-111111111201' and name = 'ICU' limit 1),
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaa111',
    now() - interval '1 hour',
    now() + interval '1 hour',
    'active',
    'emergency',
    'Dr. Benjamin Agyei',
    'high',
    'Cardiac emergency. Patient being airlifted from remote area.'
  ),
  (
    '66666666-6666-6666-6666-666666666603',
    null, -- Scheduled reservation
    '11111111-1111-1111-1111-111111111101', -- Korle Bu
    (select id from wards where hospital_id = '11111111-1111-1111-1111-111111111101' and name = 'Surgical Ward A' limit 1),
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaa102',
    now() - interval '6 hours',
    now() + interval '6 hours',
    'active',
    'scheduled',
    'Dr. Abena Osei',
    'normal',
    'Scheduled surgery tomorrow morning. Patient arriving this evening.'
  )
on conflict (id) do nothing;

-- Active Referral Reservations
insert into bed_reservations (id, referral_id, hospital_id, ward_id, reserved_by_auth_user_id, reserved_at, expires_at, status, reservation_type, reserved_by_name, priority, notes) values
  (
    '66666666-6666-6666-6666-666666666604',
    '55555555-5555-5555-5555-555555555504', -- Accepted referral for Priscilla Amoah
    '11111111-1111-1111-1111-111111111101', -- Korle Bu
    (select id from wards where hospital_id = '11111111-1111-1111-1111-111111111101' and name = 'Burns Unit' limit 1),
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaa101',
    now() - interval '2 hours',
    now() + interval '22 hours',
    'active',
    'referral',
    'Dr. Kwame Mensah',
    'high',
    'Bed reserved for incoming burns patient from Effia Nkwanta.'
  ),
  (
    '66666666-6666-6666-6666-666666666605',
    '55555555-5555-5555-5555-555555555505', -- Accepted referral for Kwame Asiedu
    '11111111-1111-1111-1111-111111111201', -- KATH
    (select id from wards where hospital_id = '11111111-1111-1111-1111-111111111201' and name = 'General Ward B' limit 1),
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaa112',
    now() - interval '4 hours',
    now() + interval '20 hours',
    'active',
    'referral',
    'Dr. Felicia Boakye',
    'normal',
    'Nephrology evaluation bed. Patient transfer in progress.'
  )
on conflict (id) do nothing;

-- Completed Reservations (Patient admitted)
insert into bed_reservations (id, referral_id, hospital_id, ward_id, reserved_by_auth_user_id, reserved_at, expires_at, status, reservation_type, reserved_by_name, priority, notes, completed_at) values
  (
    '66666666-6666-6666-6666-666666666606',
    '55555555-5555-5555-5555-555555555506', -- Completed referral for Michael Adjei
    '11111111-1111-1111-1111-111111111101', -- Korle Bu
    (select id from wards where hospital_id = '11111111-1111-1111-1111-111111111101' and name = 'Surgical Ward A' limit 1),
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaa101',
    now() - interval '15 days',
    now() - interval '14 days',
    'completed',
    'referral',
    'Dr. Kwame Mensah',
    'high',
    'Patient successfully admitted for abdominal surgery.',
    now() - interval '14 days'
  ),
  (
    '66666666-6666-6666-6666-666666666607',
    null, -- Emergency
    '11111111-1111-1111-1111-111111111701', -- Tamale Teaching
    (select id from wards where hospital_id = '11111111-1111-1111-1111-111111111701' and name = 'Emergency Ward' limit 1),
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaa115',
    now() - interval '3 days',
    now() - interval '3 days' + interval '2 hours',
    'completed',
    'emergency',
    'Dr. Ibrahim Mohammed',
    'critical',
    'Emergency accident case successfully admitted.',
    now() - interval '3 days' + interval '45 minutes'
  )
on conflict (id) do nothing;

-- Expired Reservations
insert into bed_reservations (id, referral_id, hospital_id, ward_id, reserved_by_auth_user_id, reserved_at, expires_at, status, reservation_type, reserved_by_name, priority, notes) values
  (
    '66666666-6666-6666-6666-666666666608',
    null,
    '11111111-1111-1111-1111-111111111102', -- Ridge Hospital
    (select id from wards where hospital_id = '11111111-1111-1111-1111-111111111102' and name = 'ICU' limit 1),
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaa106',
    now() - interval '1 day',
    now() - interval '22 hours',
    'expired',
    'scheduled',
    'Dr. Kofi Adjei',
    'normal',
    'Patient did not arrive. Reservation expired.'
  )
on conflict (id) do nothing;

-- Cancelled Reservations
insert into bed_reservations (id, referral_id, hospital_id, ward_id, reserved_by_auth_user_id, reserved_at, expires_at, status, reservation_type, reserved_by_name, priority, notes, cancelled_at) values
  (
    '66666666-6666-6666-6666-666666666609',
    '55555555-5555-5555-5555-555555555509', -- Cancelled referral for Yaw Opoku
    '11111111-1111-1111-1111-111111111201', -- KATH
    (select id from wards where hospital_id = '11111111-1111-1111-1111-111111111201' and name = 'General Ward A' limit 1),
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaa111',
    now() - interval '5 days',
    now() - interval '4 days',
    'cancelled',
    'referral',
    'Dr. Benjamin Agyei',
    'normal',
    'Referral cancelled - patient condition improved.',
    now() - interval '4 days' - interval '6 hours'
  )
on conflict (id) do nothing;

-- ============================================
-- 6) DEMO AUDIT LOGS
-- ============================================

insert into audit_logs (id, action, table_name, record_id, actor_auth_user_id, old_data, new_data) values
  -- Admission audit logs
  (
    '77777777-7777-7777-7777-777777777701',
    'INSERT',
    'admissions',
    '44444444-4444-4444-4444-444444444401',
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaa101',
    null,
    '{"patient_id": "33333333-3333-3333-3333-333333333301", "status": "admitted", "ward": "General Ward A"}'::jsonb
  ),
  (
    '77777777-7777-7777-7777-777777777702',
    'INSERT',
    'admissions',
    '44444444-4444-4444-4444-444444444402',
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaa102',
    null,
    '{"patient_id": "33333333-3333-3333-3333-333333333302", "status": "admitted", "ward": "ICU Main"}'::jsonb
  ),
  -- Discharge audit logs
  (
    '77777777-7777-7777-7777-777777777703',
    'UPDATE',
    'admissions',
    '44444444-4444-4444-4444-444444444411',
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaa102',
    '{"status": "admitted"}'::jsonb,
    '{"status": "discharged"}'::jsonb
  ),
  -- Referral audit logs
  (
    '77777777-7777-7777-7777-777777777704',
    'INSERT',
    'referrals',
    '55555555-5555-5555-5555-555555555501',
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaa115',
    null,
    '{"patient_id": "33333333-3333-3333-3333-333333333309", "from_hospital": "Tamale Teaching", "to_hospital": "Korle Bu", "status": "pending"}'::jsonb
  ),
  (
    '77777777-7777-7777-7777-777777777705',
    'UPDATE',
    'referrals',
    '55555555-5555-5555-5555-555555555504',
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaa101',
    '{"status": "pending"}'::jsonb,
    '{"status": "accepted"}'::jsonb
  ),
  (
    '77777777-7777-7777-7777-777777777706',
    'UPDATE',
    'referrals',
    '55555555-5555-5555-5555-555555555506',
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaa101',
    '{"status": "accepted"}'::jsonb,
    '{"status": "completed"}'::jsonb
  ),
  -- Bed reservation audit logs
  (
    '77777777-7777-7777-7777-777777777707',
    'INSERT',
    'bed_reservations',
    '66666666-6666-6666-6666-666666666601',
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaa101',
    null,
    '{"ward": "Emergency Ward", "type": "emergency", "priority": "critical"}'::jsonb
  ),
  (
    '77777777-7777-7777-7777-777777777708',
    'UPDATE',
    'bed_reservations',
    '66666666-6666-6666-6666-666666666606',
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaa101',
    '{"status": "active"}'::jsonb,
    '{"status": "completed"}'::jsonb
  ),
  -- User creation audit logs
  (
    '77777777-7777-7777-7777-777777777709',
    'INSERT',
    'users',
    '22222222-2222-2222-2222-222222222201',
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaa105', -- Admin user
    null,
    '{"staff_id": "KB-DOC-001", "role": "doctor", "name": "Dr. Kwame Mensah"}'::jsonb
  ),
  (
    '77777777-7777-7777-7777-777777777710',
    'INSERT',
    'patients',
    '33333333-3333-3333-3333-333333333301',
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaa101',
    null,
    '{"full_name": "Kweku Asante", "sex": "M", "national_id": "GHA-1985-0315-M001"}'::jsonb
  )
on conflict (id) do nothing;

-- ============================================
-- 7) SUMMARY
-- ============================================
-- This seed data includes:
-- - 25 staff users across 10 hospitals (doctors, nurses, admins)
-- - 30 patients with Ghanaian names and realistic data
-- - 13 admissions (8 current, 5 discharged)
-- - 9 referrals (3 pending, 2 accepted, 2 completed, 1 rejected, 1 cancelled)
-- - 9 bed reservations (5 active, 2 completed, 1 expired, 1 cancelled)
-- - 10 audit log entries
--
-- All UUIDs follow a consistent pattern for easy identification:
-- - Users: 22222222-2222-2222-2222-2222222222XX
-- - Auth Users: aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaa1XX
-- - Patients: 33333333-3333-3333-3333-3333333333XX
-- - Admissions: 44444444-4444-4444-4444-4444444444XX
-- - Referrals: 55555555-5555-5555-5555-5555555555XX
-- - Bed Reservations: 66666666-6666-6666-6666-6666666666XX
-- - Audit Logs: 77777777-7777-7777-7777-7777777777XX
