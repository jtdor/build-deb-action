#!/bin/sh

set -eu

cd "$BDP_SOURCES_DIR"
dpkg-buildpackage "$@"
