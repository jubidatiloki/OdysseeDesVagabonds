import 'classe.dart';
import 'voie.dart';

/// Famille d'une aptitude (règles §5.5) : savoir (connaissance) ou
/// savoir-faire (action) ; `autre` : maîtrises, langues, domaine libre.
enum FamilleAptitude {
  savoir('savoir', 'Savoirs', 'Connaissances'),
  savoirFaire('savoir-faire', 'Savoir-faire', 'Aptitudes et actions'),
  autre('', 'Maîtrises et autres', 'Armes, instruments, langues…');

  const FamilleAptitude(this.code, this.libelle, this.sousTitre);

  final String code;
  final String libelle;
  final String sousTitre;

  static FamilleAptitude depuisCode(String? code) {
    final c = (code ?? '').trim().toLowerCase();
    for (final f in values) {
      if (f != autre && (c == f.code || c == f.libelle.toLowerCase())) {
        return f;
      }
    }
    return autre;
  }
}

/// Aptitude ou connaissance achetable avec 1 point de compétence
/// (natation, langue, maîtrise d'une arme…). Règles §5.4 et §5.5.
class Aptitude {
  const Aptitude({
    required this.id,
    required this.nom,
    this.description = '',
    this.question,
    this.multiple = false,
    this.inneeSiIntAuMoins,
    this.liste = '',
    this.sort,
    this.classes = const [],
    this.famille = FamilleAptitude.autre,
    this.complexe = false,
    this.carac = '',
    this.race = '',
  });

  /// Connaissance d'un peuple : innée pour un personnage de cette race (id).
  final String race;

  /// Acquise d'office par un personnage de race [raceId] et d'INT [intel].
  bool estInnee({required String raceId, required int intel}) =>
      (race.isNotEmpty && race == raceId) ||
      (inneeSiIntAuMoins != null && intel >= inneeSiIntAuMoins!);

  final String id;
  final String nom;
  final String description;

  /// Savoir, savoir-faire ou autre.
  final FamilleAptitude famille;

  /// Complexe : −5 aux tests liés sans la maîtrise ; basique : pas de malus.
  final bool complexe;

  /// Caractéristique du test (« INT », « DEX »…) ; vide si non précisée.
  final String carac;

  /// « Savoir basique · INT », « Savoir-faire complexe · DEX ».
  String get resume => [
        if (famille != FamilleAptitude.autre)
          '${famille == FamilleAptitude.savoir ? 'Savoir' : 'Savoir-faire'} '
              '${complexe ? 'complexe' : 'basique'}',
        if (carac.isNotEmpty) carac,
      ].join(' · ');

  /// Effet en jeu : +5 aux tests liés ; −5 sans la maîtrise si complexe.
  String get regle => famille == FamilleAptitude.autre
      ? ''
      : complexe
          ? '+5 aux tests liés · −5 sans la maîtrise'
          : '+5 aux tests liés · pas de malus sans';

  /// Question posée à l'achat pour préciser (« Quelle langue ? »).
  /// `null` si l'aptitude n'a pas besoin de précision.
  final String? question;

  /// Peut-on la prendre plusieurs fois (plusieurs langues, plusieurs armes) ?
  final bool multiple;

  /// Aptitude acquise d'office si l'INT finale atteint cette valeur
  /// (lire et écrire : INT ≥ 10).
  final int? inneeSiIntAuMoins;

  /// Liste de choix pour la précision (`langues` : liste déroulante des
  /// langues du monde, « Autre… » possible).
  final String liste;

  /// Sort de rang 0 (1 point, 0 PM) : la compétence obtenue ; `null` pour
  /// une aptitude ordinaire.
  final Competence? sort;

  /// Sort de rang 0 réservé à ces classes (ids) ; vide : toutes les classes
  /// magiques ou hybrides.
  final List<String> classes;

  bool get estSort => sort != null;

