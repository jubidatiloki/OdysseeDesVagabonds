import 'package:flutter/material.dart';

import '../data/compte.dart';
import '../state/compte_controller.dart';
import '../widgets/consultation.dart';

/// Page « Compte » : sans compte, les personnages restent sur l'appareil ;
/// avec un compte (e-mail ou Google), ils sont sauvegardés en ligne et
/// retrouvés sur tous les appareils. Les fiches déjà créées sur l'appareil
/// sont envoyées sur le compte à la connexion.
class CompteScreen extends StatelessWidget {
  const CompteScreen({super.key, required this.compte, this.menu});

  final CompteController compte;
  final Widget? menu;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: menu,
      appBar: AppBar(title: const Text('Compte')),
      body: LargeurLimitee(
        child: ListenableBuilder(
          listenable: compte,
          builder: (context, _) => ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _EtatCompte(compte: compte),
              const SizedBox(height: 12),
              if (!compte.service.disponible)
                const BlocConsultation(
                  titre: 'Compte indisponible',
                  icone: Icons.cloud_off_outlined,
                  children: [
                    Text('La sauvegarde en ligne n\'existe que sur le '
                        'téléphone (Android) et la version web. Ici, les '
                        'personnages restent sur cet appareil.'),
                  ],
                )
              else if (compte.connecte) ...[
                _Synchronisation(compte: compte),
                _Connecte(compte: compte),
              ] else
                _Connexion(compte: compte),
            ],
          ),
        ),
      ),
    );
  }
}

/// Où sont les personnages (appareil, en ligne) et dernier compte rendu.
class _EtatCompte extends StatelessWidget {
  const _EtatCompte({required this.compte});

  final CompteController compte;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final u = compte.utilisateur;
    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        key: const Key('etat-compte'),
        leading: Icon(iconeSynchro(compte.etat), size: 32),
        title: Text(compte.etat.libelle),
        subtitle: Text([
          if (u == null)
            'Sans compte, tes personnages sont gardés sur cet appareil '
                'seulement. Crée un compte (ou connecte-toi) pour les '
                'sauvegarder en ligne et les retrouver sur tes autres '
                'appareils : ceux déjà créés ici seront envoyés.'
          else
            'Connecté : ${u.email ?? u.nom ?? 'compte Google'}. Tes '
                'personnages sont sauvegardés en ligne.',
          if (compte.message != null) compte.message!,
        ].join('\n\n')),
        subtitleTextStyle: theme.textTheme.bodyMedium
            ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        isThreeLine: true,
      ),
    );
  }
}

/// Icône de l'état de synchronisation (menu, page Compte).
IconData iconeSynchro(EtatSynchro e) => switch (e) {
      EtatSynchro.surAppareil => Icons.phone_android_outlined,
      EtatSynchro.envoi => Icons.cloud_sync_outlined,
      EtatSynchro.synchronise => Icons.cloud_done_outlined,
      EtatSynchro.enAttente => Icons.cloud_upload_outlined,
      EtatSynchro.erreur => Icons.cloud_off_outlined,
    };

/// Formulaire : e-mail + mot de passe, créer un compte, Google.
class _Connexion extends StatefulWidget {
  const _Connexion({required this.compte});

  final CompteController compte;

  @override
  State<_Connexion> createState() => _ConnexionState();
}

class _ConnexionState extends State<_Connexion> {
  final _email = TextEditingController();
  final _motDePasse = TextEditingController();
  bool _occupe = false;
  bool _masque = true;
  String? _erreur;
  String? _info;

  @override
  void dispose() {
    _email.dispose();
    _motDePasse.dispose();
    super.dispose();
  }

  Future<void> _agir(Future<void> Function() action, {String? info}) async {
    setState(() {
      _occupe = true;
      _erreur = null;
      _info = null;
    });
    try {
      await action();
      _info = info;
    } on ErreurCompte catch (e) {
      _erreur = e.message;
    } catch (e) {
      _erreur = 'Erreur inattendue : $e';
    }
    if (mounted) setState(() => _occupe = false);
  }

