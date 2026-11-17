# L'odyssée des vagabonds

Application pour jouer à **L'odyssée des vagabonds**, un jeu de rôle maison à d20 dans un univers médiéval fantastique : créer et faire vivre ses personnages, lancer les dés, consulter les règles et mener des parties à plusieurs, en ligne.

Elle fonctionne sur **Android**, dans un **navigateur** (installable sur iPhone) et sur **Windows**.

## Essayer l'application

- **En ligne** (ordinateur, Android, iPhone) : https://odyssee-vagabonds.web.app. Sur iPhone, ouvrir le lien dans Safari, puis Partager → « Sur l'écran d'accueil ».
- **Android** : télécharger le fichier `.apk` de la [dernière version](https://github.com/jubidatiloki/OdysseeDesVagabonds/releases/latest), puis l'ouvrir sur le téléphone.
- **Version web à emporter** : télécharger le `.zip` de la même page, le dézipper et lancer `lancer.bat`.

## Ce qu'on peut faire

### Personnages
- **Création guidée** en 6 étapes : identité, race, classe, répartition des caractéristiques, compétences, récapitulatif. Chaque étape explique les règles.
- **Fiche complète**, calculée automatiquement :
  - caractéristiques et modificateurs ;
  - points de vie, de mana et d'endurance ;
  - classe d'armure, initiative ;
  - compétences et passifs ;
  - inventaire, équipement et argent ;
  - historique de tout ce qui arrive au personnage.
- **Montée de niveau** pas à pas.
- **Sauvegarde** : sur l'appareil, ou sur un compte en ligne pour retrouver ses fiches partout. Export et import d'une fiche, ou de toutes les fiches en un fichier.

### Dés et règles
- **Lancer de dé** relié à la fiche : tests de caractéristique, attaques, sorts, situations à cocher (avantage, terrain…).
- **Glossaire** : races, classes et leurs voies, compétences, équipements, bestiaire, afflictions et types de dégâts.
- **Règles système** consultables à tout moment.

### Campagnes et séances (avec un compte)
- **Le MJ crée une campagne** et invite ses joueurs avec un code. Chaque joueur la rejoint avec un personnage existant, ou en crée un sur le moment.
- **Séance en direct** :
  - PV, PM et PE de chacun à jour pour toute la table ;
  - combat au tour par tour, avec l'ordre d'initiative ;
  - créatures du bestiaire, alliés, compagnons et invocations ;
  - attaques et esquives, avec les dégâts appliqués automatiquement ;
  - butins, objets envoyés entre joueurs, messages privés avec le MJ.
- **Cartes** : le MJ importe ses cartes (PNG ou JPEG) et les diffuse aux joueurs pendant la séance.
- **Notes de séance** rédigées toutes seules : lieux, combats, montées de niveau. Le MJ choisit ce que les joueurs peuvent voir.

### Et aussi
- Thème sombre ou clair, écran « Nouveautés », et l'écran **« Donner son avis »** pour signaler un bug ou proposer une idée.

## Pour les développeurs

- Application **Flutter** (Dart), dans le dossier `V1/`. Données du jeu dans `V1/assets/data/`. Compte et parties en ligne avec **Firebase** (Authentication, Firestore, Hosting).
- Lancer : `cd V1`, puis `flutter pub get` et `flutter run`. Vérifier : `flutter analyze` et `flutter test`.
- Reprendre le projet sans connaître Flutter : [`REPRISE_DU_PROJET.md`](REPRISE_DU_PROJET.md). Suivi détaillé, règles du jeu tranchées et journal : [`AVANCEMENT.md`](AVANCEMENT.md).
