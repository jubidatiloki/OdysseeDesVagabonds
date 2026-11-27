import '../models/voie.dart';

/// Réactions déclenchées par une attaque ratée (27/11/2026) : noms des
/// compétences dont le déclencheur est rempli. Une compétence « pour » une
/// autre remplace son déclencheur (Vétéran : Contre-attaque sur toute
/// attaque ratée au contact).
List<String> reactionsDeclenchees(
  Iterable<Competence> competences, {
  required bool contact,
  int? ecart,
}) {
  final declencheurs = <String, DeclencheurReaction>{};
  final liste = competences.toList();
  for (final c in liste) {
    final d = c.declencheur;
    if (d != null && d.pour.isEmpty) declencheurs[c.nom] = d;
  }
  for (final c in liste) {
    final d = c.declencheur;
    if (d != null && d.pour.isNotEmpty && declencheurs.containsKey(d.pour)) {
      declencheurs[d.pour] = d;
    }
  }
  return [
    for (final e in declencheurs.entries)
      if (e.value.declenche(contactAttaque: contact, ecart: ecart)) e.key,
  ];
}