  bool _champsRemplis() {
    if (_email.text.trim().isEmpty || _motDePasse.text.isEmpty) {
      setState(() => _erreur = 'Indique ton e-mail et ton mot de passe.');
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final c = widget.compte;
    return BlocConsultation(
      titre: 'Se connecter ou créer un compte',
      icone: Icons.login,
      children: [
        TextField(
          key: const Key('compte-email'),
          controller: _email,
          enabled: !_occupe,
          keyboardType: TextInputType.emailAddress,
          autofillHints: const [AutofillHints.email],
          decoration: const InputDecoration(
            labelText: 'E-mail',
            prefixIcon: Icon(Icons.alternate_email),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          key: const Key('compte-mot-de-passe'),
          controller: _motDePasse,
          enabled: !_occupe,
          obscureText: _masque,
          autofillHints: const [AutofillHints.password],
          decoration: InputDecoration(
            labelText: 'Mot de passe (6 caractères au minimum)',
            prefixIcon: const Icon(Icons.lock_outline),
            suffixIcon: IconButton(
              tooltip: _masque ? 'Afficher' : 'Masquer',
              icon: Icon(_masque
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined),
              onPressed: () => setState(() => _masque = !_masque),
            ),
          ),
          onSubmitted: (_) {
            if (_champsRemplis()) {
              _agir(() => c.connexionEmail(_email.text, _motDePasse.text));
            }
          },
        ),
        if (_erreur != null) ...[
          const SizedBox(height: 12),
          Text(
            _erreur!,
            key: const Key('compte-erreur'),
            style: TextStyle(color: theme.colorScheme.error),
          ),
        ],
        if (_info != null) ...[
          const SizedBox(height: 12),
          Text(_info!, key: const Key('compte-info')),
        ],
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            FilledButton.icon(
              key: const Key('compte-connexion'),
              icon: const Icon(Icons.login),
              label: const Text('Se connecter'),
              onPressed: _occupe
                  ? null
                  : () {
                      if (_champsRemplis()) {
                        _agir(() =>
                            c.connexionEmail(_email.text, _motDePasse.text));
                      }
                    },
            ),
            OutlinedButton.icon(
              key: const Key('compte-creer'),
              icon: const Icon(Icons.person_add_alt),
              label: const Text('Créer un compte'),
              onPressed: _occupe
                  ? null
                  : () {
                      if (_champsRemplis()) {
                        _agir(
                            () => c.creerCompte(_email.text, _motDePasse.text));
                      }
                    },
            ),
            TextButton(
              key: const Key('compte-oubli'),
              onPressed: _occupe
                  ? null
                  : () {
                      if (_email.text.trim().isEmpty) {
                        setState(() => _erreur =
                            'Indique ton e-mail pour recevoir le lien.');
                        return;
                      }
                      _agir(() => c.motDePasseOublie(_email.text),
                          info: 'Un e-mail t\'a été envoyé pour choisir un '
                              'nouveau mot de passe.');
                    },
              child: const Text('Mot de passe oublié'),
            ),
          ],
        ),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 16),
          child: Divider(height: 1),
        ),
        OutlinedButton.icon(
          key: const Key('compte-google'),
          icon: const Icon(Icons.account_circle_outlined),
          label: const Text('Continuer avec Google'),
          onPressed: _occupe ? null : () => _agir(c.connexionGoogle),
        ),
        if (_occupe) ...[
          const SizedBox(height: 16),
          const LinearProgressIndicator(),
        ],
      ],
    );
  }
}

/// Compte connecté : réessayer l'envoi, se déconnecter, supprimer.
class _Connecte extends StatelessWidget {
  const _Connecte({required this.compte});

  final CompteController compte;

