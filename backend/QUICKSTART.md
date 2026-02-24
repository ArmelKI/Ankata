# 🚀 Ankata Backend - Guide de Démarrage Rapide

> Base de données complète du transport burkinabé (Février 2026)  
> Inspiré de SNCF, adapté au Burkina Faso 🇧🇫

## ⚡ Installation en 5 Minutes

### 1️⃣ Prérequis

```bash
# Vérifier PostgreSQL
psql --version  # Version 12+

# Vérifier Node.js
node --version  # Version 16+
npm --version   # Version 8+
```

### 2️⃣ Configuration

```bash
# Cloner et naviguer
cd /home/armelki/Documents/projets/Ankata/backend

# Copier le fichier environnement
cp .env.example .env

# Éditer .env (modifier le mot de passe !)
nano .env
```

**Variables importantes à configurer :**
```env
# PostgreSQL
DB_HOST=localhost
DB_PORT=5432
DB_NAME=ankata_db
DB_USER=ankata_user
DB_PASSWORD=VotreMotDePasseSecurise123!  # ⚠️ À CHANGER !

# API
API_PORT=3000
NODE_ENV=development
```

### 3️⃣ Créer la Base PostgreSQL

```bash
# Devenir utilisateur postgres
sudo -u postgres psql

# Dans psql, exécuter :
CREATE USER ankata_user WITH PASSWORD 'VotreMotDePasseSecurise123!';
CREATE DATABASE ankata_db OWNER ankata_user;
GRANT ALL PRIVILEGES ON DATABASE ankata_db TO ankata_user;
\c ankata_db
GRANT ALL ON SCHEMA public TO ankata_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO ankata_user;
\q
```

### 4️⃣ Installer les Dépendances

```bash
npm install
```

### 5️⃣ Initialiser la Base de Données

**Option A : Script Node.js (recommandé)**
```bash
npm run db:init
```

**Option B : Script Bash**
```bash
chmod +x init-database.sh
./init-database.sh
```

**✅ Résultat attendu :**
```
🚀 ANKATA - Initialisation Base de Données
================================================
✅ Connexion PostgreSQL OK
✅ Création des tables - OK
✅ Seed Compagnies (7 compagnies) - OK
✅ Seed Lignes (60+ lignes) - OK
✅ Seed Horaires (100+ horaires) - OK

📊 Statistiques de la base de données:
  🏢 Compagnies: 7
  🚌 Lignes: 60
  ⏰ Horaires: 100+

✅ INITIALISATION TERMINÉE AVEC SUCCÈS !
```

### 6️⃣ Démarrer le Serveur

```bash
npm run dev
```

**✅ Serveur démarré sur :** `http://localhost:3000`

### 7️⃣ Tester l'API

```bash
# Vérifier la santé de l'API
curl http://localhost:3000/health

# Lister les compagnies
curl http://localhost:3000/api/companies

# Rechercher trajets Ouaga-Bobo
curl "http://localhost:3000/api/lines/search?origin=Ouagadougou&destination=Bobo-Dioulasso"
```

---

## 📦 Ce Qui Est Inclus

### ✅ 7 Compagnies de Transport

| Compagnie | Type | Badge | Prix | Note |
|-----------|------|-------|------|------|
| **SOTRACO** | Urbain | Éco-responsable | ~150-200 FCFA | 3.5/5 |
| **TSR** | Interurbain | Prix bas | 4500 FCFA Ouaga-Bobo | 2.5/5 |
| **STAF** | Interurbain | Fiable | 6500 FCFA (suspendu) | 4.1/5 |
| **RAHIMO** | Premium | Premium | 6500-8000 FCFA | 4.6/5 ⭐ |
| **RAKIETA** | Interurbain | Rapide | 7500 FCFA | 4.3/5 |
| **TCV** | Interurbain | Milieu gamme | 6500 FCFA | 3.0/5 |
| **SARAMAYA** | Interurbain | Confort | 6000 FCFA | 2.5/5 |

### ✅ 60+ Lignes de Transport

- **18 lignes urbaines SOTRACO** à Ouagadougou (L1-L19)
- **8 options Ouagadougou → Bobo-Dioulasso** (toutes compagnies)
- **Lignes nationales** : Banfora, Niangoloko, Boromo
- **Lignes internationales** :
  - 🇨🇮 Côte d'Ivoire : Abidjan, Bouaké
  - 🇹🇬 Togo : Lomé
  - 🇧🇯 Bénin : Cotonou
  - 🇲🇱 Mali : Bamako, Sikasso
  - 🇳🇪 Niger : Niamey

### ✅ 100+ Horaires Détaillés

- **SOTRACO L3** : Horaires précis dimanche (05:50 - 20:30)
- **SOTRACO L6B** : Horaires précis lundi heures pointe (05:10 - 07:39)
- **Interurbains** : Horaires types 6-8 départs/jour
- **Internationaux** : Horaires confirmés (ex: TCV Lomé dimanche 06h)

### ✅ Tarifs Officiels Confirmés

**RAKIETA (Tarifs 2023) :**
- Ouaga → Bobo : 7 500 FCFA
- Ouaga → Banfora : 9 000 FCFA
- Ouaga → Abidjan : 32 500 FCFA
- Ouaga → Bamako : 20 500 FCFA
- Ouaga → Lomé : 20 000 FCFA

**TCV (Tarifs 2018) :**
- Ouaga → Bobo : 6 500 FCFA
- Ouaga → Abidjan : 25 000 FCFA
- Ouaga → Cotonou : 22 000 FCFA
- Ouaga → Bamako : 16 500 FCFA

---

## 📚 Documentation Complète

