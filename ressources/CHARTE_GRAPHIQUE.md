# Charte graphique — L'odyssée des vagabonds

> Version du 21/10/2026 — **palette « Taverne »** (décisions validées le même jour, voir §11), construite à partir du dossier `ressources/assets/` : `couleurs.txt`, `colors.png`, `logo.png`, `EXEMPLE_STYLE_1.png` (accueil), `EXEMPLE_STYLE_2.png` (création).
> Sert de référence à l'étape **1.10 Design** d'`AVANCEMENT.md`.
> Marqueurs : ✅ repris tel quel des assets · 💡 proposition à valider · ❓ question ouverte.

---

## 1. Intention

**Un carnet d'aventurier lu à la lueur d'une lanterne, sur une table de taverne.**

- **Fond brun-noir chaud** (palette « Taverne ») et **texte couleur parchemin** : l'ambiance du logo (cuir, bois, encre, parchemin), confortable pour jouer dans une pièce peu éclairée.
- **Orange cuivré = action.** Il est réservé à ce qu'on peut faire ou à ce qui est actif : bouton +, boutons principaux, onglet actif, élément sélectionné, filet sous la barre du haut. Il n'est plus utilisé en grands aplats.
- **Or = progression** (pièces du logo) : niveau, montée de niveau.
- **Couleurs « sémantiques » douces** (vert, rouge, bleu), toujours dans la même fonction : vie, mana, bonus / malus.
- **Profondeur par paliers** : le fond, puis les cartes un cran plus clair, puis les cases encore un cran au-dessus.

---

## 2. Logo

| Élément | Règle |
|---|---|
| Fichier | `logo_tr.png` (**fond transparent**, à utiliser dans l'app) · `ressources/assets/logo.png` (fond taupe) : parchemins, plume, encrier et pièces, style illustré ✅ |
| Fond | Utiliser `logo_tr.png` (transparent) sur le gris de l'app ; `logo.png` (fond taupe ≈ `#7A7162`) seulement là où un fond plein est souhaité ✅ |
| Menu latéral | Dans un **cercle de 56 px**, à gauche du nom de l'app et du nombre de personnages (comme le médaillon de l'accueil dans `EXEMPLE_STYLE_1`) |
| Icône de l'app | Logo recadré sur les parchemins et la plume, sur fond `primaryDarker` `#282828`. 💡 Une version simplifiée (moins de détails) restera lisible en 48 px |
| Écran de démarrage | Logo centré (40 % de la largeur) sur `primaryDark` `#3B3B3B` |
| Zone de protection | Laisser au moins **¼ du diamètre** de vide autour du logo |
| Interdits | Le déformer, le recolorer, le poser sur l'orange ou sur une photo |

✅ Le **médaillon de magicien barbu** de `EXEMPLE_STYLE_1` est un **avatar de personnage**, pas le logo. Les avatars sont des illustrations rondes, dans le même style que le logo (§9).

---

## 3. Couleurs

### 3.1 Neutres « Taverne » (thème sombre) ✅ (21/10/2026)

Du plus sombre au plus clair :

| Nom | Hex | Rôle |
|---|---|---|
| `ink` (encre) | `#14110F` | Champs de saisie, fond des jauges |
| `tavern` (fond) | `#1C1916` | Fond des écrans |
| `card` | `#26211D` | Cartes, barre du haut, menu latéral, fenêtres |
| `cardGradient` | `#2A241F` → `#26211D` | Dégradé **vertical** des cartes |
| `tile` | `#322B25` | Cases de statistiques, jauges |
| `tileHigh` | `#3A322B` | Cases en relief, étiquettes, bordure des cartes |
| `border` | `#4A4038` | Séparateurs, contours discrets |
| `parchmentText` | `#F1E8DA` | Texte principal |
| `secondaryText` | `#B8AC9C` | Texte secondaire |
| `discreetText` | `#8F8478` | Mentions, éléments désactivés |

Les anciens gris (`primaryDark` `#3B3B3B`, `primaryDarker` `#282828`, `grey` `#5D5D5D`, `lightGrey` `#8F8F8F`) restent dans `couleurs.txt` pour référence, mais ne servent plus au thème sombre.

### 3.2 Accent et or ✅

