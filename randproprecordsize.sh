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
	$SUDO $ZFS list -H -o name -t filesystem |
		grep -e "^$DATASET$" -e "^$DATASET/" |
	while read ds ; do
		size=`rand_recordsize`
		$SUDO $ZFS set recordsize=$size $ds
	done
done
