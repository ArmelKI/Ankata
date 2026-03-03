# Quick Start - Ankata

Ce guide sert à démarrer rapidement le projet en local.

## 1) Lancer le backend

```bash
cd /home/armelki/Documents/projets/Ankata/backend
cp .env.example .env
npm install
npm run db:migrate
npm run dev
```

Backend par défaut: `http://localhost:3000`

## 2) Lancer l'app mobile

```bash
cd /home/armelki/Documents/projets/Ankata/mobile
flutter pub get
flutter run
```

## 3) Vérifications rapides

- L'API répond sur `/health`
- L'app mobile arrive à afficher l'accueil
- La recherche de trajets charge des lignes depuis l'API

## 4) Documentation utile

- `README.md` : vue d'ensemble du monorepo
- `DEPLOYMENT_GUIDE.md` : déploiement backend/mobile
- `FIREBASE_SETUP_GUIDE.md` : configuration Firebase
- `PAIEMENT_SETUP_GUIDE.md` : configuration paiement

## Notes importantes

- Les logos compagnies restent dans `mobile/assets/images/companies`
- Le backend seed ne doit pas supprimer les données existantes en production
- Supabase est la source de vérité pour le schéma en production

