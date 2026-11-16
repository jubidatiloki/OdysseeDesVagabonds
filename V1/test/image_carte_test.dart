import 'dart:math';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:odyssee_vagabonds/data/image_carte.dart';
import 'package:odyssee_vagabonds/models/campagne.dart';
import 'package:odyssee_vagabonds/models/carte_campagne.dart';

void main() {
  test('grande image PNG (transparente, bruitée) : réduite et légère',
      () async {
    final hasard = Random(1);
    final source = img.Image(width: 2400, height: 1200, numChannels: 4);
    for (final p in source) {
      p
        ..r = hasard.nextInt(256)
        ..g = hasard.nextInt(256)
        ..b = hasard.nextInt(256)
        ..a = hasard.nextBool() ? 255 : 0;
    }
    final png = Uint8List.fromList(img.encodePng(source));
    final r = await ImageCarte.preparer(png);
    // Plus grand côté ramené à 1600 px (ou moins si elle restait lourde).
    expect(r.largeur, lessThanOrEqualTo(ImageCarte.coteMax));
    expect(r.largeur / r.hauteur, closeTo(2, 0.01));
    expect(r.jpeg.length, lessThanOrEqualTo(ImageCarte.poidsCible));
    // Un vrai JPEG, relisible.
    final relue = img.decodeJpg(r.jpeg)!;
    expect((relue.width, relue.height), (r.largeur, r.hauteur));
  });

  test('petite image : taille gardée', () async {
    final source = img.Image(width: 400, height: 300)
      ..clear(img.ColorRgb8(120, 80, 40));
    final r = await ImageCarte.preparer(
      Uint8List.fromList(img.encodeJpg(source)),
    );
    expect((r.largeur, r.hauteur), (400, 300));
  });

  test('fichier illisible ou trop lourd : message clair', () async {
    await expectLater(
      ImageCarte.preparer(Uint8List.fromList([1, 2, 3, 4])),
      throwsA(isA<ErreurCampagne>()),
    );
    await expectLater(
      ImageCarte.preparer(Uint8List(ImageCarte.poidsSourceMax + 1)),
      throwsA(isA<ErreurCampagne>()),
    );
  });

  test('découpe en morceaux de moins de 1 Mo', () {
    final octets = Uint8List(ImageCarte.tailleMorceau * 2 + 10);
    final m = ImageCarte.decouper(octets);
    expect(m.map((x) => x.length),
        [ImageCarte.tailleMorceau, ImageCarte.tailleMorceau, 10]);
    expect(ImageCarte.decouper(Uint8List(5)), hasLength(1));
  });

  test('nom propre : sans extension, jamais vide, pas trop long', () {
    expect(CarteCampagne.nomPropre(' Forêt noire.PNG '), 'Forêt noire');
    expect(CarteCampagne.nomPropre('plan.jpeg'), 'plan');
    expect(CarteCampagne.nomPropre('  '), 'Carte');
    expect(CarteCampagne.nomPropre('x' * 200), hasLength(80));
    final c = CarteCampagne(
      id: 'a',
      nom: 'Port',
      largeur: 1600,
      hauteur: 1200,
      octets: 430080,
      ajouteeLe: DateTime(2026, 11, 16),
    );
    expect(c.resume, '1600 × 1200 · 420 Ko');
    final relue =
        CarteCampagne.depuisJson('a', c.copie(diffusee: true).versJson());
    expect((relue.nom, relue.diffusee, relue.octets), ('Port', true, 430080));
  });
}
