import 'package:flutter/material.dart';

import '../../models/campagne.dart';
import '../../models/personnage.dart';
import '../../widgets/consultation.dart';
import 'campagnes_screen.dart';

/// Résumé d'un personnage pour la campagne : « Nain · Guerrier · niveau 3 ».
String resumePersonnage(ContexteCampagnes contexte, Personnage p) => [
      contexte.referentiel.race(p.raceId)?.nom ?? p.raceId,
      contexte.referentiel.classe(p.classeId)?.nom ?? p.classeId,
      'niveau ${p.niveau}',
    ].join(' · ');

/// Membre (demande) d'un joueur avec un personnage.
MembreCampagne membrePour(ContexteCampagnes contexte, Personnage p) {
  final u = contexte.campagnes.compte.utilisateur;
  return MembreCampagne(
    uid: contexte.campagnes.uid ?? '',
    nom: u?.nom ?? u?.email?.split('@').first ?? 'Joueur',
    personnageId: p.id,
    personnageNom: p.nom,
    personnageResume: resumePersonnage(contexte, p),
    date: DateTime.now(),
  );
}

/// Rejoindre une campagne : code d'invitation, vérification (nom, MJ,
/// places), choix du personnage, demande envoyée au MJ.
class RejoindreCampagneScreen extends StatefulWidget {
  const RejoindreCampagneScreen({
    super.key,
    required this.contexte,
    this.codeInitial = '',
  });

  final ContexteCampagnes contexte;
  final String codeInitial;

  @override
  State<RejoindreCampagneScreen> createState() => _RejoindreState();
}

class _RejoindreState extends State<RejoindreCampagneScreen> {
  late final _code = TextEditingController(text: widget.codeInitial);
  Campagne? _campagne;
  String? _personnageId;
  String? _erreur;
  var _attente = false;

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  Future<void> _chercher() async {
    setState(() {
      _attente = true;
      _erreur = null;
      _campagne = null;
    });
    Campagne? trouvee;
    final erreur = await widget.contexte.campagnes.agir((s) async {
      trouvee = await s.trouverParCode(_code.text);
    });
    if (!mounted) return;
    setState(() {
      _attente = false;
      _erreur = erreur;
      _campagne = trouvee;
      _code.text = CodeInvitation.normaliser(_code.text);
    });
  }

  Future<void> _demander() async {
    final c = _campagne;
    final p = widget.contexte.personnages.parId(_personnageId ?? '');
    if (c == null || p == null) return;
    setState(() => _attente = true);
    final erreur = await widget.contexte.campagnes
        .agir((s) => s.demander(c, membrePour(widget.contexte, p)));
    if (!mounted) return;
    setState(() {
      _attente = false;
      _erreur = erreur;
    });
    if (erreur != null) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Demande envoyée à ${c.mjNom} : tu seras membre de '
          '« ${c.nom} » dès qu\'il l\'aura acceptée.'),
    ));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final c = _campagne;
    final personnages = widget.contexte.personnages.personnages;
    return Scaffold(
      appBar: AppBar(title: const Text('Rejoindre une campagne')),
      body: LargeurLimitee(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text('Saisis le code d\'invitation que ton MJ t\'a envoyé '
                '(un mot et 4 chiffres).'),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextField(
                    key: const Key('code-rejoindre'),
                    controller: _code,
                    textCapitalization: TextCapitalization.characters,
                    decoration: const InputDecoration(
                      labelText: 'Code',
                      hintText: 'LOUP-4827',
                      prefixIcon: Icon(Icons.vpn_key_outlined),
                    ),
                    onSubmitted: (_) => _chercher(),
                  ),
                ),
                const SizedBox(width: 8),
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: FilledButton.tonal(
                    key: const Key('chercher-campagne'),
                    onPressed: _attente ? null : _chercher,
                    child: const Text('Vérifier'),
                  ),
                ),
              ],
            ),
            if (_erreur != null) ...[
              const SizedBox(height: 12),
              Text(
                _erreur!,
                key: const Key('erreur-rejoindre'),
                style: TextStyle(color: theme.colorScheme.error),
              ),
            ],
            if (c != null) ...[
              const SizedBox(height: 16),
              BlocConsultation(
                titre: c.nom,
                icone: Icons.menu_book_outlined,
                children: [
                  Text('MJ : ${c.mjNom}'),
                  Text('${c.joueurs.length}/${c.parametres.joueursMax} '
                      'joueurs'),
                  if (c.description.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(c.description),
                  ],
                ],
              ),
              Text('Avec quel personnage ?', style: theme.textTheme.titleSmall),
              const SizedBox(height: 8),
              if (personnages.isEmpty)
                const TexteAVenir('Crée d\'abord un personnage (page '
                    'Personnages).')
              else
                RadioGroup<String>(
                  groupValue: _personnageId,
                  onChanged: (v) => setState(() => _personnageId = v),
                  child: Column(
                    children: [
                      for (final p in personnages)
                        RadioListTile<String>(
                          key: Key('choisir-${p.id}'),
                          value: p.id,
                          title: Text(p.nom),
                          subtitle: Text(resumePersonnage(widget.contexte, p)),
                        ),
                    ],
                  ),
                ),
              const SizedBox(height: 12),
              FilledButton.icon(
                key: const Key('envoyer-demande'),
                onPressed: _personnageId == null || _attente ? null : _demander,
                icon: const Icon(Icons.send_outlined),
                label: const Text('Envoyer la demande au MJ'),
              ),
              if (c.parametres.fichesVisiblesMj) ...[
                const SizedBox(height: 8),
                Text(
                  'Le MJ pourra consulter la fiche de ton personnage.',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}
