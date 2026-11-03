import 'package:flutter/material.dart';

import '../../models/campagne.dart';
import '../../models/creature.dart';
import '../../models/seance.dart';
import '../../state/seance_controller.dart';
import '../../theme.dart';
import '../../widgets/consultation.dart';
import '../../widgets/profil_classe.dart';
import '../bestiaire_screen.dart';
import '../fiche/vues_fiche.dart';
import 'campagnes_screen.dart';
import 'fiche_partagee_screen.dart';

/// Portion de gauche : script (MJ) ou notes de séance (PJ), personnages,
/// créatures. [onChoisie] : téléphone, passe à la vue Détail.
class ListeCartes extends StatelessWidget {
  const ListeCartes({super.key, required this.seance, this.onChoisie});

  final SeanceController seance;
  final VoidCallback? onChoisie;

  void _choisir(String id) {
    seance.choisirCarte(id);
    onChoisie?.call();
  }

  @override
  Widget build(BuildContext context) {
    final s = seance;
    return ListView(
      key: const Key('liste-cartes'),
      padding: const EdgeInsets.all(8),
      children: [
        if (s.estMj)
          _Carte(
            cle: 'carte-script',
            selectionnee: s.carte == kCarteScript,
            icone: Icons.history_edu_outlined,
            titre: 'Script',
            onTap: () => _choisir(kCarteScript),
          )
        else
          _Carte(
            cle: 'carte-notes',
            selectionnee: s.carte == kCarteNotes,
            icone: Icons.edit_note,
            titre: 'Mes notes de séance',
            onTap: () => _choisir(kCarteNotes),
          ),
        for (final m in s.joueurs)
          _Carte(
            cle: 'carte-${m.uid}',
            selectionnee: s.carte == m.uid,
            actif: s.etat.actif == m.uid,
            icone: Icons.person_outline,
            titre: m.personnageNom,
            lignes: [m.personnageResume],
            initiative: s.etat.enCombat ? m.initiative : null,
            ressources: [
              if (s.ressources[m.uid] case final r?) ...[
                _Ressource.vie(context, r.pv, r.pvMax),
                if (r.pmMax > 0) _Ressource.mana(context, r.pm, r.pmMax),
                if (r.peMax > 0) _Ressource.endurance(context, r.pe, r.peMax),
              ],
            ],
            onTap: () => _choisir(m.uid),
          ),
        for (final c in s.creatures)
          _Carte(
            cle: 'carte-${c.id}',
            selectionnee: s.carte == c.id,
            actif: s.etat.actif == c.id,
            icone: Icons.pets_outlined,
            titre: c.nom,
            initiative: s.etat.enCombat ? c.initiative : null,
            ressources: [
              if (c.pv != null)
                _Ressource.vie(context, c.pv!, c.pvMax ?? c.pv!),
            ],
            lignes: [
              if (c.pv == null) c.etat.libelle,
              if (s.estMj && c.cachee)
                'Carte cachée aux PJ'
              else if (s.estMj && c.nomCache)
                'Nom caché aux PJ',
            ],
            onTap: () => _choisir(c.id),
            // Petite croix rouge : retirer la créature de la partie.
            onRetirer: s.estMj
                ? () async {
                    final erreur = await s.retirerCreature(c);
                    if (erreur != null && context.mounted) {
                      ScaffoldMessenger.of(context)
                          .showSnackBar(SnackBar(content: Text(erreur)));
                    }
                  }
                : null,
            cleRetirer: 'retirer-${c.id}',
          ),
      ],
    );
  }
}

class _Carte extends StatelessWidget {
  const _Carte({
    required this.cle,
    required this.selectionnee,
    required this.icone,
    required this.titre,
    required this.onTap,
    this.lignes = const [],
    this.ressources = const [],
    this.initiative,
    this.actif = false,
    this.onRetirer,
    this.cleRetirer,
  });

  final String cle;
  final bool selectionnee;
  final IconData icone;
  final String titre;
  final List<String> lignes;

  /// PV, PM, PE avec leurs icônes et couleurs.
  final List<Widget> ressources;

  /// Initiative, affichée en combat.
  final int? initiative;
  final VoidCallback onTap;

