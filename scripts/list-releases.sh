#!/bin/bash
url="https://extensions.snowlinux.org/extensions"


echo "Global:"
curl --silent --fail --location "${url}/SHA256SUMS"

echo "sysext-code:"
curl --silent --fail --location "${url}/sysext-code/SHA256SUMS"

echo "sysext-dev:"
curl --silent --fail --location "${url}/sysext-dev/SHA256SUMS"

echo "sysext-edge:"
curl --silent --fail --location "${url}/sysext-edge/SHA256SUMS"

