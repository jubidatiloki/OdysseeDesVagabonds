import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:odyssee_vagabonds/data/compte.dart';
import 'package:odyssee_vagabonds/data/personnage_repository.dart';
import 'package:odyssee_vagabonds/data/retours.dart';
import 'package:odyssee_vagabonds/models/retour.dart';
import 'package:odyssee_vagabonds/screens/retours_screen.dart';
import 'package:odyssee_vagabonds/state/compte_controller.dart';
import 'package:odyssee_vagabonds/state/personnages_controller.dart';
import 'package:odyssee_vagabonds/version.dart';
import 'package:odyssee_vagabonds/widgets/menu_lateral.dart';

class _Compte implements ServiceCompte {
  _Compte(this._actuel);

  final Utilisateur? _actuel;

  @override
  bool get disponible => true;
  @override
  Utilisateur? get actuel => _actuel;
  @override
  Stream<Utilisateur?> get changements => const Stream.empty();
  @override
  Future<void> connexionEmail(String email, String motDePasse) async {}
  @override
  Future<void> creerCompte(String email, String motDePasse) async {}
  @override
  Future<void> connexionGoogle() async {}
  @override
  Future<void> motDePasseOublie(String email) async {}
  @override
  Future<void> deconnexion() async {}
  @override
  Future<void> supprimerCompte() async {}
}

Future<CompteController> _compte(Utilisateur? u) async {
  final personnages = PersonnagesController(EnMemoirePersonnageRepository());
  await personnages.charger();
  final compte = CompteController(
    service: _Compte(u),
    personnages: personnages,
    local: personnages.repository,
    depotEnLigne: (_) => EnMemoireDepotEnLigne(const []),
  );
  await compte.demarrer();
  return compte;
}

void main() {
  test('retour : seulement les champs permis par les règles en ligne', () {
    final r = Retour(
      type: TypeRetour.idee,
      texte: 'Un mode nuit',
      auteur: 'u1',
      version: '1.0.0',
      plateforme: 'web',
      date: DateTime(2026, 11, 18),
    );
    expect(r.versJson().keys, isNot(contains('email')));
    expect(r.versJson()['type'], 'idee');
    const permis = {
      'type', 'texte', 'auteur', 'nom', 'email', 'version', 'plateforme',
      'date', //
    };
    final complet = Retour(
      type: TypeRetour.bug,
      texte: 'x',
      auteur: 'u1',
      nom: 'Léa',
      version: '1',
      plateforme: 'android',
      date: DateTime(2026),
    ).versJson();
    expect(permis.containsAll(complet.keys), isTrue);
    expect(TypeRetour.depuisCode('rien'), TypeRetour.autre);
    // Entrée du menu latéral.
    expect(Section.retours.libelle, 'Donner son avis');
  });

  testWidgets('avec un compte : le retour part, avec la version',
      (tester) async {
    final compte = await _compte(
      const Utilisateur(uid: 'u1', nom: 'Léa', email: 'lea@exemple.fr'),
    );
    final service = ServiceRetoursMemoire();
    await tester.pumpWidget(MaterialApp(
      home: RetoursScreen(compte: compte, service: service),
    ));
    final envoyer = find.byKey(const Key('envoyer-retour'));
    // Texte vide : envoi impossible.
    expect(tester.widget<FilledButton>(envoyer).onPressed, isNull);
    await tester.tap(find.byKey(const Key('type-retour-idee')));
    await tester.enterText(
        find.byKey(const Key('texte-retour')), '  Un mode nuit  ');
    // Plus de case « Me répondre par e-mail » (18/11/2026).
    expect(find.byKey(const Key('retour-email')), findsNothing);
    await tester.pump();
    await tester.tap(envoyer);
    await tester.pumpAndSettle();
    final r = service.envoyes.single;
    expect((r.type, r.texte, r.auteur, r.nom, r.version),
        (TypeRetour.idee, 'Un mode nuit', 'u1', 'Léa', kVersionApp));
    expect(find.text('Merci ! Ton retour est bien arrivé.'), findsOneWidget);
    // Champ vidé ; un second envoi tout de suite est refusé.
    await tester.enterText(find.byKey(const Key('texte-retour')), 'Encore');
    await tester.pump();
    await tester.tap(envoyer);
    await tester.pumpAndSettle();
    expect(service.envoyes, hasLength(1));
    expect(find.textContaining('Patiente'), findsOneWidget);
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
  });

  testWidgets('sans compte : invitation à se connecter, texte à copier',
      (tester) async {
    final compte = await _compte(null);
    // Presse-papiers simulé : il garde le texte copié.
    String? copie;
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (appel) async {
        if (appel.method == 'Clipboard.setData') {
          copie = (appel.arguments as Map)['text'] as String?;
        }
        return null;
      },
    );
    addTearDown(() => tester.binding.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null));
    await tester.pumpWidget(MaterialApp(home: RetoursScreen(compte: compte)));
    expect(find.byKey(const Key('retour-sans-compte')), findsOneWidget);
    expect(find.byKey(const Key('envoyer-retour')), findsNothing);
    await tester.enterText(find.byKey(const Key('texte-retour')), 'Bug');
    await tester.pump();
    await tester.tap(find.byKey(const Key('copier-retour')));
    await tester.pumpAndSettle();
    expect(find.textContaining('Texte copié'), findsOneWidget);
    expect(copie, contains('Bug'));
    expect(copie, contains(kVersionApp));
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
  });
}
