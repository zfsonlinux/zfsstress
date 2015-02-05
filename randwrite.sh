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
	# Truncate each file to 0 with 2/3 probability, otherwise
	# write up to MAX_WRITE_SIZE to it.
	for f in $MOUNTPOINT/* $MOUNTPOINT/.* ; do
		wait_for_mount $MOUNTPOINT
		if coinflip 66 ; then
			$SUDO dd oflag=nofollow if=/dev/null of="$f"
			continue
		fi
		$SUDO dd oflag=nofollow if=/dev/urandom of="$f" bs=512 \
			count=$(( $RANDOM % $(( MAX_WRITE_SIZE / 512 )) ))
	done
done
