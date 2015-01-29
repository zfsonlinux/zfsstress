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
	randsleep 300
	if $SUDO $ZPOOL export $POOL ; then
		$SUDO rm -f $MOUNTPOINT/*
		$SUDO $ZPOOL import $ZPOOL_DEVDIR_OPT $POOL
	fi
done
