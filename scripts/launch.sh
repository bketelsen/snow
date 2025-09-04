#!/usr/bin/env bash
set -euo pipefail

variant="server"

# first parameter to the script determines whether we're booting desktop or server
if [ "${1:-}" = "server" ]; then
    variant="server"
    # find the first file in ./mkosi.output named DayoServer_*x86-64.raw
    image_file=$(find ./mkosi.output -name "ParticleOS_*x86-64.raw" | head -n 1)
else
    variant="desktop"
    # find the first file in ./mkosi.output named DayoDesktop_*x86-64.raw
    image_file=$(find ./mkosi.output -name "ParticleOS_*x86-64.raw" | head -n 1)
fi

if [ -z "$image_file" ]; then
    echo "No image file found"
    exit 1
fi


abs_image_file=$(realpath "$image_file")

# make the instance_name "dayo" plus the variant
instance_name="dayo-$variant"

incus init "$instance_name" --empty --vm
incus config device override "$instance_name" root size=50GiB
incus config set "$instance_name" limits.cpu=4 limits.memory=8GiB
incus config set "$instance_name" security.secureboot=false
incus config device add "$instance_name" vtpm tpm
incus config device add "$instance_name" install disk source="$abs_image_file" boot.priority=90
incus start "$instance_name"


echo "Dayo is Starting..."
echo "Boot into the Live System (Installer) boot profile."
echo "at the root prompt, enter:"
echo " "
echo "> lsblk"
echo " "
echo "Identify the disk with no partitions, either sda or sdb, then use that below"
echo "> systemd-repart --dry-run=no --empty=force /dev/sdX"

echo " "
echo "When the repart is complete, enter 'systemctl poweroff'"

# this blocks until secure boot enrollment is complete
incus console --type=vga "$instance_name"

sleep 2
# this blocks until poweroff
incus console --type=vga "$instance_name"

echo "reconfiguring instance..."
sleep 3

incus config device remove "$instance_name" install || true
incus start "$instance_name"
incus console --type=vga "$instance_name"
