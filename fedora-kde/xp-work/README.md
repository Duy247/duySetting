# XP desktop and KDE work mode

Fedora 44 / KDE Plasma 6.8 setup, captured November 2, 2026.

- `work off`: Luna colors, XP icons/window borders, blue taskbar, green Start button,
  Bliss desktop and lock screen wallpaper.
- `work on`: saved KDE work appearance, including its lock wallpaper and icons.
- `work status`: current mode.
- XP is selected at login. The XP-style loading animation stays enabled in both modes.
- Switching reloads Plasma to clear cached taskbar/tray icons. Applications stay open.
  KDE still handles authentication; lock/password/security settings are preserved.

## Install

Run inside your KDE session as your normal user. Requires Python 3, Git, Plasma 6,
Aurorae, `qdbus-qt6`, `kwriteconfig6`, `dbus-send`, and the systemd Plasma user service.
Fedora's spinner Plymouth theme supplies the disk-unlock prompt assets.

```bash
python3 fedora-kde/xp-work/install.py --dry-run
python3 fedora-kde/xp-work/install.py
~/.local/bin/work off
```

The installer captures **this machine's current work appearance** before installing.
It does not apply the ThinkPad reference profile automatically. If the switch is
already installed, run `work on` before reinstalling; existing saved profiles remain
intact. Backups of replaced files go to
`~/.local/share/xp-work/install-backups/<timestamp>/`.

The Luna assets are downloaded from
[klapeto/KDE-plasma-luna](https://github.com/klapeto/KDE-plasma-luna), pinned to
`68a6405ca03f55f83998991ca09d4d6bde9d56ec`. Only the color scheme, icons, desktop
theme, and SVG window borders are copied. Its global widget and shell QML overrides
are excluded. A compatible existing checkout can be supplied with
`--theme-source /path/to/KDE-plasma-luna` for an offline installation.

The `work` command must be on PATH; Fedora normally includes `~/.local/bin`.

## Boot animation

After installation, enable the system boot animation separately:

```bash
sudo bash ~/.local/share/xp-work/install-boot.sh
```

This installs the theme in `/usr/share/plymouth/themes/xp-work`, records the previous
Plymouth selection in `/var/lib/xp-work/original-plymouth-theme`, and rebuilds the
boot image. It retains Fedora's password-entry assets. The next reboot displays the
animation; the installer does not reboot. The source machine's previous theme was
`bgrt`. Restore the recorded theme with:

```bash
sudo plymouth-set-default-theme -R bgrt  # substitute your recorded original theme
```

## Saved profiles and removal

The switch saves work settings when leaving work mode, so later work-mode appearance
changes persist. `original/` under `~/.local/share/xp-work` is the initial backup;
`work/` is the latest saved work appearance.

`reference-work/` preserves this ThinkPad's work palette, panel/wallpaper snapshot,
window-manager settings and lock wallpaper. `@HOME@` represents the user's home.
These are reference files, not an automatic restore: panel IDs, monitor UUIDs and
workspace IDs are machine-specific. To reproduce the original base desktop, use
[the Fedora desktop restore](../README.md) first, then install this switch.

To stop automatically selecting XP, run `work on` and remove
`~/.config/autostart/xp-desktop.desktop`. To restore the original login splash,
restore `ksplashrc` from the initial backup, or remove the XP Theme/Engine keys if
there was no original file. Boot-theme restoration is separate as described above.

## Validation and credits

The live source machine passed mode switching, work palette/panel/wallpaper restore,
lock wallpaper restoration and icon refresh checks. The boot image contains the XP
theme; full boot behavior requires a reboot. Installer checks run in an isolated home:

```bash
python3 fedora-kde/xp-work/test_install.py
```

Luna assets retain their upstream GPLv3 license (saved as `Luna-LICENSE` during
installation), attribution, and third-party artwork rights. No upstream icon pack
or Bliss image is vendored here. The loading animation, Start button and panel
adaptation are stored in `assets/`; Fedora supplies its own password-prompt assets.
