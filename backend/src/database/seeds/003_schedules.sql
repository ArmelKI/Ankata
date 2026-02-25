-- =====================================================
-- SEED: HORAIRES DES LIGNES DE TRANSPORT
-- Horaires détaillés SOTRACO L3/L6B + horaires types interurbains
-- =====================================================

-- =====================================================
-- SECTION 1: HORAIRES SOTRACO LIGNE L3
-- Terminus de Bissighin ↔ Zones de Écoles
-- Service dimanche : 05:50 - 20:30
-- Fréquence : 10-15 min (normal), 20-25 min (heures creuses)
-- =====================================================

-- Horaires dimanche L3 (exemples basés sur données Moovit)
INSERT INTO schedules (
  id, line_id, departure_time, days_of_week,
  total_seats, available_seats, frequency_minutes,
  valid_from, is_active
) VALUES
  ('sotraco_l3_0550', 'sotraco_l3', '05:50:00', ARRAY['DIMANCHE'], 70, 70, 15, '2026-01-01', true),
  ('sotraco_l3_0605', 'sotraco_l3', '06:05:00', ARRAY['DIMANCHE'], 70, 70, 15, '2026-01-01', true),
  ('sotraco_l3_0620', 'sotraco_l3', '06:20:00', ARRAY['DIMANCHE'], 70, 70, 15, '2026-01-01', true),
  ('sotraco_l3_0635', 'sotraco_l3', '06:35:00', ARRAY['DIMANCHE'], 70, 70, 15, '2026-01-01', true),
  ('sotraco_l3_0650', 'sotraco_l3', '06:50:00', ARRAY['DIMANCHE'], 70, 70, 15, '2026-01-01', true),
  ('sotraco_l3_0706', 'sotraco_l3', '07:06:00', ARRAY['DIMANCHE'], 70, 70, 20, '2026-01-01', true),
  ('sotraco_l3_0726', 'sotraco_l3', '07:26:00', ARRAY['DIMANCHE'], 70, 70, 15, '2026-01-01', true),
  ('sotraco_l3_0741', 'sotraco_l3', '07:41:00', ARRAY['DIMANCHE'], 70, 70, 15, '2026-01-01', true),
  ('sotraco_l3_0756', 'sotraco_l3', '07:56:00', ARRAY['DIMANCHE'], 70, 70, 15, '2026-01-01', true),
  ('sotraco_l3_0811', 'sotraco_l3', '08:11:00', ARRAY['DIMANCHE'], 70, 70, 15, '2026-01-01', true),
  ('sotraco_l3_0826', 'sotraco_l3', '08:26:00', ARRAY['DIMANCHE'], 70, 70, 15, '2026-01-01', true),
  ('sotraco_l3_0841', 'sotraco_l3', '08:41:00', ARRAY['DIMANCHE'], 70, 70, 15, '2026-01-01', true),
  ('sotraco_l3_0856', 'sotraco_l3', '08:56:00', ARRAY['DIMANCHE'], 70, 70, 15, '2026-01-01', true),
  ('sotraco_l3_0911', 'sotraco_l3', '09:11:00', ARRAY['DIMANCHE'], 70, 70, 15, '2026-01-01', true),
  ('sotraco_l3_0926', 'sotraco_l3', '09:26:00', ARRAY['DIMANCHE'], 70, 70, 15, '2026-01-01', true),
  ('sotraco_l3_0941', 'sotraco_l3', '09:41:00', ARRAY['DIMANCHE'], 70, 70, 15, '2026-01-01', true),
  ('sotraco_l3_0956', 'sotraco_l3', '09:56:00', ARRAY['DIMANCHE'], 70, 70, 13, '2026-01-01', true),
  ('sotraco_l3_1009', 'sotraco_l3', '10:09:00', ARRAY['DIMANCHE'], 70, 70, 13, '2026-01-01', true),
  ('sotraco_l3_1022', 'sotraco_l3', '10:22:00', ARRAY['DIMANCHE'], 70, 70, 15, '2026-01-01', true),
  ('sotraco_l3_1037', 'sotraco_l3', '10:37:00', ARRAY['DIMANCHE'], 70, 70, 15, '2026-01-01', true),
  ('sotraco_l3_1052', 'sotraco_l3', '10:52:00', ARRAY['DIMANCHE'], 70, 70, 15, '2026-01-01', true),
  ('sotraco_l3_1107', 'sotraco_l3', '11:07:00', ARRAY['DIMANCHE'], 70, 70, 15, '2026-01-01', true),
  ('sotraco_l3_1122', 'sotraco_l3', '11:22:00', ARRAY['DIMANCHE'], 70, 70, 15, '2026-01-01', true),
  ('sotraco_l3_1137', 'sotraco_l3', '11:37:00', ARRAY['DIMANCHE'], 70, 70, 15, '2026-01-01', true),
  ('sotraco_l3_1152', 'sotraco_l3', '11:52:00', ARRAY['DIMANCHE'], 70, 70, 15, '2026-01-01', true)
