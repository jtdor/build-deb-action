#!/bin/sh

set -eu

# Usage:
#   bdp_end_group
bdp_end_group()
{
	echo "::endgroup::"
}

# Usage:
#   bdp_start_group GROUP_NAME
bdp_start_group()
{
	echo "::group::$1"
}

bdp_start_group "Preparing build container"
env > "$HOME/build-deb-package.env"
docker run \
	--detach \
	--env-file="$HOME/build-deb-package.env" \
	--name=bdp_container \
	--rm \
	--volume="$GITHUB_ACTION_PATH":/github/action \
	--volume="$GITHUB_WORKSPACE":/github/workspace \
	--workdir=/github/workspace \
	-- "$BDP_DOCKER_IMAGE" tail -f /dev/null
bdp_end_group

bdp_start_group "Installing build dependencies"
docker exec bdp_container /github/action/install_build_deps.sh
bdp_end_group

bdp_start_group "Building package"
docker exec bdp_container /github/action/build_packages.sh
bdp_end_group

bdp_start_group "Moving artifacts"
docker exec bdp_container /github/action/move_artifacts.sh
bdp_end_group

bdp_start_group "Stopping build container"
docker stop --time=1 bdp_container
rm -f "$HOME/build-deb-package.env"
bdp_end_group