| Nom | Hex | Rôle |
|---|---|---|
| `accent` | `#C87234` | **Actions** : bouton +, boutons principaux, onglet actif, bouton radio coché, filet sous la barre du haut, contour de l'avatar et des grandes cases |
| `accentDark` | `#A04824` | Accent sur fond clair (texte, liens) |
| `accentLight` | `#E59A62` | Orange **lisible en texte** sur fond sombre (onglet actif, liens, initiale de l'avatar) |
| `accentTint` | `#3A2A1E` | Fond teinté orange (avatar, élément sélectionné du menu) |
| `gold` | `#D4A24C` | **Progression** : pastille du niveau, bouton « Monter au niveau », PV entre 25 et 50 % |
| `onGold` | `#2A1E0A` | Texte sur fond or |

### 3.3 Couleurs sémantiques ✅

Chaque teinte existe en 3 intensités : **light** pour les jauges et les étiquettes, **normal** pour les boutons et les icônes, **dark** pour les fonds pleins et les textes sur fond clair.

| Teinte | dark | normal | light |
|---|---|---|---|
| Rouge | `darkRed` `#92322D` | `red` `#B14742` | `lightRed` `#C67A76` |
| Vert | `darkGreen` `#296A25` | `green` `#439E3E` | `lightGreen` `#83CA7F` |
| Bleu | `darkBlue` `#23426E` | `blue` `#3E73BE` | `lightBlue` `#7FA6DE` |
| Gris | — | `grey` `#5D5D5D` | `lightGrey` `#8F8F8F` |

> Intensités « dark » (première colonne de `colors.png`) : noms validés le 21/10/2026 ✅.

### 3.4 Signification dans le jeu ✅

Une même couleur garde toujours le même sens.

| Information | Couleur | Exemple d'usage |
|---|---|---|
| **Points de vie (PV)** | jauge **selon l'état** : `lightGreen` au-dessus de 50 %, `gold` de 25 à 50 %, `lightRed` en dessous | Jauge PV |
| **Points de mana (PM)** | `lightBlue` `#7FA6DE` | Jauge PM, coût d'un sort |
| **Points d'endurance (PE)** | `gold` `#D4A24C` (thème clair : `#8A6420`), icône coureur (`directions_run`) | Jauge PE, curseur du DE, coût d'une compétence (« 2 PE ») (03/11/2026) |
| **Modificateur positif / négatif** | `lightGreen` / `lightRed` (neutre à 0 : `secondaryText`) | « +3 » d'une caractéristique |
| Soin, repos, gain | `green` `#439E3E` | Nuit de repos, réussite critique (20) |
| Échec, suppression, danger | `red` / `lightRed` | Échec critique (1), bouton Supprimer, erreurs |
| **Progression** | `gold` `#D4A24C` | Pastille NIVEAU, bouton « Monter au niveau » |
| **Action** | `accent` `#C87234` | Bouton +, boutons principaux |
| **Physique** (race / classe) | `lightRed`, icône arts martiaux ✅ | Classes : barbare, chevalier, guerrier, ingénieur, rôdeur · Races : demi-orque, draconien, nain |
| **Lanceur de sorts / magique** | `lightBlue`, icône étincelles ✅ | Classes : druide, magicien, nécromancien · Race : haut-elfe (étiquette « Magique ») |
| **Hybride** | **`hybrid` `#A48FD0`** (violet = rouge + bleu ; `#6E56A8` sur fond clair), icône deux cercles ✅ | Classes : barde, moine, prêtre, voleur · Races : demi-elfe, elfe-sylvain, gnome, humain |
| Vie / mana d'une classe | **jauge à 3 crans** après le cœur `lightGreen` ou la goutte `lightBlue`, remplie jusqu'au cran : 1 cran = dé inférieur (`lightRed`), 2 crans = dé de la race (`discreetText`), 3 crans = dé supérieur (couleur de la ressource) ; explication au survol | Liste, détail des classes, création |
| Dés d'une race | même curseur, placé selon la taille du dé (d4 bas, d6 milieu, d8 haut), suivi du dé (« d8 ») | Liste, détail des races, création |
| Famille de créature | Bêtes `lightGreen` (patte) · Morts-vivants `hybrid` (cœur brisé) · Dragons `lightRed` (flamme) · Élémentaires / magiques `lightBlue` (étincelles) · autres `secondaryText`, avec une icône propre (31/10/2026) : Monstres (insecte), Gobelinoïdes (groupe), Humanoïdes (silhouette), Fées (fleur), Créatures artificielles (machine), Géants (montagne) ; archétypes : meute, puissant, rapide, volant, berzerk, chef, furtif (œil barré), tireur (cible), lanceur de sorts (étincelles), gardien (bouclier), fouisseur (terrain) ; **Invocations** `or` (baguette magique, 01/11/2026) : fiches des invocations et compagnons des personnages, archétypes compagnon (cœur), monture (siège), familier (œil), soutien (poignée de main), mort-vivant (cœur brisé), prédateur (patte) | Bestiaire (étiquette, avatar, filtres) |
| Taille de créature | échelle à 7 crans croissants (minuscule → titanesque), cran de la créature en `accent` | Bestiaire |
| Modificateurs de race | « +3 FOR » en `lightGreen`, « −2 INT » en `lightRed` | Liste, détail des races |
| Information neutre, désactivé | `discreetText` | Rang pas encore accessible |

---

## 4. Thèmes

### 4.1 Thème sombre « Taverne » — thème par défaut ✅

| Zone | Couleur |
|---|---|
| Fond d'écran | `tavern` `#1C1916` |
| Barre du haut | `card` `#26211D`, titre et icônes `parchmentText`, **filet `accent` de 2 px en bas** ; onglet actif `accentLight` souligné `accent` |
| Cartes | dégradé `#2A241F` → `#26211D`, bordure `tileHigh`, ombre douce |
| Cases (statistiques, jauges) | `tile` `#322B25` |
| Carte sélectionnée | bordure `parchmentText` 2 px |
| Texte principal / secondaire | `parchmentText` `#F1E8DA` / `secondaryText` `#B8AC9C` |
| Séparateurs | `border` `#4A4038`, 1 px |
| Menu latéral | fond `card`, entrée active sur `accentTint`, texte `accentLight` |

### 4.2 Thème clair « parchemin » ✅ (page Préférences)

Le thème clair reprend le **parchemin** du logo :

| Zone | Couleur |
|---|---|
| Fond d'écran | parchemin `#F4EDE1` |
| Cartes | blanc `#FFFFFF` → `#F4EDE1` (même dégradé vertical, inversé en clair), bordure `#E2D6C3` |
| Barre du haut | `#FBF7F0`, titre `#2E2E2E`, filet `accent` de 2 px en bas |
| Texte principal | `#2E2E2E` |
| Texte secondaire | `grey` `#5D5D5D` |
| Accent sur fond clair (texte, liens, icônes) | `accentDark` `#A04824` |
| Jauges PV / PM | `lightGreen` / `lightBlue`, avec bordure `darkGreen` / `blue` |
| Vert sur fond clair | `darkGreen` `#296A25` (le `green` manque de contraste sur le parchemin) |

---

## 5. Typographie

Les maquettes utilisent une police **sans empattement** simple, proche de **Roboto**.

| Usage | Police | Taille | Graisse | Exemple |
|---|---|---|---|---|
| Titre d'écran (barre du haut) | Roboto | 20 | Medium 500 | « Choix de la race et de la classe » |
| Nom d'un personnage | **Cinzel** | 22 | Bold 700 | « Roberto lvl 11 » |
| Titre de race / classe / créature | **Cinzel** | 18 | SemiBold 600 | « Nain » |
| Titre de section | Roboto | 18 | SemiBold 600 | « Statistiques » |
| Chiffre mis en avant | Roboto | 40 | Regular 400 | « 3 » personnages créés, résultat du d20 (64) |
| Valeur de statistique | Roboto | 18 | Regular 400 | « PV : 15/71 », « FOR : +2 » |
| Texte courant | Roboto | 16 | Regular 400 | Descriptions |
| Libellé, étiquette | Roboto | 13 | Medium 500 | « physique », « Introduction » |
| Petite note | Roboto | 12 | Regular 400 | « Coût : 2 pts · niveau 3 minimum » |

✅ **Police d'ambiance : Cinzel** (Google Fonts, libre, à embarquer dans l'app), réservée au **nom de l'app**, aux **noms de personnages** et aux **titres de race, de classe et de créature**. Tout le reste reste en Roboto pour la lisibilité. Choix modifiable plus tard : une seule constante à changer dans `theme.dart`.

- Abréviations des statistiques toujours en **majuscules** : FOR, DEX, CON… (exception : AdC, AdT, AdM).
- Chiffres alignés (`tabular figures`) dans les tableaux de statistiques.

---

## 6. Formes et espacements

| Élément | Valeur |
|---|---|
| Rayon des cartes | **16 px** |
| Rayon des étiquettes et des boutons | **pilule** (rayon = moitié de la hauteur) |
| Rayon des champs de saisie | 12 px |
| Bouton flottant (FAB) | rond, **56 px**, `accent`, icône + blanche |
| Ombre des cartes | noir à 35 %, flou 12 px, décalage vertical 4 px |
| Bordure de sélection | `parchmentText` 2 px (sombre) · `accent` 2 px (clair) |
| Pastille de rang (compétences) | cercle **22 px à contour** `accent`, numéro orange en petit (pas de fond plein) |
| Grille d'espacement | multiples de **4** : 4, 8, 12, **16** (marges d'écran et intérieur des cartes), 24 |
| Espacement entre cartes | 16 px |
| Zone tactile minimum | 48 × 48 px |

---

## 7. Composants

