-- =====================================================
-- SEED: COMPAGNIES DE TRANSPORT BURKINA FASO
-- 7 compagnies principales (Données 2026)
-- =====================================================

-- Nettoyer les données existantes (développement uniquement)
-- TRUNCATE TABLE companies CASCADE;

-- =====================================================
-- 1. SOTRACO (Société de Transport en Commun)
-- =====================================================
INSERT INTO companies (
  id, name, slug, company_type, description,
  primary_color, secondary_color,
  phone, whatsapp, email, website_url, facebook_url,
  headquarters_city, headquarters_address,
  rating_average, total_ratings, fleet_size, badge, is_active,
  suspension_date, suspension_reason
) VALUES (
  'sotraco',
  'SOTRACO - Société de Transport en Commun',
  'sotraco',
  'URBAIN',
  'Leader du transport urbain à Ouagadougou et Bobo-Dioulasso avec une flotte moderne de 530 bus verts climatisés. Service prioritaire pour le transport scolaire et populaire.',
  '#00A859',
  '#00723F',
  '+226 25 35 55 55',
  NULL,
  NULL,
  NULL,
  NULL,
  'Ouagadougou',
  'Siège SOTRACO, Ouagadougou, Kadiogo, Burkina Faso',
  3.50,
  0,
  530,
  'Éco-responsable',
  true,
  NULL,
  NULL
) ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  slug = EXCLUDED.slug,
  company_type = EXCLUDED.company_type,
  description = EXCLUDED.description,
  primary_color = EXCLUDED.primary_color,
  secondary_color = EXCLUDED.secondary_color,
  phone = EXCLUDED.phone,
  headquarters_city = EXCLUDED.headquarters_city,
  headquarters_address = EXCLUDED.headquarters_address,
  fleet_size = EXCLUDED.fleet_size,
  badge = EXCLUDED.badge,
  is_active = EXCLUDED.is_active,
  updated_at = CURRENT_TIMESTAMP;

-- =====================================================
-- 2. TSR (Transport Sana Rasmané)
-- =====================================================
INSERT INTO companies (
  id, name, slug, company_type, description,
  primary_color, secondary_color,
  phone, whatsapp, email, website_url, facebook_url,
  headquarters_city, headquarters_address,
  rating_average, total_ratings, fleet_size, badge, is_active
) VALUES (
  'tsr',
  'TSR - Transport Sana Rasmané',
  'tsr',
  'INTERURBAIN',
  'Compagnie interurbaine reconnue pour ses prix compétitifs sur les liaisons Ouagadougou-Bobo-Dioulasso et internationales vers Abidjan. Service économique.',
  '#1E90FF',
  '#00C853',
  '+226 25 34 25 24',
  NULL,
  NULL,
  'https://tsr-transports.com',
  NULL,
  'Ouagadougou',
  'Avenue Kadiogo, Ouagadougou, Burkina Faso',
  2.50,
  2,
  NULL,
  'Prix bas',
  true
) ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  description = EXCLUDED.description,
  phone = EXCLUDED.phone,
  website_url = EXCLUDED.website_url,
  rating_average = EXCLUDED.rating_average,
  total_ratings = EXCLUDED.total_ratings,
  badge = EXCLUDED.badge,
  updated_at = CURRENT_TIMESTAMP;

-- =====================================================
-- 3. STAF (Société de Transport Afoèma et Frères)
-- =====================================================
INSERT INTO companies (
  id, name, slug, company_type, description,
  primary_color, secondary_color,
  phone, whatsapp, email, website_url, facebook_url,
  headquarters_city, headquarters_address,
  rating_average, total_ratings, fleet_size, badge, is_active,
  suspension_date, suspension_reason
) VALUES (
  'staf',
  'STAF - Société de Transport Afoèma et Frères',
  'staf',
  'INTERURBAIN',
  'Compagnie basée à Bobo-Dioulasso avec 35 bus modernes récents climatisés. Réputée fiable avec un bon rapport qualité-prix. Actuellement suspendue par le ministère pour raisons de sécurité routière.',
  '#FF6B00',
  '#003366',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  'Bobo-Dioulasso',
  'Bobo-Dioulasso, Houet, Burkina Faso',
  4.10,
  1203,
  35,
  'Fiable',
  false,
  '2026-02-16',
  'Suspension ministère sécurité routière suite violations vitesse + 10% accidents secteur'
) ON CONFLICT (id) DO UPDATE SET
  description = EXCLUDED.description,
  rating_average = EXCLUDED.rating_average,
  total_ratings = EXCLUDED.total_ratings,
  fleet_size = EXCLUDED.fleet_size,
  is_active = EXCLUDED.is_active,
  suspension_date = EXCLUDED.suspension_date,
  suspension_reason = EXCLUDED.suspension_reason,
  updated_at = CURRENT_TIMESTAMP;

