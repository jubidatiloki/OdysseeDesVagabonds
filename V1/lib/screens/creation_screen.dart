import 'package:flutter/material.dart';

import '../data/referentiel.dart';
import '../models/aptitude.dart';
import '../models/historique.dart';
import '../models/carac.dart';
import '../models/classe.dart';
import '../models/personnage.dart';
import '../models/race.dart';
import '../regles/fiche_calculee.dart';
import '../regles/inventaire.dart';
import '../regles/montee_niveau.dart';
import '../regles/progression.dart';
import '../state/personnages_controller.dart';
import '../widgets/carte_choix.dart';
import 'creation/etape_caracteristiques.dart';
import 'creation/etape_classe.dart';
import 'creation/etape_competences.dart';
import 'creation/etape_identite.dart';
import 'creation/etape_race.dart';
import 'creation/etape_recapitulatif.dart';
import 'fiche_screen.dart';

/// Assistant de création de personnage en 6 étapes :
/// identité → race → classe → caractéristiques → compétences → récapitulatif.
class CreationScreen extends StatefulWidget {
  const CreationScreen({
    super.key,
    required this.referentiel,
    required this.controller,
  });

  final Referentiel referentiel;
  final PersonnagesController controller;

  @override
  State<CreationScreen> createState() => _CreationScreenState();
}

class _CreationScreenState extends State<CreationScreen> {
  static const List<String> _titres = [
    'Identité',
    'Race',
    'Classe',
    'Caractéristiques',
    'Compétences',
    'Récapitulatif',
  ];

  final _nom = TextEditingController();
  final _notes = TextEditingController();

  /// Niveau de départ d'un personnage.
  static const int _niveau = 1;

  int _etape = 0;

  /// Le joueur prend l'inventaire de base de sa classe.
  var _inventaireBase = true;
  Sexe? _sexe;
  Race? _race;
  String? _origineId;
  String? _optionPassifId;
  Classe? _classe;
  Map<Carac, int> _base = RepartitionCreation.valeursDepart();
  Map<String, int> _rangsVoies = {};
  List<AptitudeAcquise> _aptitudes = [];

  /// Choix faits à la création (élément du souffle draconien…).
  Map<String, String> _choix = {};

  /// Précisions des choix (« Quel instrument ? ») et descriptions des objets
  /// donnés à personnaliser (porte-bonheur), par clé.
  Map<String, String> _precisions = {};
  final Map<String, String> _descriptions = {};
  bool _enregistrement = false;

  @override
  void dispose() {
    _nom.dispose();
    _notes.dispose();
    super.dispose();
  }

  /// Grand écran : race et classe se choisissent sur la même étape (races à
  /// gauche, classes à droite) ; l'étape « Classe » est alors sautée.
  /// Mis à jour à chaque construction selon la largeur de l'écran.
  bool _large = false;

  static const double _largeurRaceEtClasse = 1100;

  /// Étape réellement affichée (l'étape « Classe » devient « Race et
  /// classe » sur grand écran).
  int get _etapeEff => _large && _etape == 2 ? 1 : _etape;

  /// Titres des étapes affichées (5 sur grand écran, 6 sinon).
  List<String> get _titresAffiches => _large
      ? const [
          'Identité',
          'Race et classe',
          'Caractéristiques',
          'Compétences',
          'Récapitulatif',
        ]
      : _titres;

  /// Numéro (à partir de 0) de l'étape affichée dans [_titresAffiches].
  int get _numeroAffiche =>
      _large && _etapeEff >= 2 ? _etapeEff - 1 : _etapeEff;

  bool get _dernierEtape => _etapeEff == _titres.length - 1;

  /// Résumé des choix déjà faits, affiché dans l'en-tête :
  /// « Brom · Demi-elfe (origine sylvaine) · Guerrier ».
  String get _resume {
    final parties = <String>[];
    final nom = _nom.text.trim();
    if (nom.isNotEmpty) parties.add(nom);
    final r = _race;
    if (r != null) {
      final precision =
          r.origine(_origineId)?.nom ?? r.optionPassif(_optionPassifId)?.nom;
      parties.add(
        precision == null ? r.nom : '${r.nom} (${precision.toLowerCase()})',
      );
    }
    if (_classe != null) parties.add(_classe!.nom);
    return parties.join(' · ');
  }

