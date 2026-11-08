import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../models/campagne.dart';
import '../../widgets/consultation.dart';
import 'campagne_mj_screen.dart';
import 'campagnes_screen.dart';

/// Création d'une campagne en 4 étapes : nom et présentation, script,
/// notes, paramètres. La page de la campagne affiche ensuite le code
/// d'invitation à envoyer aux joueurs.
class CreationCampagneScreen extends StatefulWidget {
  const CreationCampagneScreen({super.key, required this.contexte});

  final ContexteCampagnes contexte;

  @override
  State<CreationCampagneScreen> createState() => _CreationCampagneState();
}

class _CreationCampagneState extends State<CreationCampagneScreen> {
  final _nom = TextEditingController();
  final _description = TextEditingController();
  final _script = TextEditingController();
  final _notes = TextEditingController();
  var _parametres = const ParametresCampagne();
  var _etape = 0;
  var _envoi = false;
  String? _erreur;

  @override
  void dispose() {
    _nom.dispose();
    _description.dispose();
    _script.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _creer() async {
    if (_nom.text.trim().isEmpty) {
      setState(() {
        _etape = 0;
        _erreur = 'Donne un nom à la campagne.';
      });
      return;
    }
    setState(() {
      _envoi = true;
      _erreur = null;
    });
    final c = widget.contexte.campagnes;
    final u = c.compte.utilisateur;
    Campagne? creee;
    final erreur = await c.agir((s) async {
      creee = await s.creer(
        nom: _nom.text,
        mjNom: u?.nom ?? u?.email?.split('@').first ?? 'MJ',
        description: _description.text,
        prive: PriveCampagne(script: _script.text, notes: _notes.text),
        parametres: _parametres,
      );
    });
    if (!mounted) return;
    setState(() {
      _envoi = false;
      _erreur = erreur;
    });
    final campagne = creee;
    if (erreur != null || campagne == null) return;
    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (_) => CampagneMjScreen(
        contexte: widget.contexte,
        campagneId: campagne.id,
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final derniere = _etape == 3;
    return Scaffold(
      appBar: AppBar(title: const Text('Nouvelle campagne')),
      body: LargeurLimitee(
        child: Stepper(
          currentStep: _etape,
          onStepTapped: (i) => setState(() => _etape = i),
          onStepContinue: derniere
              ? (_envoi ? null : _creer)
              : () => setState(() => _etape++),
          onStepCancel: _etape == 0 ? null : () => setState(() => _etape--),
          controlsBuilder: (context, d) => Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Row(
              children: [
                FilledButton(
                  key: Key(d.stepIndex == 3
                      ? 'creer-campagne'
                      : 'etape-suivante-${d.stepIndex}'),
                  onPressed: d.onStepContinue,
                  child: _envoi
                      ? const SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(
                          d.stepIndex == 3 ? 'Créer la campagne' : 'Suivant'),
                ),
                const SizedBox(width: 8),
                if (d.onStepCancel != null)
                  TextButton(
                    onPressed: d.onStepCancel,
                    child: const Text('Précédent'),
                  ),
              ],
            ),
          ),
          steps: [
            Step(
              title: const Text('Nom et présentation'),
              isActive: _etape >= 0,
              content: Column(
                children: [
                  TextField(
                    key: const Key('campagne-nom'),
                    controller: _nom,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      labelText: 'Nom de la campagne',
                      hintText: 'Les ombres de Valfroid',
                      errorText: _erreur,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    key: const Key('campagne-description'),
                    controller: _description,
                    minLines: 2,
                    maxLines: 5,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: const InputDecoration(
                      labelText: 'Présentation (visible des joueurs)',
                      hintText: 'Accroche, ambiance, ce qu\'il faut savoir '
                          'avant de venir…',
                    ),
                  ),
                ],
              ),
            ),
            Step(
              title: const Text('Script'),
              subtitle: const Text('Visible du MJ seulement'),
              isActive: _etape >= 1,
              content: EditeurTexteCampagne(
                cle: 'campagne-script',
                controleur: _script,
                indication: 'Trame, scènes, PNJ, rebondissements…',
                importable: true,
              ),
            ),
            Step(
              title: const Text('Notes générales'),
              subtitle: const Text('Visible du MJ seulement'),
              isActive: _etape >= 2,
              content: EditeurTexteCampagne(
                cle: 'campagne-notes',
                controleur: _notes,
                indication: 'Idées, règles maison, rappels…',
              ),
            ),
            Step(
              title: const Text('Paramètres'),
              isActive: _etape >= 3,
              content: FormulaireParametres(
                valeur: _parametres,
                onChange: (p) => setState(() => _parametres = p),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Grand champ de texte (script, notes), avec import d'un fichier texte.
class EditeurTexteCampagne extends StatelessWidget {
  const EditeurTexteCampagne({
    super.key,
    required this.cle,
    required this.controleur,
    required this.indication,
    this.importable = false,
    this.lignes = 10,
  });

  final String cle;
  final TextEditingController controleur;
  final String indication;

  /// Bouton « Importer un fichier » (.txt, .md).
  final bool importable;
  final int lignes;

  Future<void> _importer(BuildContext context) async {
    final messager = ScaffoldMessenger.of(context);
    try {
      final r = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: const ['txt', 'md'],
        withData: true,
      );
      final octets = r?.files.single.bytes;
      if (octets == null) return;
      final texte = utf8.decode(octets, allowMalformed: true);
      if (controleur.text.trim().isNotEmpty && context.mounted) {
        final remplacer = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Remplacer le texte ?'),
            content: const Text('Le texte actuel sera remplacé par celui du '
                'fichier.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Annuler'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Remplacer'),
              ),
            ],
          ),
        );
        if (remplacer != true) return;
      }
      controleur.text = texte;
      messager.showSnackBar(SnackBar(
        content: Text('Fichier importé : ${r!.files.single.name}'),
      ));
    } catch (e) {
      messager.showSnackBar(SnackBar(
        content: Text('Impossible d\'ouvrir le fichier ($e). Copie-colle '
            'le texte à la place.'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          key: Key(cle),
          controller: controleur,
          minLines: lignes,
          maxLines: null,
          keyboardType: TextInputType.multiline,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(
            hintText: indication,
            border: const OutlineInputBorder(),
          ),
        ),
        if (importable) ...[
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: OutlinedButton.icon(
              key: Key('$cle-importer'),
              onPressed: () => _importer(context),
              icon: const Icon(Icons.upload_file),
              label: const Text('Importer un fichier (.txt, .md)'),
            ),
          ),
        ],
      ],
    );
  }
}

/// Paramètres d'une campagne : joueurs, fiches visibles.
class FormulaireParametres extends StatelessWidget {
  const FormulaireParametres({
    super.key,
    required this.valeur,
    required this.onChange,
  });

  final ParametresCampagne valeur;
  final ValueChanged<ParametresCampagne> onChange;

  @override
  Widget build(BuildContext context) {
    final p = valeur;
    Widget compteur({
      required String cle,
      required String libelle,
      required int v,
      required int min,
      required int max,
      required ValueChanged<int> change,
    }) =>
        Row(
          children: [
            Expanded(child: Text(libelle)),
            IconButton(
              key: Key('$cle-moins'),
              onPressed: v > min ? () => change(v - 1) : null,
              icon: const Icon(Icons.remove_circle_outline),
            ),
            SizedBox(
              width: 28,
              child: Text(
                '$v',
                key: Key('$cle-valeur'),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            IconButton(
              key: Key('$cle-plus'),
              onPressed: v < max ? () => change(v + 1) : null,
              icon: const Icon(Icons.add_circle_outline),
            ),
          ],
        );
    return Column(
      children: [
        compteur(
          cle: 'joueurs-max',
          libelle: 'Nombre maximum de joueurs',
          v: p.joueursMax,
          min: 1,
          max: ParametresCampagne.joueursMaxLimite,
          change: (v) => onChange(p.copie(joueursMax: v)),
        ),
        SwitchListTile(
          key: const Key('fiches-visibles-mj'),
          contentPadding: EdgeInsets.zero,
          title: const Text('Fiches visibles par le MJ'),
          subtitle: const Text('Tu peux consulter le personnage de chaque '
              'joueur (PV, inventaire…).'),
          value: p.fichesVisiblesMj,
          onChanged: (v) => onChange(p.copie(fichesVisiblesMj: v)),
        ),
        FormulairePermissions(valeur: p, onChange: onChange),
      ],
    );
  }
}

/// Ce que les PJ ont le droit de faire et de voir.
class FormulairePermissions extends StatelessWidget {
  const FormulairePermissions({
    super.key,
    required this.valeur,
    required this.onChange,
  });

  final ParametresCampagne valeur;
  final ValueChanged<ParametresCampagne> onChange;

  @override
  Widget build(BuildContext context) {
    final p = valeur;
    Widget ligne(String cle, String titre, bool v,
            ParametresCampagne Function(bool) change) =>
        SwitchListTile(
          key: Key(cle),
          contentPadding: EdgeInsets.zero,
          title: Text(titre),
          value: v,
          onChanged: (x) => onChange(change(x)),
        );
    Widget titre(String cle, IconData icone, String texte) => Padding(
          key: Key(cle),
          padding: const EdgeInsets.only(top: 12, bottom: 2),
          child: Row(
            children: [
              Icon(icone,
                  size: 18, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  texte,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        titre('permissions-hors-seance', Icons.home_outlined, 'Hors séance'),
        ligne(
          'pj-inventaire-hors-seance',
          "Les PJ modifient l'inventaire en dehors d'une séance",
          p.pjInventaireHorsSeance,
          (v) => p.copie(pjInventaireHorsSeance: v),
        ),
        ligne(
          'pj-competences-hors-seance',
          "Les PJ modifient leurs compétences en dehors d'une séance",
          p.pjCompetencesHorsSeance,
          (v) => p.copie(pjCompetencesHorsSeance: v),
        ),
        ligne(
          'fiches-visibles-joueurs',
          'Les PJ voient leurs fiches de personnage entre eux',
          p.fichesVisiblesJoueurs,
          (v) => p.copie(fichesVisiblesJoueurs: v),
        ),
        titre('permissions-seance', Icons.casino_outlined, 'Pendant la séance'),
        ligne(
          'pj-voient-ressources',
          'Les PJ voient leurs PV, PM et PE entre eux',
          p.pjVoientRessources,
          (v) => p.copie(pjVoientRessources: v),
        ),
        ligne(
          'pj-voient-pv-creatures',
          'Les PJ voient les PV des créatures',
          p.pjVoientPvCreatures,
          (v) => p.copie(pjVoientPvCreatures: v),
        ),
        ligne(
          'pj-voient-fiches-creatures',
          'Les PJ voient les fiches des créatures',
          p.pjVoientFichesCreatures,
          (v) => p.copie(pjVoientFichesCreatures: v),
        ),
      ],
    );
  }
}

/// Paramètres de la campagne, en consultation (joueurs).
class ResumeParametres extends StatelessWidget {
  const ResumeParametres(this.parametres, {super.key});

  final ParametresCampagne parametres;

  @override
  Widget build(BuildContext context) {
    final p = parametres;
    String oui(bool v) => v ? 'oui' : 'non';
    final style = Theme.of(context)
        .textTheme
        .titleSmall
        ?.copyWith(fontWeight: FontWeight.w700);
    Widget lignes(List<String> l) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final t in l)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(t),
              ),
          ],
        );
    return Column(
      key: const Key('resume-parametres'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        lignes([
          'Joueurs au maximum : ${p.joueursMax}',
          'Fiches visibles par le MJ : ${oui(p.fichesVisiblesMj)}',
        ]),
        const SizedBox(height: 8),
        Text('Hors séance', style: style),
        const SizedBox(height: 4),
        lignes([
          'Inventaire modifiable : ${oui(p.pjInventaireHorsSeance)}',
          'Compétences modifiables : ${oui(p.pjCompetencesHorsSeance)}',
          'Fiches visibles entre PJ : ${oui(p.fichesVisiblesJoueurs)}',
        ]),
        const SizedBox(height: 8),
        Text('Pendant la séance', style: style),
        const SizedBox(height: 4),
        lignes([
          'PV, PM et PE visibles entre PJ : ${oui(p.pjVoientRessources)}',
          'PV des créatures visibles : ${oui(p.pjVoientPvCreatures)}',
          'Fiches des créatures visibles : '
              '${oui(p.pjVoientFichesCreatures)}',
        ]),
      ],
    );
  }
}
