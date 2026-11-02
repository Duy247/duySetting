#!/usr/bin/env python3
"""Install the XP/work switch in a running KDE session; preserve its baseline."""
import argparse
import configparser
import datetime
import json
from pathlib import Path
import shutil
import subprocess
import tempfile

HERE = Path(__file__).resolve().parent
COMMIT = '68a6405ca03f55f83998991ca09d4d6bde9d56ec'
URL = 'https://github.com/klapeto/KDE-plasma-luna.git'
parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('--dry-run', action='store_true')
parser.add_argument('--theme-source', type=Path, help='Existing KDE-plasma-luna checkout (offline install)')
args = parser.parse_args()
home = Path.home()
root = home / '.local/share/xp-work'
config = home / '.config'
share = home / '.local/share'
if args.dry_run:
    print(f'Install switch in {home / ".local/bin/work"}; save baseline in {root}.')
    print(f'Theme: {URL} at {COMMIT}; copy theme assets only, without QML overrides.')
    print('Enable XP login default and login animation. Boot installation is a separate sudo command.')
    raise SystemExit(0)
for cmd in ['git', 'qdbus-qt6', 'kwriteconfig6', 'plasma-apply-colorscheme', 'plasma-apply-desktoptheme', 'systemctl', 'dbus-send']:
    if not shutil.which(cmd):
        raise SystemExit(f'Missing required command: {cmd}')
if (root / 'mode').exists() and (root / 'mode').read_text().strip() == 'off':
    raise SystemExit('Run `work on` first so the installer cannot capture XP as your work appearance.')
query = (HERE / 'capture-layout.js').read_text()
layout = subprocess.check_output(['qdbus-qt6', 'org.kde.plasmashell', '/PlasmaShell', 'org.kde.PlasmaShell.evaluateScript', query], text=True)
json.loads(layout)
backup = root / 'install-backups' / datetime.datetime.now().strftime('%Y%m%d-%H%M%S-%f')
backup.mkdir(parents=True)
root.chmod(0o700)

def install(src, dest):
    if dest.exists():
        old = backup / dest.relative_to(home)
        old.parent.mkdir(parents=True, exist_ok=True)
        if dest.is_dir():
            shutil.copytree(dest, old, symlinks=True)
        else:
            shutil.copy2(dest, old)
    dest.parent.mkdir(parents=True, exist_ok=True)
    if src.is_dir():
        shutil.copytree(src, dest, dirs_exist_ok=True, symlinks=True)
    else:
        shutil.copy2(src, dest)

with tempfile.TemporaryDirectory(prefix='xp-work-theme-') as tmp:
    source = args.theme_source.expanduser().resolve() if args.theme_source else Path(tmp) / 'source'
    if not args.theme_source:
        subprocess.run(['git', 'init', '-q', str(source)], check=True)
        subprocess.run(['git', '-C', str(source), 'fetch', '--depth', '1', URL, COMMIT], check=True)
        subprocess.run(['git', '-C', str(source), 'checkout', '--detach', '-q', 'FETCH_HEAD'], check=True)
    base = source / 'home/dot-local'
    for rel in ['plasma/desktoptheme/Luna', 'icons/Luna', 'aurorae/themes/Luna', 'color-schemes/Luna.colors']:
        if not (base / rel).exists():
            raise SystemExit(f'Missing theme asset: {base / rel}')
    for rel in ['plasma/desktoptheme/Luna', 'icons/Luna', 'aurorae/themes/Luna', 'color-schemes/Luna.colors']:
        install(base / rel, share / rel)
    install(source / 'LICENSE', root / 'Luna-LICENSE')

for folder in ['original', 'work']:
    dest = root / folder
    if not (dest / 'layout.json').exists():
        dest.mkdir(exist_ok=True)
        for name in ['kdeglobals', 'plasmarc', 'kwinrc', 'kscreenlockerrc', 'ksplashrc']:
            if (config / name).exists():
                shutil.copy2(config / name, dest / name)
        (dest / 'layout.json').write_text(layout)
    if not (dest / 'lock-appearance.json').exists():
        c = configparser.RawConfigParser(strict=False, interpolation=None)
        c.optionxform = str
        c.read(config / 'kscreenlockerrc')
        profile = {'plugin': c.get('Greeter', 'WallpaperPlugin', fallback=None),
                   'wallpaper': {g: dict(c.items(g)) for g in c.sections() if g.startswith('Greeter][Wallpaper]')}}
        (dest / 'lock-appearance.json').write_text(json.dumps(profile, indent=2) + '\n')
shutil.copy2(root / 'work/kdeglobals', share / 'color-schemes/XPWorkOriginal.colors')
install(HERE / 'work', home / '.local/bin/work')
(home / '.local/bin/work').chmod(0o755)
install(HERE / 'assets/start.svg', root / 'start.svg')
install(HERE / 'assets/panel-background.svg', share / 'plasma/desktoptheme/Luna/widgets/panel-background.svg')
(share / 'plasma/desktoptheme/Luna/metadata.json').write_text(json.dumps({
    'KPlugin': {'Id': 'Luna', 'Name': 'Windows XP Luna', 'Version': '1.0', 'License': 'GPL-3.0'},
    'X-Plasma-API': '5.0'}))
install(HERE / 'assets/org.local.xp.boot', share / 'plasma/look-and-feel/org.local.xp.boot')
# Keep Fedora's disk-unlock/password prompt assets; replace only the boot artwork.
plymouth = root / 'plymouth'
plymouth.mkdir(exist_ok=True)
for asset in Path('/usr/share/plymouth/themes/spinner').glob('*.png'):
    if not asset.name.startswith(('animation-', 'throbber-')):
        shutil.copy2(asset, plymouth / asset.name)
for asset in (HERE / 'assets/plymouth').iterdir():
    shutil.copy2(asset, plymouth / asset.name)
install(HERE / 'install-boot.sh', root / 'install-boot.sh')
(root / 'mode').write_text('on')
autostart = config / 'autostart/xp-desktop.desktop'
if autostart.exists():
    install(autostart, backup / 'previous-autostart.desktop')
autostart.parent.mkdir(parents=True, exist_ok=True)
autostart.write_text('[Desktop Entry]\nType=Application\nName=Windows XP desktop default\n'
                     f'Exec="{home / ".local/bin/work"}" --startup\nOnlyShowIn=KDE;\n'
                     'X-KDE-autostart-phase=2\nTerminal=false\n')
for key, value in [('Theme', 'org.local.xp.boot'), ('Engine', 'KSplashQML')]:
    subprocess.run(['kwriteconfig6', '--file', 'ksplashrc', '--group', 'KSplash', '--key', key, value], check=True)
print(f'Installed. Backups: {backup}')
print('Run `work off` for XP, `work on` for your saved KDE desktop.')
print('Optional boot animation: sudo bash ~/.local/share/xp-work/install-boot.sh')
