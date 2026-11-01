import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:odyssee_vagabonds/theme.dart';

void main() {
  test('charte graphique : thème sombre', () {
    final t = themeOdv(Brightness.dark);
    expect(t.colorScheme.primary, OdvCouleurs.accent);
    // Palette « Taverne » : fond brun-noir, barre du haut sombre.
    expect(t.scaffoldBackgroundColor, OdvCouleurs.fond);
    expect(t.appBarTheme.backgroundColor, OdvCouleurs.carte);
    expect(t.floatingActionButtonTheme.backgroundColor, OdvCouleurs.accent);
  });

  test('charte graphique : thème clair parchemin', () {
    final t = themeOdv(Brightness.light);
    expect(t.scaffoldBackgroundColor, OdvCouleurs.parchemin);
    // Orange foncé pour les textes et liens sur fond clair.
    expect(t.colorScheme.primary, OdvCouleurs.accentDark);
  });

  test('couleurs du jeu : PV vert clair, PM bleu clair', () {
    expect(kCouleurPv, const Color(0xFF83CA7F));
    expect(kCouleurPm, const Color(0xFF7FA6DE));
  });

  test('jauge PV : vert, or puis rouge selon l\'état', () {
    expect(couleurPv(0.8), OdvCouleurs.lightGreen);
    expect(couleurPv(0.4), OdvCouleurs.or);
    expect(couleurPv(0.1), OdvCouleurs.lightRed);
  });

  test('modificateur : vert si positif, rouge si négatif', () {
    expect(couleurModificateur(2, Brightness.dark), OdvCouleurs.lightGreen);
    expect(couleurModificateur(-1, Brightness.dark), OdvCouleurs.lightRed);
    expect(
      couleurModificateur(0, Brightness.dark),
      OdvCouleurs.texteSecondaire,
    );
  });
}
