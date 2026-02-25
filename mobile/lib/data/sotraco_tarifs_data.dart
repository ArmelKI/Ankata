/// Tarifs SOTRACO par ville et catégorie
class SotracoTarif {
  final String ville;
  final String categorie;
  final String typeTarif;
  final String montant;

  const SotracoTarif({
    required this.ville,
    required this.categorie,
    required this.typeTarif,
    required this.montant,
  });
}

class SotracoTarifsData {
  static const List<SotracoTarif> tarifs = [
    // ── Ouagadougou ──
    SotracoTarif(
        ville: 'Ouagadougou',
        categorie: 'Élèves & Étudiants',
        typeTarif: 'Ticket à la course',
        montant: '200 F CFA'),
    SotracoTarif(
        ville: 'Ouagadougou',
        categorie: 'Élèves & Étudiants',
        typeTarif: 'Abonnement hebdomadaire',
        montant: '1 000 F CFA'),
    SotracoTarif(
        ville: 'Ouagadougou',
        categorie: 'Élèves & Étudiants',
        typeTarif: 'Abonnement mensuel',
        montant: '3 000 F CFA'),
    SotracoTarif(
        ville: 'Ouagadougou',
        categorie: 'Élèves & Étudiants',
        typeTarif: 'Abonnement annuel',
        montant: '35 000 F CFA'),
    SotracoTarif(
        ville: 'Ouagadougou',
        categorie: 'Autres usagers',
        typeTarif: 'Ticket à la course',
        montant: '200 F CFA'),
    SotracoTarif(
        ville: 'Ouagadougou',
        categorie: 'Autres usagers',
        typeTarif: 'Abonnement hebdomadaire',
        montant: '2 500 F CFA'),
    SotracoTarif(
        ville: 'Ouagadougou',
        categorie: 'Autres usagers',
        typeTarif: 'Abonnement mensuel',
        montant: '7 000 F CFA'),
    SotracoTarif(
        ville: 'Ouagadougou',
        categorie: 'Autres usagers',
        typeTarif: 'Abonnement trimestriel',
        montant: '20 000 F CFA'),
    SotracoTarif(
        ville: 'Ouagadougou',
        categorie: 'Lignes intercommunales',
        typeTarif: 'Ouaga → Koubri',
        montant: '400 F CFA'),
    SotracoTarif(
        ville: 'Ouagadougou',
        categorie: 'Lignes intercommunales',
        typeTarif: 'Ouaga → Kouba',
        montant: '200 F CFA'),
    SotracoTarif(
        ville: 'Ouagadougou',
        categorie: 'Lignes intercommunales',
        typeTarif: 'Kouba → Koubri',
        montant: '200 F CFA'),
    SotracoTarif(
        ville: 'Ouagadougou',
        categorie: 'Lignes intercommunales',
        typeTarif: 'Ouaga → Ziniaré',
        montant: '700 F CFA'),
    SotracoTarif(
        ville: 'Ouagadougou',
        categorie: 'Lignes intercommunales',
        typeTarif: 'Ouaga → Nomgana',
        montant: '400 F CFA'),
    SotracoTarif(
        ville: 'Ouagadougou',
        categorie: 'Lignes intercommunales',
        typeTarif: 'Nomgana → Ziniaré',
        montant: '300 F CFA'),
    SotracoTarif(
        ville: 'Ouagadougou',
        categorie: 'Lignes intercommunales',
        typeTarif: 'Ouaga → Pabré',
        montant: '500 F CFA'),
    SotracoTarif(
        ville: 'Ouagadougou',
        categorie: 'Lignes intercommunales',
        typeTarif: 'Abonnement mensuel Ziniaré',
        montant: '15 000 F CFA'),
    SotracoTarif(
        ville: 'Ouagadougou',
        categorie: 'Lignes intercommunales',
        typeTarif: 'Abonnement mensuel Koubri',
        montant: '10 000 F CFA'),
    SotracoTarif(
        ville: 'Ouagadougou',
        categorie: 'Lignes intercommunales',
        typeTarif: 'Abonnement mensuel Pabré',
        montant: '12 000 F CFA'),
    // ── Bobo-Dioulasso ──
    SotracoTarif(
        ville: 'Bobo-Dioulasso',
        categorie: 'Élèves & Étudiants',
        typeTarif: 'Ticket à la course',
        montant: '150 F CFA'),
    SotracoTarif(
        ville: 'Bobo-Dioulasso',
        categorie: 'Élèves & Étudiants',
        typeTarif: 'Abonnement hebdomadaire',
        montant: '1 000 F CFA'),
    SotracoTarif(
        ville: 'Bobo-Dioulasso',
        categorie: 'Élèves & Étudiants',
        typeTarif: 'Abonnement mensuel',
        montant: '3 000 F CFA'),
    SotracoTarif(
        ville: 'Bobo-Dioulasso',
        categorie: 'Élèves & Étudiants',
        typeTarif: 'Abonnement annuel',
        montant: '35 000 F CFA'),
    SotracoTarif(
        ville: 'Bobo-Dioulasso',
        categorie: 'Autres usagers',
        typeTarif: 'Ticket à la course',
        montant: '150 F CFA'),
    SotracoTarif(
        ville: 'Bobo-Dioulasso',
        categorie: 'Autres usagers',
        typeTarif: 'Abonnement hebdomadaire',
        montant: '2 000 F CFA'),
    SotracoTarif(
        ville: 'Bobo-Dioulasso',
        categorie: 'Autres usagers',
        typeTarif: 'Abonnement mensuel',
        montant: '6 000 F CFA'),
    SotracoTarif(
        ville: 'Bobo-Dioulasso',
        categorie: 'Autres usagers',
        typeTarif: 'Abonnement trimestriel',
        montant: '16 000 F CFA'),
    SotracoTarif(
        ville: 'Bobo-Dioulasso',
        categorie: 'Lignes intercommunales',
        typeTarif: 'Bobo → Banakélédaga',
        montant: '250 F CFA'),
    SotracoTarif(
        ville: 'Bobo-Dioulasso',
        categorie: 'Lignes intercommunales',
        typeTarif: 'Banakélédaga → Bama',
        montant: '250 F CFA'),
    SotracoTarif(
        ville: 'Bobo-Dioulasso',
        categorie: 'Lignes intercommunales',
        typeTarif: 'Bobo → Bama',
        montant: '500 F CFA'),
    SotracoTarif(
        ville: 'Bobo-Dioulasso',
        categorie: 'Lignes intercommunales',
        typeTarif: 'Abonnement mensuel Bama',
        montant: '13 000 F CFA'),
    // ── Koudougou ──
    SotracoTarif(
        ville: 'Koudougou',
        categorie: 'Élèves & Étudiants',
        typeTarif: 'Ticket à la course',
        montant: '150 F CFA'),
    SotracoTarif(
        ville: 'Koudougou',
        categorie: 'Élèves & Étudiants',
        typeTarif: 'Abonnement hebdomadaire',
        montant: '1 000 F CFA'),
    SotracoTarif(
        ville: 'Koudougou',
        categorie: 'Élèves & Étudiants',
        typeTarif: 'Abonnement mensuel',
        montant: '3 000 F CFA'),
    SotracoTarif(
        ville: 'Koudougou',
        categorie: 'Élèves & Étudiants',
        typeTarif: 'Abonnement annuel',
        montant: '35 000 F CFA'),
    SotracoTarif(
        ville: 'Koudougou',
        categorie: 'Autres usagers',
        typeTarif: 'Ticket à la course',
        montant: '150 F CFA'),
    SotracoTarif(
        ville: 'Koudougou',
        categorie: 'Autres usagers',
        typeTarif: 'Abonnement hebdomadaire',
        montant: '1 500 F CFA'),
    SotracoTarif(
        ville: 'Koudougou',
        categorie: 'Autres usagers',
        typeTarif: 'Abonnement mensuel',
        montant: '5 000 F CFA'),
    SotracoTarif(
        ville: 'Koudougou',
        categorie: 'Autres usagers',
        typeTarif: 'Abonnement trimestriel',
        montant: '13 000 F CFA'),
    SotracoTarif(
        ville: 'Koudougou',
        categorie: 'Lignes intercommunales',
        typeTarif: 'Koudougou → Réo',
        montant: '200 F CFA'),
    SotracoTarif(
        ville: 'Koudougou',
        categorie: 'Lignes intercommunales',
        typeTarif: 'Koudougou → Sabou',
        montant: '500 F CFA'),
    SotracoTarif(
        ville: 'Koudougou',
        categorie: 'Lignes intercommunales',
        typeTarif: 'Koudougou → Tenado',
        montant: '500 F CFA'),
    SotracoTarif(
        ville: 'Koudougou',
        categorie: 'Lignes intercommunales',
        typeTarif: 'Koudougou → Ramongo',
        montant: '200 F CFA'),
    SotracoTarif(
        ville: 'Koudougou',
        categorie: 'Lignes intercommunales',
        typeTarif: 'Koudougou → Tiguindela',
        montant: '250 F CFA'),
    SotracoTarif(
        ville: 'Koudougou',
        categorie: 'Lignes intercommunales',
        typeTarif: 'Koudougou → Poa',
        montant: '500 F CFA'),
    SotracoTarif(
        ville: 'Koudougou',
        categorie: 'Lignes intercommunales',
        typeTarif: 'Abonnement mensuel Réo',
        montant: '12 000 F CFA'),
    SotracoTarif(
        ville: 'Koudougou',
        categorie: 'Lignes intercommunales',
        typeTarif: 'Abonnement mensuel Sabou',
        montant: '12 000 F CFA'),
    SotracoTarif(
        ville: 'Koudougou',
        categorie: 'Lignes intercommunales',
        typeTarif: 'Abonnement mensuel Tenado',
        montant: '12 000 F CFA'),
    // ── Ouahigouya ──
    SotracoTarif(
        ville: 'Ouahigouya',
        categorie: 'Élèves & Étudiants',
        typeTarif: 'Ticket à la course',
        montant: '150 F CFA'),
    SotracoTarif(
        ville: 'Ouahigouya',
        categorie: 'Élèves & Étudiants',
        typeTarif: 'Abonnement hebdomadaire',
        montant: '1 000 F CFA'),
    SotracoTarif(
        ville: 'Ouahigouya',
        categorie: 'Élèves & Étudiants',
        typeTarif: 'Abonnement mensuel',
        montant: '3 000 F CFA'),
    SotracoTarif(
        ville: 'Ouahigouya',
        categorie: 'Élèves & Étudiants',
        typeTarif: 'Abonnement annuel',
        montant: '35 000 F CFA'),
    SotracoTarif(
        ville: 'Ouahigouya',
        categorie: 'Autres usagers',
        typeTarif: 'Ticket à la course',
        montant: '150 F CFA'),
    SotracoTarif(
        ville: 'Ouahigouya',
        categorie: 'Autres usagers',
        typeTarif: 'Abonnement hebdomadaire',
        montant: '1 500 F CFA'),
    SotracoTarif(
        ville: 'Ouahigouya',
        categorie: 'Autres usagers',
        typeTarif: 'Abonnement mensuel',
        montant: '5 000 F CFA'),
    SotracoTarif(
        ville: 'Ouahigouya',
        categorie: 'Autres usagers',
        typeTarif: 'Abonnement trimestriel',
        montant: '13 000 F CFA'),
    // ── Dédougou ──
    SotracoTarif(
        ville: 'Dédougou',
        categorie: 'Élèves & Étudiants',
        typeTarif: 'Ticket à la course',
        montant: '150 F CFA'),
    SotracoTarif(
        ville: 'Dédougou',
        categorie: 'Élèves & Étudiants',
        typeTarif: 'Abonnement hebdomadaire',
        montant: '1 000 F CFA'),
    SotracoTarif(
        ville: 'Dédougou',
        categorie: 'Élèves & Étudiants',
        typeTarif: 'Abonnement mensuel',
        montant: '3 000 F CFA'),
    SotracoTarif(
        ville: 'Dédougou',
        categorie: 'Élèves & Étudiants',
        typeTarif: 'Abonnement annuel',
        montant: '35 000 F CFA'),
    SotracoTarif(
        ville: 'Dédougou',
        categorie: 'Autres usagers',
        typeTarif: 'Ticket à la course',
        montant: '150 F CFA'),
    SotracoTarif(
        ville: 'Dédougou',
        categorie: 'Autres usagers',
        typeTarif: 'Abonnement hebdomadaire',
        montant: '1 500 F CFA'),
    SotracoTarif(
        ville: 'Dédougou',
        categorie: 'Autres usagers',
        typeTarif: 'Abonnement mensuel',
        montant: '5 000 F CFA'),
    SotracoTarif(
        ville: 'Dédougou',
        categorie: 'Autres usagers',
        typeTarif: 'Abonnement trimestriel',
        montant: '13 000 F CFA'),
    // ── Banfora ──
    SotracoTarif(
        ville: 'Banfora',
        categorie: 'Élèves & Étudiants',
        typeTarif: 'Ticket à la course',
        montant: '150 F CFA'),
    SotracoTarif(
        ville: 'Banfora',
        categorie: 'Élèves & Étudiants',
        typeTarif: 'Abonnement hebdomadaire',
        montant: '1 000 F CFA'),
    SotracoTarif(
        ville: 'Banfora',
        categorie: 'Élèves & Étudiants',
        typeTarif: 'Abonnement mensuel',
        montant: '3 000 F CFA'),
    SotracoTarif(
        ville: 'Banfora',
        categorie: 'Élèves & Étudiants',
        typeTarif: 'Abonnement annuel',
        montant: '35 000 F CFA'),
    SotracoTarif(
        ville: 'Banfora',
        categorie: 'Autres usagers',
        typeTarif: 'Ticket à la course',
        montant: '150 F CFA'),
    SotracoTarif(
        ville: 'Banfora',
        categorie: 'Autres usagers',
        typeTarif: 'Abonnement hebdomadaire',
        montant: '1 500 F CFA'),
    SotracoTarif(
        ville: 'Banfora',
        categorie: 'Autres usagers',
        typeTarif: 'Abonnement mensuel',
        montant: '5 000 F CFA'),
    SotracoTarif(
        ville: 'Banfora',
        categorie: 'Autres usagers',
        typeTarif: 'Abonnement trimestriel',
        montant: '13 000 F CFA'),
  ];

  /// Horaires de service généraux
  static const Map<String, String> serviceHours = {
    'Lundi - Vendredi': '05:45 - 20:30',
    'Samedi': '07:00 - 19:45',
    'Dimanche et jours fériés': '07:00 - 19:45',
  };

  static List<SotracoTarif> getTarifsByCity(String city) {
    return tarifs.where((t) => t.ville == city).toList();
  }

  static List<SotracoTarif> getTarifsByCategory(String city, String category) {
    return tarifs
        .where((t) => t.ville == city && t.categorie == category)
        .toList();
  }

  static List<String> getCategories(String city) {
    return tarifs
        .where((t) => t.ville == city)
        .map((t) => t.categorie)
        .toSet()
        .toList();
  }
}
