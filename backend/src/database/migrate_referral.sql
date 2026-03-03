-- Migration: Add referral system columns to users table
-- Run this once in Supabase SQL editor

ALTER TABLE users 
  ADD COLUMN IF NOT EXISTS referral_code VARCHAR(10) UNIQUE,
  ADD COLUMN IF NOT EXISTS referred_by UUID REFERENCES users(id) ON DELETE SET NULL,
  ADD COLUMN IF NOT EXISTS wallet_balance INTEGER DEFAULT 0;

-- Generate referral codes for existing users (simple version)
UPDATE users 
SET referral_code = UPPER(SUBSTRING(MD5(id::text || phone_number), 1, 10))
WHERE referral_code IS NULL;

-- Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_users_referral_code ON users(referral_code);
CREATE INDEX IF NOT EXISTS idx_users_referred_by ON users(referred_by);
CREATE INDEX IF NOT EXISTS idx_users_wallet_balance ON users(wallet_balance);