  /// Vrai si le joueur a commencé à saisir quelque chose.
  bool get _modifie =>
      _nom.text.trim().isNotEmpty ||
      _notes.text.trim().isNotEmpty ||
      _sexe != null ||
      _race != null ||
      _classe != null ||
      RepartitionCreation.pointsDepenses(_base) > 0;

  /// Raison pour laquelle on ne peut pas passer à l'étape suivante
  /// (`null` si tout est bon).
  String? get _blocage {
    switch (_etapeEff) {
      case 0:
        if (_nom.text.trim().isEmpty) return 'Donne un nom à ton personnage';
        if (_sexe == null) return 'Choisis le sexe de ton personnage';
      case 1:
        final r = _race;
        if (r == null) return 'Choisis une race';
        if (r.aDesOrigines && r.origine(_origineId) == null) {
          return 'Choisis une origine';
        }
        if (r.aUnChoixDePassif && r.optionPassif(_optionPassifId) == null) {
          return 'Choisis un héritage';
        }
        final choixPassif = r.optionPassif(_optionPassifId)?.choix;
        if (choixPassif != null && !_choix.containsKey(choixPassif.cle)) {
          return 'Choisis : ${choixPassif.titre.toLowerCase()}';
        }
        if (_large && _classe == null) return 'Choisis une classe';
      case 2:
        if (_classe == null) return 'Choisis une classe';
      case 3:
        final restants = RepartitionCreation.pointsRestants(_base);
        if (restants > 0) {
          return 'Encore $restants point${restants > 1 ? 's' : ''} à répartir';
        }
        if (!RepartitionCreation.estComplete(_base)) {
          return 'Répartition invalide';
        }
      case 5:
        // Choix des compétences de départ (gnome : arme ou instrument).
        final enAttente = _ficheBrouillon.choixEnAttente;
        if (enAttente.isNotEmpty) {
          return 'Choix à faire : ${enAttente.first.nom}';
        }
    }
    return null;
  }

  Personnage _brouillon() => Personnage(
        id: 'brouillon',
        nom: _nom.text.trim(),
        sexe: _sexe,
        raceId: _race!.id,
        origineId: _race!.aDesOrigines ? _origineId : null,
        optionPassifId: _race!.aUnChoixDePassif ? _optionPassifId : null,
        classeId: _classe!.id,
        caracBase: Map.of(_base),
        rangsVoies: Map.of(_rangsVoies),
        aptitudes: List.of(_aptitudes),
        description: _notes.text.trim(),
        choix: Map.of(_choix),
        precisionsChoix: Map.of(_precisions),
      );

  FicheCalculee get _ficheBrouillon =>
      FicheCalculee(personnage: _brouillon(), race: _race!, classe: _classe!);

  void _suivant() {
    if (_blocage != null) return;
    if (_dernierEtape) {
      _creer();
    } else {
      FocusScope.of(context).unfocus();
      // Grand écran : la classe est déjà choisie avec la race.
      setState(() => _etape = _large && _etapeEff == 1 ? 3 : _etapeEff + 1);
    }
  }

  void _precedent() {
    if (_etapeEff == 0) return;
    setState(() => _etape = _large && _etapeEff == 3 ? 1 : _etapeEff - 1);
  }

