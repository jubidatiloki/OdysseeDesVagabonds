# L'odyssée des vagabonds — reprendre le projet

Ce document explique l'application de A à Z à une personne qui ne connaît pas Flutter et qui reprend le projet. Il n'exige que des bases de programmation.

**Ce qu'il ne remplace pas :**

| Document | Contenu |
|---|---|
| `AVANCEMENT.md` | Source de vérité : ce qui est fait, ce qui reste, journal, **règles de jeu tranchées (§7)** |
| `CLAUDE.md` | Consignes de travail du projet (versions, Git, pièges), aussi lues par l'assistant Claude Code |
| `ressources/CHARTE_GRAPHIQUE.md` | Couleurs, polices, composants et décisions de design |
| `ressources/01_REGLES_GENERALES.md`, `CLASSES.md`, `stats.txt` | Règles du jeu d'origine |

---

## 1. L'application en bref

Une application de **création et de gestion de personnages** pour un jeu de rôle maison à d20, en français. Elle sert aussi à jouer à plusieurs, avec un maître du jeu (MJ) et des personnages joueurs (PJ).

**Ce qu'elle fait :**

- **Personnages** : création en étapes, fiche, compétences, inventaire, notes, historique, montée de niveau.
- **Lancer de dé** : tests, attaques, sorts, avec les bonus déjà calculés.
- **Glossaire** : classes, races, compétences, aptitudes, équipements, bestiaire. **Règles système** : les règles consultables.
- **Compte** (Firebase) : personnages sauvegardés en ligne et retrouvés sur plusieurs appareils.
- **Campagnes** : un MJ crée une campagne, invite des joueurs par un code, et lance des **séances** : tours de combat, créatures, jets partagés ou cachés, dégâts, messagerie privée.
- **Hors connexion** : tout sauf les campagnes et les séances fonctionne sans internet.

**Plateformes :**

| Plateforme | Compte en ligne | Remarque |
|---|---|---|
| Web | Oui | Le zip contient un petit serveur local (`lancer.bat`) |
| Android | Oui | APK à installer à la main, pas de Play Store |
| Windows | Non | Personnages sur l'appareil uniquement |

---

## 2. Flutter en dix minutes

**Flutter** est un outil de Google qui produit, à partir d'un seul code, une application web, Android et Windows. Le langage s'appelle **Dart** ; il ressemble à Java ou TypeScript.

| Mot | Signification |
|---|---|
| **Widget** | Un morceau d'écran (bouton, texte, colonne, page entière). Toute l'interface est un arbre de widgets imbriqués |
| `StatelessWidget` | Widget sans mémoire : il se dessine à partir de ce qu'on lui donne |
| `StatefulWidget` | Widget avec un état interne ; `setState(...)` le redessine |
| `build()` | La méthode qui décrit à quoi ressemble un widget. Flutter la rappelle quand il faut redessiner |
| `ChangeNotifier` | Objet qui contient des données et prévient les écrans quand elles changent (`notifyListeners()`) |
| `ListenableBuilder` | Widget qui se redessine quand un `ChangeNotifier` prévient |
| `Stream` | Flux de valeurs dans le temps. Sert ici à suivre Firestore en direct |
| `Future` / `async` / `await` | Résultat qui arrivera plus tard (lecture, réseau) |
| `Navigator` | La pile des pages : `push` ouvre, `pop` revient |
| `pubspec.yaml` | Fiche du projet : nom, version, dépendances, polices, fichiers embarqués |
| Package | Bibliothèque externe, listée dans `pubspec.yaml` |

Un bon exemple simple à lire pour commencer : `V1/lib/screens/a_propos_screen.dart`.

**Rechargement.** Avec une commande `flutter run`, `r` recharge vite le code et `R` redémarre l'application. Après l'ajout d'un champ à un modèle, `r` provoque un écran rouge « type 'Null' is not a subtype… » : ce n'est pas un bug, il faut faire `R`. Après une modification d'un fichier `assets/data/*.json`, il faut relancer complètement `lancer_web.bat`.

