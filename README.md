# 🛠️ Termux-Fixer

One script to fix common Termux headaches: storage permissions, repo/key issues, broken updates, and essential setup.

> **Version:** 2.1.0

## ✅ What it can do

### Fix & repair
- **Storage setup** (`termux-setup-storage`) with correct detection.
- **Repo/keyring repair** for common signature / GPG issues.
- **Repo repair fallback** for common update failures (cache/list reset + clock validity workaround).
- **Apt lists reset** (safe) and **Hash Sum mismatch** recovery.
- **Broken packages** routine (`apt --fix-broken`, `dpkg --configure -a`).
- **Cache cleanup** to recover from stuck installs.

### Setup & convenience
- **Install profiles** (Minimal / Full) for a clean baseline.
- **Quality-of-life tweaks** (safe `.bashrc` additions only).
- **Diagnostics report** you can attach to GitHub issues.
- **Repo status** helper (prints your current sources so others can help faster).
- **Backup/restore** helpers for your Termux config.

## ⚠️ Safety notes
- This project avoids destructive operations by default.
- It does **not** delete your files.
- Always read the prompts—Android may request storage permission.

## 🚀 Quick install

```bash
pkg update -y && pkg install git -y

git clone https://github.com/Niranj-coder/Termux-fixer
cd Termux-fixer
chmod +x fix.sh
./fix.sh
```

## 🧰 CLI usage

```bash
./fix.sh --auto                  # Full Auto Fix
./fix.sh --profile minimal       # Run fixes then install Minimal profile
./fix.sh --profile full          # Run fixes then install Full profile
./fix.sh --no-tweaks             # Skip bashrc tweaks
./fix.sh --repo-status           # Print repo sources and exit
./fix.sh --diagnose              # Create report and exit
```

## 📄 Logs & reports
- Logs: `~/.termux-fixer/termux-fixer-*.log`
- Reports: `~/.termux-fixer/diagnose-*.txt`

## 📚 Docs
- `docs/QUICKSTART.md`
- `docs/FAQ.md`

## License
MIT (see `LICENSE`).