  Future<void> _creer() async {
    if (_enregistrement) return;
    setState(() => _enregistrement = true);
    final brouillon = _brouillon();
    final personnage = Personnage(
      id: Personnage.nouvelId(),
      nom: brouillon.nom,
      sexe: brouillon.sexe,
      raceId: brouillon.raceId,
      origineId: brouillon.origineId,
      optionPassifId: brouillon.optionPassifId,
      classeId: brouillon.classeId,
      caracBase: brouillon.caracBase,
      rangsVoies: brouillon.rangsVoies,
      aptitudes: brouillon.aptitudes,
      description: brouillon.description,
      choix: brouillon.choix,
      precisionsChoix: brouillon.precisionsChoix,
    );
    personnage.journaliser(
      'Personnage créé : $_resume · niveau 1',
      categorie: CategorieHistorique.creation,
    );
    if (_inventaireBase) {
      personnage.inventaire.addAll(
        ObjetDuCatalogue.inventaireBase(
          _classe!,
          widget.referentiel.equipements,
        ),
      );
    }
    // Objets donnés par les compétences de départ (porte-bonheur du gnome).
    final ficheCree =
        FicheCalculee(personnage: personnage, race: _race!, classe: _classe!);
    // Choix faits à la création (élément, arme ou instrument du gnome…).
    MonteeNiveau.journaliserChoix(personnage, ficheCree, personnage.choix);
    // Objets donnés (porte-bonheur décrit par le joueur, arme ou instrument
    // choisi, repris du catalogue s'il y existe).
    ObjetsDonnes.recevoir(
      ficheCree,
      catalogue: widget.referentiel.equipements,
      descriptions: _descriptions,
    );
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    try {
      await widget.controller.sauvegarder(personnage);
    } catch (e) {
      if (!mounted) return;
      setState(() => _enregistrement = false);
      messenger.showSnackBar(
        SnackBar(content: Text('Échec de la sauvegarde : $e')),
      );
      return;
    }
    // On remplace l'assistant par la fiche du nouveau personnage
    // (le PopScope ne bloque que les retours, pas les remplacements).
    navigator.pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => FicheScreen(
          personnageId: personnage.id,
          referentiel: widget.referentiel,
          controller: widget.controller,
        ),
      ),
    );
    messenger.showSnackBar(
      SnackBar(content: Text('${personnage.nom} a rejoint l\'aventure !')),
    );
  }

  Future<void> _confirmerAbandon() async {
    final abandonner = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Abandonner la création ?'),
        content: const Text('Les informations saisies seront perdues.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Continuer'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Abandonner'),
          ),
        ],
      ),
    );
    if (abandonner == true && mounted) Navigator.of(context).pop();
  }

  Widget _contenuEtape() {
    final ref = widget.referentiel;
    switch (_etapeEff) {
      case 0:
        return EtapeIdentite(
          nom: _nom,
          notes: _notes,
          sexe: _sexe,
          onSexe: (sexe) => setState(() => _sexe = sexe),
          onChange: () => setState(() {}),
        );
      case 1:
        if (_large) {
          // Races à gauche, classes à droite (chaque liste défile seule).
          return Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: _etapeRace()),
              VerticalDivider(
                width: 1,
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
              Expanded(child: _etapeClasse()),
            ],
          );
        }
        return _etapeRace();
      case 2:
        return _etapeClasse();
      case 3:
        return EtapeCaracteristiques(
          base: _base,
          race: _race,
          origine: _race?.origine(_origineId),
          onChange: (b) => setState(() => _base = b),
        );
      case 4:
        return EtapeCompetences(
          race: _race!,
          classe: _classe!,
          niveau: _niveau,
          rangsVoies: _rangsVoies,
          aptitudes: _aptitudes,
          catalogueAptitudes: ref.aptitudes,
          intFinale: FicheCalculee(
            personnage: _brouillon(),
            race: _race!,
            classe: _classe!,
          ).carac(Carac.intel),
          onChange: (r) => setState(() => _rangsVoies = r),
          onAptitudes: (a) => setState(() => _aptitudes = a),
        );
      default:
        final fiche = _ficheBrouillon;
        return EtapeRecapitulatif(
          fiche: fiche,
          inventaireBase: ObjetDuCatalogue.inventaireBase(
            _classe!,
            widget.referentiel.equipements,
          ),
          recevoirInventaire: _inventaireBase,
          onInventaire: (v) => setState(() => _inventaireBase = v),
          competences: fiche.competencesAcquises,
          entete: [
            // Choix des compétences de départ (gnome, rang 1 : arme ou
            // instrument, avec son nom).
            for (final c in fiche.competencesAcquises)
              if (c.competence.choix != null)
                CarteChoix(
                  nom: c.competence.nom,
                  origine: c.voie.nom,
                  choix: c.competence.choix!,
                  valeur: _choix[c.competence.choix!.cle],
                  onChoisir: (o) => setState(() {
                    _choix = {..._choix, c.competence.choix!.cle: o};
                    _precisions = {..._precisions}
                      ..remove(c.competence.choix!.cle);
                  }),
                  precision: _precisions[c.competence.choix!.cle] ?? '',
                  catalogue: widget.referentiel.equipements,
                  elements: (liste) => fiche.elementsChoix(
                    liste,
                    catalogue: widget.referentiel.equipements,
                    cle: c.competence.choix!.cle,
                  ),
                  onPrecision: (t) => setState(
                    () => _precisions = {
                      ..._precisions,
                      c.competence.choix!.cle: t,
                    },
                  ),
                ),
            // Objets donnés à personnaliser (description du porte-bonheur).
            for (final o in fiche.objetsARecevoir)
              if (o.objet['personnaliser'] == true)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: TextFormField(
                    key: Key('description-objet-${o.objet['nom']}'),
                    initialValue: _descriptions[o.cle] ?? '',
                    minLines: 1,
                    maxLines: 3,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      labelText: 'Description : ${o.objet['nom']} '
                          '(facultatif)',
                      hintText: 'À quoi ressemble-t-il ?',
                      helperText: 'Donné par ${o.competence}',
                      border: const OutlineInputBorder(),
                    ),
                    onChanged: (t) => _descriptions[o.cle] = t,
                  ),
                ),
          ],
          aptitudes: [
            for (final a in _aptitudes)
              (aptitude: ref.aptitude(a.id), acquise: a),
          ],
          pointsConserves: Progression.pointsRestants(
            niveau: _niveau,
            race: _race!,
            rangsVoies: _rangsVoies,
            aptitudes: _aptitudes.length,
          ),
        );
    }
  }

  Widget _etapeRace() => EtapeRace(
        races: widget.referentiel.races,
        race: _race,
        origineId: _origineId,
        optionPassifId: _optionPassifId,
        onRace: (r) => setState(() {
          if (r.id != _race?.id) {
            _race = r;
            _origineId = null;
            _optionPassifId = null;
            _choix = {};
            // Le nombre de points de compétence dépend de la race.
            _rangsVoies = {};
            _aptitudes = [];
          }
        }),
        onOrigine: (id) => setState(() => _origineId = id),
        onOptionPassif: (id) => setState(() {
          if (id != _optionPassifId) _choix = {};
          _optionPassifId = id;
        }),
        choix: _choix,
        onChoix: (cle, o) => setState(() => _choix = {..._choix, cle: o}),
      );

  Widget _etapeClasse() => EtapeClasse(
        classes: widget.referentiel.classes,
        race: _race,
        classe: _classe,
        onClasse: (c) => setState(() {
          if (c.id != _classe?.id) {
            _classe = c;
            _rangsVoies = {};
          }
        }),
      );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    _large = MediaQuery.sizeOf(context).width >= _largeurRaceEtClasse;
    final blocage = _blocage;
    final titres = _titresAffiches;
    final numero = _numeroAffiche;
    final cote = _large && _etapeEff == 1;

    return PopScope<void>(
      canPop: !_modifie || _enregistrement,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _confirmerAbandon();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Nouveau personnage'),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(68),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.person_outline,
                        size: 18,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          _resume.isEmpty
                              ? 'Aucun choix pour l\'instant'
                              : _resume,
                          key: const Key('resume-entete'),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: _resume.isEmpty
                                ? theme.colorScheme.onSurfaceVariant
                                : theme.colorScheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Étape ${numero + 1} sur ${titres.length} · '
                    '${titres[numero]}',
                    style: theme.textTheme.labelLarge,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  LinearProgressIndicator(
                    value: (numero + 1) / titres.length,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ],
              ),
            ),
          ),
        ),
        body: Center(
          child: ConstrainedBox(
            // Races et classes côte à côte : deux colonnes de 720 px.
            // Compétences : place pour le panneau « Déjà acquis ».
            constraints: BoxConstraints(
              maxWidth: cote
                  ? 1440
                  : _etapeEff == 4
                      ? kLargeurAvecResume
                      : 720,
            ),
            child: _contenuEtape(),
          ),
        ),
        bottomNavigationBar: SafeArea(
          child: Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              border: Border(
                top: BorderSide(color: theme.colorScheme.outlineVariant),
              ),
            ),
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            // heightFactor: 1 → la barre prend la hauteur de son contenu
            // (sans lui, Center s'étire sur tout l'écran et masque l'étape).
            child: Center(
              heightFactor: 1,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (blocage != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          blocage,
                          key: const Key('message-blocage'),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    // Les deux boutons se partagent la largeur : sur un petit
                    // écran (ou avec une grande police), le texte passe à la
                    // ligne au lieu de déborder.
                    Row(
                      children: [
                        if (_etapeEff > 0)
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _enregistrement ? null : _precedent,
                              icon: const Icon(Icons.arrow_back),
                              label: const Text('Précédent'),
                            ),
                          )
                        else
                          const Spacer(),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton.icon(
                            key: const Key('bouton-suivant'),
                            onPressed: blocage == null && !_enregistrement
                                ? _suivant
                                : null,
                            icon: Icon(
                              _dernierEtape ? Icons.check : Icons.arrow_forward,
                            ),
                            label: Text(
                              _dernierEtape ? 'Créer le personnage' : 'Suivant',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
