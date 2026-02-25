const fs = require('fs');
const path = require('path');
const { Pool } = require('pg');
require('dotenv').config();

const pool = new Pool({
  host: process.env.DB_HOST || 'localhost',
  port: process.env.DB_PORT || 5432,
  database: process.env.DB_NAME || process.env.POSTGRES_DB || 'ankata_db',
  user: process.env.DB_USER || process.env.POSTGRES_USER || 'ankata_user',
  password: process.env.DB_PASSWORD || process.env.POSTGRES_PASSWORD,
});

async function runMigration() {
  try {
    const filePath = path.join(__dirname, 'src/database/migrations/003_auth_refactor.sql');
    const sql = fs.readFileSync(filePath, 'utf8');
    await pool.query(sql);
    console.log('Migration 003_auth_refactor.sql ran successfully.');
  } catch (err) {
    console.error('Migration failed:', err);
  } finally {
    pool.end();
  }
}

runMigration();
