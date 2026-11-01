import 'package:flutter/material.dart';

import '../../models/objet.dart';
import '../../widgets/cadre_classe.dart';
import '../../widgets/icone_guitare.dart';

/// Écran plein de création / modification d'un objet.
/// Renvoie l'objet (nouveau ou modifié) ou `null` si annulé.
class FormulaireObjet extends StatefulWidget {
  const FormulaireObjet({super.key, this.objet, this.modele});

  /// Objet à modifier (`null` = nouvel objet).
  final Objet? objet;

  /// Nouvel objet : valeurs de départ (objet choisi dans le catalogue).
  final Objet? modele;

  static Future<Objet?> ouvrir(
    BuildContext context, {
    Objet? objet,
    Objet? modele,
  }) =>
      Navigator.of(context).push<Objet>(
        MaterialPageRoute(
          fullscreenDialog: true,
          builder: (_) => FormulaireObjet(objet: objet, modele: modele),
        ),
      );

  @override
  State<FormulaireObjet> createState() => _FormulaireObjetState();
}

class _FormulaireObjetState extends State<FormulaireObjet> {
  late final TextEditingController _nom;
  late final TextEditingController _description;
  late final TextEditingController _degats;
  late final TextEditingController _degatsDeuxMains;
  late CategorieObjet _categorie;
  late int _quantite;
  late int _bonusCA;

  /// Armure : limite du bonus de DEX (`null` : sans limite).
  int? _dexMax;
  String? _typeDegats;
  late _Prise _prise;
  late bool _distance;
  late OrigineObjet _origine;
  late MatiereObjet _matiere;
  late PoidsArmure _poidsArmure;
  late final TextEditingController _precisionOrigine;

  bool get _modification => widget.objet != null;

  /// Objet du catalogue ou donné par une compétence : attributs figés tant
  /// qu'on n'a pas appuyé sur « Éditer l'objet ».
  late bool _verrouille;

  /// « Éditer l'objet » utilisé : s'il change, l'objet devient personnalisé.
  bool _edite = false;
  late final String _empreinteDepart;

  @override
  void initState() {
    super.initState();
    final o = widget.objet ?? widget.modele;
    _nom = TextEditingController(text: o?.nom ?? '');
    _description = TextEditingController(text: o?.description ?? '');
    _degats = TextEditingController(text: o?.degats ?? '');
    _categorie = o?.categorie ?? CategorieObjet.divers;
    _quantite = o?.quantite ?? 1;
    _bonusCA = o?.bonusCA ?? 0;
    _dexMax = o?.dexMax;
    _typeDegats = o?.typeDegats;
    _degatsDeuxMains = TextEditingController(text: o?.degatsDeuxMains ?? '');
    _prise = o == null
        ? _Prise.uneMain
        : o.polyvalente
            ? _Prise.polyvalente
            : o.deuxMains
                ? _Prise.deuxMains
                : _Prise.uneMain;
    _distance = o?.distance ?? false;
    _origine = o?.origine ?? OrigineObjet.inconnue;
    _matiere = o?.matiere ?? MatiereObjet.nonPrecisee;
    _poidsArmure = o?.poidsArmure ?? PoidsArmure.nonPrecise;
    _precisionOrigine = TextEditingController(text: o?.precisionOrigine ?? '');
    _verrouille = o?.verrouille ?? false;
    _empreinteDepart = o?.empreinteAttributs ?? '';
  }

  @override
  void dispose() {
    _nom.dispose();
    _description.dispose();
    _degats.dispose();
    _degatsDeuxMains.dispose();
    _precisionOrigine.dispose();
    super.dispose();
  }

  bool get _valide => _nom.text.trim().isNotEmpty && _quantite >= 1;

