-- =====================================================
-- SEED: LIGNES DE TRANSPORT BURKINA FASO
-- 18 lignes SOTRACO urbaines + 40+ lignes interurbaines/internationales
-- =====================================================

-- =====================================================
-- SECTION 1: LIGNES URBAINES SOTRACO OUAGADOUGOU (18 lignes)
-- =====================================================

-- L1: Karpala ↔ Place Naaba Koom
INSERT INTO lines (
  id, company_id, line_code, line_name,
  origin_city, destination_city, origin_address, destination_address,
  distance_km, duration_minutes, line_type,
  base_price, student_price, child_price,
  included_luggage_kg, services_included, is_active
) VALUES (
  'sotraco_l1', 'sotraco', 'L1', 'Karpala ↔ Place Naaba Koom',
  'Ouagadougou', 'Ouagadougou', 'Karpala', 'Place Naaba Koom',
  10, 35, 'URBAIN',
  NULL, NULL, NULL,
  0, 'Bus climatisé moderne, transport scolaire prioritaire', true
) ON CONFLICT (id) DO UPDATE SET
  line_name = EXCLUDED.line_name,
  distance_km = EXCLUDED.distance_km,
  duration_minutes = EXCLUDED.duration_minutes,
  services_included = EXCLUDED.services_included,
  updated_at = CURRENT_TIMESTAMP;

-- L2: 2 Boutiques ↔ Place Naaba Koom
INSERT INTO lines (
  id, company_id, line_code, line_name,
  origin_city, destination_city, origin_address, destination_address,
  distance_km, duration_minutes, line_type,
  base_price, included_luggage_kg, is_active
) VALUES (
  'sotraco_l2', 'sotraco', 'L2', '2 Boutiques ↔ Place Naaba Koom',
  'Ouagadougou', 'Ouagadougou', '2 Boutiques', 'Place Naaba Koom',
  8, 30, 'URBAIN',
  NULL, 0, true
) ON CONFLICT (id) DO UPDATE SET
  line_name = EXCLUDED.line_name,
  updated_at = CURRENT_TIMESTAMP;

-- L2B: Balkuy ↔ Place Naaba Koom (La plus longue ligne urbaine)
INSERT INTO lines (
  id, company_id, line_code, line_name,
  origin_city, destination_city, origin_address, destination_address,
  distance_km, duration_minutes, line_type,
  base_price, included_luggage_kg, route_description, is_active
) VALUES (
  'sotraco_l2b', 'sotraco', 'L2B', 'Balkuy ↔ Place Naaba Koom',
  'Ouagadougou', 'Ouagadougou', 'Balkuy', 'Place Naaba Koom',
  18, 55, 'URBAIN',
  NULL, 0, 'Ligne la plus longue du réseau SOTRACO avec 39 arrêts', true
) ON CONFLICT (id) DO UPDATE SET
  distance_km = EXCLUDED.distance_km,
  route_description = EXCLUDED.route_description,
  updated_at = CURRENT_TIMESTAMP;

-- L3: Terminus de Bissighin ↔ Zones de Écoles
INSERT INTO lines (
  id, company_id, line_code, line_name,
  origin_city, destination_city, origin_address, destination_address,
  distance_km, duration_minutes, line_type,
  base_price, included_luggage_kg, services_included, is_active
) VALUES (
  'sotraco_l3', 'sotraco', 'L3', 'Terminus de Bissighin ↔ Zones de Écoles',
  'Ouagadougou', 'Ouagadougou', 'Terminus de Bissighin', 'Zones de Écoles',
  12, 40, 'URBAIN',
  NULL, 0, 'Fréquence 10-15 min en heures normales, horaires détaillés disponibles', true
) ON CONFLICT (id) DO UPDATE SET
  services_included = EXCLUDED.services_included,
  updated_at = CURRENT_TIMESTAMP;

