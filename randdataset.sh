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
	ZFS_CREATE_OPT=""

	if [ x$ZFS_CREATE_RAND_DNODESIZE = "x1" ] ; then
		ZFS_CREATE_OPT+=" -o dnodesize=$(rand_dnodesize)"
	fi

	if [ x$ZFS_CREATE_RAND_RECORDSIZE = "x1" ] ; then
		ZFS_CREATE_OPT+=" -o recordsize=$(rand_recordsize)"
	fi

	if [ x$ZFS_CREATE_RAND_COMPRESSION = "x1" ] ; then
		ZFS_CREATE_OPT+=" -o compression=$(rand_compression)"
	fi
	# Create a dataset then randomly destroy datasets
	# with 50% probability.
	$SUDO $ZFS create $ZFS_CREATE_OPT $POOL/`mktemp -u XXXXXXXX`
	$SUDO $ZFS list -H -o name -t filesystem| grep /| grep -v "^$DATASET$"|
	while read ds ; do
		if coinflip 50 ; then
			$SUDO $ZFS destroy $ds
		fi
	done
done
