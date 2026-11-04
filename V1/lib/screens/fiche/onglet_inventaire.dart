import 'dart:async';

import 'package:flutter/material.dart';

import '../../models/effet.dart';
import '../../models/equipement.dart';
import '../../models/historique.dart';
import '../../models/objet.dart';
import '../../models/personnage.dart';
import '../../regles/fiche_calculee.dart';
import '../../regles/inventaire.dart';
import 'choix_objet.dart';
import 'formulaire_objet.dart';

/// Inventaire : bourse, équipement porté, sac. Ajout, modification,
/// équipement, utilisation (consommables) et suppression d'objets.
class OngletInventaire extends StatelessWidget {
  const OngletInventaire({
    super.key,
    required this.personnage,
    required this.onModifie,
    this.equipements = const [],
    this.verrouille = false,
    this.deuxArmesDeuxMains = false,
    this.fabrications = const [],
    this.usagesRestants = const {},
    this.bidouillage = false,
  });

  final Personnage personnage;
  final Future<void> Function() onModifie;

  /// Catalogue des équipements proposé à l'ajout d'un objet.
  final List<Equipement> equipements;

  /// Armement barbare : deux armes en main, même à deux mains.
  final bool deuxArmesDeuxMains;

  /// Hors séance, si le MJ l'interdit : on voit tout et on peut équiper,
  /// mais ni l'argent ni la liste des objets ne changent.
  final bool verrouille;

  /// Objets que les compétences permettent de fabriquer (Assaut : bélier,
  /// échelle) : bouton « Fabriquer » (ajoutés au sac).
  final List<({String competence, Map<String, dynamic> objet})> fabrications;

  /// Utilisations restantes des capacités limitées (nom → nombre) : une
  /// fabrication avec `usage` (potions du jour) en consomme une.
  final Map<String, int> usagesRestants;

  /// Bidouillage (ingénieur) : menu « Bidouiller » sur les armes à poudre.
  final bool bidouillage;

  /// Fabrique un objet : ajouté au sac, origine « Fabrication ».
  void _fabriquer(
      BuildContext context, String competence, Map<String, dynamic> modele) {
    // Fabrication limitée (potions : RANG×2 par jour) : une utilisation.
    final usage = modele['usage'] as String?;
    if (usage != null) {
      if ((usagesRestants[usage] ?? 0) <= 0) {
        _message(context, '$usage : plus d\'utilisation (nouveau jour ?).');
        return;
      }
      personnage.utilisations[usage] =
          (personnage.utilisations[usage] ?? 0) + 1;
    }
    final objet = Objet.depuisJson({...modele, 'id': null})
      ..origine = OrigineObjet.fabrication
      ..donnePar = competence;
    _inventaire.add(objet);
    _journal('Objet fabriqué : ${objet.nom} ($competence)');
    _message(context, '${objet.nom} fabriqué : ajouté au sac.');
    onModifie();
  }

  /// Améliorations d'une arme à poudre (Bidouillage) : nom, effet, coût.
  static const prixBidouillage = 10; // pièces d'argent

  static List<Effet> amelioration(String nom, Objet arme) => switch (nom) {
        'Crosse modifiée' => [
            Effet(
              type: 'toucher',
              valeur: '3',
              si: 'arme-choisie',
              condition: arme.nom,
              nom: nom,
            ),
          ],
        'Canon vissé' => [
            Effet(
              type: 'degats',
              valeur: '1d6',
              si: 'arme-choisie',
              condition: arme.nom,
              nom: nom,
            ),
          ],
        _ => [
            Effet(
              type: 'texte',
              nom: nom,
              texte: 'Chargeur : +2 balles sans recharger (+2 réactions de '
                  '« tenir en joue »).',
            ),
          ],
      };

  /// Améliorations possibles (nom, effet) du Bidouillage.
  static const optionsBidouillage = [
    ('Crosse modifiée', '+3 AdT'),
    ('Canon vissé', '+1d6 DMG'),
    ('Chargeur', '+2 balles sans recharger'),
  ];

