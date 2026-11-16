import 'dart:async';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../data/image_carte.dart';
import '../../models/campagne.dart';
import '../../models/carte_campagne.dart';
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
/// ne coûte rien) ; zoomable.
class VueCarte extends StatefulWidget {
  const VueCarte({
    super.key,
    required this.contexte,
    required this.campagne,
    required this.carte,
  });

  final ContexteCampagnes contexte;
  final Campagne campagne;
  final CarteCampagne carte;

  @override
  State<VueCarte> createState() => _VueCarteState();
}

class _VueCarteState extends State<VueCarte> {
  late Future<Uint8List> _image = _lire();

  Future<Uint8List> _lire() {
    final s = widget.contexte.campagnes.serviceActuel;
    if (s == null) {
      return Future.error(const ErreurCampagne('Connecte-toi.'));
    }
    return s.lireImageCarte(widget.campagne, widget.carte);
  }

  @override
  void didUpdateWidget(VueCarte ancien) {
    super.didUpdateWidget(ancien);
    if (ancien.carte.id != widget.carte.id ||
        ancien.carte.octets != widget.carte.octets) {
      _image = _lire();
    }
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
          return InteractiveViewer(
            key: Key('vue-carte-${widget.carte.id}'),
            maxScale: 6,
            child: Center(
              child: Image.memory(
                octets,
                gaplessPlayback: true,
                errorBuilder: (_, __, ___) => const Text('Image illisible.'),
              ),
            ),
          );
        },
      );
}
