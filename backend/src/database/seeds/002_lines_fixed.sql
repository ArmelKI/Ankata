-- SEED: LIGNES DE TRANSPORT
INSERT INTO lines (
  id, company_id, line_code, origin_city, destination_city, origin_name, destination_name,
  distance_km, estimated_duration_minutes, base_price, is_active
) VALUES 
  ('9d5785a9-721f-4449-89e5-e389c1d6abb9', '4b65926a-d4ef-4317-9f0a-99af26fd68fb', 'L1', 'Ouagadougou', 'Ouagadougou', 'Karpala', 'Place Naaba Koom', 10, 35, 200, true),
  ('5b61af63-d3ec-4915-baf5-fcd3e897de9a', '52e6f3ee-6ee5-41c3-83c8-4563532cf791', 'OUA-BOB-TSR', 'Ouagadougou', 'Bobo-Dioulasso', 'Gare TSR Ouaga', 'Gare TSR Bobo', 360, 330, 4500, true),
  ('0436db44-050e-4250-bdf7-f95ffa409b9d', '52e6f3ee-6ee5-41c3-83c8-4563532cf791', 'BOB-OUA-TSR', 'Bobo-Dioulasso', 'Ouagadougou', 'Gare TSR Bobo', 'Gare TSR Ouaga', 360, 330, 4500, true),
  ('173960eb-306a-4ba6-9e67-1d45417a1d34', '7f849e9b-22a1-4356-a1af-1ce1ca6cdc89', 'OUA-BOB-STAF', 'Ouagadougou', 'Bobo-Dioulasso', 'Gare STAF Ouaga', 'Gare STAF Bobo', 360, 300, 6500, false),
  ('b0cc5c8e-3ece-4401-975f-e9cd3e04cca4', 'cdfeaa05-abf4-418d-ac7e-c334d17de8bd', 'OUA-BOB-RAHIMO', 'Ouagadougou', 'Bobo-Dioulasso', 'Gare RAHIMO Ouaga', 'Gare RAHIMO Bobo', 360, 300, 6500, true),
  ('e7181d51-7694-41e3-ad39-1f4a25af4cfd', 'cdfeaa05-abf4-418d-ac7e-c334d17de8bd', 'BOB-OUA-RAHIMO', 'Bobo-Dioulasso', 'Ouagadougou', 'Gare RAHIMO Bobo', 'Gare RAHIMO Ouaga', 360, 300, 6500, true),
  ('bd9b1f0a-61f0-4a70-8045-902aa22365c1', 'a59ff95c-2c97-46d6-8396-c2fb6c570b11', 'OUA-BOB-RAKIETA', 'Ouagadougou', 'Bobo-Dioulasso', 'Gare RAKIETA Ouaga', 'Gare RAKIETA Bobo', 360, 300, 7500, true),
  ('cf2ae1e1-37b2-4b74-af20-5f2d4e556f36', 'a59ff95c-2c97-46d6-8396-c2fb6c570b11', 'BOB-OUA-RAKIETA', 'Bobo-Dioulasso', 'Ouagadougou', 'Gare RAKIETA Bobo', 'Gare RAKIETA Ouaga', 360, 300, 7500, true),
  ('cfd041ee-3dc0-4b0f-b555-3085134cc301', 'eebd8b5f-e501-4556-b69a-46e692008554', 'OUA-BOB-TCV', 'Ouagadougou', 'Bobo-Dioulasso', 'Gare TCV Ouaga', 'Gare TCV Bobo', 360, 360, 6500, true)
ON CONFLICT ON CONSTRAINT lines_line_code_key DO NOTHING;
