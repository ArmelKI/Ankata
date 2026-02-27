const { initializeDatabase } = require('./src/database/schema');
const { runSeeds } = require('./src/database/seeds/run-seeds');

/**
 * Main database initialization and seeding script.
 * Can be run via `npm run db:init`.
 */
async function main() {
  console.log('=== Ankata Database Initialization ===');
  
  try {
    // 1. Initialize schema and migrations
    await initializeDatabase();
    
    // 2. Run seeds
    console.log('[Database] Running seeds...');
    await runSeeds();
    
    console.log('=== Initialization Successful ===');
    process.exit(0);
  } catch (error) {
    console.error('=== Initialization Failed ===');
    console.error(error);
    process.exit(1);
  }
}

main();
