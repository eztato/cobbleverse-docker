#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"

if [ "$#" -ne 1 ]; then
  echo "Uso: $0 data/config/<ruta/archivo>"
  echo "Ejemplo: $0 data/config/cobblemon/main.json"
  exit 1
fi

SRC_INPUT="$1"

if [[ "$SRC_INPUT" = /* ]]; then
  SRC_PATH="$SRC_INPUT"
else
  SRC_PATH="$ROOT_DIR/$SRC_INPUT"
fi

if [ ! -f "$SRC_PATH" ]; then
  echo "No existe el archivo: $SRC_PATH"
  exit 1
fi

case "$SRC_PATH" in
  "$ROOT_DIR"/data/config/*)
    REL_PATH="${SRC_PATH#"$ROOT_DIR"/data/config/}"
    ;;
  *)
    echo "El archivo debe estar dentro de data/config/"
    exit 1
    ;;
esac

DST_PATH="$ROOT_DIR/config/$REL_PATH"
DST_DIR="$(dirname "$DST_PATH")"
mkdir -p "$DST_DIR"

if [ -f "$DST_PATH" ]; then
  TS="$(date +%Y%m%d-%H%M%S)"
  cp -a "$DST_PATH" "$DST_PATH.bak.$TS"
  echo "Backup creado: $DST_PATH.bak.$TS"
fi

cp -a "$SRC_PATH" "$DST_PATH"
echo "Promovido a override: $DST_PATH"
echo "Aplica cambios con: docker compose restart cobbleverse-docker"
