/**
 * Validation des variables d'environnement critiques
 * Crash rapide au démarrage si config manquante
 */

const requiredEnvVars = {
  DATABASE_URL: 'Connection string PostgreSQL/Supabase',
  JWT_SECRET: 'Secret pour signer les tokens JWT (min 32 chars)',
  NODE_ENV: 'Environment (development|production)',
};

const optionalEnvVars = {
  SUPABASE_URL: 'URL du projet Supabase',
  SUPABASE_SERVICE_ROLE_KEY: 'Clé service role Supabase',
  PORT: 'Port du serveur (défaut: 3000)',
  API_BASE_URL: 'URL publique de l\'API',
  FRONTEND_URL: 'URL du frontend pour CORS',
};

function validateEnv() {
  const missing = [];
  const warnings = [];

  // Vérifier variables obligatoires
  for (const [key, description] of Object.entries(requiredEnvVars)) {
    if (!process.env[key]) {
      missing.push(`${key}: ${description}`);
    }
  }

  // JWT_SECRET doit être assez long
  if (process.env.JWT_SECRET && process.env.JWT_SECRET.length < 32) {
    warnings.push('JWT_SECRET est trop court (< 32 caractères)');
  }

  // Alertes pour variables optionnelles manquantes
  for (const [key, description] of Object.entries(optionalEnvVars)) {
    if (!process.env[key]) {
      warnings.push(`${key} non défini: ${description}`);
    }
  }

  // Crash si variables critiques manquantes
  if (missing.length > 0) {
    console.error('[ERREUR]: Variables d\'environnement manquantes:');
    missing.forEach((msg) => console.error(`   - ${msg}`));
    console.error('\nCopiez .env.example vers .env et remplissez les valeurs.');
    process.exit(1);
  }

  // Warnings non bloquants
  if (warnings.length > 0 && process.env.NODE_ENV === 'development') {
    console.warn('[WARNINGS]:');
    warnings.forEach((msg) => console.warn(`   - ${msg}`));
  }

  console.log('[OK] Variables d\'environnement validées');
}

module.exports = { validateEnv };