  void _enregistrer() {
    if (!_valide) return;
    final estArme = _categorie == CategorieObjet.arme;
    final polyvalente = estArme && _prise == _Prise.polyvalente;
    final objet = widget.objet ?? Objet(nom: '');
    objet
      ..nom = _nom.text.trim()
      ..categorie = _categorie
      ..quantite = _quantite
      ..description = _description.text.trim()
      ..degats = estArme ? _degats.text.trim() : ''
      ..typeDegats = estArme ? _typeDegats : null
      ..deuxMains = (estArme || _categorie == CategorieObjet.bouclier) &&
          _prise == _Prise.deuxMains
      ..polyvalente = polyvalente
      ..degatsDeuxMains = polyvalente ? _degatsDeuxMains.text.trim() : ''
      ..tenueDeuxMains = polyvalente && objet.tenueDeuxMains
      ..distance = estArme && _distance
      ..bonusCA = _categorie.protection ? _bonusCA : 0
      ..dexMax = _categorie == CategorieObjet.armure ? _dexMax : null
      ..matiere = _matiere
      ..poidsArmure = _categorie == CategorieObjet.armure
          ? _poidsArmure
          : PoidsArmure.nonPrecise;
    // Objet du catalogue : le reste ; édité et changé : personnalisé.
    if (widget.modele?.duCatalogue ?? false) objet.duCatalogue = true;
    if (_edite && objet.empreinteAttributs != _empreinteDepart) {
      objet.personnalise = true;
    }
    // Origine « race » / « classe » : fixée, jamais modifiée ici.
    if (!objet.origine.verrouillee) {
      objet
        ..origine = _origine
        ..precisionOrigine = _precisionOrigine.text.trim();
    }
    if (!_categorie.equipable) objet.equipe = false;
    Navigator.of(context).pop(objet);
  }

