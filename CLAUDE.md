# L'odyssée des vagabonds — instructions pour Claude

Application Flutter (mobile Android + web + Windows) de création et de gestion de personnages de jeu de rôle (système maison à d20). Utilisateur : francophone, non développeur. **Toujours répondre en français**, avec des explications simples, sans jargon inutile.

## À lire en début de session
0. Nouveau sur le projet : `REPRISE_DU_PROJET.md` explique tout, sans connaître Flutter.
1. `AVANCEMENT.md` : suivi complet (étapes cochées, décisions, **règles de jeu §7**, journal). C'est la source de vérité du projet.
2. `ressources/CHARTE_GRAPHIQUE.md` : charte graphique (palette « Taverne », Cinzel, composants, décisions 1 à 17).
3. Règles du jeu : `ressources/01_REGLES_GENERALES.md`, `CLASSES.md`, `stats.txt` (+ `RACES.md` dans le projet claude.ai).

## Règles de travail
- **Mettre à jour `AVANCEMENT.md` à chaque modification** : case cochée ou complétée dans la bonne étape, règle dans §7 si une règle de jeu est tranchée, **ligne de journal** (date · ce qui a été fait · ce qui reste à vérifier).
- Charte graphique modifiée → mettre à jour `ressources/CHARTE_GRAPHIQUE.md` et `ressources/assets/couleurs.txt`.
- Ne jamais inventer une règle de jeu : en cas de doute, demander (et proposer une interprétation). Les interprétations validées sont dans `AVANCEMENT.md` §7.
- Les fichiers de données (`V1/assets/data/*.json`) sont souvent édités à la main par l'utilisateur : vérifier qu'ils restent du JSON valide (virgules finales, accolades, clés en double) et signaler les blocages.
- Après chaque changement : `cd V1` puis `flutter analyze` et `flutter test` (doivent être sans erreur / tous verts). Les scripts `verifier.bat` (analyse + tests → `verification.log`) existent pour l'utilisateur.
- Ajouter ou adapter un test pour chaque fonctionnalité.
- **Version** (`V1/lib/version.dart` et `version:` de `V1/pubspec.yaml`, toujours en phase) : MINEUR +1 pour un lot de nouveautés, CORRECTIF +1 pour des corrections seules (MAJEUR 0 en phase 1) ; mettre à jour `kDateVersion` et noter la version dans la ligne de journal d'`AVANCEMENT.md`. Elle est affichée en bas du menu latéral.
- **Nouveautés** (`V1/lib/data/changelog.dart`, écran « Nouveautés ») : à chaque modification, ajouter une ligne courte (type Ajout / Amélioration / Correction) dans la version en cours ; une nouvelle version = un nouveau bloc en tête (un test vérifie que le 1ᵉʳ bloc = `kVersionApp`).
- **Git** : dépôt https://github.com/jubidatiloki/OdysseeDesVagabonds, branche de travail `odv-2026`.
  - **Committer et envoyer (`git push`) après chaque modification** (une fois `flutter analyze` / `flutter test` verts), sans redemander. Message en français, une ligne : `Type · Écran ou fonction : brève description`, Type ∈ **Ajout / Modification / Correction / Retrait** (ex. `Ajout · Fiche personnage : trèfle en filigrane de la CHAN`). Détails éventuels dans le corps du message.
  - **Nouvelle version** (`kVersionApp` change) : étiquette `vX.Y.Z` sur le commit, envoyée avec `git push origin vX.Y.Z`.
  - **Livraison** (APK / zip web construits dans `livraison/`) : release GitHub `vX.Y.Z` avec l'APK (`odyssee_vagabonds_X.Y.Z.apk`) et le zip web, notes = bloc de la version dans `changelog.dart`.
  - Ne jamais committer `flutter/`, `livraison/`, journaux ni secrets (voir `.gitignore` racine).

