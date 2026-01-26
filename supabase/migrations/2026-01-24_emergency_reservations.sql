-- =========================================
-- MIGRATION: Emergency Reservations Support
-- Date: 2026-01-24
-- Purpose: Allow bed reservations without a referral (emergency use)
-- =========================================

-- 1) Make referral_id nullable for emergency reservations
ALTER TABLE bed_reservations 
  ALTER COLUMN referral_id DROP NOT NULL;

-- 2) Add reservation_type column to distinguish emergency vs referral reservations
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'bed_reservations' AND column_name = 'reservation_type'
  ) THEN
    ALTER TABLE bed_reservations 
      ADD COLUMN reservation_type TEXT NOT NULL DEFAULT 'referral' 
      CHECK (reservation_type IN ('emergency', 'referral', 'scheduled'));
  END IF;
END $$;

-- 3) Add reserved_by_name for display purposes
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'bed_reservations' AND column_name = 'reserved_by_name'
  ) THEN
    ALTER TABLE bed_reservations 
      ADD COLUMN reserved_by_name TEXT;
  END IF;
END $$;

-- 4) Add priority column for emergency reservations
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'bed_reservations' AND column_name = 'priority'
  ) THEN
    ALTER TABLE bed_reservations 
      ADD COLUMN priority TEXT DEFAULT 'normal' 
      CHECK (priority IN ('critical', 'high', 'normal', 'low'));
  END IF;
END $$;

-- 5) Add notes column
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'bed_reservations' AND column_name = 'notes'
  ) THEN
    ALTER TABLE bed_reservations 
      ADD COLUMN notes TEXT;
  END IF;
END $$;

-- 6) Drop the unique constraint that requires referral_id (if it exists)
DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM information_schema.table_constraints
    WHERE table_name = 'bed_reservations' 
    AND constraint_name = 'bed_reservations_unique_active'
  ) THEN
    ALTER TABLE bed_reservations 
      DROP CONSTRAINT bed_reservations_unique_active;
  END IF;
END $$;

-- 7) Create a new partial unique constraint that only applies when referral_id is not null
CREATE UNIQUE INDEX IF NOT EXISTS bed_reservations_unique_active_referral 
  ON bed_reservations(referral_id, status) 
  WHERE referral_id IS NOT NULL AND status = 'active';

-- 8) Update status check constraint to include 'reserved' as an alias for 'active'
ALTER TABLE bed_reservations 
  DROP CONSTRAINT IF EXISTS bed_reservations_status_check;

ALTER TABLE bed_reservations 
  ADD CONSTRAINT bed_reservations_status_check 
  CHECK (status IN ('active', 'reserved', 'completed', 'expired', 'cancelled'));

COMMENT ON TABLE bed_reservations IS 'Temporary bed holds - supports both referral-based and emergency reservations';
