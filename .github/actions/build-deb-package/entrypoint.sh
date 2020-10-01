#!/bin/sh

set -e

# Calling `apt-get build-dep` with ./ here to easily keep compatibility with
# old apt versions
apt-get build-dep --no-install-recommends --yes ./

dpkg-buildpackage "$@"

mv ../*.deb .

