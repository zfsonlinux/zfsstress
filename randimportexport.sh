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
	set_export_flag
	while ! $SUDO $ZPOOL export $POOL ; do
		sleep 1
	done
	clear_export_flag
	$SUDO rm -f $ROOTDIR/* $ROOTDIR/.*
	$SUDO $ZPOOL import $ZPOOL_IMPORT_OPT $POOL
done
