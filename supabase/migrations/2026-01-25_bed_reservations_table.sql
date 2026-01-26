-- Migration: Create bed_reservations table for emergency and referral bed reservations
-- Date: 2026-01-25

-- Create bed_reservations table
CREATE TABLE IF NOT EXISTS bed_reservations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    ward_id UUID NOT NULL REFERENCES wards(id) ON DELETE CASCADE,
    reserved_by_auth_user_id UUID NOT NULL REFERENCES auth.users(id),
    reserved_by_name TEXT,
    reservation_type TEXT NOT NULL CHECK (reservation_type IN ('emergency', 'referral', 'scheduled')),
    priority TEXT DEFAULT 'normal' CHECK (priority IN ('critical', 'high', 'normal', 'low')),
    notes TEXT,
    expires_at TIMESTAMPTZ NOT NULL,
    status TEXT DEFAULT 'reserved' CHECK (status IN ('reserved', 'completed', 'cancelled', 'expired')),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create index for faster queries
CREATE INDEX IF NOT EXISTS idx_bed_reservations_status ON bed_reservations(status);
CREATE INDEX IF NOT EXISTS idx_bed_reservations_ward ON bed_reservations(ward_id);
CREATE INDEX IF NOT EXISTS idx_bed_reservations_expires ON bed_reservations(expires_at) WHERE status = 'reserved';

-- Enable RLS
ALTER TABLE bed_reservations ENABLE ROW LEVEL SECURITY;

-- Policy: Authenticated users can view all reservations
CREATE POLICY "Authenticated users can view reservations" ON bed_reservations
    FOR SELECT
    TO authenticated
    USING (true);

-- Policy: Authenticated users can create reservations
CREATE POLICY "Authenticated users can create reservations" ON bed_reservations
    FOR INSERT
    TO authenticated
    WITH CHECK (true);

-- Policy: Users can update their own reservations or admins can update any
CREATE POLICY "Users can update reservations" ON bed_reservations
    FOR UPDATE
    TO authenticated
    USING (
        reserved_by_auth_user_id = auth.uid() 
        OR EXISTS (
            SELECT 1 FROM profiles 
            WHERE profiles.auth_user_id = auth.uid() 
            AND profiles.role IN ('admin', 'superadmin')
        )
    );

-- Policy: Admins can delete reservations
CREATE POLICY "Admins can delete reservations" ON bed_reservations
    FOR DELETE
    TO authenticated
    USING (
        EXISTS (
            SELECT 1 FROM profiles 
            WHERE profiles.auth_user_id = auth.uid() 
            AND profiles.role IN ('admin', 'superadmin')
        )
    );

-- Function to auto-expire reservations
CREATE OR REPLACE FUNCTION expire_old_reservations()
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    expired_reservation RECORD;
BEGIN
    -- Find all expired reservations
    FOR expired_reservation IN 
        SELECT br.id, br.ward_id
        FROM bed_reservations br
        WHERE br.status = 'reserved'
        AND br.expires_at < NOW()
    LOOP
        -- Update reservation status
        UPDATE bed_reservations 
        SET status = 'expired', updated_at = NOW()
        WHERE id = expired_reservation.id;
        
        -- Increment available beds
        UPDATE wards 
        SET available_beds = available_beds + 1
        WHERE id = expired_reservation.ward_id;
    END LOOP;
END;
$$;

-- Comment for documentation
COMMENT ON TABLE bed_reservations IS 'Temporary bed reservations for emergency or referral cases before full admission';
COMMENT ON COLUMN bed_reservations.reservation_type IS 'Type of reservation: emergency (for urgent cases), referral (from another hospital), scheduled (planned admission)';
COMMENT ON COLUMN bed_reservations.priority IS 'Priority level: critical, high, normal, low';
COMMENT ON COLUMN bed_reservations.expires_at IS 'When the reservation expires if not completed';
