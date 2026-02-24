-- =====================================================
-- ANKATA APP PASSAGERS - MIGRATIONS COMPLÈTES
-- Base de données Transport Burkina Faso 2026
-- Compatible SNCF style, adapté au contexte burkinabé
-- =====================================================

-- Extensions PostgreSQL
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- =====================================================
-- TABLE: users (Utilisateurs de l'application)
-- =====================================================
CREATE TABLE IF NOT EXISTS users (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  phone_number VARCHAR(20) UNIQUE NOT NULL,
  country_code VARCHAR(5) DEFAULT '+226',
  full_name VARCHAR(255),
  email VARCHAR(255) UNIQUE,
  profile_picture_url TEXT,
  date_of_birth DATE,
  gender VARCHAR(10),
  loyalty_points INTEGER DEFAULT 0,
  is_verified BOOLEAN DEFAULT false,
  verification_date TIMESTAMP,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  last_login TIMESTAMP
);

-- Index pour optimiser les recherches par téléphone
CREATE INDEX IF NOT EXISTS idx_users_phone ON users(phone_number);
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);

-- =====================================================
-- TABLE: companies (Compagnies de transport)
-- =====================================================
CREATE TABLE IF NOT EXISTS companies (
  id VARCHAR(50) PRIMARY KEY,
  name VARCHAR(200) NOT NULL,
  slug VARCHAR(100) UNIQUE NOT NULL,
  company_type VARCHAR(20) NOT NULL CHECK (company_type IN ('URBAIN', 'INTERURBAIN', 'INTERNATIONAL')),
  description TEXT,
  logo_url TEXT,
  primary_color VARCHAR(7) NOT NULL,
  secondary_color VARCHAR(7),
  phone VARCHAR(30),
  whatsapp VARCHAR(30),
  email VARCHAR(100),
  website_url VARCHAR(200),
  facebook_url VARCHAR(200),
  headquarters_city VARCHAR(100),
  headquarters_address TEXT,
  rating_average DECIMAL(3,2) DEFAULT 0.00 CHECK (rating_average >= 0 AND rating_average <= 5),
  total_ratings INTEGER DEFAULT 0,
  fleet_size INTEGER,
  badge VARCHAR(50),
  is_active BOOLEAN DEFAULT true,
  suspension_date DATE,
  suspension_reason TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Index pour recherche et tri
CREATE INDEX IF NOT EXISTS idx_companies_slug ON companies(slug);
CREATE INDEX IF NOT EXISTS idx_companies_type ON companies(company_type);
CREATE INDEX IF NOT EXISTS idx_companies_active ON companies(is_active);
CREATE INDEX IF NOT EXISTS idx_companies_rating ON companies(rating_average DESC);

-- =====================================================
-- TABLE: lines (Lignes de transport)
-- =====================================================
CREATE TABLE IF NOT EXISTS lines (
  id VARCHAR(100) PRIMARY KEY,
  company_id VARCHAR(50) NOT NULL REFERENCES companies(id) ON DELETE CASCADE,
  line_code VARCHAR(50) NOT NULL,
  line_name VARCHAR(200) NOT NULL,
  origin_city VARCHAR(100) NOT NULL,
  destination_city VARCHAR(100) NOT NULL,
  origin_address TEXT,
  destination_address TEXT,
  origin_latitude DECIMAL(10, 8),
  origin_longitude DECIMAL(11, 8),
  destination_latitude DECIMAL(10, 8),
  destination_longitude DECIMAL(11, 8),
  distance_km INTEGER,
  duration_minutes INTEGER,
  line_type VARCHAR(20) NOT NULL CHECK (line_type IN ('URBAIN', 'INTERURBAIN', 'INTERNATIONAL')),
  base_price INTEGER,
  student_price INTEGER,
  child_price INTEGER,
  currency VARCHAR(3) DEFAULT 'XOF',
  included_luggage_kg INTEGER DEFAULT 0,
  extra_luggage_price_per_kg INTEGER DEFAULT 0,
  services_included TEXT,
  route_description TEXT,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Index pour optimiser recherches par villes et compagnie
CREATE INDEX IF NOT EXISTS idx_lines_company ON lines(company_id);
CREATE INDEX IF NOT EXISTS idx_lines_cities ON lines(origin_city, destination_city);
CREATE INDEX IF NOT EXISTS idx_lines_type ON lines(line_type);
CREATE INDEX IF NOT EXISTS idx_lines_active ON lines(is_active);
CREATE INDEX IF NOT EXISTS idx_lines_code ON lines(line_code);

-- =====================================================
-- TABLE: stops (Arrêts de bus SOTRACO)
-- =====================================================
CREATE TABLE IF NOT EXISTS stops (
  id VARCHAR(100) PRIMARY KEY,
  stop_name VARCHAR(200) NOT NULL,
  city VARCHAR(100) NOT NULL,
  address TEXT,
  latitude DECIMAL(10, 8),
  longitude DECIMAL(11, 8),
  stop_type VARCHAR(20) CHECK (stop_type IN ('URBAIN', 'GARE', 'TERMINAL')),
  company_id VARCHAR(50) REFERENCES companies(id),
  facilities TEXT,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_stops_city ON stops(city);
CREATE INDEX IF NOT EXISTS idx_stops_company ON stops(company_id);

-- =====================================================
-- TABLE: line_stops (Association lignes ↔ arrêts)
-- =====================================================
CREATE TABLE IF NOT EXISTS line_stops (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  line_id VARCHAR(100) NOT NULL REFERENCES lines(id) ON DELETE CASCADE,
  stop_id VARCHAR(100) NOT NULL REFERENCES stops(id) ON DELETE CASCADE,
  stop_sequence INTEGER NOT NULL,
  arrival_offset_minutes INTEGER,
  departure_offset_minutes INTEGER,
  is_pickup_allowed BOOLEAN DEFAULT true,
  is_dropoff_allowed BOOLEAN DEFAULT true,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE(line_id, stop_sequence)
);

CREATE INDEX IF NOT EXISTS idx_line_stops_line ON line_stops(line_id);
CREATE INDEX IF NOT EXISTS idx_line_stops_stop ON line_stops(stop_id);

-- =====================================================
-- TABLE: schedules (Horaires des lignes)
-- =====================================================
CREATE TABLE IF NOT EXISTS schedules (
  id VARCHAR(100) PRIMARY KEY,
  line_id VARCHAR(100) NOT NULL REFERENCES lines(id) ON DELETE CASCADE,
  departure_time TIME NOT NULL,
  arrival_time TIME,
  days_of_week VARCHAR(50)[] DEFAULT ARRAY['LUNDI', 'MARDI', 'MERCREDI', 'JEUDI', 'VENDREDI', 'SAMEDI', 'DIMANCHE'],
  total_seats INTEGER NOT NULL DEFAULT 60,
  available_seats INTEGER NOT NULL DEFAULT 60,
  vehicle_type VARCHAR(50),
  valid_from DATE NOT NULL DEFAULT CURRENT_DATE,
  valid_until DATE,
  frequency_minutes INTEGER,
  notes TEXT,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_schedules_line ON schedules(line_id);
CREATE INDEX IF NOT EXISTS idx_schedules_departure ON schedules(departure_time);
CREATE INDEX IF NOT EXISTS idx_schedules_active ON schedules(is_active);

-- =====================================================
-- TABLE: bookings (Réservations)
-- =====================================================
CREATE TABLE IF NOT EXISTS bookings (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  booking_code VARCHAR(8) UNIQUE NOT NULL,
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  line_id VARCHAR(100) NOT NULL REFERENCES lines(id),
  schedule_id VARCHAR(100) NOT NULL REFERENCES schedules(id),
  travel_date DATE NOT NULL,
  passenger_name VARCHAR(255) NOT NULL,
  passenger_phone VARCHAR(20) NOT NULL,
  passenger_email VARCHAR(100),
  num_passengers INTEGER DEFAULT 1 CHECK (num_passengers > 0),
  seat_numbers VARCHAR(10)[],
  total_price DECIMAL(10, 2) NOT NULL,
  luggage_weight_kg DECIMAL(5, 2) DEFAULT 0,
  luggage_price DECIMAL(8, 2) DEFAULT 0,
  service_fee DECIMAL(8, 2) DEFAULT 0,
  payment_status VARCHAR(20) DEFAULT 'PENDING' CHECK (payment_status IN ('PENDING', 'PAID', 'FAILED', 'REFUNDED')),
  booking_status VARCHAR(20) DEFAULT 'CONFIRMED' CHECK (booking_status IN ('PENDING', 'CONFIRMED', 'CANCELLED', 'COMPLETED', 'NO_SHOW')),
  payment_method VARCHAR(50),
  transaction_id VARCHAR(100),
  special_requests TEXT,
  cancellation_reason TEXT,
  cancelled_at TIMESTAMP,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_bookings_user ON bookings(user_id);
CREATE INDEX IF NOT EXISTS idx_bookings_code ON bookings(booking_code);
CREATE INDEX IF NOT EXISTS idx_bookings_travel_date ON bookings(travel_date);
CREATE INDEX IF NOT EXISTS idx_bookings_status ON bookings(booking_status);
CREATE INDEX IF NOT EXISTS idx_bookings_line ON bookings(line_id);

-- =====================================================
-- TABLE: payments (Paiements)
-- =====================================================
CREATE TABLE IF NOT EXISTS payments (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  booking_id UUID NOT NULL REFERENCES bookings(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES users(id),
  amount DECIMAL(10, 2) NOT NULL,
  currency VARCHAR(3) DEFAULT 'XOF',
  payment_method VARCHAR(50) NOT NULL,
  payment_provider VARCHAR(50),
  transaction_id VARCHAR(100) UNIQUE,
  provider_reference VARCHAR(100),
  payment_status VARCHAR(20) DEFAULT 'PENDING' CHECK (payment_status IN ('PENDING', 'PROCESSING', 'COMPLETED', 'FAILED', 'REFUNDED')),
  payment_date TIMESTAMP,
  refund_amount DECIMAL(10, 2),
  refund_date TIMESTAMP,
  metadata JSONB,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_payments_booking ON payments(booking_id);
CREATE INDEX IF NOT EXISTS idx_payments_user ON payments(user_id);
CREATE INDEX IF NOT EXISTS idx_payments_status ON payments(payment_status);
CREATE INDEX IF NOT EXISTS idx_payments_transaction ON payments(transaction_id);

-- =====================================================
-- TABLE: ratings (Évaluations)
-- =====================================================
CREATE TABLE IF NOT EXISTS ratings (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  booking_id UUID NOT NULL REFERENCES bookings(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES users(id),
  company_id VARCHAR(50) NOT NULL REFERENCES companies(id),
  line_id VARCHAR(100) NOT NULL REFERENCES lines(id),
  rating INTEGER NOT NULL CHECK (rating >= 1 AND rating <= 5),
  comment TEXT,
  comfort_rating INTEGER CHECK (comfort_rating >= 1 AND comfort_rating <= 5),
  punctuality_rating INTEGER CHECK (punctuality_rating >= 1 AND punctuality_rating <= 5),
  cleanliness_rating INTEGER CHECK (cleanliness_rating >= 1 AND cleanliness_rating <= 5),
  service_rating INTEGER CHECK (service_rating >= 1 AND service_rating <= 5),
  is_verified BOOLEAN DEFAULT false,
  is_visible BOOLEAN DEFAULT true,
  admin_response TEXT,
  admin_response_date TIMESTAMP,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE(booking_id, user_id)
);

CREATE INDEX IF NOT EXISTS idx_ratings_company ON ratings(company_id);
CREATE INDEX IF NOT EXISTS idx_ratings_line ON ratings(line_id);
CREATE INDEX IF NOT EXISTS idx_ratings_user ON ratings(user_id);
CREATE INDEX IF NOT EXISTS idx_ratings_visible ON ratings(is_visible);

-- =====================================================
-- TABLE: otp_codes (Codes OTP pour vérification)
-- =====================================================
CREATE TABLE IF NOT EXISTS otp_codes (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  phone_number VARCHAR(20) NOT NULL,
  otp_code VARCHAR(6) NOT NULL,
  purpose VARCHAR(50) NOT NULL CHECK (purpose IN ('REGISTRATION', 'LOGIN', 'PASSWORD_RESET', 'PHONE_VERIFICATION')),
  is_verified BOOLEAN DEFAULT false,
  attempts INTEGER DEFAULT 0,
  expires_at TIMESTAMP NOT NULL,
  verified_at TIMESTAMP,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_otp_phone ON otp_codes(phone_number);
CREATE INDEX IF NOT EXISTS idx_otp_expires ON otp_codes(expires_at);

-- =====================================================
-- TABLE: notifications (Notifications utilisateur)
-- =====================================================
CREATE TABLE IF NOT EXISTS notifications (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  booking_id UUID REFERENCES bookings(id),
  title VARCHAR(200) NOT NULL,
  message TEXT NOT NULL,
  notification_type VARCHAR(50) NOT NULL,
  is_read BOOLEAN DEFAULT false,
  read_at TIMESTAMP,
  action_url TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_notifications_user ON notifications(user_id);
CREATE INDEX IF NOT EXISTS idx_notifications_read ON notifications(is_read);

-- =====================================================
-- TABLE: company_stats (Statistiques sécurité)
-- =====================================================
CREATE TABLE IF NOT EXISTS company_stats (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  company_id VARCHAR(50) NOT NULL REFERENCES companies(id) ON DELETE CASCADE,
  year INTEGER NOT NULL,
  accidents_count INTEGER DEFAULT 0,
  injuries_count INTEGER DEFAULT 0,
  deaths_count INTEGER DEFAULT 0,
  total_trips INTEGER DEFAULT 0,
  on_time_percentage DECIMAL(5,2),
  safety_score DECIMAL(4,2),
  notes TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE(company_id, year)
);

CREATE INDEX IF NOT EXISTS idx_company_stats_company ON company_stats(company_id);
CREATE INDEX IF NOT EXISTS idx_company_stats_year ON company_stats(year);

-- =====================================================
-- TABLE: promo_codes (Codes promotionnels)
-- =====================================================
CREATE TABLE IF NOT EXISTS promo_codes (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  code VARCHAR(50) UNIQUE NOT NULL,
  description TEXT,
  discount_type VARCHAR(20) NOT NULL CHECK (discount_type IN ('PERCENTAGE', 'FIXED_AMOUNT')),
  discount_value DECIMAL(10,2) NOT NULL,
  min_purchase_amount DECIMAL(10,2),
  max_discount_amount DECIMAL(10,2),
  usage_limit INTEGER,
  usage_count INTEGER DEFAULT 0,
  valid_from DATE NOT NULL,
  valid_until DATE NOT NULL,
  applicable_companies VARCHAR(50)[],
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_promo_codes_code ON promo_codes(code);
CREATE INDEX IF NOT EXISTS idx_promo_codes_active ON promo_codes(is_active);

-- =====================================================
-- FONCTIONS TRIGGER pour updated_at
-- =====================================================
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
   NEW.updated_at = NOW();
   RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Appliquer trigger sur toutes les tables avec updated_at
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users 
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_companies_updated_at BEFORE UPDATE ON companies 
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_lines_updated_at BEFORE UPDATE ON lines 
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_schedules_updated_at BEFORE UPDATE ON schedules 
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_bookings_updated_at BEFORE UPDATE ON bookings 
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_payments_updated_at BEFORE UPDATE ON payments 
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_ratings_updated_at BEFORE UPDATE ON ratings 
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_company_stats_updated_at BEFORE UPDATE ON company_stats 
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- =====================================================
-- FONCTION pour mettre à jour les sièges disponibles
-- =====================================================
CREATE OR REPLACE FUNCTION update_schedule_available_seats()
RETURNS TRIGGER AS $$
BEGIN
  IF (TG_OP = 'INSERT' AND NEW.booking_status IN ('CONFIRMED', 'PENDING')) THEN
    UPDATE schedules 
    SET available_seats = available_seats - NEW.num_passengers
    WHERE id = NEW.schedule_id;
  ELSIF (TG_OP = 'UPDATE') THEN
    IF (OLD.booking_status IN ('CONFIRMED', 'PENDING') AND NEW.booking_status = 'CANCELLED') THEN
      UPDATE schedules 
      SET available_seats = available_seats + OLD.num_passengers
      WHERE id = OLD.schedule_id;
    END IF;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_seats_on_booking 
  AFTER INSERT OR UPDATE ON bookings
  FOR EACH ROW EXECUTE FUNCTION update_schedule_available_seats();

-- =====================================================
-- FONCTION pour mettre à jour rating moyenne compagnie
-- =====================================================
CREATE OR REPLACE FUNCTION update_company_rating()
RETURNS TRIGGER AS $$
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
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_rating_on_insert 
  AFTER INSERT OR UPDATE ON ratings
  FOR EACH ROW EXECUTE FUNCTION update_company_rating();

-- =====================================================
-- VUES UTILES
-- =====================================================

-- Vue pour recherche de trajets disponibles
CREATE OR REPLACE VIEW available_trips AS
SELECT 
  l.id as line_id,
  l.line_code,
  l.line_name,
  l.origin_city,
  l.destination_city,
  l.distance_km,
  l.duration_minutes,
  l.base_price,
  l.line_type,
  s.id as schedule_id,
  s.departure_time,
  s.arrival_time,
  s.total_seats,
  s.available_seats,
  s.days_of_week,
  c.id as company_id,
  c.name as company_name,
  c.slug as company_slug,
  c.primary_color,
  c.secondary_color,
  c.rating_average,
  c.badge,
  c.phone as company_phone
FROM lines l
JOIN schedules s ON l.id = s.line_id
JOIN companies c ON l.company_id = c.id
WHERE l.is_active = true 
  AND s.is_active = true 
  AND c.is_active = true;

-- Vue pour statistiques compagnies
CREATE OR REPLACE VIEW company_performance AS
SELECT 
  c.id,
  c.name,
  c.slug,
  c.rating_average,
  c.total_ratings,
  COUNT(DISTINCT l.id) as total_lines,
  COUNT(DISTINCT b.id) as total_bookings,
  SUM(CASE WHEN b.booking_status = 'COMPLETED' THEN 1 ELSE 0 END) as completed_trips,
  SUM(CASE WHEN b.booking_status = 'CANCELLED' THEN 1 ELSE 0 END) as cancelled_trips
FROM companies c
LEFT JOIN lines l ON c.id = l.company_id
LEFT JOIN bookings b ON l.id = b.line_id
WHERE c.is_active = true
GROUP BY c.id, c.name, c.slug, c.rating_average, c.total_ratings;

-- =====================================================
-- COMMENTAIRES SUR LES TABLES
-- =====================================================
COMMENT ON TABLE companies IS 'Compagnies de transport (SOTRACO, TSR, STAF, RAHIMO, RAKIETA, TCV, SARAMAYA)';
COMMENT ON TABLE lines IS 'Lignes de transport urbaines, interurbaines et internationales';
COMMENT ON TABLE stops IS 'Arrêts de bus et gares routières';
COMMENT ON TABLE schedules IS 'Horaires de départ des lignes';
COMMENT ON TABLE bookings IS 'Réservations de billets';
COMMENT ON TABLE payments IS 'Historique des paiements';
COMMENT ON TABLE ratings IS 'Évaluations des trajets par les utilisateurs';
COMMENT ON TABLE company_stats IS 'Statistiques de sécurité et performance des compagnies';

-- =====================================================
-- FIN DE LA MIGRATION
-- =====================================================
