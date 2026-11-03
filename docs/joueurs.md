# Guide des joueurs

Le serveur utilise des mods. Pour pouvoir le rejoindre, il faut **exactement les mêmes mods** que lui.
Grâce à l'instance fournie, tout s'installe et se met à jour automatiquement à chaque lancement du jeu.

## Prérequis

- Un compte **Minecraft Java Edition** (acheté).
- Ton pseudo ajouté à la whitelist : envoie-le à l'admin du serveur.
- Un PC avec au moins 8 Go de RAM.

## 1. Installer Prism Launcher

Télécharge-le sur https://prismlauncher.org/download (Windows, macOS, Linux), installe-le puis lance-le.

Au premier lancement :
1. Choisis la langue.
2. Java : laisse Prism gérer (il télécharge automatiquement Java 21 si besoin).
3. **Comptes → Gérer les comptes → Ajouter Microsoft** et connecte-toi avec ton compte Minecraft.

## 2. Importer l'instance du serveur

1. Télécharge le fichier **`homelab-pack-prism.zip`** depuis la page *Releases* que l'admin t'a envoyée.
2. Dans Prism : **Ajouter une instance → Importer**, choisis le zip, puis **OK**.
   (Tu peux aussi glisser-déposer le zip dans la fenêtre de Prism.)
3. Clic droit sur l'instance → **Modifier → Paramètres → Java** :
   coche *Mémoire* et mets **Mémoire maximale : 6144 Mo** (ou 4096 si ton PC a peu de RAM).

## 3. Jouer

1. Double-clique sur l'instance.
2. Une petite fenêtre **packwiz-installer** télécharge les mods. C'est long la première fois, quasi instantané ensuite.
3. Le jeu démarre : **Multijoueur → Ajouter un serveur**, adresse fournie par l'admin (par exemple `monserveur.duckdns.org`, sans numéro de port).

La carte du monde est consultable dans un navigateur à l'adresse fournie par l'admin (par exemple `https://carte.monserveur.duckdns.org`).

## Commandes utiles en jeu

| Commande | Effet |
|---|---|
| `/sethome` puis `/home` | Enregistrer ta maison, puis t'y téléporter |
| `/tpa <pseudo>` | Demander à te téléporter vers un joueur (il répond `/tpaccept` ou `/tpdeny`) |
| `/back` | Revenir à ta position précédente (ou à l'endroit de ta mort) |
| `/spawn` | Retourner au point d'apparition |
| `/warp <nom>`, `/listwarps` | Lieux communs créés par l'admin |

## Mises à jour

**Tu n'as rien à faire** : à chaque lancement, l'instance vérifie le pack et installe, met à jour ou supprime les mods toute seule.

Seule exception : quand l'admin annonce un changement de version de NeoForge ou de Minecraft, il faut soit :
- clic droit sur l'instance → **Modifier → Version** → sélectionner *NeoForge* → **Changer de version** → choisir la version annoncée ;
- soit réimporter le nouveau zip depuis la page Releases.

## Ajouter tes propres mods client

Tu peux ajouter des mods purement visuels (minimap, Iris/shaders, Mod Menu…) via **Modifier → Mods → Télécharger des mods**.
Ils ne sont pas touchés par les mises à jour automatiques.
N'ajoute **pas** de mods de contenu (nouveaux blocs, objets) : le serveur refusera la connexion.

## Problèmes fréquents

| Symptôme | Solution |
|---|---|
| « Mod rejections » / « incompatible mods » en te connectant | Ferme le jeu et relance-le pour que la mise à jour s'applique. Si ça persiste, vérifie la version de NeoForge (voir *Mises à jour*) |
| La fenêtre packwiz affiche une erreur réseau | Vérifie ta connexion internet et relance. Le jeu peut démarrer avec la version précédente du pack |
| « You are not white-listed on this server » | Demande à l'admin de t'ajouter à la whitelist |
| Le jeu plante au démarrage | Prism → **Modifier → Journal (Minecraft Log)** : envoie le log à l'admin. Retire d'abord tes mods ajoutés à la main |
| Jeu très lent | Augmente la mémoire (étape 2.3), baisse la distance de rendu |

## Alternative : Modrinth App

Chaque release contient aussi un fichier `.mrpack` importable dans la Modrinth App.
⚠️ Cette méthode **ne se met pas à jour automatiquement** : il faut réimporter le `.mrpack` à chaque nouvelle version du pack. Préfère Prism.
