# shellcheck shell=sh

# Usage:
#   die EXIT_STATUS MESSAGE
die()
{
	error "$2"
	exit "$1"
}

# Usage:
#   end_group
end_group()
{
	echo "::endgroup::"
}

# Usage:
#   error MESSAGE
error()
{
	echo "::error::$1"
}

# Usage:
#   start_group GROUP_NAME
start_group()
{
	echo "::group::$1"
}
