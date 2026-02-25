const pool = require('../src/database/connection');

async function run() {
  try {
    const query = `
      ALTER TABLE users
      DROP COLUMN IF EXISTS email,
      DROP COLUMN IF EXISTS full_name,
      ADD COLUMN IF NOT EXISTS first_name VARCHAR(255),
      ADD COLUMN IF NOT EXISTS last_name VARCHAR(255),
      ADD COLUMN IF NOT EXISTS date_of_birth DATE,
      ADD COLUMN IF NOT EXISTS cnib VARCHAR(50),
      ADD COLUMN IF NOT EXISTS gender VARCHAR(10);
    `;
    console.log('Executing query:', query);
    await pool.query(query);
    console.log("Migration successful");
  } catch (error) {
    console.error("Migration failed:", error);
  } finally {
    process.exit();
  }
}

run();
