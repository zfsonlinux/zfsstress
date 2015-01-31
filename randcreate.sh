#!/bin/bash

basedir="$(dirname $0)"
SCRIPT_COMMON=common.sh
if [ -f "${basedir}/${SCRIPT_COMMON}" ]; then
	. "${basedir}/${SCRIPT_COMMON}"
else
	echo "Missing helper script ${SCRIPT_COMMON}" && exit 1
fi

set -x

while :; do
	wait_for_mount $MOUNTPOINT

	for ((i=0; i< $(( $RANDOM % 256 )); i++)) ; do
		file="`randstring $(( 1 + $RANDOM % $MAX_FILENAME_LEN ))`"
		$SUDO touch "$MOUNTPOINT/$file"
	done
	randsleep 60
done