| Composant | Description |
|---|---|
| **Barre du haut** | Sombre (`card`), filet orange de 2 px en bas, icône ☰ à gauche, menu ⋮ à droite |
| **Carte « compteur »** | Logo + nom de l'app + nombre de personnages ; bandeau du menu latéral |
| **Carte d'identité** (fiche) | Avatar, nom en **Cinzel**, étiquettes sexe / race / classe / héritage, **pastille NIVEAU or** à droite, crayon de modification |
| **Avatar de personnage** | Cercle `accentTint`, contour `accent` 1,5 px, initiale en Cinzel `accentLight` ; plus tard : médaillon illustré |
| **Description** | En citation : filet `accent` de 3 px à gauche, icône de guillemets, italique `secondaryText` |
| **Titres de section** | **Cinzel** (petites capitales), icône `accent` à gauche |
| **Statistiques** | En-tête DV · DM · CHAN ; **Combat** : grande case CA (bouclier en filigrane) à gauche des esquives, grande case Initiative (éclair) à gauche des rangées Toucher et Dégâts ; colonnes CaC / Distance / Magie repérées par une icône (marteau, cible, étincelles) ; **Personnage** sur 2 colonnes |
| **Case de caractéristique** | **Modificateur en grand** et en couleur (vert / rouge / neutre) à gauche ; **valeur dans un petit cadre** séparé à droite, avec la mention « valeur » |
| **Traits et compétences** | Nom en gras 15 px `parchmentText`, description `secondaryText` ; trait : icône étincelles `accent` ; compétence : pastille de rang à contour |
| **Étapes de création** | Cercles de 40 px avec icône ; étape active = cercle clair ; trait qui relie les cercles (à faire) |
| **Carte de choix** | Bouton radio `accent` à gauche, nom en Cinzel, description ; sélection = bordure claire |
| **Étiquette** | Pilule `tileHigh`, texte `parchmentText`, icône |
| **Jauges PV / PM** | Barre arrondie de **12 px** sur fond `ink`, couleur PV selon l'état (§3.4), valeur « 15 / 71 » au-dessus |
| **Boutons** | Principal : pilule `accent`, texte blanc gras · Progression : pilule `gold`, texte `onGold` · Secondaire : contour `border` · Texte : `accentLight` · Danger : `red` |

---

## 8. Accessibilité (contrastes mesurés, norme WCAG AA)

| Combinaison | Contraste | Verdict |
|---|---|---|
| `parchmentText` sur `tavern` | 14,4 | ✅ tout texte |
| `parchmentText` sur `tile` | 11,5 | ✅ |
| `secondaryText` sur `card` / `tile` | 7,2 / 6,3 | ✅ tout texte |
| `discreetText` sur `card` | 4,4 | ⚠️ petites mentions, désactivé |
| `accent` sur `card` / `tavern` | 4,5 / 4,9 | ✅ icônes, texte gras |
| `accentLight` sur `card` | 6,9 | ✅ texte orange |
| `gold` sur `card` | 6,9 | ✅ |
| `onGold` sur `gold` | 7,0 | ✅ texte des boutons or |
| Blanc sur `accent` | 3,55 | ⚠️ texte **gras** seulement (boutons, FAB) |
| `lightGreen` / `lightBlue` / `lightRed` sur `tile` | 7,1 / 5,6 / 4,3 | ✅ modificateurs, jauges |
| `accentDark` sur parchemin (thème clair) | 5,2 | ✅ |

**Règles :**
- Ne jamais transmettre une information **par la couleur seule** : la jauge PV porte toujours ses chiffres, un modificateur garde son signe + / −, une réussite critique affiche aussi un texte.
- Étiquettes physique / magique : **texte sombre** sur rouge clair et bleu clair.

---

## 9. Iconographie (étape 1.10, 2ᵉ case)

- **Interface** : icônes **au trait** (Material Symbols « Outlined », graisse 400, 24 px), en blanc ou en `accent` quand elles sont actives.
- **Illustrations** (races, classes, avatars, écran vide) : style **illustré** comme `logo.png`. Contours doux, tons chauds, lumière par le haut à gauche, médaillon rond sur fond sombre.

Icônes provisoires proposées en attendant des icônes sur mesure 💡 :

| Élément | Icône (Material Symbols) | Couleur |
|---|---|---|
| PV | `favorite` | `lightGreen` |
| PM | `water_drop` | `lightBlue` |
| Montée de niveau | `keyboard_double_arrow_up` | `accent` |
| Nuit / repos | `bedtime` | `lightGreen` |
| Initiative | `bolt` | blanc |
| CA | `shield` | blanc |
| Identité | `badge` | blanc |
| Classe | `swords` | blanc |
| Race | `diversity_3` | blanc |
| Compétences | `auto_stories` | blanc |
| Récapitulatif | `checklist` | blanc |

---

## 10. Correspondance dans le code Flutter ✅

Dans `V1/lib/theme.dart` :

- `OdvCouleurs` : toutes les couleurs ci-dessus (`fond`, `encre`, `carte`, `caseStat`, `caseHaute`, `bordure`, `texteParchemin`, `texteSecondaire`, `texteDiscret`, `accent`, `accentClair`, `accentFond`, `or`, `surOr`, sémantiques, parchemin).
- `couleurPv(ratio)` : couleur de la jauge PV selon l'état ; `couleurModificateur(mod)` : vert / rouge / neutre.
- `themeOdv(brightness)` : `ColorScheme` défini à la main (sombre « Taverne », clair « parchemin »), barre du haut sombre à filet orange, boutons pilule, cartes arrondies.
- Widgets communs :
  - `CarteOdv` (dégradé, rayon de 16 px, bordure, ombre) ;
  - `AvatarPersonnage` ;
  - `styleBoutonProgression()` (bouton or) ;
  - `styleAmbiance()` (Cinzel).
- Police Cinzel embarquée dans `assets/fonts/` ; logo dans `assets/images/logo.png`.

---

## 11. Décisions (21/10/2026) ✅

| # | Sujet | Décision |
|---|---|---|
| 1 | Jauge PV | `lightGreen` `#83CA7F` (PM : `lightBlue` `#7FA6DE`) |
| 2 | Médaillon de magicien de la maquette | Avatar de personnage (pas le logo) |
| 3 | Logo dans l'app | `logo_tr.png`, fond transparent |
| 4 | Police d'ambiance | Cinzel pour les titres (modifiable plus tard) |
| 5 | Thème clair | Parchemin (`#F4EDE1`) |
| 6 | Noms des couleurs | `accent`, `accentDark`, `darkRed`, `darkGreen`, `darkBlue`, `parchment` validés et ajoutés à `couleurs.txt` |

