import 'package:flutter/material.dart';

import '../theme.dart';

/// Sous ce widget, les [ListeDetail] affichent le détail sur place (centre de
/// la séance : le Glossaire ne couvre pas les côtés).
class DetailSurPlace extends InheritedWidget {
  const DetailSurPlace({super.key, required super.child});

  static bool actif(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<DetailSurPlace>() != null;

  @override
  bool updateShouldNotify(DetailSurPlace oldWidget) => false;
}

/// Liste + détail (pages Classes, Races…).
///
/// - **Grand écran** (≥ [largeurMin]) : au départ, la liste est centrée ;
///   dès qu'un élément est choisi, la liste glisse à gauche et le détail
///   s'affiche à droite. Un autre clic dans la liste change le détail sans
///   revenir en arrière ; la croix referme le détail.
/// - **Téléphone** : un clic ouvre le détail dans une nouvelle page.
class ListeDetail<T> extends StatefulWidget {
  const ListeDetail({
    super.key,
    required this.elements,
    required this.nom,
    required this.sousTitre,
    required this.detail,
    this.contenu,
    this.couleurAvatar,
    this.entete,
    this.vide,
    this.largeurMin = 900,
    this.largeurListe = 360,
    this.detailEnPlace = false,
  });

  final List<T> elements;
  final String Function(T) nom;
  final String Function(T) sousTitre;

  /// Contenu du détail (une `ListView`), sans `Scaffold`.
  final Widget Function(T) detail;

  /// Remplace le sous-titre texte par un contenu riche (étiquettes…).
  final Widget Function(T)? contenu;

  /// Couleur de l'avatar de chaque élément (orange par défaut).
  final Color? Function(T)? couleurAvatar;

  /// Affiché au-dessus de la liste (recherche, filtres…).
  final Widget? entete;

  /// Affiché à la place de la liste quand elle est vide.
  final Widget? vide;

  final double largeurMin;
  final double largeurListe;

  /// Écran étroit : le détail remplace la liste sur place, au lieu d'ouvrir
  /// une nouvelle page (centre de la séance : les côtés restent visibles).
  final bool detailEnPlace;

  @override
  State<ListeDetail<T>> createState() => _ListeDetailState<T>();
}

class _ListeDetailState<T> extends State<ListeDetail<T>> {
  static const _duree = Duration(milliseconds: 250);
  static const _largeurListeSeule = 760.0;

  T? _choix;

  bool get _surPlace => widget.detailEnPlace || DetailSurPlace.actif(context);

  void _ouvrirPage(BuildContext context, T e) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => Scaffold(
          appBar: AppBar(
            title: Text(
              widget.nom(e),
              style: const TextStyle(fontFamily: kPoliceAmbiance),
            ),
          ),
          body: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: SelectionArea(child: widget.detail(e)),
            ),
          ),
        ),
      ),
    );
  }

  Widget _liste(BuildContext context, {required bool grand}) {
    final scheme = Theme.of(context).colorScheme;
    return ListView.separated(
      key: const Key('liste-detail-liste'),
      padding: const EdgeInsets.all(16),
      itemCount: widget.elements.length +
          (widget.entete != null ? 1 : 0) +
          (widget.elements.isEmpty && widget.vide != null ? 1 : 0),
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, i) {
        var k = i;
        if (widget.entete != null) {
          if (k == 0) return widget.entete!;
          k--;
        }
        if (widget.elements.isEmpty) return widget.vide!;
        final e = widget.elements[k];
        final choisi = grand && e == _choix;
        return Card(
          margin: EdgeInsets.zero,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: choisi ? OdvCouleurs.accent : scheme.outlineVariant,
              width: choisi ? 2 : 1,
            ),
          ),
          color: choisi ? scheme.primaryContainer : null,
          child: ListTile(
            leading: AvatarPersonnage(
              nom: widget.nom(e),
              rayon: 20,
              couleur: widget.couleurAvatar?.call(e),
            ),
            title: Text(
              widget.nom(e),
              style: const TextStyle(
                fontFamily: kPoliceAmbiance,
                fontWeight: FontWeight.w700,
              ),
            ),
            subtitle: widget.contenu != null
                ? Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: widget.contenu!(e),
                  )
                : Text(widget.sousTitre(e)),
            trailing: Icon(
              Icons.chevron_right,
              color: choisi ? OdvCouleurs.accent : null,
            ),
            onTap: () => grand || _surPlace
                ? setState(() => _choix = e)
                : _ouvrirPage(context, e),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, contraintes) {
        final grand = !DetailSurPlace.actif(context) &&
            contraintes.maxWidth >= widget.largeurMin;
        if (!grand) {
          final choisi = _choix;
          if (_surPlace && choisi != null) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _EnteteDetail(
                  titre: widget.nom(choisi),
                  onFermer: () => setState(() => _choix = null),
                ),
                Expanded(child: widget.detail(choisi)),
              ],
            );
          }
          return Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: _largeurListeSeule),
              child: _liste(context, grand: false),
            ),
          );
        }
        final choix = _choix;
        // Liste centrée tant que rien n'est choisi, puis glissée à gauche.
        final largeur = choix == null
            ? _largeurListeSeule.clamp(0.0, contraintes.maxWidth)
            : widget.largeurListe;
        final marge =
            choix == null ? (contraintes.maxWidth - largeur) / 2 : 0.0;
        final largeurDetail = contraintes.maxWidth - widget.largeurListe - 1;
        return Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AnimatedContainer(
              duration: _duree,
              curve: Curves.easeOutCubic,
              margin: EdgeInsets.only(left: marge),
              width: largeur,
              child: _liste(context, grand: true),
            ),
            if (choix != null) ...[
              const VerticalDivider(width: 1),
              Expanded(
                // Le détail est toujours mis en page à sa largeur finale
                // (et rogné) : pas de débordement pendant que la liste
                // glisse vers la gauche.
                child: ClipRect(
                  child: OverflowBox(
                    alignment: Alignment.topLeft,
                    minWidth: largeurDetail,
                    maxWidth: largeurDetail,
                    child: AnimatedSwitcher(
                      duration: _duree,
                      child: KeyedSubtree(
                        key: ValueKey(choix),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _EnteteDetail(
                              titre: widget.nom(choix),
                              onFermer: () => setState(() => _choix = null),
                            ),
                            Expanded(
                              child: Align(
                                alignment: Alignment.topCenter,
                                child: ConstrainedBox(
                                  constraints:
                                      const BoxConstraints(maxWidth: 900),
                                  child: widget.detail(choix),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

/// Titre du détail (grand écran) avec une croix pour le refermer.
class _EnteteDetail extends StatelessWidget {
  const _EnteteDetail({required this.titre, required this.onFermer});

  final String titre;
  final VoidCallback onFermer;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 12, 0),
      child: Row(
        children: [
          Expanded(
            child: Text(
              titre,
              key: const Key('titre-detail'),
              style: styleAmbiance(theme.textTheme.headlineSmall)
                  .copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          IconButton(
            key: const Key('fermer-detail'),
            tooltip: 'Fermer',
            onPressed: onFermer,
            icon: const Icon(Icons.close),
          ),
        ],
      ),
    );
  }
}
