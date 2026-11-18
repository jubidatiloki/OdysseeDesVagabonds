import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:odyssee_vagabonds/models/voie.dart';
import 'package:odyssee_vagabonds/widgets/voie_detail.dart';

void main() {
  test('cible, durée et bonus donné : lus depuis les données', () {
    final c = Competence.depuisJson({
      'rang': 2,
      'nom': 'Lien',
      'cible': 'unique',
      'duree': {'type': 'tours', 'valeur': 'INT'},
      'bonusDonne': {'valeur': -1, 'portee': 'carac', 'carac': 'FOR'},
    });
    expect(c.cible, CibleCompetence.unique);
    expect(c.duree!.texte, 'INT tours');
    expect((c.bonusDonne!.valeur, c.bonusDonne!.portee, c.bonusDonne!.carac),
        (-1, 'carac', 'FOR'));
    expect(c.bonusDonne!.siReussite, isTrue);
    // Sans durée : rien à afficher.
    expect(const DureeCompetence(type: TypeDuree.aucune).affichee, isFalse);
    expect(const DureeCompetence(type: TypeDuree.jours, valeur: '1').texte,
        '1 jour');
    expect(const DureeCompetence(type: TypeDuree.actions, valeur: '3').texte,
        '3 actions');
    // Copie (variantes, choix) : gardés.
    expect(c.pour().duree?.type, TypeDuree.tours);
    expect(c.copie(nom: 'X').cible, CibleCompetence.unique);
  });

  test('musique vivifiante : alliés, fin du combat, +2 aux attaques', () {
    final json =
        jsonDecode(File('assets/data/classes.json').readAsStringSync());
    Competence? musique;
    for (final classe in json as List) {
      for (final v in classe['voies'] as List) {
        for (final c in v['competences'] as List) {
          if (c['nom'] == 'Musique vivifiante') {
            musique = Competence.depuisJson(c as Map<String, dynamic>);
          }
        }
      }
    }
    expect(musique!.cible, CibleCompetence.alliesSansLanceur);
    expect(musique.duree!.type, TypeDuree.finCombat);
    expect((musique.bonusDonne!.valeur, musique.bonusDonne!.portee),
        (2, 'attaque'));
  });

  testWidgets('fiche d\'une compétence : cible et durée, sauf si aucune',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: Column(
          children: [
            LigneCompetence(
              competence: Competence(
                rang: 1,
                nom: 'Chant',
                cible: CibleCompetence.allies,
                duree: DureeCompetence(type: TypeDuree.finCombat),
              ),
            ),
            LigneCompetence(
              competence: Competence(
                rang: 1,
                nom: 'Moulinet',
                duree: DureeCompetence(type: TypeDuree.aucune),
              ),
            ),
          ],
        ),
      ),
    ));
    expect(
      tester.widget<Text>(find.byKey(const Key('cible-duree-Chant'))).data,
      'Cible : Les alliés (lanceur compris) · Durée : jusqu\'à la fin du combat',
    );
    expect(find.byKey(const Key('cible-duree-Moulinet')), findsNothing);
  });
}
