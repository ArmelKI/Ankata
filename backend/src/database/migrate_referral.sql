-- Migration: Add referral system columns to users table
-- Run this once in Supabase SQL editor

ALTER TABLE users 
  ADD COLUMN IF NOT EXISTS referral_code VARCHAR(10) UNIQUE,
  ADD COLUMN IF NOT EXISTS referred_by VARCHAR(10),
  ADD COLUMN IF NOT EXISTS wallet_balance INTEGER DEFAULT 0;

-- Generate referral codes for existing users (simple version)
UPDATE users 
SET referral_code = UPPER(SUBSTRING(MD5(id::text || phone_number), 1, 8))
WHERE referral_code IS NULL;