  /// Peut-elle être prise par [classe] ? Les sorts de rang 0 : classes
  /// lanceuses de sorts ou hybrides (et celles de [classes] s'il y en a).
  bool disponiblePour(Classe classe) =>
      !estSort ||
      (classe.profil != ProfilClasse.physique &&
          (classes.isEmpty || classes.contains(classe.id)));

  bool get demandePrecision => question != null;

  factory Aptitude.depuisJson(Map<String, dynamic> j) => Aptitude(
        id: j['id'] as String,
        nom: j['nom'] as String? ?? '',
        description: j['description'] as String? ?? '',
        question: j['question'] as String?,
        multiple: j['multiple'] as bool? ?? false,
        inneeSiIntAuMoins: (j['inneeSiIntAuMoins'] as num?)?.toInt(),
        liste: j['liste'] as String? ?? '',
        famille: FamilleAptitude.depuisCode(j['famille'] as String?),
        complexe: j['complexe'] as bool? ?? false,
        carac: (j['carac'] as String? ?? '').trim().toUpperCase(),
        race: j['race'] as String? ?? '',
        sort: j['sort'] is Map<String, dynamic>
            ? Competence.depuisJson({
                'rang': 0,
                'nom': j['nom'],
                ...j['sort'] as Map<String, dynamic>,
              })
            : null,
        classes: [
          for (final c in j['classes'] as List<dynamic>? ?? const []) '$c',
        ],
      );
}

/// Aptitude achetée par un personnage, avec sa précision éventuelle
/// (ex. id `langue`, précision `Elfique`).
class AptitudeAcquise {
  const AptitudeAcquise({required this.id, this.precision});

  final String id;
  final String? precision;

  Map<String, dynamic> versJson() => {
        'id': id,
        if (precision != null) 'precision': precision,
      };

  factory AptitudeAcquise.depuisJson(Map<String, dynamic> j) =>
      _convertir(j['id'] as String, j['precision'] as String?) ??
      AptitudeAcquise(
        id: j['id'] as String,
        precision: j['precision'] as String?,
      );

  /// Anciennes sauvegardes (avant le 25/10/2026) : « Une race » et
  /// « Artisanat » avec une précision deviennent l'entrée distincte
  /// correspondante (« Peuple nain », « Couture »…) ; `null` sinon.
  static AptitudeAcquise? _convertir(String id, String? precision) {
    final p = (precision ?? '')
        .toLowerCase()
        .replaceAll(RegExp('[éèê]'), 'e')
        .replaceAll(' ', '-');
    if (p.isEmpty) return null;
    String? nouvel;
    if (id == 'connaissance-race') {
      for (final (cle, race) in const [
        ('demi-elfe', 'demi-elfe'),
        ('demi-orque', 'demi-orque'),
        ('orque', 'demi-orque'),
        ('draco', 'draconien'),
        ('sylva', 'elfe-sylvain'),
        ('haut', 'haut-elfe'),
        ('gnome', 'gnome'),
        ('humain', 'humain'),
        ('nain', 'nain'),
      ]) {
        if (p.contains(cle)) {
          nouvel = 'connaissance-$race';
          break;
        }
      }
    } else if (id == 'artisanat') {
      for (final (cle, artisanat) in const [
        ('cout', 'couture'),
        ('menuis', 'menuiserie'),
        ('bois', 'menuiserie'),
        ('joail', 'joaillerie'),
        ('bijou', 'joaillerie'),
        ('cuir', 'maroquinerie'),
        ('maroquin', 'maroquinerie'),
        ('poter', 'poterie'),
        ('tiss', 'tissage'),
      ]) {
        if (p.contains(cle)) {
          nouvel = artisanat;
          break;
        }
      }
    }
    return nouvel == null ? null : AptitudeAcquise(id: nouvel);
  }

  @override
  bool operator ==(Object other) =>
      other is AptitudeAcquise &&
      other.id == id &&
      other.precision == precision;

  @override
  int get hashCode => Object.hash(id, precision);
}
