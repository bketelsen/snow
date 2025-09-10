---
title: sysext-dev
nav_order: 3
---

# sysext-dev

Various dev tools to enable development tasks.

```text
build-essential
make
git
# autotools
automake
autoconf
libtool
pkg-config

# cmake
cmake
ninja-build

# python
python3
python3-pip
python3-setuptools
python3-venv

# additional development tools
valgrind
gdb
strace
ltrace
```

## Versions available

See the [sysext-dev versions](https://github.com/bketelsen/snow/releases/tag/sysext-dev).

## Usage instructions

<details markdown="block">
<summary>First time setup</summary>
Run those commands if you have not yet installed any sysext on your system:

```
run0 install -d -m 0755 -o 0 -g 0 /var/lib/extensions /var/lib/extensions.d
run0 systemctl enable --now systemd-sysext.service
```

</details>

<details markdown="block">
<summary>Installation</summary>
Define a helper function:

```
install_sysext() {
  SYSEXT="${1}"
  URL="https://extensions.snowlinux.org/extensions"
  run0 install -d -m 0755 -o 0 -g 0 /etc/sysupdate.${SYSEXT}.d
  curl --silent --fail --location "${URL}/${SYSEXT}.transfer" \
    | run0 tee "/etc/sysupdate.${SYSEXT}.d/${SYSEXT}.transfer"
  run0 /usr/lib/systemd/systemd-sysupdate update --component "${SYSEXT}"
}
```

Install the sysext:

```
install_sysext sysext-dev
```

</details>

<details markdown="block">
<summary>Merging</summary>
Note that this will merge all installed sysexts unconditionally:

```
run0 systemctl restart systemd-sysext.service
systemd-sysext status
```

You can also reboot the system.

</details>

<details markdown="block">
<summary>Updates</summary>
Update this sysext using:

```
run0 /usr/lib/systemd/systemd-sysupdate update --component sysext-dev
```

If you want to use the new version immediately, make sure to refresh the merged
sysexts:

```
run0 systemctl restart systemd-sysext.service
systemd-sysext status
```

To update all sysexts on a system:

```
for c in $(/usr/lib/systemd/systemd-sysupdate components --json=short | jq --raw-output '.components[]'); do
    run0 /usr/lib/systemd/systemd-sysupdate update --component "${c}"
done
```

</details>

<details markdown="block">
<summary>Uninstall</summary>
Define a helper function:

```
uninstall_sysext() {
  SYSEXT="${1}"
  run0 rm -i "/var/lib/extensions/${SYSEXT}.raw"
  run0 rm -i "/var/lib/extensions.d/${SYSEXT}-"*".raw"
  run0 rm -i "/etc/sysupdate.${SYSEXT}.d/${SYSEXT}.transfer"
  run0 rmdir "/etc/sysupdate.${SYSEXT}.d/"
}
```

Uninstall the sysext:

```
uninstall_sysext sysext-dev
```

Reboot your system or refresh the merged sysexts:

```
run0 systemctl restart systemd-sysext.service
systemd-sysext status
```

</details>
