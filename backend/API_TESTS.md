# 🧪 Tests API Ankata - Guide de Vérification

Ce guide vous permet de tester rapidement l'API Ankata une fois la base de données initialisée.

## Prérequis

1. Base de données initialisée : `npm run db:init`
2. Serveur backend démarré : `npm run dev`
3. Serveur accessible sur `http://localhost:3000`

## 🔍 Tests Manuels avec cURL

### 1. Vérifier que l'API fonctionne

```bash
# Health check
curl http://localhost:3000/health

# Réponse attendue:
# {"status":"ok","timestamp":"2026-02-23T..."}
```

### 2. Lister toutes les compagnies

```bash
curl http://localhost:3000/api/companies

# Réponse : Array de 7 compagnies avec leurs infos
```

**Réponse attendue :**
```json
[
  {
    "id": "sotraco",
    "name": "SOTRACO - Société de Transport en Commun",
    "slug": "sotraco",
    "company_type": "URBAIN",
    "primary_color": "#00A859",
    "rating_average": "3.50",
    "badge": "Éco-responsable",
    "is_active": true
  },
  {
    "id": "rahimo",
    "name": "RAHIMO Transports",
    "slug": "rahimo",
    "company_type": "INTERURBAIN",
    "rating_average": "4.60",
    "badge": "Premium",
    "is_active": true
  }
  // ... 5 autres compagnies
]
```

### 3. Détails d'une compagnie spécifique

```bash
# RAHIMO (premium)
curl http://localhost:3000/api/companies/rahimo

# TSR (prix bas)
curl http://localhost:3000/api/companies/tsr

# STAF (suspendue)
curl http://localhost:3000/api/companies/staf
```

**Réponse RAHIMO attendue :**
```json
{
  "id": "rahimo",
  "name": "RAHIMO Transports",
  "slug": "rahimo",
  "company_type": "INTERURBAIN",
  "description": "Compagnie premium créée en 2011...",
  "primary_color": "#DC143C",
  "secondary_color": "#FFD700",
  "rating_average": "4.60",
  "total_ratings": 892,
  "badge": "Premium",
  "is_active": true,
  "lines": [
    // Liste des lignes RAHIMO
  ]
}
```

### 4. Rechercher des trajets

```bash
# Ouagadougou → Bobo-Dioulasso (trajet le plus populaire)
curl "http://localhost:3000/api/lines/search?origin=Ouagadougou&destination=Bobo-Dioulasso"

# Ouagadougou → Abidjan (international)
curl "http://localhost:3000/api/lines/search?origin=Ouagadougou&destination=Abidjan"

# Ouagadougou → Lomé
curl "http://localhost:3000/api/lines/search?origin=Ouagadougou&destination=Lomé"
```

**Réponse Ouaga-Bobo attendue :**
```json
[
  {
    "line_id": "tsr_ouaga_bobo",
    "line_code": "OUA-BOB-TSR",
    "line_name": "Ouagadougou ↔ Bobo-Dioulasso",
    "company_name": "TSR - Transport Sana Rasmané",
    "company_slug": "tsr",
    "base_price": 4500,
    "duration_minutes": 330,
    "distance_km": 360,
    "badge": "Prix bas",
    "rating_average": "2.50"
  },
  {
    "line_id": "rahimo_ouaga_bobo",
    "line_code": "OUA-BOB-RAHIMO",
    "line_name": "Ouagadougou ↔ Bobo-Dioulasso",
    "company_name": "RAHIMO Transports",
    "base_price": 6500,
    "duration_minutes": 300,
    "badge": "Premium",
    "rating_average": "4.60"
  }
  // ... autres compagnies (STAF, RAKIETA, TCV, SARAMAYA)
]
```

### 5. Horaires d'une ligne spécifique

```bash
# Horaires RAHIMO Ouaga-Bobo
curl http://localhost:3000/api/lines/rahimo_ouaga_bobo/schedules

# Horaires SOTRACO L3
curl http://localhost:3000/api/lines/sotraco_l3/schedules

# Horaires SOTRACO L6B
curl http://localhost:3000/api/lines/sotraco_l6b/schedules
```