  /// C'est son tour.
  final bool actif;
  final VoidCallback? onRetirer;
  final String? cleRetirer;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Card(
      margin: const EdgeInsets.only(bottom: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: selectionnee
              ? scheme.primary
              : actif
                  ? OdvCouleurs.or
                  : Colors.transparent,
          width: 2,
        ),
      ),
      child: InkWell(
        key: Key(cle),
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 8, 4, 8),
          child: Row(
            children: [
              Icon(icone, size: 20, color: scheme.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titre,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall,
                    ),
                    for (final l in lignes)
                      Text(
                        l,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall
                            ?.copyWith(color: scheme.onSurfaceVariant),
                      ),
                    if (ressources.isNotEmpty || initiative != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Wrap(
                          spacing: 8,
                          children: [
                            ...ressources,
                            if (initiative != null)
                              Tooltip(
                                message: 'Initiative',
                                child: Row(
                                  key: Key('$cle-initiative'),
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.bolt,
                                      size: 14,
                                      color: scheme.primary,
                                    ),
                                    Text(
                                      '$initiative',
                                      style: theme.textTheme.bodySmall,
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              if (actif) const Icon(Icons.play_arrow, color: OdvCouleurs.or),
              if (onRetirer != null)
                IconButton(
                  key: Key(cleRetirer ?? ''),
                  tooltip: 'Retirer de la partie',
                  visualDensity: VisualDensity.compact,
                  onPressed: onRetirer,
                  icon: Icon(Icons.close, size: 18, color: scheme.error),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Centre : infos de la carte sélectionnée.
class DetailCarte extends StatelessWidget {
  const DetailCarte({super.key, required this.seance, required this.contexte});

  final SeanceController seance;
  final ContexteCampagnes contexte;

  @override
  Widget build(BuildContext context) {
    final s = seance;
    final id = s.carte;
    if (id == kCarteScript || id == kCarteNotes) {
      return _EditeurSeance(key: ValueKey(id), seance: s);
    }
    for (final m in s.joueurs) {
      if (m.uid == id) return _detailPj(context, m);
    }
    for (final c in s.creatures) {
      if (c.id == id) {
        return s.estMj
            ? _CreatureMj(key: ValueKey(c.id), seance: s, creature: c)
            : _CreaturePj(creature: c, fiche: s.ficheCreature(c));
      }
    }
    return const Center(child: TexteAVenir('Choisis une carte.'));
  }

  Widget _detailPj(BuildContext context, MembreCampagne m) {
    final s = seance;
    final ref = contexte.referentiel;
    final f = s.ficheDe(m.uid);
    if (f != null) {
      // Sa propre fiche, ou le MJ : fiche complète et modifiable.
      if (m.uid == s.uid) {
        return FicheComplete(
          key: ValueKey(m.uid),
          fiche: f,
          referentiel: ref,
          controller: contexte.personnages,
          onModifie: () => contexte.personnages.sauvegarder(f.personnage),
        );
      }
      if (s.estMj) {
        return FicheComplete(
          key: ValueKey(m.uid),
          fiche: f,
          referentiel: ref,
          onModifie: () => s.enregistrerFiche(f.personnage),
        );
      }
      return FicheLecture(
        key: ValueKey(m.uid),
        fiche: f,
        referentiel: ref,
        joueur: m.nom,
      );
    }
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(m.personnageNom, style: const TextStyle(fontSize: 20)),
            Text(m.personnageResume),
            const SizedBox(height: 8),
            const TexteAVenir('Fiche non partagée dans cette campagne.'),
          ],
        ),
      ),
    );
  }
}

/// PV, PM ou PE sur une carte : icône et valeur de la couleur de la ressource.
class _Ressource extends StatelessWidget {
  const _Ressource(this.icone, this.texte, this.couleur);

  factory _Ressource.vie(BuildContext context, int v, int max) => _Ressource(
        Icons.favorite,
        '$v/$max',
        couleurVie(Theme.of(context).brightness),
      );

  factory _Ressource.mana(BuildContext context, int v, int max) => _Ressource(
        Icons.water_drop,
        '$v/$max',
        couleurMana(Theme.of(context).brightness),
      );

  factory _Ressource.endurance(BuildContext context, int v, int max) =>
      _Ressource(
        kIconeEndurance,
        '$v/$max',
        couleurEndurance(Theme.of(context).brightness),
      );

  final IconData icone;
  final String texte;
  final Color couleur;

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icone, size: 14, color: couleur),
          const SizedBox(width: 2),
          Text(
            texte,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: couleur,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      );
}

/// Script (MJ) ou notes de séance (PJ), enregistrés au bouton.
class _EditeurSeance extends StatefulWidget {
  const _EditeurSeance({super.key, required this.seance});

  final SeanceController seance;

  @override
  State<_EditeurSeance> createState() => _EditeurSeanceState();
}

class _EditeurSeanceState extends State<_EditeurSeance> {
  late final _texte = TextEditingController(text: widget.seance.texte);
  late String _enregistre = widget.seance.texte;

  @override
  void didUpdateWidget(_EditeurSeance ancien) {
    super.didUpdateWidget(ancien);
    // Texte chargé après l'ouverture : repris s'il n'a pas été modifié.
    final t = widget.seance.texte;
    if (t != _enregistre && _texte.text == _enregistre) {
      _enregistre = t;
      _texte.text = t;
    }
  }

  @override
  void dispose() {
    _texte.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mj = widget.seance.estMj;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          mj ? 'Script' : 'Mes notes de séance',
          style: styleAmbiance(Theme.of(context).textTheme.titleLarge),
        ),
        const SizedBox(height: 4),
        Text(mj
            ? 'Visible du MJ seulement.'
            : 'Visibles par toi seul, pour cette séance.'),
        const SizedBox(height: 12),
        TextField(
          key: const Key('texte-seance'),
          controller: _texte,
          minLines: 12,
          maxLines: null,
          keyboardType: TextInputType.multiline,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(border: OutlineInputBorder()),
        ),
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerLeft,
          child: FilledButton.icon(
            key: const Key('enregistrer-texte-seance'),
            onPressed: () async {
              final messager = ScaffoldMessenger.of(context);
              final texte = _texte.text;
              final erreur = await widget.seance.enregistrerTexte(texte);
              if (erreur == null) _enregistre = texte;
              messager.showSnackBar(
                SnackBar(content: Text(erreur ?? 'Enregistré.')),
              );
            },
            icon: const Icon(Icons.save_outlined),
            label: const Text('Enregistrer'),
          ),
        ),
      ],
    );
  }
}