-- L4: Terminus Sandogo II ↔ Zones de Écoles
INSERT INTO lines (
  id, company_id, line_code, line_name,
  origin_city, destination_city, origin_address, destination_address,
  distance_km, duration_minutes, line_type,
  base_price, included_luggage_kg, is_active
) VALUES (
  'sotraco_l4', 'sotraco', 'L4', 'Terminus Sandogo II ↔ Zones de Écoles',
  'Ouagadougou', 'Ouagadougou', 'Terminus Sandogo II', 'Zones de Écoles',
  11, 38, 'URBAIN',
  NULL, 0, true
) ON CONFLICT (id) DO UPDATE SET
  line_name = EXCLUDED.line_name,
  updated_at = CURRENT_TIMESTAMP;

-- L5: Signoghin ↔ Place Naaba Koom
INSERT INTO lines (
  id, company_id, line_code, line_name,
  origin_city, destination_city, origin_address, destination_address,
  distance_km, duration_minutes, line_type,
  base_price, included_luggage_kg, is_active
) VALUES (
  'sotraco_l5', 'sotraco', 'L5', 'Signoghin ↔ Place Naaba Koom',
  'Ouagadougou', 'Ouagadougou', 'Signoghin', 'Place Naaba Koom',
  9, 32, 'URBAIN',
  NULL, 0, true
) ON CONFLICT (id) DO UPDATE SET
  line_name = EXCLUDED.line_name,
  updated_at = CURRENT_TIMESTAMP;

-- L6: Koulweoguin ↔ Place Naaba Koom
INSERT INTO lines (
  id, company_id, line_code, line_name,
  origin_city, destination_city, origin_address, destination_address,
  distance_km, duration_minutes, line_type,
  base_price, included_luggage_kg, is_active
) VALUES (
  'sotraco_l6', 'sotraco', 'L6', 'Koulweoguin ↔ Place Naaba Koom',
  'Ouagadougou', 'Ouagadougou', 'Koulweoguin', 'Place Naaba Koom',
  10, 35, 'URBAIN',
  NULL, 0, true
) ON CONFLICT (id) DO UPDATE SET
  line_name = EXCLUDED.line_name,
  updated_at = CURRENT_TIMESTAMP;

-- L6B: Terminus du Péage ↔ Place Naaba Koom
INSERT INTO lines (
  id, company_id, line_code, line_name,
  origin_city, destination_city, origin_address, destination_address,
  distance_km, duration_minutes, line_type,
  base_price, included_luggage_kg, services_included, is_active
) VALUES (
  'sotraco_l6b', 'sotraco', 'L6B', 'Terminus du Péage ↔ Place Naaba Koom',
  'Ouagadougou', 'Ouagadougou', 'Terminus du Péage', 'Place Naaba Koom',
  14, 48, 'URBAIN',
  NULL, 0, 'Fréquence 6-8 min heures pointe, horaires détaillés disponibles', true
) ON CONFLICT (id) DO UPDATE SET
  services_included = EXCLUDED.services_included,
  updated_at = CURRENT_TIMESTAMP;

-- L10: Terminus Tengandogo ↔ Zones de Écoles
INSERT INTO lines (
  id, company_id, line_code, line_name,
  origin_city, destination_city, origin_address, destination_address,
  distance_km, duration_minutes, line_type,
  base_price, included_luggage_kg, is_active
) VALUES (
  'sotraco_l10', 'sotraco', 'L10', 'Terminus Tengandogo ↔ Zones de Écoles',
  'Ouagadougou', 'Ouagadougou', 'Terminus Tengandogo', 'Zones de Écoles',
  13, 45, 'URBAIN',
  NULL, 0, true
) ON CONFLICT (id) DO UPDATE SET
  line_name = EXCLUDED.line_name,
  updated_at = CURRENT_TIMESTAMP;

