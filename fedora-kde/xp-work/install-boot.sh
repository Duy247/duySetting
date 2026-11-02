#!/bin/bash
set -euo pipefail
if [[ $EUID -ne 0 ]]; then
    echo 'Run this installer with sudo or pkexec.' >&2
    exit 1
fi
assets="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/plymouth"
[[ -f "$assets/xp-work.plymouth" ]] || { echo "Run install.py first, then use the installed boot script." >&2; exit 1; }
state=/var/lib/xp-work
mkdir -p "$state" /usr/share/plymouth/themes/xp-work
if [[ ! -f "$state/original-plymouth-theme" ]]; then
    plymouth-set-default-theme > "$state/original-plymouth-theme"
fi
cp -a "$assets/." /usr/share/plymouth/themes/xp-work/
chown -R root:root /usr/share/plymouth/themes/xp-work
restorecon -RF /usr/share/plymouth/themes/xp-work
old_theme=$(cat "$state/original-plymouth-theme")
if ! plymouth-set-default-theme -R xp-work; then
    plymouth-set-default-theme "$old_theme"
    echo 'Boot image rebuild failed; previous theme selection restored.' >&2
    exit 1
fi
echo 'Windows XP boot animation installed. It will appear on the next boot.'
