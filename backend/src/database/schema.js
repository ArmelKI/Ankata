const fs = require('fs');
const path = require('path');
const pool = require('./connection');

/**
 * Initializes the database by running all migration scripts.
 */
async function initializeDatabase() {
  console.log('[Database] Starting initialization...');

  try {
    // 1. Ensure extensions exist
    await pool.query('CREATE EXTENSION IF NOT EXISTS "uuid-ossp"');

    // 2. Core tables (Basic scaffolding if not exists)
    // Most logic should be in migrate_*.sql files, but we need a base.
    await pool.query(`
      CREATE TABLE IF NOT EXISTS users (
        id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
        phone VARCHAR(20) UNIQUE,
        email VARCHAR(255) UNIQUE,
        full_name VARCHAR(255),
        cnib VARCHAR(50),
        profile_picture_url TEXT,
        level INTEGER DEFAULT 1,
        xp INTEGER DEFAULT 0,
        is_active BOOLEAN DEFAULT TRUE,
        created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
      );
    `);

    // 3. Find and run all migrate_*.sql files
    const dbDir = __dirname;
    const files = fs.readdirSync(dbDir);
    const migrateFiles = files.filter(f => f.startsWith('migrate_') && f.endsWith('.sql')).sort();

    console.log(`[Database] Found ${migrateFiles.length} migration files to process.`);

    for (const file of migrateFiles) {
      const filePath = path.join(dbDir, file);
      console.log(`[Database] Applying migration: ${file}`);
      const sql = fs.readFileSync(filePath, 'utf8');
      
      // Execute as a single block. Note: This assumes the SQL is safe to run repeatedly (IF NOT EXISTS).
      await pool.query(sql);
    }

    console.log('[Database] Initialization complete successfully.');
  } catch (error) {
    console.error('[Database] Initialization error:', error);
    throw error;
  }
}

module.exports = { initializeDatabase };
