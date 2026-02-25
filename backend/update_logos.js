const { Client } = require('pg');
const fs = require('fs');

async function run() {
  const client = new Client({
    user: 'ankata_user',
    host: 'localhost',
    database: 'ankata_db',
    password: 'f51vIHwgz4l1pFRm',
    port: 5432,
  });
  await client.connect();
  const res = await client.query("UPDATE companies SET logo_url = 'assets/images/companies/' || slug || '.png'");
  console.log('Updated DB rows: ' + res.rowCount);
  await client.end();

  let sql = fs.readFileSync('src/database/seeds/001_companies.sql', 'utf8');
  sql = sql.replace(/logo_url\n\) VALUES \(\n  'sotraco',\n  'SOTRACO([^]*?),\n  NULL,\n  '#00A859'/g, "logo_url\n) VALUES (\n  'sotraco',\n  'SOTRACO$1,\n  'assets/images/companies/sotraco.png',\n  '#00A859'");
  
  // It's probably easier to just rely on the DB update for this current flow, 
  // but to make the seed correct, we should do it. Let's just sed replace the specific NULLs for logos.
  // Actually, too complex to robustly regex replace the exactly 7 NULLs without hitting others. 
  // Since the DB is already updated for runtime, the seed fix can be just a simple script appended at the end of the SQL.
  
  sql += `\n\n-- UPDATE LOGOS\nUPDATE companies SET logo_url = 'assets/images/companies/' || slug || '.png';\n`;
  fs.writeFileSync('src/database/seeds/001_companies.sql', sql);
  console.log('Updated seed SQL file');
}

run().catch(console.error);
