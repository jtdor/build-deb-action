#!/bin/sh

set -eu

# Usage:
#   error MESSAGE
error()
{
	echo "::error::$1"
}

# Usage:
#   end_group
end_group()
{
	echo "::endgroup::"
}

# Usage:
#   start_group GROUP_NAME
start_group()
{
	echo "::group::$1"
}

# Usage:
#   check_path_prefix PATH PREFIX
check_path_prefix()
{
	real_prefix=$(realpath "$2")
	case "$(realpath --canonicalize-missing -- "$1")" in
		"$real_prefix"|"$real_prefix/"*)
			return 0
			;;
	esac

	return 1
}

clean_up()
{
	rm --force -- "$env_file" "${image_id_file-}"
}

env_file=$(mktemp) || exit 1
trap clean_up EXIT INT HUP TERM

INPUT_ARTIFACTS_DIR=${INPUT_ARTIFACTS_DIR:-.}
if ! check_path_prefix "$INPUT_ARTIFACTS_DIR" "$GITHUB_WORKSPACE"; then
	error "artifacts-dir is not in GITHUB_WORKSPACE"
	exit 2
fi

if [ -n "$INPUT_BUILD_DEP_CACHE_DIR" ] && ! check_path_prefix "$INPUT_BUILD_DEP_CACHE_DIR" "$GITHUB_WORKSPACE"; then
	error "build-dep-cache-dir is not in GITHUB_WORKSPACE"
	exit 2
fi

if [ -n "$INPUT_BUILD_DEP_CACHE_DIR" ]; then
	INPUT_BUILD_DEP_CACHE_DIR=/github/workspace/$INPUT_BUILD_DEP_CACHE_DIR
fi

INPUT_SOURCE_DIR=${INPUT_SOURCE_DIR:-.}
if ! check_path_prefix "$INPUT_SOURCE_DIR" "$GITHUB_WORKSPACE"; then
	error "source-dir is not in GITHUB_WORKSPACE"
	exit 2
fi

if [ -f "$INPUT_DOCKER_IMAGE" ]; then
	if ! check_path_prefix "$INPUT_DOCKER_IMAGE" "$GITHUB_WORKSPACE"; then
		error "docker-image is the path of a Dockerfile but it is not in GITHUB_WORKSPACE"
		exit 2
	fi

	start_group "Building container image"
	image_id_file=$(mktemp) || exit 1
	docker build \
		--file="$INPUT_DOCKER_IMAGE" \
		--iidfile="$image_id_file" \
		-- "$GITHUB_WORKSPACE/$(dirname -- "$INPUT_DOCKER_IMAGE")"
	INPUT_DOCKER_IMAGE=$(cat "$image_id_file")
	end_group
fi

start_group "Starting build container"
env > "$env_file"
# shellcheck disable=SC2086
container_id=$(docker run \
	$INPUT_EXTRA_DOCKER_ARGS \
	--detach \
	--env-file="$env_file" \
	--env=GITHUB_ACTION_PATH=/github/action \
	--env=GITHUB_WORKSPACE=/github/workspace \
	--rm \
	--volume="$GITHUB_ACTION_PATH":/github/action \
	--volume="$GITHUB_WORKSPACE":/github/workspace \
	--workdir=/github/workspace \
	-- "$INPUT_DOCKER_IMAGE" tail -f /dev/null
)
end_group

start_group "Installing build dependencies"
docker exec "$container_id" /github/action/scripts/install_build_deps.sh
end_group

start_group "Building package"
docker exec "$container_id" /github/action/scripts/build_packages.sh
end_group

start_group "Moving artifacts"
docker exec "$container_id" /github/action/scripts/move_artifacts.sh
end_group

start_group "Stopping build container"
docker stop --time=1 "$container_id" >/dev/null
end_group
