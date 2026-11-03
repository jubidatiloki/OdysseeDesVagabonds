import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:odyssee_vagabonds/models/classe.dart';
import 'package:odyssee_vagabonds/models/voie.dart';

/// Équilibrages des classes (03/11/2026) : dés de vie du moine et du
/// prêtre, profil du prêtre, CA unique du duelliste et d'« À couvert »,
/// déclencheur de la riposte du voleur.
void main() {
  final classes = {
    for (final e
        in jsonDecode(File('assets/data/classes.json').readAsStringSync())
            as List)
      (e as Map<String, dynamic>)['id']: Classe.depuisJson(e),
  };
  Competence comp(String classe, String nom) => classes[classe]!
      .voies
      .expand((v) => v.competences)
      .firstWhere((c) => c.nom == nom);

  test('moine : DV inchangé ; prêtre : DV diminué, lanceur de sorts', () {
    expect(classes['moine']!.modifDeVie, ModifDe.egal);
    expect(classes['pretre']!.modifDeVie, ModifDe.moins);
    expect(classes['pretre']!.profil, ProfilClasse.lanceur);
  });

  test('duelliste et À couvert : un seul bonus de CA', () {
    final duel = comp('chevalier', 'Duelliste')
        .effets
        .where((e) => e.typeNormalise == 'ca')
        .single;
    expect((duel.categorie, duel.valeur), ('', '3'));
    expect(duel.libelle, '+3 CA (en 1 contre 1)');
    for (final (rang, valeur) in [(2, '3'), (5, '5')]) {
      final etat = classes['guerrier']!
          .voies
          .firstWhere((v) => v.id == 'guerrier-bouclier')
          .competence(rang)!
          .etat!;
      final ca = etat.effets.where((e) => e.typeNormalise == 'ca').single;
      expect((ca.categorie, ca.valeur), ('', valeur), reason: 'rang $rang');
    }
  });

  test('riposte : après une attaque ratée contre le voleur', () {
    final r = comp('voleur', 'Riposte');
    expect(r.effet, startsWith('Après une attaque ratée contre le voleur'));
    expect(r.effet, isNot(contains('esquive')));
  });
}
