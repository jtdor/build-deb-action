#!/bin/sh

set -eu

# Usage:
#   bdp_error MESSAGE
bdp_error()
{
	echo "::error::$1"
}

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

clean_up()
{
	rm --force "$env_file"
}

env_file=$(mktemp) || exit 1
trap clean_up EXIT INT HUP TERM

BDP_ARTIFACTS_DIR=/github/workspace/${BDP_ARTIFACTS_DIR:-.}
case "$(realpath --canonicalize-missing -- "$BDP_ARTIFACTS_DIR")" in
	/github/workspace*)
		;;
	*)
		bdp_error "artifacts-dir is not in GITHUB_WORKSPACE"
		exit 2
		;;
esac

BDP_SOURCE_DIR=/github/workspace/${BDP_SOURCE_DIR:-.}
case "$(realpath --canonicalize-missing -- "$BDP_SOURCE_DIR")" in
	/github/workspace*)
		;;
	*)
		bdp_error "source-dir is not in GITHUB_WORKSPACE"
		exit 2
		;;
esac

bdp_start_group "Preparing build container"
env > "$env_file"
docker run \
	--detach \
	--env-file="$env_file" \
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
bdp_end_group
