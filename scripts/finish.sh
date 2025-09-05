#!/usr/bin/env bash
set -euo pipefail

# remove the installation disk and restart the console
instance_name="snow-desktop"

incus config device remove "$instance_name" install || true
incus stop --force "$instance_name" || true
incus console --type=vga "$instance_name"
