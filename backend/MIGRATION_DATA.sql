--
-- PostgreSQL database dump
--

\restrict qO18A1KdJfqoqlNWwKwEyeM7KIxdtTcUIwLJhouL0Y0XLFpF6ocPpQ7T0qyBC43

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
-- Data for Name: admin_users; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.admin_users (id, email, password_hash, full_name, role, company_id, is_active, last_login, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: audit_logs; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.audit_logs (id, user_id, action, entity_type, entity_id, old_values, new_values, ip_address, user_agent, created_at) FROM stdin;
\.


--
-- Data for Name: bookings; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.bookings (id, booking_code, user_id, schedule_id, line_id, company_id, passenger_name, passenger_phone, departure_date, seat_number, luggage_weight_kg, base_price, luggage_fee, total_amount, payment_method, payment_status, payment_date, booking_status, cancellation_reason, cancelled_at, is_rated, created_at, updated_at) FROM stdin;
41681a8b-23a1-4af5-a52a-ee4833a5430c	64012419	05050b67-9989-45a1-90c1-ab152ed811b4	eb529c37-bbf5-4645-9e55-9d9279b99578	ca14a121-b8af-48d7-93e7-c3e2c96c7947	4b65926a-d4ef-4317-9f0a-99af26fd68fb	Test User	+22670000000	2026-02-25	A1	0.00	4500.00	0.00	4700.00	pending	pending	\N	confirmed	\N	\N	f	2026-02-25 21:17:31.890053	2026-02-25 21:17:31.890053
a619930a-f9ab-4eec-8f89-fa87e356ad71	54422394	88b7e52b-8fae-4eea-91b2-ea4d6712dcb6	c85895db-b37e-49da-83ec-b5674eda83b2	b0cc5c8e-3ece-4401-975f-e9cd3e04cca4	cdfeaa05-abf4-418d-ac7e-c334d17de8bd	Armel KI	57634040	2026-02-26	A1	0.00	6500.00	0.00	6700.00	pending	pending	\N	confirmed	\N	\N	f	2026-02-25 22:00:11.268407	2026-02-25 22:00:11.268407
7bc778d3-5c28-4f77-93de-51a2976590e6	84014986	88b7e52b-8fae-4eea-91b2-ea4d6712dcb6	c85895db-b37e-49da-83ec-b5674eda83b2	b0cc5c8e-3ece-4401-975f-e9cd3e04cca4	cdfeaa05-abf4-418d-ac7e-c334d17de8bd	Armel KI	57634040	2026-02-26	A1	0.00	6500.00	0.00	6700.00	pending	pending	\N	confirmed	\N	\N	f	2026-02-25 22:00:24.049491	2026-02-25 22:00:24.049491
\.


--
-- Data for Name: companies; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.companies (id, name, slug, description, logo_url, primary_color, secondary_color, phone, whatsapp, facebook_url, headquarters_address, rating_average, total_ratings, is_active, created_at, updated_at) FROM stdin;
cdfeaa05-abf4-418d-ac7e-c334d17de8bd	RAHIMO	rahimo	RAHIMO Transports - Compagnie interurbaine et internationale, entrée récente sur le marché burkinabè	assets/images/companies/rahimo.png	#DC143C	\N	+226 25 36 78 90	\N	\N	Avenue Charles de Gaulle, Ouagadougou, Burkina Faso	4.4	432	t	2026-02-23 18:00:42.401153	2026-02-25 22:26:45.786649
eebd8b5f-e501-4556-b69a-46e692008554	TCV	tcv	Transport Confort Voyageurs - Compagnie interurbaine et internationale basée à Ouagadougou	assets/images/companies/tcv.png	#006400	\N	+226 25 31 67 89	\N	\N	Quartier Gounghin, Ouagadougou, Burkina Faso	4.3	521	t	2026-02-23 18:00:42.401153	2026-02-25 22:26:45.786649
70fec438-a155-47c0-adfa-d258f5dbbae3	SARAMAYA	saramaya	Saramaya Transport - Compagnie interurbaine basée à Bobo-Dioulasso, réputée fiable par les guides de voyage	assets/images/companies/saramaya.png	#0044AA	\N	\N	\N	\N	Quartier Tounouma, Bobo-Dioulasso	4.0	125	t	2026-02-23 18:40:21.830783	2026-02-25 22:26:45.786649
01a56461-6017-4c43-9300-a81aecbaca32	Elitis Express	elitis	Elitis Express - Service express sur la ligne Ouaga-Bobo avec départs fréquents et service nocturne en weekend	assets/images/elitis_logo.png	#9C27B0	\N	+226 71 00 00 00	\N	\N	Gare Elitis, Ouagadougou	4.5	234	t	2026-02-25 20:25:19.540159	2026-02-25 22:26:45.786649
647da5f0-e823-47d4-8f2e-e13fe2bb58c8	CTKE WAYS	ctke	CTKE WAYS - Spécialiste des liaisons internationales vers Lomé et Cotonou depuis Ouagadougou et Bobo-Dioulasso	assets/images/ctke_logo.png	#00BCD4	\N	+226 72 00 00 00	\N	\N	Gare CTKE, Ouagadougou	4.2	167	t	2026-02-25 20:25:19.540159	2026-02-25 22:26:45.786649
9b075bbc-6ae7-45bf-ac2b-b817f03e84f7	FTS	fts	FTS - Compagnie de transport national et international, service VIP disponible sur plusieurs lignes	assets/images/fts_logo.png	#FF5722	\N	+226 73 00 00 00	\N	\N	Quartier Dassasgho, Ouagadougou	4.1	198	t	2026-02-25 20:25:19.540159	2026-02-25 22:26:45.786649
4b65926a-d4ef-4317-9f0a-99af26fd68fb	SOTRACO	sotraco	Société de Transport en Commun de Ouagadougou - Leader du transport urbain au Burkina Faso avec 18 lignes et 329 arrêts à Ouagadougou	assets/images/companies/sotraco.png	#00A859	\N	+226 25 31 23 45	\N	\N	Avenue de l'Indépendance, Ouagadougou, Burkina Faso	4.5	2847	t	2026-02-23 18:00:42.401153	2026-02-25 22:26:45.786649
52e6f3ee-6ee5-41c3-83c8-4563532cf791	TSR	tsr	Transport Sana Rasmané - Une des compagnies majeures du transport interurbain et international au Burkina Faso	assets/images/companies/tsr.png	#1E90FF	\N	+226 25 33 45 67	\N	\N	Secteur 12, Ouagadougou, Burkina Faso	4.3	856	t	2026-02-23 18:00:42.401153	2026-02-25 22:26:45.786649
7f849e9b-22a1-4356-a1af-1ce1ca6cdc89	STAF	staf	Société de Transport Aorèma et Frères - Compagnie interurbaine basée à Bobo-Dioulasso, leader sur le marché national	assets/images/companies/staf.png	#FF6B00	\N	+226 20 97 12 34	\N	\N	Boulevard de la Révolution, Bobo-Dioulasso, Burkina Faso	4.2	654	t	2026-02-23 18:00:42.401153	2026-02-25 22:26:45.786649
a59ff95c-2c97-46d6-8396-c2fb6c570b11	RAKIETA	rakieta	CTT RAKIETA - Compagnie de transport interurbain et international desservant de nombreuses villes au Burkina et en Afrique de l'Ouest	assets/images/companies/rakieta.png	#8B0000	\N	+226 20 98 45 12	\N	\N	Route de Koudougou, Ouagadougou, Burkina Faso	4.1	389	t	2026-02-23 18:00:42.401153	2026-02-25 22:26:45.786649
\.


--
-- Data for Name: lines; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.lines (id, company_id, line_code, origin_city, destination_city, origin_name, destination_name, origin_latitude, origin_longitude, destination_latitude, destination_longitude, base_price, currency, luggage_price_per_kg, distance_km, estimated_duration_minutes, is_active, created_at, updated_at) FROM stdin;
ca14a121-b8af-48d7-93e7-c3e2c96c7947	4b65926a-d4ef-4317-9f0a-99af26fd68fb	OG-BB-01	Ouagadougou	Bobo-Dioulasso	\N	\N	\N	\N	\N	\N	4500.00	XOF	100.00	365.00	300	t	2026-02-23 18:00:42.401153	2026-02-23 18:40:21.830783
ad81be83-f641-4672-a650-14cffbba2f53	4b65926a-d4ef-4317-9f0a-99af26fd68fb	BB-OG-01	Bobo-Dioulasso	Ouagadougou	\N	\N	\N	\N	\N	\N	4500.00	XOF	100.00	365.00	300	t	2026-02-23 18:00:42.401153	2026-02-23 18:40:21.830783
e3a8e68b-2bcf-44c1-9ef0-7bb5f7f37338	4b65926a-d4ef-4317-9f0a-99af26fd68fb	OG-FD-01	Ouagadougou	Fada N'Gourma	\N	\N	\N	\N	\N	\N	3500.00	XOF	100.00	219.00	210	t	2026-02-23 18:00:42.401153	2026-02-23 18:40:21.830783
bf67fac7-1225-4ee9-9812-caca7b62b4d7	4b65926a-d4ef-4317-9f0a-99af26fd68fb	OG-KD-01	Ouagadougou	Koudougou	\N	\N	\N	\N	\N	\N	2000.00	XOF	100.00	97.00	90	t	2026-02-23 18:00:42.401153	2026-02-23 18:40:21.830783
1bb0272f-54eb-4092-9342-8b946e8788a0	4b65926a-d4ef-4317-9f0a-99af26fd68fb	L1	Ouagadougou	Ouagadougou	\N	\N	\N	\N	\N	\N	200.00	XOF	100.00	10.00	35	t	2026-02-23 18:40:21.830783	2026-02-25 22:26:45.786649
6e8d0c7b-ca14-4330-9fc4-0ef0eefdf7e9	4b65926a-d4ef-4317-9f0a-99af26fd68fb	L2	Ouagadougou	Ouagadougou	\N	\N	\N	\N	\N	\N	200.00	XOF	100.00	11.00	38	t	2026-02-23 18:40:21.830783	2026-02-25 22:26:45.786649
8d18a350-61e1-47d5-a4fb-bde2f07affd9	4b65926a-d4ef-4317-9f0a-99af26fd68fb	L2B	Ouagadougou	Ouagadougou	\N	\N	\N	\N	\N	\N	200.00	XOF	100.00	12.00	45	t	2026-02-23 18:00:42.401153	2026-02-25 22:26:45.786649
861b502e-e565-4c7d-9af0-096fba747ed8	4b65926a-d4ef-4317-9f0a-99af26fd68fb	L3	Ouagadougou	Ouagadougou	\N	\N	\N	\N	\N	\N	200.00	XOF	100.00	15.00	50	t	2026-02-23 18:00:42.401153	2026-02-25 22:26:45.786649
88b96b8c-f1c0-479d-8692-160662dc6181	4b65926a-d4ef-4317-9f0a-99af26fd68fb	L4	Ouagadougou	Ouagadougou	\N	\N	\N	\N	\N	\N	200.00	XOF	100.00	10.00	40	t	2026-02-23 18:00:42.401153	2026-02-25 22:26:45.786649
466fa3e2-ad68-4bfb-a51e-58f603e24168	4b65926a-d4ef-4317-9f0a-99af26fd68fb	L5	Ouagadougou	Ouagadougou	\N	\N	\N	\N	\N	\N	200.00	XOF	100.00	13.00	45	t	2026-02-23 18:40:21.830783	2026-02-25 22:26:45.786649
d2c670a8-b0ea-4618-986a-84a61e328ecb	4b65926a-d4ef-4317-9f0a-99af26fd68fb	L6	Ouagadougou	Ouagadougou	\N	\N	\N	\N	\N	\N	200.00	XOF	100.00	11.00	40	t	2026-02-23 18:40:21.830783	2026-02-25 22:26:45.786649
c10eaedf-3e18-4d98-b473-783ddd4b22a6	4b65926a-d4ef-4317-9f0a-99af26fd68fb	L6B	Ouagadougou	Ouagadougou	\N	\N	\N	\N	\N	\N	200.00	XOF	100.00	15.00	50	t	2026-02-23 18:40:21.830783	2026-02-25 22:26:45.786649
d594417c-236d-43be-9b5e-6866e3ac2cf2	4b65926a-d4ef-4317-9f0a-99af26fd68fb	L10	Ouagadougou	Ouagadougou	\N	\N	\N	\N	\N	\N	200.00	XOF	100.00	8.00	30	t	2026-02-23 18:00:42.401153	2026-02-25 22:26:45.786649
1a5b903f-8f8a-4003-9458-b83e5c352dbe	4b65926a-d4ef-4317-9f0a-99af26fd68fb	L11	Ouagadougou	Ouagadougou	\N	\N	\N	\N	\N	\N	200.00	XOF	100.00	12.00	43	t	2026-02-23 18:40:21.830783	2026-02-25 22:26:45.786649
3f24fd5c-6801-4652-a50a-f592709b8377	4b65926a-d4ef-4317-9f0a-99af26fd68fb	L12	Ouagadougou	Ouagadougou	\N	\N	\N	\N	\N	\N	200.00	XOF	100.00	11.00	40	t	2026-02-23 18:40:21.830783	2026-02-25 22:26:45.786649
5937ba7c-f259-4959-946f-054d6c7ca617	4b65926a-d4ef-4317-9f0a-99af26fd68fb	L13	Ouagadougou	Ouagadougou	\N	\N	\N	\N	\N	\N	200.00	XOF	100.00	13.00	46	t	2026-02-23 18:40:21.830783	2026-02-25 22:26:45.786649
0c7e0feb-410d-46c3-8889-b7b29eb1754c	4b65926a-d4ef-4317-9f0a-99af26fd68fb	L14	Ouagadougou	Ouagadougou	\N	\N	\N	\N	\N	\N	200.00	XOF	100.00	12.00	44	t	2026-02-23 18:40:21.830783	2026-02-25 22:26:45.786649
f0fb030d-6e30-4be2-88e2-dbb371667820	4b65926a-d4ef-4317-9f0a-99af26fd68fb	L15	Ouagadougou	Ouagadougou	\N	\N	\N	\N	\N	\N	200.00	XOF	100.00	16.00	52	t	2026-02-23 18:40:21.830783	2026-02-25 22:26:45.786649
b5155823-d5e7-4e4a-a700-58921b9048ee	4b65926a-d4ef-4317-9f0a-99af26fd68fb	L16	Ouagadougou	Ouagadougou	\N	\N	\N	\N	\N	\N	200.00	XOF	100.00	15.00	50	t	2026-02-23 18:40:21.830783	2026-02-25 22:26:45.786649
2adf02e6-d332-4bd4-91ad-df8b4388299e	4b65926a-d4ef-4317-9f0a-99af26fd68fb	L17	Ouagadougou	Ouagadougou	\N	\N	\N	\N	\N	\N	200.00	XOF	100.00	9.00	34	t	2026-02-23 18:40:21.830783	2026-02-25 22:26:45.786649
302d8a81-235d-4e5d-be15-0b00a9c34d49	4b65926a-d4ef-4317-9f0a-99af26fd68fb	L18	Ouagadougou	Ouagadougou	\N	\N	\N	\N	\N	\N	200.00	XOF	100.00	14.00	48	t	2026-02-23 18:40:21.830783	2026-02-25 22:26:45.786649
92b34d4e-da8c-4ed9-8d64-3a07dedb88f7	52e6f3ee-6ee5-41c3-83c8-4563532cf791	TSR-BB-01	Ouagadougou	Bobo-Dioulasso	\N	\N	\N	\N	\N	\N	4500.00	XOF	100.00	365.00	280	t	2026-02-23 18:00:42.401153	2026-02-25 22:26:45.786649
4d11e3fc-36e7-441a-9b2c-b0e592458e19	7f849e9b-22a1-4356-a1af-1ce1ca6cdc89	STAF-OB	Ouagadougou	Bobo-Dioulasso	\N	\N	\N	\N	\N	\N	5000.00	XOF	100.00	365.00	290	t	2026-02-23 18:00:42.401153	2026-02-25 22:26:45.786649
cd95aa15-480f-42a0-a863-60f2896814fb	cdfeaa05-abf4-418d-ac7e-c334d17de8bd	RH-PREMIUM-BB	Ouagadougou	Bobo-Dioulasso	\N	\N	\N	\N	\N	\N	6500.00	XOF	100.00	365.00	270	t	2026-02-23 18:00:42.401153	2026-02-25 22:26:45.786649
61565c46-d1ee-4c1a-b043-184dc10db348	a59ff95c-2c97-46d6-8396-c2fb6c570b11	RAK-OB	Ouagadougou	Bobo-Dioulasso	\N	\N	\N	\N	\N	\N	7500.00	XOF	100.00	365.00	310	t	2026-02-23 18:00:42.401153	2026-02-25 22:26:45.786649
fd593275-8d4d-430f-9754-fbc48499a44c	eebd8b5f-e501-4556-b69a-46e692008554	TCV-BB	Ouagadougou	Bobo-Dioulasso	\N	\N	\N	\N	\N	\N	5000.00	XOF	100.00	365.00	295	t	2026-02-23 18:00:42.401153	2026-02-25 22:26:45.786649
5b61af63-d3ec-4915-baf5-fcd3e897de9a	52e6f3ee-6ee5-41c3-83c8-4563532cf791	OUA-BOB-TSR	Ouagadougou	Bobo-Dioulasso	Gare TSR Ouaga	Gare TSR Bobo	\N	\N	\N	\N	4500.00	XOF	100.00	360.00	330	t	2026-02-25 16:25:01.804322	2026-02-25 16:25:01.804322
0436db44-050e-4250-bdf7-f95ffa409b9d	52e6f3ee-6ee5-41c3-83c8-4563532cf791	BOB-OUA-TSR	Bobo-Dioulasso	Ouagadougou	Gare TSR Bobo	Gare TSR Ouaga	\N	\N	\N	\N	4500.00	XOF	100.00	360.00	330	t	2026-02-25 16:25:01.804322	2026-02-25 16:25:01.804322
173960eb-306a-4ba6-9e67-1d45417a1d34	7f849e9b-22a1-4356-a1af-1ce1ca6cdc89	OUA-BOB-STAF	Ouagadougou	Bobo-Dioulasso	Gare STAF Ouaga	Gare STAF Bobo	\N	\N	\N	\N	6500.00	XOF	100.00	360.00	300	f	2026-02-25 16:25:01.804322	2026-02-25 16:25:01.804322
b0cc5c8e-3ece-4401-975f-e9cd3e04cca4	cdfeaa05-abf4-418d-ac7e-c334d17de8bd	OUA-BOB-RAHIMO	Ouagadougou	Bobo-Dioulasso	Gare RAHIMO Ouaga	Gare RAHIMO Bobo	\N	\N	\N	\N	6500.00	XOF	100.00	360.00	300	t	2026-02-25 16:25:01.804322	2026-02-25 16:25:01.804322
e7181d51-7694-41e3-ad39-1f4a25af4cfd	cdfeaa05-abf4-418d-ac7e-c334d17de8bd	BOB-OUA-RAHIMO	Bobo-Dioulasso	Ouagadougou	Gare RAHIMO Bobo	Gare RAHIMO Ouaga	\N	\N	\N	\N	6500.00	XOF	100.00	360.00	300	t	2026-02-25 16:25:01.804322	2026-02-25 16:25:01.804322
bd9b1f0a-61f0-4a70-8045-902aa22365c1	a59ff95c-2c97-46d6-8396-c2fb6c570b11	OUA-BOB-RAKIETA	Ouagadougou	Bobo-Dioulasso	Gare RAKIETA Ouaga	Gare RAKIETA Bobo	\N	\N	\N	\N	7500.00	XOF	100.00	360.00	300	t	2026-02-25 16:25:01.804322	2026-02-25 16:25:01.804322
cf2ae1e1-37b2-4b74-af20-5f2d4e556f36	a59ff95c-2c97-46d6-8396-c2fb6c570b11	BOB-OUA-RAKIETA	Bobo-Dioulasso	Ouagadougou	Gare RAKIETA Bobo	Gare RAKIETA Ouaga	\N	\N	\N	\N	7500.00	XOF	100.00	360.00	300	t	2026-02-25 16:25:01.804322	2026-02-25 16:25:01.804322
cfd041ee-3dc0-4b0f-b555-3085134cc301	eebd8b5f-e501-4556-b69a-46e692008554	OUA-BOB-TCV	Ouagadougou	Bobo-Dioulasso	Gare TCV Ouaga	Gare TCV Bobo	\N	\N	\N	\N	6500.00	XOF	100.00	360.00	360	t	2026-02-25 16:25:01.804322	2026-02-25 16:25:01.804322
eaed93ea-6ca6-4fbe-b20f-7a878bfa22fa	7f849e9b-22a1-4356-a1af-1ce1ca6cdc89	STAF-BO	Bobo-Dioulasso	Ouagadougou	\N	\N	\N	\N	\N	\N	5000.00	XOF	100.00	365.00	290	t	2026-02-23 18:00:42.401153	2026-02-25 22:26:45.786649
1d165a17-848c-4ba4-8353-9180c2de91d1	cdfeaa05-abf4-418d-ac7e-c334d17de8bd	RH-PREMIUM-BO	Bobo-Dioulasso	Ouagadougou	\N	\N	\N	\N	\N	\N	6500.00	XOF	100.00	365.00	270	t	2026-02-23 18:00:42.401153	2026-02-25 22:26:45.786649
74504400-e6f4-4143-a1aa-ceff2dc1c94c	52e6f3ee-6ee5-41c3-83c8-4563532cf791	TSR-FD	Ouagadougou	Fada N'Gourma	\N	\N	\N	\N	\N	\N	3500.00	XOF	100.00	219.00	195	t	2026-02-23 18:00:42.401153	2026-02-25 22:26:45.786649
a9b6e6bb-2528-459c-bb5e-e38d98d51f0c	a59ff95c-2c97-46d6-8396-c2fb6c570b11	RAK-FD	Ouagadougou	Fada N'Gourma	\N	\N	\N	\N	\N	\N	3500.00	XOF	100.00	219.00	220	t	2026-02-23 18:00:42.401153	2026-02-25 22:26:45.786649
4d9653e4-121d-4d37-82ce-e9cc584e4722	eebd8b5f-e501-4556-b69a-46e692008554	TCV-FD	Ouagadougou	Fada N'Gourma	\N	\N	\N	\N	\N	\N	4000.00	XOF	100.00	219.00	200	t	2026-02-23 18:00:42.401153	2026-02-25 22:26:45.786649
fa760d1c-6d4c-4fd2-b6cf-1f2539efe158	7f849e9b-22a1-4356-a1af-1ce1ca6cdc89	STAF-KD	Ouagadougou	Koudougou	\N	\N	\N	\N	\N	\N	2500.00	XOF	100.00	97.00	85	t	2026-02-23 18:00:42.401153	2026-02-25 22:26:45.786649
a704a351-5f4a-4957-88e2-dc903887d8f7	cdfeaa05-abf4-418d-ac7e-c334d17de8bd	RH-KAYA	Ouagadougou	Kaya	\N	\N	\N	\N	\N	\N	2500.00	XOF	100.00	100.00	95	t	2026-02-23 18:00:42.401153	2026-02-25 22:26:45.786649
6f628bc2-9e7b-4f98-a8f0-fce5039f8f8f	a59ff95c-2c97-46d6-8396-c2fb6c570b11	RAK-KAYA	Ouagadougou	Kaya	\N	\N	\N	\N	\N	\N	2000.00	XOF	100.00	100.00	100	t	2026-02-23 18:00:42.401153	2026-02-25 22:26:45.786649
c5af9c1f-0aa5-4443-90cf-567ed9d14b64	a59ff95c-2c97-46d6-8396-c2fb6c570b11	RAK-BF	Ouagadougou	Banfora	\N	\N	\N	\N	\N	\N	9000.00	XOF	100.00	440.00	390	t	2026-02-23 18:40:21.830783	2026-02-25 22:26:45.786649
0065edd4-d616-4f9e-ad1e-c61dccb965a1	a59ff95c-2c97-46d6-8396-c2fb6c570b11	RAK-BF-R	Banfora	Ouagadougou	\N	\N	\N	\N	\N	\N	9000.00	XOF	100.00	440.00	390	t	2026-02-23 18:40:21.830783	2026-02-25 22:26:45.786649
106e586a-77e6-420f-b2f4-7d1c97196e12	a59ff95c-2c97-46d6-8396-c2fb6c570b11	RAK-NG	Ouagadougou	Niangoloko	\N	\N	\N	\N	\N	\N	9500.00	XOF	100.00	470.00	420	t	2026-02-23 18:40:21.830783	2026-02-25 22:26:45.786649
5097a213-fddf-439d-8063-e409133fb0f8	a59ff95c-2c97-46d6-8396-c2fb6c570b11	RAK-NG-R	Niangoloko	Ouagadougou	\N	\N	\N	\N	\N	\N	9500.00	XOF	100.00	470.00	420	t	2026-02-23 18:40:21.830783	2026-02-25 22:26:45.786649
c1bfbfc0-0e88-449d-b889-bb2ed525b6c6	a59ff95c-2c97-46d6-8396-c2fb6c570b11	RAK-ABIDJAN	Ouagadougou	Abidjan	\N	\N	\N	\N	\N	\N	32500.00	XOF	100.00	1150.00	1260	t	2026-02-23 18:40:21.830783	2026-02-25 22:26:45.786649
8f4e8f12-6cf8-43e3-8ca1-4f90f13ef822	a59ff95c-2c97-46d6-8396-c2fb6c570b11	RAK-ABIDJAN-R	Abidjan	Ouagadougou	\N	\N	\N	\N	\N	\N	32500.00	XOF	100.00	1150.00	1260	t	2026-02-23 18:40:21.830783	2026-02-25 22:26:45.786649
27da7c88-dada-4e9d-8bfc-768569a665fe	a59ff95c-2c97-46d6-8396-c2fb6c570b11	RAK-BAMAKO	Ouagadougou	Bamako	\N	\N	\N	\N	\N	\N	20500.00	XOF	100.00	1200.00	1320	t	2026-02-23 18:40:21.830783	2026-02-25 22:26:45.786649
e377c74a-3e48-4fd6-aa4d-76807d903012	a59ff95c-2c97-46d6-8396-c2fb6c570b11	RAK-BAMAKO-R	Bamako	Ouagadougou	\N	\N	\N	\N	\N	\N	20500.00	XOF	100.00	1200.00	1320	t	2026-02-23 18:40:21.830783	2026-02-25 22:26:45.786649
52de9f8d-89d0-464d-9348-a38938733adf	a59ff95c-2c97-46d6-8396-c2fb6c570b11	RAK-SIKASSO	Ouagadougou	Sikasso	\N	\N	\N	\N	\N	\N	13500.00	XOF	100.00	445.00	480	t	2026-02-23 18:40:21.830783	2026-02-25 22:26:45.786649
6b646f38-5b44-4c9a-9bac-1a0df371d24a	52e6f3ee-6ee5-41c3-83c8-4563532cf791	TSR-BB-02	Bobo-Dioulasso	Ouagadougou	\N	\N	\N	\N	\N	\N	4500.00	XOF	100.00	365.00	280	t	2026-02-23 18:00:42.401153	2026-02-25 22:26:45.786649
f3dffffa-39d7-4478-bc0d-69a1dea63f15	a59ff95c-2c97-46d6-8396-c2fb6c570b11	RAK-SIKASSO-R	Sikasso	Ouagadougou	\N	\N	\N	\N	\N	\N	13500.00	XOF	100.00	445.00	480	t	2026-02-23 18:40:21.830783	2026-02-25 22:26:45.786649
ae0e041a-1686-4ae4-81b5-c78fb5d50091	a59ff95c-2c97-46d6-8396-c2fb6c570b11	RAK-BOUAKE	Ouagadougou	Bouaké	\N	\N	\N	\N	\N	\N	26500.00	XOF	100.00	780.00	900	t	2026-02-23 18:40:21.830783	2026-02-25 22:26:45.786649
2dde6fed-7382-4a8d-9b24-2620e67331f9	a59ff95c-2c97-46d6-8396-c2fb6c570b11	RAK-BOUAKE-R	Bouaké	Ouagadougou	\N	\N	\N	\N	\N	\N	26500.00	XOF	100.00	780.00	900	t	2026-02-23 18:40:21.830783	2026-02-25 22:26:45.786649
c4c37289-d803-4670-a974-fc3bf46c3d12	a59ff95c-2c97-46d6-8396-c2fb6c570b11	RAK-YAKO	Ouagadougou	Yako	\N	\N	\N	\N	\N	\N	1800.00	XOF	100.00	110.00	105	t	2026-02-23 18:40:21.830783	2026-02-25 22:26:45.786649
cf96dead-0ad9-4845-aad4-df29970cf22c	a59ff95c-2c97-46d6-8396-c2fb6c570b11	RAK-YAKO-R	Yako	Ouagadougou	\N	\N	\N	\N	\N	\N	1800.00	XOF	100.00	110.00	105	t	2026-02-23 18:40:21.830783	2026-02-25 22:26:45.786649
dd6c1950-30fa-494f-b2a0-7adf64f66ed1	eebd8b5f-e501-4556-b69a-46e692008554	TCV-LOME	Ouagadougou	Lomé	\N	\N	\N	\N	\N	\N	20000.00	XOF	100.00	990.00	1080	t	2026-02-23 18:40:21.830783	2026-02-25 22:26:45.786649
17f9f776-b72c-4cb3-b808-d78b110c2834	eebd8b5f-e501-4556-b69a-46e692008554	TCV-LOME-R	Lomé	Ouagadougou	\N	\N	\N	\N	\N	\N	20000.00	XOF	100.00	990.00	1080	t	2026-02-23 18:40:21.830783	2026-02-25 22:26:45.786649
\.


--
-- Data for Name: loyalty_points; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.loyalty_points (id, user_id, total_points, available_points, lifetime_points, last_updated, created_at) FROM stdin;
\.


--
-- Data for Name: loyalty_transactions; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.loyalty_transactions (id, user_id, booking_id, points_amount, transaction_type, description, created_at) FROM stdin;
\.


--
-- Data for Name: notifications; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.notifications (id, user_id, booking_id, title, message, notification_type, is_read, read_at, action_url, created_at) FROM stdin;
\.


--
-- Data for Name: otp_codes; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.otp_codes (id, phone_number, otp_code, purpose, is_verified, attempts, expires_at, verified_at, created_at) FROM stdin;
0e664763-b825-4d50-8dd8-d363773addd9	+226226XXXXXXXX	842980	LOGIN	f	0	2026-02-24 23:54:30.18	\N	2026-02-24 23:44:30.239986
\.


--
-- Data for Name: otp_verifications; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.otp_verifications (id, phone_number, otp_code, attempts, max_attempts, is_verified, verified_at, expires_at, created_at) FROM stdin;
\.


--
-- Data for Name: payments; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.payments (id, booking_id, user_id, amount, currency, payment_method, payment_gateway, transaction_id, provider_reference, status, error_message, metadata, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: promo_codes; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.promo_codes (id, code, company_id, discount_percentage, discount_amount, max_uses, current_uses, valid_from, valid_until, is_active, created_by, created_at) FROM stdin;
\.


--
-- Data for Name: ratings; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.ratings (id, booking_id, user_id, company_id, line_id, rating, punctuality_rating, comfort_rating, staff_rating, cleanliness_rating, comment, is_verified, verification_date, helpful_count, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: schedules; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.schedules (id, line_id, departure_time, days_of_week, total_seats, available_seats, valid_from, valid_until, is_active, created_at, updated_at, arrival_time) FROM stdin;
0995c37f-71d8-4be4-8dff-e9ba30ef6e3d	4d11e3fc-36e7-441a-9b2c-b0e592458e19	06:30:00	{1,2,3,4,5,6,7}	40	40	2026-02-23	2026-05-24	t	2026-02-23 18:00:42.401153	2026-02-23 18:00:42.401153	\N
78431501-242b-4c20-be98-2ab5336dcf3c	4d11e3fc-36e7-441a-9b2c-b0e592458e19	13:00:00	{1,2,3,4,5,6,7}	40	40	2026-02-23	2026-05-24	t	2026-02-23 18:00:42.401153	2026-02-23 18:00:42.401153	\N
5818c652-e38f-438f-9dd6-d92fab95ec3b	cd95aa15-480f-42a0-a863-60f2896814fb	08:00:00	{1,2,3,4,5,6,7}	40	40	2026-02-23	2026-05-24	t	2026-02-23 18:00:42.401153	2026-02-23 18:00:42.401153	\N
2ebadac8-a443-4aa5-9365-cf669a130de5	cd95aa15-480f-42a0-a863-60f2896814fb	16:00:00	{1,2,3,4,5,6,7}	40	40	2026-02-23	2026-05-24	t	2026-02-23 18:00:42.401153	2026-02-23 18:00:42.401153	\N
372b7d94-9a51-4e23-9931-9ad4b49398c0	61565c46-d1ee-4c1a-b043-184dc10db348	07:30:00	{1,2,3,4,5,6,7}	40	40	2026-02-23	2026-05-24	t	2026-02-23 18:00:42.401153	2026-02-23 18:00:42.401153	\N
7d6a37ac-ff0a-4f32-aea7-e1383c7c59c5	fd593275-8d4d-430f-9754-fbc48499a44c	10:00:00	{1,2,3,4,5,6,7}	40	40	2026-02-23	2026-05-24	t	2026-02-23 18:00:42.401153	2026-02-23 18:00:42.401153	\N
0e00c22d-4739-47ca-9e6b-3b0ad8030218	ad81be83-f641-4672-a650-14cffbba2f53	06:00:00	{1,2,3,4,5,6,7}	40	40	2026-02-23	2026-05-24	t	2026-02-23 18:00:42.401153	2026-02-23 18:00:42.401153	\N
b15c2537-76b6-4efc-a10e-3e0a6707d570	ad81be83-f641-4672-a650-14cffbba2f53	14:00:00	{1,2,3,4,5,6,7}	40	40	2026-02-23	2026-05-24	t	2026-02-23 18:00:42.401153	2026-02-23 18:00:42.401153	\N
96d6e705-db6d-4bf6-ac17-cba2562af563	6b646f38-5b44-4c9a-9bac-1a0df371d24a	07:00:00	{1,2,3,4,5,6,7}	40	40	2026-02-23	2026-05-24	t	2026-02-23 18:00:42.401153	2026-02-23 18:00:42.401153	\N
cbc7c9d2-ddbe-4998-8791-84f51fa98175	eaed93ea-6ca6-4fbe-b20f-7a878bfa22fa	08:00:00	{1,2,3,4,5,6,7}	40	40	2026-02-23	2026-05-24	t	2026-02-23 18:00:42.401153	2026-02-23 18:00:42.401153	\N
c188502e-b0a8-481c-a816-0cdbaca36327	1d165a17-848c-4ba4-8353-9180c2de91d1	09:00:00	{1,2,3,4,5,6,7}	40	40	2026-02-23	2026-05-24	t	2026-02-23 18:00:42.401153	2026-02-23 18:00:42.401153	\N
be70d5c3-54f3-4251-bc46-d2b55458ca3a	e3a8e68b-2bcf-44c1-9ef0-7bb5f7f37338	07:00:00	{1,2,3,4,5,6,7}	40	40	2026-02-23	2026-05-24	t	2026-02-23 18:00:42.401153	2026-02-23 18:00:42.401153	\N
8d9dd87c-7086-4543-be4e-14337ba76654	e3a8e68b-2bcf-44c1-9ef0-7bb5f7f37338	14:00:00	{1,2,3,4,5,6,7}	40	40	2026-02-23	2026-05-24	t	2026-02-23 18:00:42.401153	2026-02-23 18:00:42.401153	\N
aaabfea6-60ac-4f50-842a-a6d8f0b52875	74504400-e6f4-4143-a1aa-ceff2dc1c94c	08:00:00	{1,2,3,4,5,6,7}	40	40	2026-02-23	2026-05-24	t	2026-02-23 18:00:42.401153	2026-02-23 18:00:42.401153	\N
f64cf7a1-64cf-4746-94a0-b5f10ea0e04d	a9b6e6bb-2528-459c-bb5e-e38d98d51f0c	09:00:00	{1,2,3,4,5,6,7}	40	40	2026-02-23	2026-05-24	t	2026-02-23 18:00:42.401153	2026-02-23 18:00:42.401153	\N
52a3dad6-e339-4673-bd45-206aefbe9ada	4d9653e4-121d-4d37-82ce-e9cc584e4722	10:00:00	{1,2,3,4,5,6,7}	40	40	2026-02-23	2026-05-24	t	2026-02-23 18:00:42.401153	2026-02-23 18:00:42.401153	\N
b0161651-f92a-4858-a09b-c2bb1be5b27d	bf67fac7-1225-4ee9-9812-caca7b62b4d7	06:30:00	{1,2,3,4,5,6,7}	40	40	2026-02-23	2026-05-24	t	2026-02-23 18:00:42.401153	2026-02-23 18:00:42.401153	\N
33520da1-3103-4a11-9fe5-d090fbeebe45	bf67fac7-1225-4ee9-9812-caca7b62b4d7	10:00:00	{1,2,3,4,5,6,7}	40	40	2026-02-23	2026-05-24	t	2026-02-23 18:00:42.401153	2026-02-23 18:00:42.401153	\N
7e307570-7918-4c7d-9496-a6e0fe30e616	bf67fac7-1225-4ee9-9812-caca7b62b4d7	15:00:00	{1,2,3,4,5,6,7}	40	40	2026-02-23	2026-05-24	t	2026-02-23 18:00:42.401153	2026-02-23 18:00:42.401153	\N
3ef3ff92-1b7b-4f1a-9bd7-220a41c61491	fa760d1c-6d4c-4fd2-b6cf-1f2539efe158	07:00:00	{1,2,3,4,5,6,7}	40	40	2026-02-23	2026-05-24	t	2026-02-23 18:00:42.401153	2026-02-23 18:00:42.401153	\N
98a037b0-de33-460f-b457-c649bdf3458d	a704a351-5f4a-4957-88e2-dc903887d8f7	08:00:00	{1,2,3,4,5,6,7}	40	40	2026-02-23	2026-05-24	t	2026-02-23 18:00:42.401153	2026-02-23 18:00:42.401153	\N
5ff07b8f-88a3-4398-8bc0-f0aab017fa87	6f628bc2-9e7b-4f98-a8f0-fce5039f8f8f	09:00:00	{1,2,3,4,5,6,7}	40	40	2026-02-23	2026-05-24	t	2026-02-23 18:00:42.401153	2026-02-23 18:00:42.401153	\N
c636080b-1d8b-4890-ba13-3dc65f2b029e	8d18a350-61e1-47d5-a4fb-bde2f07affd9	06:00:00	{1,2,3,4,5,6}	40	40	2026-02-23	2026-05-24	t	2026-02-23 18:00:42.401153	2026-02-23 18:00:42.401153	\N
abfdfc40-6af6-4b0f-a918-583cca5cb71c	861b502e-e565-4c7d-9af0-096fba747ed8	06:00:00	{1,2,3,4,5,6}	40	40	2026-02-23	2026-05-24	t	2026-02-23 18:00:42.401153	2026-02-23 18:00:42.401153	\N
1199fb76-0f3c-43e1-923d-47aa809d5927	88b96b8c-f1c0-479d-8692-160662dc6181	06:00:00	{1,2,3,4,5,6}	40	40	2026-02-23	2026-05-24	t	2026-02-23 18:00:42.401153	2026-02-23 18:00:42.401153	\N
e85b7922-08e6-4be8-960e-cb746e07591c	d594417c-236d-43be-9b5e-6866e3ac2cf2	06:00:00	{1,2,3,4,5,6,7}	40	40	2026-02-23	2026-05-24	t	2026-02-23 18:00:42.401153	2026-02-23 18:00:42.401153	\N
83b80005-8e42-4dbe-bc39-3ef587635833	ca14a121-b8af-48d7-93e7-c3e2c96c7947	09:00:00	{1,2,3,4,5,6,7}	40	40	2026-02-23	2026-05-24	t	2026-02-23 18:40:21.830783	2026-02-23 18:40:21.830783	\N
7d877b01-54be-497a-bd0e-35f6021e51bc	ca14a121-b8af-48d7-93e7-c3e2c96c7947	15:00:00	{1,2,3,4,5,6,7}	40	40	2026-02-23	2026-05-24	t	2026-02-23 18:40:21.830783	2026-02-23 18:40:21.830783	\N
11005f23-eaa9-44b1-95c8-280bc39e5a90	92b34d4e-da8c-4ed9-8d64-3a07dedb88f7	07:00:00	{1,2,3,4,5,6,7}	40	40	2026-02-23	2026-05-24	t	2026-02-23 18:40:21.830783	2026-02-23 18:40:21.830783	\N
d1514266-42b7-408d-ae2e-b5486b7b67d6	92b34d4e-da8c-4ed9-8d64-3a07dedb88f7	14:00:00	{1,2,3,4,5,6,7}	40	40	2026-02-23	2026-05-24	t	2026-02-23 18:40:21.830783	2026-02-23 18:40:21.830783	\N
146b6d63-d98b-473f-b151-3d02596a40b2	4d11e3fc-36e7-441a-9b2c-b0e592458e19	06:30:00	{1,2,3,4,5,6,7}	40	40	2026-02-23	2026-05-24	t	2026-02-23 18:40:21.830783	2026-02-23 18:40:21.830783	\N
f68771c4-f544-49a1-892c-d0afc7fe1ae5	4d11e3fc-36e7-441a-9b2c-b0e592458e19	13:00:00	{1,2,3,4,5,6,7}	40	40	2026-02-23	2026-05-24	t	2026-02-23 18:40:21.830783	2026-02-23 18:40:21.830783	\N
820833c8-ae08-494f-8938-4bd97f10d32e	cd95aa15-480f-42a0-a863-60f2896814fb	08:00:00	{1,2,3,4,5,6,7}	40	40	2026-02-23	2026-05-24	t	2026-02-23 18:40:21.830783	2026-02-23 18:40:21.830783	\N
8bd4fca4-5d10-4293-b5ec-70171676c077	cd95aa15-480f-42a0-a863-60f2896814fb	16:00:00	{1,2,3,4,5,6,7}	40	40	2026-02-23	2026-05-24	t	2026-02-23 18:40:21.830783	2026-02-23 18:40:21.830783	\N
1844beb9-4adb-4f75-abac-162d2904b705	61565c46-d1ee-4c1a-b043-184dc10db348	07:30:00	{1,2,3,4,5,6,7}	40	40	2026-02-23	2026-05-24	t	2026-02-23 18:40:21.830783	2026-02-23 18:40:21.830783	\N
dbb175e1-059f-411f-944b-721e2dd5f759	61565c46-d1ee-4c1a-b043-184dc10db348	13:30:00	{1,2,3,4,5,6,7}	40	40	2026-02-23	2026-05-24	t	2026-02-23 18:40:21.830783	2026-02-23 18:40:21.830783	\N
eddbee97-e095-4e37-aa5d-02d869e3b43f	fd593275-8d4d-430f-9754-fbc48499a44c	10:00:00	{1,2,3,4,5,6,7}	40	40	2026-02-23	2026-05-24	t	2026-02-23 18:40:21.830783	2026-02-23 18:40:21.830783	\N
a3d8ab1b-47c8-4b49-8cc6-4313439ae222	ad81be83-f641-4672-a650-14cffbba2f53	06:00:00	{1,2,3,4,5,6,7}	40	40	2026-02-23	2026-05-24	t	2026-02-23 18:40:21.830783	2026-02-23 18:40:21.830783	\N
6e9c1f1e-b0f6-4d40-95df-2d20cef5a8a3	ad81be83-f641-4672-a650-14cffbba2f53	14:00:00	{1,2,3,4,5,6,7}	40	40	2026-02-23	2026-05-24	t	2026-02-23 18:40:21.830783	2026-02-23 18:40:21.830783	\N
8cea0dac-418f-4758-a004-2c193d998b5c	6b646f38-5b44-4c9a-9bac-1a0df371d24a	07:00:00	{1,2,3,4,5,6,7}	40	40	2026-02-23	2026-05-24	t	2026-02-23 18:40:21.830783	2026-02-23 18:40:21.830783	\N
815a7ea6-86b4-42c2-8b51-e983b875d8d1	eaed93ea-6ca6-4fbe-b20f-7a878bfa22fa	08:00:00	{1,2,3,4,5,6,7}	40	40	2026-02-23	2026-05-24	t	2026-02-23 18:40:21.830783	2026-02-23 18:40:21.830783	\N
09fcd00f-accb-4a25-964a-065bb847868a	1d165a17-848c-4ba4-8353-9180c2de91d1	09:00:00	{1,2,3,4,5,6,7}	40	40	2026-02-23	2026-05-24	t	2026-02-23 18:40:21.830783	2026-02-23 18:40:21.830783	\N
65c08c0b-295e-4b6b-9454-0ab57f969b25	e3a8e68b-2bcf-44c1-9ef0-7bb5f7f37338	07:00:00	{1,2,3,4,5,6,7}	40	40	2026-02-23	2026-05-24	t	2026-02-23 18:40:21.830783	2026-02-23 18:40:21.830783	\N
0a56b075-05c5-4013-bc96-5a840a8df667	e3a8e68b-2bcf-44c1-9ef0-7bb5f7f37338	14:00:00	{1,2,3,4,5,6,7}	40	40	2026-02-23	2026-05-24	t	2026-02-23 18:40:21.830783	2026-02-23 18:40:21.830783	\N
12c0b795-4577-45df-8f6d-8b108df253f4	74504400-e6f4-4143-a1aa-ceff2dc1c94c	08:00:00	{1,2,3,4,5,6,7}	40	40	2026-02-23	2026-05-24	t	2026-02-23 18:40:21.830783	2026-02-23 18:40:21.830783	\N
8f36e7d3-dee3-4146-a193-ac070abe83ef	a9b6e6bb-2528-459c-bb5e-e38d98d51f0c	09:00:00	{1,2,3,4,5,6,7}	40	40	2026-02-23	2026-05-24	t	2026-02-23 18:40:21.830783	2026-02-23 18:40:21.830783	\N
62225ed5-1a86-4819-83a7-aeab8a940c1d	ca14a121-b8af-48d7-93e7-c3e2c96c7947	09:00:00	{1,2,3,4,5,6,7}	40	39	2026-02-23	2026-05-24	t	2026-02-23 18:00:42.401153	2026-02-25 17:23:55.299085	\N
34573d8e-a065-46a4-92fa-02b8f5ec64ad	ca14a121-b8af-48d7-93e7-c3e2c96c7947	15:00:00	{1,2,3,4,5,6,7}	40	39	2026-02-23	2026-05-24	t	2026-02-23 18:00:42.401153	2026-02-25 17:24:08.175513	\N
daea48bb-307d-494a-bc33-745335a51abd	92b34d4e-da8c-4ed9-8d64-3a07dedb88f7	07:00:00	{1,2,3,4,5,6,7}	40	39	2026-02-23	2026-05-24	t	2026-02-23 18:00:42.401153	2026-02-25 17:24:41.490766	\N
1f4bd0de-8c71-4f89-8367-4e6503eb9296	92b34d4e-da8c-4ed9-8d64-3a07dedb88f7	14:00:00	{1,2,3,4,5,6,7}	40	41	2026-02-23	2026-05-24	t	2026-02-23 18:00:42.401153	2026-02-25 17:25:01.881883	\N
eb529c37-bbf5-4645-9e55-9d9279b99578	ca14a121-b8af-48d7-93e7-c3e2c96c7947	06:00:00	{1,2,3,4,5,6,7}	40	39	2026-02-23	2026-05-24	t	2026-02-23 18:40:21.830783	2026-02-25 21:17:31.895198	\N
7d799701-63f2-488e-8e55-609958ef1d73	4d9653e4-121d-4d37-82ce-e9cc584e4722	10:00:00	{1,2,3,4,5,6,7}	40	40	2026-02-23	2026-05-24	t	2026-02-23 18:40:21.830783	2026-02-23 18:40:21.830783	\N
2a4088f5-6ac7-4756-973c-be5ee2e8e563	bf67fac7-1225-4ee9-9812-caca7b62b4d7	06:30:00	{1,2,3,4,5,6,7}	40	40	2026-02-23	2026-05-24	t	2026-02-23 18:40:21.830783	2026-02-23 18:40:21.830783	\N
cc314fa6-4d1e-4fbd-88c9-cb488d99c6d3	bf67fac7-1225-4ee9-9812-caca7b62b4d7	10:00:00	{1,2,3,4,5,6,7}	40	40	2026-02-23	2026-05-24	t	2026-02-23 18:40:21.830783	2026-02-23 18:40:21.830783	\N
e72c39c0-8074-4dcd-b6ec-e3e0f74edea9	bf67fac7-1225-4ee9-9812-caca7b62b4d7	15:00:00	{1,2,3,4,5,6,7}	40	40	2026-02-23	2026-05-24	t	2026-02-23 18:40:21.830783	2026-02-23 18:40:21.830783	\N
80f86e0a-e750-447a-acf6-b84e685e799b	fa760d1c-6d4c-4fd2-b6cf-1f2539efe158	07:00:00	{1,2,3,4,5,6,7}	40	40	2026-02-23	2026-05-24	t	2026-02-23 18:40:21.830783	2026-02-23 18:40:21.830783	\N
b1f62ff0-cd35-451e-9d9b-23a6d8fcc726	a704a351-5f4a-4957-88e2-dc903887d8f7	08:00:00	{1,2,3,4,5,6,7}	40	40	2026-02-23	2026-05-24	t	2026-02-23 18:40:21.830783	2026-02-23 18:40:21.830783	\N
b9f08db6-62e4-4649-aa84-e39350838ae4	6f628bc2-9e7b-4f98-a8f0-fce5039f8f8f	09:00:00	{1,2,3,4,5,6,7}	40	40	2026-02-23	2026-05-24	t	2026-02-23 18:40:21.830783	2026-02-23 18:40:21.830783	\N
b28c761e-6b99-4cba-85aa-5766c8f03eea	c5af9c1f-0aa5-4443-90cf-567ed9d14b64	07:00:00	{1,2,3,4,5,6,7}	40	40	2026-02-23	2026-05-24	t	2026-02-23 18:40:21.830783	2026-02-23 18:40:21.830783	\N
194364dc-ba01-4eec-a3dd-c1db6c7f74cc	0065edd4-d616-4f9e-ad1e-c61dccb965a1	08:00:00	{1,2,3,4,5,6,7}	40	40	2026-02-23	2026-05-24	t	2026-02-23 18:40:21.830783	2026-02-23 18:40:21.830783	\N
3f884a59-4f0c-40bc-9a76-add9439748f1	106e586a-77e6-420f-b2f4-7d1c97196e12	06:30:00	{1,2,3,4,5,6}	40	40	2026-02-23	2026-05-24	t	2026-02-23 18:40:21.830783	2026-02-23 18:40:21.830783	\N
2626703e-f575-4293-8627-18d6e5c99154	5097a213-fddf-439d-8063-e409133fb0f8	07:00:00	{1,2,3,4,5,6}	40	40	2026-02-23	2026-05-24	t	2026-02-23 18:40:21.830783	2026-02-23 18:40:21.830783	\N
8233a8c7-3c6a-43ca-a05b-efed11d32e4a	c1bfbfc0-0e88-449d-b889-bb2ed525b6c6	17:00:00	{2,4,6}	40	40	2026-02-23	2026-05-24	t	2026-02-23 18:40:21.830783	2026-02-23 18:40:21.830783	\N
89a1e7be-013c-48da-abfd-c84e69094962	8f4e8f12-6cf8-43e3-8ca1-4f90f13ef822	18:00:00	{1,3,5}	40	40	2026-02-23	2026-05-24	t	2026-02-23 18:40:21.830783	2026-02-23 18:40:21.830783	\N
942ace74-3c70-490f-8cef-b89c49130b28	27da7c88-dada-4e9d-8bfc-768569a665fe	16:00:00	{1,3,5,7}	40	40	2026-02-23	2026-05-24	t	2026-02-23 18:40:21.830783	2026-02-23 18:40:21.830783	\N
6118eeff-4659-477a-b38a-fab86dc71c7d	e377c74a-3e48-4fd6-aa4d-76807d903012	17:00:00	{2,4,6}	40	40	2026-02-23	2026-05-24	t	2026-02-23 18:40:21.830783	2026-02-23 18:40:21.830783	\N
09fc36e8-5ff3-4960-92c6-58e8487afe1a	52de9f8d-89d0-464d-9348-a38938733adf	06:00:00	{1,2,3,4,5,6}	40	40	2026-02-23	2026-05-24	t	2026-02-23 18:40:21.830783	2026-02-23 18:40:21.830783	\N
b8b4805b-d187-443c-8fba-81a68f42be6d	f3dffffa-39d7-4478-bc0d-69a1dea63f15	07:00:00	{1,2,3,4,5,6}	40	40	2026-02-23	2026-05-24	t	2026-02-23 18:40:21.830783	2026-02-23 18:40:21.830783	\N
b0569985-a811-419b-98f2-cc71b017d040	ae0e041a-1686-4ae4-81b5-c78fb5d50091	08:00:00	{2,4,6}	40	40	2026-02-23	2026-05-24	t	2026-02-23 18:40:21.830783	2026-02-23 18:40:21.830783	\N
1f17abe2-45b1-4e9e-b342-5bf6fbc2c40f	2dde6fed-7382-4a8d-9b24-2620e67331f9	09:00:00	{1,3,5}	40	40	2026-02-23	2026-05-24	t	2026-02-23 18:40:21.830783	2026-02-23 18:40:21.830783	\N
f3420ba7-1cf8-47ca-be35-9fe957554ae8	c4c37289-d803-4670-a974-fc3bf46c3d12	08:00:00	{1,2,3,4,5,6,7}	40	40	2026-02-23	2026-05-24	t	2026-02-23 18:40:21.830783	2026-02-23 18:40:21.830783	\N
c3a8f73a-b47e-451d-82a3-7401faa101aa	c4c37289-d803-4670-a974-fc3bf46c3d12	14:00:00	{1,2,3,4,5,6,7}	40	40	2026-02-23	2026-05-24	t	2026-02-23 18:40:21.830783	2026-02-23 18:40:21.830783	\N
52876d43-682a-4a0c-bee8-7f7de2ffe991	cf96dead-0ad9-4845-aad4-df29970cf22c	09:00:00	{1,2,3,4,5,6,7}	40	40	2026-02-23	2026-05-24	t	2026-02-23 18:40:21.830783	2026-02-23 18:40:21.830783	\N
a674df95-1af0-45ea-bbe9-b66e9f732fb2	cf96dead-0ad9-4845-aad4-df29970cf22c	15:00:00	{1,2,3,4,5,6,7}	40	40	2026-02-23	2026-05-24	t	2026-02-23 18:40:21.830783	2026-02-23 18:40:21.830783	\N
dc537c3f-d92c-483d-a8f9-6b76c94aece7	dd6c1950-30fa-494f-b2a0-7adf64f66ed1	06:00:00	{7}	40	40	2026-02-23	2026-05-24	t	2026-02-23 18:40:21.830783	2026-02-23 18:40:21.830783	\N
70e4dce5-257a-4111-bd5e-9d302e4cdf90	17f9f776-b72c-4cb3-b808-d78b110c2834	07:00:00	{1}	40	40	2026-02-23	2026-05-24	t	2026-02-23 18:40:21.830783	2026-02-23 18:40:21.830783	\N
e50d9d25-3e3a-4ba8-9e79-e129805a6689	1bb0272f-54eb-4092-9342-8b946e8788a0	06:00:00	{1,2,3,4,5,6}	40	40	2026-02-23	2026-05-24	t	2026-02-23 18:40:21.830783	2026-02-23 18:40:21.830783	\N
20698af3-cc03-40d1-a821-2d62e8ef4cb4	6e8d0c7b-ca14-4330-9fc4-0ef0eefdf7e9	06:00:00	{1,2,3,4,5,6}	40	40	2026-02-23	2026-05-24	t	2026-02-23 18:40:21.830783	2026-02-23 18:40:21.830783	\N
a43c6a87-ea64-4c7a-bc63-ef2da9bd1fa7	8d18a350-61e1-47d5-a4fb-bde2f07affd9	06:00:00	{1,2,3,4,5,6}	40	40	2026-02-23	2026-05-24	t	2026-02-23 18:40:21.830783	2026-02-23 18:40:21.830783	\N
22b38415-cf9f-4586-8e88-8954e420ded7	861b502e-e565-4c7d-9af0-096fba747ed8	06:00:00	{1,2,3,4,5,6}	40	40	2026-02-23	2026-05-24	t	2026-02-23 18:40:21.830783	2026-02-23 18:40:21.830783	\N
86201041-cb6f-4595-a854-8c20e3506681	88b96b8c-f1c0-479d-8692-160662dc6181	06:00:00	{1,2,3,4,5,6}	40	40	2026-02-23	2026-05-24	t	2026-02-23 18:40:21.830783	2026-02-23 18:40:21.830783	\N
b81050e8-5e66-4cd3-b9eb-282061dee672	466fa3e2-ad68-4bfb-a51e-58f603e24168	06:00:00	{1,2,3,4,5,6}	40	40	2026-02-23	2026-05-24	t	2026-02-23 18:40:21.830783	2026-02-23 18:40:21.830783	\N
beaf6c5f-997d-427b-88fb-c4fbd528b12f	d2c670a8-b0ea-4618-986a-84a61e328ecb	06:00:00	{1,2,3,4,5,6}	40	40	2026-02-23	2026-05-24	t	2026-02-23 18:40:21.830783	2026-02-23 18:40:21.830783	\N
dba78a83-ede2-43e7-8b92-dfe31d0cedd7	c10eaedf-3e18-4d98-b473-783ddd4b22a6	06:00:00	{1,2,3,4,5,6}	40	40	2026-02-23	2026-05-24	t	2026-02-23 18:40:21.830783	2026-02-23 18:40:21.830783	\N
1009e5f9-baf5-4535-aa22-d9d921dfc027	d594417c-236d-43be-9b5e-6866e3ac2cf2	06:00:00	{1,2,3,4,5,6,7}	40	40	2026-02-23	2026-05-24	t	2026-02-23 18:40:21.830783	2026-02-23 18:40:21.830783	\N
7d012e6d-190d-4fc7-a159-b4536fd08841	1a5b903f-8f8a-4003-9458-b83e5c352dbe	06:00:00	{1,2,3,4,5,6}	40	40	2026-02-23	2026-05-24	t	2026-02-23 18:40:21.830783	2026-02-23 18:40:21.830783	\N
c777429d-d501-4e22-9129-b4fb6940a3f4	3f24fd5c-6801-4652-a50a-f592709b8377	06:00:00	{1,2,3,4,5,6}	40	40	2026-02-23	2026-05-24	t	2026-02-23 18:40:21.830783	2026-02-23 18:40:21.830783	\N
064a8f25-909d-4231-9295-42478885ec9c	5937ba7c-f259-4959-946f-054d6c7ca617	06:00:00	{1,2,3,4,5,6}	40	40	2026-02-23	2026-05-24	t	2026-02-23 18:40:21.830783	2026-02-23 18:40:21.830783	\N
2110ca40-6ba9-4be8-84a3-91bd79613a37	0c7e0feb-410d-46c3-8889-b7b29eb1754c	06:00:00	{1,2,3,4,5,6}	40	40	2026-02-23	2026-05-24	t	2026-02-23 18:40:21.830783	2026-02-23 18:40:21.830783	\N
9c690305-f657-4fe6-85b1-39b4e113e132	f0fb030d-6e30-4be2-88e2-dbb371667820	06:00:00	{1,2,3,4,5,6}	40	40	2026-02-23	2026-05-24	t	2026-02-23 18:40:21.830783	2026-02-23 18:40:21.830783	\N
9b4c8627-13cc-4da0-87c6-2f9aa22998ef	b5155823-d5e7-4e4a-a700-58921b9048ee	06:00:00	{1,2,3,4,5,6}	40	40	2026-02-23	2026-05-24	t	2026-02-23 18:40:21.830783	2026-02-23 18:40:21.830783	\N
e5da52ae-4b59-41e7-9eae-6a7daf862b28	2adf02e6-d332-4bd4-91ad-df8b4388299e	06:00:00	{1,2,3,4,5,6,7}	40	40	2026-02-23	2026-05-24	t	2026-02-23 18:40:21.830783	2026-02-23 18:40:21.830783	\N
286d6804-1c0d-4273-9c86-a0905a0d502a	302d8a81-235d-4e5d-be15-0b00a9c34d49	06:00:00	{1,2,3,4,5,6}	40	40	2026-02-23	2026-05-24	t	2026-02-23 18:40:21.830783	2026-02-23 18:40:21.830783	\N
6cd4870e-a94e-481f-90c9-12b2d2b6747e	1bb0272f-54eb-4092-9342-8b946e8788a0	06:00:00	{1,2,3,4,5,6,7}	60	60	2026-01-01	2030-12-31	t	2026-02-25 16:27:04.907953	2026-02-25 16:27:04.907953	\N
0ebb8cfc-a93a-41cb-ae00-36692d4e0960	1bb0272f-54eb-4092-9342-8b946e8788a0	12:00:00	{1,2,3,4,5,6,7}	60	60	2026-01-01	2030-12-31	t	2026-02-25 16:27:04.907953	2026-02-25 16:27:04.907953	\N
e46639ae-2305-4101-9e44-44c59f7b5fb3	5b61af63-d3ec-4915-baf5-fcd3e897de9a	06:00:00	{1,2,3,4,5,6,7}	60	60	2026-01-01	2030-12-31	t	2026-02-25 16:27:04.907953	2026-02-25 16:27:04.907953	\N
9dd92986-d083-4741-a28a-5be7639621bb	5b61af63-d3ec-4915-baf5-fcd3e897de9a	14:00:00	{1,2,3,4,5,6,7}	60	60	2026-01-01	2030-12-31	t	2026-02-25 16:27:04.907953	2026-02-25 16:27:04.907953	\N
4cae921a-24ce-40b1-a639-5c52758b80ed	0436db44-050e-4250-bdf7-f95ffa409b9d	06:00:00	{1,2,3,4,5,6,7}	60	60	2026-01-01	2030-12-31	t	2026-02-25 16:27:04.907953	2026-02-25 16:27:04.907953	\N
32aaaa8e-be53-46d9-8901-5c97913d7bc6	0436db44-050e-4250-bdf7-f95ffa409b9d	14:00:00	{1,2,3,4,5,6,7}	60	60	2026-01-01	2030-12-31	t	2026-02-25 16:27:04.907953	2026-02-25 16:27:04.907953	\N
d744d779-14db-4874-87b1-eb0a5f335d3a	b0cc5c8e-3ece-4401-975f-e9cd3e04cca4	14:30:00	{1,2,3,4,5,6,7}	60	60	2026-01-01	2030-12-31	t	2026-02-25 16:27:04.907953	2026-02-25 16:27:04.907953	\N
b7d4713a-bdbe-4e87-a98f-1da0f0eec45b	e7181d51-7694-41e3-ad39-1f4a25af4cfd	07:30:00	{1,2,3,4,5,6,7}	60	60	2026-01-01	2030-12-31	t	2026-02-25 16:27:04.907953	2026-02-25 16:27:04.907953	\N
58d4f590-dd9c-4c85-bdd4-3dce814209f4	e7181d51-7694-41e3-ad39-1f4a25af4cfd	14:30:00	{1,2,3,4,5,6,7}	60	60	2026-01-01	2030-12-31	t	2026-02-25 16:27:04.907953	2026-02-25 16:27:04.907953	\N
451f85d7-e8ea-4c60-ad57-1bbb982a25f7	bd9b1f0a-61f0-4a70-8045-902aa22365c1	07:00:00	{1,2,3,4,5,6,7}	60	60	2026-01-01	2030-12-31	t	2026-02-25 16:27:04.907953	2026-02-25 16:27:04.907953	\N
8d84b375-6b23-4779-b735-e4d0658968cd	bd9b1f0a-61f0-4a70-8045-902aa22365c1	15:00:00	{1,2,3,4,5,6,7}	60	60	2026-01-01	2030-12-31	t	2026-02-25 16:27:04.907953	2026-02-25 16:27:04.907953	\N
56597b92-0e84-46a0-8281-e092a6d752f9	cf2ae1e1-37b2-4b74-af20-5f2d4e556f36	07:00:00	{1,2,3,4,5,6,7}	60	60	2026-01-01	2030-12-31	t	2026-02-25 16:27:04.907953	2026-02-25 16:27:04.907953	\N
45461aa8-7b73-4ad6-ac90-0b26ee2f0e5d	cf2ae1e1-37b2-4b74-af20-5f2d4e556f36	15:00:00	{1,2,3,4,5,6,7}	60	60	2026-01-01	2030-12-31	t	2026-02-25 16:27:04.907953	2026-02-25 16:27:04.907953	\N
a186d189-f328-4838-9423-4b611e927213	cfd041ee-3dc0-4b0f-b555-3085134cc301	08:00:00	{1,2,3,4,5,6,7}	60	60	2026-01-01	2030-12-31	t	2026-02-25 16:27:04.907953	2026-02-25 16:27:04.907953	\N
118bac4a-af61-496d-a632-d236bde16010	cfd041ee-3dc0-4b0f-b555-3085134cc301	15:00:00	{1,2,3,4,5,6,7}	60	60	2026-01-01	2030-12-31	t	2026-02-25 16:27:04.907953	2026-02-25 16:27:04.907953	\N
651a23f0-30b5-48fb-b92f-a80b75ab225e	ca14a121-b8af-48d7-93e7-c3e2c96c7947	06:00:00	{1,2,3,4,5,6,7}	40	39	2026-02-23	2026-05-24	t	2026-02-23 18:00:42.401153	2026-02-25 17:23:41.570249	\N
c85895db-b37e-49da-83ec-b5674eda83b2	b0cc5c8e-3ece-4401-975f-e9cd3e04cca4	07:30:00	{1,2,3,4,5,6,7}	60	58	2026-01-01	2030-12-31	t	2026-02-25 16:27:04.907953	2026-02-25 22:00:24.051871	\N
432f01a4-6105-4895-b5e6-afa2e1c8b733	92b34d4e-da8c-4ed9-8d64-3a07dedb88f7	07:00:00	{1,2,3,4,5,6,7}	40	40	2026-02-25	2026-05-26	t	2026-02-25 22:26:45.786649	2026-02-25 22:26:45.786649	11:40:00
c1c61222-9376-410c-a710-af6b0f10183e	92b34d4e-da8c-4ed9-8d64-3a07dedb88f7	14:00:00	{1,2,3,4,5,6,7}	40	40	2026-02-25	2026-05-26	t	2026-02-25 22:26:45.786649	2026-02-25 22:26:45.786649	18:40:00
8e9fa342-9327-45f6-89e3-c0f269b6e72a	4d11e3fc-36e7-441a-9b2c-b0e592458e19	06:30:00	{1,2,3,4,5,6,7}	40	40	2026-02-25	2026-05-26	t	2026-02-25 22:26:45.786649	2026-02-25 22:26:45.786649	11:20:00
260f170a-1e20-4d29-a20d-6b7e9413c4b4	4d11e3fc-36e7-441a-9b2c-b0e592458e19	13:00:00	{1,2,3,4,5,6,7}	40	40	2026-02-25	2026-05-26	t	2026-02-25 22:26:45.786649	2026-02-25 22:26:45.786649	17:50:00
8c784161-422e-4ada-b883-a45133d96319	cd95aa15-480f-42a0-a863-60f2896814fb	08:00:00	{1,2,3,4,5,6,7}	40	40	2026-02-25	2026-05-26	t	2026-02-25 22:26:45.786649	2026-02-25 22:26:45.786649	12:30:00
e097b799-6d8c-47af-8de5-35d560b0d887	cd95aa15-480f-42a0-a863-60f2896814fb	16:00:00	{1,2,3,4,5,6,7}	40	40	2026-02-25	2026-05-26	t	2026-02-25 22:26:45.786649	2026-02-25 22:26:45.786649	20:30:00
b650f317-7bd0-47d0-a327-4fb77c07d88e	61565c46-d1ee-4c1a-b043-184dc10db348	07:30:00	{1,2,3,4,5,6,7}	40	40	2026-02-25	2026-05-26	t	2026-02-25 22:26:45.786649	2026-02-25 22:26:45.786649	12:40:00
18601cab-8f91-4a30-ac25-033889bf0354	61565c46-d1ee-4c1a-b043-184dc10db348	13:30:00	{1,2,3,4,5,6,7}	40	40	2026-02-25	2026-05-26	t	2026-02-25 22:26:45.786649	2026-02-25 22:26:45.786649	18:40:00
c529dda9-c2e9-4b41-81ff-2d757148e787	fd593275-8d4d-430f-9754-fbc48499a44c	10:00:00	{1,2,3,4,5,6,7}	40	40	2026-02-25	2026-05-26	t	2026-02-25 22:26:45.786649	2026-02-25 22:26:45.786649	14:55:00
4d5d7661-1239-42e5-97bd-53c828984f96	6b646f38-5b44-4c9a-9bac-1a0df371d24a	07:00:00	{1,2,3,4,5,6,7}	40	40	2026-02-25	2026-05-26	t	2026-02-25 22:26:45.786649	2026-02-25 22:26:45.786649	11:40:00
f9ec7567-2372-48f0-a2bc-4341ea9eefd7	eaed93ea-6ca6-4fbe-b20f-7a878bfa22fa	08:00:00	{1,2,3,4,5,6,7}	40	40	2026-02-25	2026-05-26	t	2026-02-25 22:26:45.786649	2026-02-25 22:26:45.786649	12:50:00
25f2e04c-8949-458c-bdf7-da4585cee7c7	1d165a17-848c-4ba4-8353-9180c2de91d1	09:00:00	{1,2,3,4,5,6,7}	40	40	2026-02-25	2026-05-26	t	2026-02-25 22:26:45.786649	2026-02-25 22:26:45.786649	13:30:00
74c24b6b-f04b-4afe-a07b-7ffac7ba91bc	74504400-e6f4-4143-a1aa-ceff2dc1c94c	08:00:00	{1,2,3,4,5,6,7}	40	40	2026-02-25	2026-05-26	t	2026-02-25 22:26:45.786649	2026-02-25 22:26:45.786649	11:15:00
be7e6204-3045-4373-8f22-c0c624e71be8	a9b6e6bb-2528-459c-bb5e-e38d98d51f0c	09:00:00	{1,2,3,4,5,6,7}	40	40	2026-02-25	2026-05-26	t	2026-02-25 22:26:45.786649	2026-02-25 22:26:45.786649	12:40:00
2bbfa575-2a21-49f6-8572-e8218ed27a11	4d9653e4-121d-4d37-82ce-e9cc584e4722	10:00:00	{1,2,3,4,5,6,7}	40	40	2026-02-25	2026-05-26	t	2026-02-25 22:26:45.786649	2026-02-25 22:26:45.786649	13:20:00
f6562b89-6c4f-437a-9e99-cfc002f1600d	fa760d1c-6d4c-4fd2-b6cf-1f2539efe158	07:00:00	{1,2,3,4,5,6,7}	40	40	2026-02-25	2026-05-26	t	2026-02-25 22:26:45.786649	2026-02-25 22:26:45.786649	08:25:00
31445736-2168-4093-b0dd-1d4ffb130d5a	a704a351-5f4a-4957-88e2-dc903887d8f7	08:00:00	{1,2,3,4,5,6,7}	40	40	2026-02-25	2026-05-26	t	2026-02-25 22:26:45.786649	2026-02-25 22:26:45.786649	09:35:00
0278930a-39fc-4da3-9ad8-81e3b2de100b	6f628bc2-9e7b-4f98-a8f0-fce5039f8f8f	09:00:00	{1,2,3,4,5,6,7}	40	40	2026-02-25	2026-05-26	t	2026-02-25 22:26:45.786649	2026-02-25 22:26:45.786649	10:40:00
92c9f628-03ef-4e71-9f4a-7f570a19aecb	c5af9c1f-0aa5-4443-90cf-567ed9d14b64	07:00:00	{1,2,3,4,5,6,7}	40	40	2026-02-25	2026-05-26	t	2026-02-25 22:26:45.786649	2026-02-25 22:26:45.786649	13:30:00
defd6a03-6892-47d0-9ed7-c1f6b04e890e	0065edd4-d616-4f9e-ad1e-c61dccb965a1	08:00:00	{1,2,3,4,5,6,7}	40	40	2026-02-25	2026-05-26	t	2026-02-25 22:26:45.786649	2026-02-25 22:26:45.786649	14:30:00
99bf2d5d-5070-4e71-9786-5f723e3a2119	106e586a-77e6-420f-b2f4-7d1c97196e12	06:30:00	{1,2,3,4,5,6}	40	40	2026-02-25	2026-05-26	t	2026-02-25 22:26:45.786649	2026-02-25 22:26:45.786649	13:30:00
2921b8a3-4cca-40a7-bcb2-6f706c8f084f	5097a213-fddf-439d-8063-e409133fb0f8	07:00:00	{1,2,3,4,5,6}	40	40	2026-02-25	2026-05-26	t	2026-02-25 22:26:45.786649	2026-02-25 22:26:45.786649	14:00:00
27c850df-b198-42d0-b47e-80c773ed5f3f	c1bfbfc0-0e88-449d-b889-bb2ed525b6c6	17:00:00	{2,4,6}	40	40	2026-02-25	2026-05-26	t	2026-02-25 22:26:45.786649	2026-02-25 22:26:45.786649	14:00:00
506e431c-c99c-43a7-b696-50666c6d6ac6	8f4e8f12-6cf8-43e3-8ca1-4f90f13ef822	18:00:00	{1,3,5}	40	40	2026-02-25	2026-05-26	t	2026-02-25 22:26:45.786649	2026-02-25 22:26:45.786649	15:00:00
c70b3be3-701f-4def-b5f9-b4a9c54036a6	27da7c88-dada-4e9d-8bfc-768569a665fe	16:00:00	{1,3,5,7}	40	40	2026-02-25	2026-05-26	t	2026-02-25 22:26:45.786649	2026-02-25 22:26:45.786649	14:00:00
6d4e5f39-6b7b-4483-b31f-619965d5dd9f	e377c74a-3e48-4fd6-aa4d-76807d903012	17:00:00	{2,4,6}	40	40	2026-02-25	2026-05-26	t	2026-02-25 22:26:45.786649	2026-02-25 22:26:45.786649	15:00:00
4dbad41b-f462-4fa3-9fb5-4c0a3f7e9f50	52de9f8d-89d0-464d-9348-a38938733adf	06:00:00	{1,2,3,4,5,6}	40	40	2026-02-25	2026-05-26	t	2026-02-25 22:26:45.786649	2026-02-25 22:26:45.786649	14:00:00
d4a0f52b-4f57-4c27-8787-06c3edd36418	f3dffffa-39d7-4478-bc0d-69a1dea63f15	07:00:00	{1,2,3,4,5,6}	40	40	2026-02-25	2026-05-26	t	2026-02-25 22:26:45.786649	2026-02-25 22:26:45.786649	15:00:00
8cfcb1e8-c1da-42f3-ac55-7999fa3bd2c7	ae0e041a-1686-4ae4-81b5-c78fb5d50091	08:00:00	{2,4,6}	40	40	2026-02-25	2026-05-26	t	2026-02-25 22:26:45.786649	2026-02-25 22:26:45.786649	23:00:00
c4e4030f-7985-4e85-b6a5-89470c014003	2dde6fed-7382-4a8d-9b24-2620e67331f9	09:00:00	{1,3,5}	40	40	2026-02-25	2026-05-26	t	2026-02-25 22:26:45.786649	2026-02-25 22:26:45.786649	00:00:00
0121663e-4efa-4c1d-a9c9-262178ab27d7	c4c37289-d803-4670-a974-fc3bf46c3d12	08:00:00	{1,2,3,4,5,6,7}	40	40	2026-02-25	2026-05-26	t	2026-02-25 22:26:45.786649	2026-02-25 22:26:45.786649	09:45:00
cd8b84d6-a61c-4d2f-865d-4b4e46a05258	c4c37289-d803-4670-a974-fc3bf46c3d12	14:00:00	{1,2,3,4,5,6,7}	40	40	2026-02-25	2026-05-26	t	2026-02-25 22:26:45.786649	2026-02-25 22:26:45.786649	15:45:00
22788aac-60b0-4b27-9a78-d2f12de20d64	cf96dead-0ad9-4845-aad4-df29970cf22c	09:00:00	{1,2,3,4,5,6,7}	40	40	2026-02-25	2026-05-26	t	2026-02-25 22:26:45.786649	2026-02-25 22:26:45.786649	10:45:00
1678a69a-9a1f-4b03-a216-f8da53513674	cf96dead-0ad9-4845-aad4-df29970cf22c	15:00:00	{1,2,3,4,5,6,7}	40	40	2026-02-25	2026-05-26	t	2026-02-25 22:26:45.786649	2026-02-25 22:26:45.786649	16:45:00
e9beb614-e734-47dc-a200-c0e74ceb8bf1	dd6c1950-30fa-494f-b2a0-7adf64f66ed1	06:00:00	{7}	40	40	2026-02-25	2026-05-26	t	2026-02-25 22:26:45.786649	2026-02-25 22:26:45.786649	00:00:00
6bfbc628-6409-4d52-b422-41ad364b0d0e	17f9f776-b72c-4cb3-b808-d78b110c2834	07:00:00	{1}	40	40	2026-02-25	2026-05-26	t	2026-02-25 22:26:45.786649	2026-02-25 22:26:45.786649	01:00:00
6a99bfad-213e-4f8d-b7b0-096959ce32d8	1bb0272f-54eb-4092-9342-8b946e8788a0	06:00:00	{1,2,3,4,5,6}	40	40	2026-02-25	2026-05-26	t	2026-02-25 22:26:45.786649	2026-02-25 22:26:45.786649	06:35:00
e60a11da-49b6-4f86-9d42-10a616a974a5	6e8d0c7b-ca14-4330-9fc4-0ef0eefdf7e9	06:00:00	{1,2,3,4,5,6}	40	40	2026-02-25	2026-05-26	t	2026-02-25 22:26:45.786649	2026-02-25 22:26:45.786649	06:38:00
aff1e420-7ba8-4701-a42c-fa6b34264e93	8d18a350-61e1-47d5-a4fb-bde2f07affd9	06:00:00	{1,2,3,4,5,6}	40	40	2026-02-25	2026-05-26	t	2026-02-25 22:26:45.786649	2026-02-25 22:26:45.786649	06:55:00
259a4974-b5cf-4298-af03-46987bf1a514	861b502e-e565-4c7d-9af0-096fba747ed8	06:00:00	{1,2,3,4,5,6}	40	40	2026-02-25	2026-05-26	t	2026-02-25 22:26:45.786649	2026-02-25 22:26:45.786649	06:48:00
48690221-84cd-4e46-b94a-a965614404c6	88b96b8c-f1c0-479d-8692-160662dc6181	06:00:00	{1,2,3,4,5,6}	40	40	2026-02-25	2026-05-26	t	2026-02-25 22:26:45.786649	2026-02-25 22:26:45.786649	06:42:00
8ddc0f68-bee2-45f3-abe6-99d5f0ab7da9	466fa3e2-ad68-4bfb-a51e-58f603e24168	06:00:00	{1,2,3,4,5,6}	40	40	2026-02-25	2026-05-26	t	2026-02-25 22:26:45.786649	2026-02-25 22:26:45.786649	06:45:00
55c5cfb0-c9b4-4dcc-8758-1a8d1273bc53	d2c670a8-b0ea-4618-986a-84a61e328ecb	06:00:00	{1,2,3,4,5,6}	40	40	2026-02-25	2026-05-26	t	2026-02-25 22:26:45.786649	2026-02-25 22:26:45.786649	06:40:00
4f2ae01d-2a5f-4886-a60d-32e21f802395	c10eaedf-3e18-4d98-b473-783ddd4b22a6	06:00:00	{1,2,3,4,5,6}	40	40	2026-02-25	2026-05-26	t	2026-02-25 22:26:45.786649	2026-02-25 22:26:45.786649	06:50:00
0f768191-d2b0-4ac0-b5a5-a2171c6668da	d594417c-236d-43be-9b5e-6866e3ac2cf2	06:00:00	{1,2,3,4,5,6,7}	40	40	2026-02-25	2026-05-26	t	2026-02-25 22:26:45.786649	2026-02-25 22:26:45.786649	06:36:00
aabb4c94-69ad-46c8-b544-1b888bbdcd75	1a5b903f-8f8a-4003-9458-b83e5c352dbe	06:00:00	{1,2,3,4,5,6}	40	40	2026-02-25	2026-05-26	t	2026-02-25 22:26:45.786649	2026-02-25 22:26:45.786649	06:43:00
13cb6d4b-61ac-4ab9-ba43-40a752b36ae4	3f24fd5c-6801-4652-a50a-f592709b8377	06:00:00	{1,2,3,4,5,6}	40	40	2026-02-25	2026-05-26	t	2026-02-25 22:26:45.786649	2026-02-25 22:26:45.786649	06:40:00
128fcfa3-aa16-41ee-8f55-f3d15fedfa43	5937ba7c-f259-4959-946f-054d6c7ca617	06:00:00	{1,2,3,4,5,6}	40	40	2026-02-25	2026-05-26	t	2026-02-25 22:26:45.786649	2026-02-25 22:26:45.786649	06:46:00
6e7a443c-9f2e-43cd-994c-e2654bd78f82	0c7e0feb-410d-46c3-8889-b7b29eb1754c	06:00:00	{1,2,3,4,5,6}	40	40	2026-02-25	2026-05-26	t	2026-02-25 22:26:45.786649	2026-02-25 22:26:45.786649	06:44:00
dbf868cf-814d-462a-ad0d-5e9fac85ae90	f0fb030d-6e30-4be2-88e2-dbb371667820	06:00:00	{1,2,3,4,5,6}	40	40	2026-02-25	2026-05-26	t	2026-02-25 22:26:45.786649	2026-02-25 22:26:45.786649	06:52:00
381912f8-0a3a-4e1f-9e18-13d494a63d7f	b5155823-d5e7-4e4a-a700-58921b9048ee	06:00:00	{1,2,3,4,5,6}	40	40	2026-02-25	2026-05-26	t	2026-02-25 22:26:45.786649	2026-02-25 22:26:45.786649	06:50:00
e840df9f-1e6f-4f1e-9bc8-65678a2fe2c1	2adf02e6-d332-4bd4-91ad-df8b4388299e	06:00:00	{1,2,3,4,5,6,7}	40	40	2026-02-25	2026-05-26	t	2026-02-25 22:26:45.786649	2026-02-25 22:26:45.786649	06:34:00
243b68dd-2cfb-4bae-9e2c-5272a702b819	302d8a81-235d-4e5d-be15-0b00a9c34d49	06:00:00	{1,2,3,4,5,6}	40	40	2026-02-25	2026-05-26	t	2026-02-25 22:26:45.786649	2026-02-25 22:26:45.786649	06:48:00
\.


--
-- Data for Name: stops; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.stops (id, line_id, stop_order, city_name, stop_name, latitude, longitude, stop_address, is_pickup_point, is_dropoff_point, created_at) FROM stdin;
d385ccd7-b579-44be-8c41-5f684b7eaac5	8d18a350-61e1-47d5-a4fb-bde2f07affd9	1	Ouagadougou	Tanghin Terminus	12.35140000	-1.51480000	\N	t	t	2026-02-23 18:00:42.401153
34d0b333-afc6-46f8-9313-9cd4c1d4d097	8d18a350-61e1-47d5-a4fb-bde2f07affd9	2	Ouagadougou	Avenue Loudun	12.35980000	-1.52030000	\N	t	t	2026-02-23 18:00:42.401153
e1fba0da-6d82-43a2-a69a-6ca77a874400	8d18a350-61e1-47d5-a4fb-bde2f07affd9	3	Ouagadougou	Place des Nations Unies	12.37140000	-1.52470000	\N	t	t	2026-02-23 18:00:42.401153
801ebff5-ef71-4cc5-980a-7368752856c7	8d18a350-61e1-47d5-a4fb-bde2f07affd9	4	Ouagadougou	Gounghin Centre	12.38210000	-1.52940000	\N	t	t	2026-02-23 18:00:42.401153
f6e05fa4-d864-47dc-9891-0949b6b1ebea	d594417c-236d-43be-9b5e-6866e3ac2cf2	1	Ouagadougou	Aéroport International	12.35320000	-1.51240000	\N	t	t	2026-02-23 18:00:42.401153
0fbacffa-f0b7-4944-aac9-299529059b8b	d594417c-236d-43be-9b5e-6866e3ac2cf2	2	Ouagadougou	Zone du Bois	12.36210000	-1.51870000	\N	t	t	2026-02-23 18:00:42.401153
d30eca39-28bc-4b93-8b53-3dbf19277e28	d594417c-236d-43be-9b5e-6866e3ac2cf2	3	Ouagadougou	Avenue de l'Indépendance	12.37020000	-1.52340000	\N	t	t	2026-02-23 18:00:42.401153
d9084273-c993-4738-ac56-c26af9bdef07	d594417c-236d-43be-9b5e-6866e3ac2cf2	4	Ouagadougou	Centre Ville	12.37140000	-1.52470000	\N	t	t	2026-02-23 18:00:42.401153
c8fc44a4-5fee-4ae6-8208-be5f9efba1f9	8d18a350-61e1-47d5-a4fb-bde2f07affd9	1	Ouagadougou	Tanghin Terminus	12.35140000	-1.51480000	\N	t	t	2026-02-23 18:40:21.830783
cd3d58fa-a238-47fe-88f0-a718b761dec4	8d18a350-61e1-47d5-a4fb-bde2f07affd9	2	Ouagadougou	Avenue Loudun	12.35980000	-1.52030000	\N	t	t	2026-02-23 18:40:21.830783
a2e0508d-4918-40a8-9594-5e6a029d2014	8d18a350-61e1-47d5-a4fb-bde2f07affd9	3	Ouagadougou	Place des Nations Unies	12.37140000	-1.52470000	\N	t	t	2026-02-23 18:40:21.830783
ef8a7d09-f244-4fc5-8e79-40febb3895e4	8d18a350-61e1-47d5-a4fb-bde2f07affd9	4	Ouagadougou	Gounghin Centre	12.38210000	-1.52940000	\N	t	t	2026-02-23 18:40:21.830783
ab6ca5d8-63da-4713-a370-bc2122dfe591	d594417c-236d-43be-9b5e-6866e3ac2cf2	1	Ouagadougou	Aéroport International	12.35320000	-1.51240000	\N	t	t	2026-02-23 18:40:21.830783
0c237fca-03f0-4100-ac16-27d5da7ac32c	d594417c-236d-43be-9b5e-6866e3ac2cf2	2	Ouagadougou	Zone du Bois	12.36210000	-1.51870000	\N	t	t	2026-02-23 18:40:21.830783
04304e07-7851-4885-8ccd-8935740e70b5	d594417c-236d-43be-9b5e-6866e3ac2cf2	3	Ouagadougou	Avenue de l'Indépendance	12.37020000	-1.52340000	\N	t	t	2026-02-23 18:40:21.830783
4f8fd6af-0e61-4c19-aeb7-ab6f6aa6279b	d594417c-236d-43be-9b5e-6866e3ac2cf2	4	Ouagadougou	Centre Ville	12.37140000	-1.52470000	\N	t	t	2026-02-23 18:40:21.830783
daf4d726-5d0d-4ce9-bba6-f4a07da7726c	8d18a350-61e1-47d5-a4fb-bde2f07affd9	1	Ouagadougou	Tanghin Terminus	12.35140000	-1.51480000	\N	t	t	2026-02-25 22:26:45.786649
1b5774a4-62df-430d-8cc2-8a01f4155bd6	8d18a350-61e1-47d5-a4fb-bde2f07affd9	2	Ouagadougou	Avenue Loudun	12.35980000	-1.52030000	\N	t	t	2026-02-25 22:26:45.786649
50d7db7e-11c6-4812-8db0-4171daa3c996	8d18a350-61e1-47d5-a4fb-bde2f07affd9	3	Ouagadougou	Place des Nations Unies	12.37140000	-1.52470000	\N	t	t	2026-02-25 22:26:45.786649
916ea906-92e0-4a6e-aa25-079e82828f53	8d18a350-61e1-47d5-a4fb-bde2f07affd9	4	Ouagadougou	Gounghin Centre	12.38210000	-1.52940000	\N	t	t	2026-02-25 22:26:45.786649
b05ff51c-1ab3-4204-9bc4-a2a8c568eaa2	d594417c-236d-43be-9b5e-6866e3ac2cf2	1	Ouagadougou	Aéroport International	12.35320000	-1.51240000	\N	t	t	2026-02-25 22:26:45.786649
ffb3cd03-235f-4afb-9b2b-0cc73e1cab68	d594417c-236d-43be-9b5e-6866e3ac2cf2	2	Ouagadougou	Zone du Bois	12.36210000	-1.51870000	\N	t	t	2026-02-25 22:26:45.786649
e927f8db-a32b-4e91-8f96-07a22dd12f32	d594417c-236d-43be-9b5e-6866e3ac2cf2	3	Ouagadougou	Avenue de l'Indépendance	12.37020000	-1.52340000	\N	t	t	2026-02-25 22:26:45.786649
25daec97-937a-4429-9a77-793a34bf3bfe	d594417c-236d-43be-9b5e-6866e3ac2cf2	4	Ouagadougou	Centre Ville	12.37140000	-1.52470000	\N	t	t	2026-02-25 22:26:45.786649
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.users (id, phone_number, country_code, profile_picture_url, is_verified, verification_date, created_at, updated_at, last_login, first_name, last_name, date_of_birth, cnib, gender, password_hash, security_q1, security_a1, security_q2, security_a2, google_id, email) FROM stdin;
05050b67-9989-45a1-90c1-ab152ed811b4	+22677123412	+226	\N	f	\N	2026-02-25 15:10:29.231588	2026-02-25 15:10:29.237444	2026-02-25 15:10:29.237444	Test	User	\N	\N	\N	$2a$10$lY6qUzV0doxWGhwFP/.4.OboowP0ds4gLOZ/aZtKUo2Ze1xLu0iJG	Q1	$2a$10$lY6qUzV0doxWGhwFP/.4.OVakGflIizsVlZdB38GQhHYgd3BDeiM6	Q2	$2a$10$lY6qUzV0doxWGhwFP/.4.OA5h6gFI3NsFzaTBToEoLw.7M9tx9ybK	\N	\N
88b7e52b-8fae-4eea-91b2-ea4d6712dcb6	+22657634040	+226	/uploads/88b7e52b-8fae-4eea-91b2-ea4d6712dcb6-1772047936736-213681663.png	f	\N	2026-02-25 15:14:24.032199	2026-02-25 21:51:18.8467	2026-02-25 21:51:18.8467	Armel	KI	\N	\N	\N	$2a$10$xJePDjragq4ddUqrKe5h8OSVJmL1O1KolasLZNntDtwk7bNpsZ8vi	Quel est le nom de votre premier animal de compagnie ?	$2a$10$gBnAbQR4Opc8h2ecgSBev.3Ed28wcMBbobLGjLGcJf1ba6WpTGoSS	Dans quelle ville êtes-vous né(e) ?	$2a$10$gBnAbQR4Opc8h2ecgSBev.qybxhabHcl0y/3k4ark75Q91qFOdKOy	\N	\N
\.


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

\unrestrict qO18A1KdJfqoqlNWwKwEyeM7KIxdtTcUIwLJhouL0Y0XLFpF6ocPpQ7T0qyBC43

