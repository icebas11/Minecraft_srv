# Serveur Minecraft moddé : homelab TrueNAS + Dockhand

Serveur **NeoForge 1.21.1** sous Docker ([`itzg/minecraft-server`](https://docker-minecraft-server.readthedocs.io/)).
Les mods sont gérés par un modpack **[packwiz](https://packwiz.infra.link/)** versionné dans ce dépôt Git.
Le serveur **et** les joueurs se synchronisent automatiquement sur ce pack.

```
          ce dépôt GitHub (public)
          └── pack/pack.toml  ◄────────────── source de vérité des mods
                 ▲                    ▲
     au démarrage│                    │à chaque lancement du jeu
                 │                    │
   ┌─────────────┴─────┐      ┌───────┴──────────────────┐
   │ TrueNAS / Dockhand│      │ Joueurs : Prism Launcher │
   │ conteneur itzg    │      │ + packwiz-installer      │
   │ (mods "server"    │      │ (mods "client" + "both") │
   │  + "both")        │      └──────────────────────────┘
   └───────────────────┘
```

## Contenu du dépôt

| Chemin | Rôle |
|---|---|
| [docker-compose.yml](docker-compose.yml) | Stack à déployer dans Dockhand |
| [.env.example](.env.example) | Variables de la stack (chemins, RAM, whitelist…) à copier en `.env` |
| [pack/](pack/) | Le modpack packwiz : `pack.toml`, `index.toml`, `mods/*.pw.toml`, `config/` |
| [scripts/build-prism-instance.sh](scripts/build-prism-instance.sh) | Génère l'instance Prism Launcher à distribuer aux joueurs |
| [scripts/check-versions.sh](scripts/check-versions.sh) | Vérifie que serveur et pack utilisent les mêmes versions |
| [.github/workflows/pack.yml](.github/workflows/pack.yml) | CI : contrôle le pack à chaque push, publie une release sur chaque tag `v*` |

## Documentation

1. [Installation](docs/installation.md) : TrueNAS, GitHub, Dockhand, premier démarrage
2. [Gestion des mods](docs/mods.md) : ajouter, mettre à jour, retirer des mods, configs, versions, retour arrière
3. [Guide des joueurs](docs/joueurs.md) : à envoyer à tes amis
4. [Exploitation](docs/operations.md) : console, whitelist, BlueMap, mises à jour, dépannage
5. [Accès depuis Internet](docs/acces-externe.md) : DuckDNS, redirection de port, BlueMap via NPMplus

## Démarrage rapide

1. Pousser ce dépôt sur GitHub (public).
2. Copier `.env.example` en `.env` et renseigner `MC_DATA_DIR` et `PACKWIZ_URL`.
3. Créer la stack dans Dockhand avec `docker-compose.yml` + `.env`, puis déployer.
4. Créer un tag `v1.0.0` : la release GitHub contient l'instance Prism à donner aux joueurs.

## Contenu actuel du pack

| Mod | Côté | Rôle |
|---|---|---|
| BlueMap 5.7 | serveur | Carte 3D du monde : `http://<ip-truenas>:8100` en LAN, `https://carte.<domaine>.duckdns.org` via NPMplus |
| LuckPerms 5.4.140 | serveur | Permissions fines par groupe/joueur ([operations.md](docs/operations.md#permissions-luckperms--ftb-essentials)) |
| FTB Essentials 2101.1.10 | les deux | `/home`, `/tpa`, `/back`, `/spawn`, `/warp`, `/rtp`… |
| FTB Library 2101.1.39 | les deux | Dépendance de FTB Essentials |
| Architectury API 13.0.11 | les deux | Dépendance de FTB Library |

Ajoute tes mods en suivant [docs/mods.md](docs/mods.md).
