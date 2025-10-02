#!/bin/sh
# SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
# SPDX-FileCopyrightText: 2024 Harald Sitter <sitter@kde.org>
# SPDX-FileCopyrightText: 2024 Bruno Pajdek <brupaj@proton.me>

# Bootstraps an Arch Linux Docker container to be ready for building KDE Linux.

# WARNING: DO NOT CALL INTO OTHER SCRIPTS HERE.
# This file needs to be self-contained because it gets run by the CI VM provisioning in isolation.

# Exit immediately if any command fails and print all commands before they are executed.
set -ex

DEBIAN_FRONTEND=noninteractive apt-get update && apt-get install -y \
    mkosi \
    build-essential \
    btrfs-progs \
    clang \
    btrfs-compsize \
    cpio \
    dosfstools \
    duperemove \
    erofs-utils \
    flatpak \
    git \
    golang \
    openssh-server \
    qemu-utils \
    qemu-system-x86 \
    rsync \
    rust-all \
    squashfs-tools \
    transmission-cli \
    tree \
    systemd-ukify

# Use mkosi from Git so we don't have to wait for releases when things break.
# OTOH, things may break in Git. Therefore, which version is used may change over time.
git clone https://github.com/systemd/mkosi.git /opt/mkosi
ln --symbolic /opt/mkosi/bin/mkosi /usr/local/bin/mkosi
