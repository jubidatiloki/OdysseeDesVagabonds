import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Lieu de sauvegarde des préférences (remplaçable dans les tests).
abstract class PreferencesStockage {
  Future<ThemeMode> lireTheme();
  Future<void> enregistrerTheme(ThemeMode theme);
  Future<bool> lireMenuEpingle();
  Future<void> enregistrerMenuEpingle(bool epingle);
  Future<String?> lirePersonnageActif();
  Future<void> enregistrerPersonnageActif(String? id);
  Future<bool> lireAnimations();
  Future<void> enregistrerAnimations(bool actives);

  /// Réglages simples par clé (page Lancer de dé…) ; `null` : effacé.
  Future<String?> lireReglage(String cle);
  Future<void> enregistrerReglage(String cle, String? valeur);
}

/// Affichage d'un groupe de jets de la page Lancer de dé à l'ouverture.
enum AffichageGroupe {
  visible('Visible'),
  cache('Caché'),
  memoriser('Comme la dernière fois');

  const AffichageGroupe(this.libelle);
  final String libelle;

  /// Sans réglage enregistré : caché (préférence par défaut du 31/10/2026).
  static AffichageGroupe depuisCode(String? code) {
    for (final a in values) {
      if (a.name == code) return a;
    }
    return cache;
  }
}

/// Groupes repliables de la page Lancer de dé.
enum GroupeJets {
  connaissances('Connaissances'),
  aptitudes('Aptitudes');

  const GroupeJets(this.libelle);
  final String libelle;
}

/// Dés proposés pour le lancer libre.
const List<int> facesDesLibres = [4, 6, 8, 10, 12, 20, 100];

/// Préférences sauvegardées sur l'appareil (localStorage sur le web).
class PreferencesLocales implements PreferencesStockage {
  static const String _cleTheme = 'odv.preferences.theme';
  static const String _cleMenuEpingle = 'odv.preferences.menuEpingle';
  static const String _clePersonnageActif = 'odv.preferences.personnageActif';
  static const String _cleAnimations = 'odv.preferences.animations';

  @override
  Future<String?> lireReglage(String cle) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('odv.preferences.$cle');
  }

  @override
  Future<void> enregistrerReglage(String cle, String? valeur) async {
    final prefs = await SharedPreferences.getInstance();
    if (valeur == null) {
      await prefs.remove('odv.preferences.$cle');
    } else {
      await prefs.setString('odv.preferences.$cle', valeur);
    }
  }

  @override
  Future<bool> lireAnimations() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_cleAnimations) ?? true;
  }

  @override
  Future<void> enregistrerAnimations(bool actives) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_cleAnimations, actives);
  }

  @override
  Future<ThemeMode> lireTheme() async {
    final prefs = await SharedPreferences.getInstance();
    return themeDepuisCode(prefs.getString(_cleTheme));
  }

  @override
  Future<void> enregistrerTheme(ThemeMode theme) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_cleTheme, theme.name);
  }

  @override
  Future<bool> lireMenuEpingle() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_cleMenuEpingle) ?? true;
  }

  @override
  Future<void> enregistrerMenuEpingle(bool epingle) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_cleMenuEpingle, epingle);
  }

  @override
  Future<String?> lirePersonnageActif() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_clePersonnageActif);
  }

  @override
  Future<void> enregistrerPersonnageActif(String? id) async {
    final prefs = await SharedPreferences.getInstance();
    if (id == null) {
      await prefs.remove(_clePersonnageActif);
    } else {
      await prefs.setString(_clePersonnageActif, id);
    }
  }
}

ThemeMode themeDepuisCode(String? code) {
  for (final t in ThemeMode.values) {
    if (t.name == code) return t;
  }
  return ThemeMode.dark; // thème par défaut de la charte graphique
}

/// Préférences de l'utilisateur : thème, menu latéral gardé ouvert sur grand
/// écran (page Préférences), personnage actif (accueil, Lancer de dé).
class PreferencesController extends ChangeNotifier {
  PreferencesController({
    ThemeMode theme = ThemeMode.dark,
    bool menuEpingle = false,
    String? personnageActifId,
    bool animations = true,
    this.stockage,
    int deDefaut = 20,
    Map<GroupeJets, AffichageGroupe> affichages = const {},
    Map<GroupeJets, bool> derniersOuverts = const {},
  })  : _deDefaut = facesDesLibres.contains(deDefaut) ? deDefaut : 20,
        _affichages = Map.of(affichages),
        _derniersOuverts = Map.of(derniersOuverts),
        _theme = theme,
        _menuEpingle = menuEpingle,
        _animations = animations,
        _personnageActifId = personnageActifId;

  /// `null` : préférences gardées en mémoire seulement (tests).
  final PreferencesStockage? stockage;

  ThemeMode _theme;
  ThemeMode get theme => _theme;

