#!/data/data/com.termux/files/usr/bin/bash
set -Eeuo pipefail

BACKUP_DIR="$HOME/storage/shared/TermuxBackups"
mkdir -p "$BACKUP_DIR"

STAMP=$(date +%Y%m%d-%H%M%S)
OUT="$BACKUP_DIR/termux-backup-$STAMP.tar.gz"

# Back up common user config and scripts (safe subset)
TARGETS=(
  "$HOME/.bashrc"
  "$HOME/.profile"
  "$HOME/.termux"
  "$HOME/bin"
  "$HOME/storage"
)

TMP_LIST=$(mktemp)
for t in "${TARGETS[@]}"; do
  [[ -e "$t" ]] && echo "$t" >> "$TMP_LIST"
done

tar -czf "$OUT" -T "$TMP_LIST" 2>/dev/null || true
rm -f "$TMP_LIST"

echo "Backup saved to: $OUT"
