#!/usr/bin/env bash
# Install user-scoped applications and ACP runtimes. Does not log into services.
set -euo pipefail
for tool in curl python3 npm node; do
    command -v "$tool" >/dev/null || { echo "Missing prerequisite: $tool" >&2; exit 1; }
done
[[ "$(uname -s)-$(uname -m)" == "Linux-x86_64" ]] || { echo "This snapshot targets Linux x86_64." >&2; exit 1; }
export PATH="$HOME/.local/bin:$PATH"
mkdir -p "$HOME/.local/bin" "$HOME/.local/share/duySetting"
workdir=$(mktemp -d)
trap 'rm -rf "$workdir"' EXIT

# Official user-level installers. Application versions follow current releases.
curl -fsSL https://zed.dev/install.sh -o "$workdir/zed.sh"
sh "$workdir/zed.sh"
curl -fsSL https://x.ai/cli/install.sh -o "$workdir/grok.sh"
GROK_BIN_DIR="$HOME/.local/bin" bash "$workdir/grok.sh"
curl -fsSL https://antigravity.google/cli/install.sh -o "$workdir/agy.sh"
bash "$workdir/agy.sh"
curl -fsSL https://opencode.ai/v2/install -o "$workdir/opencode.sh"
bash "$workdir/opencode.sh" --no-modify-path
if [[ ! -e "$HOME/.local/bin/opencode" && ! -L "$HOME/.local/bin/opencode" ]]; then
    ln -s "$HOME/.opencode/bin/opencode" "$HOME/.local/bin/opencode"
fi
# Keep the adapter independent of Zed's temporary registry installation paths.
# --omit=optional avoids downloading another Codex runtime; CODEX_PATH selects
# the user's existing Codex executable in the Zed settings.
npm install --prefix "$HOME/.local/share/duySetting/codex-acp" --omit=optional \
    @agentclientprotocol/codex-acp@2.2.2
if ! command -v codex >/dev/null; then
    npm install --global --prefix "$HOME/.local" @openai/codex
fi
# Settings use an absolute user-level path, including for a system Codex install.
if [[ ! -e "$HOME/.local/bin/codex" && ! -L "$HOME/.local/bin/codex" ]]; then
    ln -s "$(command -v codex)" "$HOME/.local/bin/codex"
fi

# Antigravity CLI does not implement ACP; install Google's dedicated runtime.
curl -fsSL https://dl.google.com/agy-extensions/releases/linux/agy-acp-server-1.4.3-linux-x86_64.zip \
    -o "$workdir/agy-acp.zip"
python3 - "$workdir/agy-acp.zip" <<'PY'
import hashlib
from pathlib import Path
import platform
import sys
import zipfile
if platform.machine() != 'x86_64':
    raise SystemExit('This Antigravity ACP snapshot requires Linux x86_64.')
archive = Path(sys.argv[1])
expected = '0634ce5306ba92c932945455e7a83fda78e2d99c33fa8aa6ee0566206a382714'
if hashlib.sha256(archive.read_bytes()).hexdigest() != expected:
    raise SystemExit('Antigravity ACP checksum mismatch')
target = Path.home() / '.local/share/agy-acp'
target.mkdir(parents=True, exist_ok=True)
with zipfile.ZipFile(archive) as z:
    for name in ('agy_acp_server.par', 'localharness_external'):
        path = target / name
        path.write_bytes(z.read(name))
        path.chmod(0o755)
PY
printf '\nTools installed. Run restore.py to apply configuration, then sign in to each service.\n'
