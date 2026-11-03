import 'package:flutter/material.dart';

import '../../theme.dart';
import '../../widgets/consultation.dart';
import 'campagnes_screen.dart';

/// Séance de jeu d'une campagne. L'interface de séance (tour de jeu, jets
/// partagés…) sera définie plus tard : pour l'instant, l'état de la séance
/// et, pour le MJ, le bouton pour la terminer.
class SeanceScreen extends StatelessWidget {
  const SeanceScreen({
    super.key,
    required this.contexte,
    required this.campagneId,
  });

  final ContexteCampagnes contexte;
  final String campagneId;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: contexte.campagnes,
      builder: (context, _) {
        final c = contexte.campagnes.parId(campagneId);
        final s = c?.seance;
        final mj = c != null && c.estMj(contexte.campagnes.uid ?? '');
        final theme = Theme.of(context);
        return Scaffold(
          appBar: AppBar(
            title: Text(s == null ? 'Séance' : 'Séance ${s.numero}'),
          ),
          body: LargeurLimitee(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (c == null || s == null)
                  const TexteAVenir('Séance introuvable.')
                else ...[
                  Text(
                    c.nom,
                    style: styleAmbiance(theme.textTheme.headlineSmall),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    s.enCours
                        ? 'Séance en cours depuis ${_heure(s.debut)}.'
                        : 'Séance terminée.',
                    key: const Key('etat-seance'),
                  ),
                  const SizedBox(height: 24),
                  const BlocConsultation(
                    titre: 'Interface de séance',
                    icone: Icons.construction_outlined,
                    children: [
                      TexteAVenir('L\'interface de séance arrive bientôt.'),
                    ],
                  ),
                  if (mj && s.enCours)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: FilledButton.icon(
                        key: const Key('terminer-seance'),
                        onPressed: () async {
                          final navigator = Navigator.of(context);
                          final erreur = await contexte.campagnes
                              .agir((x) => x.terminerSeance(c));
                          if (erreur == null) navigator.pop();
                        },
                        icon: const Icon(Icons.stop_circle_outlined),
                        label: const Text('Terminer la séance'),
                      ),
                    ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  static String _heure(DateTime d) =>
      '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
}