- **[DATABASE_README.md](./DATABASE_README.md)** - Documentation complète de la base
- **[API_TESTS.md](./API_TESTS.md)** - Guide de tests API
- **Migrations** : `src/database/migrations/001_create_transport_tables.sql`
- **Seeds** :
  - `src/database/seeds/001_companies.sql` (7 compagnies)
  - `src/database/seeds/002_lines.sql` (60+ lignes)
  - `src/database/seeds/003_schedules.sql` (100+ horaires)

---

## 🔧 Commandes NPM Utiles

```bash
# Initialiser la base de données
npm run db:init

# Démarrer le serveur (développement)
npm run dev

# Démarrer le serveur (production)
npm start

# Réinitialiser complètement la base (⚠️ SUPPRIME TOUT)
npm run db:reset

# Tests
npm test

# Linter
npm run lint
```

---

## 🎯 Exemples d'Usage Rapide

### Rechercher un trajet

```bash
# Ouagadougou → Bobo-Dioulasso
curl "http://localhost:3000/api/lines/search?origin=Ouagadougou&destination=Bobo-Dioulasso" | jq .

# Réponse : 8 options (TSR, STAF, RAHIMO x2, RAKIETA, TCV, SARAMAYA x2)
# Prix : de 4500 FCFA (TSR) à 8000 FCFA (RAHIMO VIP)
```

### Comparer les prix

```javascript
// Les compagnies pour Ouaga-Bobo triées par prix :
1. TSR           - 4500 FCFA  (Prix bas, mais confort limité)
2. SARAMAYA      - 6000 FCFA  (Confort, nouveau)
3. STAF          - 6500 FCFA  (Suspendu temporairement ⚠️)
4. RAHIMO        - 6500 FCFA  (Premium, meilleur confort ⭐)
5. TCV           - 6500 FCFA  (Milieu gamme)
6. RAKIETA       - 7500 FCFA  (Rapide, fiable)
7. SARAMAYA VIP  - 7500 FCFA  (Confort VIP)
8. RAHIMO VIP    - 8000 FCFA  (Premium VIP, meilleur service)
```

### Voir les horaires détaillés

```bash
# Horaires RAHIMO Premium vers Bobo
curl http://localhost:3000/api/lines/rahimo_ouaga_bobo/schedules | jq .

# Résultat : 5 départs quotidiens (07:30, 10:00, 14:30, 18:30, 23:30)
```

---

## 🐛 Résolution de Problèmes

### ❌ Erreur : "password authentication failed"

```bash
# Vérifier que le mot de passe dans .env correspond à PostgreSQL
# Réinitialiser si nécessaire :
sudo -u postgres psql -c "ALTER USER ankata_user WITH PASSWORD 'NouveauMotDePasse';"

# Mettre à jour .env avec le nouveau mot de passe
```

### ❌ Erreur : "relation already exists"

```bash
# Les tables existent déjà. Pour réinitialiser :
npm run db:reset
```

### ❌ Erreur : "permission denied for schema public"

```bash
sudo -u postgres psql -d ankata_db
GRANT ALL ON SCHEMA public TO ankata_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO ankata_user;
\q
```

### ❌ Serveur ne démarre pas (port déjà utilisé)

```bash
# Vérifier quel processus utilise le port 3000
lsof -i :3000

# Tuer le processus
kill -9 <PID>

# Ou changer le port dans .env
API_PORT=3001
```

---

## 🎨 Fonctionnalités Principales

### ✅ Recherche de Trajets
- Par ville d'origine et destination
- Filtrage par prix, durée, note
- Tri par compagnie, horaire

### ✅ Réservation de Billets
- Sélection siège(s)
- Calcul automatique prix total
- Génération code réservation 8 chiffres

### ✅ Paiement Intégré
- Orange Money
- Moov Money
- Yenga Pay (à venir)

### ✅ Système d'Évaluations
- Note globale et notes détaillées (confort, ponctualité, etc.)
- Commentaires vérifiés (uniquement voyageurs confirmés)
- Mise à jour automatique rating compagnie

### ✅ Transport Urbain SOTRACO
- 18 lignes Ouagadougou
- Horaires détaillés L3 et L6B
- Fréquences en temps réel

---

## 📊 Statistiques Base de Données

```sql
-- Se connecter
psql -h localhost -U ankata_user -d ankata_db

-- Vue d'ensemble
SELECT 
  (SELECT COUNT(*) FROM companies WHERE is_active = true) as compagnies,
  (SELECT COUNT(*) FROM lines WHERE is_active = true) as lignes,
  (SELECT COUNT(*) FROM schedules WHERE is_active = true) as horaires,
  (SELECT COUNT(DISTINCT destination_city) FROM lines) as destinations;
```

**Résultat attendu :**
```
 compagnies | lignes | horaires | destinations 
------------+--------+----------+--------------
          6 |     60 |      100 |           15
```

---

## 🚀 Prochaines Étapes

1. ✅ **Base de données initialisée**
2. ⏳ **Tester l'API** (voir [API_TESTS.md](./API_TESTS.md))
3. ⏳ **Intégrer frontend mobile Flutter**
4. ⏳ **Configurer authentification OTP**
5. ⏳ **Intégrer paiements mobile money**
6. ⏳ **Déployer sur serveur production**

---

## 📞 Support

- **Documentation** : [DATABASE_README.md](./DATABASE_README.md)
- **Tests API** : [API_TESTS.md](./API_TESTS.md)
- **Email** : support@axiane-agency.com

---

## 📄 Licence

Proprietary - Axiane Agency © 2026

---

**🎉 Félicitations ! Votre base de données Ankata est prête !**

```
┌─────────────────────────────────────────┐
│  🚌 ANKATA - Transport Intelligent      │
│  🇧🇫 Made in Burkina Faso               │
│  ⭐ Inspiré de SNCF, adapté au contexte │
└─────────────────────────────────────────┘
```
