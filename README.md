# Build Debian Packages GitHub Action

This action builds Debian packages in a flexible environment.

It is mainly a shell wrapper around `dpkg-buildpackage`, using a configurable
Docker image to install build dependencies in and build packages. Resulting
.deb files and other build artifacts are moved to a specified place.

In some aspects, this action is comparable to `pbuilder` or `sbuild` (and it
might be desireable to use those here in the future, instead of manually
setting up a build environment and calling `dpkg-buildpackage`).

## Usage
### Basic Example
```yaml
on: push

jobs:
  build-debs:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: jtdor/build-deb-action@v1
        env:
          DEB_BUILD_OPTIONS: noautodbgsym
        with:
          buildpackage-opts: --build=binary --no-sign
```

### Inputs
All inputs have a default value or are optional.

#### `apt-opts`
Extra options to be passed to `apt-get` when installing build dependencies and
extra packages.

Optional and empty by default.

#### `artifacts-dir`
Directory relative to the workspace where the built packages and other
artifacts will be moved to.

Defaults to `debian/artifacts` in the workspace.

#### `buildpackage-opts`
Options to be passed to `dpkg-buildpackage`. See `man dpkg-buildpackage`.

Optional and empty by default.

#### `docker-image`
Name of a (Debian-based) Docker image to build packages inside or path of a
Dockerfile in GITHUB_WORKSPACE to build a container from.

Defaults to `debian:stable-slim`.

#### `extra-build-deps`
Extra packages to be installed as “build dependencies”. *This should rarely be
used, build dependencies should be specified in the `debian/control` file.*

By default, these packages are installed without their recommended
dependencies. To change this, pass `--install-recommends` in
[`apt-opts`](#apt-opts).

Optional and empty by default.

#### `extra-docker-args`
Additional command-line arguments passed to `docker run` when the build
container is started. This might be needed if specific volumes or network
settings are required.

Optional and empty by default.

#### `host-arch`
The architecture packages are built for. If this parameter is set,
cross-compilation is set up with `apt-get` and `dpkg-buildpackage` as described
[in the Debian wiki](https://wiki.debian.org/CrossCompiling#Building_with_dpkg-buildpackage).

Optional and defaults to the architecture the action is run on (likely amd64).

Basic example for cross-compilation:
```yaml
- uses: jtdor/build-deb-action@v1
  with:
    host-arch: i386
```

#### `source-dir`
Directory relative to the workspace that contains the package sources,
especially the `debian/` subdirectory.

Defaults to the workspace.

### Environment Variables
Environment variables work as you would expect. So you can use e.g. the
`DEB_BUILD_OPTIONS` variable:
```yaml
- uses: jtdor/build-deb-action@v1
  env:
    DEB_BUILD_OPTIONS: noautodbgsym
```

## Motivation
There are other GitHub actions that wrap `dpkg-buildpackage`. At the time of
writing, all of them had one or multiple limitations:
 * Hard-coding too specific options,
 * hard-coding one specific distribution as build environment,
 * installing unnecessary packages as build dependencies,
 * or expecting only exactly one .deb file.

This action’s goal is to not have any of these limitations.
