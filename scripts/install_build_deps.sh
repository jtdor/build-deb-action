#!/bin/sh

set -eu

export DEBIAN_FRONTEND=noninteractive

apt-get update --quiet

apt-get build-dep \
	--quiet \
	--yes \
	$INPUT_APT_OPTS \
	-- "./$INPUT_SOURCE_DIR"

# In theory, explicitly installing dpkg-dev would not be necessary. `apt-get
# build-dep` will *always* install build-essential which depends on dpkg-dev.
# But let’s be explicit here.
apt-get install \
	--no-install-recommends \
	--quiet \
	--yes \
	$INPUT_APT_OPTS \
	-- dpkg-dev $INPUT_EXTRA_BUILD_DEPS
