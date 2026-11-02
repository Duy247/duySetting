# Additional Fedora KDE setup

Captured October 25, 2026 on Fedora 44, Plasma 6.7, Linux x86_64.
This adds eyecare, Vietnamese Telex, Grok Build, Antigravity, OpenCode v2,
and Zed to the older desktop snapshot. Accounts, tokens, histories, caches,
application binaries, and temporary eyecare state are excluded.

## Install and restore

Install system dependencies with Fedora's package manager:

```bash
sudo dnf install python3 curl nodejs npm ibus ibus-typing-booster ibus-gtk3 ibus-gtk4
```

The existing desktop provides KDE's `kwriteconfig6`, `kreadconfig6`, and
`busctl`. The installation script downloads official user-level applications,
installs the Codex ACP adapter, and verifies Google's Antigravity ACP archive.
It needs internet access. It installs Codex if missing because Zed's saved
configuration includes Codex as well as the three newer agents.

```bash
bash fedora-kde/tools/install-tools.sh
python3 fedora-kde/tools/restore.py --dry-run
python3 fedora-kde/tools/restore.py
bash fedora-kde/tools/restore-input-method.sh
```

The restore backs up existing destination files under
`~/Backups/duySetting-tools/`, then replaces Zed settings, the IBus environment
snippet, and `~/.local/bin/eyecare`. It adds `~/.local/bin` to Bash's PATH.
It does not change the older desktop snapshot. Close Zed before restoring its
settings. Sign out of Plasma and back in after restoring the input method.

To inspect file restoration without touching your real home:

```bash
python3 fedora-kde/tools/restore.py --target-home /tmp/duySetting-preview
```

This redirects only configuration restoration. Do not run `install-tools.sh`
or `restore-input-method.sh` for an isolated preview: they configure the live
user account. To undo restoration, copy the matching backed-up files to their
original locations. The input-method backup records its previous dconf tree
and KWin input-method value; use `dconf load /desktop/ibus/` and KDE's
`kwriteconfig6` to restore those values if needed.

## Eyecare

```bash
eyecare on                 # 30% brightness, warm 3200 K
eyecare off                # Restore previous brightness and Night Light config
eyecare status
eyecare on --brightness 35 --temperature 4000
```

This uses KDE PowerDevil brightness controls and KWin Night Light on Wayland.
It saves the original settings on the first `on`, preserving them across
repeated `on` commands. Run `off` before uninstalling if you want them restored.
The CLI uses `kwriteconfig6 --notify` so KWin applies the color settings.
The current Night Light enum uses `Mode=0` for constant warmth; older Plasma
versions may use different values. No startup service is installed.

## Vietnamese Telex

The engine is IBus Typing Booster's `tb:vi:telex`, alongside English (US),
with **Ctrl+Space** to switch. KWin uses IBus as its Wayland input method.
`90-ibus.conf` sets `XMODIFIERS=@im=ibus`; GTK and Qt input-module overrides
are deliberately absent in this Wayland setup. The restore loads the saved
engine order and hotkey without replacing unrelated KDE settings.

## Zed and AI tools

Run `grok`, `agy`, `opencode`, or `zed` from a terminal. The saved Zed preferences
include Vim mode, VS Code base keymap, Ayu theme following system appearance,
16 pt interface text, 15 pt editor text, disabled telemetry, and the machine's
existing `trust_all_worktrees=true` preference. Review the latter if restoring
onto a machine where you want per-project trust prompts.

All four agents use custom ACP commands, avoiding background registry downloads:

| Agent | Command |
| --- | --- |
| Codex | Node adapter 2.2.2 with `CODEX_PATH=~/.local/bin/codex` |
| Grok Build | `~/.local/bin/grok agent stdio` |
| Antigravity | Google's dedicated `agy_acp_server.par --uid=` runtime |
| OpenCode v2 | `~/.local/bin/opencode acp` |

Antigravity's regular `agy` CLI does not expose ACP. Its separate runtime is
pinned to 1.4.3 and installed alongside `localharness_external`. The adapter
for Codex lives under `~/.local/share/duySetting/` instead of inside Zed's cache.
Home-directory placeholders in the Zed template are expanded by `restore.py`.
The OpenCode default is `opencode/glm-5.3-flash-free`, matching the current
machine setting; change it using Zed's model selector as desired.

Sign in to the individual services after installation. Existing subscriptions
and quotas remain with each provider. OpenCode Go is a separate subscription:
run `opencode`, then `/connect` → OpenCode Go and `/models`. No credentials or
provider configuration are copied from the source machine. The installer does
not purchase plans or initiate authentication.

Recorded application versions: Zed 1.25.3, Grok 1.0.70, Antigravity CLI 1.4.7,
and OpenCode 2.1.4. Their official installers follow current releases; only the
Codex adapter and Antigravity ACP runtime above are pinned.

## Validation and sources

On the source machine, all four adapters passed ACP initialization; Codex also
passed session creation. These checks do not validate billable prompts or
sign-in on another machine. Eyecare was checked with real on/off transitions,
restoring 45% / 6500 K and applying 30% / 3200 K. The file restore is checked
in an isolated home, including backups and repeated restores. Downloading all
applications again is not part of that check.

- [Zed Linux installation](https://zed.dev/docs/linux)
- [Zed external agents](https://zed.dev/docs/ai/external-agents)
- [Grok Build](https://docs.x.ai/build/overview)
- [Antigravity CLI installation](https://antigravity.google/docs/cli/install/)
- [Google Antigravity ACP registry manifest](https://github.com/agentclientprotocol/registry/blob/main/antigravity-acp/agent.json)
- [OpenCode v2](https://opencode.ai/v2/docs/)
- [OpenCode ACP](https://opencode.ai/v2/docs/cli/acp/)