-- =====================================================
-- 4. RAHIMO Transports
-- =====================================================
INSERT INTO companies (
  id, name, slug, company_type, description,
  primary_color, secondary_color,
  phone, whatsapp, email, website_url, facebook_url,
  headquarters_city, headquarters_address,
  rating_average, total_ratings, fleet_size, badge, is_active
) VALUES (
  'rahimo',
  'RAHIMO Transports',
  'rahimo',
  'INTERURBAIN',
  'Compagnie premium créée en 2011, spécialisée dans le confort haut de gamme avec bus G8 de luxe. Services inclus : AC garanti, sièges inclinables cuir, TV individuelle + USB, collation offerte, assurance voyage. Meilleur service du marché.',
  '#DC143C',
  '#FFD700',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  'Ouagadougou',
  'Ouagadougou, Burkina Faso',
  4.60,
  892,
  NULL,
  'Premium',
  true
) ON CONFLICT (id) DO UPDATE SET
  description = EXCLUDED.description,
  rating_average = EXCLUDED.rating_average,
  total_ratings = EXCLUDED.total_ratings,
  badge = EXCLUDED.badge,
  updated_at = CURRENT_TIMESTAMP;

-- =====================================================
-- 5. RAKIETA Transport
-- =====================================================
INSERT INTO companies (
  id, name, slug, company_type, description,
  primary_color, secondary_color,
  phone, whatsapp, email, website_url, facebook_url,
  headquarters_city, headquarters_address,
  rating_average, total_ratings, fleet_size, badge, is_active
) VALUES (
  'rakieta',
  'CTT RAKIETA',
  'rakieta',
  'INTERURBAIN',
  'Compagnie historique basée à Banfora avec bus bleus climatisés. Excellente couverture nationale et internationale (Mali, Togo, Côte d''Ivoire). Respecte généralement les horaires, tarifs transparents.',
  '#8B0000',
  '#FFD700',
  '+226 20 91 03 07',
  NULL,
  NULL,
  'https://transport-rakieta.com',
  NULL,
  'Banfora',
  'Banfora, Burkina Faso',
  4.30,
  324,
  NULL,
  'Rapide',
  true
) ON CONFLICT (id) DO UPDATE SET
  description = EXCLUDED.description,
  phone = EXCLUDED.phone,
  website_url = EXCLUDED.website_url,
  rating_average = EXCLUDED.rating_average,
  total_ratings = EXCLUDED.total_ratings,
  badge = EXCLUDED.badge,
  updated_at = CURRENT_TIMESTAMP;

-- =====================================================
-- 6. TCV (Transport Confort Voyageurs)
-- =====================================================
INSERT INTO companies (
  id, name, slug, company_type, description,
  primary_color, secondary_color,
  phone, whatsapp, email, website_url, facebook_url,
  headquarters_city, headquarters_address,
  rating_average, total_ratings, fleet_size, badge, is_active
) VALUES (
  'tcv',
  'TCV - Transport Confort Voyageurs',
  'tcv',
  'INTERURBAIN',
  'Compagnie établie avec gare internationale ZAD Ouagadougou. Large réseau vers Afrique de l''Ouest (Mali, Togo, Bénin, Côte d''Ivoire). Réputation en déclin récent (retards fréquents, AC en panne). Prix milieu de gamme.',
  '#006400',
  '#FFD700',
  '+226 25 30 14 12',
  NULL,
  NULL,
  NULL,
  NULL,
  'Ouagadougou',
  'ZAD (Zone Activités Diverses), près SONABEL, face Plan Burkina, Ouagadougou',
  3.00,
  5,
  NULL,
  'Milieu de gamme',
  true
) ON CONFLICT (id) DO UPDATE SET
  description = EXCLUDED.description,
  phone = EXCLUDED.phone,
  headquarters_address = EXCLUDED.headquarters_address,
  rating_average = EXCLUDED.rating_average,
  total_ratings = EXCLUDED.total_ratings,
  badge = EXCLUDED.badge,
  updated_at = CURRENT_TIMESTAMP;

