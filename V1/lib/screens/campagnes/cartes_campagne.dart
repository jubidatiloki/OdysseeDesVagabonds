import 'dart:async';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../data/image_carte.dart';
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
  String _nom(PionCarte p) {
    final s = widget.seance;
    if (s == null) return p.nom;
    for (final m in s.joueurs) {
      if (m.uid == p.id) return m.personnageNom;
    }
    for (final c in s.creatures) {
      if (c.id == p.id) return s.estMj ? c.nom : c.nomPublic;
    }
    return p.nom;
  }

  Widget _pion(PionCarte p) {
    final gere = _peutGerer(p);
    final enCours = _deplace == p.id;
    final widgetPion = Column(
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
            _nom(p),
            key: Key('nom-pion-${p.id}'),
            textAlign: TextAlign.center,
            softWrap: true,
            style: const TextStyle(color: Colors.white, fontSize: 11),
          ),
        ),
        const SizedBox(height: 2),
        IconePion(pion: p, rayon: 16, souligne: enCours),
      ],
    );
    if (!gere) return widgetPion;
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
              final pions = flux.data ?? const <PionCarte>[];
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
                  if (peutAjouter)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: FilledButton.tonalIcon(
                        key: const Key('ajouter-pion'),
                        onPressed: () => _ajouter(pions),
                        icon: const Icon(Icons.person_pin_circle_outlined),
                        label: const Text('Pion'),
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
    if (pion.personnage) {
      icone = AvatarClasse(
        nom: pion.nom,
        classeId: pion.classeId.isEmpty ? null : pion.classeId,
        raceId: pion.raceId.isEmpty ? null : pion.raceId,
        element: pion.element.isEmpty ? null : pion.element,
        rayon: rayon,
      );
    } else {
      final style = pion.famille.isEmpty
          ? null
          : styleFamille(pion.famille, theme.brightness);
      icone = Container(
        width: rayon * 2,
        height: rayon * 2,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: theme.colorScheme.surface,
          border: Border.all(
            color: pion.allie ? OdvCouleurs.green : OdvCouleurs.red,
            width: 2,
          ),
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
