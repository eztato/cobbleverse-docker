#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
TMP_DIR="$(mktemp -d)"
WIKI_REMOTE="git@github.com:eztato/cobbleverse-docker.wiki.git"

cleanup() {
  rm -rf "$TMP_DIR"
}

trap cleanup EXIT

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || {
    echo "Comando requerido no encontrado: $1"
    exit 1
  }
}

require_cmd git
require_cmd rsync

if ! git clone "$WIKI_REMOTE" "$TMP_DIR"; then
  echo "No se pudo clonar la wiki."
  echo "Asegurate de activar GitHub Wiki en:"
  echo "Settings -> Features -> Wikis"
  exit 1
fi

REMOTE_URL="$(git -C "$TMP_DIR" remote get-url origin)"
case "$REMOTE_URL" in
  *.wiki.git) ;;
  *)
    echo "El remoto clonado no parece ser una wiki: $REMOTE_URL"
    echo "Aborta para evitar publicar en el repo principal."
    exit 1
    ;;
esac

rsync -a --delete --exclude '.git/' "$ROOT_DIR/docs/wiki/" "$TMP_DIR/"

if [ -n "$(git -C "$TMP_DIR" status --porcelain)" ]; then
  git -C "$TMP_DIR" add .
  git -C "$TMP_DIR" commit -m "docs: sync wiki content"
  git -C "$TMP_DIR" push
  echo "Wiki publicada correctamente."
else
  echo "No hubo cambios para publicar en la wiki."
fi
