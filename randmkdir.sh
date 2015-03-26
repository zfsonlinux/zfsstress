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
	for ((i=0; i< $(( $RANDOM % 64 )); i++)) ; do
		wait_for_mount $MOUNTPOINT
		wait_for_export
		parent=`rand_directory`
		newdir="`randstring $(( 1 + $RANDOM % $MAX_FILENAME_LEN ))`"
		$SUDO mkdir "$parent/$newdir"
	done
	randsleep 60
done
