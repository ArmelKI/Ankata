const { Client } = require('pg');

async function run() {
  const client = new Client({
    user: 'ankata_user',
    host: 'localhost',
    database: 'ankata_db',
    password: 'f51vIHwgz4l1pFRm',
    port: 5432,
  });
  await client.connect();

  const res = await client.query("SELECT * FROM ratings LIMIT 5;");
  console.log('Ratings:', res.rows);

  await client.end();
}

run().catch(console.error);
