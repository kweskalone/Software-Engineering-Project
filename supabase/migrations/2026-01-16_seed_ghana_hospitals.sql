-- =========================================
-- SEED DATA: Ghana Hospitals and Wards
-- Date: 2026-01-16
-- =========================================
-- This script populates the database with actual hospitals in Ghana
-- and realistic ward configurations.

-- ============================================
-- 1) HOSPITALS - Major Healthcare Facilities in Ghana
-- ============================================

insert into hospitals (id, name, region, district) values
  -- Greater Accra Region
  ('11111111-1111-1111-1111-111111111101', 'Korle Bu Teaching Hospital', 'Greater Accra', 'Accra Metropolitan'),
  ('11111111-1111-1111-1111-111111111102', 'Ridge Hospital', 'Greater Accra', 'Accra Metropolitan'),
  ('11111111-1111-1111-1111-111111111103', '37 Military Hospital', 'Greater Accra', 'Accra Metropolitan'),
  ('11111111-1111-1111-1111-111111111104', 'Police Hospital', 'Greater Accra', 'Accra Metropolitan'),
  ('11111111-1111-1111-1111-111111111105', 'La General Hospital', 'Greater Accra', 'La Dade-Kotopon'),
  ('11111111-1111-1111-1111-111111111106', 'Tema General Hospital', 'Greater Accra', 'Tema Metropolitan'),
  ('11111111-1111-1111-1111-111111111107', 'Lekma Hospital', 'Greater Accra', 'Ledzokuku-Krowor'),
  ('11111111-1111-1111-1111-111111111108', 'Achimota Hospital', 'Greater Accra', 'Okaikwei North'),
  ('11111111-1111-1111-1111-111111111109', 'Ga South Municipal Hospital', 'Greater Accra', 'Ga South'),
  ('11111111-1111-1111-1111-111111111110', 'Pentecost Hospital (Madina)', 'Greater Accra', 'La-Nkwantanang-Madina'),

  -- Ashanti Region
  ('11111111-1111-1111-1111-111111111201', 'Komfo Anokye Teaching Hospital', 'Ashanti', 'Kumasi Metropolitan'),
  ('11111111-1111-1111-1111-111111111202', 'Manhyia District Hospital', 'Ashanti', 'Kumasi Metropolitan'),
  ('11111111-1111-1111-1111-111111111203', 'Okomfo Anokye Hospital', 'Ashanti', 'Kumasi Metropolitan'),
  ('11111111-1111-1111-1111-111111111204', 'Kumasi South Hospital', 'Ashanti', 'Asokwa'),
  ('11111111-1111-1111-1111-111111111205', 'Ejisu Government Hospital', 'Ashanti', 'Ejisu-Juaben'),
  ('11111111-1111-1111-1111-111111111206', 'Bekwai Municipal Hospital', 'Ashanti', 'Bekwai'),
  ('11111111-1111-1111-1111-111111111207', 'Konongo-Odumase Government Hospital', 'Ashanti', 'Asante Akim Central'),
  ('11111111-1111-1111-1111-111111111208', 'Agogo Presbyterian Hospital', 'Ashanti', 'Asante Akim North'),

  -- Western Region
  ('11111111-1111-1111-1111-111111111301', 'Effia Nkwanta Regional Hospital', 'Western', 'Sekondi-Takoradi'),
  ('11111111-1111-1111-1111-111111111302', 'Takoradi Hospital', 'Western', 'Sekondi-Takoradi'),
  ('11111111-1111-1111-1111-111111111303', 'Tarkwa Municipal Hospital', 'Western', 'Tarkwa-Nsuaem'),
  ('11111111-1111-1111-1111-111111111304', 'Axim Government Hospital', 'Western', 'Nzema East'),

  -- Central Region
  ('11111111-1111-1111-1111-111111111401', 'Cape Coast Teaching Hospital', 'Central', 'Cape Coast Metropolitan'),
  ('11111111-1111-1111-1111-111111111402', 'University of Cape Coast Hospital', 'Central', 'Cape Coast Metropolitan'),
  ('11111111-1111-1111-1111-111111111403', 'Winneba Municipal Hospital', 'Central', 'Effutu'),
  ('11111111-1111-1111-1111-111111111404', 'Saltpond Government Hospital', 'Central', 'Mfantseman'),
  ('11111111-1111-1111-1111-111111111405', 'Swedru Municipal Hospital', 'Central', 'Agona West'),

  -- Eastern Region
  ('11111111-1111-1111-1111-111111111501', 'Eastern Regional Hospital (Koforidua)', 'Eastern', 'New Juaben South'),
  ('11111111-1111-1111-1111-111111111502', 'St. Joseph Hospital (Koforidua)', 'Eastern', 'New Juaben South'),
  ('11111111-1111-1111-1111-111111111503', 'Tetteh Quarshie Memorial Hospital', 'Eastern', 'Akuapem North'),
  ('11111111-1111-1111-1111-111111111504', 'Atua Government Hospital', 'Eastern', 'Lower Manya Krobo'),
  ('11111111-1111-1111-1111-111111111505', 'Oda Government Hospital', 'Eastern', 'Birim Central'),

  -- Volta Region
  ('11111111-1111-1111-1111-111111111601', 'Ho Teaching Hospital', 'Volta', 'Ho Municipal'),
  ('11111111-1111-1111-1111-111111111602', 'Hohoe Municipal Hospital', 'Volta', 'Hohoe'),
  ('11111111-1111-1111-1111-111111111603', 'Keta Municipal Hospital', 'Volta', 'Keta'),
  ('11111111-1111-1111-1111-111111111604', 'Kpando District Hospital', 'Volta', 'Kpando'),

  -- Northern Region
  ('11111111-1111-1111-1111-111111111701', 'Tamale Teaching Hospital', 'Northern', 'Tamale Metropolitan'),
  ('11111111-1111-1111-1111-111111111702', 'Tamale Central Hospital', 'Northern', 'Tamale Metropolitan'),
  ('11111111-1111-1111-1111-111111111703', 'Yendi Municipal Hospital', 'Northern', 'Yendi'),
  ('11111111-1111-1111-1111-111111111704', 'Baptist Medical Centre (Nalerigu)', 'Northern', 'East Mamprusi'),

  -- Upper East Region
  ('11111111-1111-1111-1111-111111111801', 'Upper East Regional Hospital (Bolgatanga)', 'Upper East', 'Bolgatanga'),
  ('11111111-1111-1111-1111-111111111802', 'War Memorial Hospital (Navrongo)', 'Upper East', 'Kassena-Nankana'),
  ('11111111-1111-1111-1111-111111111803', 'Bawku Presbyterian Hospital', 'Upper East', 'Bawku Municipal'),

  -- Upper West Region
  ('11111111-1111-1111-1111-111111111901', 'Upper West Regional Hospital (Wa)', 'Upper West', 'Wa Municipal'),
  ('11111111-1111-1111-1111-111111111902', 'St. Theresa Hospital (Nandom)', 'Upper West', 'Nandom'),
  ('11111111-1111-1111-1111-111111111903', 'Jirapa District Hospital', 'Upper West', 'Jirapa'),

  -- Bono Region
  ('11111111-1111-1111-1111-111111112001', 'Sunyani Regional Hospital', 'Bono', 'Sunyani Municipal'),
  ('11111111-1111-1111-1111-111111112002', 'Sunyani Municipal Hospital', 'Bono', 'Sunyani Municipal'),
  ('11111111-1111-1111-1111-111111112003', 'Berekum Holy Family Hospital', 'Bono', 'Berekum'),

  -- Bono East Region
  ('11111111-1111-1111-1111-111111112101', 'Techiman Holy Family Hospital', 'Bono East', 'Techiman'),
  ('11111111-1111-1111-1111-111111112102', 'Kintampo Municipal Hospital', 'Bono East', 'Kintampo North'),

  -- Ahafo Region
  ('11111111-1111-1111-1111-111111112201', 'Goaso Government Hospital', 'Ahafo', 'Asunafo North'),

  -- Savannah Region
  ('11111111-1111-1111-1111-111111112301', 'Damongo District Hospital', 'Savannah', 'West Gonja'),

  -- North East Region
  ('11111111-1111-1111-1111-111111112401', 'Gambaga District Hospital', 'North East', 'East Mamprusi'),

  -- Oti Region
  ('11111111-1111-1111-1111-111111112501', 'Dambai District Hospital', 'Oti', 'Krachi East'),
  ('11111111-1111-1111-1111-111111112502', 'Worawora Government Hospital', 'Oti', 'Biakoye'),

  -- Western North Region
  ('11111111-1111-1111-1111-111111112601', 'Sefwi Wiawso Government Hospital', 'Western North', 'Sefwi Wiawso'),
  ('11111111-1111-1111-1111-111111112602', 'Bibiani Government Hospital', 'Western North', 'Bibiani-Anhwiaso-Bekwai')