-- L11 à L19 (Données terminus à confirmer)
INSERT INTO lines (id, company_id, line_code, line_name, origin_city, destination_city, line_type, is_active)
VALUES 
  ('sotraco_l11', 'sotraco', 'L11', 'Ligne L11 (Terminus à confirmer)', 'Ouagadougou', 'Ouagadougou', 'URBAIN', true),
  ('sotraco_l12', 'sotraco', 'L12', 'Ligne L12 (Terminus à confirmer)', 'Ouagadougou', 'Ouagadougou', 'URBAIN', true),
  ('sotraco_l13', 'sotraco', 'L13', 'Ligne L13 (Terminus à confirmer)', 'Ouagadougou', 'Ouagadougou', 'URBAIN', true),
  ('sotraco_l14', 'sotraco', 'L14', 'Ligne L14 (Terminus à confirmer)', 'Ouagadougou', 'Ouagadougou', 'URBAIN', true),
  ('sotraco_l15', 'sotraco', 'L15', 'Ligne L15 (Terminus à confirmer)', 'Ouagadougou', 'Ouagadougou', 'URBAIN', true),
  ('sotraco_l16', 'sotraco', 'L16', 'Ligne L16 (Terminus à confirmer)', 'Ouagadougou', 'Ouagadougou', 'URBAIN', true),
  ('sotraco_l17', 'sotraco', 'L17', 'Ligne L17 (Terminus à confirmer)', 'Ouagadougou', 'Ouagadougou', 'URBAIN', true),
  ('sotraco_l18', 'sotraco', 'L18', 'Ligne L18 (Terminus à confirmer)', 'Ouagadougou', 'Ouagadougou', 'URBAIN', true),
  ('sotraco_l19', 'sotraco', 'L19', 'Ligne L19 (Terminus à confirmer)', 'Ouagadougou', 'Ouagadougou', 'URBAIN', true)
ON CONFLICT (id) DO NOTHING;

-- =====================================================
-- SECTION 2: LIGNES INTERURBAINES NATIONALES
-- =====================================================

-- ========== OUAGADOUGOU ↔ BOBO-DIOULASSO (Trajet le plus fréquenté) ==========

-- TSR Ouaga-Bobo (Prix bas)
INSERT INTO lines (
  id, company_id, line_code, line_name,
  origin_city, destination_city,
  distance_km, duration_minutes, line_type,
  base_price, included_luggage_kg, extra_luggage_price_per_kg,
  services_included, is_active
) VALUES (
  'tsr_ouaga_bobo', 'tsr', 'OUA-BOB-TSR', 'Ouagadougou ↔ Bobo-Dioulasso',
  'Ouagadougou', 'Bobo-Dioulasso',
  360, 330, 'INTERURBAIN',
  4500, 20, 0,
  '1 bagage soute inclus (20 kg), climatisation', true
) ON CONFLICT (id) DO UPDATE SET
  base_price = EXCLUDED.base_price,
  services_included = EXCLUDED.services_included,
  updated_at = CURRENT_TIMESTAMP;

-- STAF Ouaga-Bobo (Fiable - actuellement suspendu)
INSERT INTO lines (
  id, company_id, line_code, line_name,
  origin_city, destination_city,
  distance_km, duration_minutes, line_type,
  base_price, included_luggage_kg,
  services_included, is_active
) VALUES (
  'staf_ouaga_bobo', 'staf', 'OUA-BOB-STAF', 'Ouagadougou ↔ Bobo-Dioulasso',
  'Ouagadougou', 'Bobo-Dioulasso',
  360, 300, 'INTERURBAIN',
  6500, 25,
  'Bus récents climatisés, confort moderne', false
) ON CONFLICT (id) DO UPDATE SET
  is_active = false,
  updated_at = CURRENT_TIMESTAMP;

-- RAHIMO Ouaga-Bobo (Premium)
INSERT INTO lines (
  id, company_id, line_code, line_name,
  origin_city, destination_city,
  distance_km, duration_minutes, line_type,
  base_price, included_luggage_kg,
  services_included, is_active
) VALUES (
  'rahimo_ouaga_bobo', 'rahimo', 'OUA-BOB-RAHIMO', 'Ouagadougou ↔ Bobo-Dioulasso',
  'Ouagadougou', 'Bobo-Dioulasso',
  360, 300, 'INTERURBAIN',
  6500, 30,
  'AC garanti 100%, sièges inclinables cuir, TV individuelle + USB, collation offerte, assurance voyage', true
) ON CONFLICT (id) DO UPDATE SET
  services_included = EXCLUDED.services_included,
  updated_at = CURRENT_TIMESTAMP;

