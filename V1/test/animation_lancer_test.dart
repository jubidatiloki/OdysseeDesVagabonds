import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:odyssee_vagabonds/screens/campagnes/seance_messages.dart';
import 'package:odyssee_vagabonds/widgets/animation_lancer.dart';

/// Animation de lancer de dés et heure des messages de séance (08/11/2026).
void main() {
  Future<BuildContext> ecran(WidgetTester tester,
      {bool sansAnimations = false}) async {
    late BuildContext contexte;
    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(disableAnimations: sansAnimations),
          child: Scaffold(
            body: Builder(
              builder: (context) {
                contexte = context;
                return const Center(child: Text('Page'));
              },
            ),
          ),
        ),
      ),
    );
    return contexte;
  }

  testWidgets('lancer : le dé roule, montre le résultat, puis disparaît',
      (tester) async {
    final contexte = await ecran(tester);
    AnimationLancer.montrer(contexte, total: 17, libelle: 'Force');
    await tester.pump();
    expect(find.byKey(const Key('animation-lancer')), findsOneWidget);
    // Fin du roulement : le total et le libellé sont affichés.
    await tester.pump(const Duration(milliseconds: 900));
    expect(find.text('17', findRichText: true), findsOneWidget);
    expect(find.text('Force', findRichText: true), findsOneWidget);
    // Les chiffres décoratifs ne gênent pas la lecture de l'écran.
    expect(find.text('17'), findsNothing);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('animation-lancer')), findsNothing);
  });

  testWidgets('deux lancers rapprochés : une seule animation', (tester) async {
    final contexte = await ecran(tester);
    AnimationLancer.montrer(contexte, total: 3, libelle: 'A');
    await tester.pump(const Duration(milliseconds: 300));
    AnimationLancer.montrer(contexte, total: 20, libelle: 'B', critique: true);
    await tester.pump();
    expect(find.byKey(const Key('animation-lancer')), findsOneWidget);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('animation-lancer')), findsNothing);
  });

  testWidgets('animations coupées sur l\'appareil : rien', (tester) async {
    final contexte = await ecran(tester, sansAnimations: true);
    AnimationLancer.montrer(contexte, total: 5, libelle: 'X');
    await tester.pump();
    expect(find.byKey(const Key('animation-lancer')), findsNothing);
  });

  test('heure d\'un message : heure seule le jour même, date sinon', () {
    final maintenant = DateTime(2026, 11, 8, 21, 30);
    expect(heureMessage(DateTime(2026, 11, 8, 9, 5), maintenant), '09:05');
    expect(
      heureMessage(DateTime(2026, 11, 7, 20, 15), maintenant),
      '07/11 · 20:15',
    );
  });
}
