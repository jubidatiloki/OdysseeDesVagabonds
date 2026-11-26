import 'dart:async';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../data/image_carte.dart';
import '../../models/bonus_seance.dart';
import '../../models/campagne.dart';
import '../../models/carte_campagne.dart';
import '../../state/seance_controller.dart';
import '../../theme.dart';
import '../../widgets/cadre_classe.dart';
import '../../widgets/infos_creature.dart';
import '../../widgets/consultation.dart';
import 'campagnes_screen.dart';

/// Fichier choisi par le MJ : nom et contenu.
typedef FichierImage = ({String nom, List<int> octets});

/// Ouvre le sélecteur de fichiers (PNG ou JPEG).
Future<FichierImage?> choisirImage() async {
  final r = await FilePicker.platform.pickFiles(
    type: FileType.custom,
    allowedExtensions: const ['png', 'jpg', 'jpeg'],
    withData: true,
  );
  final f = r?.files.singleOrNull;
  final octets = f?.bytes;
  if (f == null || octets == null) return null;
  return (nom: f.name, octets: octets);
}

/// Cartes d'une campagne, côté MJ (16/11/2026) : consulter, ajouter,
/// renommer, supprimer ; pendant une séance, diffuser aux PJ.
class GestionCartes extends StatefulWidget {
  const GestionCartes({
    super.key,
    required this.contexte,
    required this.campagne,
    this.enSeance = false,
    this.choisirFichier = choisirImage,
  });

  final ContexteCampagnes contexte;
  final Campagne campagne;

  /// Pendant une séance : interrupteur « Diffuser aux PJ ».
  final bool enSeance;

  /// Sélecteur de fichier (remplacé dans les tests).
  final Future<FichierImage?> Function() choisirFichier;

  @override
  State<GestionCartes> createState() => _GestionCartesState();
}

class _GestionCartesState extends State<GestionCartes> {
  /// Un seul abonnement (les informations des cartes, pas les images).
  late final Stream<List<CarteCampagne>>? _cartes =
      widget.contexte.campagnes.serviceActuel?.ecouterCartes(widget.campagne);

  /// Ajout en cours : étape affichée (réduction, envoi) ; `null` : aucun.
  String? _etape;
  bool get _occupe => _etape != null;

  static String _poids(int octets) => octets >= 1024 * 1024
      ? '${(octets / (1024 * 1024)).toStringAsFixed(1).replaceAll('.', ',')} Mo'
      : '${(octets / 1024).round()} Ko';