  bool _menuEpingle;

  /// Menu latéral toujours visible à gauche (sur grand écran seulement).
  bool get menuEpingle => _menuEpingle;

  bool _animations;

  /// Effets animés des cadres de classe (braises, brume, étoiles…).
  bool get animations => _animations;

  int _deDefaut;

  /// Dé du lancer libre à l'ouverture de la page Lancer de dé (d20).
  int get deDefaut => _deDefaut;

  final Map<GroupeJets, AffichageGroupe> _affichages;
  final Map<GroupeJets, bool> _derniersOuverts;

  /// Groupe ouvert ou caché à l'ouverture de la page Lancer de dé.
  AffichageGroupe affichage(GroupeJets g) =>
      _affichages[g] ?? AffichageGroupe.cache;

  /// Le groupe [g] est-il ouvert à l'arrivée sur la page Lancer de dé ?
  bool groupeOuvert(GroupeJets g) => switch (affichage(g)) {
        AffichageGroupe.visible => true,
        AffichageGroupe.cache => false,
        AffichageGroupe.memoriser => _derniersOuverts[g] ?? true,
      };

  static String _cleAffichage(GroupeJets g) => 'de.affichage.${g.name}';
  static String _cleOuvert(GroupeJets g) => 'de.ouvert.${g.name}';

  String? _personnageActifId;

  /// Personnage mis en évidence et utilisé par la page Lancer de dé
  /// (`null` : aucun).
  String? get personnageActifId => _personnageActifId;

  static Future<PreferencesController> charger(
    PreferencesStockage stockage,
  ) async {
    var theme = ThemeMode.dark;
    // Menu latéral gardé ouvert par défaut (sur grand écran seulement).
    var menuEpingle = true;
    String? personnageActifId;
    var animations = true;
    var deDefaut = 20;
    final affichages = <GroupeJets, AffichageGroupe>{};
    final ouverts = <GroupeJets, bool>{};
    try {
      theme = await stockage.lireTheme();
      menuEpingle = await stockage.lireMenuEpingle();
      personnageActifId = await stockage.lirePersonnageActif();
      animations = await stockage.lireAnimations();
      deDefaut =
          int.tryParse(await stockage.lireReglage('de.defaut') ?? '') ?? 20;
      for (final g in GroupeJets.values) {
        affichages[g] = AffichageGroupe.depuisCode(
            await stockage.lireReglage(_cleAffichage(g)));
        final o = await stockage.lireReglage(_cleOuvert(g));
        if (o != null) ouverts[g] = o == 'true';
      }
    } catch (_) {
      // Préférences illisibles : valeurs par défaut.
    }
    return PreferencesController(
      theme: theme,
      menuEpingle: menuEpingle,
      personnageActifId: personnageActifId,
      animations: animations,
      stockage: stockage,
      deDefaut: deDefaut,
      affichages: affichages,
      derniersOuverts: ouverts,
    );
  }

  Future<void> changerDeDefaut(int faces) async {
    if (faces == _deDefaut || !facesDesLibres.contains(faces)) return;
    _deDefaut = faces;
    notifyListeners();
    await stockage?.enregistrerReglage('de.defaut', '$faces');
  }

  Future<void> changerAffichage(GroupeJets g, AffichageGroupe a) async {
    if (a == affichage(g)) return;
    _affichages[g] = a;
    notifyListeners();
    await stockage?.enregistrerReglage(_cleAffichage(g), a.name);
  }

  /// Le groupe [g] vient d'être ouvert ou replié sur la page Lancer de dé :
  /// retenu pour la prochaine fois (utile en mode « comme la dernière
  /// fois »). Pas de notification : la page gère son propre affichage.
  Future<void> memoriserGroupe(GroupeJets g, bool ouvert) async {
    if (_derniersOuverts[g] == ouvert) return;
    _derniersOuverts[g] = ouvert;
    await stockage?.enregistrerReglage(_cleOuvert(g), '$ouvert');
  }

  /// Choisit le personnage actif (`null` : aucun).
  Future<void> changerPersonnageActif(String? id) async {
    if (id == _personnageActifId) return;
    _personnageActifId = id;
    notifyListeners();
    await stockage?.enregistrerPersonnageActif(id);
  }

  Future<void> changerTheme(ThemeMode theme) async {
    if (theme == _theme) return;
    _theme = theme;
    notifyListeners();
    await stockage?.enregistrerTheme(theme);
  }

  Future<void> changerAnimations(bool actives) async {
    if (actives == _animations) return;
    _animations = actives;
    notifyListeners();
    await stockage?.enregistrerAnimations(actives);
  }

  Future<void> changerMenuEpingle(bool epingle) async {
    if (epingle == _menuEpingle) return;
    _menuEpingle = epingle;
    notifyListeners();
    await stockage?.enregistrerMenuEpingle(epingle);
  }
}
