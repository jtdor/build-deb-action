#!/bin/sh

set -eu

cd "$BDP_SOURCE_DIR"
dpkg-buildpackage "$@"