on conflict (id) do update set
  name = excluded.name,
  region = excluded.region,
  district = excluded.district;

-- ============================================
-- 2) WARDS - For Each Hospital
-- ============================================
-- Ward types: general, maternity, pediatric, icu, surgical, emergency, orthopedic, psychiatric, oncology, cardiac

-- Helper function to create wards for a hospital
-- We'll insert wards manually for each hospital type

-- ==========================================
-- TEACHING HOSPITALS (Large - Many Wards)
-- ==========================================

-- Korle Bu Teaching Hospital (Ghana's largest)
insert into wards (hospital_id, name, type, total_beds, available_beds) values
  ('11111111-1111-1111-1111-111111111101', 'General Ward A', 'general', 50, 15),
  ('11111111-1111-1111-1111-111111111101', 'General Ward B', 'general', 50, 12),
  ('11111111-1111-1111-1111-111111111101', 'General Ward C', 'general', 45, 8),
  ('11111111-1111-1111-1111-111111111101', 'Maternity Ward', 'maternity', 60, 20),
  ('11111111-1111-1111-1111-111111111101', 'Labour Ward', 'maternity', 30, 10),
  ('11111111-1111-1111-1111-111111111101', 'Pediatric Ward A', 'pediatric', 40, 12),
  ('11111111-1111-1111-1111-111111111101', 'Pediatric Ward B', 'pediatric', 35, 8),
  ('11111111-1111-1111-1111-111111111101', 'NICU', 'pediatric', 25, 5),
  ('11111111-1111-1111-1111-111111111101', 'ICU Main', 'icu', 20, 3),
  ('11111111-1111-1111-1111-111111111101', 'Cardiac ICU', 'icu', 15, 2),
  ('11111111-1111-1111-1111-111111111101', 'Surgical Ward A', 'surgical', 40, 10),
  ('11111111-1111-1111-1111-111111111101', 'Surgical Ward B', 'surgical', 35, 7),
  ('11111111-1111-1111-1111-111111111101', 'Emergency Ward', 'emergency', 30, 8),
  ('11111111-1111-1111-1111-111111111101', 'Orthopedic Ward', 'orthopedic', 35, 10),
  ('11111111-1111-1111-1111-111111111101', 'Burns Unit', 'surgical', 20, 5),
  ('11111111-1111-1111-1111-111111111101', 'Oncology Ward', 'oncology', 30, 8),
  ('11111111-1111-1111-1111-111111111101', 'Cardiac Ward', 'cardiac', 25, 6),
  ('11111111-1111-1111-1111-111111111101', 'Psychiatric Ward', 'psychiatric', 40, 15),
  ('11111111-1111-1111-1111-111111111101', 'Renal Unit', 'general', 20, 4),
  ('11111111-1111-1111-1111-111111111101', 'Eye Ward', 'surgical', 25, 10)
on conflict do nothing;

-- Komfo Anokye Teaching Hospital
insert into wards (hospital_id, name, type, total_beds, available_beds) values
  ('11111111-1111-1111-1111-111111111201', 'General Ward A', 'general', 45, 12),
  ('11111111-1111-1111-1111-111111111201', 'General Ward B', 'general', 45, 10),
  ('11111111-1111-1111-1111-111111111201', 'General Ward C', 'general', 40, 8),
  ('11111111-1111-1111-1111-111111111201', 'Maternity Ward', 'maternity', 55, 18),
  ('11111111-1111-1111-1111-111111111201', 'Labour Ward', 'maternity', 25, 8),
  ('11111111-1111-1111-1111-111111111201', 'Pediatric Ward', 'pediatric', 40, 10),
  ('11111111-1111-1111-1111-111111111201', 'NICU', 'pediatric', 20, 4),
  ('11111111-1111-1111-1111-111111111201', 'ICU', 'icu', 18, 2),
  ('11111111-1111-1111-1111-111111111201', 'Surgical Ward A', 'surgical', 35, 8),
  ('11111111-1111-1111-1111-111111111201', 'Surgical Ward B', 'surgical', 30, 6),
  ('11111111-1111-1111-1111-111111111201', 'Emergency Ward', 'emergency', 25, 5),
  ('11111111-1111-1111-1111-111111111201', 'Orthopedic Ward', 'orthopedic', 30, 8),
  ('11111111-1111-1111-1111-111111111201', 'Oncology Ward', 'oncology', 25, 7),
  ('11111111-1111-1111-1111-111111111201', 'Cardiac Ward', 'cardiac', 20, 5),
  ('11111111-1111-1111-1111-111111111201', 'Psychiatric Ward', 'psychiatric', 35, 12),
  ('11111111-1111-1111-1111-111111111201', 'Burns Unit', 'surgical', 15, 4)
on conflict do nothing;

-- Tamale Teaching Hospital
insert into wards (hospital_id, name, type, total_beds, available_beds) values
  ('11111111-1111-1111-1111-111111111701', 'General Ward A', 'general', 40, 12),
  ('11111111-1111-1111-1111-111111111701', 'General Ward B', 'general', 40, 10),
  ('11111111-1111-1111-1111-111111111701', 'Maternity Ward', 'maternity', 50, 15),
  ('11111111-1111-1111-1111-111111111701', 'Labour Ward', 'maternity', 20, 6),
  ('11111111-1111-1111-1111-111111111701', 'Pediatric Ward', 'pediatric', 35, 10),
  ('11111111-1111-1111-1111-111111111701', 'NICU', 'pediatric', 15, 3),
  ('11111111-1111-1111-1111-111111111701', 'ICU', 'icu', 15, 2),
  ('11111111-1111-1111-1111-111111111701', 'Surgical Ward', 'surgical', 30, 8),
  ('11111111-1111-1111-1111-111111111701', 'Emergency Ward', 'emergency', 20, 5),
  ('11111111-1111-1111-1111-111111111701', 'Orthopedic Ward', 'orthopedic', 25, 7),
  ('11111111-1111-1111-1111-111111111701', 'Psychiatric Ward', 'psychiatric', 30, 10)
on conflict do nothing;

-- Cape Coast Teaching Hospital
insert into wards (hospital_id, name, type, total_beds, available_beds) values
  ('11111111-1111-1111-1111-111111111401', 'General Ward A', 'general', 40, 10),
  ('11111111-1111-1111-1111-111111111401', 'General Ward B', 'general', 35, 8),
  ('11111111-1111-1111-1111-111111111401', 'Maternity Ward', 'maternity', 45, 12),
  ('11111111-1111-1111-1111-111111111401', 'Labour Ward', 'maternity', 20, 5),
  ('11111111-1111-1111-1111-111111111401', 'Pediatric Ward', 'pediatric', 35, 10),
  ('11111111-1111-1111-1111-111111111401', 'NICU', 'pediatric', 12, 2),
  ('11111111-1111-1111-1111-111111111401', 'ICU', 'icu', 12, 2),
  ('11111111-1111-1111-1111-111111111401', 'Surgical Ward', 'surgical', 30, 7),
  ('11111111-1111-1111-1111-111111111401', 'Emergency Ward', 'emergency', 20, 5),
  ('11111111-1111-1111-1111-111111111401', 'Orthopedic Ward', 'orthopedic', 20, 6)
on conflict do nothing;

-- Ho Teaching Hospital
insert into wards (hospital_id, name, type, total_beds, available_beds) values
  ('11111111-1111-1111-1111-111111111601', 'General Ward A', 'general', 35, 10),
  ('11111111-1111-1111-1111-111111111601', 'General Ward B', 'general', 35, 8),
  ('11111111-1111-1111-1111-111111111601', 'Maternity Ward', 'maternity', 40, 12),
  ('11111111-1111-1111-1111-111111111601', 'Labour Ward', 'maternity', 18, 5),
  ('11111111-1111-1111-1111-111111111601', 'Pediatric Ward', 'pediatric', 30, 8),
  ('11111111-1111-1111-1111-111111111601', 'NICU', 'pediatric', 10, 2),
  ('11111111-1111-1111-1111-111111111601', 'ICU', 'icu', 10, 2),
  ('11111111-1111-1111-1111-111111111601', 'Surgical Ward', 'surgical', 25, 6),
  ('11111111-1111-1111-1111-111111111601', 'Emergency Ward', 'emergency', 18, 4)
on conflict do nothing;

-- ==========================================
-- REGIONAL HOSPITALS (Medium Size)
-- ==========================================

-- Ridge Hospital
insert into wards (hospital_id, name, type, total_beds, available_beds) values
  ('11111111-1111-1111-1111-111111111102', 'General Ward A', 'general', 35, 10),
  ('11111111-1111-1111-1111-111111111102', 'General Ward B', 'general', 30, 8),
  ('11111111-1111-1111-1111-111111111102', 'Maternity Ward', 'maternity', 45, 15),
  ('11111111-1111-1111-1111-111111111102', 'Labour Ward', 'maternity', 20, 6),
  ('11111111-1111-1111-1111-111111111102', 'Pediatric Ward', 'pediatric', 30, 8),
  ('11111111-1111-1111-1111-111111111102', 'NICU', 'pediatric', 15, 3),
  ('11111111-1111-1111-1111-111111111102', 'ICU', 'icu', 12, 2),
  ('11111111-1111-1111-1111-111111111102', 'Surgical Ward', 'surgical', 25, 6),
  ('11111111-1111-1111-1111-111111111102', 'Emergency Ward', 'emergency', 20, 5)
on conflict do nothing;

-- 37 Military Hospital
insert into wards (hospital_id, name, type, total_beds, available_beds) values
  ('11111111-1111-1111-1111-111111111103', 'General Ward A', 'general', 40, 12),
  ('11111111-1111-1111-1111-111111111103', 'General Ward B', 'general', 35, 10),
  ('11111111-1111-1111-1111-111111111103', 'Maternity Ward', 'maternity', 35, 10),
  ('11111111-1111-1111-1111-111111111103', 'Pediatric Ward', 'pediatric', 25, 8),
  ('11111111-1111-1111-1111-111111111103', 'ICU', 'icu', 15, 3),
  ('11111111-1111-1111-1111-111111111103', 'Surgical Ward', 'surgical', 30, 8),
  ('11111111-1111-1111-1111-111111111103', 'Emergency Ward', 'emergency', 20, 5),
  ('11111111-1111-1111-1111-111111111103', 'Orthopedic Ward', 'orthopedic', 25, 7),
  ('11111111-1111-1111-1111-111111111103', 'Cardiac Ward', 'cardiac', 15, 4)
on conflict do nothing;

-- Police Hospital
insert into wards (hospital_id, name, type, total_beds, available_beds) values
  ('11111111-1111-1111-1111-111111111104', 'General Ward', 'general', 30, 10),
  ('11111111-1111-1111-1111-111111111104', 'Maternity Ward', 'maternity', 25, 8),
  ('11111111-1111-1111-1111-111111111104', 'Pediatric Ward', 'pediatric', 20, 6),
  ('11111111-1111-1111-1111-111111111104', 'ICU', 'icu', 8, 2),
  ('11111111-1111-1111-1111-111111111104', 'Surgical Ward', 'surgical', 20, 5),
  ('11111111-1111-1111-1111-111111111104', 'Emergency Ward', 'emergency', 15, 4)
on conflict do nothing;

-- Tema General Hospital
insert into wards (hospital_id, name, type, total_beds, available_beds) values
  ('11111111-1111-1111-1111-111111111106', 'General Ward A', 'general', 35, 10),
  ('11111111-1111-1111-1111-111111111106', 'General Ward B', 'general', 30, 8),
  ('11111111-1111-1111-1111-111111111106', 'Maternity Ward', 'maternity', 40, 12),
  ('11111111-1111-1111-1111-111111111106', 'Pediatric Ward', 'pediatric', 25, 7),
  ('11111111-1111-1111-1111-111111111106', 'ICU', 'icu', 10, 2),
  ('11111111-1111-1111-1111-111111111106', 'Surgical Ward', 'surgical', 25, 6),
  ('11111111-1111-1111-1111-111111111106', 'Emergency Ward', 'emergency', 18, 4)
on conflict do nothing;

-- Effia Nkwanta Regional Hospital
insert into wards (hospital_id, name, type, total_beds, available_beds) values
  ('11111111-1111-1111-1111-111111111301', 'General Ward A', 'general', 35, 10),
  ('11111111-1111-1111-1111-111111111301', 'General Ward B', 'general', 30, 8),
  ('11111111-1111-1111-1111-111111111301', 'Maternity Ward', 'maternity', 40, 12),
  ('11111111-1111-1111-1111-111111111301', 'Labour Ward', 'maternity', 18, 5),
  ('11111111-1111-1111-1111-111111111301', 'Pediatric Ward', 'pediatric', 30, 8),
  ('11111111-1111-1111-1111-111111111301', 'ICU', 'icu', 10, 2),
  ('11111111-1111-1111-1111-111111111301', 'Surgical Ward', 'surgical', 25, 6),
  ('11111111-1111-1111-1111-111111111301', 'Emergency Ward', 'emergency', 18, 4)
on conflict do nothing;

-- Eastern Regional Hospital
insert into wards (hospital_id, name, type, total_beds, available_beds) values
  ('11111111-1111-1111-1111-111111111501', 'General Ward A', 'general', 35, 10),
  ('11111111-1111-1111-1111-111111111501', 'General Ward B', 'general', 30, 8),
  ('11111111-1111-1111-1111-111111111501', 'Maternity Ward', 'maternity', 40, 12),
  ('11111111-1111-1111-1111-111111111501', 'Pediatric Ward', 'pediatric', 25, 7),
  ('11111111-1111-1111-1111-111111111501', 'ICU', 'icu', 10, 2),
  ('11111111-1111-1111-1111-111111111501', 'Surgical Ward', 'surgical', 25, 6),
  ('11111111-1111-1111-1111-111111111501', 'Emergency Ward', 'emergency', 18, 4)
on conflict do nothing;

-- Upper East Regional Hospital
insert into wards (hospital_id, name, type, total_beds, available_beds) values
  ('11111111-1111-1111-1111-111111111801', 'General Ward A', 'general', 30, 10),
  ('11111111-1111-1111-1111-111111111801', 'General Ward B', 'general', 25, 8),
  ('11111111-1111-1111-1111-111111111801', 'Maternity Ward', 'maternity', 35, 12),
  ('11111111-1111-1111-1111-111111111801', 'Pediatric Ward', 'pediatric', 25, 8),
  ('11111111-1111-1111-1111-111111111801', 'ICU', 'icu', 8, 2),
  ('11111111-1111-1111-1111-111111111801', 'Surgical Ward', 'surgical', 20, 5),
  ('11111111-1111-1111-1111-111111111801', 'Emergency Ward', 'emergency', 15, 4)
on conflict do nothing;

-- Upper West Regional Hospital
insert into wards (hospital_id, name, type, total_beds, available_beds) values
  ('11111111-1111-1111-1111-111111111901', 'General Ward A', 'general', 30, 10),
  ('11111111-1111-1111-1111-111111111901', 'General Ward B', 'general', 25, 8),
  ('11111111-1111-1111-1111-111111111901', 'Maternity Ward', 'maternity', 35, 12),
  ('11111111-1111-1111-1111-111111111901', 'Pediatric Ward', 'pediatric', 20, 6),
  ('11111111-1111-1111-1111-111111111901', 'ICU', 'icu', 6, 1),
  ('11111111-1111-1111-1111-111111111901', 'Surgical Ward', 'surgical', 18, 5),
  ('11111111-1111-1111-1111-111111111901', 'Emergency Ward', 'emergency', 12, 3)
on conflict do nothing;

-- Sunyani Regional Hospital
insert into wards (hospital_id, name, type, total_beds, available_beds) values
  ('11111111-1111-1111-1111-111111112001', 'General Ward A', 'general', 30, 10),
  ('11111111-1111-1111-1111-111111112001', 'General Ward B', 'general', 25, 8),
  ('11111111-1111-1111-1111-111111112001', 'Maternity Ward', 'maternity', 35, 10),
  ('11111111-1111-1111-1111-111111112001', 'Pediatric Ward', 'pediatric', 25, 7),
  ('11111111-1111-1111-1111-111111112001', 'ICU', 'icu', 8, 2),
  ('11111111-1111-1111-1111-111111112001', 'Surgical Ward', 'surgical', 20, 5),
  ('11111111-1111-1111-1111-111111112001', 'Emergency Ward', 'emergency', 15, 4)
on conflict do nothing;

-- ==========================================
-- DISTRICT/MUNICIPAL HOSPITALS (Smaller)
-- ==========================================

-- La General Hospital
insert into wards (hospital_id, name, type, total_beds, available_beds) values
  ('11111111-1111-1111-1111-111111111105', 'General Ward', 'general', 25, 8),
  ('11111111-1111-1111-1111-111111111105', 'Maternity Ward', 'maternity', 30, 10),
  ('11111111-1111-1111-1111-111111111105', 'Pediatric Ward', 'pediatric', 20, 6),
  ('11111111-1111-1111-1111-111111111105', 'Emergency Ward', 'emergency', 12, 3)
on conflict do nothing;

-- Lekma Hospital
insert into wards (hospital_id, name, type, total_beds, available_beds) values
  ('11111111-1111-1111-1111-111111111107', 'General Ward', 'general', 25, 8),
  ('11111111-1111-1111-1111-111111111107', 'Maternity Ward', 'maternity', 30, 10),
  ('11111111-1111-1111-1111-111111111107', 'Pediatric Ward', 'pediatric', 18, 5),
  ('11111111-1111-1111-1111-111111111107', 'Emergency Ward', 'emergency', 10, 3)
on conflict do nothing;

-- Achimota Hospital
insert into wards (hospital_id, name, type, total_beds, available_beds) values
  ('11111111-1111-1111-1111-111111111108', 'General Ward', 'general', 25, 8),
  ('11111111-1111-1111-1111-111111111108', 'Maternity Ward', 'maternity', 28, 9),
  ('11111111-1111-1111-1111-111111111108', 'Pediatric Ward', 'pediatric', 18, 5),
  ('11111111-1111-1111-1111-111111111108', 'Emergency Ward', 'emergency', 10, 3)
on conflict do nothing;

-- Ga South Municipal Hospital
insert into wards (hospital_id, name, type, total_beds, available_beds) values
  ('11111111-1111-1111-1111-111111111109', 'General Ward', 'general', 20, 6),
  ('11111111-1111-1111-1111-111111111109', 'Maternity Ward', 'maternity', 25, 8),
  ('11111111-1111-1111-1111-111111111109', 'Pediatric Ward', 'pediatric', 15, 4),
  ('11111111-1111-1111-1111-111111111109', 'Emergency Ward', 'emergency', 10, 3)
on conflict do nothing;

-- Pentecost Hospital Madina
insert into wards (hospital_id, name, type, total_beds, available_beds) values
  ('11111111-1111-1111-1111-111111111110', 'General Ward', 'general', 25, 8),
  ('11111111-1111-1111-1111-111111111110', 'Maternity Ward', 'maternity', 30, 10),
  ('11111111-1111-1111-1111-111111111110', 'Pediatric Ward', 'pediatric', 18, 5),
  ('11111111-1111-1111-1111-111111111110', 'ICU', 'icu', 6, 1),
  ('11111111-1111-1111-1111-111111111110', 'Surgical Ward', 'surgical', 15, 4)
on conflict do nothing;

-- Manhyia District Hospital
insert into wards (hospital_id, name, type, total_beds, available_beds) values
  ('11111111-1111-1111-1111-111111111202', 'General Ward', 'general', 25, 8),
  ('11111111-1111-1111-1111-111111111202', 'Maternity Ward', 'maternity', 30, 10),
  ('11111111-1111-1111-1111-111111111202', 'Pediatric Ward', 'pediatric', 18, 5),
  ('11111111-1111-1111-1111-111111111202', 'Emergency Ward', 'emergency', 10, 3)
on conflict do nothing;

-- Kumasi South Hospital
insert into wards (hospital_id, name, type, total_beds, available_beds) values
  ('11111111-1111-1111-1111-111111111204', 'General Ward', 'general', 25, 8),
  ('11111111-1111-1111-1111-111111111204', 'Maternity Ward', 'maternity', 28, 9),
  ('11111111-1111-1111-1111-111111111204', 'Pediatric Ward', 'pediatric', 18, 5),
  ('11111111-1111-1111-1111-111111111204', 'Emergency Ward', 'emergency', 12, 3)
on conflict do nothing;

-- Bekwai Municipal Hospital
insert into wards (hospital_id, name, type, total_beds, available_beds) values
  ('11111111-1111-1111-1111-111111111206', 'General Ward', 'general', 20, 6),
  ('11111111-1111-1111-1111-111111111206', 'Maternity Ward', 'maternity', 25, 8),
  ('11111111-1111-1111-1111-111111111206', 'Pediatric Ward', 'pediatric', 15, 4),
  ('11111111-1111-1111-1111-111111111206', 'Emergency Ward', 'emergency', 10, 3)
on conflict do nothing;

-- Agogo Presbyterian Hospital
insert into wards (hospital_id, name, type, total_beds, available_beds) values
  ('11111111-1111-1111-1111-111111111208', 'General Ward', 'general', 30, 10),
  ('11111111-1111-1111-1111-111111111208', 'Maternity Ward', 'maternity', 35, 12),
  ('11111111-1111-1111-1111-111111111208', 'Pediatric Ward', 'pediatric', 20, 6),
  ('11111111-1111-1111-1111-111111111208', 'ICU', 'icu', 6, 1),
  ('11111111-1111-1111-1111-111111111208', 'Surgical Ward', 'surgical', 18, 5)
on conflict do nothing;

-- Takoradi Hospital
insert into wards (hospital_id, name, type, total_beds, available_beds) values
  ('11111111-1111-1111-1111-111111111302', 'General Ward', 'general', 25, 8),
  ('11111111-1111-1111-1111-111111111302', 'Maternity Ward', 'maternity', 30, 10),
  ('11111111-1111-1111-1111-111111111302', 'Pediatric Ward', 'pediatric', 18, 5),
  ('11111111-1111-1111-1111-111111111302', 'Emergency Ward', 'emergency', 12, 3)
on conflict do nothing;

-- Tarkwa Municipal Hospital
insert into wards (hospital_id, name, type, total_beds, available_beds) values
  ('11111111-1111-1111-1111-111111111303', 'General Ward', 'general', 25, 8),
  ('11111111-1111-1111-1111-111111111303', 'Maternity Ward', 'maternity', 28, 9),
  ('11111111-1111-1111-1111-111111111303', 'Pediatric Ward', 'pediatric', 15, 4),
  ('11111111-1111-1111-1111-111111111303', 'Emergency Ward', 'emergency', 10, 3)
on conflict do nothing;

-- Winneba Municipal Hospital
insert into wards (hospital_id, name, type, total_beds, available_beds) values
  ('11111111-1111-1111-1111-111111111403', 'General Ward', 'general', 20, 6),
  ('11111111-1111-1111-1111-111111111403', 'Maternity Ward', 'maternity', 25, 8),
  ('11111111-1111-1111-1111-111111111403', 'Pediatric Ward', 'pediatric', 15, 4),
  ('11111111-1111-1111-1111-111111111403', 'Emergency Ward', 'emergency', 10, 3)
on conflict do nothing;

-- Hohoe Municipal Hospital
insert into wards (hospital_id, name, type, total_beds, available_beds) values
  ('11111111-1111-1111-1111-111111111602', 'General Ward', 'general', 25, 8),
  ('11111111-1111-1111-1111-111111111602', 'Maternity Ward', 'maternity', 30, 10),
  ('11111111-1111-1111-1111-111111111602', 'Pediatric Ward', 'pediatric', 18, 5),
  ('11111111-1111-1111-1111-111111111602', 'Emergency Ward', 'emergency', 12, 3)
on conflict do nothing;

-- Keta Municipal Hospital
insert into wards (hospital_id, name, type, total_beds, available_beds) values
  ('11111111-1111-1111-1111-111111111603', 'General Ward', 'general', 20, 6),
  ('11111111-1111-1111-1111-111111111603', 'Maternity Ward', 'maternity', 25, 8),
  ('11111111-1111-1111-1111-111111111603', 'Pediatric Ward', 'pediatric', 15, 4),
  ('11111111-1111-1111-1111-111111111603', 'Emergency Ward', 'emergency', 10, 3)
on conflict do nothing;

-- Yendi Municipal Hospital
insert into wards (hospital_id, name, type, total_beds, available_beds) values
  ('11111111-1111-1111-1111-111111111703', 'General Ward', 'general', 20, 6),
  ('11111111-1111-1111-1111-111111111703', 'Maternity Ward', 'maternity', 25, 8),
  ('11111111-1111-1111-1111-111111111703', 'Pediatric Ward', 'pediatric', 15, 4),
  ('11111111-1111-1111-1111-111111111703', 'Emergency Ward', 'emergency', 10, 3)
on conflict do nothing;

-- War Memorial Hospital Navrongo
insert into wards (hospital_id, name, type, total_beds, available_beds) values
  ('11111111-1111-1111-1111-111111111802', 'General Ward', 'general', 25, 8),
  ('11111111-1111-1111-1111-111111111802', 'Maternity Ward', 'maternity', 30, 10),
  ('11111111-1111-1111-1111-111111111802', 'Pediatric Ward', 'pediatric', 18, 5),
  ('11111111-1111-1111-1111-111111111802', 'Emergency Ward', 'emergency', 12, 3)
on conflict do nothing;

-- Bawku Presbyterian Hospital
insert into wards (hospital_id, name, type, total_beds, available_beds) values
  ('11111111-1111-1111-1111-111111111803', 'General Ward', 'general', 25, 8),
  ('11111111-1111-1111-1111-111111111803', 'Maternity Ward', 'maternity', 28, 9),
  ('11111111-1111-1111-1111-111111111803', 'Pediatric Ward', 'pediatric', 15, 4),
  ('11111111-1111-1111-1111-111111111803', 'Surgical Ward', 'surgical', 15, 4)
on conflict do nothing;

-- Techiman Holy Family Hospital
insert into wards (hospital_id, name, type, total_beds, available_beds) values
  ('11111111-1111-1111-1111-111111112101', 'General Ward', 'general', 30, 10),
  ('11111111-1111-1111-1111-111111112101', 'Maternity Ward', 'maternity', 35, 12),
  ('11111111-1111-1111-1111-111111112101', 'Pediatric Ward', 'pediatric', 20, 6),
  ('11111111-1111-1111-1111-111111112101', 'ICU', 'icu', 6, 1),
  ('11111111-1111-1111-1111-111111112101', 'Surgical Ward', 'surgical', 18, 5)
on conflict do nothing;

-- Berekum Holy Family Hospital
insert into wards (hospital_id, name, type, total_beds, available_beds) values
  ('11111111-1111-1111-1111-111111112003', 'General Ward', 'general', 25, 8),
  ('11111111-1111-1111-1111-111111112003', 'Maternity Ward', 'maternity', 30, 10),
  ('11111111-1111-1111-1111-111111112003', 'Pediatric Ward', 'pediatric', 18, 5),
  ('11111111-1111-1111-1111-111111112003', 'Surgical Ward', 'surgical', 15, 4)
on conflict do nothing;

-- St. Theresa Hospital Nandom
insert into wards (hospital_id, name, type, total_beds, available_beds) values
  ('11111111-1111-1111-1111-111111111902', 'General Ward', 'general', 20, 6),
  ('11111111-1111-1111-1111-111111111902', 'Maternity Ward', 'maternity', 25, 8),
  ('11111111-1111-1111-1111-111111111902', 'Pediatric Ward', 'pediatric', 15, 4),
  ('11111111-1111-1111-1111-111111111902', 'Emergency Ward', 'emergency', 8, 2)
on conflict do nothing;

-- Baptist Medical Centre Nalerigu
insert into wards (hospital_id, name, type, total_beds, available_beds) values
  ('11111111-1111-1111-1111-111111111704', 'General Ward', 'general', 25, 8),
  ('11111111-1111-1111-1111-111111111704', 'Maternity Ward', 'maternity', 30, 10),
  ('11111111-1111-1111-1111-111111111704', 'Pediatric Ward', 'pediatric', 18, 5),
  ('11111111-1111-1111-1111-111111111704', 'Surgical Ward', 'surgical', 15, 4)
on conflict do nothing;

-- Remaining hospitals with standard ward setup
-- Using a pattern for smaller district hospitals

-- UCC Hospital
insert into wards (hospital_id, name, type, total_beds, available_beds) values
  ('11111111-1111-1111-1111-111111111402', 'General Ward', 'general', 20, 6),
  ('11111111-1111-1111-1111-111111111402', 'Maternity Ward', 'maternity', 25, 8),
  ('11111111-1111-1111-1111-111111111402', 'Emergency Ward', 'emergency', 10, 3)
on conflict do nothing;

-- Saltpond Government Hospital
insert into wards (hospital_id, name, type, total_beds, available_beds) values
  ('11111111-1111-1111-1111-111111111404', 'General Ward', 'general', 20, 6),
  ('11111111-1111-1111-1111-111111111404', 'Maternity Ward', 'maternity', 22, 7),
  ('11111111-1111-1111-1111-111111111404', 'Pediatric Ward', 'pediatric', 12, 3),
  ('11111111-1111-1111-1111-111111111404', 'Emergency Ward', 'emergency', 8, 2)
on conflict do nothing;

-- Swedru Municipal Hospital
insert into wards (hospital_id, name, type, total_beds, available_beds) values
  ('11111111-1111-1111-1111-111111111405', 'General Ward', 'general', 22, 7),
  ('11111111-1111-1111-1111-111111111405', 'Maternity Ward', 'maternity', 25, 8),
  ('11111111-1111-1111-1111-111111111405', 'Pediatric Ward', 'pediatric', 15, 4),
  ('11111111-1111-1111-1111-111111111405', 'Emergency Ward', 'emergency', 10, 3)
on conflict do nothing;

-- St. Joseph Hospital Koforidua
insert into wards (hospital_id, name, type, total_beds, available_beds) values
  ('11111111-1111-1111-1111-111111111502', 'General Ward', 'general', 25, 8),
  ('11111111-1111-1111-1111-111111111502', 'Maternity Ward', 'maternity', 30, 10),
  ('11111111-1111-1111-1111-111111111502', 'Pediatric Ward', 'pediatric', 18, 5),
  ('11111111-1111-1111-1111-111111111502', 'Surgical Ward', 'surgical', 15, 4)
on conflict do nothing;

-- Tetteh Quarshie Memorial Hospital
insert into wards (hospital_id, name, type, total_beds, available_beds) values
  ('11111111-1111-1111-1111-111111111503', 'General Ward', 'general', 20, 6),
  ('11111111-1111-1111-1111-111111111503', 'Maternity Ward', 'maternity', 25, 8),
  ('11111111-1111-1111-1111-111111111503', 'Pediatric Ward', 'pediatric', 15, 4),
  ('11111111-1111-1111-1111-111111111503', 'Emergency Ward', 'emergency', 10, 3)
on conflict do nothing;

-- Atua Government Hospital
insert into wards (hospital_id, name, type, total_beds, available_beds) values
  ('11111111-1111-1111-1111-111111111504', 'General Ward', 'general', 18, 5),
  ('11111111-1111-1111-1111-111111111504', 'Maternity Ward', 'maternity', 22, 7),
  ('11111111-1111-1111-1111-111111111504', 'Pediatric Ward', 'pediatric', 12, 3),
  ('11111111-1111-1111-1111-111111111504', 'Emergency Ward', 'emergency', 8, 2)
on conflict do nothing;

-- Oda Government Hospital
insert into wards (hospital_id, name, type, total_beds, available_beds) values
  ('11111111-1111-1111-1111-111111111505', 'General Ward', 'general', 20, 6),
  ('11111111-1111-1111-1111-111111111505', 'Maternity Ward', 'maternity', 25, 8),
  ('11111111-1111-1111-1111-111111111505', 'Pediatric Ward', 'pediatric', 15, 4),
  ('11111111-1111-1111-1111-111111111505', 'Emergency Ward', 'emergency', 10, 3)
on conflict do nothing;

-- Kpando District Hospital
insert into wards (hospital_id, name, type, total_beds, available_beds) values
  ('11111111-1111-1111-1111-111111111604', 'General Ward', 'general', 18, 5),
  ('11111111-1111-1111-1111-111111111604', 'Maternity Ward', 'maternity', 22, 7),
  ('11111111-1111-1111-1111-111111111604', 'Pediatric Ward', 'pediatric', 12, 3),
  ('11111111-1111-1111-1111-111111111604', 'Emergency Ward', 'emergency', 8, 2)
on conflict do nothing;

-- Tamale Central Hospital
insert into wards (hospital_id, name, type, total_beds, available_beds) values
  ('11111111-1111-1111-1111-111111111702', 'General Ward', 'general', 25, 8),
  ('11111111-1111-1111-1111-111111111702', 'Maternity Ward', 'maternity', 28, 9),
  ('11111111-1111-1111-1111-111111111702', 'Pediatric Ward', 'pediatric', 18, 5),
  ('11111111-1111-1111-1111-111111111702', 'Emergency Ward', 'emergency', 12, 3)
on conflict do nothing;

-- Jirapa District Hospital
insert into wards (hospital_id, name, type, total_beds, available_beds) values
  ('11111111-1111-1111-1111-111111111903', 'General Ward', 'general', 18, 5),
  ('11111111-1111-1111-1111-111111111903', 'Maternity Ward', 'maternity', 22, 7),
  ('11111111-1111-1111-1111-111111111903', 'Pediatric Ward', 'pediatric', 12, 3),
  ('11111111-1111-1111-1111-111111111903', 'Emergency Ward', 'emergency', 8, 2)
on conflict do nothing;

-- Sunyani Municipal Hospital
insert into wards (hospital_id, name, type, total_beds, available_beds) values
  ('11111111-1111-1111-1111-111111112002', 'General Ward', 'general', 22, 7),
  ('11111111-1111-1111-1111-111111112002', 'Maternity Ward', 'maternity', 25, 8),
  ('11111111-1111-1111-1111-111111112002', 'Pediatric Ward', 'pediatric', 15, 4),
  ('11111111-1111-1111-1111-111111112002', 'Emergency Ward', 'emergency', 10, 3)
on conflict do nothing;

-- Kintampo Municipal Hospital
insert into wards (hospital_id, name, type, total_beds, available_beds) values
  ('11111111-1111-1111-1111-111111112102', 'General Ward', 'general', 20, 6),
  ('11111111-1111-1111-1111-111111112102', 'Maternity Ward', 'maternity', 25, 8),
  ('11111111-1111-1111-1111-111111112102', 'Pediatric Ward', 'pediatric', 15, 4),
  ('11111111-1111-1111-1111-111111112102', 'Emergency Ward', 'emergency', 10, 3)
on conflict do nothing;

-- Goaso Government Hospital
insert into wards (hospital_id, name, type, total_beds, available_beds) values
  ('11111111-1111-1111-1111-111111112201', 'General Ward', 'general', 20, 6),
  ('11111111-1111-1111-1111-111111112201', 'Maternity Ward', 'maternity', 25, 8),
  ('11111111-1111-1111-1111-111111112201', 'Pediatric Ward', 'pediatric', 15, 4),
  ('11111111-1111-1111-1111-111111112201', 'Emergency Ward', 'emergency', 10, 3)
on conflict do nothing;

-- Damongo District Hospital
insert into wards (hospital_id, name, type, total_beds, available_beds) values
  ('11111111-1111-1111-1111-111111112301', 'General Ward', 'general', 18, 5),
  ('11111111-1111-1111-1111-111111112301', 'Maternity Ward', 'maternity', 22, 7),
  ('11111111-1111-1111-1111-111111112301', 'Pediatric Ward', 'pediatric', 12, 3),
  ('11111111-1111-1111-1111-111111112301', 'Emergency Ward', 'emergency', 8, 2)
on conflict do nothing;

-- Gambaga District Hospital
insert into wards (hospital_id, name, type, total_beds, available_beds) values
  ('11111111-1111-1111-1111-111111112401', 'General Ward', 'general', 15, 4),
  ('11111111-1111-1111-1111-111111112401', 'Maternity Ward', 'maternity', 20, 6),
  ('11111111-1111-1111-1111-111111112401', 'Pediatric Ward', 'pediatric', 10, 3),
  ('11111111-1111-1111-1111-111111112401', 'Emergency Ward', 'emergency', 6, 2)
on conflict do nothing;

-- Dambai District Hospital
insert into wards (hospital_id, name, type, total_beds, available_beds) values
  ('11111111-1111-1111-1111-111111112501', 'General Ward', 'general', 15, 4),
  ('11111111-1111-1111-1111-111111112501', 'Maternity Ward', 'maternity', 20, 6),
  ('11111111-1111-1111-1111-111111112501', 'Pediatric Ward', 'pediatric', 10, 3),
  ('11111111-1111-1111-1111-111111112501', 'Emergency Ward', 'emergency', 6, 2)
on conflict do nothing;

-- Worawora Government Hospital
insert into wards (hospital_id, name, type, total_beds, available_beds) values
  ('11111111-1111-1111-1111-111111112502', 'General Ward', 'general', 18, 5),
  ('11111111-1111-1111-1111-111111112502', 'Maternity Ward', 'maternity', 22, 7),
  ('11111111-1111-1111-1111-111111112502', 'Pediatric Ward', 'pediatric', 12, 3),
  ('11111111-1111-1111-1111-111111112502', 'Emergency Ward', 'emergency', 8, 2)
on conflict do nothing;

-- Sefwi Wiawso Government Hospital
insert into wards (hospital_id, name, type, total_beds, available_beds) values
  ('11111111-1111-1111-1111-111111112601', 'General Ward', 'general', 20, 6),
  ('11111111-1111-1111-1111-111111112601', 'Maternity Ward', 'maternity', 25, 8),
  ('11111111-1111-1111-1111-111111112601', 'Pediatric Ward', 'pediatric', 15, 4),
  ('11111111-1111-1111-1111-111111112601', 'Emergency Ward', 'emergency', 10, 3)
on conflict do nothing;

-- Bibiani Government Hospital
insert into wards (hospital_id, name, type, total_beds, available_beds) values
  ('11111111-1111-1111-1111-111111112602', 'General Ward', 'general', 20, 6),
  ('11111111-1111-1111-1111-111111112602', 'Maternity Ward', 'maternity', 25, 8),
  ('11111111-1111-1111-1111-111111112602', 'Pediatric Ward', 'pediatric', 15, 4),
  ('11111111-1111-1111-1111-111111112602', 'Emergency Ward', 'emergency', 10, 3)
on conflict do nothing;

-- Remaining Ashanti hospitals
-- Okomfo Anokye Hospital
insert into wards (hospital_id, name, type, total_beds, available_beds) values
  ('11111111-1111-1111-1111-111111111203', 'General Ward', 'general', 20, 6),
  ('11111111-1111-1111-1111-111111111203', 'Maternity Ward', 'maternity', 25, 8),
  ('11111111-1111-1111-1111-111111111203', 'Pediatric Ward', 'pediatric', 15, 4),
  ('11111111-1111-1111-1111-111111111203', 'Emergency Ward', 'emergency', 10, 3)
on conflict do nothing;

-- Ejisu Government Hospital
insert into wards (hospital_id, name, type, total_beds, available_beds) values
  ('11111111-1111-1111-1111-111111111205', 'General Ward', 'general', 20, 6),
  ('11111111-1111-1111-1111-111111111205', 'Maternity Ward', 'maternity', 25, 8),
  ('11111111-1111-1111-1111-111111111205', 'Pediatric Ward', 'pediatric', 15, 4),
  ('11111111-1111-1111-1111-111111111205', 'Emergency Ward', 'emergency', 10, 3)
on conflict do nothing;

-- Konongo-Odumase Government Hospital
insert into wards (hospital_id, name, type, total_beds, available_beds) values
  ('11111111-1111-1111-1111-111111111207', 'General Ward', 'general', 22, 7),
  ('11111111-1111-1111-1111-111111111207', 'Maternity Ward', 'maternity', 28, 9),
  ('11111111-1111-1111-1111-111111111207', 'Pediatric Ward', 'pediatric', 15, 4),
  ('11111111-1111-1111-1111-111111111207', 'Emergency Ward', 'emergency', 10, 3)
on conflict do nothing;

-- Axim Government Hospital
insert into wards (hospital_id, name, type, total_beds, available_beds) values
  ('11111111-1111-1111-1111-111111111304', 'General Ward', 'general', 18, 5),
  ('11111111-1111-1111-1111-111111111304', 'Maternity Ward', 'maternity', 22, 7),
  ('11111111-1111-1111-1111-111111111304', 'Pediatric Ward', 'pediatric', 12, 3),
  ('11111111-1111-1111-1111-111111111304', 'Emergency Ward', 'emergency', 8, 2)
on conflict do nothing;

-- ============================================
-- 3) UPDATE ward_type to match type column
-- ============================================
-- Ensure ward_type is synced with type for all records
update wards set ward_type = type where ward_type is null or ward_type <> type;

-- ============================================
-- SUMMARY
-- ============================================
-- Total hospitals: 55 across all 16 regions of Ghana
-- Ward types included: general, maternity, pediatric, icu, surgical, emergency, orthopedic, psychiatric, oncology, cardiac
-- Teaching hospitals have 10-20 wards each
-- Regional hospitals have 7-10 wards each
-- District hospitals have 4-5 wards each

-- Run this SQL in your Supabase SQL Editor to seed the database with Ghanaian hospitals and wards.
