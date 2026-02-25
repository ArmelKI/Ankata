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
  
  const res = await client.query('SELECT slug, id FROM companies');
  const companyMap = {};
  res.rows.forEach(r => companyMap[r.slug] = r.id);

  const { randomUUID } = require('crypto');
  
  const generateLine = (companySlug, code, origin, dest, originName, destName, dist, dur, price, active) => {
    const cid = companyMap[companySlug] || companyMap[companySlug.toUpperCase()];
    if (!cid) return null;
    return `('${randomUUID()}', '${cid}', '${code}', '${origin}', '${dest}', '${originName}', '${destName}', ${dist}, ${dur}, ${price}, ${active})`;
  };

  const lineArr = [
    generateLine('sotraco', 'L1', 'Ouagadougou', 'Ouagadougou', 'Karpala', 'Place Naaba Koom', 10, 35, 200, true),
    generateLine('tsr', 'OUA-BOB-TSR', 'Ouagadougou', 'Bobo-Dioulasso', 'Gare TSR Ouaga', 'Gare TSR Bobo', 360, 330, 4500, true),
    generateLine('tsr', 'BOB-OUA-TSR', 'Bobo-Dioulasso', 'Ouagadougou', 'Gare TSR Bobo', 'Gare TSR Ouaga', 360, 330, 4500, true),
    generateLine('staf', 'OUA-BOB-STAF', 'Ouagadougou', 'Bobo-Dioulasso', 'Gare STAF Ouaga', 'Gare STAF Bobo', 360, 300, 6500, false),
    generateLine('rahimo', 'OUA-BOB-RAHIMO', 'Ouagadougou', 'Bobo-Dioulasso', 'Gare RAHIMO Ouaga', 'Gare RAHIMO Bobo', 360, 300, 6500, true),
    generateLine('rahimo', 'BOB-OUA-RAHIMO', 'Bobo-Dioulasso', 'Ouagadougou', 'Gare RAHIMO Bobo', 'Gare RAHIMO Ouaga', 360, 300, 6500, true),
    generateLine('rakieta', 'OUA-BOB-RAKIETA', 'Ouagadougou', 'Bobo-Dioulasso', 'Gare RAKIETA Ouaga', 'Gare RAKIETA Bobo', 360, 300, 7500, true),
    generateLine('rakieta', 'BOB-OUA-RAKIETA', 'Bobo-Dioulasso', 'Ouagadougou', 'Gare RAKIETA Bobo', 'Gare RAKIETA Ouaga', 360, 300, 7500, true),
    generateLine('tcv', 'OUA-BOB-TCV', 'Ouagadougou', 'Bobo-Dioulasso', 'Gare TCV Ouaga', 'Gare TCV Bobo', 360, 360, 6500, true)
  ].filter(l => l !== null);

  const lines = lineArr.join(',\n  ');

  const sql = `-- SEED: LIGNES DE TRANSPORT
INSERT INTO lines (
  id, company_id, line_code, origin_city, destination_city, origin_name, destination_name,
  distance_km, estimated_duration_minutes, base_price, is_active
) VALUES 
  ${lines}
ON CONFLICT ON CONSTRAINT lines_line_code_key DO NOTHING;
`;

  fs.writeFileSync('src/database/seeds/002_lines_fixed.sql', sql);
  await client.end();
}

run().catch(console.error);
