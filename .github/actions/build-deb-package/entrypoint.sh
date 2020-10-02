#!/bin/sh

set -e

DEBIAN_FRONTEND=noninteractive apt-get update --quiet

DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends --quiet --yes dpkg-dev

# Calling `apt-get build-dep` with ./ here to easily keep compatibility with
# old apt versions
DEBIAN_FRONTEND=noninteractive apt-get build-dep --no-install-recommends --quiet --yes ./

dpkg-buildpackage "$@"

mv ../*.deb .

