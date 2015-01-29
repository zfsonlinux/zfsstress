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
	while ! $SUDO $ZPOOL export $POOL ; do
		sleep 1
	done
	$SUDO rm -f $MOUNTPOINT/*
	$SUDO $ZPOOL import $ZPOOL_IMPORT_OPT $POOL
done
