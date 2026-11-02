#!/usr/bin/env python3
"""Restore terminal tools and Zed settings, backing up existing destinations."""
import argparse
from datetime import datetime
from pathlib import Path
import shutil


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--dry-run', action='store_true')
    parser.add_argument('--target-home', type=Path, default=Path.home(),
                        help='Alternate home for previewing the restore')
    args = parser.parse_args()
    home = args.target_home.expanduser().resolve()
    source = Path(__file__).resolve().parent / 'files'
    backup = home / 'Backups/duySetting-tools' / datetime.now().strftime('%Y%m%d-%H%M%S-%f')

    def write(target, content, mode=0o644):
        if args.dry_run:
            print(target)
            return
        if target.exists() or target.is_symlink():
            saved = backup / target.relative_to(home)
            saved.parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(target, saved, follow_symlinks=False)
            target.unlink()
        target.parent.mkdir(parents=True, exist_ok=True)
        target.write_text(content)
        target.chmod(mode)

    for item in sorted(source.rglob('*')):
        if item.is_file():
            relative = item.relative_to(source)
            content = item.read_text().replace('__HOME__', str(home))
            write(home / relative, content, 0o755 if relative.parts[:2] == ('.local', 'bin') else 0o644)

    bashrc = home / '.bashrc'
    content = bashrc.read_text() if bashrc.exists() else ''
    if '# duySetting local tools PATH' not in content:
        content += '\n# duySetting local tools PATH\nexport PATH="$HOME/.local/bin:$PATH"\n'
    if not bashrc.exists() or content != bashrc.read_text():
        write(bashrc, content)
    if not args.dry_run:
        print('Restored tool configuration. Open a new terminal and fresh Zed threads.')
        print('Previous files saved in:', backup)
        print('Install dependencies separately with install-tools.sh.')


if __name__ == '__main__':
    main()
