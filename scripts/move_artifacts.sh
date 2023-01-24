#!/bin/sh

set -eu

# Usage:
#   mv_artifact ARTIFACT_PATH DEST_DIR
mv_artifact()
{
	ad=$(dirname "$1")
	if [ "$(realpath -- "$ad")" != "$(realpath -- "$2")" ]; then
		mv -- "$1" "$2"
		echo "Moved $(basename -- "$1")"
	fi
}

# Usage:
#   mv_other_artifact BUILDINFO_PATH OTHER_EXT DEST_DIR
mv_other_artifact()
{
	a=${1%.buildinfo}$2
	[ ! -f "$a" ] || mv_artifact "$a" "$3"
}

# Usage:
#   mv_source_package CHANGES_FILE
mv_source_package()
{
	for ext in .dsc '.tar.[[:alnum:]]\+'; do
		src_artifact=$INPUT_SOURCE_DIR/../$(grep \
			--max-count=1 --only-matching "[[:graph:]]\+$ext" "$1") || continue
		mv_artifact "$src_artifact" "$INPUT_ARTIFACTS_DIR"
	done
}

mkdir --parents -- "$INPUT_ARTIFACTS_DIR"

while read -r l; do
	artifact=$INPUT_SOURCE_DIR/../${l%% *}
	mv_artifact "$artifact" "$INPUT_ARTIFACTS_DIR"
	case "$artifact" in
		*.buildinfo)
			changes_file=${artifact%.buildinfo}.changes
			mv_source_package "$changes_file"
			mv_artifact "$changes_file" "$INPUT_ARTIFACTS_DIR"
			;;
	esac
done < "$INPUT_SOURCE_DIR/debian/files"
