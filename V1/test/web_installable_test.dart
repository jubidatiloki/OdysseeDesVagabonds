import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Version web installable sur iPhone (09/11/2026) : nom, icône et
/// hébergement Firebase.
void main() {
  test('manifeste et page : nom, icône de l\'écran d\'accueil', () {
    final m = jsonDecode(File('web/manifest.json').readAsStringSync())
        as Map<String, dynamic>;
    expect(m['name'], 'L\'odyssée des vagabonds');
    expect(m['short_name'], 'Odyssée');
    expect(m['display'], 'standalone');
    for (final i in m['icons'] as List) {
      expect(File('web/${(i as Map)['src']}').existsSync(), isTrue);
    }
    final page = File('web/index.html').readAsStringSync();
    expect(page, contains('apple-mobile-web-app-capable'));
    expect(page, contains('icons/apple-touch-icon.png'));
    expect(File('web/icons/apple-touch-icon.png').existsSync(), isTrue);
  });

  test('Firebase Hosting publie build/web', () {
    final f = jsonDecode(File('firebase.json').readAsStringSync())
        as Map<String, dynamic>;
    final h = f['hosting'] as Map<String, dynamic>;
    expect(h['public'], 'build/web');
    expect(f['firestore'], isNotNull);
  });
}
