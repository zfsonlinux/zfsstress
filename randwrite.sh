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
	randsleep
	wait_for_mount $MOUNTPOINT
	wait_for_export
	# Truncate each file to 0 with 2/3 probability, otherwise
	# write up to MAX_WRITE_SIZE to it.
	find $MOUNTPOINT -type f | while read f ; do
		wait_for_mount $MOUNTPOINT
		if coinflip 66 ; then
			$SUDO dd if=/dev/null of="$f"
			continue
		fi
		$SUDO dd if=/dev/urandom of="$f" bs=512 \
			count=$(( $RANDOM % $(( MAX_WRITE_SIZE / 512 )) ))
	done
done