ON CONFLICT (id) DO UPDATE SET
  departure_time = EXCLUDED.departure_time,
  frequency_minutes = EXCLUDED.frequency_minutes,
  updated_at = CURRENT_TIMESTAMP;

-- Horaires types L3 en semaine (lundi-samedi)
INSERT INTO schedules (
  id, line_id, departure_time, days_of_week,
  total_seats, available_seats, frequency_minutes,
  notes, valid_from, is_active
) VALUES
  ('sotraco_l3_weekday_heures_pointe', 'sotraco_l3', '06:00:00', 
   ARRAY['LUNDI', 'MARDI', 'MERCREDI', 'JEUDI', 'VENDREDI', 'SAMEDI'], 
   70, 70, 10,
   'Heures de pointe : fréquence toutes les 10 minutes (06h-08h et 17h-19h)', 
   '2026-01-01', true),
  ('sotraco_l3_weekday_normal', 'sotraco_l3', '09:00:00', 
   ARRAY['LUNDI', 'MARDI', 'MERCREDI', 'JEUDI', 'VENDREDI', 'SAMEDI'], 
   70, 70, 15,
   'Heures normales : fréquence toutes les 15 minutes (08h-17h)', 
   '2026-01-01', true),
  ('sotraco_l3_weekday_soir', 'sotraco_l3', '20:00:00', 
   ARRAY['LUNDI', 'MARDI', 'MERCREDI', 'JEUDI', 'VENDREDI', 'SAMEDI'], 
   70, 70, 20,
   'Heures creuses soirée : fréquence toutes les 20 minutes (19h-20h30)', 
   '2026-01-01', true)
ON CONFLICT (id) DO NOTHING;

-- =====================================================
-- SECTION 2: HORAIRES SOTRACO LIGNE L6B
-- Terminus du Péage ↔ Place Naaba Koom
-- Service lundi : 05:10 - 20:30
-- Fréquence : 6-8 min (heures pointe)
-- =====================================================

