import 'package:flutter/material.dart';

import '../../models/seance.dart';
import '../../theme.dart';

/// Couleur d'une cible selon son camp (19/11/2026) : soi-même en doré,
/// alliés en vert, ennemis en rouge.
Color couleurCamp(CampCible camp, Brightness b) => switch (camp) {
      CampCible.soi =>
        b == Brightness.dark ? OdvCouleurs.or : OdvCouleurs.peFonce,
      CampCible.allie => couleurModificateur(1, b),
      CampCible.neutre =>
        b == Brightness.dark ? OdvCouleurs.texteSecondaire : OdvCouleurs.grey,
      CampCible.ennemi => couleurModificateur(-1, b),
    };

/// Fenêtre des cibles d'une attaque, d'un sort ou d'une compétence
/// (19/11/2026), à la place de la liste déroulante. Une seule cible : un
/// appui suffit ; plusieurs : on coche (au plus [maximum]) puis on valide.
/// Renvoie les ids choisis (vide : « Aucune cible »), `null` si annulé.
class DialogueCibles extends StatefulWidget {
  const DialogueCibles({
    super.key,
    required this.titre,
    required this.cibles,
    this.maximum = 1,
    this.aucune = false,
    this.derniere = const [],
  });

  final String titre;
  final List<CibleSeance> cibles;

  /// 1 : une seule cible ; `null` : sans limite.
  final int? maximum;

  /// Propose « Aucune cible » (attaque sans comparaison).
  final bool aucune;

  /// Dernières cibles choisies : mises en évidence (une seule cible) ou
  /// déjà cochées (plusieurs).
  final List<String> derniere;

  bool get unique => maximum == 1;

  @override
  State<DialogueCibles> createState() => _DialogueCiblesState();
}

class _DialogueCiblesState extends State<DialogueCibles> {
  late final Set<String> _choisis = widget.unique
      ? {}
      : {
          for (final id in widget.derniere)
            if (widget.cibles.any((c) => c.id == id)) id,
        }.take(widget.maximum ?? 1 << 20).toSet();

  Widget _puce(CibleSeance c) {
    final b = Theme.of(context).brightness;
    final couleur = couleurCamp(c.camp, b);
    final nom = c.camp == CampCible.soi ? '${c.nom} (soi-même)' : c.nom;
    final texte = Text(
      nom,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(color: couleur, fontWeight: FontWeight.w700),
    );
    final cle = Key('choix-cible-${c.id}');
    if (widget.unique) {
      final derniere = widget.derniere.contains(c.id);
      return ActionChip(
        key: cle,
        avatar: derniere ? Icon(Icons.history, size: 16, color: couleur) : null,
        side: BorderSide(color: couleur, width: derniere ? 2 : 1),
        label: texte,
        onPressed: () => Navigator.pop(context, [c.id]),
      );
    }
    final choisi = _choisis.contains(c.id);
    final max = widget.maximum;
    final plein = max != null && _choisis.length >= max && !choisi;
    return FilterChip(
      key: cle,
      side: BorderSide(color: couleur),
      checkmarkColor: couleur,
      label: texte,
      selected: choisi,
      onSelected: plein
          ? null
          : (oui) => setState(() {
                oui ? _choisis.add(c.id) : _choisis.remove(c.id);
              }),
    );
  }

  Widget _partie(String titre, CampCible camp) {
    final liste = [
      for (final c in widget.cibles)
        if (c.camp == camp) c,
    ];
    if (liste.isEmpty) return const SizedBox.shrink();
    final couleur = couleurCamp(camp, Theme.of(context).brightness);
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(titre, style: TextStyle(color: couleur)),
          const SizedBox(height: 4),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [for (final c in liste) _puce(c)],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final max = widget.maximum;
    // Ennemis d'abord quand ils sont en tête de la liste (PJ qui attaque).
    final ennemisDabord = widget.cibles.isNotEmpty &&
        widget.cibles.first.camp == CampCible.ennemi;
    final parties = [
      _partie('Ennemis', CampCible.ennemi),
      _partie('Alliés', CampCible.allie),
    ];
    return AlertDialog(
      key: const Key('fenetre-cibles'),
      title: Text(widget.titre),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.unique
                  ? 'Sur qui ?'
                  : max == null
                      ? 'Sur qui ? (une ou plusieurs cibles)'
                      : 'Sur qui ? (${_choisis.length} / $max au plus)',
              key: const Key('compte-cibles'),
            ),
            ...(ennemisDabord ? parties : parties.reversed),
            _partie('Neutres', CampCible.neutre),
            _partie('Soi-même', CampCible.soi),
          ],
        ),
      ),
      actions: [
        TextButton(
          key: const Key('annuler-cibles'),
          onPressed: () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
        if (widget.unique && widget.aucune)
          TextButton(
            key: const Key('aucune-cible'),
            onPressed: () => Navigator.pop(context, <String>[]),
            child: const Text('Aucune cible'),
          ),
        if (!widget.unique)
          FilledButton(
            key: const Key('valider-cibles'),
            onPressed: _choisis.isEmpty
                ? null
                : () => Navigator.pop(context, _choisis.toList()),
            child: const Text('Valider'),
          ),
      ],
    );
  }
}
