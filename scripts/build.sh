#!/bin/zsh
# Compile .cherri files into build/ and sign them locally with macOS `shortcuts sign`.
#
# Cherri's own signing falls back to uploading the shortcut to a remote service (HubSign)
# whenever local signing fails. These shortcuts carry contact details, so we compile
# unsigned and sign locally only, failing loudly instead of uploading.
#
# Usage: scripts/build.sh [file.cherri ...]   (default: src/qr_vcard_share.cherri)
set -euo pipefail

root=${0:A:h:h}
cherri=$root/tools/cherri/cherri
build=$root/build

if [[ ! -x $cherri ]]; then
    echo "Cherri compiler not found at $cherri; run scripts/setup-cherri.sh first" >&2
    exit 1
fi

(( $# )) || set -- $root/src/qr_vcard_share.cherri
mkdir -p $build

for file in "$@"; do
    src=${file:A}
    name=$(sed -n 's/^#define name //p' $src | head -n 1)
    if [[ -z $name ]]; then
        echo "$src has no '#define name'" >&2
        exit 1
    fi

    # Includes such as 'vcard_parse.cherri' resolve against the working directory. With
    # --skip-sign, Cherri ignores --output and writes "<name>_unsigned.shortcut" beside the source.
    (cd ${src:h} && $cherri ${src:t} --skip-sign --no-ansi)
    mv "${src:h}/${name}_unsigned.shortcut" "$build/"
    shortcuts sign -m people-who-know-me -i "$build/${name}_unsigned.shortcut" -o "$build/${name}.shortcut"
    rm "$build/${name}_unsigned.shortcut"
    echo "Signed: $build/${name}.shortcut"
done
