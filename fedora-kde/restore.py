#!/usr/bin/env python3
"""Restore this KDE desktop snapshot, preserving replaced files."""
import argparse
from datetime import datetime
from pathlib import Path
import shutil

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('--dry-run', action='store_true', help='List destinations without writing anything')
args = parser.parse_args()
source = Path(__file__).resolve().parent / 'files'
home = Path.home()
backup = home / 'Backups' / 'desktop' / ('before-restore-' + datetime.now().strftime('%Y%m%d-%H%M%S-%f'))
files = sorted(p for p in source.rglob('*') if p.is_file())
for item in files:
    rel = item.relative_to(source)
    target = home / rel
    if args.dry_run:
        print(target)
        continue
    if target.exists() or target.is_symlink():
        saved = backup / rel
        saved.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(target, saved, follow_symlinks=False)
        target.unlink()
    target.parent.mkdir(parents=True, exist_ok=True)
    shutil.copy2(item, target)
if not args.dry_run:
    print('Restored desktop settings. Sign back in to Plasma.')
    print('Previous files saved in:', backup)
