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

	# Creat a snapshot then randomly destroy snapshots
	# with 50% probability.
	ds=`rand_dataset`
	snap=$(mktemp -u `perl -e 'print "X" x int rand 255 + 1'`)
	$SUDO $ZFS snap $ds@$snap
	$SUDO $ZFS list -H -o name -t snap |
		grep -e "^$DATASET@" -e "^$DATASET/.*@" |
	while read snap ; do
		if coinflip 50 ; then
			$SUDO $ZFS destroy $snap
		fi
	done
done
