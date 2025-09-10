#!/bin/bash

# Re-generate the GitHub workflows based on templates. We do not use a matrix
# build strategy in GitHub worflows to reduce overall build time and avoid
# pulling the same base container image multiple time, once for each individual
# job.

set -euo pipefail
# set -x

main() {
    if [[ ! -d .github ]] || [[ ! -d .git ]]; then
        echo "This script must be run at the root of the repo"
        exit 1
    fi

    # Remove all existing worflows
    rm -f "./.github/workflows/sysexts"*".yml"

    local -r releaseurl="https://github.com/\${{ github.repository }}/releases/download"

    # Get the list of sysexts
    declare sysexts=()


    local -r tmpl=".workflow-templates/"
    if [[ ! -d "${tmpl}" ]]; then
        echo "Could not find the templates. Is this script run from the root of the repo?"
        exit 1
    fi

    # Generate sysexts workflows
    {
    sed -e "s|%%RELEASEURL%%|${releaseurl}|g" \
        "${tmpl}/00_push_header"

    cat "${tmpl}/05_push_build"

    cat "${tmpl}/06_push_named"

    readarray -t sysexts < <(./scripts/extensions.sh | sort)

    for image in "${sysexts[@]}"; do

        for s in $(echo "${image}" | tr ';' ' '); do
            sed "s|%%SYSEXT%%|${s}|g" "${tmpl}/15_push_build"
            echo ""
        done
    done


    # # TODO: Dynamic list of jobs to depend on
    # all_sysexts=()
    #     for s in "${sysexts[@]}"; do
    #             all_sysexts+=("${s}")
    #     done
    # uniq_sysexts="$(echo "${all_sysexts[@]}" | tr ' ' '\n' | sort -u | tr '\n' ';')"
    # sed -e "s|%%SYSEXTS%%|${uniq_sysexts}|g" "${tmpl}/16_push_named_sysexts"
    # sed -e "s|%%SYSEXTS%%|${uniq_sysexts}|g" "${tmpl}/20_gather_releases"
    } > ".github/workflows/push-snow.yml"
}

main "${@}"
