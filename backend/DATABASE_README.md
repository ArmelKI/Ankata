# 🚌 Ankata Transport Database - Guide Complet

## 📋 Vue d'ensemble

Base de données complète pour l'application Ankata Passagers, inspirée du système SNCF mais adaptée au contexte burkinabé. Cette base contient toutes les données réelles des compagnies de transport du Burkina Faso (urbaines, interurbaines et internationales) mises à jour en février 2026.

## 📊 Contenu de la Base de Données

### ✅ Données Complètes

- **7 Compagnies de transport** avec informations détaillées
  - SOTRACO (urbain Ouagadougou/Bobo)
  - TSR (interurbain, prix bas)
  - STAF (interurbain, fiable - actuellement suspendu)
  - RAHIMO (premium, meilleur confort)
  - RAKIETA (rapide, large réseau international)
  - TCV (milieu de gamme)
  - SARAMAYA (confort)

- **60+ Lignes de transport**
  - 18 lignes urbaines SOTRACO à Ouagadougou (L1-L19)
  - 40+ lignes interurbaines nationales
  - 15+ lignes internationales (Mali, Togo, Bénin, Côte d'Ivoire, Niger)

- **100+ Horaires détaillés**
  - Horaires précis SOTRACO L3 et L6B (données Moovit 2026)
  - Horaires types toutes lignes interurbaines
  - Fréquences et capacités

- **Tarifs officiels confirmés**
  - RAKIETA : 8 destinations avec tarifs officiels 2023
  - TCV : 6 destinations avec tarifs officiels 2018
  - Autres compagnies : estimations basées sur données marché

- **Statistiques sécurité** (2019-2024)
  - Données ministère des Transports
  - Accidents, blessés, décès par compagnie

### ⚠️ Données Partielles

- Arrêts détaillés SOTRACO (329 arrêts) - À compléter via GTFS ou saisie manuelle
- Horaires précis interurbains - Estimations, à affiner avec compagnies
- Tarifs étudiants/enfants - À confirmer auprès de chaque compagnie

## 🚀 Installation

### 1. Prérequis

```bash
# PostgreSQL 12+ installé et en cours d'exécution
sudo systemctl status postgresql

# Node.js 16+ et npm
node --version
npm --version
```

### 2. Configuration

```bash
# Copier le fichier d'environnement exemple
cp .env.example .env

# Éditer .env avec vos paramètres PostgreSQL
nano .env
```

Variables importantes dans `.env` :

```env
# Base de données PostgreSQL
DB_HOST=localhost
DB_PORT=5432
DB_NAME=ankata_db
DB_USER=ankata_user
DB_PASSWORD=votre_mot_de_passe_securise

# API Config
PORT=3000
NODE_ENV=development
```

### 3. Créer la base de données PostgreSQL

```bash
# Se connecter à PostgreSQL
sudo -u postgres psql

# Créer l'utilisateur et la base de données
CREATE USER ankata_user WITH PASSWORD 'votre_mot_de_passe_securise';
CREATE DATABASE ankata_db OWNER ankata_user;
GRANT ALL PRIVILEGES ON DATABASE ankata_db TO ankata_user;

# Donner les permissions nécessaires
\c ankata_db
GRANT ALL ON SCHEMA public TO ankata_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO ankata_user;

# Quitter psql
\q
```

### 4. Initialiser la base de données

```bash
# Rendre le script exécutable
chmod +x init-database.sh

# Exécuter les migrations et seeds
./init-database.sh
```

Le script va :
1. ✅ Vérifier la connexion PostgreSQL
2. 📋 Créer toutes les tables (users, companies, lines, schedules, bookings, etc.)
3. 🌱 Insérer les 7 compagnies de transport
4. 🚌 Insérer toutes les lignes (urbaines + interurbaines + internationales)
5. ⏰ Insérer les horaires détaillés
6. 📊 Vérifier que tout est bien importé

### 5. Démarrer le serveur backend

```bash
# Installer les dépendances
npm install

# Démarrer en mode développement
npm run dev

# Le serveur démarre sur http://localhost:3000
```

## 📁 Structure des Fichiers

```
backend/
├── src/
│   ├── database/
│   │   ├── connection.js                     # Connexion PostgreSQL
│   │   ├── migrations/
│   │   │   └── 001_create_transport_tables.sql  # Schéma complet
│   │   └── seeds/
│   │       ├── 001_companies.sql             # 7 compagnies
│   │       ├── 002_lines.sql                 # 60+ lignes
│   │       └── 003_schedules.sql             # 100+ horaires
│   ├── models/                               # Modèles Sequelize/Knex
│   ├── controllers/                          # Logique métier
│   ├── routes/                               # Routes API
│   └── index.js                              # Point d'entrée
├── init-database.sh                          # Script d'initialisation
├── .env.example                              # Configuration exemple
└── package.json                              # Dépendances Node.js
```

## 🔍 Vérifier les Données

### Via psql

```bash
# Se connecter à la base
psql -h localhost -U ankata_user -d ankata_db

# Vérifier les compagnies
SELECT id, name, company_type, rating_average, badge, is_active FROM companies;

# Vérifier les lignes par compagnie
SELECT c.name, COUNT(l.id) as nb_lignes
FROM companies c
LEFT JOIN lines l ON c.id = l.company_id
GROUP BY c.name;

# Trouver les trajets Ouaga-Bobo avec prix
SELECT 
  c.name as compagnie,
  l.line_code,
  l.base_price as prix,
  l.duration_minutes/60.0 as duree_heures,
  c.badge
FROM lines l
JOIN companies c ON l.company_id = c.id
WHERE l.origin_city = 'Ouagadougou'
  AND l.destination_city = 'Bobo-Dioulasso'
  AND l.is_active = true
ORDER BY l.base_price;

# Horaires disponibles pour une ligne
SELECT 
  departure_time,
  arrival_time,
  total_seats,
  available_seats,
  days_of_week,
  notes
FROM schedules
WHERE line_id = 'rahimo_ouaga_bobo'
ORDER BY departure_time;
```

### Via l'API Backend

Une fois le serveur démarré (`npm run dev`) :

```bash
# Lister toutes les compagnies
curl http://localhost:3000/api/companies

# Détails d'une compagnie
curl http://localhost:3000/api/companies/rahimo

# Rechercher trajets Ouaga-Bobo
curl "http://localhost:3000/api/lines/search?origin=Ouagadougou&destination=Bobo-Dioulasso"

# Horaires d'une ligne
curl http://localhost:3000/api/lines/rahimo_ouaga_bobo/schedules
```

## 📊 Tables de la Base de Données

### Tables principales

| Table | Description | Nombre d'enregistrements |
|-------|-------------|-------------------------|
| `companies` | Compagnies de transport | 7 |
| `lines` | Lignes de transport | 60+ |
| `schedules` | Horaires des départs | 100+ |
| `users` | Utilisateurs de l'app | 0 (à remplir) |
| `bookings` | Réservations | 0 (à remplir) |
| `payments` | Paiements | 0 (à remplir) |
| `ratings` | Évaluations | 0 (à remplir) |
| `stops` | Arrêts de bus | 0 (à remplir) |
| `company_stats` | Statistiques sécurité | 6 |

### Relations importantes

```
companies (1) ←→ (N) lines
lines (1) ←→ (N) schedules
lines (1) ←→ (N) bookings
users (1) ←→ (N) bookings
bookings (1) ←→ (1) payments
bookings (1) ←→ (N) ratings
```

## 🎯 Exemples d'Usage

### 1. Rechercher tous les trajets disponibles

```sql
-- Vue disponible : available_trips
SELECT * FROM available_trips
WHERE origin_city = 'Ouagadougou'
  AND destination_city = 'Bobo-Dioulasso'
  AND departure_time >= '06:00:00'
  AND departure_time <= '12:00:00'
ORDER BY base_price;
```

### 2. Comparer les prix par compagnie

```sql
SELECT 
  company_name,
  badge,
  base_price,
  duration_minutes/60.0 as duree_h,
  rating_average,
  base_price/(distance_km*1.0) as prix_par_km
FROM available_trips
WHERE origin_city = 'Ouagadougou'
  AND destination_city = 'Bobo-Dioulasso'
ORDER BY base_price;
```

### 3. Trouver les horaires d'une journée spécifique

```sql
-- Ex: Lundi
SELECT 
  l.line_name,
  c.name as compagnie,
  s.departure_time,
  s.arrival_time,
  s.available_seats,
  l.base_price
FROM schedules s
JOIN lines l ON s.line_id = l.id
JOIN companies c ON l.company_id = c.id
WHERE 'LUNDI' = ANY(s.days_of_week)
  AND l.origin_city = 'Ouagadougou'
  AND l.destination_city = 'Bobo-Dioulasso'
  AND s.is_active = true
ORDER BY s.departure_time;
```

## 🔧 Maintenance

### Réinitialiser la base de données

```bash
# ATTENTION : Cela supprime TOUTES les données !
psql -h localhost -U ankata_user -d ankata_db -c "DROP SCHEMA public CASCADE; CREATE SCHEMA public;"

# Puis relancer l'initialisation
./init-database.sh
```

### Ajouter des données manuellement

```bash
# Via psql
psql -h localhost -U ankata_user -d ankata_db

# Exemple : Ajouter une nouvelle ligne
INSERT INTO lines (
  id, company_id, line_code, line_name,
  origin_city, destination_city,
  distance_km, duration_minutes, line_type,
  base_price, included_luggage_kg, is_active
) VALUES (
  'nouvelle_ligne_id', 'sotraco', 'L20', 'Nouvelle Ligne',
  'Ouagadougou', 'Ouagadougou',
  15, 45, 'URBAIN',
  NULL, 0, true
);
```

### Backup de la base de données

```bash
# Créer un backup
pg_dump -h localhost -U ankata_user -d ankata_db > backup_ankata_$(date +%Y%m%d).sql

# Restaurer depuis un backup
psql -h localhost -U ankata_user -d ankata_db < backup_ankata_20260223.sql
```

## 📝 Données Manquantes à Compléter

### Priorité Haute
1. **Arrêts SOTRACO détaillés** (329 arrêts)
   - Noms, coordonnées GPS, séquence sur chaque ligne
   - Solution : Import GTFS ou saisie manuelle via back-office

2. **Horaires précis interurbains**
   - Actuellement : horaires types estimés
   - Solution : Contacter chaque compagnie directement

### Priorité Moyenne
3. **Tarifs étudiants/enfants**
   - Actuellement : NULL ou estimations
   - Solution : Confirmation auprès des compagnies

4. **Contacts complets**
   - WhatsApp, emails manquants pour certaines compagnies
   - Solution : Recherche terrain ou site web

### Priorité Basse
5. **Lignes SOTRACO L11-L19**
   - Terminus non confirmés
   - Solution : Import GTFS SOTRACO officiel

## 🆘 Dépannage

### Erreur : "FATAL: password authentication failed"
```bash
# Vérifier que DB_PASSWORD dans .env correspond au mot de passe PostgreSQL
# Réinitialiser le mot de passe si nécessaire :
sudo -u postgres psql -c "ALTER USER ankata_user WITH PASSWORD 'nouveau_mdp';"
```

### Erreur : "relation X already exists"
```bash
# Les tables existent déjà. Options :
# 1. Supprimer et recréer (perte de données)
./init-database.sh --force

# 2. Ou créer une nouvelle base
CREATE DATABASE ankata_db_test OWNER ankata_user;
# Puis modifier .env pour pointer vers ankata_db_test
```

### Erreur : "permission denied for schema public"
```bash
sudo -u postgres psql -d ankata_db
GRANT ALL ON SCHEMA public TO ankata_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO ankata_user;
```

## 📞 Support

Pour toute question ou problème :
- **Email** : support@axiane-agency.com
- **Documentation** : Voir `backend/README.md`
- **Issues** : Contacter l'équipe de développement

## 📄 Licence

Proprietary - Axiane Agency © 2026
