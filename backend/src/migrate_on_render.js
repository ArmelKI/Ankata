const { Client } = require('pg');
const fs = require('fs');
const path = require('path');

async function migrate() {
  if (!process.env.DATABASE_URL) {
    console.log('Skipping migration: DATABASE_URL not set');
    return;
  }
  
  if (process.env.NODE_ENV !== 'production') {
    console.log('Skipping migration: Not in production environment');
    return;
  }
  
  console.log('Starting automated migration to Supabase on Render...');
  
  const client = new Client({
    connectionString: process.env.DATABASE_URL,
    ssl: { rejectUnauthorized: false }
  });

  try {
    await client.connect();
    console.log('Connected to DB successfully!');
    
    // Check if migration is already done
    const res = await client.query(`
      SELECT EXISTS (
        SELECT FROM information_schema.tables 
        WHERE table_schema = 'public' AND table_name = 'companies'
      );
    `);
    
    if (res.rows[0].exists) {
      console.log('Tables already exist! Checking data...');
      const obj = await client.query('SELECT count(*) FROM companies');
      if (parseInt(obj.rows[0].count) > 0) {
        console.log('Data already migrated. Skipping migration.');
        await client.end();
        return;
      }
    }

    const schemaPath = path.join(__dirname, '../SUPABASE_SCHEMA.sql');
    const dataPath = path.join(__dirname, '../MIGRATION_DATA.sql');
    
    if (fs.existsSync(schemaPath)) {
      console.log('Executing Schema...');
      const schemaSql = fs.readFileSync(schemaPath, 'utf8');
      await client.query(schemaSql);
      console.log('Schema created!');
    }
    
    if (fs.existsSync(dataPath)) {
      console.log('Executing Data Import...');
      const dataSql = fs.readFileSync(dataPath, 'utf8');
      await client.query(dataSql);
      console.log('Data imported!');
    }
    
    console.log('🎉 Migration completed successfully!');
  } catch (err) {
    console.error('Migration failed:', err);
    process.exit(1);
  } finally {
    await client.end();
  }
}

migrate();
