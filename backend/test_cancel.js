const { Client } = require('pg');
const axios = require('axios');

async function run() {
  const client = new Client({
    user: 'ankata_user',
    host: 'localhost',
    database: 'ankata_db',
    password: 'f51vIHwgz4l1pFRm',
    port: 5432,
  });
  await client.connect();

  let res = await client.query("SELECT id FROM users LIMIT 1");
  const userId = res.rows[0].id;

  const jwt = require('jsonwebtoken');
  const token = jwt.sign({ userId, phone: '00000000' }, 'your_jwt_secret_key_here_min_32_chars', { expiresIn: '7d' });

  res = await client.query("SELECT id, line_id FROM schedules LIMIT 1");
  const scheduleId = res.rows[0].id;
  const lineId = res.rows[0].line_id;

  const { randomUUID } = require('crypto');
  const bookingId = randomUUID();

  await client.query(`
    INSERT INTO bookings (id, booking_code, user_id, schedule_id, line_id, company_id, passenger_name, departure_date, total_amount, base_price, booking_status)
    VALUES ($1, 'TEST-12345', $2, $3, $4, (SELECT company_id FROM lines WHERE id = $4), 'Test User', CURRENT_DATE + INTERVAL '1 day', 5000, 5000, 'CONFIRMED')
  `, [bookingId, userId, scheduleId, lineId]);

  console.log('Created booking:', bookingId);

  try {
    const apiRes = await axios.post(`http://localhost:3000/api/bookings/${bookingId}/cancel`, {
      reason: 'Testing cancellation'
    }, {
      headers: { Authorization: `Bearer ${token}` }
    });
    console.log('Cancel API success:', apiRes.data);
  } catch (err) {
    if (err.response) {
      console.log('Cancel API error response:', err.response.status, err.response.data);
    } else {
      console.log('Cancel API runtime error:', err.message);
    }
  }

  await client.query("DELETE FROM bookings WHERE id = $1", [bookingId]);
  await client.end();
}

run().catch(console.error);
