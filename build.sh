#!/usr/bin/env bash

set -euo pipefail
IFS=$'\n\t'

if [ -n "${DEBUG:-}" ]; then
    set -x
fi

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
export $(grep -v '^#' $SCRIPT_DIR/.env | xargs)

function main() {
    apt-get update \
    && apt-get upgrade -y \
    && apt-get install -y --no-install-recommends rpm \
    && if [[ "$FPM_VERSION" == 'latest' ]]; then \
        gem install --no-document fpm; \
    else \
        gem install --no-document fpm -v "$FPM_VERSION"; \
    fi

    cd $(gem env gemhome)/gems/fpm-* \
    && patch -p 0 -ruN < /src/patches/fpm-apk-archive-header.patch \
    && mkdir -pv /src/

    mkdir -p /tmp/build
    uname -a >> /tmp/build/out
}

main
