# Gestion des mods avec packwiz

Tout se passe dans le dossier [`pack/`](../pack/), sur ton PC. Le cycle est toujours le même :

```
modifier le pack  →  git commit + push  →  redémarrer le serveur  →  les joueurs relancent le jeu
   (packwiz)                                  (Dockhand)                 (mise à jour auto)
```

## 1. Installer packwiz sur ton PC

packwiz n'a pas de « release » classique. Deux options :

- **Binaire prêt à l'emploi** : https://nightly.link/packwiz/packwiz/workflows/go/main
  Prends `Windows 64-bit`, décompresse `packwiz.exe` dans un dossier présent dans ton `PATH`.
- **Avec Go** : `go install github.com/packwiz/packwiz@latest`

Vérifie l'installation :

```bash
packwiz --help
```

Toutes les commandes ci-dessous se lancent **depuis le dossier `pack/`**.

## 2. Comprendre les fichiers

| Fichier | Rôle |
|---|---|
| `pack.toml` | Nom, version du pack, versions Minecraft/NeoForge, hash de l'index |
| `index.toml` | Liste de tous les fichiers du pack avec leur hash (généré, ne pas éditer à la main) |
| `mods/<mod>.pw.toml` | Un fichier par mod : URL de téléchargement, hash, côté (`side`), source pour les mises à jour |
| `config/…` | Fichiers de configuration des mods, copiés tels quels chez le serveur **et** les joueurs |
| `defaultconfigs/…` | Configs serveur NeoForge par défaut, appliquées aux nouveaux mondes |
| `.packwizignore` | Fichiers de `pack/` à ne pas distribuer |

La valeur `side` de chaque mod décide qui le reçoit :

| `side` | Serveur | Joueurs | Exemples |
|---|---|---|---|
| `both` | ✅ | ✅ | Create, Mekanism, Farmer's Delight, JEI |
| `server` | ✅ | ❌ | BlueMap, spark, Chunky |
| `client` | ❌ | ✅ | Sodium/Embeddium, Iris, minimap, shaders |

packwiz la remplit automatiquement depuis Modrinth/CurseForge, mais vérifie-la : un mod client installé sur le serveur peut le faire planter.

## 3. Ajouter un mod

### Depuis Modrinth (à privilégier)

Le slug est dans l'URL : `https://modrinth.com/mod/create` donne `create`.

```bash
packwiz modrinth add create
```

packwiz choisit la dernière version compatible **NeoForge 1.21.1** et propose d'ajouter les dépendances manquantes : réponds `Y`.

Tu peux aussi coller l'URL complète d'une version précise :

```bash
packwiz modrinth add https://modrinth.com/mod/create/version/<id-de-version>
```

### Depuis CurseForge

```bash
packwiz curseforge add jei
# ou avec l'URL de la page / d'un fichier précis
packwiz curseforge add https://www.curseforge.com/minecraft/mc-mods/jei/files/1234567
```

> Certains auteurs interdisent la distribution par des outils tiers. packwiz te le signale : cherche alors le mod sur Modrinth, ou utilise la méthode ci-dessous.

### Un .jar hébergé ailleurs (GitHub Releases, etc.)

```bash
packwiz url add mon-mod https://github.com/auteur/mon-mod/releases/download/1.0/mon-mod-1.0.jar
```

Édite ensuite `mods/mon-mod.pw.toml` pour régler `side`. Ces mods ne peuvent pas être mis à jour par `packwiz update` : change l'URL à la main.

### Publier l'ajout

```bash
packwiz refresh            # met à jour index.toml / pack.toml (fait automatiquement par add, mais sans risque)
git add -A
git commit -m "Ajout de Create"
git push
```

Redémarre ensuite le conteneur dans Dockhand (**Restart**) : `packwiz-installer` télécharge le nouveau mod au démarrage.

## 4. Retirer un mod

```bash
packwiz remove create
git commit -am "Retrait de Create" && git push
```

Au redémarrage, le serveur supprime le `.jar`, et les joueurs aussi au prochain lancement.

> ⚠️ Retirer un mod de contenu supprime ses blocs et objets du monde. Fais un snapshot ZFS avant.

## 5. Mettre à jour les mods

```bash
packwiz update create      # un seul mod
packwiz update --all       # tous les mods (liste les changements et demande confirmation)
```

Les versions sont **figées par Git** : rien ne change tant que tu ne lances pas ces commandes et ne pousses pas le résultat.

Pour bloquer un mod sur sa version actuelle (ignoré par `update --all`) :

```bash
packwiz pin create
packwiz unpin create
```

## 6. Configurer les mods (configs versionnées)

1. Lance le serveur une fois avec le mod : il génère sa config dans `data/config/` sur TrueNAS (accès par partage SMB ou shell).
2. Copie le fichier dans `pack/config/` (même chemin relatif) et modifie-le.
3. Indexe et publie :
   ```bash
   packwiz refresh
   git add -A && git commit -m "Config de Create" && git push
   ```

