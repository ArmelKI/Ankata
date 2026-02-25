const pool = require('./src/database/connection');
async function check() {
  try {
    const res = await pool.query(`
      SELECT column_name 
      FROM information_schema.columns 
      WHERE table_name = 'bookings';
    `);
    console.log("Columns:", res.rows.map(r => r.column_name).join(', '));
  } catch (e) {
    console.error(e);
  } finally {
    pool.end();
  }
}
check();