-- RAHIMO Ouaga-Bobo VIP
INSERT INTO lines (
  id, company_id, line_code, line_name,
  origin_city, destination_city,
  distance_km, duration_minutes, line_type,
  base_price, included_luggage_kg,
  services_included, is_active
) VALUES (
  'rahimo_ouaga_bobo_vip', 'rahimo', 'OUA-BOB-RAHIMO-VIP', 'Ouagadougou ↔ Bobo-Dioulasso VIP',
  'Ouagadougou', 'Bobo-Dioulasso',
  360, 300, 'INTERURBAIN',
  8000, 30,
  'Classe VIP : tous services premium + sièges extra-larges + service prioritaire', true
) ON CONFLICT (id) DO UPDATE SET
  base_price = EXCLUDED.base_price,
  updated_at = CURRENT_TIMESTAMP;

-- RAKIETA Ouaga-Bobo (Rapide)
INSERT INTO lines (
  id, company_id, line_code, line_name,
  origin_city, destination_city,
  distance_km, duration_minutes, line_type,
  base_price, included_luggage_kg,
  services_included, is_active
) VALUES (
  'rakieta_ouaga_bobo', 'rakieta', 'OUA-BOB-RAKIETA', 'Ouagadougou ↔ Bobo-Dioulasso',
  'Ouagadougou', 'Bobo-Dioulasso',
  360, 300, 'INTERURBAIN',
  7500, 20,
  'Bus bleus climatisés, 1 bagage soute inclus, ponctualité respectée', true
) ON CONFLICT (id) DO UPDATE SET
  base_price = 7500,
  updated_at = CURRENT_TIMESTAMP;

-- TCV Ouaga-Bobo (Milieu de gamme)
INSERT INTO lines (
  id, company_id, line_code, line_name,
  origin_city, destination_city,
  distance_km, duration_minutes, line_type,
  base_price, included_luggage_kg,
  services_included, is_active
) VALUES (
  'tcv_ouaga_bobo', 'tcv', 'OUA-BOB-TCV', 'Ouagadougou ↔ Bobo-Dioulasso',
  'Ouagadougou', 'Bobo-Dioulasso',
  360, 360, 'INTERURBAIN',
  6500, 20,
  'Départs quotidiens, climatisation (parfois en panne)', true
) ON CONFLICT (id) DO UPDATE SET
  base_price = 6500,
  duration_minutes = 360,
  updated_at = CURRENT_TIMESTAMP;

-- SARAMAYA Ouaga-Bobo (Confort)
INSERT INTO lines (
  id, company_id, line_code, line_name,
  origin_city, destination_city,
  distance_km, duration_minutes, line_type,
  base_price, included_luggage_kg,
  services_included, is_active
) VALUES (
  'saramaya_ouaga_bobo', 'saramaya', 'OUA-BOB-SARAMAYA', 'Ouagadougou ↔ Bobo-Dioulasso',
  'Ouagadougou', 'Bobo-Dioulasso',
  360, 300, 'INTERURBAIN',
  6000, 25,
  'Bus ordinaire climatisé, compagnie fiable et ponctuelle', true
) ON CONFLICT (id) DO UPDATE SET
  base_price = 6000,
  updated_at = CURRENT_TIMESTAMP;

-- SARAMAYA Ouaga-Bobo VIP
INSERT INTO lines (
  id, company_id, line_code, line_name,
  origin_city, destination_city,
  distance_km, duration_minutes, line_type,
  base_price, included_luggage_kg,
  services_included, is_active
) VALUES (
  'saramaya_ouaga_bobo_vip', 'saramaya', 'OUA-BOB-SARAMAYA-VIP', 'Ouagadougou ↔ Bobo-Dioulasso VIP',
  'Ouagadougou', 'Bobo-Dioulasso',
  360, 300, 'INTERURBAIN',
  7500, 25,
  'Bus VIP : sièges extra-larges (3/rangée au lieu de 4), TV individuelle, USB, boisson offerte', true
) ON CONFLICT (id) DO UPDATE SET
  base_price = 7500,
  updated_at = CURRENT_TIMESTAMP;

-- ========== AUTRES DESTINATIONS NATIONALES ==========

