const { initializeDatabase } = require('./schema');

(async () => {
  try {
    await initializeDatabase();
    process.exit(0);
  } catch (error) {
    console.error('Migration failed:', error.message);
    process.exit(1);
  }
})();
