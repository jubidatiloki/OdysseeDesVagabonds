import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:odyssee_vagabonds/theme.dart';
import 'package:odyssee_vagabonds/widgets/cadre_classe.dart';
import 'package:odyssee_vagabonds/widgets/matieres_classe.dart';

void main() {
  testsAnimations();

  test('chaque classe des données a son habillage', () {
    final ids = [
      for (final c
          in jsonDecode(File('assets/data/classes.json').readAsStringSync())
              as List)
        (c as Map<String, dynamic>)['id'] as String,
    ];
    expect(ids, hasLength(12));
    for (final id in ids) {
      expect(StyleClasse.de(id), isNotNull, reason: id);
    }
    expect(StyleClasse.de('barbare')!.abime, isTrue);
    expect(StyleClasse.de('inconnue'), isNull);
  });

  for (final sombre in [true, false]) {
    testWidgets(
        'cadres et avatars des 12 classes dessinés sans erreur '
        '(${sombre ? 'sombre' : 'clair'})', (tester) async {
      tester.view.physicalSize = const Size(1000, 2400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      var touches = 0;
      await tester.pumpWidget(
        MaterialApp(
          theme: themeOdv(sombre ? Brightness.dark : Brightness.light),
          home: Scaffold(
            body: ListView(
              children: [
                for (final c in StyleClasse.parClasse.keys)
                  CadreClasse(
                    classeId: c,
                    selectionnee: c == 'barbare',
                    onTap: () => touches++,
                    child: Row(
                      children: [
                        AvatarClasse(nom: c, classeId: c),
                        const Expanded(child: SizedBox(height: 60)),
                      ],
                    ),
                  ),
                // Classe inconnue : carte de la charte
                const CadreClasse(classeId: 'x', child: Text('Sans classe')),
              ],
            ),
          ),
        ),
      );
      expect(tester.takeException(), isNull);
      expect(find.byKey(const Key('cadre-classe-barbare')), findsOneWidget);
      expect(find.byKey(const Key('embleme-classe')), findsNWidgets(12));
      expect(find.byType(CarteOdv), findsOneWidget);
      await tester.tap(find.byKey(const Key('cadre-classe-moine')));
      expect(touches, 1);
    });
  }
}

/// Horloge de l'effet du cadre de [classeId] (`null` : effet figé).
Animation<double>? _horloge(WidgetTester tester, String classeId) {
  final peintre = tester
      .widget<CustomPaint>(find.byKey(Key('effet-classe-$classeId')))
      .painter! as PeintreEffet;
  return peintre.horloge;
}

void testsAnimations() {
  testWidgets('effets animés : actifs, coupés par la préférence ou le système',
      (tester) async {
    CadreClasse.animationsAutorisees = true;
    addTearDown(() => CadreClasse.animationsAutorisees = false);
    Future<void> afficher({bool actives = true, bool systeme = false}) =>
        tester.pumpWidget(
          MediaQuery(
            data: MediaQueryData(disableAnimations: systeme),
            child: MaterialApp(
              home: AnimationsCadres(
                actives: actives,
                child: const Scaffold(
                  body: CadreClasse(
                    classeId: 'druide',
                    child: SizedBox(height: 80),
                  ),
                ),
              ),
            ),
          ),
        );

    await afficher();
    final h = _horloge(tester, 'druide')!;
    final avant = h.value;
    await tester.pump(const Duration(seconds: 1));
    expect(h.value, isNot(avant));
    expect(h.isAnimating, isTrue);

    // Préférence coupée : effet figé
    await afficher(actives: false);
    expect(_horloge(tester, 'druide'), isNull);

    // « Réduire les animations » du système
    await afficher(systeme: true);
    expect(_horloge(tester, 'druide'), isNull);

    await tester.pumpWidget(const SizedBox());
  });
}