-- RAKIETA Ouaga-Banfora
INSERT INTO lines (
  id, company_id, line_code, line_name,
  origin_city, destination_city,
  distance_km, duration_minutes, line_type,
  base_price, included_luggage_kg, is_active
) VALUES (
  'rakieta_ouaga_banfora', 'rakieta', 'OUA-BAN-RAKIETA', 'Ouagadougou ↔ Banfora',
  'Ouagadougou', 'Banfora',
  440, 540, 'INTERURBAIN',
  9000, 20, true
) ON CONFLICT (id) DO UPDATE SET
  base_price = 9000,
  updated_at = CURRENT_TIMESTAMP;

-- RAKIETA Ouaga-Niangoloko
INSERT INTO lines (
  id, company_id, line_code, line_name,
  origin_city, destination_city,
  distance_km, duration_minutes, line_type,
  base_price, included_luggage_kg, is_active
) VALUES (
  'rakieta_ouaga_niangoloko', 'rakieta', 'OUA-NIA-RAKIETA', 'Ouagadougou ↔ Niangoloko',
  'Ouagadougou', 'Niangoloko',
  500, 600, 'INTERURBAIN',
  9500, 20, true
) ON CONFLICT (id) DO UPDATE SET
  base_price = 9500,
  updated_at = CURRENT_TIMESTAMP;

-- TCV Ouaga-Boromo
INSERT INTO lines (
  id, company_id, line_code, line_name,
  origin_city, destination_city,
  distance_km, duration_minutes, line_type,
  base_price, included_luggage_kg,
  services_included, is_active
) VALUES (
  'tcv_ouaga_boromo', 'tcv', 'OUA-BOR-TCV', 'Ouagadougou ↔ Boromo',
  'Ouagadougou', 'Boromo',
  180, 180, 'INTERURBAIN',
  3500, 20,
  'Départs quotidiens, tarif officiel 2018', true
) ON CONFLICT (id) DO UPDATE SET
  base_price = 3500,
  updated_at = CURRENT_TIMESTAMP;

-- =====================================================
-- SECTION 3: LIGNES INTERNATIONALES
-- =====================================================

-- ========== BURKINA FASO ↔ CÔTE D'IVOIRE ==========

-- RAKIETA Ouaga-Abidjan
INSERT INTO lines (
  id, company_id, line_code, line_name,
  origin_city, destination_city,
  distance_km, duration_minutes, line_type,
  base_price, included_luggage_kg,
  services_included, is_active
) VALUES (
  'rakieta_ouaga_abidjan', 'rakieta', 'OUA-ABJ-RAKIETA', 'Ouagadougou ↔ Abidjan (Côte d''Ivoire)',
  'Ouagadougou', 'Abidjan',
  1000, 1200, 'INTERNATIONAL',
  32500, 20,
  'Voyage international, 1 bagage soute inclus (20 kg), climatisation', true
) ON CONFLICT (id) DO UPDATE SET
  base_price = 32500,
  updated_at = CURRENT_TIMESTAMP;

-- TCV Ouaga-Abidjan Direct
INSERT INTO lines (
  id, company_id, line_code, line_name,
  origin_city, destination_city,
  distance_km, duration_minutes, line_type,
  base_price, included_luggage_kg,
  services_included, is_active
) VALUES (
  'tcv_ouaga_abidjan', 'tcv', 'OUA-ABJ-TCV', 'Ouagadougou ↔ Abidjan Direct',
  'Ouagadougou', 'Abidjan',
  1000, 1200, 'INTERNATIONAL',
  25000, 20,
  'Départs quotidiens, liaison directe, tarif officiel 2018', true
) ON CONFLICT (id) DO UPDATE SET
  base_price = 25000,
  updated_at = CURRENT_TIMESTAMP;

-- TSR Abidjan-Ouaga
INSERT INTO lines (
  id, company_id, line_code, line_name,
  origin_city, destination_city,
  origin_address, distance_km, duration_minutes, line_type,
  base_price, included_luggage_kg,
  services_included, is_active
) VALUES (
  'tsr_abidjan_ouaga', 'tsr', 'ABJ-OUA-TSR', 'Abidjan ↔ Ouagadougou',
  'Abidjan', 'Ouagadougou',
  'Port-Bouët 2, Abidjan', 1000, 1200, 'INTERNATIONAL',
  30100, 20,
  'Départ 18:30 GMT depuis gare Port-Bouët 2. Contact: +225 0778050230 / 0757796032', true
) ON CONFLICT (id) DO UPDATE SET
  base_price = 30100,
  updated_at = CURRENT_TIMESTAMP;

