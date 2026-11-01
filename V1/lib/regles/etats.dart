import '../models/historique.dart';
import '../models/voie.dart';
import 'fiche_calculee.dart';

/// Active ou annule un état (réutiliser la compétence annule l'apparence) ;
/// [actif] force l'un ou l'autre. Un seul état actif par groupe (postures
/// du guerrier, formes du druide). Noté dans l'historique ; renvoie le
/// nouvel état.
bool basculerEtat(
  FicheCalculee f,
  EtatCompetence etat,
  String competence, {
  bool? actif,
}) {
  final p = f.personnage;
  final oui = actif ?? !p.etats.contains(etat.nom);
  if (oui == p.etats.contains(etat.nom)) return oui;
  if (oui) {
    p.etats.add(etat.nom);
    if (etat.groupe.isNotEmpty) {
      for (final e in [...f.etatsPossibles, ...f.etatsRecus]) {
        if (e.etat.groupe == etat.groupe && e.etat.nom != etat.nom) {
          p.etats.remove(e.etat.nom);
        }
      }
    }
  } else {
    p.etats.remove(etat.nom);
  }
  p.journaliser(
    '$competence : ${etat.nom} ${oui ? 'activée' : 'annulée'}',
    categorie: CategorieHistorique.competences,
  );
  return oui;
}
