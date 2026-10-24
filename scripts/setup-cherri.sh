#!/bin/zsh
# Build the Cherri compiler this project uses: upstream Cherri at a pinned commit, plus the fixes
# in patches/cherri/ (see the README for what they fix). The checkout lives in tools/cherri and is
# owned by this script: re-running it resets that checkout, discarding any local edits there.
#
# Usage: scripts/setup-cherri.sh
set -euo pipefail

root=${0:A:h:h}
dir=$root/tools/cherri
# electrikmilk/cherri main as of 2026-10-14 (v2.3.0 plus fixes).
commit=bcc0095754e2cc0baaeb4d93dae172b8153b4716

if ! command -v go >/dev/null; then
    echo "Go is required to build Cherri: brew install go" >&2
    exit 1
fi

if [[ ! -d $dir/.git ]]; then
    git clone --quiet https://github.com/electrikmilk/cherri.git $dir
fi

cd $dir
git fetch --quiet origin
git -c advice.detachedHead=false checkout --quiet --force $commit
git checkout --quiet -B qrcode-vcard-fixes
git am --quiet $root/patches/cherri/*.patch
go build -o cherri .
./cherri --version --no-ansi