-- RAKIETA Ouaga-Bouaké
INSERT INTO lines (
  id, company_id, line_code, line_name,
  origin_city, destination_city,
  distance_km, duration_minutes, line_type,
  base_price, included_luggage_kg, is_active
) VALUES (
  'rakieta_ouaga_bouake', 'rakieta', 'OUA-BKE-RAKIETA', 'Ouagadougou ↔ Bouaké (Côte d''Ivoire)',
  'Ouagadougou', 'Bouaké',
  700, 840, 'INTERNATIONAL',
  26500, 20, true
) ON CONFLICT (id) DO UPDATE SET
  base_price = 26500,
  updated_at = CURRENT_TIMESTAMP;

-- ========== BURKINA FASO ↔ TOGO ==========

-- RAKIETA Ouaga-Lomé
INSERT INTO lines (
  id, company_id, line_code, line_name,
  origin_city, destination_city,
  distance_km, duration_minutes, line_type,
  base_price, included_luggage_kg,
  services_included, is_active
) VALUES (
  'rakieta_ouaga_lome', 'rakieta', 'OUA-LOM-RAKIETA', 'Ouagadougou ↔ Lomé (Togo)',
  'Ouagadougou', 'Lomé',
  900, 1020, 'INTERNATIONAL',
  20000, 20,
  'Destinations internationales : Lomé, Kara, Atakpamé, Sokodé. Réservation 72h avance recommandée.', true
) ON CONFLICT (id) DO UPDATE SET
  base_price = 20000,
  updated_at = CURRENT_TIMESTAMP;

-- TCV Ouaga-Lomé (1 départ hebdo)
INSERT INTO lines (
  id, company_id, line_code, line_name,
  origin_city, destination_city,
  distance_km, duration_minutes, line_type,
  base_price, included_luggage_kg,
  services_included, is_active
) VALUES (
  'tcv_ouaga_lome', 'tcv', 'OUA-LOM-TCV', 'Ouagadougou ↔ Lomé (Togo)',
  'Ouagadougou', 'Lomé',
  900, 1080, 'INTERNATIONAL',
  20000, 20,
  '1 départ/semaine : Dimanche 06h00. Tarif officiel 2018.', true
) ON CONFLICT (id) DO UPDATE SET
  base_price = 20000,
  updated_at = CURRENT_TIMESTAMP;

-- ========== BURKINA FASO ↔ BÉNIN ==========

-- TCV Ouaga-Cotonou
INSERT INTO lines (
  id, company_id, line_code, line_name,
  origin_city, destination_city,
  distance_km, duration_minutes, line_type,
  base_price, included_luggage_kg,
  services_included, is_active
) VALUES (
  'tcv_ouaga_cotonou', 'tcv', 'OUA-COT-TCV', 'Ouagadougou ↔ Cotonou (Bénin)',
  'Ouagadougou', 'Cotonou',
  1100, 1320, 'INTERNATIONAL',
  22000, 20,
  'Départs quotidiens, tarif officiel 2018', true
) ON CONFLICT (id) DO UPDATE SET
  base_price = 22000,
  updated_at = CURRENT_TIMESTAMP;

-- ========== BURKINA FASO ↔ MALI ==========

-- RAKIETA Ouaga-Bamako
INSERT INTO lines (
  id, company_id, line_code, line_name,
  origin_city, destination_city,
  distance_km, duration_minutes, line_type,
  base_price, included_luggage_kg, is_active
) VALUES (
  'rakieta_ouaga_bamako', 'rakieta', 'OUA-BKO-RAKIETA', 'Ouagadougou ↔ Bamako (Mali)',
  'Ouagadougou', 'Bamako',
  900, 1080, 'INTERNATIONAL',
  20500, 20, true
) ON CONFLICT (id) DO UPDATE SET
  base_price = 20500,
  updated_at = CURRENT_TIMESTAMP;

