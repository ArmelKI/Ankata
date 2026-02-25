const fs = require('fs');
let txt = fs.readFileSync('src/database/seeds/002_lines.sql', 'utf8');

// The DB schema according to my `\d lines` check is:
// id, company_id, line_code, origin_city, destination_city, origin_name, destination_name, origin_latitude, origin_longitude, destination_latitude, destination_longitude, base_price, currency, luggage_price_per_kg, distance_km, estimated_duration_minutes, is_active, created_at, updated_at

// So we MUST REMOVE from INSERT lists:
// line_name, origin_address, destination_address, duration_minutes, line_type, student_price, child_price, included_luggage_kg, services_included, extra_luggage_price_per_kg, route_description

txt = txt.replace(/line_name,/g, '');
txt = txt.replace(/, line_name /g, ' ');
txt = txt.replace(/, origin_address/g, '');
txt = txt.replace(/, destination_address/g, '');
txt = txt.replace(/, duration_minutes/g, '');
txt = txt.replace(/, line_type/g, '');
txt = txt.replace(/, student_price/g, '');
txt = txt.replace(/, child_price/g, '');
txt = txt.replace(/, included_luggage_kg/g, '');
txt = txt.replace(/, services_included/g, '');
txt = txt.replace(/, extra_luggage_price_per_kg/g, '');
txt = txt.replace(/, route_description/g, '');

// Also we need to fix the values! This is harder with regex, but let's do our best for each specific block. 
// Too error prone. I will just run `node` to rewrite the whole file cleanly with valid Postgres SQL.
