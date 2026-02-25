-- ============================================
-- SUPABASE RLS POLICIES FOR ANKATA
-- ============================================
-- Copy and paste these policies into the Supabase SQL Editor
-- Dashboard: https://app.supabase.com/ → SQL Editor

-- Enable RLS on all tables
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.bookings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.favorites_routes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.ratings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.wallet_transactions ENABLE ROW LEVEL SECURITY;

-- ============================================
-- USERS TABLE POLICIES
-- ============================================

-- Users can only read their own profile
CREATE POLICY "Users can read own profile"
ON public.users FOR SELECT
USING (auth.uid()::text = id::text);

-- Users can only update their own profile
CREATE POLICY "Users can update own profile"
ON public.users FOR UPDATE
USING (auth.uid()::text = id::text)
WITH CHECK (auth.uid()::text = id::text);

-- Service role (backend) can read user data for API operations
CREATE POLICY "Service role can read users"
ON public.users FOR SELECT
TO service_role
USING (true);

-- Service role can update users
CREATE POLICY "Service role can update users"
ON public.users FOR UPDATE
TO service_role
USING (true);

-- ============================================
-- BOOKINGS TABLE POLICIES
-- ============================================

-- Users can only see their own bookings
CREATE POLICY "Users can read own bookings"
ON public.bookings FOR SELECT
USING (auth.uid()::text = user_id::text);

-- Users can create bookings for themselves
CREATE POLICY "Users can create own bookings"
ON public.bookings FOR INSERT
WITH CHECK (auth.uid()::text = user_id::text);

-- Users can update only their own bookings
CREATE POLICY "Users can update own bookings"
ON public.bookings FOR UPDATE
USING (auth.uid()::text = user_id::text)
WITH CHECK (auth.uid()::text = user_id::text);

-- Service role can manage bookings
CREATE POLICY "Service role can manage bookings"
ON public.bookings FOR ALL
TO service_role
USING (true);

-- ============================================
-- FAVORITES ROUTES TABLE POLICIES
-- ============================================

-- Users can read their own favorites
CREATE POLICY "Users can read own favorites"
ON public.favorites_routes FOR SELECT
USING (auth.uid()::text = user_id::text);

-- Users can create their own favorites
CREATE POLICY "Users can create own favorites"
ON public.favorites_routes FOR INSERT
WITH CHECK (auth.uid()::text = user_id::text);

-- Users can delete their own favorites
CREATE POLICY "Users can delete own favorites"
ON public.favorites_routes FOR DELETE
USING (auth.uid()::text = user_id::text);

-- ============================================
-- RATINGS TABLE POLICIES
-- ============================================

-- Users can read all ratings (public)
CREATE POLICY "Users can read ratings"
ON public.ratings FOR SELECT
USING (true);

-- Users can create ratings
CREATE POLICY "Users can create ratings"
ON public.ratings FOR INSERT
WITH CHECK (auth.uid()::text = user_id::text);

-- Users can only update their own ratings
CREATE POLICY "Users can update own ratings"
ON public.ratings FOR UPDATE
USING (auth.uid()::text = user_id::text)
WITH CHECK (auth.uid()::text = user_id::text);

-- ============================================
-- NOTIFICATIONS TABLE POLICIES
-- ============================================

-- Users can read their own notifications
CREATE POLICY "Users can read own notifications"
ON public.notifications FOR SELECT
USING (auth.uid()::text = user_id::text);

-- Service role can create notifications
CREATE POLICY "Service role can create notifications"
ON public.notifications FOR INSERT
TO service_role
USING (true);

-- Users can update (mark as read) their own notifications
CREATE POLICY "Users can update own notifications"
ON public.notifications FOR UPDATE
USING (auth.uid()::text = user_id::text)
WITH CHECK (auth.uid()::text = user_id::text);

-- ============================================
-- WALLET TRANSACTIONS TABLE POLICIES
-- ============================================

-- Users can read their own wallet transactions
CREATE POLICY "Users can read own wallet transactions"
ON public.wallet_transactions FOR SELECT
USING (auth.uid()::text = user_id::text);

-- Service role can create transactions
CREATE POLICY "Service role can create transactions"
ON public.wallet_transactions FOR INSERT
TO service_role
USING (true);

-- ============================================
-- VERIFY RLS IS ENABLED
-- ============================================

-- Run this query to verify RLS status:
-- SELECT schemaname, tablename, rowsecurity 
-- FROM pg_tables 
-- WHERE schemaname = 'public' 
-- AND tablename IN ('users', 'bookings', 'favorites_routes', 'ratings', 'notifications', 'wallet_transactions');

-- ============================================
-- NOTES
-- ============================================
-- 1. auth.uid() returns the Supabase auth user ID
-- 2. For the backend (Node.js), use the service_role key in your HTTP headers
-- 3. Test RLS by querying without auth headers (should fail)
-- 4. Test RLS by querying with different user IDs (should only return own data)
-- 5. Always test RLS policies before deploying to production
