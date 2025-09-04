#!/usr/bin/env bash
set -euo pipefail

# kill and remove the instance

variant="server"

# first parameter to the script determines whether we're booting desktop or server
if [ "${1:-}" = "server" ]; then
    variant="server"
    # find the first file in ./mkosi.output named DayoServer_*x86-64.raw
    image_file=$(find ./mkosi.output -name "MetropolisOS_*x86-64.raw" | head -n 1)
else
    variant="desktop"
    # find the first file in ./mkosi.output named DayoDesktop_*x86-64.raw
    image_file=$(find ./mkosi.output -name "MetropolisOS_*x86-64.raw" | head -n 1)
fi

if [ -z "$image_file" ]; then
    echo "No image file found"
    exit 1
fi
# make the instance_name "dayo" plus the variant
instance_name="dayo-$variant"

incus stop --force "$instance_name" || true
incus rm "$instance_name" || true
