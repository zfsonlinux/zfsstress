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

	# Creat a snapshot then randomly destroy snapshots
	# with 50% probability.
	$SUDO $ZFS snap $DATASET@`date +%s`
	$SUDO $ZFS list -H -o name -t snap | grep "^$DATASET@" |
	while read snap ; do
		if coinflip 50 ; then
			$SUDO $ZFS destroy $snap
		fi
	done
done