| 7 | Palette du thème sombre | **« Taverne »** : bruns chauds, texte parchemin |
| 8 | Barre du haut | Sombre, filet orange ; l'orange réservé aux actions |
| 9 | Or | Progression : pastille NIVEAU, bouton « Monter au niveau » |
| 10 | Rangs des compétences | Pastille discrète à contour ; **nom du trait / de la compétence mis en avant** |
| 11 | Profondeur | Fond, cartes, cases : trois paliers nets |
| 12 | Caractéristiques | **Modificateur en grand** et en couleur, **valeur à part** dans un cadre, clairement séparée |
| 13 | Jauge PV | Couleur selon l'état (vert, or, rouge), 12 px |
| 14 | Titres de section | Cinzel |
| 15 | Esquives / toucher / dégâts | Colonnes CaC / Distance / Magie repérées par une icône |
| 16 | Description | En citation (filet orange, italique) |
| 17 | CA et initiative | Grandes cases à gauche de leurs rangées |
| 18 | Onglets de la fiche (22/10/2026) | Icônes 28 px, texte 15 px semi-gras |
| 19 | Montée de niveau (22/10/2026) | Bouton or en haut à droite de la barre (« Niveau N » sur téléphone) |
| 59 | Page Compte (02/11/2026) | Entrée « Compte » (`account_circle`) en tête du groupe Préférences du menu ; page : carte d'état (icône téléphone = sur l'appareil, `cloud_sync` = envoi, `cloud_done` = synchronisé, `cloud_off` = erreur) avec l'explication, puis bloc « Se connecter ou créer un compte » (champs e-mail et mot de passe à icônes, bouton plein « Se connecter », contour « Créer un compte », lien « Mot de passe oublié », filet, contour « Continuer avec Google », erreur en rouge sous les champs, barre de progression pendant l'attente) ou « Mon compte » (déconnexion, suppression avec confirmation). Menu : sous le nombre de personnages, icône d'état + libellé en `bodySmall` secondaire |
| 60 | Synchronisation (02/11/2026) | Page Compte, connecté : bloc « Synchronisation » (icône `sync`) au-dessus de « Mon compte » : « Dernière synchronisation : jj/mm/aaaa à hh:mm » (ou « jamais ») en `titleSmall`, nombre de modifications en attente en couleur primaire ; « Méthode de sauvegarde » : bouton segmenté **Automatique** (`autorenew`) / **Manuelle** (`touch_app`), en automatique deux cases (« À chaque modification de personnage », « À chaque lancer de dé (personnage actif) ») avec une ligne d'explication ; bouton plein « Synchroniser maintenant » (`cloud_upload`, rond de chargement pendant l'envoi) quand l'envoi n'est pas immédiat ou que des modifications attendent. État « Modifications en attente » (`cloud_upload`) dans la carte d'état et le menu |
| 61 | Endurance (03/11/2026) | Ressource des classes physiques et hybrides : couleur `gold` (thème clair `#8A6420`), icône coureur `directions_run` (`kIconeEndurance`). Classes : 3 curseurs (vie, mana, endurance) ; la ressource que la classe n'a pas (mana d'une classe physique, endurance d'un lanceur) garde sa jauge vide **barrée d'une croix** `close` rouge, explication « aucun (pas de PM / PE) » au survol. Races : curseur du DE à la suite du DM. Fiche : jauge « Points d'endurance » (Dépenser / Récupérer) à côté ou sous les PV et PM, seulement les ressources de la classe ; repos : « + N PE ». Compétences : pastille « N PE » (ou « Action : N PE ») en or avant les libellés de sort. Page dé : « PE a/b » dans le rappel, section « Endurance » (après Compétences) avec un bouton par action payante, « PE insuffisants » quand il en manque |
| 62 | Campagnes (03/11/2026) | Entrée « Campagnes » (carte `map`) après « Lancer de dé », pastille (`Badge`) quand une séance est en cours ou qu'une demande attend le MJ. Page : deux grandes cartes (`CarteOdv`) « En tant que maître du jeu » (livre) et « En tant que joueur » (bouclier), titre Cinzel, détail en secondaire, pastille d'alerte ; sans compte, bloc « Connecte-toi pour jouer à plusieurs » et bouton plein « Se connecter ». Listes : tuiles avec avatar à initiales, détail (joueurs n/max, demandes, code), puce « Séance n » ; bouton flottant étendu « Nouvelle campagne » / « Rejoindre une campagne ». Création : `Stepper` vertical en 4 étapes, boutons « Suivant » / « Précédent » puis « Créer la campagne » ; fenêtre du code d'invitation en `headlineMedium` gras espacé, couleur primaire, « Copier le message ». Page MJ : barre d'onglets (Joueurs avec pastille du nombre de demandes, Script, Notes, Paramètres), bouton plein « Démarrer une séance » / « Reprendre la séance n » dans la barre du haut. Séance en cours côté joueur : carte `primaryContainer` (icône `campaign`) avec « Rejoindre », et message en bas d'écran (10 s) avec l'action « Rejoindre » |
| 63 | Interface de séance (03/11/2026) | Barre d'onglets comme la fiche (icône 28 au-dessus du libellé, hauteur 76) : Tableau de bord (`dashboard`), Créatures (`pets`, MJ), Règles système, Paramètres. Sous la barre, bandeau `surfaceContainerLow` : mode (`explore` ou `sports_martial_arts`), « Manche n · Tour : X » (« À toi de jouer » en couleur primaire), bouton plein « Passer son tour », contours « Tour précédent » et « Passer en combat / exploration ». À partir de 900 px : colonne de cartes (280), détail, colonne de dés (340), séparées d'un filet ; en dessous, 3 vues Cartes / Détail / Dés. Petites cartes : icône, nom en `titleSmall`, lignes en `bodySmall` secondaire ; contour primaire = sélectionnée, fond teinté d'or (30 %), contour or et flèche or = c'est son tour ; croix `close` rouge pour retirer une créature. Jet non public : icône `visibility_off` dans l'historique |
| 64 | Séance, 2ᵉ lot (03/11/2026) | La navigation du haut ne change que le centre : cartes et dés restent visibles. Cartes : PV (`favorite`), PM (`water_drop`), PE (coureur) en 14 px avec leur valeur de la couleur de la ressource (`couleurVie`, `couleurMana`, `couleurEndurance`), initiative (`bolt`, couleur primaire) en combat. Paramètres : bloc « Permissions » (interrupteurs) pour le MJ, bloc « Graphismes » avec trois curseurs (Menu gauche, Corps central, Menu droite, 15 % au moins, total 100 %) et « Tailles par défaut » (22 / 52 / 26 %). Attaques : pastilles `ActionChip` « Toucher CaC : 1d20 +2 » dans le lancer de dés |
| 65 | Séance, 3ᵉ lot (03/11/2026) | Barre du haut, à droite : bouton plein « Clôturer la séance » (`stop_circle`, MJ, avec confirmation) ou contour « Quitter la séance » (`logout`, PJ). Lancer de dés : liste « Cible » au-dessus des attaques, pastilles « Sorts » (nom : coût). Historique : « Auteur · Jet → Cible » |
| 66 | Présence (04/11/2026) | Carte d'un joueur absent de la séance : icône `person_off_outlined` 18 px couleur d'erreur, à droite de la carte, explication au survol |
| 67 | Lot du 04/11/2026 | Séance : liseré de 3 px autour de l'écran, `red` en combat, `green` en exploration (par-dessus le contenu, sans le cacher). Onglets MJ : Glossaire (`auto_stories`), Séances précédentes (`event_note`). Portion de droite : onglets Dés, Historique, Messages (pastille des messages non lus, bulles `primaryContainer` à droite pour soi). Taille des menus : boutons segmentés Étroit / Normal / Large (remplacent les curseurs de la décision 64). Code d'invitation : bouton `copy`. État « Hors connexion » (`wifi_off`). Police Roboto embarquée |
| 68 | Lot du 07/11/2026 | Fenêtres de survol (`tooltipTheme`) : fond de carte (`carte` en sombre, `#FBF7F0` en clair), filet `or`, coins de 10 px, ombre légère, texte 13 px, largeur max 320 px ; statistiques de la fiche : titre en Cinzel couleur primaire puis explication. Logs de séance : icône de nature du jet (`casino_outlined`, `gps_fixed`, `local_fire_department_outlined`, `auto_awesome_outlined`, `fact_check_outlined`), total `titleLarge` gras dans un cadre `or` à fond teinté, bonus vert, malus rouge. Cartes de créatures : icône et couleur de `styleFamille`. Compétences : en-tête coloré des voies (`tertiary` pour la race, `primary` pour la classe), panneau « Déjà acquis » de 280 px à gauche dès 900 px, cadre repliable en dessous. |
| 69 | Séance et compétences (07/11/2026) | En-tête de séance sur deux lignes : titre, puis pastille du mode (`red` en combat, `darkGreen` en exploration, texte blanc Cinzel, icône) et lieu (`place_outlined`) ; barre du haut teintée de `red` à 35 % en combat. Téléphone : boutons de l'en-tête réduits à leur icône. Menu de droite : fond `surfaceContainerLow`, filet gauche `or` de 2 px, titre « Actions de jeu » en Cinzel, onglets avec icônes. Boutons de dés en cartes repliables (Combat, Statistiques, Aptitudes). Logs : bandeaux de section teintés `red` ou `green`, Touché en vert, Raté en rouge. Compétences : troisième colonne dès 1200 px, largeur max 1440 px. |
| 70 | Cadres réductibles (07/11/2026) | `CadreRepliable` : en-tête teinté à 15 %, bordure de la teinte à 60 %, icône, titre, sous-titre et chevron ; toucher l'en-tête réduit le cadre. Même cadre pour les voies et groupes de la répartition des points, les voies du glossaire (`tertiary` pour une voie raciale, `primary` pour une voie de classe) et les notes de séances. |
| 71 | Butins (07/11/2026) | Carte de butin dans le menu de gauche : icône `redeem_outlined` en `or`, résumé (« 2 objets · 10 or ») ; MJ : bouton contour « Créer un butin » sous les cartes. Détail en blocs Argent et Objets. |
| 72 | Maîtrises et restrictions (07/11/2026) | Groupes à icône et titre, pastilles teintées à 12 % avec bordure à 50 %, rayon 12 : Armes maîtrisées en vert (`lightGreen` sombre, `darkGreen` clair), Armures permises en `primary`, Interdit et Malus en `error`. Précisions en petite italique. Survol d'une pastille de groupe : armes du catalogue. |
| 73 | Animation de lancer (08/11/2026) | Au centre de l'écran, par-dessus tout : d20 dessiné (hexagone, triangle central, ombre), fond `surface` teinté à 15 %, trait de 4 px or (`OdvCouleurs.or`), vert en réussite critique, rouge en échec critique. Il tourne (2 tours) en grossissant de 60 à 100 % en faisant défiler des chiffres, puis montre le total avec un léger rebond et le libellé dans une pastille ; fondu à la fin. 2,4 s (résultat affiché 1 s de plus depuis le 09/11/2026), ne bloque pas les clics, coupée si l'appareil désactive les animations. |
| 74 | Résultat de jet en séance (09/11/2026) | Carte à bordure de 2 px et rayon 12 : total en grand (`headlineMedium` gras, carré 64 px teinté à 15 %), libellé en `titleMedium` gras, verdict (Touché, Raté, critique) dans la couleur de la carte, détail en petit gris. Couleur : vert (critique, touché), rouge `error` (échec critique, raté), or sinon. Boutons d'action avec avantage ou maîtrise : bordure de 2 px et texte verts (`couleurModificateur`), suivis de « · avantage ». |
| 75 | Esquive et puces (09/11/2026) | Bandeau d'esquive en haut de la séance : fond `errorContainer`, icône d'alerte, source et dégâts en gras, difficulté en petit, boutons « Esquiver » (plein) et « Subir » (contour). Puces des effets sans icône propre : point de 6 px dans la couleur du texte d'accent, au lieu d'un chevron. Description d'une voie : italique, en tête du cadre. |
| 76 | Historique par séance, afflictions (10/11/2026) | Historique : une carte repliable par séance (icône groupe en `primary`, titre « Campagne · Séance N », nombre d'événements et heures), fermée au départ. Afflictions : titre de famille en `primary` gras avec icône, cartes `surfaceContainerHighest` à bordure `outlineVariant`, rayon 10, icône en `error`, nom en gras et effet dessous ; une carte par ligne sur toute la largeur (10/11/2026), causes en petite italique grise sous l'effet ; types de dégâts dans le même style, icône dans la couleur du type (feu et chaos rouges, glace et magie bleues, physique et foudre or). |
| 77 | Icônes des types de dégâts (10/11/2026) | Devant chaque ligne à puce des cartes de types de dégâts, icône de 18 px : tranchant = épée, perçant = flèche (dessinées, `IconeEpee` / `IconeFleche` dans `widgets/icones_armes.dart`), contondant = marteau (`hardware`) en `onSurfaceVariant` ; feu = flamme (rouge), glace = flocon (bleu), foudre = éclair (or) |
| 78 | Fenêtres de créature et sous-compétences (11/11/2026) | Statistiques d'une invocation ou d'un familier : fenêtre (640 px max, 85 % de la hauteur), nom en Cinzel et croix de fermeture, fiche du bestiaire dessous. Autre compétence d'un même rang (« Serviteur permanent ») : flèche `subdirectory_arrow_right` de 22 px à la place de la pastille de rang. Nécrose : icône `heart_broken_outlined`. Glossaire des classes : bloc « Inventaire de base » (icône `backpack_outlined`, une ligne à puce par objet) |
| 79 | Compagnons en séance (11/11/2026) | Liste de gauche : carte du compagnon ou familier juste sous celle de son propriétaire, en retrait de 20 px ; icône `pets_outlined` (compagnon) ou `auto_awesome_outlined` (familier) en `or` ; lignes « Compagnon de X » / « Familier de X » puis « CA · PV » |
| 58 | Cadre du guerrier sur téléphone (02/11/2026) | Écran de moins de 600 px (`CadreClasse.estCompact`) : la cible, les flèches et les épées croisées du guerrier sont retirées (elles cachaient les infos) ; seuls le fer cabossé, les rivets et le filigrane bouclier + arc du coin en bas à droite restent. Grand écran inchangé (décision 26) |
| 57 | Invocations et effets reçus (01/11/2026) | Compétence qui invoque ou donne un compagnon : puce « Statistiques : nom » (icône patte) sous l'effet, qui ouvre la fiche du bestiaire en page entière (sur la fiche du personnage : seulement l'option choisie) ; formes au choix (druide, élémentaires) : nom en `labelLarge` puis leurs effets en puces, « (aussi sur un allié) » si recevable. Fiche : carte repliable « Effets reçus » (baguette magique `auto_fix_high`) avec une puce à cocher par sort lancé par un allié (infobulle = effets) ; état actif rappelé comme les autres (puce à croix). Page dé : groupe « Effets reçus » (puces actives, annulables) sous « États » |
| 56 | Résistances et sorts modulables (26/10/2026) | Fiche › Statistiques : sous-titre « Résistances » (bouclier lunaire `shield_moon_outlined`) et une case par type « RD feu +3 » (sources en petit, détail en infobulle), affichée seulement s'il y a des RD. Page dé : un sort modulable donne une carte par puissance, « Boule de feu (2d6) » avec son coût en PM |
| 55 | Types de sorts (26/10/2026) | 8 étiquettes teintées (même forme que les libellés de sort, placées **avant** le mana) : Offensif (flamme, rouge), Support (mains tendues, vert), Transformation (flèches, orange), Invocation (patte, violet), Illusion (flou, cyan), Contrôle physique (chaîne, brun), Contrôle mental (cerveau, rose), Utilitaire (outils, gris-bleu) ; couleurs claires en thème sombre, foncées en thème clair (`couleurs.txt`). Glossaire › Compétences : rangée « Type de sort : » de pastilles avec l'icône colorée |
| 54 | Écran Nouveautés (26/10/2026) | Entrée de menu « Nouveautés » (icône `new_releases`) ; numéro de version souligné en bas du menu, cliquable. Légende des types en haut ; une carte par version (titre Cinzel « Version 0.6.0 », date grise, étiquette « Actuelle » et contour or 2 px pour la version en cours) ; une ligne par modification avec icône colorée : Ajout ⊕ vert, Amélioration (baguette) or, Correction (clé) rouge |
| 53 | Origine du pouvoir (26/10/2026) | Glossaire › Classes, bloc « Description » : sous le texte d'ambiance, ligne en petit italique gris (`bodySmall`, `onSurfaceVariant`) précédée d'une étincelle or (`auto_awesome`, 16 px) : « Origine du pouvoir : … » (lanceurs de sorts seulement) |
| 52 | Cartes PV / PM de la fiche (26/10/2026) | Icône de 22 px avant le titre : cœur plein `OdvCouleurs.pv` (PV), goutte pleine `OdvCouleurs.pm` (PM). Boutons −1 / +1 en icônes pleines (`remove_circle` / `add_circle`) : −1 rouge (`couleurModificateur(-1)`), +1 vert (PV) ou bleu mana (PM). Bouton « Dégâts / Soins » avec l'icône note (`edit_note`). Fenêtre de saisie : titre avec l'icône de la carte, champ « Commentaire (facultatif) » (bulle), bouton de dépense à contour rouge avec icône (cœur brisé / éclat), bouton de gain plein vert ou bleu avec icône (soin / recharge) |
| 51 | Numéro de version (25/10/2026) | Bas du menu latéral, sous la dernière entrée : « Version 0.2.0 · 25/10/2026 » en petit (`labelSmall`), gris (`onSurfaceVariant`), aligné sur les entrées (marge 28) ; aussi sous le titre de « À propos » |
| 50 | Icône des armes à poudre (25/10/2026) | Motif dessiné `pistolet` : pistolet à silex tourné vers la gauche (canon épais, bouche évasée, chien, pontet, crosse courbée) et trois bouffées de fumée ; remplace l'arc pour les armes à poudre (glossaire, catalogue, inventaire) |
| 49 | Ingénieur : fabrication limitée et bidouillage (25/10/2026) | Inventaire › Fabrication : pastille « Fabriquer : Potion de fer (3) » (restantes du jour), grisée à 0. Menu « ⋮ » d'une arme à poudre : « Bidouiller (10 pa) » → fenêtre avec les 3 améliorations (« · déjà faite » grisée). Page dé › Usages limités : bouton texte « Nouveau jour » (soleil) |
| 48 | Guerrier : postures et dégâts divisés (25/10/2026) | États « Posture défensive » / « Posture offensive » : une seule pastille active à la fois. Bouton « Dégâts · Coup de boucher » avec la précision « dégâts ÷2 » ; détail du lancer « … −3 (÷2) = 4 ». Bouton « Toucher CaC · arme (2ᵉ) » au d20 avec l'Ambidextrie |
| 47 | Situations « Initiative » et « Savoirs » (25/10/2026) | Situations à cocher : groupes « Initiative » (après « Tous les jets ») et « Savoirs » (avant « Dégâts CaC ») ; pastilles « +3 entouré de végétation », « +5 Discrétion en nature », « +4 Survie, Escalade, Natation, Acrobatie en milieu difficile » |
| 46 | Situations dégâts et CA, nouveau combat (25/10/2026) | Situations à cocher : nouveaux groupes « Dégâts CaC » et « CA » (étiquettes comme « Tests AdC ») ; pastilles « +1d6 en 1 contre 1 », « +3 CA CaC en 1 contre 1 », « +5 CA … ». Bloc « Usages limités » : bouton texte « Nouveau combat » (drapeau) à côté de « Nouvelle aventure » quand un usage « par combat » est entamé |
| 45 | Écuyer et usages limités (25/10/2026) | Carte de choix « Écuyer » : trois cartes arrondies (icône personnage, nom en gras, description en petit) ; retenue = fond `secondaryContainer`, contour or 2 px, coche. Page dé : bloc « Usages limités » (icône calendrier coché) avant COMBAT, boutons larges « Faire jouer son titre · 3 / 4 · restants par aventure » (grisé « épuisé ») et bouton texte « Nouvelle aventure » ; fenêtre de confirmation « Utiliser ». Inventaire : catégorie « Compagnon » (icône personnage) |
| 44 | Arme familiale et critique élargi (25/10/2026) | Page dé : bouton « Toucher CaC » avec la précision verte « ⇈ critique 19-20 » (infobulle : compétence d'origine) quand l'arme familiale légendaire est en main ; un 19 naturel affiche le bandeau de réussite critique. Effets débloqués plus tard : suffixe « (dès le rang 3) » / « (jusqu'au rang 2) » dans les listes d'effets |
| 43 | Préférences, page Lancer de dé (25/10/2026) | 4ᵉ bloc « Page Lancer de dé » (icône dé) : sous-titres (titre + aide grise) puis pastilles compactes : « D4 … D100 » pour le dé par défaut ; pour Connaissances et Aptitudes : « Visible » (œil), « Caché » (œil barré), « Comme la dernière fois » (horloge) |
| 42 | Glossaire, filtre par caractéristique (25/10/2026) | Onglet Connaissances & Aptitudes : 3ᵉ rangée de filtres « Test : » suivie de pastilles compactes par caractéristique utilisée (« FOR (6) », infobulle = nom complet), dans l'ordre des caractéristiques ; une seule à la fois, retouchée = toutes. Cartes des peuples : étiquette « Innée pour ce peuple » |
| 41 | Page dé : textes longs et groupes repliables (25/10/2026) | « Toujours appliqués » et situations : pastilles arrondies (rayon 10, contour `outlineVariant`, coche or) dont le texte passe à la ligne ; situation cochée = fond `secondaryContainer`, contour or 1,5 px. Boutons de jet : libellé centré et précision sur 2 lignes. Catégories CONNAISSANCES et APTITUDES : titre touchable avec chevron (rotation 200 ms) ; replié : nombre de jets à droite du titre ; COMBAT reste toujours ouvert |
| 40 | Glossaire, onglet Connaissances & Aptitudes (25/10/2026) | 4ᵉ onglet (icône `school_outlined`), entre Compétences et Équipements. Même présentation que l'onglet Équipements : champ de recherche, pastilles de famille (Tout, Savoirs [livre], Savoir-faire [outils], Maîtrises et autres [médaille]) avec nombre, puis filtres Basiques / Complexes (−5 sans) ; groupes titrés en or (icône + nom en gras + sous-titre gris) ; cartes : nom, étiquettes, ligne de règle en or (basique) ou couleur tertiaire (complexe), description |
| 39 | Page dé : catégories de jets (25/10/2026) | Panneau du personnage actif : sous les tests de caractéristique, 3 grandes catégories `_Categorie` (icône 22 px + titre en capitales or Cinzel, espacé, filet or à 45 %) : COMBAT (sous-titres Initiative et attaques, Sorts, Compétences, États), CONNAISSANCES, APTITUDES (savoir-faire puis Instruments). Boutons de savoir larges : maîtrisé = bordure et valeur vertes, précision « ⇈ maîtrisé · +5 » ; complexe non maîtrisé = « ⇊ non maîtrisé · −5 » en rouge (flèche vers le bas) ; basique non maîtrisé = gris. Très grand écran (≥ 1400 px) : carte « Toujours appliqués / Situations » dans une colonne de 400 px à gauche (largeur max 1700) |
| 38 | Savoirs et savoir-faire (25/10/2026) | Étape Compétences › Aptitudes et connaissances : trois groupes, titre or en gras (« Savoirs », « Savoir-faire », « Maîtrises et autres ») suivi d'un sous-titre gris (« Connaissances », « Aptitudes et actions »…) ; sous le nom de chaque entrée, petite ligne « Savoir basique · INT · +5 aux tests liés · pas de malus sans » en or (basique) ou en couleur tertiaire (complexe, « −5 sans la maîtrise ») |
| 37 | Dé libre et instruments (24/10/2026) | Page Lancer de dé : rangée de pastilles « D4 · D6 · D8 · D10 · D12 · D20 · D100 » (compactes, contour 2 px et texte or en gras pour le dé choisi, D20 par défaut) juste au-dessus du bouton du lancer libre, dont le texte suit le dé (« Lancer le d6 », « d6 libre ») ; le cercle de résultat affiche le dé choisi avant le premier lancer. Glossaire › Équipements : catégorie « Instruments » (guitare dessinée), entre Consommables et Autres |
| 36 | Barde (24/10/2026) | Carte de choix multiple : compteur « 5 / 6 choisies » (or tant qu'incomplet, orange une fois complet), pastilles à cocher, les autres grisées quand c'est plein ; carte de choix à plus de 12 options : liste déroulante. Titres (« Musicien de renom ») : étiquette médaille sur la carte d'identité, ligne dorée sous la race et la classe sur l'accueil. Fiche › Mouvement : cases « Actions de mvt » et « Chute sans dégâts ». Page dé : « instrument maîtrisé requis », « gain : 1d20 + CHAN cuivre » sous le bouton, instruments en vert avec « avantage » |
| 35 | Glossaire, onglet Compétences (24/10/2026) | 3ᵉ onglet « Compétences » (livre) : champ de recherche (nom, effet, voie, sans accents), pastilles de filtre « Classes » / « Races » | « Sorts », « Sorts mineurs » (rang 0, étincelle), « Compétences », « Soutien », « Soin », « Dégâts » (icônes ; plusieurs = l'un ou l'autre ; les deux groupes se combinent), compteur « N compétences · M voies », « Effacer les filtres » ; une section par voie (titre or « Barbare · Voie de la brute », icône bouclier / diversité / étincelles, mention Classe / Race / Sorts de rang 0) puis ses lignes de compétence. Les 5 onglets du Glossaire (6 avant le retrait de Sorts) défilent sur téléphone, centrés sur grand écran |
| 34 | Sorts de rang 0 (24/10/2026) | Glossaire : onglet « Sorts » retiré le 24/10 — les sorts mineurs sont dans l'onglet Compétences (filtre « Sorts mineurs », groupe « Sorts mineurs (rang 0) », « Pour : … » sous chaque sort). Création et montée de niveau : section « Sorts de rang 0 » (titre avec étincelles, rappel « 1 point chacun · 0 PM · une fois par tour · pas de maintien », libellés du sort sous le nom). Fiche : groupe « Sorts de rang 0 » |
| 33 | Déplacement (24/10/2026) | Fiche, Statistiques › Combat : sous-titre « Mouvement » (icône coureur) et case « Déplacement » (« 15 m », détail « dont +5 m Colosse infatigable » ou « par action de mouvement », infobulle) |
| 32 | Barbare : inventaire et attaques (24/10/2026) | Inventaire : bouton « 1 / 2 » (arme principale / secondaire) sur les armes en main avec l'Armement barbare, en-tête « Armes en main x/2 » ; armures : « Armure légère/lourde » dans le détail, choix du poids dans le formulaire ; section « Fabrication » (pastilles « Fabriquer : … », icône marteau). Page dé : attaques de compétence en boutons de combat (précision « attaque + dégâts · +6 DM », grisés avec « arme à 2 mains requise ») ; depuis le 24/10 : deux boutons, « Nom » (attaque) et « Dégâts · Nom » (formule regroupée, bonus fixes en précision), « Moulinet · cible 2 » et bouton « Terminer moulinet » ; toucher « CaC · arme » (d20) et « CaC · arme (2ᵉ) » (d12). Étiquettes de type « Fabrication » (marteau, or) et « 2×/jour », « 3×/jour » |
| 31 | Icônes des équipements (24/10/2026) | Motifs dessinés (`IconeMotif`) au lieu des icônes génériques, d'après la catégorie et les étiquettes : arme CaC → épée, arme à distance → arc, outil (étiquette « outil ») → pioche, armure → plastron, bouclier → bouclier rond, casque → casque, consommable → potion (fiole ronde) ; objets magiques, accessoires et autres gardent leur icône. Glossaire (pastilles de filtre et cartes), catalogue d'ajout d'objet, inventaire et formulaire d'objet |
| 30 | Glossaire (24/10/2026) | Menu latéral : une entrée « Glossaire » (livre ouvert) remplace Classes, Races, Équipements et Bestiaire ; groupe « référence » avec Règles système. Écran `screens/glossaire_screen.dart` : titre « Glossaire · Races » (onglet courant en gris), 4 onglets sous la barre (icône avec pastille du nombre d'entrées, nom en gras quand actif, soulignement orange) ; on change d'onglet en touchant ou en glissant ; onglet retenu en revenant ; grand écran (≥ 700 px) : onglets groupés au centre comme le contenu, téléphone : toute la largeur. Les 4 écrans gardent leur présentation (liste + détail, filtres, recherche) sans barre de titre propre ; complété le 24/10 : onglets Compétences (décision 35) et Sorts (décision 34) |
| 29 | Création, étape Race (24/10/2026) | Modificateurs de caractéristiques en couleur (vert positif, rouge négatif) sur la ligne « Caractéristiques : », plus à côté des dés (la page Races les garde dans son résumé) ; origine et héritage choisis présentés comme les races sans origine : « Caractéristiques : » en couleur, puis lignes « Nom du passif : description », « Bonus : … » |
| 28 | Emblèmes de race (24/10/2026) | Dans le cercle des cartes de personnage (accueil, fiche), l'emblème de la race remplace l'initiale (`widgets/emblemes_race.dart`) : humain couronne (24/10, remplace bannière et épi), nain casque à cornes et barbe tressée, gnome bonnet pointu à engrenage, elfe sylvain tête d'elfe devant un arbre (24/10), haut-elfe tête d'elfe sous trois étoiles (24/10), demi-elfe visage (oreille ronde / oreille pointue), demi-orque mâchoire à défenses, draconien tête de dragon de profil. Fond du cercle selon la race (humain `#B89A6A`, nain `#8A7A66`, gnome `#6F8F4E`, elfe sylvain `#3F7A3A`, haut-elfe `#8FA8C8`, demi-elfe moitié `#3F7A3A` / moitié `#B89A6A`, demi-orque `#6F7F62`, draconien selon l'élément : feu `#C0463E`, glace `#7FC4E0`, foudre `#E0C040`, neutre `#7A7A80` sans élément) à 45 % (sombre) / 35 % (clair) ; emblème clair teinté par la classe, contour de la couleur de la classe ; médaillon de classe inchangé. Race inconnue : initiale |
| 27 | Libellés des sorts (24/10/2026) | Sous le nom d'un sort, pastilles teintées (`widgets/libelles_sort.dart`) : mana dépensé (goutte, bleu `pm` / `blue`), jet de réussite s'il en faut un (dé, or `or` / `#8A6420`, « 1d20 + ADM · contre esquive magique de la cible »), dégâts infligés s'il y en a (éclair, rouge `physique` / `darkRed`), soin s'il y en a (cœur, vert `pv` / `darkGreen`, ajouté le 24/10), effet appliqué s'il y en a (baguette magique, violet `hybride` / `hybrideFonce`) ; fond à 14 %, bordure à 50 %, infobulle. Partout où une compétence s'affiche (fiche, onglet Compétences, création, montée de niveau, pages Classes et Races) ; page Lancer de dé : chaque sort est une carte (nom, libellés, jet éventuel, « mana insuffisant » en rouge) ; sort à jet de réussite : carte à deux boutons, « Lancer · −N PM · 1d20 +X » (tonal) puis « Dégâts / effet » (contour, éclair) |
| 26 | Matières et effets des cadres de classe (24/10/2026) | Direction « Matière » choisie : le fond du cadre est la matière de la classe (`widgets/matieres_classe.dart`), la bordure, les coins ornés, le filigrane et le médaillon restent (décision 25). Barbare bois griffé et ébréché / sang qui coule ; barde tissu brodé, portée / notes qui s'envolent ; chevalier acier brossé, rivets / reflet qui passe ; druide écorce, lierre / grandes feuilles qui tombent ; guerrier fer de bataille (bosses, rivets) et cible d'entraînement / trois flèches tirées qui se plantent dans la cible, deux épées qui se lèvent et se croisent en X (étincelles) ; ingénieur plaques de laiton rivetées / engrenages qui tournent, fumée ; magicien nuit étoilée, constellation / étoiles et runes qui scintillent ; moine paravent shōji, bambous, lotus et bâton d.encens / fumée d.encens, shuriken qui se plante ; nécromancien pierre, fissures, os croisés / brume verte ; prêtre marbre veiné, filet d'or, fleurons / halo et rayons ; rôdeur cuir cousu, piste de cerf (sabots) / piste de loup dont les empreintes apparaissent une à une ; voleur cuir sombre cousu / ombre aux bords, pièce qui brille. Cycle de 8 s, lent et discret ; option « Effets animés » (Préférences, active par défaut), coupée aussi si le système demande moins d'animations ; effet figé sinon. Fonds éclaircis vers le parchemin en thème clair. Lisibilité (24/10) : fonds atténués (matière mêlée à 40 % au fond des cartes en sombre, 88 % parchemin en clair), texture à 60 %, voile dégradé derrière le texte à gauche (60 % → 0 à 55 % de la largeur). Accueil : étoile du personnage actif à côté du nom, plus de flèche à droite |
| 25 | Cadres de classe (24/10/2026) | Carte d'identité de la fiche et cartes de l'accueil habillées selon la classe (`widgets/cadre_classe.dart`) : fond teinté de la couleur de la classe, bordure + filet intérieur, coins ornés (losange, traits, points), motifs en filigrane à droite (27 % sombre / 22 % clair), avatar au contour de la classe avec médaillon-emblème. Couleurs : barbare `#C0463E`, barde `#D883B0`, chevalier `#8FA7C4`, druide `#6DB363`, guerrier `#C49A62`, ingénieur `#E0B040`, magicien `#6E8FE0`, moine `#E08A3C`, nécromancien `#9A7BD0`, prêtre `#E8D27A`, rôdeur `#8DA45A`, voleur `#A6A6B8` (35 % plus sombres sur le parchemin). Motifs : barbare 2 labrys + sang, cadre ébréché et fissuré, éclaboussures et coulures de sang ; barde flûte, baluchon, notes ; chevalier casque, écusson ; druide feuille, patte, fleur, lapin ; guerrier bouclier, arc (24/10) ; ingénieur marteau, bombe, poudre ; magicien livre, sort, étoiles ; moine lotus, ninja, shuriken (24/10) ; nécromancien crâne, démon ; prêtre cœur de vitalité, bouclier (aile d.ange retirée le 24/10/2026) ; rôdeur arc, piège, patte ; voleur dague, bourse. Personnage actif : bordure plus épaisse et plus claire de la couleur de la classe |
| 24 | Instruments, avantage (23/10/2026) | Guitare dessinée (`widgets/icone_guitare.dart`) pour la catégorie « Instrument de musique » et la zone Instruments ; bouton de test d'une stat avec avantage permanent : bordure et valeur vertes, mention « ⇈ avantage » |
| 23 | Réussite / échec (23/10/2026) | Bandeau arrondi « RÉUSSITE » (fond `darkGreen`, texte blanc, icône ✔) ou « ÉCHEC » (fond rouge d'erreur, icône ✖), halo de la même couleur, apparition avec rebond ; cercle du résultat vert / rouge |
| 22 | Chance (CHAN) (23/10/2026) | Trèfle à quatre feuilles dessiné (`widgets/icone_trefle.dart`, 4 feuilles en cœur + tige) en filigrane de la case CHAN, couleur orange à 18 % comme le bouclier de la CA |
| 21 | Avantage / désavantage (22/10/2026) | Avantage : vert (`lightGreen` / `darkGreen`), icône double flèche vers le haut ; désavantage : rouge (`lightRed` / `darkRed`), double flèche vers le bas ; normal : orange, icône dé ; bordure épaisse de la couleur quand choisi |
| 20 | Groupes de traits / compétences (22/10/2026) | En-tête or avec icône de voie (« Voie de la brute », « Passif racial · Demi-orque »), filet fin entre deux voies |

**Thème par défaut** : sombre (les préférences permettent de passer en clair « parchemin » ou de suivre l'appareil).
