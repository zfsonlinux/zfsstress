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

	# Create some datasets then randomly destroy datasets
	# with 50% probability.
	let loops=$(( $RANDOM % 64 ))
	for ((i=0; i< ${loops} ; i++)) ; do
		parent=`rand_dataset`
		ds=$(mktemp -u `perl -e 'print "X" x int rand 255 + 1'`)
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
		$SUDO $ZFS create $ZFS_CREATE_OPT $parent/$ds
	done
	$SUDO $ZFS list -H -o name -t filesystem| grep "^$DATASET/"|
	while read ds ; do
		if coinflip 50 ; then
			$SUDO $ZFS destroy -rR $ds
		fi
	done
done