-- Horaires lundi matin L6B (données Moovit - heures pointe 05:10-07:39)
INSERT INTO schedules (
  id, line_id, departure_time, days_of_week,
  total_seats, available_seats, frequency_minutes,
  valid_from, is_active
) VALUES
  ('sotraco_l6b_0510', 'sotraco_l6b', '05:10:00', ARRAY['LUNDI'], 70, 70, 6, '2026-01-01', true),
  ('sotraco_l6b_0516', 'sotraco_l6b', '05:16:00', ARRAY['LUNDI'], 70, 70, 6, '2026-01-01', true),
  ('sotraco_l6b_0522', 'sotraco_l6b', '05:22:00', ARRAY['LUNDI'], 70, 70, 6, '2026-01-01', true),
  ('sotraco_l6b_0528', 'sotraco_l6b', '05:28:00', ARRAY['LUNDI'], 70, 70, 6, '2026-01-01', true),
  ('sotraco_l6b_0534', 'sotraco_l6b', '05:34:00', ARRAY['LUNDI'], 70, 70, 6, '2026-01-01', true),
  ('sotraco_l6b_0540', 'sotraco_l6b', '05:40:00', ARRAY['LUNDI'], 70, 70, 6, '2026-01-01', true),
  ('sotraco_l6b_0546', 'sotraco_l6b', '05:46:00', ARRAY['LUNDI'], 70, 70, 6, '2026-01-01', true),
  ('sotraco_l6b_0552', 'sotraco_l6b', '05:52:00', ARRAY['LUNDI'], 70, 70, 6, '2026-01-01', true),
  ('sotraco_l6b_0558', 'sotraco_l6b', '05:58:00', ARRAY['LUNDI'], 70, 70, 6, '2026-01-01', true),
  ('sotraco_l6b_0604', 'sotraco_l6b', '06:04:00', ARRAY['LUNDI'], 70, 70, 6, '2026-01-01', true),
  ('sotraco_l6b_0610', 'sotraco_l6b', '06:10:00', ARRAY['LUNDI'], 70, 70, 6, '2026-01-01', true),
  ('sotraco_l6b_0616', 'sotraco_l6b', '06:16:00', ARRAY['LUNDI'], 70, 70, 6, '2026-01-01', true),
  ('sotraco_l6b_0622', 'sotraco_l6b', '06:22:00', ARRAY['LUNDI'], 70, 70, 6, '2026-01-01', true),
  ('sotraco_l6b_0628', 'sotraco_l6b', '06:28:00', ARRAY['LUNDI'], 70, 70, 6, '2026-01-01', true),
  ('sotraco_l6b_0634', 'sotraco_l6b', '06:34:00', ARRAY['LUNDI'], 70, 70, 6, '2026-01-01', true),
  ('sotraco_l6b_0640', 'sotraco_l6b', '06:40:00', ARRAY['LUNDI'], 70, 70, 6, '2026-01-01', true),
  ('sotraco_l6b_0646', 'sotraco_l6b', '06:46:00', ARRAY['LUNDI'], 70, 70, 6, '2026-01-01', true),
  ('sotraco_l6b_0652', 'sotraco_l6b', '06:52:00', ARRAY['LUNDI'], 70, 70, 6, '2026-01-01', true),
  ('sotraco_l6b_0658', 'sotraco_l6b', '06:58:00', ARRAY['LUNDI'], 70, 70, 8, '2026-01-01', true),
  ('sotraco_l6b_0706', 'sotraco_l6b', '07:06:00', ARRAY['LUNDI'], 70, 70, 7, '2026-01-01', true),
  ('sotraco_l6b_0713', 'sotraco_l6b', '07:13:00', ARRAY['LUNDI'], 70, 70, 8, '2026-01-01', true),
  ('sotraco_l6b_0721', 'sotraco_l6b', '07:21:00', ARRAY['LUNDI'], 70, 70, 6, '2026-01-01', true),
  ('sotraco_l6b_0727', 'sotraco_l6b', '07:27:00', ARRAY['LUNDI'], 70, 70, 6, '2026-01-01', true),
  ('sotraco_l6b_0733', 'sotraco_l6b', '07:33:00', ARRAY['LUNDI'], 70, 70, 6, '2026-01-01', true),
  ('sotraco_l6b_0739', 'sotraco_l6b', '07:39:00', ARRAY['LUNDI'], 70, 70, 6, '2026-01-01', true)
ON CONFLICT (id) DO UPDATE SET
  departure_time = EXCLUDED.departure_time,
  frequency_minutes = EXCLUDED.frequency_minutes,
  updated_at = CURRENT_TIMESTAMP;

-- Horaires types L6B autres jours
INSERT INTO schedules (
  id, line_id, departure_time, days_of_week,
  total_seats, available_seats, frequency_minutes,
  notes, valid_from, is_active
) VALUES
  ('sotraco_l6b_weekday_pointe_matin', 'sotraco_l6b', '05:10:00', 
   ARRAY['MARDI', 'MERCREDI', 'JEUDI', 'VENDREDI', 'SAMEDI'], 
   70, 70, 6,
   'Heures de pointe matin : fréquence toutes les 6 minutes (05h10-07h00)', 
   '2026-01-01', true),
  ('sotraco_l6b_weekday_journee', 'sotraco_l6b', '09:00:00', 
   ARRAY['LUNDI', 'MARDI', 'MERCREDI', 'JEUDI', 'VENDREDI', 'SAMEDI'], 
   70, 70, 10,
   'Heures normales journée : fréquence toutes les 8-10 minutes (07h-17h)', 
   '2026-01-01', true),
  ('sotraco_l6b_weekday_pointe_soir', 'sotraco_l6b', '17:00:00', 
   ARRAY['LUNDI', 'MARDI', 'MERCREDI', 'JEUDI', 'VENDREDI', 'SAMEDI'], 
   70, 70, 8,
   'Heures de pointe soir : fréquence toutes les 8 minutes (17h-19h)', 
   '2026-01-01', true),
  ('sotraco_l6b_dimanche', 'sotraco_l6b', '06:00:00', 
   ARRAY['DIMANCHE'], 
   70, 70, 12,
   'Service dimanche : fréquence réduite toutes les 12-15 minutes', 
   '2026-01-01', true)
ON CONFLICT (id) DO NOTHING;

-- =====================================================
-- SECTION 3: HORAIRES INTERURBAINS OUAGADOUGOU-BOBO
-- =====================================================

