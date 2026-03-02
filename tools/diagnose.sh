#!/data/data/com.termux/files/usr/bin/bash
set -Eeuo pipefail

REPORT_DIR="$HOME/.termux-fixer"
mkdir -p "$REPORT_DIR"
OUT="$REPORT_DIR/diagnose-$(date +%Y%m%d-%H%M%S).txt"

{
  echo "Termux-Fixer Diagnose Report"
  echo "Generated: $(date)"
  echo
  echo "== Basics =="
  echo "USER: $(whoami)"
  echo "HOME: $HOME"
  echo "PREFIX: ${PREFIX:-}"
  echo "SHELL: ${SHELL:-}"
  echo "ARCH: $(uname -m)"
  echo "KERNEL: $(uname -sr)"
  if command -v getprop >/dev/null 2>&1; then
    echo "ANDROID: $(getprop ro.build.version.release 2>/dev/null || true)"
    echo "SDK: $(getprop ro.build.version.sdk 2>/dev/null || true)"
    echo "DEVICE: $(getprop ro.product.model 2>/dev/null || true)"
  fi
  echo
  echo "== Termux version (if available) =="
  if command -v termux-info >/dev/null 2>&1; then
    termux-info
  else
    echo "termux-info not installed"
  fi
  echo
  echo "== Storage =="
  ls -la "$HOME" | sed -n '1,200p'
  echo
  echo "== Repos =="
  if [[ -f "$PREFIX/etc/apt/sources.list" ]]; then
    echo "-- sources.list --"; cat "$PREFIX/etc/apt/sources.list"
  fi
  if [[ -d "$PREFIX/etc/apt/sources.list.d" ]]; then
    echo "-- sources.list.d --"; ls -la "$PREFIX/etc/apt/sources.list.d"; 
    for f in "$PREFIX"/etc/apt/sources.list.d/*; do
      [[ -f "$f" ]] && { echo "---- $f ----"; cat "$f"; }
    done
  fi
  echo
  echo "== Package health =="
  apt update || true
  dpkg -l | sed -n '1,200p'
  echo
  echo "== Network quick checks =="
  echo "DNS (getent hosts):"; getent hosts termux.dev 2>/dev/null || true
  echo "Ping (1 packet):"; ping -c 1 -W 2 1.1.1.1 2>/dev/null || true
  if command -v curl >/dev/null 2>&1; then
    echo "HTTP HEAD packages.termux.dev:"; curl -fsSIL --max-time 8 https://packages.termux.dev 2>/dev/null | sed -n '1,20p' || true
  else
    echo "curl not installed"
  fi
  echo
  echo "== Disk =="
  df -h
  echo
  echo "== Recent Termux-Fixer logs =="
  ls -la "$HOME/.termux-fixer" 2>/dev/null | sed -n '1,200p' || true
} > "$OUT" 2>&1

echo "Saved: $OUT"