-- =====================================================
-- 7. SARAMAYA Transport
-- =====================================================
INSERT INTO companies (
  id, name, slug, company_type, description,
  primary_color, secondary_color,
  phone, whatsapp, email, website_url, facebook_url,
  headquarters_city, headquarters_address,
  rating_average, total_ratings, fleet_size, badge, is_active
) VALUES (
  'saramaya',
  'Saramaya Transport',
  'saramaya',
  'INTERURBAIN',
  'Compagnie récente fiable et ponctuelle basée à Bobo-Dioulasso. Deux gammes : bus ordinaire climatisé et bus VIP (sièges extra-larges, TV individuelle, USB, boisson offerte). Excellent confort.',
  '#0044AA',
  '#F5A623',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  'Bobo-Dioulasso',
  'Quartier Tounouma, Boulevard de la Révolution, Bobo-Dioulasso',
  2.50,
  1,
  NULL,
  'Confort',
  true
) ON CONFLICT (id) DO UPDATE SET
  description = EXCLUDED.description,
  headquarters_address = EXCLUDED.headquarters_address,
  rating_average = EXCLUDED.rating_average,
  total_ratings = EXCLUDED.total_ratings,
  badge = EXCLUDED.badge,
  updated_at = CURRENT_TIMESTAMP;

-- =====================================================
-- STATISTIQUES SÉCURITÉ 2019-2024 (Optionnel)
-- =====================================================

-- STAF (Le plus d'accidents)
INSERT INTO company_stats (company_id, year, accidents_count, injuries_count, deaths_count, notes)
VALUES 
  ('staf', 2024, 136, 191, 57, 'Données ministère Transports 2019-2024 cumulées')
ON CONFLICT (company_id, year) DO UPDATE SET
  accidents_count = EXCLUDED.accidents_count,
  injuries_count = EXCLUDED.injuries_count,
  deaths_count = EXCLUDED.deaths_count,
  notes = EXCLUDED.notes;

-- TSR
INSERT INTO company_stats (company_id, year, accidents_count, injuries_count, deaths_count, notes)
VALUES 
  ('tsr', 2024, 105, 164, 61, 'Données ministère Transports 2019-2024 cumulées')
ON CONFLICT (company_id, year) DO UPDATE SET
  accidents_count = EXCLUDED.accidents_count,
  injuries_count = EXCLUDED.injuries_count,
  deaths_count = EXCLUDED.deaths_count,
  notes = EXCLUDED.notes;

-- RAHIMO (Meilleure sécurité premium)
INSERT INTO company_stats (company_id, year, deaths_count, notes)
VALUES 
  ('rahimo', 2024, 19, 'Données ministère Transports 2019-2024. Meilleur ratio pour catégorie premium.')
ON CONFLICT (company_id, year) DO UPDATE SET
  deaths_count = EXCLUDED.deaths_count,
  notes = EXCLUDED.notes;

-- SARAMAYA
INSERT INTO company_stats (company_id, year, deaths_count, notes)
VALUES 
  ('saramaya', 2024, 10, 'Données ministère Transports 2019-2024')
ON CONFLICT (company_id, year) DO UPDATE SET
  deaths_count = EXCLUDED.deaths_count,
  notes = EXCLUDED.notes;

-- SOTRACO (Urbain, meilleure sécurité)
INSERT INTO company_stats (company_id, year, deaths_count, notes)
VALUES 
  ('sotraco', 2024, 6, 'Données ministère Transports 2019-2024. Transport urbain, distances courtes.')
ON CONFLICT (company_id, year) DO UPDATE SET
  deaths_count = EXCLUDED.deaths_count,
  notes = EXCLUDED.notes;

-- TCV (Meilleur record)
INSERT INTO company_stats (company_id, year, deaths_count, notes)
VALUES 
  ('tcv', 2024, 2, 'Données ministère Transports 2019-2024. Meilleur record sécurité.')
ON CONFLICT (company_id, year) DO UPDATE SET
  deaths_count = EXCLUDED.deaths_count,
  notes = EXCLUDED.notes;

-- =====================================================
-- VÉRIFICATIONS
-- =====================================================

-- Nombre de compagnies actives (doit être 6, STAF suspendue)
SELECT COUNT(*) as compagnies_actives FROM companies WHERE is_active = true;

-- Toutes les compagnies avec leurs infos principales
SELECT 
  id,
  name,
  company_type,
  headquarters_city,
  rating_average,
  badge,
  CASE WHEN is_active THEN 'Actif' ELSE 'Suspendu' END as statut
FROM companies
ORDER BY rating_average DESC;

-- =====================================================
-- FIN DU SEED COMPANIES
-- =====================================================


-- UPDATE LOGOS
UPDATE companies SET logo_url = 'assets/images/companies/' || slug || '.png';