/// Créature côté MJ : PV, ce que voient les PJ, fiche du bestiaire.
class _CreatureMj extends StatelessWidget {
  const _CreatureMj({super.key, required this.seance, required this.creature});

  final SeanceController seance;
  final CreatureSeance creature;

  @override
  Widget build(BuildContext context) {
    final c = creature;
    final s = seance;
    final fiche = s.ficheCreature(c);
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(c.nom, style: styleAmbiance(theme.textTheme.titleLarge)),
              if (c.pv != null)
                Row(
                  children: [
                    IconButton(
                      key: const Key('creature-pv-moins'),
                      onPressed: () =>
                          s.modifierCreature(c.copie(pv: c.pv! - 1)),
                      icon: const Icon(Icons.remove_circle_outline),
                    ),
                    Text(
                      'PV ${c.pv}/${c.pvMax}',
                      key: const Key('creature-pv'),
                      style: theme.textTheme.titleMedium,
                    ),
                    IconButton(
                      key: const Key('creature-pv-plus'),
                      onPressed: c.pv! >= c.pvMax!
                          ? null
                          : () => s.modifierCreature(c.copie(pv: c.pv! + 1)),
                      icon: const Icon(Icons.add_circle_outline),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        c.etat.libelle,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              SwitchListTile(
                key: const Key('creature-cachee'),
                contentPadding: EdgeInsets.zero,
                dense: true,
                title: const Text('Cacher la carte aux PJ'),
                value: c.cachee,
                onChanged: (v) => s.modifierCreature(c.copie(cachee: v)),
              ),
              SwitchListTile(
                key: const Key('creature-nom-cache'),
                contentPadding: EdgeInsets.zero,
                dense: true,
                title: const Text('Cacher son nom aux PJ'),
                value: c.nomCache,
                onChanged: c.cachee
                    ? null
                    : (v) => s.modifierCreature(c.copie(nomCache: v)),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: fiche == null
              ? const Center(child: TexteAVenir('Fiche introuvable.'))
              : CreatureDetail(creature: fiche),
        ),
      ],
    );
  }
}

/// Créature côté PJ : nom affiché, description et état approximatif.
class _CreaturePj extends StatelessWidget {
  const _CreaturePj({required this.creature, this.fiche});

  final CreatureSeance creature;

  /// Fiche du bestiaire, si le MJ la montre aux PJ.
  final Creature? fiche;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final f = fiche;
    if (f != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Text(
              [
                creature.nom,
                creature.pv != null
                    ? 'PV ${creature.pv}/${creature.pvMax}'
                    : creature.etat.libelle,
              ].join(' · '),
              style: styleAmbiance(theme.textTheme.titleLarge),
            ),
          ),
          Expanded(child: CreatureDetail(creature: f)),
        ],
      );
    }
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(creature.nom, style: styleAmbiance(theme.textTheme.titleLarge)),
        const SizedBox(height: 4),
        Text(
          creature.etat.libelle,
          key: const Key('creature-etat'),
          style: theme.textTheme.titleSmall,
        ),
        if (creature.pv != null)
          Text('PV ${creature.pv}/${creature.pvMax}',
              key: const Key('creature-pv')),
        const SizedBox(height: 12),
        if (creature.description.isNotEmpty) Text(creature.description),
      ],
    );
  }
}
