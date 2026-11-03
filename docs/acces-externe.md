# Accès depuis Internet (DuckDNS + NPMplus)

Exemple avec le domaine `monserveur.duckdns.org` : remplace-le partout par le tien.

| Service | Adresse pour tes amis | Chemin |
|---|---|---|
| **Jeu** | `monserveur.duckdns.org` | Box → port 25565 → TrueNAS (direct, **sans** NPMplus) |
| **Carte BlueMap** | `https://carte.monserveur.duckdns.org` | Box → 443 → NPMplus → BlueMap (port 8100) |

Pourquoi deux chemins : Minecraft utilise un protocole TCP brut, pas du HTTP. Un *Proxy Host* NPMplus ne peut donc pas le relayer. BlueMap, lui, est un site web classique.

## 0. Vérifications préalables

1. **DuckDNS à jour** : sur https://www.duckdns.org, l'IP affichée pour ton domaine doit être ton IP publique actuelle (https://ifconfig.me).
   Il faut un client de mise à jour actif (conteneur `linuxserver/duckdns`, ou DDNS de ta box), sinon l'adresse cassera au prochain changement d'IP.
2. **Pas de CGNAT** : l'IP WAN affichée dans ta box doit être la même que celle d'ifconfig.me. Si l'IP de la box commence par `100.64.` à `100.127.`, demande une IPv4 publique ou « full-stack » à ton FAI.
3. **Ports 80/443 déjà redirigés vers NPMplus** : probablement déjà le cas si tu l'utilises pour d'autres services.

> 💡 **Sous-domaines DuckDNS** : DuckDNS résout automatiquement tous les sous-domaines de ton domaine (`carte.monserveur.duckdns.org`, `mc.monserveur.duckdns.org`…) vers la même IP. Il n'y a rien à créer côté DNS.
> En revanche, DuckDNS ne gère **pas** les enregistrements SRV : le port externe du jeu doit donc rester **25565**, sinon tes amis devront taper `monserveur.duckdns.org:<port>`.

## 1. Le serveur de jeu

### Redirection de port sur la box

Dans l'interface de ta box (*NAT / PAT*, *Redirection de ports* ou *Port forwarding*) :

| Protocole | Port externe | IP interne | Port interne |
|---|---|---|---|
| TCP | 25565 | `<ip-truenas>` | 25565 (`MC_PORT`) |

Mets une IP fixe (bail DHCP statique) au TrueNAS si ce n'est pas déjà fait.

### Tester

- **Depuis l'extérieur** (4G sur ton téléphone, ou un ami) : https://mcsrvstat.us/server/monserveur.duckdns.org doit afficher le serveur en ligne avec ton MOTD.
- **Depuis ton LAN** : si `monserveur.duckdns.org` ne répond pas alors que le test externe fonctionne, ta box ne gère pas le *NAT loopback* (hairpin). Chez toi, utilise simplement l'IP locale du TrueNAS.

### Sécurité

Le serveur est désormais visible sur Internet, et des bots vont le scanner : c'est normal. La stack est déjà protégée :
- ✅ `ENFORCE_WHITELIST=true` : seuls les pseudos de la whitelist peuvent entrer (les scans apparaissent dans les logs comme `not white-listed`)
- ✅ `ONLINE_MODE=true` : comptes Microsoft vérifiés, impossible d'usurper un pseudo
- ✅ RCON (25575) non exposé

**N'ouvre jamais** sur la box le port 8100 (BlueMap), le 25575 (RCON) ni l'interface TrueNAS.

## 2. BlueMap via NPMplus

### Proxy Host

NPMplus → **Hosts → Proxy Hosts → Add Proxy Host** :

**Onglet Details**
- Domain Names : `carte.monserveur.duckdns.org`
- Scheme : `http`
- Forward Hostname / IP et Forward Port, selon le mode réseau de ton conteneur NPMplus :

  | NPMplus est… | Forward Hostname / IP | Port | `BLUEMAP_BIND` dans `.env` |
  |---|---|---|---|
  | **app du catalogue TrueNAS**, *Host Network* décoché (notre cas) | `<ip-truenas>` | 8100 | `0.0.0.0` (défaut) |
  | en réseau bridge (ports `80:80`, `443:443` dans son compose) | `<ip-truenas>` | 8100 | `0.0.0.0` (défaut) |
  | en `network_mode: host` (*Host Network* coché, ou compose officiel NPMplus) | `127.0.0.1` | 8100 | `127.0.0.1` (BlueMap n'est alors plus joignable directement depuis le LAN) |

  Pour l'app TrueNAS : *Apps → npmplus → Edit → Network Configuration*. Si **Host Network** est décoché, tu es en réseau bridge.

  > Dans un conteneur en bridge, `127.0.0.1` désigne le conteneur NPMplus lui-même, pas le TrueNAS. Il faut donc bien mettre l'IP LAN du TrueNAS (par exemple `192.168.1.50`).
- Coche **Block Common Exploits**.

**Onglet SSL**
- SSL Certificate : *Request a new certificate* (Let's Encrypt)
- Coche **Force SSL** et **HTTP/2 Support**

> 💡 Si tu as déjà un certificat wildcard `*.monserveur.duckdns.org` dans NPMplus (challenge DNS DuckDNS), sélectionne-le plutôt que d'en demander un nouveau.

Enregistre, puis teste `https://carte.monserveur.duckdns.org`.

### Protéger la carte (recommandé)

La carte montre ta base, celle de tes amis et la position des joueurs en direct. Deux protections, cumulables :

**a) Mot de passe avec une Access List NPMplus**
1. NPMplus → **Access Lists → Add** : nom `bluemap`, onglet *Authorization* → ajoute un ou plusieurs identifiants et mots de passe.
2. Retourne dans le Proxy Host de la carte → **Access List** : `bluemap`.
3. Partage l'identifiant et le mot de passe avec tes amis en privé (pas dans le dépôt Git, qui est public).

**b) Masquer les joueurs sur la carte**

Après le premier démarrage, BlueMap génère `data/config/bluemap/plugin.conf`. Les réglages utiles :

```hocon
live-player-markers: true        # false = plus aucun joueur affiché sur la carte
hidden-game-modes: ["spectator"]
hide-vanished: true
hide-invisible: true
```

Pour versionner ces réglages, copie le fichier dans `pack/config/bluemap/plugin.conf`, puis lance `packwiz refresh`, commite et pousse ([mods.md](mods.md)).

## 3. Récapitulatif à envoyer à tes amis

> **Serveur** : `monserveur.duckdns.org` (Multijoueur → Ajouter un serveur)
> **Carte** : https://carte.monserveur.duckdns.org (identifiants envoyés en privé)
> **Installation** : télécharge l'instance Prism sur la page Releases et suis le guide joueurs.

## Dépannage

| Symptôme | Piste |
|---|---|
| mcsrvstat.us : serveur hors ligne | Redirection de port sur la box, IP du TrueNAS, conteneur démarré ? IP DuckDNS à jour ? CGNAT ? |
| Ça marche en 4G mais pas depuis chez toi | Pas de NAT loopback sur la box : utilise l'IP locale en LAN |
| `502 Bad Gateway` sur la carte | Mauvais Forward Hostname/IP ou port (voir le tableau du mode réseau), ou BlueMap pas encore démarré |
| Échec du certificat Let's Encrypt | Le port 80 doit arriver sur NPMplus. Sinon, utilise le challenge DNS avec le fournisseur DuckDNS (token dans ton compte duckdns.org) |
| La carte s'affiche mais reste vide | Rendu en cours (voir `bluemap` dans la console), ou `accept-download` (voir [operations.md](operations.md)) |
