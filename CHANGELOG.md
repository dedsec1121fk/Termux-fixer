# Changelog

## 2.1.0
- Smarter update flow: internet check + repo repair fallback when `pkg update` fails
- Added safe apt list reset + Hash Sum mismatch recovery steps
- Added `--diagnose` and `--repo-status` CLI flags
- Expanded diagnose report (Android/device info, HTTP check, recent logs)
- Menu expanded with repo status + cache/list repair utilities

## 2.0.0
- New interactive menu + non-destructive fixes
- Proper storage detection (`$HOME/storage`)
- Keyring repair, broken-package routine, cache cleanup
- Install profiles (minimal/full)
- Diagnostics report generator
- Backup/restore helpers
- Logging to `~/.termux-fixer/`