-- TCV Ouaga-Bamako
INSERT INTO lines (
  id, company_id, line_code, line_name,
  origin_city, destination_city,
  distance_km, duration_minutes, line_type,
  base_price, included_luggage_kg,
  services_included, is_active
) VALUES (
  'tcv_ouaga_bamako', 'tcv', 'OUA-BKO-TCV', 'Ouagadougou ↔ Bamako (Mali)',
  'Ouagadougou', 'Bamako',
  900, 1080, 'INTERNATIONAL',
  16500, 20,
  'Départs quotidiens, tarif officiel 2018', true
) ON CONFLICT (id) DO UPDATE SET
  base_price = 16500,
  updated_at = CURRENT_TIMESTAMP;

-- RAKIETA Ouaga-Sikasso
INSERT INTO lines (
  id, company_id, line_code, line_name,
  origin_city, destination_city,
  distance_km, duration_minutes, line_type,
  base_price, included_luggage_kg, is_active
) VALUES (
  'rakieta_ouaga_sikasso', 'rakieta', 'OUA-SIK-RAKIETA', 'Ouagadougou ↔ Sikasso (Mali)',
  'Ouagadougou', 'Sikasso',
  450, 540, 'INTERNATIONAL',
  13500, 20, true
) ON CONFLICT (id) DO UPDATE SET
  base_price = 13500,
  updated_at = CURRENT_TIMESTAMP;

-- ========== BURKINA FASO ↔ NIGER ==========

-- TCV Ouaga-Niamey
INSERT INTO lines (
  id, company_id, line_code, line_name,
  origin_city, destination_city,
  distance_km, duration_minutes, line_type,
  base_price, included_luggage_kg,
  services_included, is_active
) VALUES (
  'tcv_ouaga_niamey', 'tcv', 'OUA-NIA-TCV', 'Ouagadougou ↔ Niamey (Niger)',
  'Ouagadougou', 'Niamey',
  520, 600, 'INTERNATIONAL',
  NULL, 20,
  'Fréquence variable, contacter la compagnie pour tarif et horaires', true
) ON CONFLICT (id) DO UPDATE SET
  services_included = EXCLUDED.services_included,
  updated_at = CURRENT_TIMESTAMP;

-- =====================================================
-- VÉRIFICATIONS
-- =====================================================

-- Nombre total de lignes
SELECT COUNT(*) as total_lignes FROM lines;

-- Lignes par type
SELECT 
  line_type,
  COUNT(*) as nombre_lignes
FROM lines
GROUP BY line_type
ORDER BY line_type;

-- Lignes par compagnie
SELECT 
  c.name,
  c.company_type,
  COUNT(l.id) as nombre_lignes,
  CASE WHEN c.is_active THEN 'Actif' ELSE 'Suspendu' END as statut
FROM companies c
LEFT JOIN lines l ON c.id = l.company_id
GROUP BY c.id, c.name, c.company_type, c.is_active
ORDER BY COUNT(l.id) DESC;

-- Top 5 destinations les plus desservies
SELECT 
  destination_city,
  COUNT(*) as nombre_lignes,
  string_agg(DISTINCT c.name, ', ') as compagnies
FROM lines l
JOIN companies c ON l.company_id = c.id
WHERE l.line_type IN ('INTERURBAIN', 'INTERNATIONAL')
GROUP BY destination_city
ORDER BY COUNT(*) DESC
LIMIT 5;

-- Prix minimum et maximum par destination depuis Ouagadougou
SELECT 
  destination_city,
  MIN(base_price) as prix_min,
  MAX(base_price) as prix_max,
  AVG(base_price)::int as prix_moyen,
  COUNT(*) as nb_options
FROM lines
WHERE origin_city = 'Ouagadougou' 
  AND base_price IS NOT NULL
  AND line_type IN ('INTERURBAIN', 'INTERNATIONAL')
GROUP BY destination_city
ORDER BY prix_min;

-- =====================================================
-- FIN DU SEED LINES
-- =====================================================
