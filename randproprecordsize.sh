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
	# powers of 2 between 512 and 8MiB
	P2=$(( 9 + $(( $RANDOM % 15 )) ))
	size=$(( 2 ** $P2 ))
	$SUDO $ZFS set recordsize=$size $DATASET
done
