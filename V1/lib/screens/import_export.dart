import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/echange_personnage.dart';
import '../data/referentiel.dart';
import '../models/personnage.dart';
import '../state/personnages_controller.dart';

void _message(ScaffoldMessengerState messenger, String texte) {
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(texte)));
}

// ---------------------------------------------------------------------------
// Export
// ---------------------------------------------------------------------------

/// Propose d'exporter le personnage : fichier .json ou texte copié.
Future<void> exporterPersonnage(BuildContext context, Personnage p) async {
  final choix = await showModalBottomSheet<String>(
    context: context,
    showDragHandle: true,
    builder: (context) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: Text('Exporter ${p.nom}'),
            subtitle: const Text(
              'Pour le sauvegarder, le partager ou le transférer sur un '
              'autre appareil.',
            ),
          ),
          ListTile(
            key: const Key('export-fichier'),
            leading: const Icon(Icons.save_alt),
            title: const Text('Enregistrer un fichier .json'),
            subtitle: Text(EchangePersonnage.nomFichier(p)),
            onTap: () => Navigator.of(context).pop('fichier'),
          ),
          ListTile(
            key: const Key('export-copier'),
            leading: const Icon(Icons.copy),
            title: const Text('Copier le texte'),
            subtitle: const Text('À coller dans un message, un e-mail…'),
            onTap: () => Navigator.of(context).pop('copier'),
          ),
        ],
      ),
    ),
  );
  if (choix == null || !context.mounted) return;
  final messenger = ScaffoldMessenger.of(context);
  final texte = EchangePersonnage.exporter(p);

  if (choix == 'copier') {
    await Clipboard.setData(ClipboardData(text: texte));
    _message(messenger, '${p.nom} copié dans le presse-papiers.');
    return;
  }

  try {
    final nom = EchangePersonnage.nomFichier(p);
    final chemin = await FilePicker.platform.saveFile(
      dialogTitle: 'Exporter ${p.nom}',
      fileName: nom,
      type: FileType.custom,
      allowedExtensions: const ['json'],
      bytes: utf8.encode(texte),
    );
    if (kIsWeb) {
      _message(messenger, 'Téléchargement de $nom lancé.');
    } else if (chemin != null) {
      _message(messenger, 'Personnage exporté : $chemin');
    }
  } catch (e) {
    _message(
      messenger,
      'Impossible d\'enregistrer le fichier ($e). '
      'Utilise « Copier le texte » à la place.',
    );
  }
}

// ---------------------------------------------------------------------------
// Import
// ---------------------------------------------------------------------------

/// Importe un personnage depuis un fichier .json ou un texte collé.
/// Renvoie le personnage ajouté (ou `null` si annulé / en erreur).
Future<Personnage?> importerPersonnage(
  BuildContext context, {
  required Referentiel referentiel,
  required PersonnagesController controller,
}) async {
  final choix = await showModalBottomSheet<String>(
    context: context,
    showDragHandle: true,
    builder: (context) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const ListTile(
            title: Text('Importer un personnage'),
            subtitle: Text('Depuis un export de L\'odyssée des vagabonds.'),
          ),
          ListTile(
            key: const Key('import-fichier'),
            leading: const Icon(Icons.file_open_outlined),
            title: const Text('Ouvrir un fichier .json'),
            onTap: () => Navigator.of(context).pop('fichier'),
          ),
          ListTile(
            key: const Key('import-texte'),
            leading: const Icon(Icons.content_paste),
            title: const Text('Coller le texte'),
            onTap: () => Navigator.of(context).pop('texte'),
          ),
        ],
      ),
    ),
  );
  if (choix == null || !context.mounted) return null;
  final messenger = ScaffoldMessenger.of(context);

  String? texte;
  if (choix == 'texte') {
    texte = await showDialog<String>(
      context: context,
      builder: (context) => const _DialogueCollerTexte(),
    );
  } else {
    try {
      final resultat = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: const ['json'],
        withData: true,
      );
      final bytes = resultat?.files.single.bytes;
      if (bytes != null) texte = utf8.decode(bytes);
    } catch (e) {
      _message(
        messenger,
        'Impossible d\'ouvrir le fichier ($e). '
        'Utilise « Coller le texte » à la place.',
      );
      return null;
    }
  }
  if (texte == null || texte.trim().isEmpty || !context.mounted) return null;

  final lu = _lire(texte, referentiel, messenger);
  if (lu == null) return null;
  var importe = lu;

  // Le personnage existe déjà sur cet appareil ?
  final existant = controller.parId(importe.id);
  if (existant != null) {
    final decision = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${existant.nom} existe déjà'),
        content: const Text(
          'Remplacer le personnage actuel par celui du fichier, ou garder '
          'les deux ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          OutlinedButton(
            key: const Key('import-copie'),
            onPressed: () => Navigator.of(context).pop('copie'),
            child: const Text('Garder les deux'),
          ),
          FilledButton(
            key: const Key('import-remplacer'),
            onPressed: () => Navigator.of(context).pop('remplacer'),
            child: const Text('Remplacer'),
          ),
        ],
      ),
    );
    if (decision == null) return null;
    if (decision == 'copie') importe = EchangePersonnage.copie(importe);
  }

  EchangePersonnage.journaliserImport(importe);
  await controller.sauvegarder(importe);
  _message(messenger, '${importe.nom} a été importé.');
  return importe;
}

Personnage? _lire(
  String texte,
  Referentiel referentiel,
  ScaffoldMessengerState messenger,
) {
  try {
    return EchangePersonnage.lire(texte, referentiel);
  } on ErreurImport catch (e) {
    _message(messenger, e.message);
    return null;
  }
}

class _DialogueCollerTexte extends StatefulWidget {
  const _DialogueCollerTexte();

  @override
  State<_DialogueCollerTexte> createState() => _DialogueCollerTexteState();
}

class _DialogueCollerTexteState extends State<_DialogueCollerTexte> {
  final _controleur = TextEditingController();

  @override
  void dispose() {
    _controleur.dispose();
    super.dispose();
  }

  Future<void> _coller() async {
    final donnees = await Clipboard.getData(Clipboard.kTextPlain);
    final t = donnees?.text;
    if (t != null && mounted) setState(() => _controleur.text = t);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Coller le personnage'),
      content: SizedBox(
        width: 480,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              key: const Key('champ-import-texte'),
              controller: _controleur,
              minLines: 6,
              maxLines: 10,
              decoration: const InputDecoration(
                hintText: '{ "format": "odyssee-vagabonds/personnage", … }',
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: _coller,
                icon: const Icon(Icons.content_paste),
                label: const Text('Coller depuis le presse-papiers'),
              ),
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
          key: const Key('valider-import'),
          onPressed: _controleur.text.trim().isEmpty
              ? null
              : () => Navigator.of(context).pop(_controleur.text),
          child: const Text('Importer'),
        ),
      ],
    );
  }
}
