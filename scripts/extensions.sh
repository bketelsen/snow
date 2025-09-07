#!/usr/bin/env bash
set -euo pipefail

# get a list of all the sysext and confext image directories in mkosi.images directory
image_dirs=$(find mkosi.images -maxdepth 1 -type d \( -name "confext-*" -o -name "sysext-*" \))
for dir in $image_dirs; do
    # remove "mkosi.images/" prefix to get the image name
    image_name=${dir#mkosi.images/}
    echo "$image_name"
done