## Architecture (`V1/lib/`)
- `main.dart` → `app.dart` (`OdvApp` : thème, préférences) → `screens/racine_screen.dart` (menu latéral, section affichée).
- `models/` : `personnage.dart` (schéma JSON v10, historique), `race.dart`, `classe.dart` (`ProfilClasse`, `aDuMana` / `aDeLEndurance`), `voie.dart` (`Competence` avec `effets`), `effet.dart` (effets détaillés : bonus / test / renforcement / maîtrise), `equipement.dart`, `creature.dart`, `carac.dart`, `univers.dart` (univers de jeu, médiéval fantastique par défaut), `objet.dart`, `historique.dart`, `aptitude.dart`.
- `regles/` : **toutes les formules** dans `fiche_calculee.dart` (`FicheCalculee`, bonus d'effets, `ameliorationDe`), `progression.dart`, `montee_niveau.dart`, `regles_particulieres.dart`, `inventaire.dart`, `maitrises.dart` (armes maîtrisées, restrictions), `des.dart`.
- `data/` : `referentiel.dart` (charge `assets/data/*.json` + `regles_systeme.md`), stockage local `shared_preferences` (`local_personnage_repository.dart`), import/export.
- `state/` : `PersonnagesController` (`utiliser` : stockage appareil ou en ligne), `CompteController` (connexion, envoi des fiches de l'appareil), `PreferencesController` (thème, sombre par défaut).
- Compte en ligne (phase 2, Firebase `odyssee-vagabonds`, Android + web) : `data/compte.dart`, `data/firebase_compte.dart`, `data/firestore_personnage_repository.dart` (collection `personnages` : `proprietaire`, `partageAvec`, `fiche`), `screens/compte_screen.dart` ; règles dans `V1/firestore.rules` et index dans `V1/firestore.indexes.json` (déployer les deux : `firebase deploy --only firestore`).
- Campagnes (phase 2) : `models/campagne.dart`, `data/campagnes.dart` (`ServiceCampagnes`, `ServiceCampagnesMemoire` pour les tests), `data/firestore_campagnes.dart`, `state/campagnes_controller.dart`, écrans dans `screens/campagnes/` ; collections `campagnes` (+ `prive`, `membres`) et `codes`. Séance : `models/seance.dart`, `data/seance.dart` (`ServiceSeance`, `ServiceSeanceMemoire`), `data/firestore_seance.dart`, `state/seance_controller.dart`, `seance_*.dart` ; sous-collections `jeu`, `creatures`, `creaturesMj`, `ressources`, `jets`, `degats`, `butins`, `envois`, `presences`, `messages`, `notesJoueurs`. En test, pas de `ensureVisible` dans la séance : il fait défiler les onglets. Vues de la fiche partagées avec la séance : `screens/fiche/vues_fiche.dart`.
- `widgets/` : `theme.dart` est à la racine de `lib/` (couleurs `OdvCouleurs`, `CarteOdv`, `AvatarPersonnage`, `styleAmbiance`) ; `liste_detail.dart` (liste + détail côte à côte ≥ 900 px), `profil_classe.dart` (profils, jauges à 3 crans), `infos_creature.dart`, `voie_detail.dart` (`LigneCompetence`, `LigneTrait`, `ListeEffets`), `types_competence.dart`, `resume_fiche.dart` (statistiques), `carte_identite.dart`, `menu_lateral.dart`, `consultation.dart`, `markdown_simple.dart`.

## Pièges connus (tests widget)
- Police de test (Ahem) très large → débordements : `Flexible`/`Expanded` + `TextOverflow.ellipsis`, `FittedBox` pour les chiffres.
- Les erreurs de débordement **pendant une animation** font échouer les tests (cf. `OverflowBox` dans `liste_detail.dart`).
- `ListView` paresseuse → `scrollUntilVisible` / `ensureVisible` avant de taper.
- SnackBar avec action : se ferme par `Timer` ; aucun `Timer` ne doit rester actif à la fin d'un test.
- `find.text` doit être unique : attention aux textes affichés deux fois (liste + détail, titre + carte).

## Piège du rechargement à chaud (`r`)
- Après l'ajout d'un champ à un modèle (ex. `Objet.distance`), un rechargement à chaud (`r` dans `lancer_web.bat`) garde les objets déjà en mémoire avec ce champ à `null` → écran rouge « type 'Null' is not a subtype of type 'bool' ». Ce n'est pas un bug : faire un **redémarrage complet** (`R`, ou fermer et relancer `lancer_web.bat`). Le dire à l'utilisateur après ce type de modification.
- Après une modification d'un fichier `assets/data/*.json`, même `R` ne suffit pas sur le web (ancienne copie dans `build/`) : **fermer et relancer `lancer_web.bat`**.

## Environnement de l'utilisateur (Windows)
- Projet : `D:\claude\ODV` ; Flutter : `C:\Users\benja\Documents\flutter` (3.38) ; Android SDK : `C:\Users\benja\AppData\Local\Android\Sdk`.
- Java par défaut = 25 (incompatible Android) → utiliser le **JDK 17** `C:\Program Files\Eclipse Adoptium\jdk-17.0.18.8-hotspot` (`flutter config --jdk-dir=...`, fait par `construire_apk.bat`).
- Scripts dans `V1/` : `verifier.bat`, `lancer_web.bat` (http://localhost:8080, port fixe pour garder la sauvegarde), `lancer_telephone.bat` (Wi-Fi local), `construire_apk.bat`, `construire_web.bat`, `construire_windows.bat` (sorties dans `D:\claude\ODV\livraison\`), `publier_web.bat` (version web en ligne sur Firebase Hosting, https://odyssee-vagabonds.web.app, installable sur iPhone).

## Feuille de route
Phase 1 (V1, en cours : finitions 1.10 → 1.12) · Phase 2 : Firebase (cloud + connexion) · Phase 3 : V2 à définir. Détail et prochaines cases dans `AVANCEMENT.md`.