  Future<void> _supprimer(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer le compte ?'),
        content: const Text('Tes personnages sont recopiés sur cet appareil, '
            'puis effacés en ligne avec ton compte. Tu ne les retrouveras '
            'plus sur tes autres appareils.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            key: const Key('confirmer-suppression-compte'),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await compte.supprimerCompte();
    } on ErreurCompte catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.message)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsultation(
      titre: 'Mon compte',
      icone: Icons.account_circle_outlined,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            if (compte.etat == EtatSynchro.erreur)
              FilledButton.icon(
                key: const Key('compte-reessayer'),
                icon: const Icon(Icons.cloud_upload_outlined),
                label: const Text('Réessayer l\'envoi'),
                onPressed: compte.envoyerFichesLocales,
              ),
            OutlinedButton.icon(
              key: const Key('compte-deconnexion'),
              icon: const Icon(Icons.logout),
              label: const Text('Se déconnecter'),
              onPressed: compte.deconnexion,
            ),
            TextButton.icon(
              key: const Key('compte-supprimer'),
              icon: const Icon(Icons.delete_outline),
              label: const Text('Supprimer mon compte'),
              onPressed: () => _supprimer(context),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Une fois déconnecté, cet appareil ne montre plus les personnages '
          'du compte : reconnecte-toi pour les retrouver.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}

/// « 02/11/2026 à 19:42 ».
String dateHeure(DateTime d) {
  String deux(int n) => n.toString().padLeft(2, '0');
  return '${deux(d.day)}/${deux(d.month)}/${d.year} à '
      '${deux(d.hour)}:${deux(d.minute)}';
}

/// Synchronisation : date du dernier envoi, méthode de sauvegarde
/// (automatique : à chaque modification et / ou à chaque lancer de dé ;
/// manuelle), bouton « Synchroniser maintenant ».
class _Synchronisation extends StatefulWidget {
  const _Synchronisation({required this.compte});

  final CompteController compte;

  @override
  State<_Synchronisation> createState() => _SynchronisationState();
}

class _SynchronisationState extends State<_Synchronisation> {
  bool _envoi = false;

  Future<void> _synchroniser() async {
    setState(() => _envoi = true);
    final n = await widget.compte.synchroniser();
    if (!mounted) return;
    setState(() => _envoi = false);
    if (n == null) return; // message d'erreur dans la carte d'état
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(n == 0
          ? 'Tout est déjà à jour.'
          : '$n modification${n > 1 ? 's' : ''} envoyée${n > 1 ? 's' : ''}.'),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final c = widget.compte;
    final derniere = c.derniereSynchro;
    final attente = c.nbEnAttente;
    return BlocConsultation(
      titre: 'Synchronisation',
      icone: Icons.sync,
      children: [
        Text(
          derniere == null
              ? 'Dernière synchronisation : jamais'
              : 'Dernière synchronisation : ${dateHeure(derniere)}',
          key: const Key('derniere-synchro'),
          style: theme.textTheme.titleSmall,
        ),
        if (attente > 0)
          Text(
            '$attente modification${attente > 1 ? 's' : ''} en attente '
            'sur cet appareil',
            key: const Key('modifications-en-attente'),
            style: theme.textTheme.bodyMedium
                ?.copyWith(color: theme.colorScheme.primary),
          ),
        const SizedBox(height: 16),
        Text('Méthode de sauvegarde', style: theme.textTheme.titleSmall),
        const SizedBox(height: 8),
        SegmentedButton<bool>(
          key: const Key('methode-sauvegarde'),
          segments: const [
            ButtonSegment(
              value: true,
              icon: Icon(Icons.autorenew),
              label: Text('Automatique'),
            ),
            ButtonSegment(
              value: false,
              icon: Icon(Icons.touch_app_outlined),
              label: Text('Manuelle'),
            ),
          ],
          selected: {c.automatique},
          onSelectionChanged: (s) => c.regler(automatique: s.first),
        ),
        if (c.automatique) ...[
          CheckboxListTile(
            key: const Key('sauvegarde-modification'),
            contentPadding: EdgeInsets.zero,
            value: c.aChaqueModification,
            onChanged: (v) => c.regler(aChaqueModification: v),
            title: const Text('À chaque modification de personnage'),
            subtitle: const Text('Les changements partent aussitôt.'),
          ),
          CheckboxListTile(
            key: const Key('sauvegarde-lancer'),
            contentPadding: EdgeInsets.zero,
            value: c.aChaqueLancer,
            onChanged: (v) => c.regler(aChaqueLancer: v),
            title: const Text('À chaque lancer de dé (personnage actif)'),
            subtitle: const Text('Le lancer est noté dans l\'historique de '
                'la fiche (100 derniers lancers gardés), puis tout ce qui attendait '
                'est envoyé.'),
          ),
        ] else
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              'Les modifications restent sur cet appareil jusqu\'à ce que tu '
              'touches « Synchroniser maintenant ».',
              style: theme.textTheme.bodySmall,
            ),
          ),
        if (!c.envoiImmediat || attente > 0) ...[
          const SizedBox(height: 8),
          FilledButton.icon(
            key: const Key('synchroniser-maintenant'),
            icon: _envoi
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.cloud_upload_outlined),
            label: const Text('Synchroniser maintenant'),
            onPressed: _envoi ? null : _synchroniser,
          ),
        ],
      ],
    );
  }
}
