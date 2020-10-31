#!/bin/sh

set -eu

cd -- "$INPUT_SOURCE_DIR"
dpkg-buildpackage "$@"
