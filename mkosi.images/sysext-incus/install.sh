#!/bin/sh
[ "$1" = "final" ] || exit 0

# Get the repository keyring key.
if [ ! -e /etc/apt/keyrings/zabbly.asc ]; then
    mkdir -p /etc/apt/keyrings/
    curl -fsSL https://pkgs.zabbly.com/key.asc -o /etc/apt/keyrings/zabbly.asc
fi

# Add the repository.
cat <<EOF > /etc/apt/sources.list.d/zabbly-incus-stable.sources
Enabled: yes
Types: deb
URIs: https://pkgs.zabbly.com/incus/stable
Suites: trixie
Components: main
Signed-By: /etc/apt/keyrings/zabbly.asc

EOF

# Install the incus packages.
apt-get update
apt-get install ceph-common incus incus-ui-canonical --yes

exit 0
