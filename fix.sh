#!/data/data/com.termux/files/usr/bin/bash

# Termux-Fixer entrypoint
# Runs an interactive menu or an automated "full" routine.

set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "$SCRIPT_DIR/lib/common.sh"

AUTO=0
PROFILE=""
NO_TWEAKS=0
DIAGNOSE_ONLY=0
REPO_STATUS_ONLY=0

usage() {
  cat <<USAGE
$TF_APP_NAME v$TF_VERSION

Usage:
  ./fix.sh                  # interactive
  ./fix.sh --auto           # run Full Auto Fix
  ./fix.sh --profile minimal|full   # install a profile after fixes
  ./fix.sh --no-tweaks      # skip .bashrc quality-of-life additions
  ./fix.sh --diagnose       # create a diagnostic report and exit
  ./fix.sh --repo-status    # print current repo config and exit

Logs:
  ~/.termux-fixer/termux-fixer-*.log
USAGE
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    -h|--help) usage; exit 0 ;;
    --auto) AUTO=1; shift ;;
    --profile) PROFILE="${2:-}"; shift 2 ;;
    --no-tweaks) NO_TWEAKS=1; shift ;;
    --diagnose) DIAGNOSE_ONLY=1; shift ;;
    --repo-status) REPO_STATUS_ONLY=1; shift ;;
    *) err "Unknown option: $1"; usage; exit 2 ;;
  esac
done

banner() {
  clear || true
  say "${bold}==========================================${reset}"
  say "${bold}   TERMUX FIXER${reset}  ${gray}(v$TF_VERSION)${reset}"
  say "${bold}==========================================${reset}"
}

full_auto_fix() {
  hr
  info "Starting Full Auto Fix…"
  repo_status || true
  setup_storage
  fix_repo_keyring
  pkg_update_upgrade
  fix_broken_packages
  clean_caches
  if [[ $NO_TWEAKS -eq 0 ]]; then
    optimize_termux
  else
    warn "Skipping tweaks (--no-tweaks)."
  fi
  ok "Full Auto Fix complete."
  hr
}

install_profile_prompted() {
  local p="$1"
  case "$p" in
    minimal) install_profiles "$SCRIPT_DIR/profiles/minimal.pkgs" ;;
    full) install_profiles "$SCRIPT_DIR/profiles/full.pkgs" ;;
    "") return 0 ;;
    *) err "Unknown profile: $p"; return 2 ;;
  esac
}

menu() {
  while true; do
    banner
    say "${blue}Choose an option:${reset}"
    say "  1) Full Auto Fix (recommended)"
    say "  2) Setup storage permissions"
    say "  3) Fix repo keyring / signatures"
    say "  4) Update + upgrade packages"
    say "  5) Fix broken packages"
    say "  6) Clean caches"
    say "  7) Reset apt lists (safe)"
    say "  8) Hash Sum mismatch / cache repair"
    say "  9) Repo status (print sources)"
    say " 10) Diagnose & create report"
    say " 11) Install essentials (Minimal profile)"
    say " 12) Install dev stack (Full profile)"
    say " 13) Backup Termux config to shared storage"
    say " 14) Restore Termux config from backup"
    say "  0) Exit"
    hr
    read -r -p "Enter choice: " choice

    case "$choice" in
      1) init_logging; require_termux; full_auto_fix; read -r -p "Press Enter to continue…" _ ;;
      2) init_logging; setup_storage; read -r -p "Press Enter to continue…" _ ;;
      3) init_logging; fix_repo_keyring; read -r -p "Press Enter to continue…" _ ;;
      4) init_logging; pkg_update_upgrade; read -r -p "Press Enter to continue…" _ ;;
      5) init_logging; fix_broken_packages; read -r -p "Press Enter to continue…" _ ;;
      6) init_logging; clean_caches; read -r -p "Press Enter to continue…" _ ;;
      7) init_logging; lists_reset; read -r -p "Press Enter to continue…" _ ;;
      8) init_logging; hash_sum_mismatch_fix; read -r -p "Press Enter to continue…" _ ;;
      9) init_logging; repo_status; read -r -p "Press Enter to continue…" _ ;;
      10) init_logging; "$SCRIPT_DIR/tools/diagnose.sh"; read -r -p "Press Enter to continue…" _ ;;
      11) init_logging; install_profile_prompted minimal; read -r -p "Press Enter to continue…" _ ;;
      12) init_logging; install_profile_prompted full; read -r -p "Press Enter to continue…" _ ;;
      13) init_logging; setup_storage; "$SCRIPT_DIR/tools/backup.sh"; read -r -p "Press Enter to continue…" _ ;;
      14) init_logging; read -r -p "Path to backup (.tar.gz): " p; "$SCRIPT_DIR/tools/restore.sh" "$p"; read -r -p "Press Enter to continue…" _ ;;
      0) break ;;
      *) warn "Invalid choice."; sleep 1 ;;
    esac
  done
}

main() {
  banner
  require_termux

  # Start logging as early as possible
  init_logging

  if [[ $REPO_STATUS_ONLY -eq 1 ]]; then
    repo_status
    exit 0
  fi

  if [[ $DIAGNOSE_ONLY -eq 1 ]]; then
    "$SCRIPT_DIR/tools/diagnose.sh"
    exit 0
  fi

  if [[ $AUTO -eq 1 ]]; then
    full_auto_fix
    if [[ -n "$PROFILE" ]]; then
      install_profile_prompted "$PROFILE"
    fi
    ok "Done. Log saved to: $TF_LOG_FILE"
    exit 0
  fi

  # If user passed only --profile without --auto, treat it as: run fix then install
  if [[ -n "$PROFILE" ]]; then
    full_auto_fix
    install_profile_prompted "$PROFILE"
    ok "Done. Log saved to: $TF_LOG_FILE"
    exit 0
  fi

  # interactive menu
  # (re-open stdout/stderr to both console and file already done)
  menu
  ok "Goodbye! Last log: $TF_LOG_FILE"
}

main "$@"
