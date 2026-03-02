#!/data/data/com.termux/files/usr/bin/bash
set -Eeuo pipefail

if [[ $# -lt 1 ]]; then
  echo "Usage: ./tools/restore.sh <backup.tar.gz>"
  exit 2
fi

IN="$1"
if [[ ! -f "$IN" ]]; then
  echo "File not found: $IN"
  exit 2
fi

tar -xzf "$IN" -C / 2>/dev/null || true

echo "Restore attempted. Restart Termux if needed."
