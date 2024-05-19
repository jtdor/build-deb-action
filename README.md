[![Linting](https://github.com/jtdor/build-deb-action/actions/workflows/lint.yml/badge.svg)](https://github.com/jtdor/build-deb-action/actions/workflows/lint.yml)
[![Testing](https://github.com/jtdor/build-deb-action/actions/workflows/test.yml/badge.svg)](https://github.com/jtdor/build-deb-action/actions/workflows/test.yml)

# Build Debian Packages GitHub Action

This action builds Debian packages in a clean, flexible environment.

It is mainly a shell wrapper around `dpkg-buildpackage`, using a configurable
Docker image to install build dependencies in and build packages. Resulting
.deb files and other build artifacts are moved to a specified place.

In some aspects, this action is comparable to `pbuilder` and `sbuild`. It uses
Docker containers instead of chroots, though, to set up the clean, predefined
build environment.

> [!IMPORTANT]
> This action is
> [intended](https://github.com/jtdor/build-deb-action/discussions/5#discussioncomment-5512205)
> to be used with repositories that are prepared to be packaged in the standard
> Debian way. This means repositories must provide a `debian/` subdirectory
> that contains information and rules about the package(s) to be built.
>
> If you are looking for an action that packages an arbitrary repository, you
> might prefer looking for a different action on the
> [GitHub Marketplace](https://github.com/marketplace?type=actions).

## Usage
### Basic Example
```yaml
on: push

jobs:
  build-debs:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: jtdor/build-deb-action@v1
        env:
          DEB_BUILD_OPTIONS: noautodbgsym
        with:
          buildpackage-opts: --build=binary --no-sign
```

### Input Parameters
All input parameters have a default value or are optional.

#### `apt-opts`
Extra options to be passed to `apt-get` when installing build dependencies and
extra packages.

Optional and empty by default.

#### `artifacts-dir`
Directory relative to the workspace where the built packages and other
artifacts will be moved to.

Defaults to `debian/artifacts` in the workspace.

#### `before-build-hook`
Shell command(s) to be executed after installing the build dependencies and right
before `dpkg-buildpackage` is executed. A single or multiple commands can be
given, same as for a
[`run` step](https://docs.github.com/en/actions/using-workflows/workflow-syntax-for-github-actions#jobsjob_idstepsrun)
in a workflow.

The hook is executed with `sh -c` as the root user *inside* the build
container. The working directory is the workspace. The package contents from
the build dependencies and [`extra-build-deps`](#extra-build-deps) are
available.

Optional and empty by default.

Example use case:
```yaml
- uses: jtdor/build-deb-action@v1
  with:
    before-build-hook: debchange --controlmaint --local="+ci${{ github.run_id }}~git$(git rev-parse --short HEAD)" "CI build"
    extra-build-deps: devscripts git
```

#### `buildpackage-opts`
Options to be passed to `dpkg-buildpackage`. See `man dpkg-buildpackage`.

Optional and empty by default.

#### `docker-image`
Name of a Debian-based Docker image to use as build container or path of a
Dockerfile in the workspace to build a temporary container from.

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

#### `extra-repos`
Extra APT repositories to configure as sources in the build environment.

Entries can be given in either format supported by APT: one-line style or
deb822 style, see
[`man sources.list`](https://manpages.debian.org/sources.list.5).

Optional and empty by default.

#### `extra-repo-keys`
Extra keys for APT to trust in the build environment. Useful in combination
with [`extra-repos`](#extra-repos).

The parameter can be used to pass either one or multiple ASCII-armored keys, or
a newline-separated list of paths to key files in ASCII-armored or binary
format. Paths to key files must be relative to the workspace.

Optional and empty by default.

#### `host-arch`
The architecture packages are built for. If this parameter is set,
cross-building (cross-compilation) is automatically set up with `apt-get` and
`dpkg-buildpackage` as described
[in the Debian wiki](https://wiki.debian.org/CrossCompiling#Building_with_dpkg-buildpackage).

Optional and defaults to the architecture the action is run on (likely amd64).

Basic example for a cross-build:
```yaml
- uses: jtdor/build-deb-action@v1
  with:
    host-arch: i386
```

#### `setup-hook`
Shell command(s) to be executed after setting-up the build environment and
right before installing the build dependencies. A single or multiple commands
can be given, same as for a
[`run` step](https://docs.github.com/en/actions/using-workflows/workflow-syntax-for-github-actions#jobsjob_idstepsrun)
in a workflow.

The hook is executed with `sh -c` as the root user *inside* the build
container. The working directory is the workspace.

Optional and empty by default.

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
