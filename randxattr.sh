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

	for f in $MOUNTPOINT/* $MOUNTPOINT/.* ; do
		if coinflip 50 ; then
			v=`randbase64`
			$SUDO setfattr -h -n trusted.foo -v 0s$v "$f"
		else
			$SUDO setfattr -h -x trusted.foo "$f"
		fi
	done
done
