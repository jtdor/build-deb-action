#!/bin/sh

set -eu

export DEBIAN_FRONTEND=noninteractive

apt-get update --quiet

# Installing build-essential instead of dpkg-dev here. The former is designated
# essential for package building by the Debian Policy.
apt-get install --no-install-recommends --quiet --yes $BDP_APT_OPTS -- build-essential $BDP_EXTRA_BUILD_DEPS

apt-get build-dep --no-install-recommends --quiet --yes $BDP_APT_OPTS -- "$BDP_SOURCES_DIR"