**Réponse RAHIMO attendue :**
```json
[
  {
    "id": "rahimo_ouaga_bobo_0730",
    "departure_time": "07:30:00",
    "arrival_time": "12:30:00",
    "days_of_week": ["LUNDI", "MARDI", "MERCREDI", "JEUDI", "VENDREDI", "SAMEDI", "DIMANCHE"],
    "total_seats": 70,
    "available_seats": 70,
    "vehicle_type": "Bus G8 Premium",
    "notes": "Service premium : AC garanti, TV, USB, collation"
  },
  {
    "id": "rahimo_ouaga_bobo_1000",
    "departure_time": "10:00:00",
    "arrival_time": "15:00:00",
    "days_of_week": ["LUNDI", "MARDI", "MERCREDI", "JEUDI", "VENDREDI", "SAMEDI", "DIMANCHE"],
    "total_seats": 70,
    "available_seats": 70
  }
  // ... autres horaires
]
```

### 6. Horaires disponibles pour une date spécifique

```bash
# Horaires disponibles lundi pour Ouaga-Bobo
curl "http://localhost:3000/api/lines/rahimo_ouaga_bobo/schedules?date=2026-02-24&day=LUNDI"

# Horaires disponibles dimanche pour L3 SOTRACO
curl "http://localhost:3000/api/lines/sotraco_l3/schedules?day=DIMANCHE"
```

### 7. Comparer les prix pour une destination

```bash
# Prix min/max/moyen vers Bobo-Dioulasso
curl "http://localhost:3000/api/lines/compare-prices?destination=Bobo-Dioulasso"
```

## 🧪 Tests avec Postman / Insomnia

### Collection de requêtes recommandées

1. **GET** `http://localhost:3000/api/companies`
   - Headers: `Accept: application/json`

2. **GET** `http://localhost:3000/api/companies/:slug`
   - Params: `slug = rahimo`

3. **GET** `http://localhost:3000/api/lines/search`
   - Query Params:
     - `origin = Ouagadougou`
     - `destination = Bobo-Dioulasso`
     - `date = 2026-02-24` (optionnel)

4. **GET** `http://localhost:3000/api/lines/:lineId/schedules`
   - Params: `lineId = rahimo_ouaga_bobo`
   - Query Params: `day = LUNDI` (optionnel)

5. **POST** `http://localhost:3000/api/bookings` (Réservation test)
   - Body (JSON):
     ```json
     {
       "line_id": "rahimo_ouaga_bobo",
       "schedule_id": "rahimo_ouaga_bobo_0730",
       "travel_date": "2026-03-01",
       "passenger_name": "Test User",
       "passenger_phone": "+22670123456",
       "num_passengers": 2,
       "total_price": 13000
     }
     ```

## 📊 Tests SQL Directs

Si vous souhaitez vérifier directement dans PostgreSQL :

```bash
# Se connecter à la base
psql -h localhost -U ankata_user -d ankata_db
```

### Requêtes de vérification

