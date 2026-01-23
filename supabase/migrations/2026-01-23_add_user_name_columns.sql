-- Migration: Add first_name and last_name columns to users table
-- Date: 2026-01-23

-- Add first_name column
ALTER TABLE users
ADD COLUMN IF NOT EXISTS first_name text;

-- Add last_name column
ALTER TABLE users
ADD COLUMN IF NOT EXISTS last_name text;

-- Optional: Add index for name-based searches
CREATE INDEX IF NOT EXISTS users_first_name_idx ON users(first_name);
CREATE INDEX IF NOT EXISTS users_last_name_idx ON users(last_name);

-- Comment for documentation
COMMENT ON COLUMN users.first_name IS 'User first name, synced with auth.users.user_metadata';
COMMENT ON COLUMN users.last_name IS 'User last name, synced with auth.users.user_metadata';
