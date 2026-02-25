-- SEED: LIGNES DE TRANSPORT
INSERT INTO lines (
  id, company_id, line_code, origin_city, destination_city, origin_name, destination_name,
  distance_km, estimated_duration_minutes, base_price, is_active
) VALUES 
  ('sotraco_l1', 'sotraco', 'L1', 'Ouagadougou', 'Ouagadougou', 'Karpala', 'Place Naaba Koom', 10, 35, 200, true),
  ('sotraco_l2', 'sotraco', 'L2', 'Ouagadougou', 'Ouagadougou', '2 Boutiques', 'Place Naaba Koom', 8, 30, 200, true),
  ('sotraco_l2b', 'sotraco', 'L2B', 'Ouagadougou', 'Ouagadougou', 'Balkuy', 'Place Naaba Koom', 18, 55, 200, true),
  ('sotraco_l3', 'sotraco', 'L3', 'Ouagadougou', 'Ouagadougou', 'Terminus de Bissighin', 'Zones de Écoles', 12, 40, 200, true),
  ('sotraco_l4', 'sotraco', 'L4', 'Ouagadougou', 'Ouagadougou', 'Terminus Sandogo II', 'Zones de Écoles', 11, 38, 200, true),
  ('sotraco_l5', 'sotraco', 'L5', 'Ouagadougou', 'Ouagadougou', 'Signoghin', 'Place Naaba Koom', 9, 32, 200, true),
  ('sotraco_l6', 'sotraco', 'L6', 'Ouagadougou', 'Ouagadougou', 'Koulweoguin', 'Place Naaba Koom', 10, 35, 200, true),
  ('sotraco_l6b', 'sotraco', 'L6B', 'Ouagadougou', 'Ouagadougou', 'Terminus du Péage', 'Place Naaba Koom', 14, 48, 200, true),
  ('sotraco_l10', 'sotraco', 'L10', 'Ouagadougou', 'Ouagadougou', 'Terminus Tengandogo', 'Zones de Écoles', 13, 45, 200, true),
  
  ('tsr_ouaga_bobo', 'tsr', 'OUA-BOB-TSR', 'Ouagadougou', 'Bobo-Dioulasso', 'Gare TSR Ouaga', 'Gare TSR Bobo', 360, 330, 4500, true),
  ('staf_ouaga_bobo', 'staf', 'OUA-BOB-STAF', 'Ouagadougou', 'Bobo-Dioulasso', 'Gare STAF Ouaga', 'Gare STAF Bobo', 360, 300, 6500, false),
  ('rahimo_ouaga_bobo', 'rahimo', 'OUA-BOB-RAHIMO', 'Ouagadougou', 'Bobo-Dioulasso', 'Gare RAHIMO Ouaga', 'Gare RAHIMO Bobo', 360, 300, 6500, true),
  ('rahimo_ouaga_bobo_vip', 'rahimo', 'OUA-BOB-RAHIMO-VIP', 'Ouagadougou', 'Bobo-Dioulasso', 'Gare RAHIMO Ouaga', 'Gare RAHIMO Bobo', 360, 300, 8000, true),
  ('rakieta_ouaga_bobo', 'rakieta', 'OUA-BOB-RAKIETA', 'Ouagadougou', 'Bobo-Dioulasso', 'Gare RAKIETA Ouaga', 'Gare RAKIETA Bobo', 360, 300, 7500, true),
  ('tcv_ouaga_bobo', 'tcv', 'OUA-BOB-TCV', 'Ouagadougou', 'Bobo-Dioulasso', 'Gare TCV Ouaga', 'Gare TCV Bobo', 360, 360, 6500, true),
  
  -- The retour
  ('tsr_bobo_ouaga', 'tsr', 'BOB-OUA-TSR', 'Bobo-Dioulasso', 'Ouagadougou', 'Gare TSR Bobo', 'Gare TSR Ouaga', 360, 330, 4500, true),
  ('rahimo_bobo_ouaga', 'rahimo', 'BOB-OUA-RAHIMO', 'Bobo-Dioulasso', 'Ouagadougou', 'Gare RAHIMO Bobo', 'Gare RAHIMO Ouaga', 360, 300, 6500, true),
  ('rakieta_bobo_ouaga', 'rakieta', 'BOB-OUA-RAKIETA', 'Bobo-Dioulasso', 'Ouagadougou', 'Gare RAKIETA Bobo', 'Gare RAKIETA Ouaga', 360, 300, 7500, true)
ON CONFLICT (id) DO UPDATE SET
  base_price = EXCLUDED.base_price,
  updated_at = CURRENT_TIMESTAMP;