-- TSR Ouaga-Bobo (6 départs quotidiens)
INSERT INTO schedules (
  id, line_id, departure_time, days_of_week,
  total_seats, available_seats, arrival_time,
  vehicle_type, notes, valid_from, is_active
) VALUES
  ('tsr_ouaga_bobo_0600', 'tsr_ouaga_bobo', '06:00:00', 
   ARRAY['LUNDI', 'MARDI', 'MERCREDI', 'JEUDI', 'VENDREDI', 'SAMEDI', 'DIMANCHE'], 
   60, 60, '11:30:00',
   'Bus standard climatisé', 'Départ tôt matin', '2026-01-01', true),
  ('tsr_ouaga_bobo_0700', 'tsr_ouaga_bobo', '07:00:00', 
   ARRAY['LUNDI', 'MARDI', 'MERCREDI', 'JEUDI', 'VENDREDI', 'SAMEDI', 'DIMANCHE'], 
   60, 60, '12:30:00',
   'Bus standard climatisé', 'Départ matinal populaire', '2026-01-01', true),
  ('tsr_ouaga_bobo_1000', 'tsr_ouaga_bobo', '10:00:00', 
   ARRAY['LUNDI', 'MARDI', 'MERCREDI', 'JEUDI', 'VENDREDI', 'SAMEDI', 'DIMANCHE'], 
   60, 60, '15:30:00',
   'Bus standard climatisé', 'Départ milieu matinée', '2026-01-01', true),
  ('tsr_ouaga_bobo_1400', 'tsr_ouaga_bobo', '14:00:00', 
   ARRAY['LUNDI', 'MARDI', 'MERCREDI', 'JEUDI', 'VENDREDI', 'SAMEDI', 'DIMANCHE'], 
   60, 60, '19:30:00',
   'Bus standard climatisé', 'Départ après-midi', '2026-01-01', true),
  ('tsr_ouaga_bobo_1700', 'tsr_ouaga_bobo', '17:00:00', 
   ARRAY['LUNDI', 'MARDI', 'MERCREDI', 'JEUDI', 'VENDREDI', 'SAMEDI', 'DIMANCHE'], 
   60, 60, '22:30:00',
   'Bus standard climatisé', 'Départ fin d''après-midi', '2026-01-01', true),
  ('tsr_ouaga_bobo_2330', 'tsr_ouaga_bobo', '23:30:00', 
   ARRAY['LUNDI', 'MARDI', 'MERCREDI', 'JEUDI', 'VENDREDI', 'SAMEDI', 'DIMANCHE'], 
   60, 60, '05:00:00',
   'Bus standard climatisé', 'Départ nocturne, arrivée matin', '2026-01-01', true)
ON CONFLICT (id) DO UPDATE SET
  departure_time = EXCLUDED.departure_time,
  arrival_time = EXCLUDED.arrival_time,
  updated_at = CURRENT_TIMESTAMP;

-- RAHIMO Ouaga-Bobo Standard (5 départs quotidiens)
INSERT INTO schedules (
  id, line_id, departure_time, days_of_week,
  total_seats, available_seats, arrival_time,
  vehicle_type, notes, valid_from, is_active
) VALUES
  ('rahimo_ouaga_bobo_0730', 'rahimo_ouaga_bobo', '07:30:00', 
   ARRAY['LUNDI', 'MARDI', 'MERCREDI', 'JEUDI', 'VENDREDI', 'SAMEDI', 'DIMANCHE'], 
   70, 70, '12:30:00',
   'Bus G8 Premium', 'Service premium : AC garanti, TV, USB, collation', '2026-01-01', true),
  ('rahimo_ouaga_bobo_1000', 'rahimo_ouaga_bobo', '10:00:00', 
   ARRAY['LUNDI', 'MARDI', 'MERCREDI', 'JEUDI', 'VENDREDI', 'SAMEDI', 'DIMANCHE'], 
   70, 70, '15:00:00',
   'Bus G8 Premium', 'Service premium', '2026-01-01', true),
  ('rahimo_ouaga_bobo_1430', 'rahimo_ouaga_bobo', '14:30:00', 
   ARRAY['LUNDI', 'MARDI', 'MERCREDI', 'JEUDI', 'VENDREDI', 'SAMEDI', 'DIMANCHE'], 
   70, 70, '19:30:00',
   'Bus G8 Premium', 'Service premium', '2026-01-01', true),
  ('rahimo_ouaga_bobo_1830', 'rahimo_ouaga_bobo', '18:30:00', 
   ARRAY['LUNDI', 'MARDI', 'MERCREDI', 'JEUDI', 'VENDREDI', 'SAMEDI', 'DIMANCHE'], 
   70, 70, '23:30:00',
   'Bus G8 Premium', 'Service premium', '2026-01-01', true),
  ('rahimo_ouaga_bobo_night', 'rahimo_ouaga_bobo', '23:30:00', 
   ARRAY['LUNDI', 'MARDI', 'MERCREDI', 'JEUDI', 'VENDREDI', 'SAMEDI', 'DIMANCHE'], 
   70, 70, '04:30:00',
   'Bus G8 Premium', 'Trajet nocturne premium', '2026-01-01', true)
