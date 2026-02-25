const pool = require('./src/database/connection');
async function test() {
  try {
    const res = await pool.query("SELECT column_name, data_type, character_maximum_length FROM information_schema.columns WHERE table_name = 'users'");
    console.log(res.rows);
  } catch(e) { console.error(e); }
  process.exit(0);
}
test();
