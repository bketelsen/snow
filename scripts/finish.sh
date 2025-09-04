#!/usr/bin/env bash
set -euo pipefail

# remove the installation disk and restart the console

incus config device remove dayo install || true
incus stop --force dayo || true
incus console --type=vga dayo