  /// Choix de la prise (arme : 3 choix ; bouclier : une ou deux mains).
  Widget _choixPrise(ThemeData theme, List<_Prise> choix) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Prise', style: theme.textTheme.titleSmall),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final p in choix)
                ChoiceChip(
                  key: Key('prise-${p.name}'),
                  label: Text(p.libelle),
                  selected: p == _prise,
                  onSelected: (_) => setState(() => _prise = p),
                ),
            ],
          ),
        ],
      );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(_modification ? 'Modifier l\'objet' : 'Nouvel objet'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilledButton(
              key: const Key('enregistrer-objet'),
              onPressed: _valide ? _enregistrer : null,
              child: const Text('Enregistrer'),
            ),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Objet du catalogue ou donné : attributs en lecture seule.
              if (_verrouille) ...[
                _ResumeObjet(objet: (widget.objet ?? widget.modele)!),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: OutlinedButton.icon(
                    key: const Key('editer-objet'),
                    onPressed: () => setState(() {
                      _verrouille = false;
                      _edite = true;
                    }),
                    icon: const Icon(Icons.build_outlined, size: 18),
                    label: const Text("Éditer l'objet"),
                  ),
                ),
                const SizedBox(height: 16),
                _Compteur(
                  cle: 'quantite',
                  libelle: 'Quantité',
                  valeur: _quantite,
                  min: 1,
                  onChange: (v) => setState(() => _quantite = v),
                ),
              ] else ...[
                TextField(
                  key: const Key('champ-nom-objet'),
                  controller: _nom,
                  autofocus: !_modification,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    labelText: 'Nom',
                    hintText: 'Ex. : Épée longue, Potion de santé…',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 16),
                Text('Catégorie', style: theme.textTheme.titleSmall),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final c in CategorieObjet.values)
                      ChoiceChip(
                        key: Key('categorie-${c.name}'),
                        avatar: iconeCategorieWidget(c, taille: 18),
                        label: Text(c.libelle),
                        selected: c == _categorie,
                        onSelected: (_) => setState(() => _categorie = c),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                _Compteur(
                  cle: 'quantite',
                  libelle: 'Quantité',
                  valeur: _quantite,
                  min: 1,
                  onChange: (v) => setState(() => _quantite = v),
                ),
                if (_categorie == CategorieObjet.arme) ...[
                  const SizedBox(height: 16),
                  Text('Portée', style: theme.textTheme.titleSmall),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ChoiceChip(
                        key: const Key('portee-cac'),
                        avatar: const Icon(Icons.gavel, size: 18),
                        label: const Text('Corps à corps'),
                        selected: !_distance,
                        onSelected: (_) => setState(() => _distance = false),
                      ),
                      ChoiceChip(
                        key: const Key('portee-distance'),
                        avatar: const Icon(Icons.gps_fixed, size: 18),
                        label: const Text('Distance'),
                        selected: _distance,
                        onSelected: (_) => setState(() => _distance = true),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _choixPrise(theme, _Prise.values),
                  const SizedBox(height: 12),
                  TextField(
                    key: const Key('champ-degats'),
                    controller: _degats,
                    decoration: InputDecoration(
                      labelText: _prise == _Prise.polyvalente
                          ? 'Dégâts à une main'
                          : 'Dégâts',
                      hintText: 'Ex. : 1d8, 2d6',
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  if (_prise == _Prise.polyvalente) ...[
                    const SizedBox(height: 12),
                    TextField(
                      key: const Key('champ-degats-deux-mains'),
                      controller: _degatsDeuxMains,
                      decoration: const InputDecoration(
                        labelText: 'Dégâts à deux mains',
                        hintText: 'Ex. : 1d8',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  Text('Type de dégâts', style: theme.textTheme.titleSmall),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      for (final t in kTypesDegats)
                        ChoiceChip(
                          label: Text(t),
                          selected: t == _typeDegats,
                          onSelected: (choisi) =>
                              setState(() => _typeDegats = choisi ? t : null),
                        ),
                    ],
                  ),
                ],
                if (_categorie == CategorieObjet.bouclier) ...[
                  const SizedBox(height: 16),
                  _choixPrise(theme, const [_Prise.uneMain, _Prise.deuxMains]),
                ],
                if (_categorie.protection) ...[
                  const SizedBox(height: 16),
                  _Compteur(
                    cle: 'bonus-ca',
                    libelle: 'Bonus de CA',
                    valeur: _bonusCA,
                    min: -5,
                    max: 20,
                    signe: true,
                    onChange: (v) => setState(() => _bonusCA = v),
                  ),
                  // Armure : limite du bonus de DEX à la CA et à l'esquive.
                  if (_categorie == CategorieObjet.armure) ...[
                    SwitchListTile(
                      key: const Key('limite-dex'),
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Limite le bonus de DEX'),
                      subtitle: const Text(
                          'Cuir +3, cotte de mailles +2, plaques +1'),
                      value: _dexMax != null,
                      onChanged: (v) => setState(() => _dexMax = v ? 1 : null),
                    ),
                    if (_dexMax != null)
                      _Compteur(
                        cle: 'dex-max',
                        libelle: 'DEX max',
                        valeur: _dexMax!,
                        min: 0,
                        max: 10,
                        signe: true,
                        onChange: (v) => setState(() => _dexMax = v),
                      ),
                  ],
                ],
                const SizedBox(height: 16),
                TextField(
                  controller: _description,
                  minLines: 2,
                  maxLines: 6,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    labelText: 'Description, effets (facultatif)',
                    alignLabelWithHint: true,
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                Text('Matière', style: theme.textTheme.titleSmall),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final m in MatiereObjet.values)
                      ChoiceChip(
                        key: Key('matiere-${m.name}'),
                        label: Text(m.libelle),
                        selected: m == _matiere,
                        onSelected: (_) => setState(() => _matiere = m),
                      ),
                  ],
                ),
                // Armure : légère, intermédiaire, lourde (Légèreté animale).
                if (_categorie == CategorieObjet.armure) ...[
                  const SizedBox(height: 16),
                  Text('Poids d\x27armure', style: theme.textTheme.titleSmall),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final p in PoidsArmure.values)
                        ChoiceChip(
                          key: Key('poids-armure-${p.name}'),
                          label: Text(p.libelle),
                          selected: p == _poidsArmure,
                          onSelected: (_) => setState(() => _poidsArmure = p),
                        ),
                    ],
                  ),
                ],
              ],
              const SizedBox(height: 16),
              Text('Origine', style: theme.textTheme.titleSmall),
              const SizedBox(height: 8),
              if (_origine.verrouillee)
                // Objet donné par la race ou la classe : pas de changement.
                ListTile(
                  key: const Key('origine-verrouillee'),
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.lock_outline),
                  title: Text(
                    _precisionOrigine.text.isEmpty
                        ? _origine.libelle
                        : '${_origine.libelle} (${_precisionOrigine.text})',
                  ),
                  subtitle: const Text('Donné par la race ou la classe'),
                )
              else ...[
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final o in OrigineObjet.values)
                      if (!o.verrouillee)
                        ChoiceChip(
                          key: Key('origine-${o.name}'),
                          label: Text(o.libelle),
                          selected: o == _origine,
                          onSelected: (_) => setState(() => _origine = o),
                        ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  key: const Key('champ-precision-origine'),
                  controller: _precisionOrigine,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    labelText: 'Précision (facultatif)',
                    hintText: 'Ex. : marchand de Port-Réal, coffre du donjon…',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Façon de tenir une arme.
enum _Prise {
  uneMain('Une main'),
  deuxMains('Deux mains'),
  polyvalente('Une ou deux mains');

  const _Prise(this.libelle);

  final String libelle;
}

class _Compteur extends StatelessWidget {
  const _Compteur({
    required this.cle,
    required this.libelle,
    required this.valeur,
    required this.onChange,
    this.min = 0,
    this.max = 999,
    this.signe = false,
  });

  final String cle;
  final String libelle;
  final int valeur;
  final int min;
  final int max;
  final bool signe;
  final ValueChanged<int> onChange;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final texte = signe && valeur >= 0 ? '+$valeur' : '$valeur';
    return Row(
      children: [
        Expanded(child: Text(libelle, style: theme.textTheme.titleSmall)),
        IconButton(
          key: Key('$cle-moins'),
          onPressed: valeur > min ? () => onChange(valeur - 1) : null,
          icon: const Icon(Icons.remove_circle_outline),
        ),
        SizedBox(
          width: 40,
          child: Text(
            texte,
            key: Key('$cle-valeur'),
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium,
          ),
        ),
        IconButton(
          key: Key('$cle-plus'),
          onPressed: valeur < max ? () => onChange(valeur + 1) : null,
          icon: const Icon(Icons.add_circle_outline),
        ),
      ],
    );
  }
}

