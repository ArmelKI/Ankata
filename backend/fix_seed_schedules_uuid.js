const fs = require('fs');
const { Client } = require('pg');

const client = new Client({
  user: 'ankata_user',
  host: 'localhost',
  database: 'ankata_db',
  password: 'f51vIHwgz4l1pFRm',
  port: 5432,
});

async function run() {
  await client.connect();
  
  const res = await client.query('SELECT line_code, id FROM lines');
  const lineMap = {};
  res.rows.forEach(r => lineMap[r.line_code] = r.id);

  const { randomUUID } = require('crypto');
  
  const generateSchedule = (lineCode, departureTime) => {
    const lid = lineMap[lineCode];
    if (!lid) return null;
    return `('${randomUUID()}', '${lid}', '${departureTime}', ARRAY[1, 2, 3, 4, 5, 6, 7], 60, 60, '2026-01-01', '2030-12-31', true)`;
  };

  const scheduleArr = [
    generateSchedule('L1', '06:00:00'),
    generateSchedule('L1', '12:00:00'),
    
    generateSchedule('OUA-BOB-TSR', '06:00:00'),
    generateSchedule('OUA-BOB-TSR', '14:00:00'),
    
    generateSchedule('BOB-OUA-TSR', '06:00:00'),
    generateSchedule('BOB-OUA-TSR', '14:00:00'),
    
    generateSchedule('OUA-BOB-RAHIMO', '07:30:00'),
    generateSchedule('OUA-BOB-RAHIMO', '14:30:00'),
    
    generateSchedule('BOB-OUA-RAHIMO', '07:30:00'),
    generateSchedule('BOB-OUA-RAHIMO', '14:30:00'),

    generateSchedule('OUA-BOB-RAKIETA', '07:00:00'),
    generateSchedule('OUA-BOB-RAKIETA', '15:00:00'),
    
    generateSchedule('BOB-OUA-RAKIETA', '07:00:00'),
    generateSchedule('BOB-OUA-RAKIETA', '15:00:00'),

    generateSchedule('OUA-BOB-TCV', '08:00:00'),
    generateSchedule('OUA-BOB-TCV', '15:00:00'),
  ].filter(l => l !== null);

  const schedules = scheduleArr.join(',\n  ');

  const sql = `-- SEED: HORAIRES DE TRANSPORT
INSERT INTO schedules (
  id, line_id, departure_time, days_of_week,
  total_seats, available_seats, valid_from, valid_until, is_active
) VALUES 
  ${schedules};
`;

  fs.writeFileSync('src/database/seeds/003_schedules_fixed.sql', sql);
  await client.end();
}

run().catch(console.error);
