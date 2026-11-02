#!/usr/bin/env bash
# Run in the logged-in Plasma session after installing IBus Typing Booster.
set -euo pipefail
source_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
for tool in dconf kwriteconfig6 kreadconfig6; do
    command -v "$tool" >/dev/null || { echo "Missing prerequisite: $tool" >&2; exit 1; }
done
backup="$HOME/Backups/duySetting-tools/ibus-$(date +%Y%m%d-%H%M%S-%N)"
mkdir -p "$backup"
dconf dump /desktop/ibus/ > "$backup/ibus.dconf"
kreadconfig6 --file kwinrc --group Wayland --key InputMethod > "$backup/previous-input-method.txt"
dconf load /desktop/ibus/ < "$source_dir/ibus-telex.dconf"
kwriteconfig6 --file kwinrc --group Wayland --key InputMethod \
    /usr/share/applications/org.freedesktop.IBus.Panel.Wayland.Gtk3.desktop
printf 'Telex configured. Sign out of Plasma and back in. Toggle English/Telex with Ctrl+Space.\nBackup: %s\n' "$backup"
