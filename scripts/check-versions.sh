#!/usr/bin/env bash
# Vérifie que les versions Minecraft/NeoForge du serveur (docker-compose.yml)
# sont identiques à celles du pack (pack/pack.toml).
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"

pack_mc="$(sed -n 's/^minecraft = "\(.*\)"$/\1/p' "$ROOT/pack/pack.toml")"
pack_nf="$(sed -n 's/^neoforge = "\(.*\)"$/\1/p' "$ROOT/pack/pack.toml")"
compose_mc="$(sed -n 's/^ *VERSION: "\(.*\)"$/\1/p' "$ROOT/docker-compose.yml")"
compose_nf="$(sed -n 's/^ *NEOFORGE_VERSION: "\(.*\)"$/\1/p' "$ROOT/docker-compose.yml")"

status=0
if [ "$pack_mc" != "$compose_mc" ]; then
  echo "❌ Minecraft : pack.toml=$pack_mc / docker-compose.yml=$compose_mc"; status=1
fi
if [ "$pack_nf" != "$compose_nf" ]; then
  echo "❌ NeoForge : pack.toml=$pack_nf / docker-compose.yml=$compose_nf"; status=1
fi
[ $status -eq 0 ] && echo "✅ Versions cohérentes : Minecraft $pack_mc, NeoForge $pack_nf"
exit $status
