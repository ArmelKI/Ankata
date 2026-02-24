#!/bin/bash

# =====================================================
# ANKATA - Script d'initialisation de la base de données
# Exécute les migrations et seeds dans l'ordre correct
# =====================================================

set -e  # Arrêter le script en cas d'erreur

# Couleurs pour le terminal
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Charger les variables d'environnement
if [ -f .env ]; then
    source .env
else
    echo -e "${RED}❌ Fichier .env introuvable${NC}"
    exit 1
fi

# Configuration par défaut (peut être overridé par .env)
DB_HOST=${DB_HOST:-localhost}
DB_PORT=${DB_PORT:-5432}
DB_NAME=${DB_NAME:-ankata_db}
DB_USER=${DB_USER:-ankata_user}

echo -e "${BLUE}================================================${NC}"
echo -e "${BLUE}🚀 ANKATA - Initialisation Base de Données${NC}"
echo -e "${BLUE}================================================${NC}"
echo ""
echo -e "Host: ${DB_HOST}:${DB_PORT}"
echo -e "Database: ${DB_NAME}"
echo -e "User: ${DB_USER}"
echo ""

# Fonction pour exécuter un fichier SQL
run_sql_file() {
    local file=$1
    local description=$2
    
    echo -e "${YELLOW}⏳ ${description}...${NC}"
    
    if [ ! -f "$file" ]; then
        echo -e "${RED}❌ Fichier introuvable: $file${NC}"
        return 1
    fi
    
    PGPASSWORD=$DB_PASSWORD psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -f "$file" > /dev/null 2>&1
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ ${description} - OK${NC}"
        return 0
    else
        echo -e "${RED}❌ ${description} - ERREUR${NC}"
        return 1
    fi
}

# Vérifier la connexion à PostgreSQL
echo -e "${YELLOW}🔧 Vérification de la connexion PostgreSQL...${NC}"
PGPASSWORD=$DB_PASSWORD psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -c "SELECT version();" > /dev/null 2>&1

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Connexion PostgreSQL OK${NC}"
else
    echo -e "${RED}❌ Impossible de se connecter à PostgreSQL${NC}"
    echo -e "${RED}Vérifiez vos paramètres dans le fichier .env${NC}"
    exit 1
fi

echo ""
echo -e "${BLUE}================================================${NC}"
echo -e "${BLUE}📋 ÉTAPE 1: MIGRATIONS (Création des tables)${NC}"
echo -e "${BLUE}================================================${NC}"
echo ""

run_sql_file "src/database/migrations/001_create_transport_tables.sql" "Création des tables"

echo ""
echo -e "${BLUE}================================================${NC}"
echo -e "${BLUE}🌱 ÉTAPE 2: SEEDS (Données initiales)${NC}"
echo -e "${BLUE}================================================${NC}"
echo ""

run_sql_file "src/database/seeds/001_companies.sql" "Seed Compagnies (7 compagnies)"
run_sql_file "src/database/seeds/002_lines.sql" "Seed Lignes (60+ lignes)"
run_sql_file "src/database/seeds/003_schedules.sql" "Seed Horaires (100+ horaires)"

echo ""
echo -e "${BLUE}================================================${NC}"
echo -e "${BLUE}📊 VÉRIFICATION DES DONNÉES${NC}"
echo -e "${BLUE}================================================${NC}"
echo ""

# Vérifier le nombre d'enregistrements
echo -e "${YELLOW}📈 Statistiques de la base de données:${NC}"
echo ""

COMPANIES_COUNT=$(PGPASSWORD=$DB_PASSWORD psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -t -c "SELECT COUNT(*) FROM companies;")
LINES_COUNT=$(PGPASSWORD=$DB_PASSWORD psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -t -c "SELECT COUNT(*) FROM lines;")
SCHEDULES_COUNT=$(PGPASSWORD=$DB_PASSWORD psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -t -c "SELECT COUNT(*) FROM schedules;")

echo -e "  🏢 Compagnies: ${GREEN}${COMPANIES_COUNT}${NC}"
echo -e "  🚌 Lignes: ${GREEN}${LINES_COUNT}${NC}"
echo -e "  ⏰ Horaires: ${GREEN}${SCHEDULES_COUNT}${NC}"

echo ""
echo -e "${GREEN}================================================${NC}"
echo -e "${GREEN}✅ INITIALISATION TERMINÉE AVEC SUCCÈS !${NC}"
echo -e "${GREEN}================================================${NC}"
echo ""
echo -e "La base de données Ankata est prête à être utilisée."
echo -e "Vous pouvez maintenant démarrer le serveur backend avec: ${BLUE}npm run dev${NC}"
echo ""
