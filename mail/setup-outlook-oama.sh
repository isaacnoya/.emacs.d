#!/bin/sh
set -eu

ACCOUNT="${1:-isaac_nv@hotmail.es}"
CLIENT_ID="${OAMA_MICROSOFT_CLIENT_ID:-9e5f94bc-e8a4-4e73-b8be-63364c29d753}"
REPO_DIR="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
OAMA_TAR="${OAMA_TAR:-}"
OAMA_BIN="$REPO_DIR/bin/oama"
OAMA_CONFIG_DIR="$HOME/.config/oama"
OAMA_CONFIG="$OAMA_CONFIG_DIR/config.yaml"

export PATH="$REPO_DIR/bin:$PATH"

backup_file() {
    file="$1"
    if [ -f "$file" ]; then
        cp "$file" "$file.backup.$(date +%Y%m%d%H%M%S)"
    fi
}

find_oama_tar() {
    if [ -n "$OAMA_TAR" ]; then
        printf '%s\n' "$OAMA_TAR"
        return
    fi

    set -- "$HOME"/Downloads/oama-*-Darwin-arm64.tar.gz
    if [ -f "$1" ]; then
        printf '%s\n' "$1"
        return
    fi

    printf 'Could not find oama-*-Darwin-arm64.tar.gz in ~/Downloads.\n' >&2
    printf 'Download it from https://github.com/pdobsan/oama/releases or set OAMA_TAR=/path/file.tar.gz.\n' >&2
    exit 1
}

patch_oama_config() {
    python3 - "$OAMA_CONFIG" "$CLIENT_ID" <<'PY'
from pathlib import Path
import sys

path = Path(sys.argv[1])
client_id = sys.argv[2]
text = path.read_text()
lines = text.splitlines()
out = []
in_microsoft = False
patched = False

for line in lines:
    stripped = line.strip()
    if line.startswith("  microsoft:"):
        in_microsoft = True
        out.append(line)
        continue
    if in_microsoft and line.startswith("  ") and stripped and not line.startswith("    ") and not line.startswith("     "):
        if not patched:
            out.append(f"     client_id: {client_id}")
            patched = True
        in_microsoft = False
    if in_microsoft and stripped.startswith("client_id:"):
        out.append(f"     client_id: {client_id}")
        patched = True
        continue
    out.append(line)

if in_microsoft and not patched:
    out.append(f"     client_id: {client_id}")
    patched = True

if not patched:
    raise SystemExit("Could not patch microsoft.client_id in oama config")

path.write_text("\n".join(out) + "\n")
PY
}

printf 'Using account: %s\n' "$ACCOUNT"

mkdir -p "$REPO_DIR/bin"
tar_file="$(find_oama_tar)"
tmp_dir="$(mktemp -d)"
trap 'rm -rf "$tmp_dir"' EXIT

printf 'Installing oama from %s\n' "$tar_file"
tar -xzf "$tar_file" -C "$tmp_dir"
cp "$tmp_dir"/oama-*-Darwin-arm64/oama "$OAMA_BIN"
chmod +x "$OAMA_BIN"
xattr -d com.apple.quarantine "$OAMA_BIN" 2>/dev/null || true

printf 'Installed %s\n' "$OAMA_BIN"
"$OAMA_BIN" --version || true

mkdir -p "$OAMA_CONFIG_DIR"
if [ -f "$OAMA_CONFIG" ]; then
    if ! grep -q '^encryption:' "$OAMA_CONFIG"; then
        printf 'Existing %s does not look valid; backing it up.\n' "$OAMA_CONFIG"
        backup_file "$OAMA_CONFIG"
        rm "$OAMA_CONFIG"
    fi
fi

if [ ! -f "$OAMA_CONFIG" ]; then
    printf 'Creating %s\n' "$OAMA_CONFIG"
    "$OAMA_BIN" template || true
fi

patch_oama_config

mkdir -p "$HOME/Mail/hotmail"
backup_file "$HOME/.mbsyncrc"
backup_file "$HOME/.msmtprc"
cp "$REPO_DIR/mail/mbsyncrc.example" "$HOME/.mbsyncrc"
cp "$REPO_DIR/mail/msmtprc.example" "$HOME/.msmtprc"
chmod 600 "$HOME/.mbsyncrc" "$HOME/.msmtprc"

printf '\nNow authorize the account in Microsoft:\n'
"$OAMA_BIN" authorize microsoft "$ACCOUNT" --device

printf '\nChecking token access...\n'
"$OAMA_BIN" access "$ACCOUNT" >/dev/null
printf 'Token OK.\n'

if otool -L "$(command -v mbsync)" 2>/dev/null | grep -q '/usr/lib/libsasl2'; then
    printf '\nmbsync is linked against Apple SASL, which fails with XOAUTH2 on macOS.\n' >&2
    printf 'Run this first, then re-run this setup script:\n' >&2
    printf '  ./mail/build-mbsync-xoauth2-macos.sh\n' >&2
    exit 1
fi

printf '\nSyncing mail with mbsync...\n'
mbsync -a

printf '\nInitializing/indexing mu...\n'
if [ ! -d "$HOME/.mu" ]; then
    mu init --maildir="$HOME/Mail" --my-address="$ACCOUNT"
fi
mu index

printf '\nDone. Open mu4e in Emacs with C-c m.\n'
