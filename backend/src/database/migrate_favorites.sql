-- Create favorites table
CREATE TABLE IF NOT EXISTS favorites (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    item_id VARCHAR(255) NOT NULL, -- UUID for company/trip or custom string
    item_type VARCHAR(50) NOT NULL, -- 'company', 'trip', 'route'
    item_data JSONB, -- Storing extra info for UI (optional)
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, item_id, item_type)
);
