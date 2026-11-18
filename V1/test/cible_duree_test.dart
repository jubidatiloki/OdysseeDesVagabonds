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

  test('données : cibles et durées validées (19/11/2026)', () {
    // Toutes les compétences des classes, par nom (la première suffit).
    final parNom = <String, Competence>{};
    for (final classe
        in jsonDecode(File('assets/data/classes.json').readAsStringSync())
            as List) {
      for (final v in classe['voies'] as List) {
        for (final c in v['competences'] as List) {
          final k = Competence.depuisJson(c as Map<String, dynamic>);
          parNom.putIfAbsent(k.nom, () => k);
        }
      }
    }
    String texte(String nom) {
      final c = parNom[nom]!;
      return '${c.cible!.libelle} · ${c.duree!.texte}';
    }

    expect(texte('Rage berzerker (niveau 1)'), 'Soi-même · 1d4 + CON tours');
    expect(texte('Charme mineur (niveau 1)'), 'Une cible · INT × 10 minutes');
    expect(texte('Bénédiction'), 'Une cible · 1 jour');
    expect(
        texte('Écorces partagées'), 'Les alliés, sans le lanceur · INT tours');
    expect(texte("Mur d'air"), 'Les alliés (lanceur compris) · indéfinie');
    expect(parNom['Boule de feu']!.cible, CibleCompetence.selection);
    expect(parNom['Boule de feu']!.duree!.affichee, isFalse);
    // Passif : rien de renseigné.
    expect(parNom['Grandes poches']!.cible, isNull);
    // Sorts de rang 0 : dans leur objet « sort » ; une durée en heures.
    final sorts =
        jsonDecode(File('assets/data/sorts_rang0.json').readAsStringSync())
            as List;
    final lumiere = sorts.firstWhere((s) => s['nom'] == 'Lumière');
    final c = Competence.depuisJson({
      'rang': 0,
      'nom': 'Lumière',
      ...lumiere['sort'] as Map<String, dynamic>,
    });
    expect((c.cible, c.duree!.texte), (CibleCompetence.unique, '1 heure'));
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
