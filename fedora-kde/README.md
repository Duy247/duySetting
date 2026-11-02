# Fedora KDE desktop

Current ThinkPad T14s Gen 2 Intel desktop configuration, captured October 22, 2026 on Fedora 44 / Plasma 6.7.

- Calm Charcoal theme, muted blue accent, dark Breeze panel and icons.
- Ubuntu Nerd Font 13 pt, JetBrainsMono Nerd Font Mono 13 pt, small text 12 pt.
- Compact 9 pt clock with the date below the time.
- Three workspaces: Code, Web, Tools.
- Natural two-finger scrolling, tap-to-click, tap-and-drag, typing suppression, pointer acceleration 0.1.
- Battery: Power Save, 45% display brightness, keyboard backlight off; display off after 3 minutes and suspend after 10 minutes idle. AC: Balanced.

## Restore

Requires KDE Plasma, Python 3, Ubuntu Nerd Font, and JetBrainsMono Nerd Font Mono. Install the fonts from [Nerd Fonts](https://www.nerdfonts.com/font-downloads). The wallpaper is Fedora's installed `/usr/share/wallpapers/DarkestHour/contents/images/2560x1600.jpg`; install the corresponding wallpaper package if absent.

Sign out of Plasma and use a text console (Ctrl+Alt+F3), then run from the repository root:

```bash
python3 fedora-kde/restore.py --dry-run
python3 fedora-kde/restore.py
```

The script backs up each destination before replacing it. Log back in afterward. Existing panel layout and keyboard shortcuts will be replaced with this snapshot. The touchpad device IDs and monitor/workspace layout belong to this ThinkPad; review these settings before restoring on another machine.

Pinch zoom depends on application support; no custom gesture service is installed. The battery's existing 75–80% charging thresholds are firmware settings and are not restored by copying these files. Set them through KDE Power Management if needed.

Only desktop configuration is included here. Font binaries and wallpaper are supplied separately; the complete local archive also contains those assets. No GitHub login credentials, SSH keys, browser profiles, or LTE connection secrets are included.

## Additional tools and input method

The October 25 additions—eyecare, Vietnamese Telex, Grok Build, Antigravity,
OpenCode v2, and Zed with local ACP commands—are documented in
[tools/README.md](tools/README.md). Their restore is separate from the desktop
snapshot and includes portable paths and configuration backups.

## XP desktop and work mode

The XP-style desktop, `work on` / `work off` switch, matching lock wallpaper,
startup animations, portable installer, and saved work reference settings are in
[xp-work/README.md](xp-work/README.md).
