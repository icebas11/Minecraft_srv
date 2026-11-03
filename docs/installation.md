# Installation

## 1. Préparer le stockage sur TrueNAS SCALE

1. **Storage → Datasets** : sélectionne ton pool (exemple : `tank`) puis le dataset `apps` (crée-le s'il n'existe pas).
2. **Add Dataset** :
   - Name : `minecraft`
   - Dataset Preset : **Apps**
3. Dans `minecraft`, crée un dataset enfant `data` (preset **Apps** également).
4. **Permissions** de `minecraft/data` → **Edit** :
   - Owner user : `apps` (UID 568), Owner group : `apps` (GID 568)
   - Coche *Apply User / Apply Group* et *Apply permissions recursively*

   Si tu préfères un utilisateur dédié, crée-le et reporte son UID/GID dans `PUID`/`PGID` du `.env`.
5. **Fortement recommandé**, *Data Protection → Periodic Snapshot Tasks → Add* :
   - Dataset : `tank/apps/minecraft`, récursif
   - Toutes les heures, rétention de 2 jours (ou tous les jours, rétention de 2 semaines)

   C'est ton filet de sécurité avant chaque mise à jour du pack.

Le chemin à mettre dans `MC_DATA_DIR` est alors `/mnt/tank/apps/minecraft/data`.

## 2. Publier le dépôt sur GitHub

Le pack doit être accessible en HTTP(S) par le serveur et par les joueurs. On utilise l'URL « raw » d'un dépôt **public**.

> ⚠️ Le dépôt est public : n'y mets jamais de secret (mot de passe, token Discord…). Le fichier `.env` est exclu par `.gitignore`.

1. Crée un dépôt vide sur GitHub, par exemple `minecraft-homelab` (sans README).
2. Depuis ce dossier :
   ```bash
   git init -b main
   git add .
   git commit -m "Pack initial"
   git remote add origin https://github.com/<utilisateur>/minecraft-homelab.git
   git push -u origin main
   ```
3. Vérifie que l'URL suivante s'ouvre dans un navigateur :
   `https://raw.githubusercontent.com/<utilisateur>/minecraft-homelab/main/pack/pack.toml`
   C'est ta valeur `PACKWIZ_URL`.
4. Onglet **Actions** du dépôt : le workflow *Pack* doit passer au vert.

## 3. Déployer la stack dans Dockhand

1. **Stacks → Create** (ou équivalent selon ta version de Dockhand), nom : `minecraft`.
2. Colle le contenu de [docker-compose.yml](../docker-compose.yml).
3. Dans l'éditeur de variables d'environnement de la stack (fichier `.env`), colle [.env.example](../.env.example) puis adapte :
   - `MC_DATA_DIR`, `PACKWIZ_URL` (obligatoires)
   - `MEMORY` / `MEM_LIMIT` selon ta RAM disponible (6G / 8g conviennent pour un pack moyen ; compte 8–10G pour un gros pack)
   - `WHITELIST`, `OPS` : vos pseudos Minecraft
4. **Deploy**.

> 💡 Si ta version de Dockhand permet de lier une stack à un dépôt Git, tu peux pointer directement sur ce dépôt : le compose sera alors lui aussi versionné et mis à jour par un `git push`.

## 4. Premier démarrage

Suis les logs du conteneur `minecraft` dans Dockhand. Dans l'ordre, tu dois voir :

1. L'installation de NeoForge (`21.1.265`), qui prend quelques minutes la première fois.
2. `packwiz-installer` qui télécharge les mods du pack (`bluemap-5.7-neoforge.jar`…).
3. Le chargement des mods, puis :
   ```
   Done (xx.xxxs)! For help, type "help"
   ```

Le conteneur passe alors en état **healthy**.

### Tester

- **Jeu** : depuis le LAN, connecte-toi à `<ip-truenas>:25565` avec l'instance Prism (voir [joueurs.md](joueurs.md)).
- **Carte** : ouvre `http://<ip-truenas>:8100`. Le rendu initial prend un moment.

## 5. Créer la première release pour les joueurs

```bash
git tag v1.0.0
git push origin v1.0.0
```

La CI publie dans **Releases** :
- `homelab-pack-prism.zip` : l'instance Prism Launcher à glisser-déposer (méthode recommandée)
- `pack-v1.0.0.mrpack` : alternative pour la Modrinth App (sans mise à jour automatique)

Envoie à tes amis le lien de la page Releases avec [joueurs.md](joueurs.md).

## 6. Accès depuis l'extérieur

Voir [acces-externe.md](acces-externe.md) : domaine DuckDNS pour le jeu, et BlueMap en HTTPS via NPMplus.
