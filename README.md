# SNOW is Not Only Windows

**DO NOT USE THIS YET. Seriously. Just Don't.**

SNOW is a fully customizable immutable Linux distribution implementing the
concepts described in
[Fitting Everything Together](https://0pointer.net/blog/fitting-everything-together.html).

SNOW is derived from [ParticleOS](https://github.com/systemd/particleos), mostly by means
of simplification through removal of options.

Note that SNOW is still in development, and we don't provide any backwards
compatibility guarantees at all.

The crucial difference that makes SNOW unique compared to other immutable
distributions is that users build the SNOW image themselves and sign it
with their own keys instead of installing vendor signed images. This allows
configuring the image to your liking by having full control over which
distribution is used as the base and which packages are installed into the
image.

The SNOW image is built using [mkosi](https://github.com/systemd/mkosi).
You will need to install the current main branch of mkosi to build current
SNOW images.

## Opinions

SNOW has some strong opinions:

- Debian Trixie base
- SystemD @ main
- Zabbly Kernel with ZFS enabled (no zfs boot support)
- Minimal but usable Gnome installation
- Flatpak enabled
- Immutable with A/B updates
- Extras installed via systemd-sysext

## Building

To build the image, run `mkosi -B -f` from the SNOW repository.

To update the system after installation, you clone the SNOW repository
or your fork of it, make sure `mkosi.local.conf` is configured to your liking and
run `mkosi -B -ff sysupdate -- update --reboot` which will update the system using
`systemd-sysupdate` and then reboot.

## Installation

Before installing SNOW, make sure that Secure Boot is in setup mode on the
target system. The Secure Boot mode can be configured in the UEFI firmware
interface of the target system. If there's an existing Linux installation on the
target system already, run `systemctl reboot --firmware-setup` to reboot into
the UEFI firmware interface. At the same time, make sure the UEFI firmware
interface is password protected so an attacker cannot just disable Secure Boot
again.

To install SNOW with a USB drive, first build the image on an existing
Linux system as described above. Then, burn it to the USB drive with
`mkosi burn /dev/<usb>`. Once burned to the USB drive, plug the USB drive into
the system onto which you'd like to install SNOW and boot into the USB
drive via the firmware. Then, boot into the "Installer" UKI profile. When you
end up in the root shell, run
`systemd-repart --dry-run=no --empty=force --defer-partitions=swap,root,home /dev/<drive>`
to install SNOW to the system's drive. Finally, reboot into the target
drive (not the USB) and the regular profile (not the installer one) to complete
the installation.

## LUKS recovery key

systemd doesn't support adding a recovery key to a partition enrolled with a token
only (tpm/fido2). It is possible to use cryptenroll to add a recovery password
to the root partition: `cryptsetup luksAddKey --token-type systemd-tpm2 /dev/<id>`

## Firmwares

Only firmwares that are dependencies of a kernel module are included, but some
modules don't declare their dependencies properly. Dependencies of a module can be
found with `modinfo`. If you experience missing firmwares, you should report
this to the module maintainer. `FirmwareInclude=` can be added in `mkosi.local.conf`
to include the firmware regardless of whether a module depends on it.

## Configuring systemd-homed after installation

After installing SNOW and logging into your systemd-homed managed user,
run the following to configure systemd-homed for the best experience:

```sh
homectl update \
    --auto-resize-mode=off \
    --disk-size=max \
    --luks-discard=on"
```

Disabling the auto resize mode avoids slow system boot and shutdown. Enabling
LUKS discard makes sure the home directory doesn't become inaccessible because
systemd-homed is unable to resize the home directory.

## Default root password and user when booting in a virtual machine

If you boot SNOW in a virtual machine using `mkosi vm`, the root password
is automatically set to `particleos` and a default user `particleos` with password
`particleos` is created as well.

## Credits

- SNOW name: Kyle Gospodnetich
- Idea, Inspiration, 99% of code: [systemd/particleos](https://github.com/systemd/particleos)
- Answering too many questions: Luca Boccassi
