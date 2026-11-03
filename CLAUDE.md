# CLAUDE.md

Serveur Minecraft NeoForge (image `itzg/minecraft-server`) déployé sur TrueNAS SCALE via Dockhand.
Les mods sont gérés par un pack packwiz dans `pack/`, lu par le serveur et par les joueurs (Prism Launcher).
Vue d'ensemble : [README.md](README.md). Procédures : [docs/](docs/).

## Règles à respecter

- **Après toute modification dans `pack/`, lancer `packwiz refresh`** (depuis `pack/`). Sinon les hashes de `index.toml`/`pack.toml` ne correspondent plus : la CI échoue et le serveur refuse le pack (`Hash mismatch`).
- **Fins de ligne LF uniquement** (voir `.gitattributes`) : les hashes packwiz portent sur les octets des fichiers.
- **Versions synchronisées** : `VERSION` et `NEOFORGE_VERSION` dans `docker-compose.yml` doivent être identiques à `[versions]` de `pack/pack.toml` (vérifié par `scripts/check-versions.sh` en CI).
- **Le repo est public** : aucun secret, ni dans le repo ni dans `pack/config/` (envoyé à tous les joueurs). Les secrets et réglages locaux vont dans `.env`, qui n'est pas versionné.
- **Choix du `side` d'un mod** : `server` seulement si le mod n'a ni contenu ni échanges réseau avec le client (BlueMap, LuckPerms…). Un mod qui ajoute des échanges réseau doit être en `both` (FTB Library par exemple), sinon NeoForge refuse la connexion des joueurs. Un mod purement visuel est en `client`. Vérifier les dépendances dans le `META-INF/neoforge.mods.toml` du jar.
- **Ajouter un mod** : `packwiz modrinth add <slug>` en priorité, sinon `packwiz curseforge add <slug>`.
- **Admins** : seul le propriétaire du serveur est op (`OPS` + `EXISTING_OPS_FILE=SYNCHRONIZE`). Les droits des autres joueurs passent par LuckPerms.

## Conventions

- Documentation, commentaires et messages de commit en **français**.
- Ne pas commiter sur `main` : créer une branche, puis ouvrir une PR avec `gh pr create`. La CI *Pack* doit passer avant le merge.
- Après un changement du pack : `git push`, puis Restart du conteneur dans Dockhand. Une modification de `docker-compose.yml` ou du `.env` nécessite un Redeploy.
