#!/usr/bin/env python3
"""Exercise the installer without touching the real session or home directory."""
import json
import os
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest

HERE = Path(__file__).resolve().parent

class InstallTests(unittest.TestCase):
    def test_install_reinstall_and_xp_guard(self):
        with tempfile.TemporaryDirectory() as tmp:
            base = Path(tmp)
            home = base / 'home'; home.mkdir()
            config = home / '.config'; config.mkdir()
            (config / 'kdeglobals').write_text('[General]\nColorScheme=Original\n')
            (config / 'plasmarc').write_text('[Theme]\nname=breeze-dark\n')
            (config / 'kwinrc').write_text('[Desktops]\nNumber=3\n')
            (config / 'kscreenlockerrc').write_text('[Daemon]\nRequirePassword=true\n[Greeter]\nWallpaperPlugin=org.kde.image\n')
            source = base / 'theme'; assets = source / 'home/dot-local'
            for rel in ['plasma/desktoptheme/Luna', 'icons/Luna', 'aurorae/themes/Luna']:
                (assets / rel).mkdir(parents=True)
            (assets / 'plasma/desktoptheme/Luna/widgets').mkdir()
            (assets / 'color-schemes').mkdir()
            (assets / 'color-schemes/Luna.colors').write_text('[General]\nName=Luna\n')
            (source / 'LICENSE').write_text('Fixture license\n')
            commands = base / 'bin'; commands.mkdir()
            for command, body in {'qdbus-qt6': 'echo \'{"desktops":[],"panels":[]}\'',
                                   'kwriteconfig6': 'exit 0'}.items():
                p = commands / command; p.write_text('#!/bin/sh\n'+body+'\n');p.chmod(0o755)
            env = dict(os.environ, HOME=str(home), PATH=str(commands)+os.pathsep+os.environ['PATH'])
            cmd = [sys.executable, str(HERE / 'install.py'), '--theme-source', str(source)]
            subprocess.run(cmd+['--dry-run'], env=env, check=True, capture_output=True)
            root = home / '.local/share/xp-work'
            self.assertFalse(root.exists())
            subprocess.run(cmd, env=env, check=True, capture_output=True)
            self.assertEqual((root / 'mode').read_text(), 'on')
            self.assertEqual(json.loads((root / 'work/lock-appearance.json').read_text())['plugin'], 'org.kde.image')
            self.assertIn('ColorScheme=Original', (root / 'work/kdeglobals').read_text())
            self.assertIn(str(home), (config / 'autostart/xp-desktop.desktop').read_text())
            installed = (home / '.local/bin/work').read_text()
            self.assertNotIn('/home/duyvt.official', installed)
            self.assertIn('startIcon', installed)
            compile(installed, 'work', 'exec')
            (config / 'kdeglobals').write_text('[General]\nColorScheme=Changed\n')
            subprocess.run(cmd, env=env, check=True, capture_output=True)
            self.assertIn('ColorScheme=Original', (root / 'work/kdeglobals').read_text())
            self.assertTrue(list((root / 'install-backups').glob('*/.local/bin/work')))
            (root / 'mode').write_text('off')
            refused = subprocess.run(cmd, env=env, capture_output=True, text=True)
            self.assertNotEqual(refused.returncode, 0)
            self.assertIn('work on', refused.stderr)
            self.assertEqual((root / 'mode').read_text(), 'off')

if __name__ == '__main__':
    unittest.main()
