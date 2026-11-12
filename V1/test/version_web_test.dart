import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Version web : la dernière version s'ouvre dès le premier lancement
/// (12/11/2026), sans copie gardée par un « service worker ».
void main() {
  test('démarrage sans service worker', () {
    final bootstrap = File('web/flutter_bootstrap.js').readAsStringSync();
    expect(bootstrap, contains('{{flutter_js}}'));
    expect(bootstrap, contains('{{flutter_build_config}}'));
    expect(bootstrap, isNot(contains('serviceWorkerSettings')));
  });

  test('la page retire l\'ancien service worker avant de démarrer', () {
    final index = File('web/index.html').readAsStringSync();
    expect(index, contains('unregister()'));
    expect(index, contains("k.startsWith('flutter-')"));
    expect(index, contains('location.reload()'));
    expect(index, contains("'flutter_bootstrap.js'"));
  });

  test('construction web sans service worker, serveur sans cache', () {
    for (final f in ['construire_web.bat', 'publier_web.bat']) {
      expect(File(f).readAsStringSync(), contains('--pwa-strategy=none'),
          reason: f);
    }
    expect(File('distribution/web/serveur.ps1').readAsStringSync(),
        contains('no-cache'));
  });
}
