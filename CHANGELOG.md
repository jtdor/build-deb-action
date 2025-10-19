# Build Debian Packages GitHub Action: Changelog

## Version 1.9.1

### Fixes

- Do not fail unexpectedly and unnecessarily with older APT versions
  when no `extra-repos` is given
  ([\#15](https://github.com/jtdor/build-deb-action/pull/15), thanks
  @funzoneq)

## Version 1.9.0

### Features

- Added the [output parameter `artifacts`](README.md#artifacts)
- Added an early check ensuring that the used Docker container is
  Debian-based

### Improvements

- Ensured that clean-up happens even when the build (or something else)
  fails
- Moved preparatory and clean-up steps into their own log groups
- Minor improvements and additions to the internal testing and linting
  workflows

### Documentation

- Added a note that this actions builds readily “debianized” sources
- Clarified the [description](README.md#host-arch) of the cross-build
  support
- Renamed the section “Inputs” to “Input Parameters”

## Version 1.8.0

### Features

- Support the use of additional APT repositories through the new
  parameters `extra-repos` and `extra-repo-keys` (thanks to
  @leonheldattoradex for the related PRs
  [\#7](https://github.com/jtdor/build-deb-action/pull/7) and
  [\#8](https://github.com/jtdor/build-deb-action/pull/8); there already
  was an old, unfinished branch with this feature)
- Add a `setup-hook` for executing commands in the build environment
  between setup and installation of build dependencies

### Documentation

- Use version 4 of actions/checkout in the documentation (and internally
  in the tests)
- Specify the working directory of the `before-build-hook`
- Reword the documentation of `docker-image`

## Version 1.7.0

### Improvements

- An ever so tiny speed-up to the installation of build dependencies
- Simplify `git` usage in the before-build-hook (suppress git’s
  complaints about “dubious ownership” in the repository) (mentioned by
  @r4sas in [\#3](https://github.com/jtdor/build-deb-action/issues/3),
  thanks)

### Documentation

- Add git to the extra-build-deps in the before-build-hook example
  (mentioned by @r4sas in
  [\#3](https://github.com/jtdor/build-deb-action/issues/3), thanks)
- Mention that the before-build-hook is executed as the root user
- Set a valid package version in the before-build-hook example (valid
  according to the Debian policy)

## Version 1.6.1

- Fix a failure when moving artifacts with valid filenames (introduced
  by version 1.6.0, fixes
  [\#3](https://github.com/jtdor/build-deb-action/issues/3), thanks
  @r4sas)

## Version 1.6.0

- Leverage
  [libdpkg-perl](https://packages.debian.org/stable/libdpkg-perl) to
  find the artifacts to move
- Log a message if `source-dir/..` and `artifacts-dir` are identical and
  an artifact did not need to be moved

## Version 1.5.0

- Add a before-build hook for executing commands inside the build
  container after the installation of build dependencies and right
  before `dpkg-buildpackage` is executed

## Version 1.4.0

- Create the action’s temporary files and directories below
  [RUNNER_TEMP](https://docs.github.com/en/actions/learn-github-actions/variables#default-environment-variables)
- Reword a reference to `pbuilder` and `sbuild` in the README.md

## Version 1.3.0

- Support building the source package
- Use version 3 of actions/checkout

## Version 1.2.0

Add parameter `extra-docker-args` to pass additional arguments to
`docker run` when the build container is started
([\#1](https://github.com/jtdor/build-deb-action/pull/1), thanks @usimd)

## Version 1.1.0

Add support for local Dockerfiles to the `docker-image` parameter

## Version 1.0.0

First release