```sql
-- Compagnies actives
SELECT id, name, company_type, rating_average, badge, is_active 
FROM companies 
ORDER BY rating_average DESC;

-- Nombre de lignes par compagnie
SELECT 
  c.name,
  COUNT(l.id) as nb_lignes,
  c.is_active
FROM companies c
LEFT JOIN lines l ON c.id = l.company_id
GROUP BY c.id, c.name, c.is_active
ORDER BY nb_lignes DESC;

-- Top 5 destinations depuis Ouagadougou
SELECT 
  destination_city,
  COUNT(*) as nb_options,
  MIN(base_price) as prix_min,
  MAX(base_price) as prix_max,
  ROUND(AVG(base_price)) as prix_moyen
FROM lines
WHERE origin_city = 'Ouagadougou' 
  AND base_price IS NOT NULL
  AND is_active = true
GROUP BY destination_city
ORDER BY nb_options DESC
LIMIT 5;

-- Lignes les moins chères vers Bobo
SELECT 
  c.name as compagnie,
  l.base_price,
  l.duration_minutes/60.0 as duree_h,
  c.badge,
  c.rating_average
FROM lines l
JOIN companies c ON l.company_id = c.id
WHERE l.origin_city = 'Ouagadougou'
  AND l.destination_city = 'Bobo-Dioulasso'
  AND l.is_active = true
  AND c.is_active = true
ORDER BY l.base_price;

-- Horaires du matin (6h-12h) pour Ouaga-Bobo
SELECT 
  c.name as compagnie,
  l.line_code,
  s.departure_time,
  s.arrival_time,
  s.available_seats,
  l.base_price
FROM schedules s
JOIN lines l ON s.line_id = l.id
JOIN companies c ON l.company_id = c.id
WHERE l.origin_city = 'Ouagadougou'
  AND l.destination_city = 'Bobo-Dioulasso'
  AND s.departure_time >= '06:00:00'
  AND s.departure_time < '12:00:00'
  AND 'LUNDI' = ANY(s.days_of_week)
  AND s.is_active = true
ORDER BY s.departure_time;

-- Statistiques globales
SELECT 
  (SELECT COUNT(*) FROM companies WHERE is_active = true) as compagnies_actives,
  (SELECT COUNT(*) FROM lines WHERE is_active = true) as lignes_actives,
  (SELECT COUNT(*) FROM schedules WHERE is_active = true) as horaires_actifs,
  (SELECT COUNT(DISTINCT destination_city) FROM lines WHERE origin_city = 'Ouagadougou') as destinations_depuis_ouaga;
```

## ✅ Checklist de Vérification

Après l'initialisation, vérifiez que :

- [ ] **7 compagnies** sont présentes (6 actives, 1 suspendue)
- [ ] **60+ lignes** sont créées (18 SOTRACO + 40+ interurbaines/internationales)
- [ ] **100+ horaires** sont disponibles
- [ ] Prix **Ouaga-Bobo** varient de **4500 FCFA** (TSR) à **8000 FCFA** (RAHIMO VIP)
- [ ] Les **lignes SOTRACO** (L1-L19) existent
- [ ] Les **horaires détaillés L3 et L6B** sont présents
- [ ] Les **badges** sont corrects (Prix bas, Premium, Fiable, etc.)
- [ ] **STAF est suspendue** (`is_active = false`)
- [ ] Les **durées de trajet** sont cohérentes (5h pour Ouaga-Bobo)
- [ ] Les **destinations internationales** incluent Abidjan, Lomé, Bamako, Cotonou

## 🐛 Résolution de Problèmes

### Problème : "Cannot GET /api/companies"

**Solution :**
- Vérifier que le serveur backend est démarré : `npm run dev`
- Vérifier le port dans `.env` : `API_PORT=3000`
- Vérifier les routes dans `src/routes/companies.routes.js`

### Problème : Résultats vides []

**Solution :**
- Vérifier que les seeds ont été exécutés : `npm run db:seed`
- Vérifier les données en SQL :
  ```sql
  SELECT COUNT(*) FROM companies;
  SELECT COUNT(*) FROM lines;
  ```

### Problème : Erreur 500 Internal Server Error

**Solution :**
- Vérifier les logs du serveur (terminal où `npm run dev` tourne)
- Vérifier la connexion PostgreSQL dans `.env`
- Vérifier les modèles dans `src/models/`

## 📝 Notes Importantes

1. **Prix affichés en FCFA** (Franc CFA)
2. **Durées en minutes** dans la base, à convertir en heures pour l'affichage
3. **Horaires en format 24h** (ex: 07:30:00 = 7h30 du matin)
4. **Jours de la semaine en français majuscule** : LUNDI, MARDI, etc.
5. **STAF suspendue depuis 16/02/2026**, ne pas afficher aux utilisateurs
6. **Réservations nécessitent authentification** (JWT token)

## 🚀 Prochaines Étapes

Une fois les tests validés :

1. **Tester la réservation complète** avec paiement
2. **Tester l'authentification** OTP WhatsApp/SMS
3. **Tester les évaluations** après voyage
4. **Implémenter back-office** pour gestion horaires
5. **Ajouter arrêts détaillés SOTRACO** (329 arrêts)
6. **Intégrer API temps réel** des compagnies

---

**Support :** Pour toute question, consultez `DATABASE_README.md` ou contactez l'équipe technique.
