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
	randsleep 60
	wait_for_mount $MOUNTPOINT
	wait_for_export
	find $ROOTDIR -mindepth 1 | while read f ; do
		if coinflip 33 ; then
			$SUDO rm -rf "$f"
		fi
	done
done