**Rectangle gris ou rouge.** Quand un widget plante, Flutter affiche un rectangle rouge en développement et **gris** dans la version construite. Il y a alors une vraie erreur, à lire dans la console.

---

## 3. Installer le poste de travail

Le projet a été développé sous Windows.

1. **Git**, puis récupérer le code : https://github.com/jubidatiloki/OdysseeDesVagabonds, branche **`odv-2026`**.
2. **Flutter 3.38** : https://docs.flutter.dev/get-started/install. Vérifier avec `flutter doctor`.
3. **Android Studio** (pour construire l'APK) : il installe le SDK Android.
4. **JDK 17** (Eclipse Temurin). Java 25 ne fonctionne pas avec Android. `construire_apk.bat` le cherche tout seul.
5. **Node.js + Firebase CLI** (pour déployer les règles) : `npm install -g firebase-tools`, puis `firebase login`.
6. **GitHub CLI** (`gh`) pour publier les releases.

Puis, dans le dossier `V1` :

```bash
flutter pub get
flutter analyze
flutter test
```

Les trois doivent se terminer sans erreur.

> Le dossier `flutter/` à la racine est une copie locale du SDK. Il est ignoré par Git : il n'y a pas à s'en servir.

---

## 4. Les commandes du quotidien

Tous les scripts sont dans `V1/`.

| Script | Rôle |
|---|---|
| `verifier.bat` | Analyse et tests, résultat dans `verification.log` |
| `lancer_web.bat` | Lance l'application sur **http://localhost:8080** |
| `lancer_telephone.bat` | La rend accessible à un téléphone sur le même Wi-Fi |
| `construire_web.bat` | Crée `livraison/odyssee_vagabonds_web_<version>.zip` |
| `construire_apk.bat` | Crée `livraison/odyssee_vagabonds.apk` (à renommer avec la version pour une release) |
| `construire_windows.bat` | Construit la version Windows |

**Sur le web, la sauvegarde sans compte dépend du navigateur et de l'adresse.** C'est pourquoi le port est fixe : 8080 pour le développement, 8088 pour le zip livré. Ce sont deux sauvegardes différentes.

---

## 5. Où est quoi

```text
ODV/
├── AVANCEMENT.md, CLAUDE.md, REPRISE_DU_PROJET.md
├── ressources/            Règles d'origine, charte graphique, images de référence
├── livraison/             APK et zips construits (hors Git)
└── V1/                    L'application
    ├── pubspec.yaml       Version, dépendances, polices
    ├── assets/data/       LES DONNÉES DU JEU (JSON + règles en Markdown)
    ├── assets/fonts/      Polices embarquées (Cinzel, Roboto)
    ├── firestore.rules    Règles de sécurité de la base en ligne
    ├── distribution/web/  Serveur local et notice livrés dans le zip web
    ├── web/, android/     Enveloppes propres à chaque plateforme
    ├── test/              Tests automatiques
    └── lib/               LE CODE
        ├── main.dart      Démarrage
        ├── app.dart       Thème, préférences
        ├── theme.dart     Couleurs et styles
        ├── version.dart   Numéro de version
        ├── models/        Ce qu'est un personnage, une classe, une campagne…
        ├── regles/        Toutes les formules du jeu
        ├── data/          Lecture et écriture (appareil, Firestore, JSON)
        ├── state/         Contrôleurs : l'état partagé entre écrans
        ├── screens/       Les pages
        └── widgets/       Les morceaux d'écran réutilisables
```

---

## 6. Comment le code est organisé

Les dépendances vont toujours dans le même sens :

```text
screens / widgets      Ce qu'on voit
       │
state (contrôleurs)    Ce qui se passe, l'état partagé
       │
regles + data          Les calculs, le stockage
       │
models                 Les données pures
```

### models — les données

`personnage.dart` est central. **Un personnage ne stocke que ce que le joueur a choisi ou lancé** : race, classe, caractéristiques de base, rangs de voies, jets de dés, inventaire, PV actuels. Tout le reste est recalculé.

Il a un numéro de format (`versionSchema`). Les anciennes sauvegardes doivent rester lisibles : chaque nouveau champ a une valeur par défaut dans `depuisJson`.

Les autres modèles importants : `race.dart`, `classe.dart` (`ProfilClasse`, `aDuMana`, `aDeLEndurance`), `voie.dart` (`Voie`, `Competence`, jets, états), `effet.dart`, `creature.dart`, `objet.dart`, `campagne.dart`, `seance.dart`.

### regles — les formules

**`fiche_calculee.dart` est le cœur du jeu.** `FicheCalculee` prend un personnage, sa race et sa classe, et calcule PV, PM, PE, modificateurs, CA, RD, bonus, sorts, jets disponibles. C'est ici qu'on change une formule.

Autres fichiers : `progression.dart` (points, rangs), `montee_niveau.dart`, `regles_particulieres.dart`, `inventaire.dart`, `des.dart` (lancers, lecture de « 1d8 + 2 »), `etats.dart`, `invocations.dart`.

### data — le stockage

| Fichier | Rôle |
|---|---|
| `referentiel.dart` | Charge les JSON au démarrage dans un objet `Referentiel`, passé aux écrans |
| `personnage_repository.dart` | Le contrat de stockage, et une version en mémoire pour les tests |
| `local_personnage_repository.dart` | Stockage sur l'appareil (`shared_preferences`) |
| `firestore_personnage_repository.dart` | Stockage en ligne |
| `depot_differe.dart` | Couche entre l'application et Firestore : file d'attente, envois espacés, copie locale |
| `compte.dart`, `firebase_compte.dart` | Connexion |
| `campagnes.dart`, `firestore_campagnes.dart` | Campagnes |
| `seance.dart`, `firestore_seance.dart` | Partie en cours |

**Le principe à retenir :** chaque service est une **interface** avec deux versions, une réelle (Firestore) et une **en mémoire**. Les tests utilisent celle en mémoire, sans réseau. Toute méthode ajoutée doit l'être aux deux.

### state — les contrôleurs

| Contrôleur | Rôle |
|---|---|
| `PersonnagesController` | Liste des personnages ; change de stockage avec `utiliser()` |
| `CompteController` | Connexion, envoi des fiches, méthode de sauvegarde, hors connexion |
| `PreferencesController` | Thème, personnage actif, taille des menus |
| `CampagnesController` | Campagnes du compte, partage des fiches, verrous hors séance |
| `SeanceController` | Tout ce qui bouge pendant une séance |

### screens et widgets — l'interface

`main.dart` → `app.dart` → `racine_screen.dart`, qui affiche le menu latéral et la section choisie. Les pages sont dans `screens/`, avec les sous-dossiers `creation/`, `fiche/` et `campagnes/`.

Les couleurs viennent uniquement de `theme.dart` (`OdvCouleurs`).

---

## 7. Les données du jeu

Tout le contenu est dans `V1/assets/data/`, modifiable **sans toucher au code** :

| Fichier | Contenu |
|---|---|
| `classes.json` | Classes, voies, compétences |
| `races.json` | Races, passifs, voies raciales |
| `equipements.json` | Armes, armures, objets |
| `bestiaire.json` | Créatures et invocations |
| `aptitudes.json`, `sorts_rang0.json` | Savoirs, savoir-faire, sorts mineurs |
| `regles_systeme.md` | Texte de la page Règles système |

Exemple simplifié de compétence :

```json
{
  "rang": 2,
  "nom": "Moulinet (niveau 1)",
  "type": "actif complexe, compétence",
  "endurance": 2,
  "effet": "Texte affiché au joueur.",
  "effets": [{"type": "bonus", "categorie": "FOR", "valeur": "2"}],
  "jets": [{"libelle": "Attaque", "des": "1d20", "carac": "ADC"}]
}
```

- `effet` est le **texte** lu par le joueur. `effets` est ce que l'application **applique vraiment** (bonus, tests, renforcements). Une compétence peut n'avoir que du texte.
- Clés utiles : `jets`, `etat` / `etats` (activables), `choix`, `selonPassif` / `selonOrigine` / `selonProfil` (variantes), `degats`, `typeDegats`, `soin`, `reussite`, `invocations`, `fabrication`, `endurance`.
- Les types d'effets sont décrits dans `lib/models/effet.dart` et dans `AVANCEMENT.md` §7.6.

**Précautions :** le JSON ne tolère ni virgule finale ni clé en double. `flutter test` détecte une partie des erreurs. L'auteur édite souvent ces fichiers à la main.

---

## 8. Comment ça marche, parcours par parcours

### Sauvegarde d'un personnage

- **Sans compte :** `LocalPersonnageRepository` écrit la liste sur l'appareil.
- **Avec un compte :** `CompteController` fait passer `PersonnagesController` sur un `DepotDiffere`, posé devant Firestore.

`DepotDiffere` garde les modifications en attente sur l'appareil, puis les envoie : la première tout de suite, les suivantes regroupées, **au plus une fois toutes les 5 secondes**. Il garde aussi une copie de toutes les fiches du compte.

À la connexion, les fiches créées sans compte sont envoyées en ligne puis retirées de l'appareil. En cas de conflit, la plus récente gagne.

### Hors connexion

- Avec Firebase chargé mais sans réseau : le cache de Firestore, plus la copie locale si le réseau ne répond pas en 3 secondes.
- Web sans internet : Firebase ne se charge pas du tout. `CompteController.horsConnexion` reprend le dernier compte depuis la copie locale. Les modifications attendent le prochain démarrage connecté.
- Les polices sont embarquées pour ne rien télécharger.

### Campagnes

Un MJ crée une campagne, qui reçoit un code (`LOUP-4827`). Un joueur saisit le code, choisit un personnage et envoie une demande, que le MJ accepte ou refuse.

La fiche d'un joueur est ouverte au MJ et aux autres joueurs par les champs `partageAvec` (lecture) et `modifiablePar` (écriture), mis à jour par `CampagnesController` selon les paramètres de la campagne.

### Séance

Quand le MJ démarre une séance, les joueurs sont avertis dans l'application. `SeanceController` suit en direct le mode (combat ou exploration), les tours, les créatures, les PV/PM/PE, les jets, les messages et la présence.

Trois mécanismes à connaître :

- **Les secrets ne sont pas juste masqués.** Une créature a deux documents : `creatures` (ce que les PJ peuvent voir) et `creaturesMj` (vrai nom, PV). Un jet n'est lisible que par ses `lecteurs`. Les règles Firestore l'imposent.
- **Les dégâts passent par une file** (`degats`) : le joueur retire lui-même les PV de sa fiche, et le MJ ceux des créatures, car personne d'autre n'a le droit d'écrire ces données. L'application du destinataire doit donc être ouverte sur la séance.
- **La présence** : l'application du joueur se signale toutes les 45 secondes ; il est absent après 2 minutes sans nouvelle.

---

## 9. Firebase

Firebase est le service en ligne de Google. Le projet s'appelle **`odyssee-vagabonds`** (console : https://console.firebase.google.com).

- **Authentication** : e-mail et mot de passe, Google.
- **Firestore** : base de données, avec ces collections :

```text
personnages/{id}               proprietaire, partageAvec, modifiablePar, fiche (JSON en texte)
codes/{code}                   code d'invitation → campagne
campagnes/{id}                 nom, MJ, joueurs, demandes, parametres, seance
  ├── prive/mj, prive/recaps   script, notes, récaps (MJ seul)
  ├── membres/{uid}            joueur, personnage, statut, initiative
  ├── jeu/etat                 mode, ordre, tour, manche
  ├── creatures, creaturesMj   partie publique, partie MJ
  ├── ressources/{uid}         PV, PM, PE publiés
  ├── jets, degats, messages
  ├── presences/{uid}
  └── notesJoueurs/{uid}/seances/{n}
```

**La sécurité est dans `V1/firestore.rules`, pas dans l'application.** Toute nouvelle collection doit y être ajoutée, sinon Firestore refuse et l'application affiche « Action impossible ». Pour déployer, depuis `V1/` :

```bash
firebase deploy --only firestore:rules
```

Cette étape n'est **pas** automatique : ni un commit ni une release ne déploient les règles.

Les fichiers `lib/firebase_options.dart` et `android/app/google-services.json` sont générés par `flutterfire configure`. Les clés qu'ils contiennent identifient le projet et ne sont pas des mots de passe.

**Limites à connaître :**

- Les APK sont signés avec la clé de **débogage** de la machine. C'est suffisant pour une installation à la main, pas pour le Play Store.
- La connexion Google sur Android dépend de l'empreinte SHA de cette clé, déclarée dans Firebase. **Sur un nouveau PC, il faut ajouter la nouvelle empreinte** dans la console Firebase, sinon la connexion Google échouera sur l'APK.
- Sur un site public, il faudrait ajouter son adresse aux « domaines autorisés » de Firebase Authentication.

---

## 10. Recettes

### Ajouter ou modifier une compétence, une race, une créature

Modifier le JSON, relancer complètement l'application, lancer `flutter test` : certains tests comptent des éléments et sont à adapter.

### Changer une règle de calcul

Modifier `lib/regles/fiche_calculee.dart`, ajouter un test, noter la règle dans `AVANCEMENT.md` §7. **Ne jamais inventer une règle** : demander à l'auteur du jeu.

### Ajouter un champ à un personnage

1. Dans `models/personnage.dart` : le champ, le constructeur, `versJson`, `depuisJson` **avec une valeur par défaut**.
2. Augmenter `versionSchema`.
3. Tester un aller-retour JSON et la lecture d'une ancienne fiche.

### Ajouter une clé à une compétence

Le modèle `Competence` est recopié à plusieurs endroits. Il faut penser à : le constructeur, `copie`, `pour`, `depuisJson` dans `models/voie.dart`, et `affichee()` dans `screens/fiche/onglet_fiche.dart`. Sinon la valeur disparaît silencieusement.

### Ajouter une fonction de séance en ligne

1. La méthode dans `ServiceSeance` (`data/seance.dart`).
2. Sa version mémoire au même endroit, sa version réelle dans `firestore_seance.dart`.
3. La règle dans `firestore.rules`, puis le déploiement.
4. L'appel dans `SeanceController`, et l'interface.
5. Un test dans `test/seance_test.dart`.

### Ajouter une page au menu

Ajouter une valeur à `Section` dans `widgets/menu_lateral.dart`, et son cas dans `screens/racine_screen.dart`.

---

## 11. Tests

Plus de 400 tests dans `V1/test/`, un fichier par sujet (`fiche_test`, `seance_test`, `compte_test`…).

```bash
cd V1
flutter test
flutter test test/seance_test.dart
```

**Règle du projet : un test par fonctionnalité.** Ils couvrent les calculs, le stockage, et les écrans avec de faux clics.

**Ils ne couvrent pas** le vrai Firestore ni ses règles de sécurité : les tests utilisent les services en mémoire. Une fonction en ligne doit être essayée avec deux vrais comptes, par exemple sur le web et sur un téléphone.

**Pièges fréquents :**

- La police de test est très large : les textes débordent plus qu'en réalité. Utiliser `Expanded` et `TextOverflow.ellipsis`.
- Aucune minuterie ne doit rester active à la fin d'un test : attendre la fin des messages en bas d'écran.
- `find.text` doit trouver un seul élément. Un même texte affiché deux fois fait échouer le test.
- Dans la séance, ne pas utiliser `ensureVisible` : il fait défiler les onglets.
- Un fichier de test peut échouer **au chargement** au premier passage après une modification. Relancer : s'il passe, ce n'était pas une erreur.

---

## 12. Version, Git, livraison

**À chaque modification :**

1. `flutter analyze` et `flutter test` sans erreur.
2. Une ligne dans `V1/lib/data/changelog.dart` (écran Nouveautés).
3. La case et la ligne de journal dans `AVANCEMENT.md`.
4. Si le design change : `ressources/CHARTE_GRAPHIQUE.md`.
5. Commit sur **`odv-2026`** au format `Type · Écran : description`, Type parmi Ajout, Modification, Correction, Retrait. Puis `git push`.

**Version** `0.MINEUR.CORRECTIF` : MINEUR pour un lot de nouveautés, CORRECTIF pour des corrections seules. À changer ensemble :

- `kVersionApp` et `kDateVersion` dans `lib/version.dart` ;
- `version:` dans `pubspec.yaml` (le nombre après `+` augmente de 1) ;
- un nouveau bloc en tête de `changelog.dart` (un test le vérifie) ;
- une étiquette Git, envoyée avec `git push origin vX.Y.Z`.

**Release :**

1. Lancer `construire_web.bat` et `construire_apk.bat`.
2. Renommer l'APK `odyssee_vagabonds_X.Y.Z.apk`.
3. Publier :

```bash
gh release create vX.Y.Z livraison/odyssee_vagabonds_X.Y.Z.apk livraison/odyssee_vagabonds_web_X.Y.Z.zip --title "Version X.Y.Z" --notes-file notes.md --target odv-2026
```

Les notes reprennent les blocs de `changelog.dart` depuis la release précédente.

**Ne jamais committer** `flutter/`, `livraison/`, les journaux ni les secrets (voir `.gitignore`).

---

## 13. Pièges déjà rencontrés

| Symptôme | Cause |
|---|---|
| Connexion impossible sur le zip web, « Firebase indisponible » dans la console | Fichier généré périmé dans `.dart_tool/flutter_build`. `construire_web.bat` l'efface et vérifie maintenant Firebase. Ne pas construire à la main sans cette précaution |
| Rectangle gris sur une fiche | Un widget plante. Exemple résolu : un bloc dépliable relisait la position de défilement. Tout `ExpansionTile` dans une liste à `PageStorageKey` a besoin de sa propre `PageStorageKey` |
| « Action impossible (connexion internet ?) » alors qu'internet fonctionne | Le plus souvent, une règle Firestore manquante ou pas déployée |
| Une ancienne version s'ouvre avec `lancer.bat` | Une fenêtre noire tourne encore sur le port 8088, ou le navigateur garde un cache : Ctrl+F5 |
| Une erreur n'apparaît qu'en version construite | Les tests tournent en mode développement. Reproduire avec `flutter build web --profile`, dont les erreurs sont lisibles dans la console |
| Erreur de construction Android liée à Java | Java 25 est utilisé au lieu du JDK 17 |

---

## 14. Ce qui reste à faire

La liste à jour est dans `AVANCEMENT.md`. À la date de ce document, restent notamment :

- **À essayer en conditions réelles :** séance à deux comptes, coupure réelle d'internet, APK sur téléphone.
- **À trancher avec l'auteur du jeu :**
  - relire les 7 sorts mis en dégâts physiques par défaut ;
  - le verrou des compétences hors séance bloque-t-il aussi la montée de niveau ? (oui pour l'instant) ;
  - les soins doivent-ils s'appliquer à la cible en séance ? ;
  - les dégâts doivent-ils dépendre de la réussite du toucher ?
- **Idées non faites :** notifications sur téléphone application fermée (demande l'offre payante Firebase), publication sur le Play Store (demande une vraie clé de signature), interface de séance pour les attaques avancées.

---

## 15. Accès à récupérer pour reprendre le projet

| Accès | Pourquoi |
|---|---|
| Dépôt GitHub `jubidatiloki/OdysseeDesVagabonds` | Code et releases |
| Projet Firebase `odyssee-vagabonds` (rôle propriétaire) | Base de données, comptes, règles |
| `RACES.md` et les documents du projet claude.ai de l'auteur | Règles non présentes dans le dépôt |

**Premier jour conseillé :**

1. Installer le poste (§3) et faire passer `flutter test`.
2. Lancer `lancer_web.bat` et parcourir l'application.
3. Lire `AVANCEMENT.md` §0 et §7.
4. Lire `models/personnage.dart`, puis le début de `regles/fiche_calculee.dart`.
5. Faire une petite modification de données, comme le texte d'une compétence, et suivre le §12 jusqu'au bout.
