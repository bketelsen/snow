#!/usr/bin/env bash
set -euo pipefail

# get a list of all the directory names under "mkosi.images" that aren't named "base"
for d in mkosi.images/*/ ; do
    d=${d%*/}
    d=${d##*/}
    if [[ "${d}" == "base" ]]; then
        continue
    fi
    echo "${d}"
done