ON CONFLICT (id) DO UPDATE SET
  departure_time = EXCLUDED.departure_time,
  arrival_time = EXCLUDED.arrival_time,
  updated_at = CURRENT_TIMESTAMP;

-- RAHIMO Ouaga-Bobo VIP (2 départs quotidiens)
INSERT INTO schedules (
  id, line_id, departure_time, days_of_week,
  total_seats, available_seats, arrival_time,
  vehicle_type, notes, valid_from, is_active
) VALUES
  ('rahimo_ouaga_bobo_vip_0900', 'rahimo_ouaga_bobo_vip', '09:00:00', 
   ARRAY['LUNDI', 'MARDI', 'MERCREDI', 'JEUDI', 'VENDREDI', 'SAMEDI', 'DIMANCHE'], 
   50, 50, '14:00:00',
   'Bus VIP Extra-confort', 'Service VIP : sièges extra-larges, service prioritaire', '2026-01-01', true),
  ('rahimo_ouaga_bobo_vip_1600', 'rahimo_ouaga_bobo_vip', '16:00:00', 
   ARRAY['LUNDI', 'MARDI', 'MERCREDI', 'JEUDI', 'VENDREDI', 'SAMEDI', 'DIMANCHE'], 
   50, 50, '21:00:00',
   'Bus VIP Extra-confort', 'Service VIP', '2026-01-01', true)
ON CONFLICT (id) DO UPDATE SET
  departure_time = EXCLUDED.departure_time,
  arrival_time = EXCLUDED.arrival_time,
  updated_at = CURRENT_TIMESTAMP;

-- RAKIETA Ouaga-Bobo (4 départs quotidiens estimés)
INSERT INTO schedules (
  id, line_id, departure_time, days_of_week,
  total_seats, available_seats, arrival_time,
  vehicle_type, notes, valid_from, is_active
) VALUES
  ('rakieta_ouaga_bobo_0700', 'rakieta_ouaga_bobo', '07:00:00', 
   ARRAY['LUNDI', 'MARDI', 'MERCREDI', 'JEUDI', 'VENDREDI', 'SAMEDI', 'DIMANCHE'], 
   60, 60, '12:00:00',
   'Bus bleu climatisé', 'Réservation 72h avance recommandée', '2026-01-01', true),
  ('rakieta_ouaga_bobo_1100', 'rakieta_ouaga_bobo', '11:00:00', 
   ARRAY['LUNDI', 'MARDI', 'MERCREDI', 'JEUDI', 'VENDREDI', 'SAMEDI', 'DIMANCHE'], 
   60, 60, '16:00:00',
   'Bus bleu climatisé', 'Départ milieu journée', '2026-01-01', true),
  ('rakieta_ouaga_bobo_1500', 'rakieta_ouaga_bobo', '15:00:00', 
   ARRAY['LUNDI', 'MARDI', 'MERCREDI', 'JEUDI', 'VENDREDI', 'SAMEDI', 'DIMANCHE'], 
   60, 60, '20:00:00',
   'Bus bleu climatisé', 'Départ après-midi', '2026-01-01', true),
  ('rakieta_ouaga_bobo_2000', 'rakieta_ouaga_bobo', '20:00:00', 
   ARRAY['LUNDI', 'MARDI', 'MERCREDI', 'JEUDI', 'VENDREDI', 'SAMEDI', 'DIMANCHE'], 
   60, 60, '01:00:00',
   'Bus bleu climatisé', 'Départ soirée', '2026-01-01', true)
ON CONFLICT (id) DO UPDATE SET
  departure_time = EXCLUDED.departure_time,
  arrival_time = EXCLUDED.arrival_time,
  updated_at = CURRENT_TIMESTAMP;

