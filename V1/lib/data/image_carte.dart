import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;

import '../models/campagne.dart';

/// Préparation des images de cartes avant l'envoi (16/11/2026) : la base en
/// ligne garde des documents de 1 Mo au plus, et chaque lecture compte.
/// L'image (PNG ou JPEG) est réduite à [coteMax] pixels sur son plus grand
/// côté, puis enregistrée en JPEG, assez compressée pour peser moins de
/// [poidsCible] octets.
abstract final class ImageCarte {
  /// Fichier refusé au-delà (avant réduction).
  static const int poidsSourceMax = 20 * 1024 * 1024;

  /// Plus grand côté de l'image envoyée, en pixels.
  static const int coteMax = 1600;

  /// Poids visé de l'image envoyée.
  static const int poidsCible = 700 * 1024;

  /// Taille d'un morceau rangé en ligne (un document par morceau).
  static const int tailleMorceau = 900 * 1024;

  /// Prépare l'image ; [ErreurCampagne] si elle est illisible ou trop
  /// lourde. Sur téléphone, le calcul se fait à part (l'écran ne fige pas).
  static Future<({Uint8List jpeg, int largeur, int hauteur})> preparer(
    Uint8List source,
  ) async {
    if (source.length > poidsSourceMax) {
      throw const ErreurCampagne(
        'Image trop lourde (20 Mo au plus) : réduis-la avant de l\'importer.',
      );
    }
    final r = kIsWeb ? _preparer(source) : await compute(_preparer, source);
    if (r == null) {
      throw const ErreurCampagne(
        'Image illisible : choisis un fichier PNG ou JPEG.',
      );
    }
    return r;
  }

  static ({Uint8List jpeg, int largeur, int hauteur})? _preparer(
    Uint8List source,
  ) {
    final img.Image? lue;
    try {
      lue = img.decodeImage(source);
    } catch (_) {
      return null;
    }
    if (lue == null) return null;
    var image = lue;
    // Transparence (PNG) : posée sur un fond blanc, le JPEG n'en a pas.
    if (image.hasAlpha) {
      final fond = img.Image(width: image.width, height: image.height)
        ..clear(img.ColorRgb8(255, 255, 255));
      image = img.compositeImage(fond, image);
    }
    var cote = coteMax;
    while (true) {
      final reduite = image.width > cote || image.height > cote
          ? img.copyResize(
              image,
              width: image.width >= image.height ? cote : null,
              height: image.height > image.width ? cote : null,
              interpolation: img.Interpolation.average,
            )
          : image;
      for (var qualite = 85; qualite >= 45; qualite -= 10) {
        final jpeg = img.encodeJpg(reduite, quality: qualite);
        if (jpeg.length <= poidsCible || (qualite <= 45 && cote <= 800)) {
          return (
            jpeg: Uint8List.fromList(jpeg),
            largeur: reduite.width,
            hauteur: reduite.height,
          );
        }
      }
      // Toujours trop lourde : plus petite.
      cote = (cote * 0.75).round();
    }
  }

  /// Découpe l'image en morceaux (un document en ligne chacun).
  static List<Uint8List> decouper(Uint8List octets) => [
        for (var i = 0; i < octets.length; i += tailleMorceau)
          Uint8List.sublistView(
            octets,
            i,
            i + tailleMorceau > octets.length
                ? octets.length
                : i + tailleMorceau,
          ),
      ];
}
