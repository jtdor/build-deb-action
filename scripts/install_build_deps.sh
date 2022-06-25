#!/bin/sh

set -eu

APT_CONF_FILE=/etc/apt/apt.conf.d/50build-deb-action

export DEBIAN_FRONTEND=noninteractive

cat > "$APT_CONF_FILE" <<-EOF
	APT::Get::Assume-Yes "yes";
	APT::Install-Recommends "no";
	quiet "yes";
EOF

# Adapted from pbuilder's support for cross-compilation:
if [ -n "$INPUT_HOST_ARCH" ]; then
	dpkg --add-architecture "$INPUT_HOST_ARCH"
	INPUT_EXTRA_BUILD_DEPS="$INPUT_EXTRA_BUILD_DEPS crossbuild-essential-$INPUT_HOST_ARCH libc-dev:$INPUT_HOST_ARCH"
	printf 'APT::Get::Host-Architecture "%s";\n' "$INPUT_HOST_ARCH" >> "$APT_CONF_FILE"
fi

# Debian-based Docker images usually contain a configuration file that makes
# the APT cache get immediately cleaned after installations. We don’t want that
# here.
rm -f -- /etc/apt/apt.conf.d/docker-clean

if [ -n "$INPUT_BUILD_DEP_CACHE_DIR" ]; then
	mkdir --parents -- "$INPUT_BUILD_DEP_CACHE_DIR"
	printf 'Dir::Cache "%s";\n' "$INPUT_BUILD_DEP_CACHE_DIR" >> "$APT_CONF_FILE"
fi

apt-get update

# Remove cached packages that turn out to be outdated after `apt-get update`
apt-get autoclean

# shellcheck disable=SC2086
apt-get build-dep $INPUT_APT_OPTS -- "./$INPUT_SOURCE_DIR"

# In theory, explicitly installing dpkg-dev would not be necessary. `apt-get
# build-dep` will *always* install build-essential which depends on dpkg-dev.
# But let’s be explicit here.
# shellcheck disable=SC2086
apt-get install $INPUT_APT_OPTS -- dpkg-dev $INPUT_EXTRA_BUILD_DEPS

if [ -n "$INPUT_BUILD_DEP_CACHE_DIR" ]; then
	rm -fr -- \
		"${INPUT_BUILD_DEP_CACHE_DIR}/archives/lock" \
		"${INPUT_BUILD_DEP_CACHE_DIR}/archives/partial"
fi
