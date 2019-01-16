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
	$SUDO $ZFS list -H -o name -t filesystem |
		grep -e "^$DATASET$" -e "^$DATASET/" |
	while read ds ; do
		if coinflip 80 ; then
			xattr="sa"
		else
			xattr="on"
		fi
		$SUDO $ZFS set xattr=$xattr $ds
	done
done
