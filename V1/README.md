# L'odyssée des vagabonds — V1 (Flutter)

Application mobile + web de création et de gestion de personnages de jeu de rôle.
Le suivi complet du projet est dans [`../AVANCEMENT.md`](../AVANCEMENT.md).

## Première installation (une seule fois)

Prérequis : [Flutter SDK](https://docs.flutter.dev/get-started/install/windows) installé (`flutter doctor` au vert pour Android et/ou Chrome).

Dans ce dossier `V1` :

```bash
# 1. Génère les dossiers de plateformes (android/, ios/, web/…).
#    Les fichiers déjà présents (lib/, test/, pubspec.yaml) ne sont PAS écrasés.
flutter create . --project-name odyssee_vagabonds --org com.odysseevagabonds --platforms=android,ios,web

# 2. Récupère les dépendances
flutter pub get

# 3. Vérifie que tout est en ordre
flutter analyze
flutter test
```

## Lancer l'application

Version web : double-cliquer **`lancer_web.bat`**, qui ouvre **http://localhost:8080**.
Toujours utiliser cette adresse dans le même navigateur : les personnages sont
sauvegardés dans le stockage de ce navigateur pour cette adresse.
(`flutter run -d chrome` ouvre un Chrome temporaire qui perd les données à chaque lancement.)

```bash
flutter run -d web-server --web-port=8080   # version web, adresse fixe
flutter run -d windows    # si la plateforme windows a été ajoutée
flutter run               # sur un téléphone Android branché / un émulateur
```

## Organisation du code

```
lib/
  main.dart                  point d'entrée : charge les données puis lance l'app
  app.dart                   MaterialApp (thème, langue française)
  theme.dart                 couleurs et thème
  models/                    Carac, Race, Classe, Personnage (+ JSON)
  regles/fiche_calculee.dart TOUTES les formules du jeu (dés, PV, esquive…)
  data/
    referentiel.dart         charge assets/data/races.json et classes.json
    personnage_repository.dart        interface de stockage (+ version en mémoire)
    local_personnage_repository.dart  stockage local (shared_preferences)
  state/personnages_controller.dart   état partagé de la liste des personnages
  screens/                   accueil, création, fiche
assets/data/                 races.json, classes.json (données de référence)
test/                        tests des règles et de l'accueil
```

Règle d'or : **aucun écran ne parle directement au stockage**. Ils passent par
`PersonnagesController`, qui passe par un `PersonnageRepository`. En phase 2, on
ajoutera un repository Firestore sans toucher aux écrans.
