import 'package:flutter_test/flutter_test.dart';
import 'package:odyssee_vagabonds/app.dart';
import 'package:odyssee_vagabonds/data/personnage_repository.dart';
import 'package:odyssee_vagabonds/data/referentiel.dart';
import 'package:odyssee_vagabonds/models/personnage.dart';
import 'package:odyssee_vagabonds/state/personnages_controller.dart';

void main() {
  const referentielVide = Referentiel(races: [], classes: []);

  testWidgets("l'accueil affiche l'état vide", (tester) async {
    final controller = PersonnagesController(EnMemoirePersonnageRepository());
    await controller.charger();

    await tester.pumpWidget(
      OdvApp(referentiel: referentielVide, controller: controller),
    );
    await tester.pumpAndSettle();

    expect(find.text("Aucun personnage pour l'instant"), findsOneWidget);
  });

  testWidgets("l'accueil liste les personnages", (tester) async {
    final controller = PersonnagesController(
      EnMemoirePersonnageRepository([
        Personnage(id: '1', nom: 'Brom', raceId: 'nain', classeId: 'guerrier'),
      ]),
    );
    await controller.charger();

    await tester.pumpWidget(
      OdvApp(referentiel: referentielVide, controller: controller),
    );
    await tester.pumpAndSettle();

    expect(find.text('Brom'), findsOneWidget);
  });
}
