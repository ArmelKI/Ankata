# 📸 Guide des Images H\u00e9ro pour la Page d'Accueil

## 🎯 Nombre d'Images Requises
**3 images** rotatives dans le carousel en haut de la page d'accueil (Hero Section).

## 📐 Sp\u00e9cifications Techniques

### Dimensions Recommand\u00e9es
- **Largeur**: 1200px
- **Hauteur**: 600px  
- **Ratio**: 2:1 (paysage)
- **Format**: JPG ou PNG
- **Taille**: < 500KB par image (optimis\u00e9es pour le web/mobile)

## 🖼️ Images Sugg\u00e9r\u00e9es

### Image 1: Bus Moderne 🚌
**Nom du fichier**: `hero_bus_moderne.jpg`

**Description**: Un bus de transport moderne et confortable, propre, sur une belle route au Burkina Faso
- Montrer un bus TSR, RAKIETA ou autre compagnie locale
- \u00c9viter les images de bus \u00e9trangers qui ne repr\u00e9sentent pas le service local
- Id\u00e9al: bus climatise, moderne, en bon \u00e9tat
- Ambiance: professionnelle, rassurante

**O\u00f9 trouver**:
- Photos des compagnies (TSR, RAKIETA, etc.) avec autorisation
- Banques d'images gratuites: Unsplash, Pexels (chercher "modern bus africa")
- Photographe local au Burkina Faso

### Image 2: Famille en Voyage 👨‍👩‍👧‍👦
**Nom du fichier**: `hero_famille_voyage.jpg`

**Description**: Famille ou groupe d'amis heureux voyageant ensemble
- Personnes souriantes, d\u00e9tendues
- Contexte: dans un bus, \u00e0 une gare, ou pr\u00eat \u00e0 voyager
- Diversit\u00e9: repr\u00e9senter la population burkinab\u00e9
- Ambiance: chaleur humaine, convivialit\u00e9

**O\u00f9 trouver**:
- Pexels, Unsplash (chercher "african family travel", "family bus")
- Photos authentiques de clients (avec autorisation)
- Session photo professionnelle locale

### Image 3: Destination Burkina 🌍
**Nom du fichier**: `hero_destination_burkina.jpg`

**Description**: Belle destination ou paysage du Burkina Faso
- Ouagadougou (Place des Cin\u00e9astes, monuments)
- Bobo-Dioulasso (Grande Mosqu\u00e9e, architecture)
- Paysages naturels (Pics de Sindou, Cascades de Banfora)
- Ambiance: attractive, inspirante, authentique

**O\u00f9 trouver**:
- Office du Tourisme du Burkina Faso
- Photographes locaux
- Wikimedia Commons (v\u00e9rifier les licences)
- Unsplash (chercher "Burkina Faso", "Ouagadougou", "Bobo-Dioulasso")

## 📁 Emplacement des Fichiers

Les images doivent \u00eatre plac\u00e9es dans:
```
mobile/assets/images/
\u251c\u2500\u2500 hero_bus_moderne.jpg
\u251c\u2500\u2500 hero_famille_voyage.jpg
\u2514\u2500\u2500 hero_destination_burkina.jpg
```

## \u2699\ufe0f Int\u00e9gration dans le Code

Le carousel est d\u00e9j\u00e0 configur\u00e9 dans `/mobile/lib/screens/home/home_screen.dart`.

Apr\u00e8s avoir ajout\u00e9 les images, mettez \u00e0 jour `pubspec.yaml`:

```yaml
flutter:
  assets:
    - assets/images/hero_bus_moderne.jpg
    - assets/images/hero_famille_voyage.jpg
    - assets/images/hero_destination_burkina.jpg
```

## ✅ Checklist

Avant de finaliser:
- [ ] Les 3 images ont les bonnes dimensions (1200x600px)
- [ ] Les images sont optimis\u00e9es (< 500KB chacune)
- [ ] Les images repr\u00e9sentent le contexte burkinab\u00e9
- [ ] Vous avez les droits d'utilisation des images
- [ ] Les fichiers sont dans `assets/images/`
- [ ] `pubspec.yaml` est mis \u00e0 jour

## 🎨 Conseils de Design

### Texte Overlay
Le carousel affiche du texte par-dessus les images. Assurez-vous que:
- Les images ont des zones sombres ou claires assez uniformes pour le texte
- Le contraste est suffisant pour lire le texte blanc facilement
- Les \u00e9l\u00e9ments importants de l'image ne sont pas cach\u00e9s par le texte

### Optimisation
Utilisez des outils comme:
- **TinyPNG** (https://tinypng.com) - compression sans perte de qualit\u00e9
- **Squoosh** (https://squoosh.app) - optimisation avanc\u00e9e
- **ImageOptim** (Mac) - optimisation locale

### Exemples de Recherche

**Sites gratuits**:
- Unsplash: https://unsplash.com
- Pexels: https://pexels.com  
- Pixabay: https://pixabay.com

**Mots-cl\u00e9s de recherche**:
- "modern bus africa"
- "family traveling bus"
- "african transportation"
- "burkina faso landscape"
- "west africa travel"
- "bus station africa"

## 📞 Support

Pour toute question sur les images, contactez:
- \u00c9quipe design Ankata
- support@ankata.bf

---

**Derni\u00e8re mise \u00e0 jour**: 24 f\u00e9vrier 2026