-- TCV Ouaga-Bobo (Départs quotidiens)
INSERT INTO schedules (
  id, line_id, departure_time, days_of_week,
  total_seats, available_seats, arrival_time,
  vehicle_type, notes, valid_from, is_active
) VALUES
  ('tcv_ouaga_bobo_0800', 'tcv_ouaga_bobo', '08:00:00', 
   ARRAY['LUNDI', 'MARDI', 'MERCREDI', 'JEUDI', 'VENDREDI', 'SAMEDI', 'DIMANCHE'], 
   60, 60, '14:00:00',
   'Bus standard', 'Départ gare ZAD. Durée 6h (plus lent que concurrence)', '2026-01-01', true),
  ('tcv_ouaga_bobo_1400', 'tcv_ouaga_bobo', '14:00:00', 
   ARRAY['LUNDI', 'MARDI', 'MERCREDI', 'JEUDI', 'VENDREDI', 'SAMEDI', 'DIMANCHE'], 
   60, 60, '20:00:00',
   'Bus standard', 'Départ après-midi', '2026-01-01', true)
ON CONFLICT (id) DO UPDATE SET
  departure_time = EXCLUDED.departure_time,
  arrival_time = EXCLUDED.arrival_time,
  updated_at = CURRENT_TIMESTAMP;

-- SARAMAYA Ouaga-Bobo Standard (3 départs estimés)
INSERT INTO schedules (
  id, line_id, departure_time, days_of_week,
  total_seats, available_seats, arrival_time,
  vehicle_type, notes, valid_from, is_active
) VALUES
  ('saramaya_ouaga_bobo_0800', 'saramaya_ouaga_bobo', '08:00:00', 
   ARRAY['LUNDI', 'MARDI', 'MERCREDI', 'JEUDI', 'VENDREDI', 'SAMEDI', 'DIMANCHE'], 
   60, 60, '13:00:00',
   'Bus ordinaire climatisé', 'Départ depuis Bobo-Dioulasso', '2026-01-01', true),
  ('saramaya_ouaga_bobo_1300', 'saramaya_ouaga_bobo', '13:00:00', 
   ARRAY['LUNDI', 'MARDI', 'MERCREDI', 'JEUDI', 'VENDREDI', 'SAMEDI', 'DIMANCHE'], 
   60, 60, '18:00:00',
   'Bus ordinaire climatisé', 'Départ après-midi', '2026-01-01', true),
  ('saramaya_ouaga_bobo_1800', 'saramaya_ouaga_bobo', '18:00:00', 
   ARRAY['LUNDI', 'MARDI', 'MERCREDI', 'JEUDI', 'VENDREDI', 'SAMEDI', 'DIMANCHE'], 
   60, 60, '23:00:00',
   'Bus ordinaire climatisé', 'Départ soirée', '2026-01-01', true)
ON CONFLICT (id) DO UPDATE SET
  departure_time = EXCLUDED.departure_time,
  arrival_time = EXCLUDED.arrival_time,
  updated_at = CURRENT_TIMESTAMP;

-- SARAMAYA Ouaga-Bobo VIP (1 départ quotidien)
INSERT INTO schedules (
  id, line_id, departure_time, days_of_week,
  total_seats, available_seats, arrival_time,
  vehicle_type, notes, valid_from, is_active
) VALUES
  ('saramaya_ouaga_bobo_vip_1000', 'saramaya_ouaga_bobo_vip', '10:00:00', 
   ARRAY['LUNDI', 'MARDI', 'MERCREDI', 'JEUDI', 'VENDREDI', 'SAMEDI', 'DIMANCHE'], 
   45, 45, '15:00:00',
   'Bus VIP', 'Sièges extra-larges (3/rangée), TV individuelle, USB, boisson offerte', '2026-01-01', true)
ON CONFLICT (id) DO UPDATE SET
  departure_time = EXCLUDED.departure_time,
  arrival_time = EXCLUDED.arrival_time,
  updated_at = CURRENT_TIMESTAMP;

-- =====================================================
-- SECTION 3B: HORAIRES INTERURBAINS BOBO-OUAGADOUGOU (Retour)
-- =====================================================

