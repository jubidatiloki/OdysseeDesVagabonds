import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:odyssee_vagabonds/models/equipement.dart';
import 'package:odyssee_vagabonds/models/objet.dart';
import 'package:odyssee_vagabonds/regles/inventaire.dart';
import 'package:odyssee_vagabonds/screens/equipements_screen.dart';
import 'package:odyssee_vagabonds/screens/fiche/formulaire_objet.dart';
import 'package:odyssee_vagabonds/widgets/cadre_classe.dart';

void main() {
  testsInstruments();

  test('icône de chaque équipement du catalogue', () {
    final catalogue = {
      for (final e in jsonDecode(
        File('assets/data/equipements.json').readAsStringSync(),
      ) as List)
        (e as Map<String, dynamic>)['nom'] as String: Equipement.depuisJson(e),
    };
    MotifClasse? motif(String nom) =>
        motifEquipement(catalogue[nom]!.categorie, catalogue[nom]!.etiquettes);
    expect(motif('Épée longue'), MotifClasse.epee);
    expect(motif('Hache de guerre'), MotifClasse.epee);
    expect(motif('Arc court'), MotifClasse.arc);
    // Armes à poudre : pistolet (distinct de l'arc).
    expect(motif('Mousquet'), MotifClasse.pistolet);
    expect(motif('Pétoire'), MotifClasse.pistolet);
    expect(motif('Canon à mains'), MotifClasse.pistolet);
    final canon = catalogue['Canon à mains']!;
    expect(canon.categorie, CategorieEquipement.arme);
    expect(canon.etiquettes, containsAll(['Distance', 'poudre', 'deux mains']));
    expect(canon.proprietes, {
      'Dégâts': '3d10 phy',
      'Portée': '50m',
      'Prix': '50 pa',
    });
    expect(motif('Pioche'), MotifClasse.pioche);
    expect(motif('Corde 20m'), MotifClasse.pioche);
    expect(motif('Bikini de plaque'), MotifClasse.plastron);
    expect(motif('Bouclier en bois'), MotifClasse.bouclier);
    expect(motif('Casque de cuir'), MotifClasse.casque);
    expect(motif('Poison'), MotifClasse.potion);
    expect(motif('Parchemin de magie'), isNull);
    expect(
        motifEquipement(CategorieEquipement.arme, const []), MotifClasse.epee);
  });

  testWidgets('inventaire : motifs selon la catégorie de l\'objet',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Row(
          children: [
            iconeCategorieWidget(CategorieObjet.arme),
            iconeCategorieWidget(CategorieObjet.arme, distance: true),
            iconeCategorieWidget(CategorieObjet.arme,
                distance: true, armeAFeu: true),
            iconeCategorieWidget(CategorieObjet.armure),
            iconeCategorieWidget(CategorieObjet.consommable),
            iconeCategorieWidget(CategorieObjet.divers),
          ],
        ),
      ),
    );
    final motifs = [
      for (final w in tester.widgetList<IconeMotif>(find.byType(IconeMotif)))
        w.motif,
    ];
    expect(motifs, [
      MotifClasse.epee,
      MotifClasse.arc,
      MotifClasse.pistolet,
      MotifClasse.plastron,
      MotifClasse.potion,
    ]);
    expect(find.byIcon(Icons.inventory_2_outlined), findsOneWidget);
  });
}

void testsInstruments() {
  test('instruments du catalogue : 10 pc, instrument dans l\'inventaire', () {
    final catalogue = [
      for (final e in jsonDecode(
        File('assets/data/equipements.json').readAsStringSync(),
      ) as List)
        Equipement.depuisJson(e as Map<String, dynamic>),
    ];
    for (final nom in ['Lyre', 'Flûte', 'Oud', 'Banjo', 'Tambour']) {
      final e = catalogue.firstWhere((e) => e.nom == nom);
      expect(e.proprietes['Prix'], '10 pc', reason: nom);
      // Catégorie « Instruments » du Glossaire.
      expect(e.categorie, CategorieEquipement.instrument, reason: nom);
      expect(ObjetDuCatalogue.depuis(e).categorie, CategorieObjet.instrument,
          reason: nom);
    }
    // Catégorie « Autre » mais étiquette « instrument » : Instruments.
    expect(
      Equipement.depuisJson(const {
        'id': 'luth',
        'nom': 'Luth',
        'categorie': 'Autre',
        'sousCategorie': 'instrument, cordes',
      }).categorie,
      CategorieEquipement.instrument,
    );
  });
}
