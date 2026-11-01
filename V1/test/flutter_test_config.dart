import 'dart:async';

import 'package:odyssee_vagabonds/widgets/cadre_classe.dart';

/// Configuration commune à tous les tests : effets animés des cadres de
/// classe coupés (une animation en boucle empêcherait `pumpAndSettle` de
/// se terminer).
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  CadreClasse.animationsAutorisees = false;
  await testMain();
}
