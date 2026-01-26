-- =========================================
-- MIGRATION: Complete Missing Ward Data
-- Date: 2026-01-26
-- =========================================
-- This script ensures ALL hospitals have ward data.
-- Some hospitals may have been added without wards or wards
-- with different naming conventions.

-- ============================================
-- 1) FIX: Add "General Ward" alias where only "General Ward A/B" exists
-- ============================================
-- Some referrals reference "General Ward" but some hospitals only have "General Ward A"
-- This adds a "General Ward" for hospitals that don't have one

INSERT INTO wards (hospital_id, name, type, total_beds, available_beds)
SELECT 
  h.id,
  'General Ward',
  'general',
  25,
  8
FROM hospitals h
WHERE NOT EXISTS (
  SELECT 1 FROM wards w 
  WHERE w.hospital_id = h.id AND w.name = 'General Ward'
)
AND EXISTS (
  SELECT 1 FROM wards w2 
  WHERE w2.hospital_id = h.id
)
ON CONFLICT DO NOTHING;

-- ============================================
-- 2) ENSURE: All hospitals have at least basic wards
-- ============================================
-- For any hospital without ANY wards, add a standard set

-- Add General Ward if missing
INSERT INTO wards (hospital_id, name, type, total_beds, available_beds)
SELECT 
  h.id,
  'General Ward',
  'general',
  20,
  6
FROM hospitals h
WHERE NOT EXISTS (
  SELECT 1 FROM wards w WHERE w.hospital_id = h.id AND w.type = 'general'
)
ON CONFLICT DO NOTHING;

-- Add Maternity Ward if missing
INSERT INTO wards (hospital_id, name, type, total_beds, available_beds)
SELECT 
  h.id,
  'Maternity Ward',
  'maternity',
  25,
  8
FROM hospitals h
WHERE NOT EXISTS (
  SELECT 1 FROM wards w WHERE w.hospital_id = h.id AND w.type = 'maternity'
)
ON CONFLICT DO NOTHING;

-- Add Pediatric Ward if missing
INSERT INTO wards (hospital_id, name, type, total_beds, available_beds)
SELECT 
  h.id,
  'Pediatric Ward',
  'pediatric',
  15,
  4
FROM hospitals h
WHERE NOT EXISTS (
  SELECT 1 FROM wards w WHERE w.hospital_id = h.id AND w.type = 'pediatric'
)
ON CONFLICT DO NOTHING;

-- Add Emergency Ward if missing
INSERT INTO wards (hospital_id, name, type, total_beds, available_beds)
SELECT 
  h.id,
  'Emergency Ward',
  'emergency',
  10,
  3
FROM hospitals h
WHERE NOT EXISTS (
  SELECT 1 FROM wards w WHERE w.hospital_id = h.id AND w.type = 'emergency'
)
ON CONFLICT DO NOTHING;

-- ============================================
-- 3) FIX: Ensure Tema General Hospital has correct ward names
-- ============================================
-- The demo data references "General Ward" for Tema General (111111111106)
-- but the seed data only has "General Ward A" and "General Ward B"

INSERT INTO wards (hospital_id, name, type, total_beds, available_beds)
VALUES (
  '11111111-1111-1111-1111-111111111106',
  'General Ward',
  'general',
  25,
  8
)
ON CONFLICT DO NOTHING;

-- ============================================
-- 4) FIX: Ensure Ridge Hospital has correct ward names  
-- ============================================
-- The demo data references "General Ward" for Ridge (111111111102)

INSERT INTO wards (hospital_id, name, type, total_beds, available_beds)
VALUES (
  '11111111-1111-1111-1111-111111111102',
  'General Ward',
  'general',
  25,
  8
)
ON CONFLICT DO NOTHING;

-- ============================================
-- 5) FIX: Ensure Upper East Regional has "General Ward"
-- ============================================
-- The demo data references "General Ward" for Upper East (111111111801)

INSERT INTO wards (hospital_id, name, type, total_beds, available_beds)
VALUES (
  '11111111-1111-1111-1111-111111111801',
  'General Ward',
  'general',
  25,
  8
)
ON CONFLICT DO NOTHING;

-- ============================================
-- 6) VERIFY: Check for hospitals without wards
-- ============================================
-- This is a diagnostic query - run it to find any hospitals still missing wards:
/*
SELECT h.id, h.name, h.region, COUNT(w.id) as ward_count
FROM hospitals h
LEFT JOIN wards w ON w.hospital_id = h.id
GROUP BY h.id, h.name, h.region
HAVING COUNT(w.id) = 0
ORDER BY h.region, h.name;
*/

-- ============================================
-- 7) SUMMARY
-- ============================================
-- This migration ensures:
-- - Every hospital has at least General, Maternity, Pediatric, and Emergency wards
-- - Hospitals with "General Ward A/B" also have a generic "General Ward" for flexibility
-- - All demo data referral ward lookups will succeed

