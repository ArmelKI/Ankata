const pool = require('./src/database/connection');
async function check() {
  try {
    const res = await pool.query(`SELECT id FROM users LIMIT 1`);
    console.log("User ID:", res.rows[0].id);
  } catch (e) {
    console.error(e);
  } finally {
    pool.end();
  }
}
check();