  void _message(String texte) => ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(texte)));

  Future<String?> _demanderNom(String titre, String initial) =>
      showDialog<String>(
        context: context,
        builder: (context) => _DialogueNom(titre: titre, initial: initial),
      );

  Future<void> _ajouter() async {
    final f = await widget.choisirFichier();
    if (f == null || !mounted) return;
    final nom = await _demanderNom(
      'Nom de la carte',
      CarteCampagne.nomPropre(f.nom),
    );
    if (nom == null || !mounted) return;
    final propre = CarteCampagne.nomPropre(nom);
    setState(() => _etape =
        '« $propre » : réduction de l\'image (${_poids(f.octets.length)})…');
    String? erreur;
    try {
      final image = await ImageCarte.preparer(
        f.octets is Uint8List
            ? f.octets as Uint8List
            : Uint8List.fromList(f.octets),
      );
      if (!mounted) return;
      setState(() => _etape =
          '« $propre » : envoi en ligne (${_poids(image.jpeg.length)})…');
      erreur = await widget.contexte.campagnes.agir(
        (s) => s.ajouterCarte(
          widget.campagne,
          nom: nom,
          image: image.jpeg,
          largeur: image.largeur,
          hauteur: image.hauteur,
        ),
      );
    } on ErreurCampagne catch (e) {
      erreur = e.message;
    }
    if (!mounted) return;
    setState(() => _etape = null);
    _message(erreur ?? 'Carte « $propre » ajoutée.');
  }

  Future<void> _renommer(CarteCampagne c) async {
    final nom = await _demanderNom('Renommer la carte', c.nom);
    if (nom == null || nom.trim() == c.nom) return;
    final erreur = await widget.contexte.campagnes
        .agir((s) => s.modifierCarte(widget.campagne, c.copie(nom: nom)));
    if (erreur != null && mounted) _message(erreur);
  }

  Future<void> _supprimer(CarteCampagne c) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Supprimer « ${c.nom} » ?'),
        content: Text(c.diffusee
            ? 'Elle est diffusée : les PJ ne la verront plus. '
                'C\'est définitif.'
            : 'C\'est définitif.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            key: const Key('confirmer-suppression-carte'),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    final erreur = await widget.contexte.campagnes
        .agir((s) => s.supprimerCarte(widget.campagne, c));
    if (mounted) _message(erreur ?? 'Carte supprimée.');
  }

  Future<void> _diffuser(CarteCampagne c, bool oui) async {
    final erreur = await widget.contexte.campagnes
        .agir((s) => s.modifierCarte(widget.campagne, c.copie(diffusee: oui)));
    if (erreur != null && mounted) _message(erreur);
  }

  @override
  Widget build(BuildContext context) {
    final flux = _cartes;
    if (flux == null) {
      return const Center(
          child: TexteAVenir('Connecte-toi pour gérer '
              'les cartes.'));
    }
    final theme = Theme.of(context);
    return StreamBuilder<List<CarteCampagne>>(
      stream: flux,
      builder: (context, instantane) {
        final cartes = instantane.data ?? const <CarteCampagne>[];
        final plein = cartes.length >= CarteCampagne.maxParCampagne;
        return LargeurLimitee(
          child: ListView(
            key: const Key('gestion-cartes'),
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                widget.enSeance
                    ? 'Diffuse une carte : elle apparaît dans la liste des PJ.'
                    : 'Plans, régions, donjons : importe tes cartes (PNG ou '
                        'JPEG). Elles se diffusent aux PJ pendant la séance.',
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Cartes (${cartes.length}/'
                      '${CarteCampagne.maxParCampagne})',
                      style: theme.textTheme.titleMedium,
                    ),
                  ),
                  FilledButton.icon(
                    key: const Key('ajouter-carte'),
                    onPressed: _occupe || plein ? null : _ajouter,
                    icon: _occupe
                        ? const SizedBox.square(
                            dimension: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.add_photo_alternate_outlined),
                    label: Text(_occupe ? 'En cours…' : 'Ajouter'),
                  ),
                ],
              ),
              // Ajout en cours : étape et barre d'attente (16/11/2026).
              if (_etape case final etape?)
                Card(
                  key: const Key('envoi-carte'),
                  margin: const EdgeInsets.only(top: 8),
                  color: theme.colorScheme.secondaryContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.cloud_upload_outlined,
                              color: theme.colorScheme.onSecondaryContainer,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                etape,
                                key: const Key('etape-envoi-carte'),
                                style: theme.textTheme.bodyMedium,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const LinearProgressIndicator(),
                        const SizedBox(height: 4),
                        Text(
                          'Reste sur cette page jusqu\'à la fin.',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ),
              if (plein)
                Text(
                  'Nombre maximum atteint : supprime une carte pour en '
                  'ajouter une.',
                  style: TextStyle(color: theme.colorScheme.error),
                ),
              const SizedBox(height: 8),
              if (cartes.isEmpty)
                const TexteAVenir('Aucune carte pour l\'instant.'),
              for (final c in cartes)
                Card(
                  key: Key('ligne-carte-${c.id}'),
                  child: ListTile(
                    leading: Icon(
                      Icons.map_outlined,
                      color: c.diffusee && widget.enSeance
                          ? theme.colorScheme.primary
                          : null,
                    ),
                    title: Text(c.nom, overflow: TextOverflow.ellipsis),
                    subtitle: Text(
                      widget.enSeance && c.diffusee
                          ? '${c.resume} · diffusée'
                          : c.resume,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onTap: () => ouvrirCarte(
                      context,
                      widget.contexte,
                      widget.campagne,
                      c,
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (widget.enSeance)
                          Tooltip(
                            message: c.diffusee
                                ? 'Retirer aux PJ'
                                : 'Diffuser aux PJ',
                            child: Switch(
                              key: Key('diffuser-${c.id}'),
                              value: c.diffusee,
                              onChanged: (v) => _diffuser(c, v),
                            ),
                          ),
                        PopupMenuButton<String>(
                          key: Key('menu-carte-${c.id}'),
                          tooltip: 'Plus',
                          onSelected: (v) =>
                              v == 'renommer' ? _renommer(c) : _supprimer(c),
                          itemBuilder: (_) => const [
                            PopupMenuItem(
                              key: Key('renommer-carte'),
                              value: 'renommer',
                              child: Text('Renommer'),
                            ),
                            PopupMenuItem(
                              key: Key('supprimer-carte'),
                              value: 'supprimer',
                              child: Text('Supprimer'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

/// Nom d'une carte (ajout, renommage).
class _DialogueNom extends StatefulWidget {
  const _DialogueNom({required this.titre, required this.initial});

  final String titre;
  final String initial;

  @override
  State<_DialogueNom> createState() => _DialogueNomState();
}

class _DialogueNomState extends State<_DialogueNom> {
  late final _champ = TextEditingController(text: widget.initial);

  @override
  void dispose() {
    _champ.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: Text(widget.titre),
        content: TextField(
          key: const Key('nom-carte'),
          controller: _champ,
          autofocus: true,
          maxLength: CarteCampagne.longueurNomMax,
          decoration: const InputDecoration(labelText: 'Nom'),
          onSubmitted: (v) => Navigator.pop(context, v),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          FilledButton(
            key: const Key('valider-nom-carte'),
            onPressed: () => Navigator.pop(context, _champ.text),
            child: const Text('Valider'),
          ),
        ],
      );
}

/// Ouvre une carte en grand (zoom avec deux doigts ou la molette).
void ouvrirCarte(
  BuildContext context,
  ContexteCampagnes contexte,
  Campagne campagne,
  CarteCampagne carte,
) =>
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => Scaffold(
          appBar: AppBar(title: Text(carte.nom)),
          body: VueCarte(
            contexte: contexte,
            campagne: campagne,
            carte: carte,
          ),
        ),
      ),
    );

/// Image d'une carte, lue une seule fois puis gardée en mémoire (la relire
/// ne coûte rien) ; zoomable. Pions des personnages et des créatures posés
/// dessus (20/11/2026) : [seance] donnée, on peut en ajouter ; on déplace
/// (glisser) et retire (toucher) ceux qu'on a le droit de gérer.
class VueCarte extends StatefulWidget {
  const VueCarte({
    super.key,
    required this.contexte,
    required this.campagne,
    required this.carte,
    this.seance,
  });

  final ContexteCampagnes contexte;
  final Campagne campagne;
  final CarteCampagne carte;

  /// Séance en cours : personnages et créatures qu'on peut poser.
  final SeanceController? seance;

  @override
  State<VueCarte> createState() => _VueCarteState();
}

class _VueCarteState extends State<VueCarte> {
  late Future<Uint8List> _image = _lire();
  late Stream<List<PionCarte>>? _pions = _ecouterPions();

  /// Zone de l'image : sert à convertir la position du doigt (zoom compris).
  final _zone = GlobalKey();

  /// Pion en cours de déplacement : sa position provisoire.
  String? _deplace;
  Offset _position = Offset.zero;

  /// Grille d'échelle (22/11/2026) : réglage en cours, montré tout de suite
  /// (enregistré en fin de glissement du curseur).
  late bool _grille = widget.carte.grille;
  late int _colonnes = widget.carte.colonnes;
  late int _epaisseur = widget.carte.epaisseur;
  late int _decalageX = widget.carte.decalageX;
  late int _decalageY = widget.carte.decalageY;

  /// MJ : panneau de réglage de la grille ouvert.
  var _reglages = false;

  bool get _estMj => _campagne.estMj(widget.contexte.campagnes.uid ?? '');

  Future<void> _enregistrerGrille() async {
    final s = widget.contexte.campagnes.serviceActuel;
    if (s == null) return;
    await _agir(() => s.modifierCarte(
          widget.campagne,
          widget.carte.copie(
            grille: _grille,
            colonnes: _colonnes,
            epaisseur: _epaisseur,
            decalageX: _decalageX,
            decalageY: _decalageY,
          ),
        ));
  }

  Future<Uint8List> _lire() {
    final s = widget.contexte.campagnes.serviceActuel;
    if (s == null) {
      return Future.error(const ErreurCampagne('Connecte-toi.'));
    }
    return s.lireImageCarte(widget.campagne, widget.carte);
  }

  Stream<List<PionCarte>>? _ecouterPions() =>
      widget.contexte.campagnes.serviceActuel
          ?.ecouterPions(widget.campagne, widget.carte);

  @override
  void didUpdateWidget(VueCarte ancien) {
    super.didUpdateWidget(ancien);
    if (ancien.carte.id != widget.carte.id ||
        ancien.carte.octets != widget.carte.octets) {
      _image = _lire();
    }
    if (ancien.carte.id != widget.carte.id) _pions = _ecouterPions();
    // Grille changée ailleurs (autre appareil, autre carte).
    if (ancien.carte.id != widget.carte.id ||
        ancien.carte.grille != widget.carte.grille ||
        ancien.carte.colonnes != widget.carte.colonnes ||
        ancien.carte.epaisseur != widget.carte.epaisseur ||
        ancien.carte.decalageX != widget.carte.decalageX ||
        ancien.carte.decalageY != widget.carte.decalageY) {
      _grille = widget.carte.grille;
      _colonnes = widget.carte.colonnes;
      _epaisseur = widget.carte.epaisseur;
      _decalageX = widget.carte.decalageX;
      _decalageY = widget.carte.decalageY;
    }
  }

  /// Campagne à jour (permissions changées pendant la séance).
  Campagne get _campagne =>
      widget.contexte.campagnes.parId(widget.campagne.id) ?? widget.campagne;

  bool _peutGerer(PionCarte p) {
    final s = widget.seance;
    if (s != null) return s.peutGererPion(p);
    final uid = widget.contexte.campagnes.uid ?? '';
    return _campagne.estMj(uid) ||
        _campagne.parametres
            .pjGerePion(uid, (proprietaire: p.proprietaire, allie: p.allie));
  }

  Future<void> _agir(Future<void> Function() action) async {
    final erreur = await widget.contexte.campagnes.agir((_) => action());
    if (erreur != null && mounted) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(erreur)));
    }
  }

  Future<void> _ajouter(List<PionCarte> poses) async {
    final deja = {for (final p in poses) p.id};
    final libres = [
      for (final p in widget.seance?.pionsPossibles ?? const <PionCarte>[])
        if (!deja.contains(p.id)) p,
    ];
    final choisi = await showDialog<PionCarte>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Poser un pion'),
        children: [
          if (libres.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('Tous les pions que tu peux gérer sont déjà sur '
                  'la carte.'),
            ),
          for (final p in libres)
            SimpleDialogOption(
              key: Key('poser-pion-${p.id}'),
              onPressed: () => Navigator.pop(context, p),
              child: Row(
                children: [
                  IconePion(pion: p, rayon: 14),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(p.nom, overflow: TextOverflow.ellipsis),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
    if (choisi == null) return;
    final s = widget.contexte.campagnes.serviceActuel;
    if (s == null) return;
    // Au centre de la carte ; on le glisse ensuite à sa place.
    await _agir(() => s.placerPion(widget.campagne, widget.carte, choisi));
  }

  Future<void> _menu(PionCarte p, Offset global) async {
    final choix = await showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(global.dx, global.dy, global.dx, 0),
      items: [
        PopupMenuItem(
          key: Key('retirer-pion-${p.id}'),
          value: 'retirer',
          child: Text('Retirer « ${p.nom} » de la carte'),
        ),
      ],
    );
    if (choix != 'retirer') return;
    final s = widget.contexte.campagnes.serviceActuel;
    if (s == null) return;
    await _agir(() => s.retirerPion(widget.campagne, widget.carte, p));
  }

  /// MJ (22/11/2026) : grille d'échelle de la carte (affichée ou non,
  /// nombre de cases sur la largeur).
  Widget _panneauGrille(BuildContext context) {
    final theme = Theme.of(context);
    final c = widget.carte;
    final lignes = c.largeur > 0 && c.hauteur > 0
        ? (_colonnes * c.hauteur / c.largeur).round()
        : _colonnes;
    return Card(
      key: const Key('panneau-grille'),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 4, 4, 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text('Grille', style: theme.textTheme.titleSmall),
                ),
                IconButton(
                  tooltip: 'Fermer',
                  onPressed: () => setState(() => _reglages = false),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            // Réglable même cachée aux PJ (22/11/2026) : le MJ la voit tant
            // que ce panneau est ouvert.
            SwitchListTile(
              key: const Key('grille-affichee'),
              contentPadding: EdgeInsets.zero,
              dense: true,
              title: const Text('Grille visible des PJ'),
              subtitle: Text(_grille
                  ? 'Affichée pour tous, pour donner l\'échelle'
                  : 'Cachée aux PJ (tu la vois pendant le réglage)'),
              value: _grille,
              onChanged: (v) {
                setState(() => _grille = v);
                _enregistrerGrille();
              },
            ),
            Text(
              '$_colonnes cases sur la largeur · $lignes sur la hauteur',
              key: const Key('grille-cases'),
              style: theme.textTheme.bodySmall,
            ),
            Slider(
              key: const Key('grille-curseur'),
              value: _colonnes.toDouble(),
              min: CarteCampagne.colonnesMin.toDouble(),
              max: CarteCampagne.colonnesMax.toDouble(),
              divisions: CarteCampagne.colonnesMax - CarteCampagne.colonnesMin,
              label: '$_colonnes',
              onChanged: (v) => setState(() => _colonnes = v.round()),
              onChangeEnd: (_) => _enregistrerGrille(),
            ),
            // Épaisseur des traits (22/11/2026).
            Text(
              'Épaisseur des traits : $_epaisseur',
              key: const Key('grille-epaisseur-texte'),
              style: theme.textTheme.bodySmall,
            ),
            Slider(
              key: const Key('grille-epaisseur'),
              value: _epaisseur.toDouble(),
              min: 1,
              max: CarteCampagne.epaisseurMax.toDouble(),
              divisions: CarteCampagne.epaisseurMax - 1,
              label: '$_epaisseur',
              onChanged: (v) => setState(() => _epaisseur = v.round()),
              onChangeEnd: (_) => _enregistrerGrille(),
            ),
            // Décalage horizontal et vertical (26/11/2026), en pourcentage
            // d'une case : pour caler la grille sur celle de l'image.
            Text(
              'Décalage horizontal : $_decalageX % d\'une case',
              key: const Key('grille-decalage-x-texte'),
              style: theme.textTheme.bodySmall,
            ),
            Slider(
              key: const Key('grille-decalage-x'),
              value: _decalageX.toDouble(),
              max: CarteCampagne.decalageMax.toDouble(),
              divisions: CarteCampagne.decalageMax,
              label: '$_decalageX %',
              onChanged: (v) => setState(() => _decalageX = v.round()),
              onChangeEnd: (_) => _enregistrerGrille(),
            ),
            Text(
              'Décalage vertical : $_decalageY % d\'une case',
              key: const Key('grille-decalage-y-texte'),
              style: theme.textTheme.bodySmall,
            ),
            Slider(
              key: const Key('grille-decalage-y'),
              value: _decalageY.toDouble(),
              max: CarteCampagne.decalageMax.toDouble(),
              divisions: CarteCampagne.decalageMax,
              label: '$_decalageY %',
              onChanged: (v) => setState(() => _decalageY = v.round()),
              onChangeEnd: (_) => _enregistrerGrille(),
            ),
          ],
        ),
      ),
    );
  }

  /// Position relative (0 à 1) du doigt sur l'image.
  Offset? _relative(Offset global) {
    final box = _zone.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return null;
    final l = box.globalToLocal(global);
    return Offset(
      (l.dx / box.size.width).clamp(0.0, 1.0),
      (l.dy / box.size.height).clamp(0.0, 1.0),
    );
  }

  /// Nom affiché : celui de la séance, à jour (créatures numérotées « 2 »,
  /// personnage renommé) ; sinon, celui enregistré à la pose.
  /// Pion lié à son personnage ou sa créature (21/11/2026) : en séance, son
  /// nom, son camp et son icône viennent de la partie, à jour ; une
  /// créature retirée de la partie, ou cachée aux PJ, n'a plus de pion
  /// visible (`null`). Hors séance : le pion tel qu'il a été posé.
  PionCarte? _aJour(PionCarte p) {
    final s = widget.seance;
    if (s == null) return p;
    if (p.personnage) {
      for (final m in s.joueurs) {
        if (m.uid == p.id) return s.pionDe(m).deplace(p.x, p.y);
      }
      return p;
    }
    for (final c in s.creatures) {
      if (c.id != p.id) continue;
      final q = s.pionCreature(c).deplace(p.x, p.y);
      // Le MJ voit le vrai nom.
      return s.estMj && q.nom != c.nom
          ? PionCarte.depuisJson(q.id, q.versJson()..['nom'] = c.nom)
          : q;
    }
    return null;
  }

  /// MJ : créature dont la carte est cachée aux PJ (pion estompé).
  bool _cacheeAuxPj(PionCarte p) =>
      (widget.seance?.estMj ?? false) &&
      (widget.seance?.creatures.any((c) => c.id == p.id && c.cachee) ?? false);

  /// Bonus, malus et afflictions visibles du personnage ou de la créature
  /// du pion (en séance).
  List<BonusSeance> _effets(PionCarte p) =>
      widget.seance?.bonusVisibles(p.id) ?? const [];

  /// Créature de la partie morte (0 PV, ou « vaincu » vu d'un PJ).
  bool _morte(PionCarte p) =>
      widget.seance?.creatures.any((c) => c.id == p.id && c.morte) ?? false;

  Widget _pion(PionCarte p) {
    final gere = _peutGerer(p);
    final enCours = _deplace == p.id;
    final widgetPion = Opacity(
      opacity: _cacheeAuxPj(p) ? 0.45 : 1,
      child: _contenuPion(p, enCours),
    );
    if (!gere) return widgetPion;
    return _deplacable(p, widgetPion);
  }

  Widget _contenuPion(PionCarte p, bool enCours) {
    return Column(
      key: Key('pion-${p.id}'),
      mainAxisSize: MainAxisSize.min,
      children: [
        // Nom en entier, sur plusieurs lignes si besoin (20/11/2026).
        Container(
          constraints: const BoxConstraints(maxWidth: 120),
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            p.nom,
            key: Key('nom-pion-${p.id}'),
            textAlign: TextAlign.center,
            softWrap: true,
            style: const TextStyle(color: Colors.white, fontSize: 11),
          ),
        ),
        const SizedBox(height: 2),
        // Effets actifs à côté (21/11/2026) ; croix rouge si la créature
        // est morte.
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                IconePion(pion: p, rayon: 16, souligne: enCours),
                if (_morte(p))
                  Positioned.fill(
                    child: Icon(
                      Icons.close,
                      key: Key('pion-mort-${p.id}'),
                      size: 34,
                      color: OdvCouleurs.red,
                    ),
                  ),
              ],
            ),
            if (_effets(p) case final effets when effets.isNotEmpty) ...[
              const SizedBox(width: 2),
              Container(
                key: Key('effets-pion-${p.id}'),
                padding: const EdgeInsets.all(1),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (final b in effets.take(4))
                      Tooltip(
                        message: '${b.nom} ${b.effet} · ${b.dureeTexte}',
                        child: Icon(
                          b.estEtat
                              ? Icons.warning_amber_rounded
                              : b.valeur >= 0
                                  ? Icons.arrow_upward
                                  : Icons.arrow_downward,
                          key: Key('effet-pion-${b.id}'),
                          size: 13,
                          color: b.estEtat || b.valeur < 0
                              ? OdvCouleurs.lightRed
                              : OdvCouleurs.lightGreen,
                        ),
                      ),
                    if (effets.length > 4)
                      Text(
                        '+${effets.length - 4}',
                        style:
                            const TextStyle(color: Colors.white, fontSize: 9),
                      ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  /// Pion qu'on a le droit de gérer : glisser pour le déplacer, toucher
  /// pour le retirer.
  Widget _deplacable(PionCarte p, Widget widgetPion) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapUp: (d) => _menu(p, d.globalPosition),
      onPanStart: (d) {
        final r = _relative(d.globalPosition);
        if (r != null) {
          setState(() {
            _deplace = p.id;
            _position = r;
          });
        }
      },
      onPanUpdate: (d) {
        final r = _relative(d.globalPosition);
        if (r != null) setState(() => _position = r);
      },
      onPanEnd: (_) async {
        final pos = _position;
        final s = widget.contexte.campagnes.serviceActuel;
        if (s != null) {
          await _agir(() => s.placerPion(
              widget.campagne, widget.carte, p.deplace(pos.dx, pos.dy)));
        }
        if (mounted) setState(() => _deplace = null);
      },
      child: widgetPion,
    );
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<Uint8List>(
        future: _image,
        builder: (context, instantane) {
          if (instantane.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Carte indisponible : ${instantane.error}',
                  key: const Key('erreur-carte'),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          final octets = instantane.data;
          if (octets == null) {
            return const Center(child: CircularProgressIndicator());
          }
          final c = widget.carte;
          final ratio =
              c.largeur > 0 && c.hauteur > 0 ? c.largeur / c.hauteur : 4 / 3;
          return StreamBuilder<List<PionCarte>>(
            stream: _pions,
            builder: (context, flux) {
              final pions = [
                for (final p in flux.data ?? const <PionCarte>[])
                  if (_aJour(p) case final q?) q,
              ];
              final peutAjouter =
                  widget.seance?.pionsPossibles.isNotEmpty ?? false;
              return Stack(
                children: [
                  Positioned.fill(
                    child: InteractiveViewer(
                      key: Key('vue-carte-${widget.carte.id}'),
                      maxScale: 6,
                      child: Center(
                        child: AspectRatio(
                          aspectRatio: ratio,
                          child: LayoutBuilder(
                            builder: (context, taille) => Stack(
                              key: _zone,
                              clipBehavior: Clip.none,
                              children: [
                                Positioned.fill(
                                  child: Image.memory(
                                    octets,
                                    fit: BoxFit.fill,
                                    gaplessPlayback: true,
                                    errorBuilder: (_, __, ___) => const Center(
                                        child: Text('Image illisible.')),
                                  ),
                                ),
                                // Grille d'échelle, sous les pions.
                                if (_grille || (_estMj && _reglages))
                                  Positioned.fill(
                                    child: IgnorePointer(
                                      child: CustomPaint(
                                        key: const Key('grille-carte'),
                                        painter: PeintreGrille(
                                          _colonnes,
                                          epaisseur: _epaisseur,
                                          decalageX: _decalageX,
                                          decalageY: _decalageY,
                                        ),
                                      ),
                                    ),
                                  ),
                                for (final p in pions)
                                  Positioned(
                                    left: (_deplace == p.id
                                            ? _position.dx
                                            : p.x) *
                                        taille.maxWidth,
                                    top: (_deplace == p.id
                                            ? _position.dy
                                            : p.y) *
                                        taille.maxHeight,
                                    child: FractionalTranslation(
                                      translation: const Offset(-0.5, -0.7),
                                      child: _pion(p),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Boutons en haut à droite : pions, réglages du MJ.
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (peutAjouter)
                          FilledButton.tonalIcon(
                            key: const Key('ajouter-pion'),
                            onPressed: () => _ajouter(pions),
                            icon: const Icon(Icons.person_pin_circle_outlined),
                            label: const Text('Pion'),
                          ),
                        if (_estMj) ...[
                          const SizedBox(width: 6),
                          IconButton.filledTonal(
                            key: const Key('reglages-carte'),
                            tooltip: 'Réglages de la carte (grille)',
                            isSelected: _reglages,
                            onPressed: () =>
                                setState(() => _reglages = !_reglages),
                            icon: const Icon(Icons.grid_on),
                          ),
                        ],
                      ],
                    ),
                  ),
                  // MJ : panneau de réglage de la grille, à droite.
                  if (_estMj && _reglages)
                    Positioned(
                      top: 56,
                      right: 8,
                      width: 280,
                      bottom: 8,
                      // Défile si la carte est basse (26/11/2026 : 5 réglages).
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: SingleChildScrollView(
                          child: _panneauGrille(context),
                        ),
                      ),
                    ),
                ],
              );
            },
          );
        },
      );
}

/// Icône d'un pion (20/11/2026) : celle du personnage comme sur l'écran
/// principal, ou celle de la famille de la créature (contour vert : allié,
/// rouge : ennemi).
/// Grille d'échelle d'une carte (22/11/2026) : cases carrées, [colonnes]
/// sur la largeur ; traits fins, clairs et soulignés de sombre pour se voir
/// sur toutes les images.
class PeintreGrille extends CustomPainter {
  const PeintreGrille(
    this.colonnes, {
    this.epaisseur = 1,
    this.decalageX = 0,
    this.decalageY = 0,
  });

  final int colonnes;

  /// Décalage des traits, en pourcentage d'une case (26/11/2026).
  final int decalageX;
  final int decalageY;

  /// Épaisseur des traits (1 : fins).
  final int epaisseur;

  @override
  void paint(Canvas canvas, Size size) {
    if (colonnes <= 0 || size.width <= 0) return;
    final pas = size.width / colonnes;
    final sombre = Paint()
      ..color = Colors.black.withValues(alpha: 0.35)
      ..strokeWidth = 1.2 + 0.8 * epaisseur;
    final clair = Paint()
      ..color = Colors.white.withValues(alpha: 0.55)
      ..strokeWidth = 0.8 * epaisseur;
    final x0 = pas * decalageX / 100;
    final y0 = pas * decalageY / 100;
    for (final p in [sombre, clair]) {
      for (var x = x0; x < size.width - 0.5; x += pas) {
        if (x < 0.5) continue;
        canvas.drawLine(Offset(x, 0), Offset(x, size.height), p);
      }
      for (var y = y0; y < size.height - 0.5; y += pas) {
        if (y < 0.5) continue;
        canvas.drawLine(Offset(0, y), Offset(size.width, y), p);
      }
    }
  }

  @override
  bool shouldRepaint(PeintreGrille ancien) =>
      ancien.colonnes != colonnes ||
      ancien.epaisseur != epaisseur ||
      ancien.decalageX != decalageX ||
      ancien.decalageY != decalageY;
}

/// Couleur du contour d'un pion selon son camp (21/11/2026) : vert pour
/// les PJ et leurs alliés, gris pour les neutres, rouge pour les ennemis.
Color couleurCampPion(PionCarte pion) => pion.personnage || pion.allie
    ? OdvCouleurs.green
    : pion.neutre
        ? OdvCouleurs.grey
        : OdvCouleurs.red;

class IconePion extends StatelessWidget {
  const IconePion({
    super.key,
    required this.pion,
    this.rayon = 16,
    this.souligne = false,
  });

  final PionCarte pion;
  final double rayon;

  /// En cours de déplacement : halo doré.
  final bool souligne;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final Widget icone;
    final camp = couleurCampPion(pion);
    if (pion.personnage) {
      // Anneau du camp autour de l'icône du personnage.
      icone = Container(
        key: Key('contour-pion-${pion.id}'),
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: camp, width: 2.5),
        ),
        child: AvatarClasse(
          nom: pion.nom,
          classeId: pion.classeId.isEmpty ? null : pion.classeId,
          raceId: pion.raceId.isEmpty ? null : pion.raceId,
          element: pion.element.isEmpty ? null : pion.element,
          rayon: rayon,
        ),
      );
    } else {
      final style = pion.famille.isEmpty
          ? null
          : styleFamille(pion.famille, theme.brightness);
      icone = Container(
        key: Key('contour-pion-${pion.id}'),
        width: rayon * 2,
        height: rayon * 2,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: theme.colorScheme.surface,
          border: Border.all(color: camp, width: 2.5),
        ),
        child: Icon(
          style?.icone ?? Icons.pets_outlined,
          size: rayon * 1.1,
          color: style?.couleur ?? theme.colorScheme.primary,
        ),
      );
    }
    if (!souligne) return icone;
    return DecoratedBox(
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: OdvCouleurs.or, blurRadius: 10)],
      ),
      child: icone,
    );
  }
}
