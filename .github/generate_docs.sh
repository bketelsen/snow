#!/bin/bash

# Re-generate the docs for the GitHub Pages workflow.

set -euo pipefail
# set -x

main() {
    if [[ ! -d .github ]] || [[ ! -d .git ]]; then
        echo "This script must be run at the root of the repo"
        exit 1
    fi

    local -r extensionsurl="https://extensions.snowlinux.org/extensions"
    local -r releaseurl="https://github.com/bketelsen/snow/releases/tag"

    local -r tmpl=".docs-templates/"

    if [[ ! -d "${tmpl}" ]]; then
        echo "Could not find the templates. Is this script run from the root of the repo?"
        exit 1
    fi

    navorder=1



    for s in $(git ls-tree -d --name-only HEAD:mkosi.images); do
        if [[ -f ./mkosi.images/${s}/.docs-ignore ]]; then
            continue
        fi
        # ignore the base image as it is not a sysext
        if [[ "${s}" == "base" ]]; then
            continue
        fi

        navorder=$((navorder+1))
        mkdir -p "docs/${s}"
        {
        sed -e "s|%%SYSEXT%%|${s}|g" \
            -e "s|%%NAVORDER%%|${navorder}|g" \
           "${tmpl}/header.md"
        pushd "mkosi.images/${s}" > /dev/null
        if [[ -f "README.md" ]]; then
            tail -n +2 README.md
        fi
        popd > /dev/null
        echo ""
        sed -e "s|%%SYSEXT%%|${s}|g" \
            -e "s|%%RELEASEURL%%|${releaseurl}|g" \
            -e "s|%%EXTENSIONSURL%%|${extensionsurl}|g" \
           "${tmpl}/body.md"
        } > "docs/${s}/index.md"
    done

}

main "${@}"
