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
	for ((i=0; i< $(( $RANDOM % 256 )); i++)) ; do
		link=$MOUNTPOINT/$( randstring $(( 1 + $RANDOM % 255 )) )
		target=$( randstring $(( 1 + $RANDOM % 4096 )) )
		wait_for_mount $MOUNTPOINT
		$SUDO ln -sf "$target" "$link"
	done
	randsleep 60
done
