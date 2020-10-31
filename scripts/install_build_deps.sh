#!/bin/sh

set -eu

export DEBIAN_FRONTEND=noninteractive

apt-get update --quiet

# Installing build-essential instead of dpkg-dev here. The former is designated
# essential for package building by the Debian Policy.
apt-get install \
	--no-install-recommends \
	--quiet \
	--yes \
	$INPUT_APT_OPTS \
	-- build-essential $INPUT_EXTRA_BUILD_DEPS

apt-get build-dep \
	--no-install-recommends \
	--quiet \
	--yes \
	$INPUT_APT_OPTS \
	-- "$INPUT_SOURCE_DIR"
