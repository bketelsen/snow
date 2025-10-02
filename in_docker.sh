#!/bin/sh
# SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
# SPDX-FileCopyrightText: 2024 Harald Sitter <sitter@kde.org>

# First thing that runs inside of Arch Linux Docker containers created by build-docker.sh.

# Exit immediately if any command fails and print all commands before they are executed.
set -ex

# Bootstrap container for building and build.
./bootstrap.sh
mkosi clean
mkosi -ff
./postbuild.sh "$@"
