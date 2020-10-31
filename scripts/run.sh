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

# Usage:
#   check_path_prefix PATH PREFIX
check_path_prefix()
{
	case "$(realpath --canonicalize-missing -- "$1")" in
		$(realpath "$2/*"))
			return 0
			;;
	esac

	return 1
}

clean_up()
{
	rm --force -- "$env_file"
}

env_file=$(mktemp) || exit 1
trap clean_up EXIT INT HUP TERM

INPUT_ARTIFACTS_DIR=${INPUT_ARTIFACTS_DIR:-.}
if ! check_path_prefix "$INPUT_ARTIFACTS_DIR" "$GITHUB_WORKSPACE"; then
	bdp_error "artifacts-dir is not in GITHUB_WORKSPACE"
	exit 2
fi

INPUT_SOURCE_DIR=${INPUT_SOURCE_DIR:-.}
if ! check_path_prefix "$INPUT_SOURCE_DIR" "$GITHUB_WORKSPACE"; then
	bdp_error "source-dir is not in GITHUB_WORKSPACE"
	exit 2
fi

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
	-- "$INPUT_DOCKER_IMAGE" tail -f /dev/null
bdp_end_group

bdp_start_group "Installing build dependencies"
docker exec bdp_container /github/action/scripts/install_build_deps.sh
bdp_end_group

bdp_start_group "Building package"
docker exec bdp_container /github/action/scripts/build_packages.sh
bdp_end_group

bdp_start_group "Moving artifacts"
docker exec bdp_container /github/action/scripts/move_artifacts.sh
bdp_end_group

bdp_start_group "Stopping build container"
docker stop --time=1 bdp_container
bdp_end_group
