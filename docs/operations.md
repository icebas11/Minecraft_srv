# Exploitation

## Console du serveur

Dans Dockhand, ouvre un terminal sur le conteneur `minecraft` (ou un shell TrueNAS) :

```bash
docker exec -it minecraft rcon-cli          # console interactive
docker exec minecraft rcon-cli list         # commande unique
```

RCON est activé par l'image avec un mot de passe généré automatiquement. Le port 25575 n'est **pas** exposé, et c'est voulu.

Commandes utiles :

| Commande | Effet |
|---|---|
| `list` | Joueurs connectés |
| `whitelist add <pseudo>` / `whitelist remove <pseudo>` | Gérer la whitelist |
| `op <pseudo>` / `deop <pseudo>` | Droits d'administrateur |
| `save-all` | Forcer la sauvegarde du monde |
| `say <message>` | Message à tous les joueurs |
| `neoforge tps` | Performances (TPS par dimension) |

> Les variables `WHITELIST`/`OPS` du `.env` sont appliquées à chaque démarrage. Pour qu'un ajout fait en console soit permanent et reproductible, reporte-le aussi dans le `.env`.

## Appliquer une mise à jour du pack

1. Pousse les modifications du pack sur GitHub ([mods.md](mods.md)).
2. Préviens les joueurs : `docker exec minecraft rcon-cli say Redémarrage dans 1 minute`.
3. Dockhand : **Restart** du conteneur. L'image exécute `packwiz-installer` au démarrage.
4. Vérifie dans les logs la liste des mods téléchargés, puis `Done (…)! For help, type "help"`.

Un simple **Restart** suffit pour les mods. Un **Redeploy** de la stack est nécessaire seulement si `docker-compose.yml` ou `.env` changent (versions, RAM, ports…).

## Sauvegardes et restauration

Méthode actuelle : **snapshots ZFS** du dataset `apps/minecraft` (voir [installation.md](installation.md)).

**Avant une mise à jour risquée**, prends un snapshot manuel : *Datasets → minecraft → Snapshots → Create Snapshot*.

**Restaurer** :
1. Dockhand : **Stop** du conteneur.
2. TrueNAS : *Datasets → minecraft/data → Snapshots* → choisis le snapshot → **Rollback**.
   (Ou, pour récupérer un seul fichier : dossier caché `/mnt/tank/apps/minecraft/data/.zfs/snapshot/<nom>/`.)
3. Si la cause est un changement du pack, `git revert` côté pack ([mods.md](mods.md)).
4. **Start** du conteneur.

> 💡 Un rollback ZFS fait sans arrêter le serveur peut corrompre le monde. Arrête-le toujours d'abord.

## BlueMap (carte web)

- Adresse : `http://<ip-truenas>:8100` en LAN, `https://carte.<domaine>.duckdns.org` depuis Internet ([acces-externe.md](acces-externe.md))
- Le premier rendu complet prend du temps (minutes ou heures selon la taille du monde). Il reprend après un redémarrage.
- Commandes (en jeu en tant qu'op, ou via `rcon-cli`) :
  - `bluemap` : état du rendu
  - `bluemap reload` : recharge la configuration
  - `bluemap freeze <map>` / `bluemap unfreeze <map>` : met en pause ou reprend les mises à jour d'une carte
- Configuration :
  - `config/bluemap/core.conf` → versionnée dans `pack/config/bluemap/`
  - Les autres fichiers (`maps/*.conf`, `webserver.conf`) sont générés au premier démarrage dans `data/config/bluemap/`. Pour les versionner, copie-les dans `pack/config/bluemap/` puis lance `packwiz refresh`.
- Les mods qui ajoutent des blocs apparaissent sur la carte grâce à `scan-for-mod-resources: true`. Les blocs avec des rendus spéciaux peuvent s'afficher imparfaitement.

## Où sont les fichiers (`MC_DATA_DIR`)

| Chemin | Contenu |
|---|---|
| `world/` | Le monde (et `world/serverconfig/` pour les configs serveur NeoForge) |
| `mods/` | Mods installés par packwiz : ne pas modifier à la main |
| `config/` | Configs des mods (écrasées par celles du pack si elles y figurent) |
| `logs/latest.log` | Log courant |
| `crash-reports/` | Rapports de plantage |
| `bluemap/` | Données et tuiles de la carte |
| `server.properties` | Généré depuis les variables d'environnement |

## Dépannage

| Symptôme | Piste |
|---|---|
| Le conteneur redémarre en boucle | Logs Dockhand : souvent un mod incompatible ou un mod `client` sur le serveur. Cherche le nom du mod dans le crash (`crash-reports/`), corrige son `side` ou retire-le, push, puis Restart |
| `Failed to download modpack` / erreur packwiz | `PACKWIZ_URL` incorrecte ou dépôt privé : ouvre l'URL dans un navigateur. Après une modification manuelle, as-tu lancé `packwiz refresh` ? (la CI le vérifie) |
| `Hash mismatch` | Un fichier du pack a été modifié sans `packwiz refresh`, ou converti en CRLF. Lance `packwiz refresh`, commite, pousse |
| `OutOfMemoryError` / serveur tué | Augmente `MEMORY` **et** `MEM_LIMIT` (garde ~2 Go d'écart), puis redéploie |
| Lag (TPS < 20) | `neoforge tps`. Ajoute le mod `spark` (côté `server`) et lance `spark profiler` pour trouver le coupable |
| Les joueurs sont refusés pour mods différents | Le serveur n'a pas redémarré après le push, ou un joueur a une ancienne version de NeoForge |
| BlueMap reste vide | Vérifie `accept-download: true` dans `data/config/bluemap/core.conf` et les logs BlueMap (`bluemap/logs/debug.log`) |
| Erreur de permission sur `/data` | Le propriétaire du dataset doit correspondre à `PUID`/`PGID` (568 par défaut) |

## Mettre à jour l'image Docker

L'image est épinglée sur le tag `java21` (bon pour Minecraft 1.21.x). Pour récupérer les correctifs de l'image : Dockhand → **Pull** puis **Redeploy**.
Ça ne change ni la version de Minecraft ni celle de NeoForge, qui sont fixées dans le compose.
