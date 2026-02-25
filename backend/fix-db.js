const pool = require('./src/database/connection');
async function fix() {
  try {
    await pool.query("ALTER TABLE users ALTER COLUMN country_code TYPE VARCHAR(5);");
    console.log("Fixed country_code type");
  } catch(e) { console.error(e); }
  process.exit(0);
}
fix();