/// Icône associée à une catégorie d'objet.
IconData iconeCategorie(CategorieObjet c) {
  switch (c) {
    case CategorieObjet.arme:
      return Icons.gavel;
    case CategorieObjet.armure:
      return Icons.checkroom;
    case CategorieObjet.bouclier:
      return Icons.shield_outlined;
    case CategorieObjet.casque:
      return Icons.sports_motorsports_outlined;
    case CategorieObjet.accessoire:
      return Icons.diamond_outlined;
    case CategorieObjet.extra:
      return Icons.auto_awesome_outlined;
    case CategorieObjet.instrument:
      return Icons.music_note_outlined;
    case CategorieObjet.monture:
      return Icons.pets_outlined;
    case CategorieObjet.compagnon:
      return Icons.person_outline;
    case CategorieObjet.consommable:
      return Icons.science_outlined;
    case CategorieObjet.divers:
      return Icons.inventory_2_outlined;
  }
}

/// Icône d'une catégorie d'objet sous forme de widget : guitare dessinée
/// pour les instruments de musique, icône Material sinon.
/// Armes (épée, arc si [distance]), armure (plastron), bouclier, casque et
/// consommable (potion) : motifs dessinés (charte, décision 31).
Widget iconeCategorieWidget(
  CategorieObjet c, {
  double taille = 24,
  Color? couleur,
  bool distance = false,
  bool armeAFeu = false,
}) {
  final motif = switch (c) {
    CategorieObjet.arme => armeAFeu
        ? MotifClasse.pistolet
        : distance
            ? MotifClasse.arc
            : MotifClasse.epee,
    CategorieObjet.armure => MotifClasse.plastron,
    CategorieObjet.bouclier => MotifClasse.bouclier,
    CategorieObjet.casque => MotifClasse.casque,
    CategorieObjet.consommable => MotifClasse.potion,
    _ => null,
  };
  if (motif != null) {
    return IconeMotif(motif, taille: taille, couleur: couleur);
  }
  return c == CategorieObjet.instrument
      ? IconeGuitare(taille: taille, couleur: couleur)
      : Icon(iconeCategorie(c), size: taille, color: couleur);
}

/// Attributs d'un objet du catalogue (ou donné par une compétence), en
/// lecture seule : nom, catégorie, dégâts / CA, matière, description.
class _ResumeObjet extends StatelessWidget {
  const _ResumeObjet({required this.objet});

  final Objet objet;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final details = [
      objet.categorie.libelle,
      if (objet.resume.isNotEmpty) objet.resume,
      if (objet.matiere != MatiereObjet.nonPrecisee) objet.matiere.libelle,
      if (objet.categorie == CategorieObjet.armure &&
          objet.poidsArmure != PoidsArmure.nonPrecise)
        'Armure ${objet.poidsArmure.libelle.toLowerCase()}',
    ];
    return Container(
      key: const Key('resume-objet-verrouille'),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          iconeCategorieWidget(objet.categorie, couleur: scheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  objet.nom,
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                Text(details.join(' · '), style: theme.textTheme.bodySmall),
                if (objet.description.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(objet.description, style: theme.textTheme.bodySmall),
                ],
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.lock_outline,
                        size: 14, color: scheme.onSurfaceVariant),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        objet.donnePar.isNotEmpty
                            ? 'Donné par une compétence : « Éditer » pour '
                                'changer ses attributs.'
                            : 'Objet du catalogue : « Éditer » pour changer '
                                'ses attributs.',
                        style: theme.textTheme.labelSmall
                            ?.copyWith(color: scheme.onSurfaceVariant),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
