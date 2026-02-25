-- Migration: Add missing user profile fields

ALTER TABLE users
  ADD COLUMN IF NOT EXISTS first_name VARCHAR(100),
  ADD COLUMN IF NOT EXISTS last_name VARCHAR(100),
  ADD COLUMN IF NOT EXISTS cnib VARCHAR(50),
  ADD COLUMN IF NOT EXISTS city VARCHAR(100);

-- Backfill full_name into first/last when possible
UPDATE users
SET first_name = COALESCE(first_name, split_part(full_name, ' ', 1)),
    last_name = COALESCE(last_name, NULLIF(trim(replace(full_name, split_part(full_name, ' ', 1), '')), ''))
WHERE full_name IS NOT NULL AND (first_name IS NULL OR last_name IS NULL);
