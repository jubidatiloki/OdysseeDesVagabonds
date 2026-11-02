import 'package:flutter_test/flutter_test.dart';
import 'package:odyssee_vagabonds/models/historique.dart';
import 'package:odyssee_vagabonds/models/personnage.dart';
import 'package:odyssee_vagabonds/screens/fiche/onglet_historique.dart';

Personnage _perso() =>
    Personnage(id: 'p', nom: 'Brom', raceId: 'nain', classeId: 'guerrier');

void main() {
  final t0 = DateTime(2026, 10, 20, 14, 0);

  test('les clics rapprochés sur −1 / +1 sont regroupés', () {
    final p = _perso();
    for (final (avant, apres, s) in [(13, 12, 0), (12, 11, 5), (11, 10, 10)]) {
      p.journaliserValeur(
        cle: 'pv',
        libelle: 'PV',
        avant: avant,
        apres: apres,
        categorie: CategorieHistorique.vie,
        regrouper: true,
        maintenant: t0.add(Duration(seconds: s)),
      );
    }
    expect(p.historique, hasLength(1));
    expect(p.historique.single.message, 'PV : 13 → 10 (−3)');
  });

  test('revenir à la valeur de départ efface la ligne', () {
    final p = _perso();
    p.journaliserValeur(
      cle: 'pv',
      libelle: 'PV',
      avant: 13,
      apres: 12,
      categorie: CategorieHistorique.vie,
      regrouper: true,
      maintenant: t0,
    );
    p.journaliserValeur(
      cle: 'pv',
      libelle: 'PV',
      avant: 12,
      apres: 13,
      categorie: CategorieHistorique.vie,
      regrouper: true,
      maintenant: t0.add(const Duration(seconds: 3)),
    );
    expect(p.historique, isEmpty);
  });

  test('pas de regroupement après une minute ni sans « regrouper »', () {
    final p = _perso();
    p.journaliserValeur(
      cle: 'pv',
      libelle: 'PV',
      avant: 13,
      apres: 12,
      categorie: CategorieHistorique.vie,
      regrouper: true,
      maintenant: t0,
    );
    p.journaliserValeur(
      cle: 'pv',
      libelle: 'PV',
      avant: 12,
      apres: 11,
      categorie: CategorieHistorique.vie,
      regrouper: true,
      maintenant: t0.add(const Duration(minutes: 2)),
    );
    // Dégâts saisis : toujours une ligne à part
    p.journaliserValeur(
      cle: 'pv',
      libelle: 'PV',
      avant: 11,
      apres: 2,
      categorie: CategorieHistorique.vie,
      maintenant: t0.add(const Duration(minutes: 2, seconds: 5)),
    );
    expect(p.historique.map((e) => e.message), [
      'PV : 13 → 12 (−1)',
      'PV : 12 → 11 (−1)',
      'PV : 11 → 2 (−9)',
    ]);
  });

  test('une clé de fusion remplace la ligne précédente (notes)', () {
    final p = _perso();
    p.journaliser('Notes modifiées', fusion: 'notes', maintenant: t0);
    p.journaliser(
      'Notes modifiées',
      fusion: 'notes',
      maintenant: t0.add(const Duration(seconds: 20)),
    );
    expect(p.historique, hasLength(1));
    expect(p.historique.single.date, t0.add(const Duration(seconds: 20)));
  });

  test('l\'historique est limité aux 1000 dernières lignes', () {
    final p = _perso();
    for (var i = 0; i < Personnage.tailleMaxHistorique + 5; i++) {
      p.journaliser('Ligne $i', maintenant: t0);
    }
    expect(p.historique, hasLength(Personnage.tailleMaxHistorique));
    expect(p.historique.first.message, 'Ligne 5');
  });

  test('100 lancers de dés gardés au plus, les autres lignes restent', () {
    final p = _perso()
      ..journaliser('Objet ajouté : Corde',
          categorie: CategorieHistorique.inventaire, maintenant: t0);
    for (var i = 0; i < 105; i++) {
      p.journaliser('Lancer · $i',
          categorie: CategorieHistorique.des, maintenant: t0);
    }
    final lancers =
        p.historique.where((e) => e.categorie == CategorieHistorique.des);
    expect(lancers, hasLength(Personnage.maxLancersHistorique));
    expect(lancers.first.message, 'Lancer · 5');
    expect(lancers.last.message, 'Lancer · 104');
    // La ligne plus ancienne, d'une autre catégorie, est gardée.
    expect(p.historique.first.message, 'Objet ajouté : Corde');
    expect(p.historique, hasLength(101));
  });

  test('l\'historique survit à un aller-retour JSON', () {
    final p = _perso()
      ..journaliser(
        'Objet ajouté : Corde',
        categorie: CategorieHistorique.inventaire,
        maintenant: t0,
      );
    final copie = Personnage.depuisJson(p.versJson());
    expect(copie.historique, hasLength(1));
    final e = copie.historique.single;
    expect(e.message, 'Objet ajouté : Corde');
    expect(e.categorie, CategorieHistorique.inventaire);
    expect(e.date, t0);
  });

  test('format des dates', () {
    final maintenant = DateTime(2026, 10, 20, 9);
    expect(formaterJour(DateTime(2026, 10, 20, 8), maintenant: maintenant),
        'Aujourd\'hui');
    expect(formaterJour(DateTime(2026, 10, 19, 23), maintenant: maintenant),
        'Hier');
    expect(formaterJour(DateTime(2026, 10, 12), maintenant: maintenant),
        'lundi 12 octobre 2026');
    expect(formaterHeure(DateTime(2026, 1, 1, 7, 5)), '07:05');
  });
}
