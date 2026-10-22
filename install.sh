#!/bin/bash
set -e

SOURCE="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DEST="$HOME/.config/quickshell/roselock"

printf 'installing roselock...\n'

if [ -d "$DEST" ]; then
    BACKUP="${DEST}.backup.$(date +%Y%m%d%H%M%S)"
    mv "$DEST" "$BACKUP"
    printf 'backup created: %s\n' "$BACKUP"
fi

mkdir -p "$DEST"

cp -a "$SOURCE/." "$DEST/"

rm -f "$DEST/install.sh"

printf '\nroselock installed successfully.\n'
printf 'run with: qs -c roselock\n'