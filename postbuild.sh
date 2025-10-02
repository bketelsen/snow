#!/bin/bash
# SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
# SPDX-FileCopyrightText: 2023 Harald Sitter <sitter@kde.org>
# SPDX-FileCopyrightText: 2024 Bruno Pajdek <brupaj@proton.me>

# Build image using mkosi, well, somewhat. mkosi is actually a bit too inflexible for our purposes so we generate a OS
# tree using mkosi and then construct shipable raw images (for installation) and tarballs (for systemd-sysupdate)
# ourselves.

set -ex

echo "Starting postbuild.sh"
OUTPUTDIR="${OUTPUTDIR:-mkosi.output}"

IMAGE_ID=$(cat "${OUTPUTDIR}/SNOW_image_id.txt")
IMAGE_VERSION=$(cat "${OUTPUTDIR}/SNOW_version.txt")
# get the SNOWDIR from
SNOWDIR=$(cat "${OUTPUTDIR}/SNOWDIR.txt")
echo "SNOWDIR: $SNOWDIR"
SNOWDIRPATH="${OUTPUTDIR}/${SNOWDIR}"
echo "SNOWDIRPATH: $SNOWDIRPATH"

IMG=${SNOWDIR}.raw                    # Output raw image path
echo "IMG: $IMG"
echo "IMAGE_ID: $IMAGE_ID"
echo "IMAGE_VERSION: $IMAGE_VERSION"




echo "$IMAGE_VERSION"



MAIN_UKI="${SNOWDIRPATH}/kde-linux.efi"               # Output main UKI path
LIVE_UKI="${SNOWDIRPATH}/live.efi"          # Output live UKI path
# SUPER WARNING: Do not use the more common foo.erofs.caibx suffix. It breaks stuff!
# https://github.com/systemd/systemd/issues/38605
# We'll rename things accordingly via sysupdate.d files.
ROOTFS_CAIBX=${SNOWDIR}_root-x86-64.caibx
ROOTFS_EROFS=${SNOWDIR}_root-x86-64.erofs # Output erofs image path
IMG="${SNOWDIR}.raw"                    # Output raw image path

EFI_BASE=kde-linux_${IMAGE_VERSION} # Base name of the UKI in the image's ESP (exported so it can be used in basic-test-efi-addon.sh)
EFI=${EFI_BASE}+3.efi # Name of primary UKI in the image's ESP




# NOTE: /efi must be empty so auto mounting can happen. As such we put our templates in a different directory
rm -rfv "${SNOWDIRPATH}/efi"
[ -d "${SNOWDIRPATH}/efi" ] || mkdir --mode 0700 "${SNOWDIRPATH}/efi"
[ -d "${SNOWDIRPATH}/usr/share/factory/boot" ] || mkdir --mode 0700 "${SNOWDIRPATH}/usr/share/factory/boot"
[ -d "${SNOWDIRPATH}/usr/share/factory/boot/EFI" ] || mkdir --mode 0700 "${SNOWDIRPATH}/usr/share/factory/boot/EFI"
[ -d "${SNOWDIRPATH}/usr/share/factory/boot/EFI/Linux" ] || mkdir --mode 0700 "${SNOWDIRPATH}/usr/share/factory/boot/EFI/Linux"
[ -d "${SNOWDIRPATH}/usr/share/factory/boot/EFI/Linux/$EFI_BASE.efi.extra.d" ] || mkdir --mode 0700 "${SNOWDIRPATH}/usr/share/factory/boot/EFI/Linux/$EFI_BASE.efi.extra.d"
#cp -v "${SNOWDIRPATH}"/kde-linux.efi "$MAIN_UKI"
mv -v "${SNOWDIRPATH}"/kde-linux.efi "${SNOWDIRPATH}/usr/share/factory/boot/EFI/Linux/$EFI"
#mv -v "${SNOWDIRPATH}"/live.efi "$LIVE_UKI"
mv -v "${SNOWDIRPATH}"/erofs.addon.efi "${SNOWDIRPATH}/usr/share/factory/boot/EFI/Linux/$EFI_BASE.efi.extra.d/erofs.addon.efi"


# Now let's actually build a live raw image. First, the ESP.
# We use kde-linux.cache instead of /tmp as usual because we'll probably run out of space there.

# Since we're building a live image, replace the main UKI with the live one.
mv "$LIVE_UKI" "${SNOWDIRPATH}/usr/share/factory/boot/EFI/Linux/$EFI"

cd "${OUTPUTDIR}"

# # Create a 260M large FAT32 filesystem inside of esp.raw.
fallocate -l 260M esp.raw
mkfs.fat -F 32 esp.raw

# # Mount it to esp.raw.mnt.
mkdir -p esp.raw.mnt # The -p prevents failure if directory already exists

# ### THIS Breaks in mkosi
mount esp.raw esp.raw.mnt

# # Copy everything from /usr/share/factory/boot into esp.raw.mnt.
cp --archive --recursive "${SNOWDIRPATH}/usr/share/factory/boot/." esp.raw.mnt

# # We're done, unmount esp.raw.mnt.
umount esp.raw.mnt

# Now, the root.

# Copy back the main UKI for the root.
cp "$MAIN_UKI" "${SNOWDIRPATH}/usr/share/factory/boot/EFI/Linux/$EFI"



# Drop flatpak data from erofs. They are in the usr/share/factory and deployed from there.
rm -rf "$SNOWDIRPATH/var/lib/flatpak"
mkdir "$SNOWDIRPATH/var/lib/flatpak" # but keep a mountpoint around for the live session
time mkfs.erofs -d0 -zzstd -C 65536 --chunksize 65536 -Efragments,ztailpacking "$ROOTFS_EROFS" "$SNOWDIRPATH" > /dev/null 2>&1
# cp --reflink=auto "$ROOTFS_EROFS" root.raw

# Now assemble the two generated images using systemd-repart and the definitions in mkosi.repart into $IMG.
touch "$IMG"
systemd-repart --no-pager --empty=allow --size=auto --dry-run=no --root=. --definitions=mkosi.repart "$IMG"

#./basic-test.py "$IMG" "$EFI_BASE.efi" || exit 1
# rm ./*.test.raw


go install -v github.com/folbricht/desync/cmd/desync@latest
~/go/bin/desync make -m 32:64:128 "$ROOTFS_CAIBX" "$ROOTFS_EROFS"
# Be very careful with this file. It is here for backwards compat. It must not appear in SHA256SUMS.
# https://github.com/systemd/systemd/issues/38605
cp "$ROOTFS_CAIBX" "$ROOTFS_EROFS.caibx"

# Fake artifacts to keep older systems happy to upgrade to newer versions.
# Can be removed once we have started having revisions in our update trees.
# tar -cf ${OUTPUTDIR}_root-x86-64.tar -T /dev/null
# zstd --threads=0 --rm ${OUTPUTDIR}_root-x86-64.tar

# TODO before accepting new uploads perform sanity checks on the artifacts (e.g. the tar being well formed)

# efi images and torrents are 700, make them readable so the server can serve them
chmod go+r "$OUTPUTDIR".* ./*.efi
# ls -lah
