--
-- PostgreSQL database dump
--


-- Dumped from database version 17.8 (Debian 17.8-0+deb13u1)
-- Dumped by pg_dump version 17.8 (Debian 17.8-0+deb13u1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;


--
-- Name: EXTENSION pgcrypto; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';


--
-- Name: unaccent; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS unaccent WITH SCHEMA public;


--
-- Name: EXTENSION unaccent; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION unaccent IS 'text search dictionary that removes accents';


--
-- Name: uuid-ossp; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA public;


--
-- Name: EXTENSION "uuid-ossp"; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';


--
-- Name: update_company_rating(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.update_company_rating() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  UPDATE companies
  SET 
    rating_average = (
      SELECT ROUND(AVG(rating)::numeric, 2)
      FROM ratings 
      WHERE company_id = NEW.company_id AND is_visible = true
    ),
    total_ratings = (
      SELECT COUNT(*) 
      FROM ratings 
      WHERE company_id = NEW.company_id AND is_visible = true
    )
  WHERE id = NEW.company_id;
  RETURN NEW;
END;
$$;


--
-- Name: update_schedule_available_seats(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.update_schedule_available_seats() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  IF (TG_OP = 'INSERT' AND NEW.booking_status IN ('CONFIRMED', 'PENDING')) THEN
    UPDATE schedules
    SET available_seats = available_seats - 1
    WHERE id = NEW.schedule_id;
  ELSIF (TG_OP = 'UPDATE') THEN
    IF (OLD.booking_status IN ('CONFIRMED', 'PENDING') AND NEW.booking_status = 'CANCELLED') THEN
      UPDATE schedules
      SET available_seats = available_seats + 1
      WHERE id = OLD.schedule_id;
    END IF;
  END IF;
  RETURN NEW;
END;
$$;


--
-- Name: update_timestamp(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.update_timestamp() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  NEW.updated_at = CURRENT_TIMESTAMP;
  RETURN NEW;
END;
$$;


--
-- Name: update_updated_at_column(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.update_updated_at_column() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
   NEW.updated_at = NOW();
   RETURN NEW;
END;
$$;


SET default_table_access_method = heap;

--
-- Name: admin_users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.admin_users (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    email character varying(255) NOT NULL,
    password_hash character varying(255) NOT NULL,
    full_name character varying(255),
    role character varying(50) DEFAULT 'admin'::character varying,
    company_id uuid,
    is_active boolean DEFAULT true,
    last_login timestamp without time zone,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


--
-- Name: audit_logs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.audit_logs (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid,
    action character varying(255) NOT NULL,
    entity_type character varying(100),
    entity_id uuid,
    old_values jsonb,
    new_values jsonb,
    ip_address character varying(45),
    user_agent text,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


--
-- Name: bookings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.bookings (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    booking_code character varying(20) NOT NULL,
    user_id uuid NOT NULL,
    schedule_id uuid NOT NULL,
    line_id uuid NOT NULL,
    company_id uuid NOT NULL,
    passenger_name character varying(255) NOT NULL,
    passenger_phone character varying(20),
    departure_date date NOT NULL,
    seat_number character varying(10),
    luggage_weight_kg numeric(6,2) DEFAULT 0,
    base_price numeric(10,2) NOT NULL,
    luggage_fee numeric(10,2) DEFAULT 0,
    total_amount numeric(10,2) NOT NULL,
    payment_method character varying(50),
    payment_status character varying(20) DEFAULT 'pending'::character varying,
    payment_date timestamp without time zone,
    booking_status character varying(20) DEFAULT 'confirmed'::character varying,
    cancellation_reason text,
    cancelled_at timestamp without time zone,
    is_rated boolean DEFAULT false,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


--
-- Name: TABLE bookings; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.bookings IS 'Réservations de billets';


--
-- Name: companies; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.companies (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name character varying(255) NOT NULL,
    slug character varying(255) NOT NULL,
    description text,
    logo_url text,
    primary_color character varying(7),
    secondary_color character varying(7),
    phone character varying(20),
    whatsapp character varying(20),
    facebook_url text,
    headquarters_address text,
    rating_average numeric(3,1) DEFAULT 0.0,
    total_ratings integer DEFAULT 0,
    is_active boolean DEFAULT true,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


--
-- Name: TABLE companies; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.companies IS 'Compagnies de transport (SOTRACO, TSR, STAF, RAHIMO, RAKIETA, TCV, SARAMAYA)';


--
-- Name: lines; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.lines (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    company_id uuid NOT NULL,
    line_code character varying(50) NOT NULL,
    origin_city character varying(100) NOT NULL,
    destination_city character varying(100) NOT NULL,
    origin_name character varying(255),
    destination_name character varying(255),
    origin_latitude numeric(10,8),
    origin_longitude numeric(11,8),
    destination_latitude numeric(10,8),
    destination_longitude numeric(11,8),
    base_price numeric(10,2) NOT NULL,
    currency character varying(3) DEFAULT 'XOF'::character varying,
    luggage_price_per_kg numeric(8,2) DEFAULT 100.00,
    distance_km numeric(8,2),
    estimated_duration_minutes integer,
    is_active boolean DEFAULT true,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


--
-- Name: TABLE lines; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.lines IS 'Lignes de transport urbaines, interurbaines et internationales';


--
-- Name: company_performance; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.company_performance AS
 SELECT c.id,
    c.name,
    c.slug,
    c.rating_average,
    c.total_ratings,
    count(DISTINCT l.id) AS total_lines,
    count(DISTINCT b.id) AS total_bookings,
    sum(
        CASE
            WHEN ((b.booking_status)::text = 'COMPLETED'::text) THEN 1
            ELSE 0
        END) AS completed_trips,
    sum(
        CASE
            WHEN ((b.booking_status)::text = 'CANCELLED'::text) THEN 1
            ELSE 0
        END) AS cancelled_trips
   FROM ((public.companies c
     LEFT JOIN public.lines l ON ((c.id = l.company_id)))
     LEFT JOIN public.bookings b ON ((l.id = b.line_id)))
  WHERE (c.is_active = true)
  GROUP BY c.id, c.name, c.slug, c.rating_average, c.total_ratings;


--
-- Name: loyalty_points; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.loyalty_points (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    total_points integer DEFAULT 0,
    available_points integer DEFAULT 0,
    lifetime_points integer DEFAULT 0,
    last_updated timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


--
-- Name: loyalty_transactions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.loyalty_transactions (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    booking_id uuid,
    points_amount integer NOT NULL,
    transaction_type character varying(50) NOT NULL,
    description text,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


--
-- Name: notifications; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.notifications (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    user_id uuid NOT NULL,
    booking_id uuid,
    title character varying(200) NOT NULL,
    message text NOT NULL,
    notification_type character varying(50) NOT NULL,
    is_read boolean DEFAULT false,
    read_at timestamp without time zone,
    action_url text,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


--
-- Name: otp_codes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.otp_codes (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    phone_number character varying(20) NOT NULL,
    otp_code character varying(6) NOT NULL,
    purpose character varying(50) NOT NULL,
    is_verified boolean DEFAULT false,
    attempts integer DEFAULT 0,
    expires_at timestamp without time zone NOT NULL,
    verified_at timestamp without time zone,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT otp_codes_purpose_check CHECK (((purpose)::text = ANY ((ARRAY['REGISTRATION'::character varying, 'LOGIN'::character varying, 'PASSWORD_RESET'::character varying, 'PHONE_VERIFICATION'::character varying])::text[])))
);


--
-- Name: otp_verifications; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.otp_verifications (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    phone_number character varying(20) NOT NULL,
    otp_code character varying(6) NOT NULL,
    attempts integer DEFAULT 0,
    max_attempts integer DEFAULT 3,
    is_verified boolean DEFAULT false,
    verified_at timestamp without time zone,
    expires_at timestamp without time zone NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


--
-- Name: payments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.payments (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    booking_id uuid NOT NULL,
    user_id uuid NOT NULL,
    amount numeric(10,2) NOT NULL,
    currency character varying(3) DEFAULT 'XOF'::character varying,
    payment_method character varying(50) NOT NULL,
    payment_gateway character varying(50),
    transaction_id character varying(255),
    provider_reference character varying(255),
    status character varying(20) DEFAULT 'pending'::character varying,
    error_message text,
    metadata jsonb,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


--
-- Name: TABLE payments; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.payments IS 'Historique des paiements';


--
-- Name: promo_codes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.promo_codes (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    code character varying(50) NOT NULL,
    company_id uuid,
    discount_percentage numeric(5,2),
    discount_amount numeric(10,2),
    max_uses integer,
    current_uses integer DEFAULT 0,
    valid_from date NOT NULL,
    valid_until date NOT NULL,
    is_active boolean DEFAULT true,
    created_by uuid,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


--
-- Name: ratings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ratings (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    booking_id uuid,
    user_id uuid NOT NULL,
    company_id uuid NOT NULL,
    line_id uuid NOT NULL,
    rating integer NOT NULL,
    punctuality_rating integer,
    comfort_rating integer,
    staff_rating integer,
    cleanliness_rating integer,
    comment text,
    is_verified boolean DEFAULT false,
    verification_date timestamp without time zone,
    helpful_count integer DEFAULT 0,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT ratings_cleanliness_rating_check CHECK (((cleanliness_rating >= 1) AND (cleanliness_rating <= 5))),
    CONSTRAINT ratings_comfort_rating_check CHECK (((comfort_rating >= 1) AND (comfort_rating <= 5))),
    CONSTRAINT ratings_punctuality_rating_check CHECK (((punctuality_rating >= 1) AND (punctuality_rating <= 5))),
    CONSTRAINT ratings_rating_check CHECK (((rating >= 1) AND (rating <= 5))),
    CONSTRAINT ratings_staff_rating_check CHECK (((staff_rating >= 1) AND (staff_rating <= 5)))
);


--
-- Name: TABLE ratings; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.ratings IS 'Évaluations des trajets par les utilisateurs';


--
-- Name: schedules; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schedules (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    line_id uuid NOT NULL,
    departure_time time without time zone NOT NULL,
    days_of_week integer[] DEFAULT ARRAY[1, 2, 3, 4, 5, 6, 7],
    total_seats integer DEFAULT 60 NOT NULL,
    available_seats integer DEFAULT 60 NOT NULL,
    valid_from date NOT NULL,
    valid_until date NOT NULL,
    is_active boolean DEFAULT true,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    arrival_time time without time zone
);


--
-- Name: TABLE schedules; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.schedules IS 'Horaires de départ des lignes';


--
-- Name: stops; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.stops (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    line_id uuid NOT NULL,
    stop_order integer NOT NULL,
    city_name character varying(100) NOT NULL,
    stop_name character varying(255),
    latitude numeric(10,8),
    longitude numeric(11,8),
    stop_address text,
    is_pickup_point boolean DEFAULT true,
    is_dropoff_point boolean DEFAULT true,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


--
-- Name: TABLE stops; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.stops IS 'Arrêts de bus et gares routières';


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    phone_number character varying(20) NOT NULL,
    country_code character varying(5) DEFAULT '+226'::character varying,
    profile_picture_url text,
    is_verified boolean DEFAULT false,
    verification_date timestamp without time zone,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    last_login timestamp without time zone,
    first_name character varying(255),
    last_name character varying(255),
    date_of_birth date,
    cnib character varying(50),
    gender character varying(10),
    password_hash character varying(255),
    security_q1 character varying(255),
    security_a1 character varying(255),
    security_q2 character varying(255),
    security_a2 character varying(255),
    google_id character varying(255),
    email character varying(255)
);


--
-- Name: admin_users admin_users_email_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.admin_users
    ADD CONSTRAINT admin_users_email_key UNIQUE (email);


--
-- Name: admin_users admin_users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.admin_users
    ADD CONSTRAINT admin_users_pkey PRIMARY KEY (id);


--
-- Name: audit_logs audit_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.audit_logs
    ADD CONSTRAINT audit_logs_pkey PRIMARY KEY (id);


--
-- Name: bookings bookings_booking_code_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookings
    ADD CONSTRAINT bookings_booking_code_key UNIQUE (booking_code);


--
-- Name: bookings bookings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookings
    ADD CONSTRAINT bookings_pkey PRIMARY KEY (id);


--
-- Name: companies companies_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.companies
    ADD CONSTRAINT companies_pkey PRIMARY KEY (id);


--
-- Name: companies companies_slug_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.companies
    ADD CONSTRAINT companies_slug_key UNIQUE (slug);


--
-- Name: lines lines_line_code_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lines
    ADD CONSTRAINT lines_line_code_key UNIQUE (line_code);


--
-- Name: lines lines_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lines
    ADD CONSTRAINT lines_pkey PRIMARY KEY (id);


--
-- Name: loyalty_points loyalty_points_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.loyalty_points
    ADD CONSTRAINT loyalty_points_pkey PRIMARY KEY (id);


--
-- Name: loyalty_points loyalty_points_user_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.loyalty_points
    ADD CONSTRAINT loyalty_points_user_id_key UNIQUE (user_id);


--
-- Name: loyalty_transactions loyalty_transactions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.loyalty_transactions
    ADD CONSTRAINT loyalty_transactions_pkey PRIMARY KEY (id);


--
-- Name: notifications notifications_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_pkey PRIMARY KEY (id);


--
-- Name: otp_codes otp_codes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.otp_codes
    ADD CONSTRAINT otp_codes_pkey PRIMARY KEY (id);


--
-- Name: otp_verifications otp_verifications_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.otp_verifications
    ADD CONSTRAINT otp_verifications_pkey PRIMARY KEY (id);


--
-- Name: payments payments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.payments
    ADD CONSTRAINT payments_pkey PRIMARY KEY (id);


--
-- Name: payments payments_transaction_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.payments
    ADD CONSTRAINT payments_transaction_id_key UNIQUE (transaction_id);


--
-- Name: promo_codes promo_codes_code_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.promo_codes
    ADD CONSTRAINT promo_codes_code_key UNIQUE (code);


--
-- Name: promo_codes promo_codes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.promo_codes
    ADD CONSTRAINT promo_codes_pkey PRIMARY KEY (id);


--
-- Name: ratings ratings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ratings
    ADD CONSTRAINT ratings_pkey PRIMARY KEY (id);


--
-- Name: schedules schedules_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schedules
    ADD CONSTRAINT schedules_pkey PRIMARY KEY (id);


--
-- Name: stops stops_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stops
    ADD CONSTRAINT stops_pkey PRIMARY KEY (id);


--
-- Name: users users_email_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key UNIQUE (email);


--
-- Name: users users_google_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_google_id_key UNIQUE (google_id);


--
-- Name: users users_phone_number_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_phone_number_key UNIQUE (phone_number);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: idx_bookings_code; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_bookings_code ON public.bookings USING btree (booking_code);


--
-- Name: idx_bookings_line; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_bookings_line ON public.bookings USING btree (line_id);


--
-- Name: idx_bookings_schedule_date; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_bookings_schedule_date ON public.bookings USING btree (schedule_id, departure_date);


--
-- Name: idx_bookings_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_bookings_status ON public.bookings USING btree (booking_status);


--
-- Name: idx_bookings_user; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_bookings_user ON public.bookings USING btree (user_id);


--
-- Name: idx_bookings_user_date; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_bookings_user_date ON public.bookings USING btree (user_id, departure_date);


--
-- Name: idx_companies_active; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_companies_active ON public.companies USING btree (is_active);


--
-- Name: idx_companies_rating; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_companies_rating ON public.companies USING btree (rating_average DESC);


--
-- Name: idx_companies_slug; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_companies_slug ON public.companies USING btree (slug);


--
-- Name: idx_lines_active; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_lines_active ON public.lines USING btree (is_active);


--
-- Name: idx_lines_cities; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_lines_cities ON public.lines USING btree (origin_city, destination_city);


--
-- Name: idx_lines_code; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_lines_code ON public.lines USING btree (line_code);


--
-- Name: idx_lines_company; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_lines_company ON public.lines USING btree (company_id);


--
-- Name: idx_lines_company_route; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_lines_company_route ON public.lines USING btree (company_id, origin_city, destination_city);


--
-- Name: idx_loyalty_transactions_user; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_loyalty_transactions_user ON public.loyalty_transactions USING btree (user_id);


--
-- Name: idx_notifications_read; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_notifications_read ON public.notifications USING btree (is_read);


--
-- Name: idx_notifications_user; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_notifications_user ON public.notifications USING btree (user_id);


--
-- Name: idx_otp_expires; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_otp_expires ON public.otp_codes USING btree (expires_at);


--
-- Name: idx_otp_phone; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_otp_phone ON public.otp_codes USING btree (phone_number);


--
-- Name: idx_payments_booking; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_payments_booking ON public.payments USING btree (booking_id);


--
-- Name: idx_payments_transaction; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_payments_transaction ON public.payments USING btree (transaction_id);


--
-- Name: idx_payments_user; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_payments_user ON public.payments USING btree (user_id);


--
-- Name: idx_promo_codes_active; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_promo_codes_active ON public.promo_codes USING btree (is_active);


--
-- Name: idx_promo_codes_code; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_promo_codes_code ON public.promo_codes USING btree (code);


--
-- Name: idx_ratings_company; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_ratings_company ON public.ratings USING btree (company_id);


--
-- Name: idx_ratings_date; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_ratings_date ON public.ratings USING btree (created_at);


--
-- Name: idx_ratings_line; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_ratings_line ON public.ratings USING btree (line_id);


--
-- Name: idx_ratings_user; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_ratings_user ON public.ratings USING btree (user_id);


--
-- Name: idx_schedules_active; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_schedules_active ON public.schedules USING btree (is_active);


--
-- Name: idx_schedules_departure; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_schedules_departure ON public.schedules USING btree (departure_time);


--
-- Name: idx_schedules_line; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_schedules_line ON public.schedules USING btree (line_id);


--
-- Name: idx_schedules_line_date; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_schedules_line_date ON public.schedules USING btree (line_id, valid_from, valid_until);


--
-- Name: idx_users_phone; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_users_phone ON public.users USING btree (phone_number);


--
-- Name: bookings bookings_update_timestamp; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER bookings_update_timestamp BEFORE UPDATE ON public.bookings FOR EACH ROW EXECUTE FUNCTION public.update_timestamp();


--
-- Name: companies companies_update_timestamp; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER companies_update_timestamp BEFORE UPDATE ON public.companies FOR EACH ROW EXECUTE FUNCTION public.update_timestamp();


--
-- Name: lines lines_update_timestamp; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER lines_update_timestamp BEFORE UPDATE ON public.lines FOR EACH ROW EXECUTE FUNCTION public.update_timestamp();


--
-- Name: payments payments_update_timestamp; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER payments_update_timestamp BEFORE UPDATE ON public.payments FOR EACH ROW EXECUTE FUNCTION public.update_timestamp();


--
-- Name: ratings ratings_update_timestamp; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER ratings_update_timestamp BEFORE UPDATE ON public.ratings FOR EACH ROW EXECUTE FUNCTION public.update_timestamp();


--
-- Name: schedules schedules_update_timestamp; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER schedules_update_timestamp BEFORE UPDATE ON public.schedules FOR EACH ROW EXECUTE FUNCTION public.update_timestamp();


--
-- Name: bookings update_bookings_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER update_bookings_updated_at BEFORE UPDATE ON public.bookings FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: companies update_companies_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER update_companies_updated_at BEFORE UPDATE ON public.companies FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: lines update_lines_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER update_lines_updated_at BEFORE UPDATE ON public.lines FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: payments update_payments_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER update_payments_updated_at BEFORE UPDATE ON public.payments FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: ratings update_rating_on_insert; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER update_rating_on_insert AFTER INSERT OR UPDATE ON public.ratings FOR EACH ROW EXECUTE FUNCTION public.update_company_rating();


--
-- Name: ratings update_ratings_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER update_ratings_updated_at BEFORE UPDATE ON public.ratings FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: schedules update_schedules_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER update_schedules_updated_at BEFORE UPDATE ON public.schedules FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: bookings update_seats_on_booking; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER update_seats_on_booking AFTER INSERT OR UPDATE ON public.bookings FOR EACH ROW EXECUTE FUNCTION public.update_schedule_available_seats();


--
-- Name: users update_users_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON public.users FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: users users_update_timestamp; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER users_update_timestamp BEFORE UPDATE ON public.users FOR EACH ROW EXECUTE FUNCTION public.update_timestamp();


--
-- Name: admin_users admin_users_company_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.admin_users
    ADD CONSTRAINT admin_users_company_id_fkey FOREIGN KEY (company_id) REFERENCES public.companies(id) ON DELETE SET NULL;


--
-- Name: audit_logs audit_logs_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.audit_logs
    ADD CONSTRAINT audit_logs_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: bookings bookings_company_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookings
    ADD CONSTRAINT bookings_company_id_fkey FOREIGN KEY (company_id) REFERENCES public.companies(id);


--
-- Name: bookings bookings_line_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookings
    ADD CONSTRAINT bookings_line_id_fkey FOREIGN KEY (line_id) REFERENCES public.lines(id) ON DELETE CASCADE;


--
-- Name: bookings bookings_schedule_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookings
    ADD CONSTRAINT bookings_schedule_id_fkey FOREIGN KEY (schedule_id) REFERENCES public.schedules(id) ON DELETE CASCADE;


--
-- Name: bookings bookings_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookings
    ADD CONSTRAINT bookings_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: lines lines_company_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lines
    ADD CONSTRAINT lines_company_id_fkey FOREIGN KEY (company_id) REFERENCES public.companies(id) ON DELETE CASCADE;


--
-- Name: loyalty_points loyalty_points_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.loyalty_points
    ADD CONSTRAINT loyalty_points_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: loyalty_transactions loyalty_transactions_booking_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.loyalty_transactions
    ADD CONSTRAINT loyalty_transactions_booking_id_fkey FOREIGN KEY (booking_id) REFERENCES public.bookings(id) ON DELETE SET NULL;


--
-- Name: loyalty_transactions loyalty_transactions_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.loyalty_transactions
    ADD CONSTRAINT loyalty_transactions_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: notifications notifications_booking_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_booking_id_fkey FOREIGN KEY (booking_id) REFERENCES public.bookings(id);


--
-- Name: notifications notifications_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: payments payments_booking_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.payments
    ADD CONSTRAINT payments_booking_id_fkey FOREIGN KEY (booking_id) REFERENCES public.bookings(id) ON DELETE CASCADE;


--
-- Name: payments payments_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.payments
    ADD CONSTRAINT payments_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: promo_codes promo_codes_company_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.promo_codes
    ADD CONSTRAINT promo_codes_company_id_fkey FOREIGN KEY (company_id) REFERENCES public.companies(id) ON DELETE SET NULL;


--
-- Name: ratings ratings_booking_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ratings
    ADD CONSTRAINT ratings_booking_id_fkey FOREIGN KEY (booking_id) REFERENCES public.bookings(id) ON DELETE SET NULL;


--
-- Name: ratings ratings_company_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ratings
    ADD CONSTRAINT ratings_company_id_fkey FOREIGN KEY (company_id) REFERENCES public.companies(id) ON DELETE CASCADE;


--
-- Name: ratings ratings_line_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ratings
    ADD CONSTRAINT ratings_line_id_fkey FOREIGN KEY (line_id) REFERENCES public.lines(id) ON DELETE CASCADE;


--
-- Name: ratings ratings_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ratings
    ADD CONSTRAINT ratings_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: schedules schedules_line_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schedules
    ADD CONSTRAINT schedules_line_id_fkey FOREIGN KEY (line_id) REFERENCES public.lines(id) ON DELETE CASCADE;


--
-- Name: stops stops_line_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stops
    ADD CONSTRAINT stops_line_id_fkey FOREIGN KEY (line_id) REFERENCES public.lines(id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--