-- TSR Bobo-Ouaga (4 départs)
INSERT INTO schedules (
  id, line_id, departure_time, days_of_week,
  total_seats, available_seats, arrival_time,
  vehicle_type, notes, valid_from, is_active
) VALUES
  ('tsr_bobo_ouaga_0600', 'tsr_bobo_ouaga', '06:00:00', 
   ARRAY['LUNDI', 'MARDI', 'MERCREDI', 'JEUDI', 'VENDREDI', 'SAMEDI', 'DIMANCHE'], 
   60, 60, '11:30:00',
   'Bus standard', 'Départ matinal', '2026-01-01', true),
  ('tsr_bobo_ouaga_1000', 'tsr_bobo_ouaga', '10:00:00', 
   ARRAY['LUNDI', 'MARDI', 'MERCREDI', 'JEUDI', 'VENDREDI', 'SAMEDI', 'DIMANCHE'], 
   60, 60, '15:30:00',
   'Bus standard', 'Matinée', '2026-01-01', true),
  ('tsr_bobo_ouaga_1400', 'tsr_bobo_ouaga', '14:00:00', 
   ARRAY['LUNDI', 'MARDI', 'MERCREDI', 'JEUDI', 'VENDREDI', 'SAMEDI', 'DIMANCHE'], 
   60, 60, '19:30:00',
   'Bus standard', 'Après-midi', '2026-01-01', true),
  ('tsr_bobo_ouaga_2330', 'tsr_bobo_ouaga', '23:30:00', 
   ARRAY['LUNDI', 'MARDI', 'MERCREDI', 'JEUDI', 'VENDREDI', 'SAMEDI', 'DIMANCHE'], 
   60, 60, '05:00:00',
   'Bus standard', 'Nocturne', '2026-01-01', true)
ON CONFLICT (id) DO UPDATE SET
  departure_time = EXCLUDED.departure_time,
  arrival_time = EXCLUDED.arrival_time,
  updated_at = CURRENT_TIMESTAMP;

-- RAHIMO Bobo-Ouaga Premium (4 départs)
INSERT INTO schedules (
  id, line_id, departure_time, days_of_week,
  total_seats, available_seats, arrival_time,
  vehicle_type, notes, valid_from, is_active
) VALUES
  ('rahimo_bobo_ouaga_0730', 'rahimo_bobo_ouaga', '07:30:00', 
   ARRAY['LUNDI', 'MARDI', 'MERCREDI', 'JEUDI', 'VENDREDI', 'SAMEDI', 'DIMANCHE'], 
   70, 70, '12:30:00',
   'Bus premium', 'Service complet', '2026-01-01', true),
  ('rahimo_bobo_ouaga_1430', 'rahimo_bobo_ouaga', '14:30:00', 
   ARRAY['LUNDI', 'MARDI', 'MERCREDI', 'JEUDI', 'VENDREDI', 'SAMEDI', 'DIMANCHE'], 
   70, 70, '19:30:00',
   'Bus premium', 'Service complet', '2026-01-01', true),
  ('rahimo_bobo_ouaga_1830', 'rahimo_bobo_ouaga', '18:30:00', 
   ARRAY['LUNDI', 'MARDI', 'MERCREDI', 'JEUDI', 'VENDREDI', 'SAMEDI', 'DIMANCHE'], 
   70, 70, '23:30:00',
   'Bus premium', 'Service complet', '2026-01-01', true),
  ('rahimo_bobo_ouaga_night', 'rahimo_bobo_ouaga', '23:30:00', 
   ARRAY['LUNDI', 'MARDI', 'MERCREDI', 'JEUDI', 'VENDREDI', 'SAMEDI', 'DIMANCHE'], 
   70, 70, '04:30:00',
   'Bus premium', 'Service complet nocturne', '2026-01-01', true)
ON CONFLICT (id) DO UPDATE SET
  departure_time = EXCLUDED.departure_time,
  arrival_time = EXCLUDED.arrival_time,
  updated_at = CURRENT_TIMESTAMP;

-- RAKIETA Bobo-Ouaga (3 départs)
INSERT INTO schedules (
  id, line_id, departure_time, days_of_week,
  total_seats, available_seats, arrival_time,
  vehicle_type, notes, valid_from, is_active
) VALUES
  ('rakieta_bobo_ouaga_0700', 'rakieta_bobo_ouaga', '07:00:00', 
   ARRAY['LUNDI', 'MARDI', 'MERCREDI', 'JEUDI', 'VENDREDI', 'SAMEDI', 'DIMANCHE'], 
   60, 60, '12:00:00',
   'Bus climatisé', 'Matinal', '2026-01-01', true),
  ('rakieta_bobo_ouaga_1500', 'rakieta_bobo_ouaga', '15:00:00', 
   ARRAY['LUNDI', 'MARDI', 'MERCREDI', 'JEUDI', 'VENDREDI', 'SAMEDI', 'DIMANCHE'], 
   60, 60, '20:00:00',
   'Bus climatisé', 'Après-midi', '2026-01-01', true),
  ('rakieta_bobo_ouaga_2000', 'rakieta_bobo_ouaga', '20:00:00', 
   ARRAY['LUNDI', 'MARDI', 'MERCREDI', 'JEUDI', 'VENDREDI', 'SAMEDI', 'DIMANCHE'], 
   60, 60, '01:00:00',
   'Bus climatisé', 'Soirée', '2026-01-01', true)