  /// Amélioration déjà faite sur [arme] (`null` : aucune).
  static String? bidouillageDe(Objet arme) {
    for (final e in arme.effets) {
      for (final (nom, _) in optionsBidouillage) {
        if (e.nom == nom) return nom;
      }
    }
    return null;
  }

  /// Bidouillage : une seule amélioration par arme, contre 10 pa ; en
  /// choisir une autre remplace l'actuelle (et coûte de nouveau 10 pa).
  Future<void> _bidouiller(BuildContext context, Objet arme) async {
    final faite = bidouillageDe(arme);
    final choix = await showDialog<String>(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text('Bidouiller : ${arme.nom}'),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
            child: Text(
              faite != null
                  ? 'Amélioration actuelle : $faite. En choisir une autre la '
                      'remplace (une seule par arme), pour $prixBidouillage pa '
                      'de pièces. Bourse : ${personnage.bourse.argent} pa.'
                  : 'Une seule amélioration par arme, pour '
                      '$prixBidouillage pa de pièces. Bourse : '
                      '${personnage.bourse.argent} pa.',
            ),
          ),
          for (final (nom, effet) in optionsBidouillage)
            SimpleDialogOption(
              key: Key('bidouiller-$nom'),
              onPressed:
                  nom == faite ? null : () => Navigator.pop(context, nom),
              child: Text(
                nom == faite ? '$nom ($effet) · actuelle' : '$nom ($effet)',
              ),
            ),
        ],
      ),
    );
    if (choix == null || !context.mounted) return;
    if (personnage.bourse.argent < prixBidouillage) {
      _message(context, 'Il faut $prixBidouillage pa pour les pièces.');
      return;
    }
    personnage.bourse.argent -= prixBidouillage;
    // L'ancienne amélioration est perdue.
    final noms = {for (final (n, _) in optionsBidouillage) n};
    arme.effets = [
      for (final e in arme.effets)
        if (!noms.contains(e.nom)) e,
      ...amelioration(choix, arme),
    ];
    _journal(faite == null
        ? 'Bidouillage : ${arme.nom} · $choix (−$prixBidouillage pa)'
        : 'Bidouillage : ${arme.nom} · $faite remplacée par $choix '
            '(−$prixBidouillage pa)');
    _message(context, '${arme.nom} : $choix.');
    unawaited(onModifie());
  }

  /// Arme principale (attaque au d20) ; les autres deviennent secondaires.
  void _rendrePrincipale(Objet objet) {
    for (final o in _inventaire) {
      o.principale = identical(o, objet);
    }
    _journal('Arme principale : ${objet.nom}');
    onModifie();
  }

  List<Objet> get _inventaire => personnage.inventaire;

  Future<void> _ajouter(BuildContext context) async {
    final objet = await ChoixObjet.ouvrir(context, equipements);
    if (objet == null) return;
    _inventaire.add(objet);
    _journal(
      'Objet ajouté : ${_nomQuantite(objet)}'
      '${objet.resume.isEmpty ? '' : ' (${objet.resume})'}'
      '${objet.origine == OrigineObjet.inconnue ? '' : ' · origine : ${objet.texteOrigine}'}',
    );
    await onModifie();
  }

  void _journal(String message, {String? fusion}) => personnage.journaliser(
        message,
        categorie: CategorieHistorique.inventaire,
        fusion: fusion,
      );

  static String _nomQuantite(Objet o) =>
      o.quantite > 1 ? '${o.nom} ×${o.quantite}' : o.nom;

  Future<void> _modifier(BuildContext context, Objet objet) async {
    final avant = Objet.depuisJson(objet.versJson());
    final modifie = await FormulaireObjet.ouvrir(context, objet: objet);
    if (modifie == null) return;
    final changements = <String>[
      if (avant.nom != objet.nom) 'renommé « ${avant.nom} » → « ${objet.nom} »',
      if (avant.categorie != objet.categorie)
        'catégorie ${objet.categorie.libelle.toLowerCase()}',
      if (avant.quantite != objet.quantite)
        'quantité ${avant.quantite} → ${objet.quantite}',
      if (avant.resume != objet.resume && objet.resume.isNotEmpty) objet.resume,
      if (avant.description != objet.description) 'description',
      if (avant.texteOrigine != objet.texteOrigine)
        'origine : ${objet.texteOrigine}',
      if (!avant.personnalise && objet.personnalise) 'personnalisé',
    ];
    if (changements.isNotEmpty) {
      _journal('Objet modifié : ${objet.nom} (${changements.join(', ')})');
    }
    // Devenu à deux mains (ou arme) alors que les mains sont déjà prises :
    // l'objet est retiré.
    if (objet.equipe &&
        ReglesInventaire.mainsDepassees(_inventaire,
            deuxArmesDeuxMains: deuxArmesDeuxMains)) {
      objet.equipe = false;
      _journal('Retiré : ${objet.nom} (plus assez de mains libres)');
      if (context.mounted) {
        _message(
          context,
          '${objet.nom} a été retiré : plus assez de mains libres.',
        );
      }
    }
    await onModifie();
  }

  static void _message(BuildContext context, String texte) =>
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(texte)));

  void _basculerEquipement(BuildContext context, Objet objet) {
    final refus = ReglesInventaire.refusEquipement(_inventaire, objet,
        deuxArmesDeuxMains: deuxArmesDeuxMains);
    if (refus != null) {
      _message(context, refus);
      return;
    }
    objet.equipe = !objet.equipe;
    // Monture « équipée » = montée.
    final monture = objet.categorie == CategorieObjet.monture;
    _journal(
      objet.equipe
          ? '${monture ? 'Monte' : 'Équipé'} : ${objet.nom}'
          : '${monture ? 'Descend' : 'Retiré'} : ${objet.nom}',
    );
    onModifie();
  }

  /// Arme utilisable à une ou deux mains : change la prise (et les dégâts).
  void _changerPrise(BuildContext context, Objet objet) {
    final refus = ReglesInventaire.refusPrise(
      _inventaire,
      objet,
      deuxMains: !objet.tenueDeuxMains,
      deuxArmesDeuxMains: deuxArmesDeuxMains,
    );
    if (refus != null) {
      _message(context, refus);
      return;
    }
    objet.tenueDeuxMains = !objet.tenueDeuxMains;
    final degats = objet.degatsActuels;
    _journal(
      '${objet.nom} : tenu à ${objet.tenueDeuxMains ? 'deux mains' : 'une main'}'
      '${degats.isEmpty ? '' : ' ($degats)'}',
    );
    onModifie();
  }

  void _changerQuantite(BuildContext context, Objet objet, int delta) {
    final q = objet.quantite + delta;
    if (q <= 0) {
      _supprimer(context, objet);
      return;
    }
    final avant = objet.quantite;
    objet.quantite = q;
    personnage.journaliserValeur(
      cle: 'quantite-${objet.id}',
      libelle: objet.nom,
      avant: avant,
      apres: q,
      categorie: CategorieHistorique.inventaire,
      regrouper: true,
    );
    onModifie();
  }

  void _supprimer(BuildContext context, Objet objet) {
    final index = _inventaire.indexOf(objet);
    if (index < 0) return;
    _inventaire.removeAt(index);
    _journal('Objet supprimé : ${_nomQuantite(objet)}');
    onModifie();
    final messenger = ScaffoldMessenger.of(context)..hideCurrentSnackBar();
    final message = messenger.showSnackBar(
      SnackBar(
        content: Text('${objet.nom} retiré de l\'inventaire.'),
        duration: _dureeMessage,
        action: SnackBarAction(
          label: 'Annuler',
          onPressed: () {
            if (objet.quantite <= 0) objet.quantite = 1;
            final position =
                index > _inventaire.length ? _inventaire.length : index;
            _inventaire.insert(position, objet);
            _journal('Suppression annulée : ${_nomQuantite(objet)}');
            onModifie();
          },
        ),
      ),
    );
    // Depuis Flutter 3.29, un message avec bouton d'action reste affiché
    // jusqu'à ce qu'on le ferme : on le ferme nous-mêmes après 4 secondes.
    Timer(_dureeMessage, message.close);
  }

  static const Duration _dureeMessage = Duration(seconds: 4);

  void _ajusterPiece(BuildContext context, String piece, int delta) {
    final b = personnage.bourse;
    late final int avant;
    late final int apres;
    switch (piece) {
      case 'or':
        avant = b.or;
        b.or = apres = (b.or + delta).clamp(0, 999999).toInt();
      case 'argent':
        avant = b.argent;
        b.argent = apres = (b.argent + delta).clamp(0, 999999).toInt();
      default:
        avant = b.cuivre;
        b.cuivre = apres = (b.cuivre + delta).clamp(0, 999999).toInt();
    }
    personnage.journaliserValeur(
      cle: 'bourse-$piece',
      libelle:
          'Pièces ${piece == 'or' ? 'd\'or' : piece == 'argent' ? 'd\'argent' : 'de cuivre'}',
      avant: avant,
      apres: apres,
      categorie: CategorieHistorique.bourse,
      regrouper: true,
    );
    onModifie();
  }

  Future<void> _transaction(BuildContext context,
      {required bool recevoir}) async {
    final resultat = await showDialog<({Bourse montant, String commentaire})>(
      context: context,
      builder: (context) => _DialogueTransaction(
        recevoir: recevoir,
        bourse: personnage.bourse,
      ),
    );
    if (resultat == null || resultat.montant.vide) return;
    final montant = resultat.montant;
    final note = resultat.commentaire.trim();
    final b = personnage.bourse;
    final signe = recevoir ? 1 : -1;
    b
      ..or += signe * montant.or
      ..argent += signe * montant.argent
      ..cuivre += signe * montant.cuivre;
    personnage.journaliser(
      '${recevoir ? 'Reçu' : 'Payé'} : ${montant.texte}'
      '${note.isEmpty ? '' : ' — $note'}',
      categorie: CategorieHistorique.bourse,
    );
    await onModifie();
  }

  Future<void> _modifierBourse(BuildContext context) async {
    final resultat = await showDialog<({Bourse bourse, String commentaire})>(
      context: context,
      builder: (context) => _DialogueBourse(bourse: personnage.bourse),
    );
    if (resultat == null) return;
    final nouvelle = resultat.bourse;
    final note = resultat.commentaire.trim();
    final ancienne = personnage.bourse;
    personnage.bourse = nouvelle;
    if (ancienne.texte != nouvelle.texte) {
      personnage.journaliser(
        'Bourse corrigée : ${ancienne.texte} → ${nouvelle.texte}'
        '${note.isEmpty ? '' : ' — $note'}',
        categorie: CategorieHistorique.bourse,
      );
    }
    await onModifie();
  }

  @override
  Widget build(BuildContext context) {
    final portes = [
      for (final o in _inventaire)
        if (o.equipe) o,
    ];
    final sac = [
      for (final o in _inventaire)
        if (!o.equipe) o,
    ];

    return ListView(
      key: const PageStorageKey('onglet-inventaire'),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      children: [
        if (verrouille) ...[
          const Text(
            'Le MJ ne permet pas d\'ajouter ou de retirer de l\'argent ou des '
            'objets en dehors d\'une séance.',
            key: Key('inventaire-verrouille'),
          ),
          const SizedBox(height: 12),
          Text('Bourse : ${personnage.bourse.texte}'),
        ] else ...[
          _CarteBourse(
            bourse: personnage.bourse,
            onModifier: () => _modifierBourse(context),
            onAjuster: (piece, delta) => _ajusterPiece(context, piece, delta),
            onRecevoir: () => _transaction(context, recevoir: true),
            onPayer: () => _transaction(context, recevoir: false),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            key: const Key('ajouter-objet'),
            onPressed: () => _ajouter(context),
            icon: const Icon(Icons.add),
            label: const Text('Ajouter un objet'),
          ),
        ],
        const SizedBox(height: 20),
        _TitreSection(
          titre: 'Équipement porté',
          detail:
              'Plastron ${ReglesInventaire.nombreEquipes(_inventaire, CategorieObjet.armure)}/1 · '
              'Casque ${ReglesInventaire.nombreEquipes(_inventaire, CategorieObjet.casque)}/1 · '
              'Bijoux ${ReglesInventaire.nombreEquipes(_inventaire, CategorieObjet.accessoire)}/2 · '
              '${deuxArmesDeuxMains ? 'Armes en main ${ReglesInventaire.enMain(_inventaire).length}/2' : 'Mains ${ReglesInventaire.mainsOccupees(_inventaire)}/${ReglesInventaire.mainsMax}'}',
        ),
        if (portes.isEmpty)
          const _Vide(texte: 'Rien n\'est porté.')
        else
          for (final o in portes) _ligne(context, o),
        const SizedBox(height: 20),
        _TitreSection(
          titre: 'Sac',
          detail: '${sac.length} objet${sac.length > 1 ? 's' : ''}',
        ),
        if (sac.isEmpty)
          const _Vide(texte: 'Le sac est vide.')
        else
          for (final o in sac) _ligne(context, o),
        // Fabrication (Assaut du barbare : bélier, échelle).
        if (fabrications.isNotEmpty && !verrouille) ...[
          const SizedBox(height: 20),
          const _TitreSection(
            titre: 'Fabrication',
            detail: 'Objets que tes compétences permettent de fabriquer',
          ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final f in fabrications)
                () {
                  // Potions : « (3 restantes aujourd'hui) ».
                  final usage = f.objet['usage'] as String?;
                  final reste = usage == null ? null : usagesRestants[usage];
                  return ActionChip(
                    key: Key('fabriquer-${f.objet['nom']}'),
                    avatar: const Icon(Icons.handyman_outlined, size: 18),
                    label: Text('Fabriquer : ${f.objet['nom']}'
                        '${reste == null ? '' : ' ($reste)'}'),
                    tooltip: usage == null
                        ? f.competence
                        : '${f.competence} · $usage : $reste restante(s)',
                    onPressed: reste == 0
                        ? null
                        : () => _fabriquer(context, f.competence, f.objet),
                  );
                }(),
            ],
          ),
        ],
      ],
    );
  }

  /// Arme principale : celle marquée, sinon la première arme de CaC équipée.
  bool _estPrincipale(Objet o) {
    final armes = [
      for (final x in _inventaire)
        if (x.equipe && x.categorie == CategorieObjet.arme && !x.distance) x,
    ];
    final p = armes.firstWhere((x) => x.principale,
        orElse: () => armes.isEmpty ? o : armes.first);
    return identical(p, o);
  }

  Widget _ligne(BuildContext context, Objet o) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final consommable = o.categorie == CategorieObjet.consommable;
    final details = <String>[
      o.categorie.libelle,
      if (o.resume.isNotEmpty) o.resume,
      if (o.matiere != MatiereObjet.nonPrecisee) o.matiere.libelle,
      if (o.categorie == CategorieObjet.armure &&
          o.poidsArmure != PoidsArmure.nonPrecise)
        'Armure ${o.poidsArmure.libelle.toLowerCase()}',
      if (o.origine != OrigineObjet.inconnue) 'Origine : ${o.texteOrigine}',
    ];
    return Card(
      key: Key('objet-${o.id}'),
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      color:
          o.equipe ? scheme.primaryContainer : scheme.surfaceContainerHighest,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: verrouille ? null : () => _modifier(context, o),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 4, 8),
          child: Row(
            children: [
              iconeCategorieWidget(
                o.categorie,
                distance: o.distance,
                armeAFeu: FicheCalculee.estArmeAFeu(o),
                couleur: o.equipe ? scheme.onPrimaryContainer : scheme.primary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            o.quantite > 1 ? '${o.nom} ×${o.quantite}' : o.nom,
                            style: theme.textTheme.bodyLarge
                                ?.copyWith(fontWeight: FontWeight.w600),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        // Objet personnalisé (attributs édités) : clé à molette.
                        if (o.personnalise) ...[
                          const SizedBox(width: 6),
                          Tooltip(
                            message: 'Objet personnalisé',
                            child: Icon(
                              Icons.build,
                              key: Key('personnalise-${o.id}'),
                              size: 14,
                              color: scheme.primary,
                            ),
                          ),
                        ],
                      ],
                    ),
                    Text(
                      details.join(' · '),
                      style: theme.textTheme.bodySmall,
                    ),
                    if (o.description.isNotEmpty)
                      Text(
                        o.description,
                        style: theme.textTheme.bodySmall
                            ?.copyWith(color: scheme.onSurfaceVariant),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              // Deux armes (Armement barbare) : laquelle attaque au d20.
              if (deuxArmesDeuxMains &&
                  o.equipe &&
                  o.categorie == CategorieObjet.arme &&
                  !o.distance &&
                  _inventaire
                          .where((x) =>
                              x.equipe &&
                              x.categorie == CategorieObjet.arme &&
                              !x.distance)
                          .length >
                      1)
                IconButton(
                  key: Key('principale-${o.id}'),
                  tooltip: _estPrincipale(o)
                      ? 'Arme principale (attaque au d20)'
                      : 'Arme secondaire (attaque au d12) — rendre principale',
                  isSelected: _estPrincipale(o),
                  onPressed: () => _rendrePrincipale(o),
                  icon: const Icon(Icons.looks_two_outlined),
                  selectedIcon: const Icon(Icons.looks_one),
                ),
              if (o.categorie == CategorieObjet.arme && o.polyvalente)
                IconButton(
                  key: Key('prise-${o.id}'),
                  tooltip: o.tenueDeuxMains
                      ? 'Tenu à deux mains — passer à une main'
                      : 'Tenu à une main — passer à deux mains',
                  onPressed: () => _changerPrise(context, o),
                  icon: Text(
                    o.tenueDeuxMains ? '2M' : '1M',
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color:
                          o.equipe ? scheme.onPrimaryContainer : scheme.primary,
                    ),
                  ),
                ),
              if (consommable && !verrouille)
                IconButton(
                  key: Key('utiliser-${o.id}'),
                  tooltip: 'Utiliser (−1)',
                  onPressed: () => _changerQuantite(context, o, -1),
                  icon: const Icon(Icons.local_drink_outlined),
                ),
              if (o.categorie.equipable)
                IconButton(
                  key: Key('equiper-${o.id}'),
                  tooltip: o.categorie == CategorieObjet.monture
                      ? (o.equipe ? 'Descendre' : 'Monter')
                      : (o.equipe ? 'Retirer' : 'Équiper'),
                  isSelected: o.equipe,
                  onPressed: () => _basculerEquipement(context, o),
                  icon: const Icon(Icons.radio_button_unchecked),
                  selectedIcon: const Icon(Icons.check_circle),
                ),
              if (!verrouille)
                PopupMenuButton<String>(
                  key: Key('menu-objet-${o.id}'),
                  tooltip: 'Actions',
                  onSelected: (action) {
                    switch (action) {
                      case 'modifier':
                        _modifier(context, o);
                      case 'plus':
                        _changerQuantite(context, o, 1);
                      case 'moins':
                        _changerQuantite(context, o, -1);
                      case 'supprimer':
                        _supprimer(context, o);
                      case 'bidouiller':
                        _bidouiller(context, o);
                    }
                  },
                  itemBuilder: (context) => [
                    if (bidouillage && FicheCalculee.estArmeAFeu(o))
                      const PopupMenuItem(
                        value: 'bidouiller',
                        child: Text('Bidouiller (10 pa)'),
                      ),
                    const PopupMenuItem(
                        value: 'modifier', child: Text('Modifier')),
                    const PopupMenuItem(
                        value: 'plus', child: Text('Quantité +1')),
                    const PopupMenuItem(
                        value: 'moins', child: Text('Quantité −1')),
                    const PopupMenuItem(
                      value: 'supprimer',
                      child: Text('Supprimer'),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TitreSection extends StatelessWidget {
  const _TitreSection({required this.titre, required this.detail});

  final String titre;
  final String detail;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(titre, style: theme.textTheme.titleMedium),
          Text(
            detail,
            style: theme.textTheme.bodySmall
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _Vide extends StatelessWidget {
  const _Vide({required this.texte});

  final String texte;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        texte,
        style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
      ),
    );
  }
}

/// Bourse : pour chaque pièce, valeur et boutons −1 / +1 ;
/// « Recevoir » / « Payer » pour un montant en une fois ;
/// crayon pour corriger les valeurs directement.
class _CarteBourse extends StatelessWidget {
  const _CarteBourse({
    required this.bourse,
    required this.onModifier,
    required this.onAjuster,
    required this.onRecevoir,
    required this.onPayer,
  });

  final Bourse bourse;
  final VoidCallback onModifier;
  final void Function(String piece, int delta) onAjuster;
  final VoidCallback onRecevoir;
  final VoidCallback onPayer;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    Widget piece(String libelle, int valeur, Color couleur, String cle) =>
        Expanded(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.circle, size: 12, color: couleur),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      libelle,
                      style: theme.textTheme.labelMedium,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              Text(
                '$valeur',
                key: Key('bourse-$cle'),
                style: theme.textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    key: Key('bourse-$cle-moins'),
                    tooltip: '−1 $libelle',
                    visualDensity: VisualDensity.compact,
                    onPressed: valeur > 0 ? () => onAjuster(cle, -1) : null,
                    icon: const Icon(Icons.remove_circle_outline),
                  ),
                  IconButton(
                    key: Key('bourse-$cle-plus'),
                    tooltip: '+1 $libelle',
                    visualDensity: VisualDensity.compact,
                    onPressed: () => onAjuster(cle, 1),
                    icon: const Icon(Icons.add_circle_outline),
                  ),
                ],
              ),
            ],
          ),
        );

    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: scheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 4, 4, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(Icons.account_balance_wallet_outlined,
                    color: scheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text('Bourse', style: theme.textTheme.titleMedium),
                ),
                IconButton(
                  key: const Key('bouton-bourse'),
                  tooltip: 'Corriger les montants',
                  onPressed: onModifier,
                  icon: const Icon(Icons.edit_outlined),
                ),
              ],
            ),
            Row(
              children: [
                piece('Or', bourse.or, const Color(0xFFD4A017), 'or'),
                piece(
                    'Argent', bourse.argent, const Color(0xFFA8A9AD), 'argent'),
                piece(
                    'Cuivre', bourse.cuivre, const Color(0xFFB87333), 'cuivre'),
              ],
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      key: const Key('bourse-payer'),
                      onPressed: bourse.vide ? null : onPayer,
                      icon: const Icon(Icons.remove),
                      label: const Text('Payer'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: FilledButton.tonalIcon(
                      key: const Key('bourse-recevoir'),
                      onPressed: onRecevoir,
                      icon: const Icon(Icons.add),
                      label: const Text('Recevoir'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Saisie d'un montant à recevoir ou à payer (or, argent, cuivre).
/// Renvoie le montant (toujours positif) ; pour un paiement, refuse si la
/// bourse ne contient pas assez de pièces.
class _DialogueTransaction extends StatefulWidget {
  const _DialogueTransaction({required this.recevoir, required this.bourse});

  final bool recevoir;
  final Bourse bourse;

  @override
  State<_DialogueTransaction> createState() => _DialogueTransactionState();
}

class _DialogueTransactionState extends State<_DialogueTransaction> {
  final _or = TextEditingController();
  final _argent = TextEditingController();
  final _cuivre = TextEditingController();

  /// Origine de la dépense ou du gain (« auberge du Sanglier »), notée dans
  /// l'historique.
  final _commentaire = TextEditingController();

  @override
  void dispose() {
    _or.dispose();
    _argent.dispose();
    _commentaire.dispose();
    _cuivre.dispose();
    super.dispose();
  }

  int _lire(TextEditingController c) {
    final v = int.tryParse(c.text.trim()) ?? 0;
    return v < 0 ? 0 : v;
  }

  Bourse get _montant =>
      Bourse(or: _lire(_or), argent: _lire(_argent), cuivre: _lire(_cuivre));

  /// Message d'erreur pour un paiement impossible (`null` si possible).
  String? get _erreur {
    if (widget.recevoir) return null;
    final m = _montant;
    final b = widget.bourse;
    final manque = <String>[
      if (m.or > b.or) 'd\'or',
      if (m.argent > b.argent) 'd\'argent',
      if (m.cuivre > b.cuivre) 'de cuivre',
    ];
    if (manque.isEmpty) return null;
    return 'Pas assez de pièces ${manque.join(', ')}.';
  }

  Widget _champ(String cle, String libelle, TextEditingController c) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: TextField(
          key: Key('transaction-$cle'),
          controller: c,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: libelle,
            hintText: '0',
            border: const OutlineInputBorder(),
          ),
          onChanged: (_) => setState(() {}),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final erreur = _erreur;
    final valide = !_montant.vide && erreur == null;
    final b = widget.bourse;
    return AlertDialog(
      title: Text(widget.recevoir ? 'Recevoir de l\'argent' : 'Payer'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (!widget.recevoir)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  'Dans la bourse : ${b.or} or · ${b.argent} argent · '
                  '${b.cuivre} cuivre',
                ),
              ),
            _champ('or', 'Pièces d\'or', _or),
            _champ('argent', 'Pièces d\'argent', _argent),
            _champ('cuivre', 'Pièces de cuivre', _cuivre),
            _ChampCommentaire(
              cle: 'transaction-commentaire',
              controleur: _commentaire,
              exemple: widget.recevoir
                  ? 'Ex. : butin du gobelin, vente de peaux…'
                  : "Ex. : auberge, achat d'une épée…",
            ),
            if (erreur != null)
              Text(
                erreur,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Annuler'),
        ),
        FilledButton(
          key: const Key('valider-transaction'),
          onPressed: valide
              ? () => Navigator.of(context)
                  .pop((montant: _montant, commentaire: _commentaire.text))
              : null,
          child: Text(widget.recevoir ? 'Recevoir' : 'Payer'),
        ),
      ],
    );
  }
}

class _DialogueBourse extends StatefulWidget {
  const _DialogueBourse({required this.bourse});

  final Bourse bourse;

  @override
  State<_DialogueBourse> createState() => _DialogueBourseState();
}

class _DialogueBourseState extends State<_DialogueBourse> {
  late final _or = TextEditingController(text: '${widget.bourse.or}');
  late final _argent = TextEditingController(text: '${widget.bourse.argent}');
  late final _cuivre = TextEditingController(text: '${widget.bourse.cuivre}');
  final _commentaire = TextEditingController();

  @override
  void dispose() {
    _or.dispose();
    _argent.dispose();
    _cuivre.dispose();
    _commentaire.dispose();
    super.dispose();
  }

  int _lire(TextEditingController c) {
    final v = int.tryParse(c.text.trim()) ?? 0;
    return v < 0 ? 0 : v;
  }

  Widget _champ(String cle, String libelle, TextEditingController c) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: TextField(
          key: Key('champ-$cle'),
          controller: c,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: libelle,
            border: const OutlineInputBorder(),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Bourse'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _champ('or', 'Pièces d\'or', _or),
            _champ('argent', 'Pièces d\'argent', _argent),
            _champ('cuivre', 'Pièces de cuivre', _cuivre),
            _ChampCommentaire(
              cle: 'bourse-commentaire',
              controleur: _commentaire,
              exemple: 'Ex. : oubli de la séance dernière…',
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Annuler'),
        ),
        FilledButton(
          key: const Key('valider-bourse'),
          onPressed: () => Navigator.of(context).pop((
            bourse: Bourse(
              or: _lire(_or),
              argent: _lire(_argent),
              cuivre: _lire(_cuivre),
            ),
            commentaire: _commentaire.text,
          )),
          child: const Text('Valider'),
        ),
      ],
    );
  }
}

/// Commentaire d'un mouvement d'argent (origine de la dépense ou du gain),
/// noté dans l'historique après le montant (« Payé : 3 pa — auberge »).
class _ChampCommentaire extends StatelessWidget {
  const _ChampCommentaire({
    required this.cle,
    required this.controleur,
    required this.exemple,
  });

  final String cle;
  final TextEditingController controleur;
  final String exemple;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: TextField(
          key: Key(cle),
          controller: controleur,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(
            labelText: 'Commentaire (facultatif)',
            hintText: exemple,
            border: const OutlineInputBorder(),
          ),
        ),
      );
}
