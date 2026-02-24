const fs = require('fs');
const path = require('path');
const { Pool } = require('pg');
require('dotenv').config();

// Configuration de la connexion PostgreSQL
const pool = new Pool({
  host: process.env.DB_HOST || 'localhost',
  port: process.env.DB_PORT || 5432,
  database: process.env.DB_NAME || process.env.POSTGRES_DB || 'ankata_db',
  user: process.env.DB_USER || process.env.POSTGRES_USER || 'ankata_user',
  password: process.env.DB_PASSWORD || process.env.POSTGRES_PASSWORD,
});

// Couleurs pour le terminal
const colors = {
  reset: '\x1b[0m',
  bright: '\x1b[1m',
  red: '\x1b[31m',
  green: '\x1b[32m',
  yellow: '\x1b[33m',
  blue: '\x1b[34m',
};

const log = {
  info: (msg) => console.log(`${colors.blue}ℹ${colors.reset} ${msg}`),
  success: (msg) => console.log(`${colors.green}✅${colors.reset} ${msg}`),
  warning: (msg) => console.log(`${colors.yellow}⚠${colors.reset} ${msg}`),
  error: (msg) => console.log(`${colors.red}❌${colors.reset} ${msg}`),
  title: (msg) => console.log(`\n${colors.bright}${colors.blue}${msg}${colors.reset}\n`),
};

/**
 * Exécute un fichier SQL
 */
async function executeSQLFile(filePath, description) {
  try {
    log.info(`${description}...`);
    
    if (!fs.existsSync(filePath)) {
      throw new Error(`Fichier introuvable: ${filePath}`);
    }

    const sql = fs.readFileSync(filePath, 'utf8');
    await pool.query(sql);
    
    log.success(`${description} - OK`);
    return true;
  } catch (error) {
    log.error(`${description} - ERREUR`);
    console.error(error.message);
    return false;
  }
}

/**
 * Vérifie la connexion à PostgreSQL
 */
async function checkConnection() {
  try {
    log.info('Vérification de la connexion PostgreSQL...');
    const result = await pool.query('SELECT version()');
    log.success('Connexion PostgreSQL OK');
    return true;
  } catch (error) {
    log.error('Impossible de se connecter à PostgreSQL');
    console.error(error.message);
    return false;
  }
}

/**
 * Récupère les statistiques de la base
 */
async function getStatistics() {
  try {
    const queries = [
      { name: 'Compagnies', query: 'SELECT COUNT(*) FROM companies' },
      { name: 'Lignes', query: 'SELECT COUNT(*) FROM lines' },
      { name: 'Horaires', query: 'SELECT COUNT(*) FROM schedules' },
    ];

    log.title('📊 Statistiques de la base de données');

    for (const { name, query } of queries) {
      const result = await pool.query(query);
      const count = result.rows[0].count;
      console.log(`  🚌 ${name}: ${colors.green}${count}${colors.reset}`);
    }
  } catch (error) {
    log.warning('Impossible de récupérer les statistiques');
    console.error(error.message);
  }
}

/**
 * Fonction principale
 */
async function main() {
  console.log('\n' + '='.repeat(60));
  log.title('🚀 ANKATA - Initialisation Base de Données');
  console.log('='.repeat(60));

  console.log(`\nHost: ${process.env.DB_HOST || 'localhost'}:${process.env.DB_PORT || 5432}`);
  console.log(`Database: ${process.env.DB_NAME || process.env.POSTGRES_DB}`);
  console.log(`User: ${process.env.DB_USER || process.env.POSTGRES_USER}\n`);

  // Vérifier la connexion
  const connected = await checkConnection();
  if (!connected) {
    log.error('Arrêt du script. Vérifiez vos paramètres de connexion dans .env');
    process.exit(1);
  }

  // ÉTAPE 1: Migrations
  log.title('📋 ÉTAPE 1: MIGRATIONS (Création des tables)');
  
  const migrationSuccess = await executeSQLFile(
    path.join(__dirname, 'src/database/migrations/001_create_transport_tables.sql'),
    'Création des tables'
  );

  if (!migrationSuccess) {
    log.error('Échec des migrations. Arrêt du script.');
    process.exit(1);
  }

  // ÉTAPE 2: Seeds
  log.title('🌱 ÉTAPE 2: SEEDS (Données initiales)');

  const seeds = [
    { file: 'src/database/seeds/001_companies.sql', description: 'Seed Compagnies (7 compagnies)' },
    { file: 'src/database/seeds/002_lines.sql', description: 'Seed Lignes (60+ lignes)' },
    { file: 'src/database/seeds/003_schedules.sql', description: 'Seed Horaires (100+ horaires)' },
  ];

  for (const { file, description } of seeds) {
    const success = await executeSQLFile(path.join(__dirname, file), description);
    if (!success) {
      log.warning(`Erreur lors de ${description}, mais continuation du script...`);
    }
  }

  // ÉTAPE 3: Vérification
  await getStatistics();

  // Fin
  console.log('\n' + '='.repeat(60));
  log.success('✅ INITIALISATION TERMINÉE AVEC SUCCÈS !');
  console.log('='.repeat(60) + '\n');

  console.log('La base de données Ankata est prête à être utilisée.');
  console.log(`Vous pouvez maintenant démarrer le serveur backend avec: ${colors.blue}npm run dev${colors.reset}\n`);

  await pool.end();
  process.exit(0);
}

// Gestion des erreurs non catchées
process.on('unhandledRejection', (error) => {
  log.error('Erreur non gérée:');
  console.error(error);
  pool.end();
  process.exit(1);
});

// Exécution
main().catch((error) => {
  log.error('Erreur fatale:');
  console.error(error);
  pool.end();
  process.exit(1);
});