ON CONFLICT (id) DO UPDATE SET
  departure_time = EXCLUDED.departure_time,
  arrival_time = EXCLUDED.arrival_time,
  updated_at = CURRENT_TIMESTAMP;

-- =====================================================
-- SECTION 4: HORAIRES INTERNATIONAUX (Exemples clés)
-- =====================================================

-- TCV Ouaga-Lomé (1 départ hebdomadaire confirmé)
INSERT INTO schedules (
  id, line_id, departure_time, days_of_week,
  total_seats, available_seats, arrival_time,
  vehicle_type, notes, valid_from, is_active
) VALUES
  ('tcv_ouaga_lome_sun', 'tcv_ouaga_lome', '06:00:00', 
   ARRAY['DIMANCHE'], 
   60, 60, '00:00:00',
   'Bus international', '1 départ/semaine : Dimanche 06h00. Durée 18h. Réservation obligatoire.', '2026-01-01', true)
ON CONFLICT (id) DO UPDATE SET
  departure_time = EXCLUDED.departure_time,
  days_of_week = EXCLUDED.days_of_week,
  updated_at = CURRENT_TIMESTAMP;

-- TSR Abidjan-Ouaga (Départ confirmé 18:30 GMT)
INSERT INTO schedules (
  id, line_id, departure_time, days_of_week,
  total_seats, available_seats, arrival_time,
  vehicle_type, notes, valid_from, is_active
) VALUES
  ('tsr_abidjan_ouaga_1830', 'tsr_abidjan_ouaga', '18:30:00', 
   ARRAY['LUNDI', 'MARDI', 'MERCREDI', 'JEUDI', 'VENDREDI', 'SAMEDI', 'DIMANCHE'], 
   60, 60, '14:30:00',
   'Bus international', 'Départ Port-Bouët 2 Abidjan 18h30 GMT. Contact: +225 0778050230', '2026-01-01', true)
ON CONFLICT (id) DO UPDATE SET
  departure_time = EXCLUDED.departure_time,
  notes = EXCLUDED.notes,
  updated_at = CURRENT_TIMESTAMP;

-- RAKIETA Ouaga-Abidjan (2 départs estimés)
INSERT INTO schedules (
  id, line_id, departure_time, days_of_week,
  total_seats, available_seats, arrival_time,
  vehicle_type, notes, valid_from, is_active
) VALUES
  ('rakieta_ouaga_abidjan_0700', 'rakieta_ouaga_abidjan', '07:00:00', 
   ARRAY['LUNDI', 'MERCREDI', 'VENDREDI', 'DIMANCHE'], 
   60, 60, '03:00:00',
   'Bus international', 'Voyage international 20h. Réservation 72h avance recommandée.', '2026-01-01', true),
  ('rakieta_ouaga_abidjan_1800', 'rakieta_ouaga_abidjan', '18:00:00', 
   ARRAY['MARDI', 'JEUDI', 'SAMEDI'], 
   60, 60, '14:00:00',
   'Bus international', 'Départ soirée, arrivée lendemain après-midi', '2026-01-01', true)
ON CONFLICT (id) DO UPDATE SET
  departure_time = EXCLUDED.departure_time,
  arrival_time = EXCLUDED.arrival_time,
  updated_at = CURRENT_TIMESTAMP;

-- =====================================================
-- VÉRIFICATIONS
-- =====================================================

-- Nombre total d'horaires
SELECT COUNT(*) as total_horaires FROM schedules;

-- Horaires par ligne (top 10)
SELECT 
  l.line_name,
  c.name as compagnie,
  COUNT(s.id) as nombre_horaires
FROM schedules s
JOIN lines l ON s.line_id = l.id
JOIN companies c ON l.company_id = c.id
GROUP BY l.id, l.line_name, c.name
ORDER BY COUNT(s.id) DESC
LIMIT 10;

-- Vérifier lignes sans horaires
SELECT 
  l.line_code,
  l.line_name,
  c.name as compagnie
FROM lines l
JOIN companies c ON l.company_id = c.id
LEFT JOIN schedules s ON l.id = s.line_id
WHERE s.id IS NULL
ORDER BY c.name, l.line_code;

-- =====================================================
-- FIN DU SEED SCHEDULES
-- =====================================================