Où placer les fichiers :

| Type de config | Emplacement dans `pack/` | Remarque |
|---|---|---|
| Config commune / client (`*-common.toml`, `*-client.toml`) | `config/` | Copiée chez le serveur et les joueurs |
| Config serveur NeoForge (`*-server.toml`) | `defaultconfigs/` | NeoForge la copie dans `world/serverconfig/` **à la création du monde**. Pour un monde existant, modifie directement `data/world/serverconfig/` |
| Config d'un mod serveur (ex. BlueMap) | `config/` | Les joueurs la reçoivent aussi, mais ne s'en servent pas |

> ⚠️ Le dépôt est public : aucun secret dans `config/`. Un fichier qui contient un token se gère directement dans `data/config/` sur TrueNAS, hors Git.

Exemple déjà présent : [`config/bluemap/core.conf`](../pack/config/bluemap/core.conf) (`accept-download: true`).

## 7. Mods optionnels pour les joueurs

Pour un mod client que chacun choisit d'installer ou non (shaders, minimap…), ajoute dans son `.pw.toml` :

```toml
side = "client"

[option]
optional = true
default = false
description = "Shaders (nécessite une bonne carte graphique)"
```

Au premier lancement, packwiz-installer affiche une fenêtre où le joueur coche les options qu'il veut.

## 8. Tester avant de publier

```bash
packwiz serve
```

Le pack est servi sur `http://localhost:8080/pack.toml`. Crée une instance Prism de test, avec la même commande de pré-lancement que dans [joueurs.md](joueurs.md) mais pointée sur cette URL, puis lance le jeu en solo pour vérifier que tout charge.

Pour tester aussi le serveur sans toucher au vrai monde, déploie une seconde stack Dockhand avec un autre `MC_DATA_DIR`, un autre port et `PACKWIZ_URL` pointant sur une branche Git de test :
`https://raw.githubusercontent.com/<utilisateur>/<repo>/test/pack/pack.toml`

## 9. Versionner le pack et publier une release

1. Incrémente `version` dans `pack/pack.toml` (par exemple `1.1.0`), puis lance `packwiz refresh`.
2. Commite, pousse, puis crée un tag :
   ```bash
   git tag v1.1.0 && git push origin v1.1.0
   ```
3. La CI publie une release avec l'instance Prism et le `.mrpack`.

Les joueurs qui ont déjà l'instance Prism **n'ont rien à faire** pour les mods : la mise à jour est automatique. La release ne sert qu'aux nouveaux joueurs, et aux changements de version de Minecraft ou NeoForge (voir ci-dessous).

> 💡 Indique la version du pack dans le `MOTD` du `.env` (par exemple `Serveur entre amis §7- pack 1.1.0`).

## 10. Changer de version de NeoForge ou de Minecraft

C'est le seul cas qui demande une action aux joueurs.

1. Dans `pack/` :
   ```bash
   packwiz migrate loader 21.1.270          # nouvelle version NeoForge
   # ou, pour Minecraft (vérifie d'abord que tous tes mods existent pour la nouvelle version) :
   packwiz migrate minecraft 1.21.4
   ```
2. Reporte les **mêmes** versions dans [docker-compose.yml](../docker-compose.yml) (`VERSION`, `NEOFORGE_VERSION`).
   La CI (`scripts/check-versions.sh`) échoue si les deux ne correspondent pas.
3. Commite, pousse, crée un tag, puis redéploie la stack dans Dockhand (le compose a changé).
4. Les joueurs mettent à jour leur instance : *Modifier → Version → NeoForge → Changer de version*, ou réimportent le nouveau zip Prism de la release.

> ⚠️ Changer de version de Minecraft sur un monde existant est risqué et ne se fait jamais dans l'autre sens. Snapshot ZFS obligatoire.

## 11. Revenir en arrière

Une mise à jour casse quelque chose ? Annule le commit fautif :

```bash
git log --oneline          # repère le commit
git revert <commit>
git push
```

Redémarre ensuite le serveur. Si le monde a été abîmé, restaure aussi le snapshot ZFS du dataset (voir [operations.md](operations.md)).

## 12. Aide-mémoire

| Je veux… | Commande (dans `pack/`) |
|---|---|
| Ajouter un mod Modrinth | `packwiz modrinth add <slug>` |
| Ajouter un mod CurseForge | `packwiz curseforge add <slug>` |
| Ajouter un .jar externe | `packwiz url add <nom> <url>` |
| Retirer un mod | `packwiz remove <nom>` |
| Mettre à jour un mod / tous | `packwiz update <nom>` / `packwiz update --all` |
| Figer un mod | `packwiz pin <nom>` |
| Lister les mods | `packwiz list` |
| Réindexer après modification manuelle | `packwiz refresh` |
| Tester localement | `packwiz serve` |
| Changer de loader | `packwiz migrate loader <version>` |
| Exporter un .mrpack | `packwiz modrinth export` |

Après chaque modification : `git commit` + `git push`, puis **Restart** du conteneur.
