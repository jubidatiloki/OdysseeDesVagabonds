import 'package:flutter/material.dart';

import '../../data/referentiel.dart';
import '../../models/aptitude.dart';
import '../../models/carac.dart';
import '../../regles/fiche_calculee.dart';
import '../../regles/montee_niveau.dart';
import '../../regles/progression.dart';
import '../../state/personnages_controller.dart';
import '../creation/etape_competences.dart';

/// Dépense des points de compétence restants, à tout moment (hors montée
/// de niveau) : même écran que la création, rangs jusqu'au niveau actuel,
/// compétences déjà acquises non retirables.
class DepenserPointsScreen extends StatefulWidget {
  const DepenserPointsScreen({
    super.key,
    required this.fiche,
    required this.referentiel,
    required this.controller,
  });

  final FicheCalculee fiche;
  final Referentiel referentiel;
  final PersonnagesController controller;

  @override
  State<DepenserPointsScreen> createState() => _DepenserPointsScreenState();
}

class _DepenserPointsScreenState extends State<DepenserPointsScreen> {
  late Map<String, int> _rangsVoies;
  late List<AptitudeAcquise> _aptitudes;
  bool _enregistrement = false;

  FicheCalculee get _fiche => widget.fiche;

  @override
  void initState() {
    super.initState();
    _rangsVoies = Map.of(_fiche.personnage.rangsVoies);
    _aptitudes = List.of(_fiche.personnage.aptitudes);
  }

  bool get _modifie =>
      _aptitudes.length != _fiche.personnage.aptitudes.length ||
      Progression.pointsDepenses(_rangsVoies) !=
          Progression.pointsDepenses(_fiche.personnage.rangsVoies);

  Future<void> _valider() async {
    if (_enregistrement || !_modifie) return;
    setState(() => _enregistrement = true);
    final p = _fiche.personnage;
    MonteeNiveau.depenserPoints(
      personnage: p,
      race: _fiche.race,
      classe: _fiche.classe,
      rangsVoies: _rangsVoies,
      aptitudes: _aptitudes,
      catalogueAptitudes: widget.referentiel.aptitudes,
      catalogueEquipements: widget.referentiel.equipements,
    );
    final navigator = Navigator.of(context);
    await widget.controller.sauvegarder(p);
    navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final p = _fiche.personnage;
    return PopScope<void>(
      canPop: !_modifie || _enregistrement,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final navigator = Navigator.of(context);
        final quitter = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Abandonner les choix ?'),
            content: const Text('Les compétences choisies ne seront pas '
                'enregistrées.'),
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
        if (quitter == true) navigator.pop();
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Dépenser des points')),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: kLargeurAvecResume),
            child: EtapeCompetences(
              titre: 'Points de compétence restants',
              race: _fiche.race,
              classe: _fiche.classe,
              niveau: p.niveau,
              rangsVoies: _rangsVoies,
              aptitudes: _aptitudes,
              catalogueAptitudes: widget.referentiel.aptitudes,
              intFinale: _fiche.carac(Carac.intel),
              rangsVerrouilles: p.rangsVoies,
              aptitudesVerrouillees: p.aptitudes,
              onChange: (r) => setState(() => _rangsVoies = r),
              onAptitudes: (a) => setState(() => _aptitudes = a),
            ),
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
            child: Center(
              heightFactor: 1,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: FilledButton.icon(
                  key: const Key('valider-depense-points'),
                  onPressed: _modifie && !_enregistrement ? _valider : null,
                  icon: const Icon(Icons.check),
                  label: const Text('Valider les nouvelles compétences'),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
