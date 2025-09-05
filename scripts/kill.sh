#!/usr/bin/env bash
set -euo pipefail

# kill and remove the instance

# make the instance_name "snow" plus the variant
instance_name="snow-desktop"

incus stop --force "$instance_name" || true
incus rm "$instance_name" || true
