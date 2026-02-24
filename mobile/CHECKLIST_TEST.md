# ✅ CHECKLIST - Teste Maintenant !

## 1️⃣ Lance l'app (2 min)

```bash
cd /home/armelki/Documents/projets/Ankata/mobile
flutter run
```

Attends que l'app se lance...

---

## 2️⃣ Page Accueil - Vérifie ces éléments

- [ ] **Banner sponsor** visible en haut de page (dégradé vert)
- [ ] Texte : "Promotion spéciale - Économise 20%..."
- [ ] Badge "-20%" visible sur la droite
- [ ] **Bouton "Rechercher un voyage"** a une icône 🚌
- [ ] Quand tu cliques sur le bouton → **ça vibre** ?

**✅ SI OUI → Passe à l'étape 3**  
**❌ SI NON → Lis CHANGEMENTS_VISUELS.md**

---

## 3️⃣ Page Profil - Vérifie ces éléments

Navigue vers **Profil** (icône personne en bas)

### Header
- [ ] **Avatar** affiche "A K" (ou tes initiales)
- [ ] Avatar a un cercle bleu avec bordure
- [ ] Nom : "Armel Kiendrebeogo" visible
- [ ] Téléphone : "+226 70 12 34 56" visible

### Gamification (Nouveau!)
- [ ] **Widget Streak** 🔥 affiché
- [ ] Texte : "Série : X jours" visible
- [ ] **Barre XP** affichée
- [ ] Texte : "Niveau X" avec barre de progression
- [ ] Bouton "Modifier le profil" existe

### Section Badges (Nouveau!)
- [ ] Titre **"🏆 Mes badges"** visible
- [ ] Message "Aucun badge débloqué..." affiché (normal au début)
- [ ] Ou bien : 6 icônes de badges max affichées

### Section Premium & Referral (Nouveau!)
- [ ] **Bouton "Passer à Premium"** existe
- [ ] Badge rouge **"NOUVEAU"** visible sur le bouton
- [ ] **Bouton "Parrainer un ami"** existe
- [ ] Badge vert **"+1000F"** visible sur le bouton

**✅ SI TOUT EST OK → Passe à l'étape 4**  
**❌ SI MANQUE → Lis INTEGRATION_STATUS.md**

---

## 4️⃣ Teste les Dialogues

### Premium Dialog
1. Clique sur **"Passer à Premium"**
2. Vérifie :
   - [ ] Dialogue s'ouvre avec animation
   - [ ] Titre "👑 PREMIUM" visible
   - [ ] Liste des avantages (5 items avec ✓)
   - [ ] Prix **"2000 F / mois"** visible
   - [ ] 2 boutons : "S'abonner" et "Plus tard"
3. Clique sur **"Plus tard"** → dialogue se ferme

### Referral Dialog  
1. Clique sur **"Parrainer un ami"**
2. Vérifie :
   - [ ] Dialogue s'ouvre avec animation
   - [ ] Titre "🎁 PARRAINAGE" visible
   - [ ] Code **"USER123"** visible
   - [ ] Bouton **"📋 Copier"** existe
   - [ ] Texte "Ton ami gagne 1000 F, Tu gagnes 1000 F"
   - [ ] Bouton **"💬 Partager via WhatsApp"** existe
3. Clique sur **"Copier"** → Message "Code copié!" apparaît
4. Clique sur **"Fermer"** → dialogue se ferme

**✅ SI TOUT FONCTIONNE → BRAVO ! Tout est bon !**  
**❌ SI PROBLÈME → Lis INTEGRATION_STATUS.md section "Troubleshooting"**

---

## 5️⃣ Tests Avancés (Optionnel)

### Haptic Feedback
Vérifie que ces actions **vibrent légèrement** :
- [ ] Clic sur "Rechercher un voyage" (accueil)
- [ ] Clic sur "Modifier le profil" (profil)
- [ ] Clic sur "Passer à Premium" (profil)
- [ ] Clic sur "Parrainer un ami" (profil)

### Banner Animation
Sur la page d'accueil :
- [ ] Le banner reste 5 secondes puis slide vers la gauche
- [ ] Si plusieurs sponsors → rotation automatique

### Persistence (Vérifie le lendemain)
Le lendemain, relance l'app et vérifie :
- [ ] Widget Streak affiche "+1 jour" (si tu ouvres tous les jours)
- [ ] XP reste le même (persisté dans SharedPreferences)

---

## 🐛 Problèmes Courants

### Le banner sponsor ne s'affiche pas
➜ Normal si `home_screen.dart` non sauvegardé. Hot reload avec `r` dans le terminal.

### Les dialogues ne s'ouvrent pas
➜ Vérifie les imports dans `profile_screen.dart` (PremiumDialog, ReferralDialog).

### L'app crash au démarrage
➜ Run `flutter pub get` puis relance.

### Compilation errors
➜ Run `flutter analyze` pour voir les erreurs. Normalement = 0 erreur.

---

## 📞 Si Tout Va Bien

**FÉLICITATIONS ! 🎉**

Tu as maintenant :
- ✅ Banner publicitaire fonctionnel (monétisation)
- ✅ Gamification complète (streaks, XP, badges)
- ✅ Système Premium opérationnel
- ✅ Système de Parrainage prêt
- ✅ Animations et haptic feedback
- ✅ Architecture scalable

**Prochaine étape :** Suis le guide [INTEGRATION_COMPLETE.md](INTEGRATION_COMPLETE.md) pour intégrer les autres écrans (6h de travail).

---

## 📞 Si Quelque Chose Ne Va Pas

1. **Lis README_SESSION4.md** (résumé express)
2. **Lis INTEGRATION_STATUS.md** (état détaillé)
3. **Lis CHANGEMENTS_VISUELS.md** (ce qui devrait être visible)
4. **Run `./test_quick.sh`** pour vérifier la compilation
5. **Check les logs** dans le terminal Flutter

Tous les fichiers sont dans `/mobile/` avec documentation complète.

---

## 🚀 Commandes Utiles

```bash
# Test rapide compilation
./test_quick.sh

# Voir rapport de session
./rapport_session.sh

# Lancer l'app
flutter run

# Hot reload (après changement)
r (dans le terminal)

# Recompilation complète
R (dans le terminal)

# Arrêter l'app
q (dans le terminal)

# Vérifier erreurs
flutter analyze

# Clean & rebuild
flutter clean && flutter pub get && flutter run
```

---

**Prêt ? Lance `flutter run` et coche les cases !** ✅
