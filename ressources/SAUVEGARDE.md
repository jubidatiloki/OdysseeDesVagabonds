# Sauvegardes — L'odyssée des vagabonds

Où sont les données, et comment ne rien perdre (16/11/2026).

## 1. Les fiches des joueurs

| Où | Risque | Protection |
|---|---|---|
| **Sur l'appareil** (sans compte) : stockage du navigateur ou du téléphone | effacé si on vide les données du navigateur, si on désinstalle l'appli, ou si l'espace est plein (environ 5 Mo sur le web) | bouton **« Sauvegarder toutes les fiches »** (page Personnages, icône disquette) : un fichier `odv_sauvegarde_AAAA-MM-JJ.json`, à garder hors de l'appareil. Il se restaure avec le bouton **Importer**. Un enregistrement qui échoue (espace plein) est maintenant signalé par un message rouge. |
| **En ligne** (avec un compte) : base Firestore | fausse manipulation, bug qui écrase des données | sauvegarde de la base (point 2) ; chaque joueur peut aussi faire « Sauvegarder toutes les fiches ». |

Conseil aux joueurs : faire « Sauvegarder toutes les fiches » de temps en temps (avant une mise à jour, une fois par mois).

## 2. La base en ligne (Firestore) — à faire dans la console

Firebase ne garde **aucune copie** de la base par défaut. Deux réglages existent ; ils demandent le **forfait Blaze** (paiement à l'usage, avec carte bancaire). Pour une base de cette taille, le coût est de quelques centimes par mois. Pense à fixer une **alerte de budget** (par exemple 1 €) dans la console Google Cloud.

1. Ouvrir https://console.firebase.google.com → projet **odyssee-vagabonds**.
2. Si besoin : passer au forfait **Blaze** (en bas à gauche, « Mettre à niveau »).
3. Menu **Firestore Database** → onglet **Récupération après sinistre** (« Disaster recovery »).
4. **Sauvegardes planifiées** : créer une planification **quotidienne**, conservation **7 jours** (ou hebdomadaire, 4 semaines).
5. Facultatif : activer la **récupération à un instant donné** (PITR) : retour possible à n'importe quelle minute des 7 derniers jours.

Restaurer : même onglet → choisir une sauvegarde → **Restaurer**. La restauration se fait dans une **nouvelle** base, pour vérifier avant de remplacer.

Sans forfait Blaze : pas de sauvegarde automatique possible. Il reste les sauvegardes manuelles de chaque joueur (point 1).

## 3. La clé de signature des APK Android

Dossier `D:\claude\ODV\signature\` (jamais envoyé sur GitHub). Voir `signature\LISEZMOI.txt`.

- **À faire une fois** : copier ce dossier sur une clé USB et dans un espace en ligne privé.
- Sans cette clé, les mises à jour Android ne s'installeraient plus par-dessus l'ancienne version. Il faudrait désinstaller l'application, ce qui efface les fiches gardées sur le téléphone.
- `construire_apk.bat` refuse de construire l'APK si la clé est absente.

## 4. Le code

Tout le code est sur GitHub (dépôt `OdysseeDesVagabonds`, branche `odv-2026`), avec une étiquette par version et une release (APK + zip web) pour les versions livrées.
