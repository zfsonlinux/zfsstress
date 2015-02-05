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
	for f in $MOUNTPOINT/* $MOUNTPONINT/.* ; do
		if coinflip 33 ; then
			$SUDO rm "$f"
		fi
	done
done
