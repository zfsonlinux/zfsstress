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
	size=$(( 512 * $(( 1 + $RANDOM % 32 )) ))
	$SUDO $ZFS set dnodesize=$size $DATASET
done
