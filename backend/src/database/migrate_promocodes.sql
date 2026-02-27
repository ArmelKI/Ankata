-- Create promo_codes table
CREATE TABLE IF NOT EXISTS promo_codes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    code VARCHAR(50) UNIQUE NOT NULL,
    description TEXT,
    discount_type VARCHAR(20) NOT NULL CHECK (discount_type IN ('percentage', 'fixed')),
    discount_value NUMERIC(10, 2) NOT NULL,
    min_purchase_amount NUMERIC(10, 2) DEFAULT 0,
    max_discount_amount NUMERIC(10, 2),
    valid_from TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    valid_until TIMESTAMP WITH TIME ZONE,
    usage_limit INTEGER,
    usage_count INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Ensure all columns exist and have correct defaults if table was created by an older migration
DO $$ 
BEGIN 
    -- description
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='promo_codes' AND column_name='description') THEN
        ALTER TABLE promo_codes ADD COLUMN description TEXT;
    END IF;

    -- discount_type
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='promo_codes' AND column_name='discount_type') THEN
        ALTER TABLE promo_codes ADD COLUMN discount_type VARCHAR(20) DEFAULT 'percentage' CHECK (discount_type IN ('percentage', 'fixed'));
    ELSE
        ALTER TABLE promo_codes ALTER COLUMN discount_type SET DEFAULT 'percentage';
    END IF;

    -- discount_value
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='promo_codes' AND column_name='discount_value') THEN
        ALTER TABLE promo_codes ADD COLUMN discount_value NUMERIC(10, 2) DEFAULT 0;
    ELSE
        ALTER TABLE promo_codes ALTER COLUMN discount_value SET DEFAULT 0;
    END IF;

    -- min_purchase_amount
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='promo_codes' AND column_name='min_purchase_amount') THEN
        ALTER TABLE promo_codes ADD COLUMN min_purchase_amount NUMERIC(10, 2) DEFAULT 0;
    ELSE
        ALTER TABLE promo_codes ALTER COLUMN min_purchase_amount SET DEFAULT 0;
    END IF;

    -- max_discount_amount
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='promo_codes' AND column_name='max_discount_amount') THEN
        ALTER TABLE promo_codes ADD COLUMN max_discount_amount NUMERIC(10, 2);
    END IF;

    -- valid_from
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='promo_codes' AND column_name='valid_from') THEN
        ALTER TABLE promo_codes ADD COLUMN valid_from TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP;
    ELSE
        ALTER TABLE promo_codes ALTER COLUMN valid_from SET DEFAULT CURRENT_TIMESTAMP;
    END IF;

    -- valid_until
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='promo_codes' AND column_name='valid_until') THEN
        ALTER TABLE promo_codes ADD COLUMN valid_until TIMESTAMP WITH TIME ZONE;
    END IF;

    -- usage_limit
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='promo_codes' AND column_name='usage_limit') THEN
        ALTER TABLE promo_codes ADD COLUMN usage_limit INTEGER;
    END IF;

    -- usage_count
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='promo_codes' AND column_name='usage_count') THEN
        ALTER TABLE promo_codes ADD COLUMN usage_count INTEGER DEFAULT 0;
    ELSE
        ALTER TABLE promo_codes ALTER COLUMN usage_count SET DEFAULT 0;
    END IF;

    -- is_active
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='promo_codes' AND column_name='is_active') THEN
        ALTER TABLE promo_codes ADD COLUMN is_active BOOLEAN DEFAULT TRUE;
    ELSE
        ALTER TABLE promo_codes ALTER COLUMN is_active SET DEFAULT TRUE;
    END IF;

    -- created_at
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='promo_codes' AND column_name='created_at') THEN
        ALTER TABLE promo_codes ADD COLUMN created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP;
    ELSE
        ALTER TABLE promo_codes ALTER COLUMN created_at SET DEFAULT CURRENT_TIMESTAMP;
    END IF;

    -- updated_at
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='promo_codes' AND column_name='updated_at') THEN
        ALTER TABLE promo_codes ADD COLUMN updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP;
    ELSE
        ALTER TABLE promo_codes ALTER COLUMN updated_at SET DEFAULT CURRENT_TIMESTAMP;
    END IF;
END $$;

-- Create promo_code_usage table to track usage per user
CREATE TABLE IF NOT EXISTS promo_code_usage (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    promo_code_id UUID REFERENCES promo_codes(id) ON DELETE CASCADE,
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    booking_id UUID, -- Optional: link to booking
    used_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    discount_applied NUMERIC(10, 2) NOT NULL,
    UNIQUE(promo_code_id, user_id)
);

-- Insert a sample promo code for testing
INSERT INTO promo_codes (code, description, discount_type, discount_value, valid_until)
VALUES ('WELCOME10', '10% off for new users', 'percentage', 10.00, '2026-12-31')
ON CONFLICT (code) DO NOTHING;
