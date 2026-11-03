#!/usr/bin/env bash
# Construit une instance Prism Launcher prête à importer (dist/<pack>-prism.zip).
# L'instance lance packwiz-installer-bootstrap avant chaque démarrage du jeu :
# les mods et configs se synchronisent automatiquement avec le pack publié.
#
# Usage : scripts/build-prism-instance.sh <url-du-pack.toml>
# Exemple : scripts/build-prism-instance.sh https://raw.githubusercontent.com/moi/minecraft/main/pack/pack.toml
set -euo pipefail

BOOTSTRAP_VERSION="v0.0.3"
BOOTSTRAP_URL="https://github.com/packwiz/packwiz-installer-bootstrap/releases/download/${BOOTSTRAP_VERSION}/packwiz-installer-bootstrap.jar"

PACK_URL="${1:?Usage: $0 <url-du-pack.toml>}"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PACK_TOML="$ROOT/pack/pack.toml"

# Lit une clé "cle = \"valeur\"" dans pack.toml
toml_get() { sed -n "s/^$1 = \"\(.*\)\"$/\1/p" "$PACK_TOML" | head -n1; }

PACK_NAME="$(toml_get name)"
PACK_VERSION="$(toml_get version)"
MC_VERSION="$(toml_get minecraft)"
NEOFORGE_VERSION="$(toml_get neoforge)"

SLUG="$(echo "$PACK_NAME" | tr '[:upper:] ' '[:lower:]-')"
WORK="$ROOT/dist/prism/$SLUG"
OUT="$ROOT/dist/${SLUG}-prism.zip"

rm -rf "$WORK" "$OUT"
mkdir -p "$WORK/.minecraft"

cat > "$WORK/instance.cfg" <<EOF
[General]
ConfigVersion=1.2
InstanceType=OneSix
iconKey=default
name=${PACK_NAME}
OverrideCommands=true
PreLaunchCommand="\$INST_JAVA" -jar packwiz-installer-bootstrap.jar ${PACK_URL}
EOF

cat > "$WORK/mmc-pack.json" <<EOF
{
    "components": [
        {
            "important": true,
            "uid": "net.minecraft",
            "version": "${MC_VERSION}"
        },
        {
            "uid": "net.neoforged",
            "version": "${NEOFORGE_VERSION}"
        }
    ],
    "formatVersion": 1
}
EOF

curl -fsSL -o "$WORK/.minecraft/packwiz-installer-bootstrap.jar" "$BOOTSTRAP_URL"

mkdir -p "$ROOT/dist"
if command -v zip >/dev/null 2>&1; then
  (cd "$WORK" && zip -qr "$OUT" .)
else
  (cd "$WORK" && python3 -m zipfile -c "$OUT" instance.cfg mmc-pack.json .minecraft)
fi

echo "Instance Prism : $OUT (pack ${PACK_NAME} ${PACK_VERSION}, MC ${MC_VERSION}, NeoForge ${NEOFORGE_VERSION})"
