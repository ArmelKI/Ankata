/**
 * Script pour peupler la base de données avec les données de seed
 * Utilisation: node src/database/seeds/run-seeds.js
 */

require('dotenv').config();
const { Pool } = require('pg');
const { companies, urbanLines, interurbanLines, schedules } = require('./companies.seed');

const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
});

async function runSeeds() {
  const client = await pool.connect();
  
  try {
    await client.query('BEGIN');
    console.log('Starting database seeding...\n');

    // 1. Insérer les compagnies
    console.log('Inserting companies...');
    const companyIds = {};
    
    for (const company of companies) {
      const result = await client.query(
        `INSERT INTO companies (
          name, slug, description, logo_url, 
          rating_average, total_ratings, phone, 
          headquarters_address, primary_color, is_active
        ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10)
        ON CONFLICT (slug) DO UPDATE SET
          name = EXCLUDED.name,
          description = EXCLUDED.description,
          rating_average = EXCLUDED.rating_average,
          total_ratings = EXCLUDED.total_ratings
        RETURNING id`,
        [
          company.name,
          company.slug,
          company.description,
          company.logo_url,
          company.rating_average,
          company.total_ratings,
          company.phone,
          company.headquarters_address,
          company.primary_color,
          company.is_active,
        ]
      );
      companyIds[company.slug] = result.rows[0].id;
      console.log(`  ${company.name} (ID: ${companyIds[company.slug]})`);
    }

    // 2. Insérer les lignes urbaines
    console.log('\nInserting urban lines...');
    const lineIds = {};
    
    for (const line of urbanLines) {
      const companyId = companyIds[line.company_slug];
      const result = await client.query(
        `INSERT INTO lines (
          company_id, line_code, origin_city, destination_city, 
          base_price, distance_km, estimated_duration_minutes, is_active
        ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
        ON CONFLICT (line_code) DO UPDATE SET
          base_price = EXCLUDED.base_price
        RETURNING id`,
        [
          companyId,
          line.line_number,
          line.origin_city,
          line.destination_city,
          200, // Prix fixe pour lignes urbaines
          line.distance_km,
          line.duration_minutes,
          true,
        ]
      );
      lineIds[line.line_number] = result.rows[0].id;
      console.log(`  ${line.line_name}`);
    }

    // 3. Insérer les lignes interurbaines
    console.log('\nInserting interurban lines...');
    
    for (const line of interurbanLines) {
      const companyId = companyIds[line.company_slug];
      
      // Trouver le prix de base depuis les schedules
      const schedule = schedules.find(s => s.line_number === line.line_number);
      const basePrice = schedule ? schedule.base_price : 5000;
      
      const result = await client.query(
        `INSERT INTO lines (
          company_id, line_code, origin_city, destination_city, 
          base_price, distance_km, estimated_duration_minutes, is_active
        ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
        ON CONFLICT (line_code) DO UPDATE SET
          base_price = EXCLUDED.base_price
        RETURNING id`,
        [
          companyId,
          line.line_number,
          line.origin_city,
          line.destination_city,
          basePrice,
          line.distance_km,
          line.duration_minutes,
          true,
        ]
      );
      lineIds[line.line_number] = result.rows[0].id;
      console.log(`  ${line.line_name}`);
    }

    // 4. Insérer les horaires
    console.log('\n⏰ Inserting schedules...');
    let scheduleCount = 0;
    
    // Dates de validité : aujourd'hui jusqu'à 90 jours dans le futur
    const validFrom = new Date().toISOString().split('T')[0];
    const validUntil = new Date(Date.now() + 90 * 24 * 60 * 60 * 1000).toISOString().split('T')[0];
    
    for (const schedule of schedules) {
      const lineId = lineIds[schedule.line_number];
      if (!lineId) {
        console.warn(`  [WARNING] Line not found: ${schedule.line_number}`);
        continue;
      }
      
      await client.query(
        `INSERT INTO schedules (
          line_id, departure_time, days_of_week, 
          total_seats, available_seats, valid_from, valid_until, is_active
        ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
        ON CONFLICT DO NOTHING`,
        [
          lineId,
          schedule.departure_time,
          schedule.days_of_week,
          40, // total_seats (bus standard)
          40, // available_seats par défaut
          validFrom,
          validUntil,
          true,
        ]
      );
      scheduleCount++;
    }
    console.log(`  ${scheduleCount} schedules inserted`);

    // 5. Créer quelques arrêts pour les lignes urbaines
    console.log('\nInserting bus stops for urban lines...');
    
    const urbanStops = [
      { line_number: 'L2B', stops: [
        { city: 'Ouagadougou', name: 'Tanghin Terminus', order: 1, lat: 12.3514, lng: -1.5148 },
        { city: 'Ouagadougou', name: 'Avenue Loudun', order: 2, lat: 12.3598, lng: -1.5203 },
        { city: 'Ouagadougou', name: 'Place des Nations Unies', order: 3, lat: 12.3714, lng: -1.5247 },
        { city: 'Ouagadougou', name: 'Gounghin Centre', order: 4, lat: 12.3821, lng: -1.5294 },
      ]},
      { line_number: 'L10', stops: [
        { city: 'Ouagadougou', name: 'Aéroport International', order: 1, lat: 12.3532, lng: -1.5124 },
        { city: 'Ouagadougou', name: 'Zone du Bois', order: 2, lat: 12.3621, lng: -1.5187 },
        { city: 'Ouagadougou', name: 'Avenue de l\'Indépendance', order: 3, lat: 12.3702, lng: -1.5234 },
        { city: 'Ouagadougou', name: 'Centre Ville', order: 4, lat: 12.3714, lng: -1.5247 },
      ]},
    ];

    for (const lineStops of urbanStops) {
      const lineId = lineIds[lineStops.line_number];
      if (!lineId) continue;
      
      for (const stop of lineStops.stops) {
        await client.query(
          `INSERT INTO stops (
            line_id, city_name, stop_name, stop_order, latitude, longitude
          ) VALUES ($1, $2, $3, $4, $5, $6)
          ON CONFLICT DO NOTHING`,
          [lineId, stop.city, stop.name, stop.order, stop.lat, stop.lng]
        );
      }
      console.log(`  ${lineStops.stops.length} stops for ${lineStops.line_number}`);
    }

    await client.query('COMMIT');
    console.log('\nDatabase seeding completed successfully!\n');
    console.log('Summary:');
    console.log(`   - ${companies.length} companies`);
    console.log(`   - ${urbanLines.length} urban lines`);
    console.log(`   - ${interurbanLines.length} interurban lines`);
    console.log(`   - ${scheduleCount} schedules`);
    console.log('');

  } catch (error) {
    await client.query('ROLLBACK');
    console.error('[ERROR] seeding database:', error);
    throw error;
  } finally {
    client.release();
    await pool.end();
  }
}

// Exécuter le script
if (require.main === module) {
  runSeeds()
    .then(() => {
      console.log('Seeding process finished!');
      process.exit(0);
    })
    .catch((error) => {
      console.error('[FAILED] Seeding process failed:', error);
      process.exit(1);
    });
}

module.exports = { runSeeds };
