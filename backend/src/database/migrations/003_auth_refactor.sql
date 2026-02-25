-- Migration: Add fields for Password, Security Questions and Google Auth

-- Table: users
ALTER TABLE users
  ADD COLUMN IF NOT EXISTS password_hash VARCHAR(255),
  ADD COLUMN IF NOT EXISTS security_q1 VARCHAR(255),
  ADD COLUMN IF NOT EXISTS security_a1 VARCHAR(255),
  ADD COLUMN IF NOT EXISTS security_q2 VARCHAR(255),
  ADD COLUMN IF NOT EXISTS security_a2 VARCHAR(255),
  ADD COLUMN IF NOT EXISTS google_id VARCHAR(255),
  ADD COLUMN IF NOT EXISTS email VARCHAR(255);

-- Ensure email is unique if provided, but can be null
-- Drop existing constraints if necessary (assuming none or we handle it gracefully here)
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 
    FROM pg_constraint 
    WHERE conname = 'users_email_key'
  ) THEN
    ALTER TABLE users ADD CONSTRAINT users_email_key UNIQUE (email);
  END IF;
END $$;

-- Ensure google_id is unique if provided
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 
    FROM pg_constraint 
    WHERE conname = 'users_google_id_key'
  ) THEN
    ALTER TABLE users ADD CONSTRAINT users_google_id_key UNIQUE (google_id);
  END IF;
END $$;
