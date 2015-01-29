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

	# Create a dataset then randomly destroy datasets
	# with 50% probability.
	$SUDO $ZFS create $POOL/`mktemp -u XXXXXXXX`
	$SUDO $ZFS list -H -o name -t filesystem| grep /| grep -v "^$DATASET$"|
	while read ds ; do
		if coinflip 50 ; then
			$SUDO $ZFS destroy $ds
		fi
	done
done
